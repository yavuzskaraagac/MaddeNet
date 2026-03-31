from pydantic import BaseModel, Field
from enum import Enum


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
