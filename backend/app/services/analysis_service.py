"""
MaddeNet — Analysis Service
-----------------------------
PDF'den metin cikarma, agent calistirma ve Supabase'e kaydetme
islemlerini ust uste baglar.

Pipeline:
    PDF bytes
      -> Unstructured.io (metin cikarma)
      -> analyze_contract() (Pydantic AI + ChromaDB)
      -> Supabase analyses + analysis_items tablolari
      -> AnalysisDetailResponse
"""

import asyncio
import uuid
from datetime import datetime
from functools import partial

from fastapi import HTTPException, status

from app.core.agent import analyze_contract
from app.models import (
    AnalysisDetailResponse,
    AnalysisSummary,
    ClauseAnalysis,
    DocumentStatus,
    RiskLevel,
    SozlesmeTuru,
)
from app.services.document_service import download_document_bytes
from app.services.supabase_client import get_supabase_client


# ── PDF Metin Cikarma ─────────────────────────────────────────────────────────

def _extract_text_sync(pdf_bytes: bytes) -> str:
    """pypdf ile PDF'den metin cikarir (senkron, Windows uyumlu)."""
    import io
    from pypdf import PdfReader

    reader = PdfReader(io.BytesIO(pdf_bytes))
    parcalar: list[str] = []
    for page in reader.pages:
        text = page.extract_text() or ""
        text = text.strip()
        if text:
            parcalar.append(text)
    return "\n\n".join(parcalar)


async def extract_text_from_pdf(pdf_bytes: bytes) -> str:
    """
    PDF'den metin cikarir.
    Unstructured senkron oldugu icin thread pool'a gonderilir — FastAPI event loop'u bloklamaz.
    """
    loop = asyncio.get_event_loop()
    text = await loop.run_in_executor(None, partial(_extract_text_sync, pdf_bytes))
    if not text.strip():
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            detail="PDF'den metin cikarilamadi. Dosyanin taranmis goruntu olmadgindan emin olun.",
        )
    return text


# ── Risk Seviyesi Yardimcisi ──────────────────────────────────────────────────

def _genel_risk_seviyesi(skor: int) -> RiskLevel:
    if skor >= 70:
        return RiskLevel.RED
    if skor >= 40:
        return RiskLevel.YELLOW
    return RiskLevel.GREEN


# DB'deki "high/medium/low" değerlerini frontend'in beklediği "red/yellow/green"'e çevirir
_DB_TO_RISK = {"high": RiskLevel.RED, "medium": RiskLevel.YELLOW, "low": RiskLevel.GREEN}
# "red/yellow/green" → DB'ye yazılacak "high/medium/low"
_RISK_TO_DB = {RiskLevel.RED: "high", RiskLevel.YELLOW: "medium", RiskLevel.GREEN: "low"}


# ── Supabase Kayit ────────────────────────────────────────────────────────────

def _save_analysis_to_db(
    analiz_id: str,
    belge_id: str,
    user_id: str,
    sozlesme_turu: SozlesmeTuru,
    genel_risk_skoru: int,
    genel_risk_seviyesi: RiskLevel,
    maddeler: list[ClauseAnalysis],
) -> None:
    """Analiz sonuclarini Supabase'e kaydeder."""
    supabase = get_supabase_client()

    # 1. analyses tablosuna ana kayit
    supabase.table("analyses").insert({
        "id": analiz_id,
        "user_id": user_id,
        "document_id": belge_id,
        "sozlesme_turu": sozlesme_turu.value,
        "overall_risk_score": genel_risk_skoru,
        "overall_risk_level": _RISK_TO_DB[genel_risk_seviyesi],  # red→high, yellow→medium, green→low
        "madde_sayisi": len(maddeler),
    }).execute()

    # 2. analysis_items tablosuna madde bazli kayitlar
    items = [
        {
            "id": str(uuid.uuid4()),
            "analysis_id": analiz_id,
            "madde_no": m.madde_no,
            "original_text": m.madde_metni,
            "plain_language": m.sade_aciklama,
            "risk_color": m.risk_seviyesi.value,
            "legal_reference": m.kanun_dayanagi,
            "kanun_maddesi": m.kanun_maddesi,
            "oneri": m.oneri,
            "rag_bulunan": m.rag_bulunan,
            "rag_max_benzerlik": m.rag_max_benzerlik,
        }
        for m in maddeler
    ]
    supabase.table("analysis_items").insert(items).execute()

    # 3. documents tablosunun status'unu guncelle
    supabase.table("documents").update(
        {"status": DocumentStatus.COMPLETED.value}
    ).eq("id", belge_id).execute()


# ── Ana Analiz Fonksiyonu ─────────────────────────────────────────────────────

async def run_analysis(
    belge_id: str,
    user_id: str,
    sozlesme_turu: SozlesmeTuru,
    api_key: str,
) -> AnalysisDetailResponse:
    """
    Tam analiz pipeline'ini calistirir:
    1. Belgeyi Supabase Storage'dan indir
    2. Unstructured ile metne donustur
    3. Pydantic AI + ChromaDB ile analiz et
    4. Supabase'e kaydet
    5. AnalysisDetailResponse dondur
    """
    supabase = get_supabase_client()

    # Belgenin var oldugunu ve bu kullaniciya ait oldugunu kontrol et
    try:
        supabase.table("documents").select("id").eq(
            "id", belge_id
        ).eq("user_id", user_id).single().execute()
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Belge bulunamadi.",
        )

    # documents.status = "processing" olarak guncelle
    supabase.table("documents").update(
        {"status": DocumentStatus.PROCESSING.value}
    ).eq("id", belge_id).execute()

    try:
        # PDF indir
        pdf_bytes = await download_document_bytes(belge_id, user_id)

        # Metin cikar
        sozlesme_metni = await extract_text_from_pdf(pdf_bytes)

        # Sozlesme turu GENEL ise otomatik tespit dene
        if sozlesme_turu == SozlesmeTuru.GENEL and api_key:
            from app.core.agent import detect_contract_type
            sozlesme_turu = await detect_contract_type(sozlesme_metni, api_key)

        # Agent'i calistir
        from app.models import ContractAnalysisResult
        sonuc: ContractAnalysisResult = await analyze_contract(
            sozlesme_metni=sozlesme_metni,
            sozlesme_turu=sozlesme_turu,
            api_key=api_key,
            belge_id=belge_id,
        )

        genel_seviye = _genel_risk_seviyesi(sonuc.genel_risk_skoru)
        analiz_id = str(uuid.uuid4())

        # Supabase'e kaydet
        _save_analysis_to_db(
            analiz_id=analiz_id,
            belge_id=belge_id,
            user_id=user_id,
            sozlesme_turu=sozlesme_turu,
            genel_risk_skoru=sonuc.genel_risk_skoru,
            genel_risk_seviyesi=genel_seviye,
            maddeler=sonuc.maddeler,
        )

        return AnalysisDetailResponse(
            id=analiz_id,
            belge_id=belge_id,
            sozlesme_turu=sozlesme_turu,
            genel_risk_skoru=sonuc.genel_risk_skoru,
            genel_risk_seviyesi=genel_seviye,
            maddeler=sonuc.maddeler,
            created_at=datetime.utcnow(),
        )

    except HTTPException:
        supabase.table("documents").update(
            {"status": DocumentStatus.FAILED.value}
        ).eq("id", belge_id).execute()
        raise
    except Exception as e:
        supabase.table("documents").update(
            {"status": DocumentStatus.FAILED.value}
        ).eq("id", belge_id).execute()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Analiz sirasinda hata olustu: {str(e)}",
        )


# ── Listeleme ve Detay ────────────────────────────────────────────────────────

async def list_analyses(user_id: str) -> list[AnalysisSummary]:
    """Kullanicinin tum analizlerini ozet olarak getirir."""
    supabase = get_supabase_client()
    try:
        result = (
            supabase.table("analyses")
            .select("id, document_id, sozlesme_turu, overall_risk_score, overall_risk_level, madde_sayisi, created_at")
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .execute()
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Analizler getirilemedi: {str(e)}",
        )

    return [
        AnalysisSummary(
            id=row["id"],
            belge_id=row["document_id"],
            sozlesme_turu=SozlesmeTuru(row["sozlesme_turu"]),
            genel_risk_skoru=row["overall_risk_score"],
            genel_risk_seviyesi=_DB_TO_RISK.get(row["overall_risk_level"], RiskLevel.YELLOW),
            madde_sayisi=row["madde_sayisi"],
            created_at=datetime.fromisoformat(row["created_at"]),
        )
        for row in result.data
    ]


async def get_analysis_detail(analiz_id: str, user_id: str) -> AnalysisDetailResponse:
    """Tek bir analizin tum madde detaylariyla birlikte getirir."""
    supabase = get_supabase_client()

    try:
        analiz_result = (
            supabase.table("analyses")
            .select("*")
            .eq("id", analiz_id)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Analiz bulunamadi.",
        )

    try:
        items_result = (
            supabase.table("analysis_items")
            .select("*")
            .eq("analysis_id", analiz_id)
            .order("madde_no")
            .execute()
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Analiz maddeleri getirilemedi: {str(e)}",
        )

    a = analiz_result.data
    maddeler = [
        ClauseAnalysis(
            madde_no=item["madde_no"],
            madde_metni=item["original_text"],
            risk_seviyesi=RiskLevel(item["risk_color"]),
            sade_aciklama=item["plain_language"],
            kanun_dayanagi=item.get("legal_reference"),
            kanun_maddesi=item.get("kanun_maddesi"),
            oneri=item.get("oneri"),
            rag_bulunan=item.get("rag_bulunan", False),
            rag_max_benzerlik=item.get("rag_max_benzerlik"),
        )
        for item in items_result.data
    ]

    return AnalysisDetailResponse(
        id=a["id"],
        belge_id=a["document_id"],
        sozlesme_turu=SozlesmeTuru(a["sozlesme_turu"]),
        genel_risk_skoru=a["overall_risk_score"],
        genel_risk_seviyesi=_DB_TO_RISK.get(a["overall_risk_level"], RiskLevel.YELLOW),
        maddeler=maddeler,
        created_at=datetime.fromisoformat(a["created_at"]),
    )


async def delete_analysis(analiz_id: str, user_id: str) -> None:
    """Analizi ve tum maddelerini siler (CASCADE)."""
    supabase = get_supabase_client()
    try:
        supabase.table("analyses").select("id").eq(
            "id", analiz_id
        ).eq("user_id", user_id).single().execute()
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Analiz bulunamadi.",
        )
    try:
        supabase.table("analyses").delete().eq("id", analiz_id).execute()
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Analiz silinemedi: {str(e)}",
        )
