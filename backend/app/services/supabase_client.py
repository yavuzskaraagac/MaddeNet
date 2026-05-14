"""
MaddeNet — Supabase Client
--------------------------
Service role key ile calisan singleton client.
RLS'yi bypass ederek sunucu tarafli islemler yapar.
"""

import os

from supabase import Client, create_client

_client: Client | None = None


def get_supabase_client() -> Client:
    """
    Supabase service role client'i dondurur.
    Service role key, RLS politikalarini bypass eder — sadece backend'de kullanilir.
    """
    global _client
    if _client is None:
        url = os.getenv("SUPABASE_URL", "")
        key = os.getenv("SUPABASE_SERVICE_ROLE_KEY", "")
        if not url or not key:
            raise RuntimeError(
                "SUPABASE_URL ve SUPABASE_SERVICE_ROLE_KEY ortam degiskenleri ayarlanmali."
            )
        _client = create_client(url, key)
    return _client
