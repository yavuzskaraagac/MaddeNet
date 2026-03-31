"""
MaddeNet — Kanun PDF'lerini ChromaDB'ye Yükleyen Pipeline

Kullanım:
    cd backend
    python scripts/process_laws.py

Beklenen dosyalar:
    backend/data/pdfs/6098.pdf   (Türk Borçlar Kanunu)
    backend/data/pdfs/4857.pdf   (İş Kanunu)
    backend/data/pdfs/6502.pdf   (Tüketici Kanunu)
    backend/data/pdfs/6102.pdf   (Türk Ticaret Kanunu)
"""

import re
import sys
from pathlib import Path

# Proje kök dizinini Python path'e ekle
sys.path.insert(0, str(Path(__file__).parent.parent))

from unstructured.partition.pdf import partition_pdf
from app.services.chroma_client import get_chroma_client, get_laws_collection

# ── Sabit Tanımlar ─────────────────────────────────────────────────────────────

PDF_DIR = Path(__file__).parent.parent / "data" / "pdfs"

PDF_METADATA: dict[str, dict] = {
    "6098.pdf": {
        "kanun_adi": "Türk Borçlar Kanunu",
        "kanun_no": "6098",
        "kategori": ["kira", "kefalet", "sozlesme"],
    },
    "4857.pdf": {
        "kanun_adi": "İş Kanunu",
        "kanun_no": "4857",
        "kategori": ["is_sozlesmesi"],
    },
    "6502.pdf": {
        "kanun_adi": "Tüketici Kanunu",
        "kanun_no": "6502",
        "kategori": ["tuketici", "abonelik"],
    },
    "6102.pdf": {
        "kanun_adi": "Türk Ticaret Kanunu",
        "kanun_no": "6102",
        "kategori": ["ticari_sozlesme"],
    },
}

# Madde başlığı pattern: "MADDE 1 –", "Madde 123-", "MADDE 45 :" vb.
MADDE_PATTERN = re.compile(
    r"(?:MADDE|Madde)\s+(\d+)\s*[-–—:.]",
    re.MULTILINE,
)


# ── Yardımcı Fonksiyonlar ──────────────────────────────────────────────────────

def extract_text_from_pdf(pdf_path: Path) -> str:
    """Unstructured.io ile PDF'den ham metin çıkar."""
    print(f"  -> PDF okunuyor: {pdf_path.name}")
    elements = partition_pdf(filename=str(pdf_path))
    return "\n".join(str(el) for el in elements)


def split_into_articles(text: str) -> list[tuple[str, str]]:
    """
    Metni MADDE numarasına göre böler.
    Döndürür: [(madde_no, madde_metni), ...]
    """
    matches = list(MADDE_PATTERN.finditer(text))
    if not matches:
        return []

    # Her madde numarası için en uzun metni tut (içindekiler sayfasındaki kısa
    # tekrarları eler, asıl madde metnini korur)
    best: dict[str, str] = {}
    for i, match in enumerate(matches):
        madde_no = match.group(1)
        start = match.start()
        end = matches[i + 1].start() if i + 1 < len(matches) else len(text)
        madde_metni = text[start:end].strip()

        if len(madde_metni) > 30:
            if madde_no not in best or len(madde_metni) > len(best[madde_no]):
                best[madde_no] = madde_metni

    # Madde numarasına göre sıralı döndür
    return sorted(best.items(), key=lambda x: int(x[0]))


def load_pdf_to_chroma(
    pdf_path: Path,
    meta: dict,
    collection,
) -> int:
    """
    Tek bir PDF'i parse edip ChromaDB koleksiyonuna yükler.
    Döndürür: yüklenen madde sayısı
    """
    text = extract_text_from_pdf(pdf_path)
    articles = split_into_articles(text)

    if not articles:
        print(f"  [UYARI] Madde bulunamadi: {pdf_path.name} -- PDF yapisini kontrol et")
        return 0

    ids: list[str] = []
    documents: list[str] = []
    metadatas: list[dict] = []

    for madde_no, madde_metni in articles:
        doc_id = f"{meta['kanun_no']}-madde-{madde_no}"
        ids.append(doc_id)
        documents.append(madde_metni)
        metadatas.append(
            {
                "kanun_adi": meta["kanun_adi"],
                "kanun_no": meta["kanun_no"],
                "madde_no": madde_no,
                "kategori": ",".join(meta["kategori"]),
            }
        )

    # Var olan kayıtları önce sil (idempotent çalışma)
    try:
        existing = collection.get(ids=ids)
        if existing["ids"]:
            collection.delete(ids=existing["ids"])
    except Exception:
        pass

    collection.add(ids=ids, documents=documents, metadatas=metadatas)
    return len(articles)


# ── Ana Akış ──────────────────────────────────────────────────────────────────

def main() -> None:
    client = get_chroma_client()
    collection = get_laws_collection(client)

    toplam = 0
    eksik_pdf: list[str] = []

    for filename, meta in PDF_METADATA.items():
        pdf_path = PDF_DIR / filename

        if not pdf_path.exists():
            eksik_pdf.append(filename)
            print(f"  [ATLANDI] Dosya yok: {filename}")
            continue

        print(f"\n[PDF] {meta['kanun_adi']} ({filename}) isleniyor...")
        count = load_pdf_to_chroma(pdf_path, meta, collection)
        print(f"  [OK] {count} madde ChromaDB'ye yuklendi")
        toplam += count

    print(f"\n{'=' * 50}")
    print(f"Toplam yuklenen madde: {toplam}")
    print(f"ChromaDB koleksiyonu : 'turkish_laws'")

    if eksik_pdf:
        print(f"\n[UYARI] Eksik PDF'ler — backend/data/pdfs/ klasorune ekle:")
        for f in eksik_pdf:
            print(f"   - {f}  ->  {PDF_METADATA[f]['kanun_adi']}")


if __name__ == "__main__":
    main()
