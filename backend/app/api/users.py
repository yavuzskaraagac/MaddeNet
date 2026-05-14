"""
MaddeNet — Kullanici Endpoint'leri

GET /api/users/me  → Mevcut kullanici profili
"""

from fastapi import APIRouter, Depends, HTTPException, status

from app.api.deps import CurrentUser, get_current_user
from app.models import UserProfile
from app.services.supabase_client import get_supabase_client

router = APIRouter(prefix="/api/users", tags=["Kullanici"])


@router.get(
    "/me",
    response_model=UserProfile,
    summary="Profil bilgileri",
    description="JWT token'a gore giris yapan kullanicinin profil bilgilerini dondurur.",
)
async def get_me(
    current_user: CurrentUser = Depends(get_current_user),
) -> UserProfile:
    supabase = get_supabase_client()
    try:
        result = (
            supabase.table("profiles")
            .select("*")
            .eq("id", current_user.user_id)
            .single()
            .execute()
        )
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Kullanici profili bulunamadi.",
        )

    row = result.data
    return UserProfile(
        id=row["id"],
        email=current_user.email,
        full_name=row.get("full_name"),
        avatar_url=row.get("avatar_url"),
        created_at=row.get("created_at"),
    )
