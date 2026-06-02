"""
MaddeNet — Belge Endpoint'leri

POST   /api/documents/upload   → PDF yukle
GET    /api/documents          → Belgeleri listele
GET    /api/documents/{id}     → Tek belge
DELETE /api/documents/{id}     → Belgeyi sil
"""

from fastapi import APIRouter, Depends, HTTPException, UploadFile, status

from app.api.deps import CurrentUser, get_current_user
from app.models import DocumentListResponse, DocumentResponse
from app.services.document_service import (
    delete_document,
    get_document,
    list_documents,
    upload_document,
)
from app.services.supabase_client import get_supabase_client

router = APIRouter(prefix="/api/documents", tags=["Belgeler"])


@router.post(
    "/upload",
    response_model=DocumentResponse,
    status_code=status.HTTP_201_CREATED,
    summary="PDF sozlesme yukle",
    description="PDF dosyasini Supabase Storage'a yukler ve kayit olusturur.",
)
async def upload_document_endpoint(
    file: UploadFile,
    current_user: CurrentUser = Depends(get_current_user),
) -> DocumentResponse:
    return await upload_document(file=file, user_id=current_user.user_id)


@router.get(
    "",
    response_model=DocumentListResponse,
    summary="Belgelerimi listele",
    description="Giris yapan kullanicinin tum belgelerini tarihe gore sirali getirir.",
)
async def list_documents_endpoint(
    current_user: CurrentUser = Depends(get_current_user),
) -> DocumentListResponse:
    belgeler = await list_documents(user_id=current_user.user_id)
    return DocumentListResponse(belgeler=belgeler, toplam=len(belgeler))


@router.get(
    "/{belge_id}",
    response_model=DocumentResponse,
    summary="Tek belge detayi",
)
async def get_document_endpoint(
    belge_id: str,
    current_user: CurrentUser = Depends(get_current_user),
) -> DocumentResponse:
    return await get_document(belge_id=belge_id, user_id=current_user.user_id)


@router.get(
    "/{belge_id}/download",
    summary="Guvenli indirme URL'i",
    description="60 saniye gecerli imzali indirme URL'i dondurur.",
)
async def download_url_endpoint(
    belge_id: str,
    current_user: CurrentUser = Depends(get_current_user),
) -> dict:
    supabase = get_supabase_client()
    try:
        row = (
            supabase.table("documents")
            .select("storage_path, file_name")
            .eq("id", belge_id)
            .eq("user_id", current_user.user_id)
            .single()
            .execute()
        )
    except Exception:
        raise HTTPException(status_code=404, detail="Belge bulunamadi.")

    storage_path: str = row.data["storage_path"]
    file_name: str = row.data["file_name"]

    try:
        signed = supabase.storage.from_("contracts").create_signed_url(
            storage_path, expires_in=60
        )
        return {"url": signed["signedURL"], "file_name": file_name}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"URL olusturulamadi: {e}")


@router.delete(
    "/{belge_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Belgeyi sil",
    description="Belgeyi, ilisikli analizleri ve Storage dosyasini kalici olarak siler.",
)
async def delete_document_endpoint(
    belge_id: str,
    current_user: CurrentUser = Depends(get_current_user),
) -> None:
    await delete_document(belge_id=belge_id, user_id=current_user.user_id)
