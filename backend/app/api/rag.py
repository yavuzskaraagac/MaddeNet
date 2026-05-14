"""
MaddeNet — RAG / Sistem Endpoint'leri

GET /api/rag/stats  → ChromaDB istatistikleri
"""

from fastapi import APIRouter, HTTPException, status

from app.models import RAGStatsResponse
from app.services.rag_service import get_collection_stats

router = APIRouter(prefix="/api/rag", tags=["Sistem"])


@router.get(
    "/stats",
    response_model=RAGStatsResponse,
    summary="ChromaDB istatistikleri",
    description="Veritabanindaki toplam kanun maddesi sayisini ve koleksiyon durumunu dondurur.",
)
async def get_rag_stats() -> RAGStatsResponse:
    try:
        stats = get_collection_stats()
        return RAGStatsResponse(
            toplam_kanun_maddesi=stats["toplam_madde"],
            koleksiyon_adi="turkish_laws",
            durum="aktif",
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"ChromaDB'ye erisilemiyor: {str(e)}",
        )
