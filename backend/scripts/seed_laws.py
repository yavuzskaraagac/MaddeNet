"""
MaddeNet - Kanun Verisi Yükleme Scripti
---------------------------------------
Bu script, data/laws/ klasöründeki JSON dosyalarını okuyarak
ChromaDB'ye yükler. OpenAI API key olmadan da çalışır;
varsayılan olarak ChromaDB'nin lokal embedding modelini kullanır.

Kullanım:
    cd backend
    python scripts/seed_laws.py

OpenAI embeddingi etkinleştirmek için:
    OPENAI_API_KEY=sk-... python scripts/seed_laws.py
"""

import json
import os
import sys
from pathlib import Path

# backend/ klasörünü Python path'e ekle
sys.path.insert(0, str(Path(__file__).parent.parent))

from app.services.chroma_client import get_chroma_client, get_laws_collection

LAWS_DIR = Path(__file__).parent.parent / "data" / "laws"


def load_json_laws(file_path: Path) -> list[dict]:
    """JSON kanun dosyasını madde listesine çevirir."""
    with open(file_path, encoding="utf-8") as f:
        data = json.load(f)

    kanun_adi = data["kanun_adi"]
    kanun_no = data["kanun_no"]
    kategori = data["kategori"]
    maddeler = []

    for madde in data["maddeler"]:
        maddeler.append(
            {
                "id": f"{kanun_no}-madde-{madde['madde_no']}",
                "document": madde["icerik"],
                "metadata": {
                    "kanun_adi": kanun_adi,
                    "kanun_no": kanun_no,
                    "madde_no": madde["madde_no"],
                    "baslik": madde.get("baslik", ""),
                    "kategori": kategori,
                    "risk_etiketleri": ",".join(madde.get("risk_etiketleri", [])),
                },
            }
        )
    return maddeler


def seed_database() -> None:
    print("ChromaDB bağlanılıyor...")
    client = get_chroma_client()
    collection = get_laws_collection(client)

    json_files = list(LAWS_DIR.glob("*.json"))
    if not json_files:
        print(f"HATA: {LAWS_DIR} içinde JSON dosyası bulunamadı.")
        sys.exit(1)

    total_added = 0

    for json_file in json_files:
        print(f"\nDosya işleniyor: {json_file.name}")
        maddeler = load_json_laws(json_file)

        ids = [m["id"] for m in maddeler]
        documents = [m["document"] for m in maddeler]
        metadatas = [m["metadata"] for m in maddeler]

        # Daha önce yüklenenler varsa önce temizle (idempotent)
        existing = collection.get(ids=ids)
        if existing["ids"]:
            collection.delete(ids=existing["ids"])
            print(f"  {len(existing['ids'])} eski madde silindi (güncelleniyor).")

        collection.add(
            ids=ids,
            documents=documents,
            metadatas=metadatas,
        )
        print(f"  {len(maddeler)} madde ChromaDB'ye eklendi.")
        total_added += len(maddeler)

    print(f"\nToplam {total_added} kanun maddesi yüklendi.")
    print(f"Koleksiyon boyutu: {collection.count()} madde")


if __name__ == "__main__":
    seed_database()
