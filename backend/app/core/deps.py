"""
Agent bağımlılıkları (Dependency Injection).

AnalysisDeps her agent.run() çağrısında bağlam olarak iletilir.
RunContext[AnalysisDeps] üzerinden tool fonksiyonlarından erişilir.
"""

from dataclasses import dataclass, field

from app.models import SozlesmeTuru


@dataclass
class AnalysisDeps:
    """
    Pydantic AI agent'ına runtime'da enjekte edilen bağımlılıklar.

    Kullanım:
        deps = AnalysisDeps(
            sozlesme_turu=SozlesmeTuru.KIRA,
            openai_api_key=os.getenv("OPENAI_API_KEY", ""),
        )
        result = await contract_agent.run(prompt, deps=deps)
    """

    sozlesme_turu: SozlesmeTuru = SozlesmeTuru.GENEL
    openai_api_key: str = field(default="")

    @property
    def is_mock(self) -> bool:
        """API key yoksa mock/test modudur."""
        return not bool(self.openai_api_key)

    @property
    def kategori_filtre(self) -> str | None:
        """
        ChromaDB araması için sözleşme türünü kategori filtresine çevirir.
        GENEL türünde filtre uygulanmaz, tüm kanunlarda arama yapılır.
        """
        if self.sozlesme_turu == SozlesmeTuru.GENEL:
            return None
        return self.sozlesme_turu.value
