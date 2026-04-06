"""
MaddeNet — Hallucinasyon Test Suite
-------------------------------------
Bilinen sozlesme maddeleri gercek beklenen risklerle karsilastirilir.

Kullanim:
    cd backend
    OPENAI_API_KEY=sk-... python scripts/test_hallucination.py

Beklenti:
    - >70% dogru siniflandirma
    - Hic bir sonucta uydurma madde numarasi olmamasi (rag_bulunan=True ise)
    - kanun_maddesi varsa ChromaDB'de gercekten bulunmasi
"""

import asyncio
import os
import sys

# backend/ dizinini path'e ekle
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.core.agent import analyze_contract
from app.models import RiskLevel, SozlesmeTuru
from app.services.rag_service import search_relevant_laws
from app.services.chroma_client import get_chroma_client, get_laws_collection


# ── Test Vakalari ─────────────────────────────────────────────────────────────
# Her vaka: madde metni, beklenen risk, neden bu risk bekleniyor aciklamasi

TEST_CASES: list[dict] = [
    {
        "id": "kira-tufe-asimi",
        "madde": (
            "Kira bedeli her yil bir onceki yilin TUFE artis oraninin yuzde elli "
            "fazlasi kadar arttirilir."
        ),
        "beklenen_risk": "red",
        "aciklama": "TBK 344 - kira artisi TUFE sinirini asamaz",
        "sozlesme_turu": SozlesmeTuru.KIRA,
    },
    {
        "id": "fazla-mesai-yasal",
        "madde": (
            "Isci, fazla mesai yaptiginda normal ucretinin 1.5 kati fazla mesai "
            "ucreti alir."
        ),
        "beklenen_risk": "green",
        "aciklama": "Is K. 41 - yasaga uygun standart klozu",
        "sozlesme_turu": SozlesmeTuru.IS_SOZLESMESI,
    },
    {
        "id": "haksiz-tahliye",
        "madde": (
            "Kiraciyi herhangi bir sebeple 3 gun icinde odeme yapmazsa "
            "mal sahibi sozlesmeyi feshederek tahliye talep edebilir."
        ),
        "beklenen_risk": "red",
        "aciklama": "TBK 352 - 30 gun ihtarname sartti var, 3 gun yetersiz",
        "sozlesme_turu": SozlesmeTuru.KIRA,
    },
    {
        "id": "ihbar-suresi-kisa",
        "madde": (
            "Is sozlesmesi isverence feshedildiginde calisana 1 gunluk ihbar "
            "suresi taninir."
        ),
        "beklenen_risk": "red",
        "aciklama": "Is K. 17 - kidem suresiyle orantili asgari ihbar sureleri zorunlu",
        "sozlesme_turu": SozlesmeTuru.IS_SOZLESMESI,
    },
    {
        "id": "kira-depozito-yasal",
        "madde": (
            "Kiracidan 3 aylik kira tutarinda depozito alinir, kira sonesinde "
            "hasar yoksa iade edilir."
        ),
        "beklenen_risk": "yellow",
        "aciklama": "TBK 342 - depozito 3 ay sinirinda, ancak kosullar belirsiz olabilir",
        "sozlesme_turu": SozlesmeTuru.KIRA,
    },
]


# ── Yardimci: Madde Dogrulama ─────────────────────────────────────────────────

def verify_citation_in_chroma(kanun_no: str, madde_no: str) -> bool:
    """Verilen kanun/madde kombinasyonu ChromaDB'de gercekten var mi?"""
    try:
        collection = get_laws_collection(get_chroma_client())
        doc_id = f"{kanun_no}-madde-{madde_no}"
        result = collection.get(ids=[doc_id])
        return len(result["ids"]) > 0
    except Exception:
        return False


def parse_kanun_no_from_dayanagi(kanun_dayanagi: str | None) -> str | None:
    """'Turk Borclar Kanunu' gibi metinden kanun numarasini tahmin eder."""
    if not kanun_dayanagi:
        return None
    mapping = {
        "borclar": "6098",
        "is kanunu": "4857",
        "tuketici": "6502",
        "ticaret": "6102",
    }
    lower = kanun_dayanagi.lower()
    for anahtar, no in mapping.items():
        if anahtar in lower:
            return no
    return None


# ── Ana Test Runner ───────────────────────────────────────────────────────────

async def run_tests(api_key: str) -> None:
    print("=" * 60)
    print("MaddeNet Hallucinasyon Test Suite")
    print("=" * 60)

    dogru = 0
    yanlis = 0
    uydurma_kaynak = 0
    toplam = len(TEST_CASES)

    for vaka in TEST_CASES:
        print(f"\n[{vaka['id']}]")
        print(f"  Madde: {vaka['madde'][:80]}...")
        print(f"  Beklenen risk: {vaka['beklenen_risk'].upper()}")

        try:
            sonuc = await analyze_contract(
                sozlesme_metni=vaka["madde"],
                sozlesme_turu=vaka["sozlesme_turu"],
                api_key=api_key,
            )

            analiz = sonuc.maddeler[0] if sonuc.maddeler else None
            if not analiz:
                print("  [HATA] Sonuc bos dondu")
                yanlis += 1
                continue

            gercek_risk = analiz.risk_seviyesi.value
            risk_dogru = gercek_risk == vaka["beklenen_risk"]

            if risk_dogru:
                print(f"  [OK] Risk: {gercek_risk.upper()} (dogru)")
                dogru += 1
            else:
                print(f"  [YANLIS] Risk: {gercek_risk.upper()} (beklenen: {vaka['beklenen_risk'].upper()})")
                yanlis += 1

            # RAG durumu
            print(f"  RAG bulundu: {analiz.rag_bulunan} | Max benzerlik: "
                  f"{analiz.rag_max_benzerlik:.2%}" if analiz.rag_max_benzerlik else
                  f"  RAG bulundu: {analiz.rag_bulunan} | Max benzerlik: -")

            # Kaynak dogrulama
            if analiz.kanun_dayanagi and analiz.kanun_maddesi:
                # Madde numarasini ayikla: "Madde 301" -> "301"
                madde_no_str = analiz.kanun_maddesi.replace("Madde", "").replace("madde", "").strip()
                kanun_no = parse_kanun_no_from_dayanagi(analiz.kanun_dayanagi)

                if kanun_no and madde_no_str.isdigit():
                    gercekten_var = verify_citation_in_chroma(kanun_no, madde_no_str)
                    if gercekten_var:
                        print(f"  [OK] Kaynak dogrulandi: {analiz.kanun_dayanagi} - {analiz.kanun_maddesi}")
                    else:
                        print(f"  [UYARI] Uydurma kaynak: {analiz.kanun_dayanagi} - {analiz.kanun_maddesi} ChromaDB'de YOK!")
                        uydurma_kaynak += 1
                else:
                    print(f"  Kaynak: {analiz.kanun_dayanagi} - {analiz.kanun_maddesi} (dogrulanamadi)")
            else:
                print(f"  Kaynak: Yok (kanun_dayanagi=None)")

            print(f"  Aciklama: {analiz.sade_aciklama[:100]}...")

        except Exception as e:
            print(f"  [HATA] {e}")
            yanlis += 1

    # ── Ozet ─────────────────────────────────────────────────────────────────
    print("\n" + "=" * 60)
    print("SONUCLAR")
    print("=" * 60)
    dogruluk = dogru / toplam * 100
    print(f"  Dogru siniflandirma: {dogru}/{toplam} ({dogruluk:.0f}%)")
    print(f"  Yanlis siniflandirma: {yanlis}/{toplam}")
    print(f"  Uydurma kaynak: {uydurma_kaynak}")

    if dogruluk >= 70 and uydurma_kaynak == 0:
        print("\n[BASARILI] Sistem hallusinasyon testini gecti.")
    elif uydurma_kaynak > 0:
        print(f"\n[KRITIK] {uydurma_kaynak} uydurma kaynak tespit edildi!")
    else:
        print(f"\n[DIKKAT] Dogruluk %70'in altinda ({dogruluk:.0f}%). Promptlari gozden gecir.")


if __name__ == "__main__":
    key = os.getenv("OPENAI_API_KEY", "")
    if not key:
        print("[HATA] OPENAI_API_KEY ortam degiskeni ayarli degil.")
        print("Kullanim: OPENAI_API_KEY=sk-... python scripts/test_hallucination.py")
        sys.exit(1)

    asyncio.run(run_tests(key))
