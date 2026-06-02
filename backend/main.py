from dotenv import load_dotenv
load_dotenv()  # .env dosyasını yükle — uvicorn başlamadan önce çalışmalı

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.analyses import router as analyses_router
from app.api.documents import router as documents_router
from app.api.rag import router as rag_router
from app.api.users import router as users_router

app = FastAPI(
    title="MaddeNet API",
    description=(
        "Sozlesme risk analizi platformu. "
        "PDF sozlesmelerini yukleyin, AI ile analiz ettirin, "
        "RED/YELLOW/GREEN risk seviyelerini gorun."
    ),
    version="0.2.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:8081"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Router Kayitlari ──────────────────────────────────────────────────────────
app.include_router(documents_router)
app.include_router(analyses_router)
app.include_router(users_router)
app.include_router(rag_router)


# ── Sistem Endpoint'leri ──────────────────────────────────────────────────────
@app.get("/health", tags=["Sistem"])
async def health_check() -> dict[str, str]:
    return {"status": "ok", "service": "MaddeNet API", "version": "0.2.0"}
