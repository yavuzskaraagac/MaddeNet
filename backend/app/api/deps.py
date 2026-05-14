"""
MaddeNet — API Bagimliliklari
------------------------------
FastAPI Depends() ile kullanilanlar:
  - get_current_user: Supabase JWT'yi dogrular, user_id dondurur
  - get_openai_key:   .env'den OpenAI API key dondurur
"""

import os
from dataclasses import dataclass

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.services.supabase_client import get_supabase_client

_bearer = HTTPBearer()


@dataclass
class CurrentUser:
    user_id: str
    email: str
    token: str


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(_bearer),
) -> CurrentUser:
    """
    Authorization: Bearer <supabase_jwt> headerini dogrular.
    Gecersiz veya suresi dolmus token'da 401 firlatir.
    """
    token = credentials.credentials
    try:
        supabase = get_supabase_client()
        response = supabase.auth.get_user(token)
        if not response.user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Gecersiz veya suresi dolmus token.",
            )
        return CurrentUser(
            user_id=response.user.id,
            email=response.user.email or "",
            token=token,
        )
    except HTTPException:
        raise
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Kimlik dogrulama basarisiz.",
        )


def get_openai_key() -> str:
    """
    OPENAI_API_KEY ortam degiskenini dondurur.
    Ayarli degilse bos string — agent TestModel modunda calisir.
    """
    return os.getenv("OPENAI_API_KEY", "")
