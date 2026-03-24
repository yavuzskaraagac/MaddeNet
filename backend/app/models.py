from pydantic import BaseModel
from enum import Enum


class RiskLevel(str, Enum):
    RED = "red"
    YELLOW = "yellow"
    GREEN = "green"


class ClauseAnalysis(BaseModel):
    madde_no: str
    madde_metni: str
    risk_seviyesi: RiskLevel
    sade_aciklama: str
    kanun_dayanagi: str | None = None
    kanun_maddesi: str | None = None
    oneri: str | None = None


class ContractAnalysisResult(BaseModel):
    belge_id: str
    sozlesme_turu: str
    maddeler: list[ClauseAnalysis]
    genel_risk_skoru: int  # 0-100


class LawChunk(BaseModel):
    kanun_adi: str
    kanun_no: str
    madde_no: str
    icerik: str
    kategori: str
    risk_etiketleri: list[str]
