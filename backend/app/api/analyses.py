"""
MaddeNet — Analiz Endpoint'leri

POST   /api/analyses           → Belgeyi analiz et
GET    /api/analyses           → Analizleri listele
GET    /api/analyses/{id}      → Tek analiz detayi (tum maddeler)
DELETE /api/analyses/{id}      → Analizi sil
"""

from fastapi import APIRouter, Depends, status

from app.api.deps import CurrentUser, get_current_user, get_openai_key
from app.models import (
    AnalysisCreateRequest,
    AnalysisDetailResponse,
    AnalysisListResponse,
)
from app.services.analysis_service import (
    delete_analysis,
    get_analysis_detail,
    list_analyses,
    run_analysis,
)

router = APIRouter(prefix="/api/analyses", tags=["Analizler"])


@router.post(
    "",
    response_model=AnalysisDetailResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Sozlesme analiz et",
    description=(
        "Daha once yuklenmis bir belgeyi analiz eder. "
        "PDF'den metin cikarilir, her madde ChromaDB'deki kanunlarla "
        "karsilastirilir ve RED/YELLOW/GREEN risk seviyeleri atanir."
    ),
)
async def create_analysis_endpoint(
    body: AnalysisCreateRequest,
    current_user: CurrentUser = Depends(get_current_user),
    api_key: str = Depends(get_openai_key),
) -> AnalysisDetailResponse:
    return await run_analysis(
        belge_id=body.belge_id,
        user_id=current_user.user_id,
        sozlesme_turu=body.sozlesme_turu,
        api_key=api_key,
    )


@router.get(
    "",
    response_model=AnalysisListResponse,
    summary="Analizlerimi listele",
    description="Giris yapan kullanicinin tum analizlerini ozet olarak getirir.",
)
async def list_analyses_endpoint(
    current_user: CurrentUser = Depends(get_current_user),
) -> AnalysisListResponse:
    analizler = await list_analyses(user_id=current_user.user_id)
    return AnalysisListResponse(analizler=analizler, toplam=len(analizler))


@router.get(
    "/{analiz_id}",
    response_model=AnalysisDetailResponse,
    summary="Analiz detayi",
    description="Tek bir analizin tum madde detaylarini, kanun dayanaklarini ve onerileri dondurur.",
)
async def get_analysis_endpoint(
    analiz_id: str,
    current_user: CurrentUser = Depends(get_current_user),
) -> AnalysisDetailResponse:
    return await get_analysis_detail(
        analiz_id=analiz_id,
        user_id=current_user.user_id,
    )


@router.delete(
    "/{analiz_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    summary="Analizi sil",
    description="Analizi ve tum madde kayitlarini kalici olarak siler.",
)
async def delete_analysis_endpoint(
    analiz_id: str,
    current_user: CurrentUser = Depends(get_current_user),
) -> None:
    await delete_analysis(analiz_id=analiz_id, user_id=current_user.user_id)
