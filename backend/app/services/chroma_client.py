import os
import chromadb
from chromadb.config import Settings

CHROMA_DB_PATH = os.getenv("CHROMA_DB_PATH", "./chroma_db")
COLLECTION_NAME = "turkish_laws"


def get_chroma_client() -> chromadb.PersistentClient:
    return chromadb.PersistentClient(
        path=CHROMA_DB_PATH,
        settings=Settings(anonymized_telemetry=False),
    )


def get_laws_collection(
    client: chromadb.PersistentClient,
) -> chromadb.Collection:
    """
    Kanunlar koleksiyonunu döndürür.
    Yoksa cosine benzerlik metriği ile oluşturur.
    """
    return client.get_or_create_collection(
        name=COLLECTION_NAME,
        metadata={"hnsw:space": "cosine"},
    )
