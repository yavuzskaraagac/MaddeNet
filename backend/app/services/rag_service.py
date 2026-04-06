"""
MaddeNet RAG Service
--------------------
Sözleşme maddelerini ChromaDB'deki kanunlarla karşılaştırır.
Pydantic AI agent'ına @agent.tool olarak bağlanacak.
"""

from dataclasses import dataclass

from app.services.chroma_client import get_chroma_client, get_laws_collection


@dataclass
class LawSearchResult:
    kanun_adi: str
    kanun_no: str
    madde_no: str
    baslik: str
    icerik: str
    kategori: str
    risk_etiketleri: list[str]
    benzerlik_skoru: float


def search_relevant_laws(
    clause_text: str,
    n_results: int = 3,
    kategori_filtre: str | None = None,
    min_similarity: float = 0.45,
) -> list[LawSearchResult]:
    """
    Verilen sözleşme maddesiyle semantik olarak en alakalı
    kanun maddelerini döndürür.

    Args:
        clause_text: Analiz edilecek sözleşme maddesi metni
        n_results: Kaç sonuç döneceği (varsayılan 3)
        kategori_filtre: Opsiyonel - sadece bu kategoriden ara
                        ("kira", "is_sozlesmesi" vb.)
        min_similarity: Minimum benzerlik eşiği (varsayılan 0.45).
                        Bu eşiğin altındaki sonuçlar filtrelenir —
                        düşük benzerlikli kanunların LLM'i yanıltmasını önler.
    """
    client = get_chroma_client()
    collection = get_laws_collection(client)

    where_filter = {"kategori": kategori_filtre} if kategori_filtre else None

    results = collection.query(
        query_texts=[clause_text],
        n_results=n_results,
        where=where_filter,
        include=["documents", "metadatas", "distances"],
    )

    law_results: list[LawSearchResult] = []

    if not results["ids"] or not results["ids"][0]:
        return law_results

    for i, doc_id in enumerate(results["ids"][0]):
        metadata = results["metadatas"][0][i]
        distance = results["distances"][0][i]
        # cosine distance → benzerlik skoru (1 = tam eşleşme)
        similarity = round(1 - distance, 4)

        law_results.append(
            LawSearchResult(
                kanun_adi=metadata.get("kanun_adi", ""),
                kanun_no=metadata.get("kanun_no", ""),
                madde_no=metadata.get("madde_no", ""),
                baslik=metadata.get("baslik", ""),
                icerik=results["documents"][0][i],
                kategori=metadata.get("kategori", ""),
                risk_etiketleri=metadata.get("risk_etiketleri", "").split(","),
                benzerlik_skoru=similarity,
            )
        )

    # Düşük benzerlikli sonuçları filtrele — LLM'in alakasız kanunlarla
    # yanıltılmasını ve hallüsinasyon riskini önler.
    return [r for r in law_results if r.benzerlik_skoru >= min_similarity]


def get_collection_stats() -> dict[str, int]:
    """Koleksiyondaki toplam kanun madde sayısını döndürür."""
    client = get_chroma_client()
    collection = get_laws_collection(client)
    return {"toplam_madde": collection.count()}
