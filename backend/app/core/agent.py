"""
MaddeNet — Pydantic AI Sozlesme Risk Analizi Agenti

Mimari:
    contract_agent  →  kanun_ara (RAG tool)
                    →  sozlesme_turu_belirle (opsiyonel tool)
    analyze_contract()  →  orkestrasyon fonksiyonu (FastAPI'dan cagirilir)

Pydantic AI v1.x API kullanilmaktadir (output_type, RunContext, ModelRetry).
"""

import re
import uuid
from dataclasses import dataclass

from pydantic_ai import Agent, ModelRetry, RunContext
from pydantic_ai.models.openai import OpenAIModel
from pydantic_ai.models.test import TestModel
from pydantic_ai.usage import UsageLimits

from app.core.deps import AnalysisDeps
from app.core.prompts import SYSTEM_PROMPT, build_clause_prompt, build_contract_type_prompt
from app.models import ClauseAnalysis, ContractAnalysisResult, RiskLevel, SozlesmeTuru
from app.services.rag_service import search_relevant_laws


# ── Model Secimi ──────────────────────────────────────────────────────────────

def _get_model(api_key: str) -> OpenAIModel | TestModel:
    """
    API key varsa OpenAI GPT-4o, yoksa TestModel doner.
    GPT-5 ciktiginda model adini 'gpt-4o' -> 'gpt-5' olarak degistir.
    """
    if api_key:
        return OpenAIModel("gpt-4o", api_key=api_key)
    return TestModel()


# ── Agent Tanimi ──────────────────────────────────────────────────────────────
# Modul yuklenirken API key gerekmemesi icin defer_model_check=True kullanilir.
# Gercek model agent.run(..., model=_get_model(api_key)) ile gecilir.

contract_agent: Agent[AnalysisDeps, ClauseAnalysis] = Agent(
    model=TestModel(),
    deps_type=AnalysisDeps,
    output_type=ClauseAnalysis,
    system_prompt=SYSTEM_PROMPT,
    retries=2,
)


# ── Dinamik Sistem Promptu ────────────────────────────────────────────────────

@contract_agent.system_prompt
async def add_mode_warning(ctx: RunContext[AnalysisDeps]) -> str:
    """API key yoksa test modu uyarisi ekler."""
    if ctx.deps.is_mock:
        return (
            "\nUYARI: Su an test modundasin (OpenAI API key yok). "
            "Gercek analiz yapilmayacak, ornekleme degerler donulecek."
        )
    return ""


# ── Tool 1: kanun_ara (zorunlu RAG entegrasyonu) ──────────────────────────────

@contract_agent.tool
async def kanun_ara(
    ctx: RunContext[AnalysisDeps],
    madde_metni: str,
) -> str:
    """
    Verilen sozlesme maddesiyle alakali Turk kanun maddelerini ChromaDB'de arar.
    Her madde analizinden once bu araci kullanmak zorunludur.

    Args:
        madde_metni: Aranacak sozlesme maddesi metni
    """
    results = search_relevant_laws(
        clause_text=madde_metni,
        n_results=3,
        kategori_filtre=ctx.deps.kategori_filtre,
    )

    if not results:
        raise ModelRetry(
            "Bu maddeyle ilgili kanun bulunamadi. "
            "Daha genel bir ifadeyle veya farkli anahtar kelimelerle tekrar ara."
        )

    satirlar = []
    for r in results:
        satirlar.append(
            f"[{r.kanun_adi} - Madde {r.madde_no}] "
            f"(Benzerlik: {r.benzerlik_skoru:.0%})\n"
            f"{r.icerik[:400]}"
        )

    return "\n\n---\n\n".join(satirlar)


# ── Tool 2: sozlesme_turu_belirle (opsiyonel) ─────────────────────────────────

@dataclass
class _TurResult:
    tur: str


_tur_agent: Agent[None, _TurResult] = Agent(
    model=TestModel(),
    output_type=_TurResult,
    system_prompt=(
        "Sozlesme metnine bakarak turunu belirle. "
        "Sadece su degerlerden birini dondur: "
        "kira, is_sozlesmesi, ticari, tuketici, genel"
    ),
)


async def detect_contract_type(
    sozlesme_metni: str,
    api_key: str,
) -> SozlesmeTuru:
    """Sozlesme metninden turu otomatik olarak tespit eder."""
    if not api_key:
        return SozlesmeTuru.GENEL

    model = OpenAIModel("gpt-4o", api_key=api_key)
    result = await _tur_agent.run(
        build_contract_type_prompt(sozlesme_metni),
        model=model,
    )
    try:
        return SozlesmeTuru(result.output.tur)
    except ValueError:
        return SozlesmeTuru.GENEL


# ── Madde Bolme Yardimcisi ────────────────────────────────────────────────────

_MADDE_RE = re.compile(r"(?:MADDE|Madde)\s+(\d+)\s*[-–—:.]", re.MULTILINE)


def _split_clauses(sozlesme_metni: str) -> list[tuple[str, str]]:
    """
    Sozlesme metnini bireysel maddelere boler.
    Dondurulen format: [(madde_no, madde_metni), ...]

    Eger madde yapisi bulunamazsa metni paragraflara gore boler.
    """
    matches = list(_MADDE_RE.finditer(sozlesme_metni))

    if matches:
        parcalar: list[tuple[str, str]] = []
        for i, m in enumerate(matches):
            no = m.group(1)
            baslangic = m.start()
            bitis = matches[i + 1].start() if i + 1 < len(matches) else len(sozlesme_metni)
            metin = sozlesme_metni[baslangic:bitis].strip()
            if len(metin) > 20:
                parcalar.append((no, metin))
        return parcalar

    # Madde yapisi yoksa paragraflara bol
    paragraflar = [p.strip() for p in sozlesme_metni.split("\n\n") if len(p.strip()) > 20]
    return [(str(i + 1), p) for i, p in enumerate(paragraflar)]


# ── Risk Skoru Hesaplama ──────────────────────────────────────────────────────

def _calculate_risk_score(maddeler: list[ClauseAnalysis]) -> int:
    """
    Maddelerin risk seviyelerine gore 0-100 arasi genel skor hesaplar.
    RED=100, YELLOW=50, GREEN=0 agirliklarinin ortalamasi.
    """
    if not maddeler:
        return 0

    agirliklar = {RiskLevel.RED: 100, RiskLevel.YELLOW: 50, RiskLevel.GREEN: 0}
    toplam = sum(agirliklar[m.risk_seviyesi] for m in maddeler)
    return round(toplam / len(maddeler))


# ── Ana Orkestrasyon Fonksiyonu ───────────────────────────────────────────────

async def analyze_contract(
    sozlesme_metni: str,
    sozlesme_turu: SozlesmeTuru,
    api_key: str,
    belge_id: str | None = None,
) -> ContractAnalysisResult:
    """
    Tam sozlesme analizi yapar ve yapilandirilmis sonuc dondurur.

    Bu fonksiyon FastAPI endpoint'inden cagirilir.

    Args:
        sozlesme_metni: PDF'den cikarilmis tam sozlesme metni
        sozlesme_turu:  Sozlesme turu (kira, is, ticari, tuketici, genel)
        api_key:        OpenAI API key; bossa mock modda calisir
        belge_id:       Opsiyonel belge ID; verilmezse UUID uretilir

    Returns:
        ContractAnalysisResult: Tum maddelerin analizi + genel risk skoru
    """
    belge_id = belge_id or str(uuid.uuid4())
    model = _get_model(api_key)

    deps = AnalysisDeps(
        sozlesme_turu=sozlesme_turu,
        openai_api_key=api_key,
    )

    maddeler_raw = _split_clauses(sozlesme_metni)
    analiz_sonuclari: list[ClauseAnalysis] = []

    for madde_no, madde_metni in maddeler_raw:
        prompt = build_clause_prompt(madde_no, madde_metni, sozlesme_turu.value)

        result = await contract_agent.run(
            prompt,
            model=model,
            deps=deps,
            usage_limits=UsageLimits(request_tokens_limit=8_000),
        )

        # output_type=ClauseAnalysis oldugu icin result.output dogrudan modeli verir
        analiz: ClauseAnalysis = result.output
        analiz = analiz.model_copy(update={"madde_metni": madde_metni})
        analiz_sonuclari.append(analiz)

    return ContractAnalysisResult(
        belge_id=belge_id,
        sozlesme_turu=sozlesme_turu,
        maddeler=analiz_sonuclari,
        genel_risk_skoru=_calculate_risk_score(analiz_sonuclari),
    )
