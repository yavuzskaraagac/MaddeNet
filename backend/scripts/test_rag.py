"""
RAG servisini test eder.
Önce seed_laws.py çalıştırılmış olmalı.

Kullanım:
    cd backend
    python scripts/test_rag.py
"""

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent.parent))

from app.services.rag_service import get_collection_stats, search_relevant_laws


def test_search(sorgu: str, kategori: str | None = None) -> None:
    print(f"\n--- Arama: '{sorgu}' ---")
    results = search_relevant_laws(sorgu, n_results=3, kategori_filtre=kategori)

    if not results:
        print("Sonuç bulunamadı.")
        return

    for i, r in enumerate(results, 1):
        print(f"\n[{i}] {r.kanun_adi} Madde {r.madde_no} - {r.baslik}")
        print(f"    Benzerlik: {r.benzerlik_skoru:.2%}")
        print(f"    Etiketler: {', '.join(r.risk_etiketleri)}")
        print(f"    İçerik: {r.icerik[:120]}...")


if __name__ == "__main__":
    stats = get_collection_stats()
    print(f"ChromaDB'de {stats['toplam_madde']} kanun maddesi mevcut.\n")

    # Test senaryoları
    test_search("Kira bedeli artışı TÜFE oranını geçemez")
    test_search("Kiracı ödeme yapmadığında tahliye")
    test_search("Fazla mesai ücreti hesabı")
    test_search("İşçi ihbar süresi fesih bildirimi")
