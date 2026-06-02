import logging
import os
from dataclasses import dataclass

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer

from app.services.supabase_client import get_supabase_client

logger = logging.getLogger(__name__)
_bearer = HTTPBearer()


@dataclass
class CurrentUser:
    user_id: str
    email: str
    token: str


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(_bearer),
) -> CurrentUser:
    token = credentials.credentials
    try:
        supabase = get_supabase_client()
        response = supabase.auth.get_user(token)
        if not response.user:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Token gecersiz: kullanici bulunamadi.",
            )
        return CurrentUser(
            user_id=response.user.id,
            email=response.user.email or "",
            token=token,
        )
    except HTTPException:
        raise
    except Exception as e:
        err_msg = f"{type(e).__name__}: {str(e)}"
        logger.error(f"Auth hatasi: {err_msg}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=err_msg,
        )


def get_openai_key() -> str:
    return os.getenv("OPENAI_API_KEY", "")
