"""
MaddeNet — Document Service
----------------------------
Supabase Storage'a PDF yukler ve documents tablosunu yonetir.
Bucket adi: "contracts"
"""

import re
import unicodedata
import uuid
from datetime import datetime

from fastapi import HTTPException, UploadFile, status

from app.models import DocumentResponse, DocumentStatus
from app.services.supabase_client import get_supabase_client

BUCKET = "contracts"
MAX_FILE_SIZE = 20 * 1024 * 1024  # 20 MB


def _sanitize_filename(name: str) -> str:
    """Türkçe karakter ve boşlukları Supabase Storage için güvenli hale getirir."""
    name = unicodedata.normalize("NFKD", name)
    name = name.encode("ascii", "ignore").decode("ascii")
    name = re.sub(r"[^\w\-.]", "_", name)
    name = re.sub(r"_+", "_", name)
    return name.strip("_")


async def upload_document(
    file: UploadFile,
    user_id: str,
) -> DocumentResponse:
    """
    PDF dosyasini Supabase Storage'a yukler ve documents tablosuna kaydeder.

    Depolama yolu: contracts/{user_id}/{belge_id}/{dosya_adi}
    Bu yapi sayesinde her kullanicinin dosyalari ayri klasorde tutulur.
    """
    if file.content_type not in ("application/pdf", "application/octet-stream"):
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Sadece PDF dosyasi yuklenebilir.",
        )

    icerik = await file.read()
    if len(icerik) > MAX_FILE_SIZE:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Dosya boyutu {MAX_FILE_SIZE // (1024*1024)} MB sinirini asiyor.",
        )

    belge_id = str(uuid.uuid4())
    safe_name = _sanitize_filename(file.filename or "belge.pdf")
    storage_path = f"{user_id}/{belge_id}/{safe_name}"

    supabase = get_supabase_client()

    try:
        supabase.storage.from_(BUCKET).upload(
            path=storage_path,
            file=icerik,
            file_options={"content-type": "application/pdf"},
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Dosya yuklenirken hata olustu: {str(e)}",
        )

    public_url = supabase.storage.from_(BUCKET).get_public_url(storage_path)

    try:
        result = (
            supabase.table("documents")
            .insert({
                "id": belge_id,
                "user_id": user_id,
                "file_name": file.filename,
                "file_url": public_url,
                "file_size": len(icerik),
                "storage_path": storage_path,
                "status": DocumentStatus.PENDING.value,
            })
            .execute()
        )
    except Exception as e:
        # Storage'a yuklendi ama DB'ye kaydedilemedi — storage'i temizle
        try:
            supabase.storage.from_(BUCKET).remove([storage_path])
        except Exception:
            pass
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Belge kaydedilemedi: {str(e)}",
        )

    row = result.data[0]
    return DocumentResponse(
        id=row["id"],
        file_name=row["file_name"],
        file_url=row["file_url"],
        file_size=row["file_size"],
        status=DocumentStatus(row["status"]),
        created_at=datetime.fromisoformat(row["created_at"]),
    )


async def list_documents(user_id: str) -> list[DocumentResponse]:
    """Kullanicinin tum belgelerini tarihe gore sirali getirir."""
    supabase = get_supabase_client()
    try:
        result = (
            supabase.table("documents")
            .select("*")
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .execute()
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Belgeler getirilemedi: {str(e)}",
        )

    return [
        DocumentResponse(
            id=row["id"],
            file_name=row["file_name"],
            file_url=row["file_url"],
            file_size=row["file_size"],
            status=DocumentStatus(row["status"]),
            created_at=datetime.fromisoformat(row["created_at"]),
        )
        for row in result.data
    ]


async def get_document(belge_id: str, user_id: str) -> DocumentResponse:
    """Tek bir belgeyi getirir. Kullaniciya ait degilse 404 firlatir."""
    supabase = get_supabase_client()
    try:
        result = (
            supabase.table("documents")
            .select("*")
            .eq("id", belge_id)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Belge bulunamadi.",
        )

    row = result.data
    return DocumentResponse(
        id=row["id"],
        file_name=row["file_name"],
        file_url=row["file_url"],
        file_size=row["file_size"],
        status=DocumentStatus(row["status"]),
        created_at=datetime.fromisoformat(row["created_at"]),
    )


async def delete_document(belge_id: str, user_id: str) -> None:
    """Belgeyi ve ilisikli analizleri siler. Storage'dan da kaldirir."""
    supabase = get_supabase_client()

    # Once belgenin bu kullaniciya ait oldugunu dogrula
    try:
        result = (
            supabase.table("documents")
            .select("storage_path")
            .eq("id", belge_id)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Belge bulunamadi.",
        )

    storage_path: str = result.data.get("storage_path", "")

    # DB'den sil (CASCADE ile analysis_items da silinir)
    try:
        supabase.table("documents").delete().eq("id", belge_id).execute()
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Belge silinemedi: {str(e)}",
        )

    # Storage'dan sil (hata olursa sessizce gec — DB zaten temizlendi)
    if storage_path:
        try:
            supabase.storage.from_(BUCKET).remove([storage_path])
        except Exception:
            pass


async def download_document_bytes(belge_id: str, user_id: str) -> bytes:
    """
    Belgenin PDF icerigini Supabase Storage'dan indirir.
    Analysis service tarafindan Unstructured'a gecirmek icin kullanilir.
    """
    supabase = get_supabase_client()

    try:
        result = (
            supabase.table("documents")
            .select("storage_path")
            .eq("id", belge_id)
            .eq("user_id", user_id)
            .single()
            .execute()
        )
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Belge bulunamadi.",
        )

    storage_path: str = result.data["storage_path"]

    try:
        pdf_bytes: bytes = supabase.storage.from_(BUCKET).download(storage_path)
        return pdf_bytes
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Dosya indirilemedi: {str(e)}",
        )
