from datetime import datetime
from enum import Enum

from pydantic import BaseModel, Field


class RiskLevel(str, Enum):
    RED = "red"
    YELLOW = "yellow"
    GREEN = "green"


class SozlesmeTuru(str, Enum):
    KIRA = "kira"
    IS_SOZLESMESI = "is_sozlesmesi"
    TICARI = "ticari"
    TUKETICI = "tuketici"
    GENEL = "genel"


class ClauseAnalysis(BaseModel):
    madde_no: str = Field(description="Sozlesmedeki madde numarasi veya siralama (orn: '1', '2a')")
    madde_metni: str = Field(description="Analiz edilen sozlesme maddesinin tam metni")
    risk_seviyesi: RiskLevel = Field(description="red=yuksek risk, yellow=dikkat, green=standart")
    sade_aciklama: str = Field(description="Maddenin ne anlama geldiginin halk dilinde aciklamasi")
    kanun_dayanagi: str | None = Field(default=None, description="Ilgili kanunun adi (orn: 'Turk Borclar Kanunu')")
    kanun_maddesi: str | None = Field(default=None, description="Ilgili kanun madde numarasi (orn: 'Madde 301')")
    oneri: str | None = Field(default=None, description="RED veya YELLOW icin kullaniciya pratik oneri")
    rag_bulunan: bool = Field(default=False, description="ChromaDB'de ilgili kanun bulundu mu?")
    rag_max_benzerlik: float | None = Field(default=None, description="RAG aramasindaki en yuksek benzerlik skoru (0-1)")


class ContractAnalysisResult(BaseModel):
    belge_id: str
    sozlesme_turu: SozlesmeTuru
    maddeler: list[ClauseAnalysis]
    genel_risk_skoru: int = Field(ge=0, le=100, description="0-100 arasi genel risk skoru")


class LawChunk(BaseModel):
    kanun_adi: str
    kanun_no: str
    madde_no: str
    icerik: str
    kategori: str
    risk_etiketleri: list[str]


# ── Document Schemas ──────────────────────────────────────────────────────────

class DocumentStatus(str, Enum):
    PENDING = "uploaded"       # DB'de "uploaded"
    PROCESSING = "processing"  # DB'de "processing"
    COMPLETED = "analyzed"     # DB'de "analyzed"
    FAILED = "error"           # DB'de "error"


class DocumentResponse(BaseModel):
    id: str
    file_name: str
    file_url: str
    file_size: int
    status: DocumentStatus
    created_at: datetime


class DocumentListResponse(BaseModel):
    belgeler: list[DocumentResponse]
    toplam: int


# ── Analysis Schemas ──────────────────────────────────────────────────────────

class AnalysisCreateRequest(BaseModel):
    belge_id: str = Field(description="Analiz edilecek belgenin ID'si")
    sozlesme_turu: SozlesmeTuru = Field(
        default=SozlesmeTuru.GENEL,
        description="Sozlesme turu; bilinmiyorsa 'genel' sec",
    )


class AnalysisSummary(BaseModel):
    id: str
    belge_id: str
    sozlesme_turu: SozlesmeTuru
    genel_risk_skoru: int
    genel_risk_seviyesi: RiskLevel
    madde_sayisi: int
    created_at: datetime


class AnalysisListResponse(BaseModel):
    analizler: list[AnalysisSummary]
    toplam: int


class AnalysisDetailResponse(BaseModel):
    id: str
    belge_id: str
    sozlesme_turu: SozlesmeTuru
    genel_risk_skoru: int
    genel_risk_seviyesi: RiskLevel
    maddeler: list[ClauseAnalysis]
    created_at: datetime


# ── User Schemas ──────────────────────────────────────────────────────────────

class UserProfile(BaseModel):
    id: str
    email: str
    full_name: str | None = None
    avatar_url: str | None = None
    created_at: datetime | None = None


# ── RAG / System Schemas ──────────────────────────────────────────────────────

class RAGStatsResponse(BaseModel):
    toplam_kanun_maddesi: int
    koleksiyon_adi: str
    durum: str
