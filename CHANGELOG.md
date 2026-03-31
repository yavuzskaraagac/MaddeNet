# MaddeNet — Geliştirme Günlüğü

Bu dosya, projeye eklenen her yeni özelliğin kaydını tutar.

---

## [2026-03-31] Pydantic AI Çekirdeği

**Modül:** `backend/app/core/` | **Teknoloji:** Pydantic AI v1.74.0 + OpenAI GPT-4o

### Oluşturulan Dosyalar

| Dosya | Açıklama |
|-------|----------|
| `backend/app/core/agent.py` | Ana Pydantic AI Agent + `kanun_ara` RAG tool + `analyze_contract()` orkestrasyon |
| `backend/app/core/deps.py` | `AnalysisDeps` — API key ve sözleşme türü bağımlılık enjeksiyonu |
| `backend/app/core/prompts.py` | Türkçe sistem promptu, madde analiz promptu, sözleşme tür tespit promptu |

### Güncellenen Dosyalar

| Dosya | Değişiklik |
|-------|------------|
| `backend/app/models.py` | `SozlesmeTuru` enum eklendi; `ClauseAnalysis` alanlarına `Field` açıklamaları eklendi |
| `backend/requirements.txt` | `pydantic-ai[openai]>=0.0.46` → kurulumda v1.74.0 geldi |
| `backend/.env.example` | `OPENAI_API_KEY` açıklaması güncellendi |

### Pydantic AI Özellikleri

| Özellik | Kullanım |
|---------|---------|
| `@agent.tool` | `kanun_ara` — her madde analizinde ChromaDB'de semantic search yapar |
| `@agent.system_prompt` | API key yoksa dinamik test modu uyarısı enjekte eder |
| `output_type=ClauseAnalysis` | Agent çıktısı doğrudan Pydantic modeline bağlı, regex ayrıştırma yok |
| `ModelRetry` | Kanun bulunamazsa agent farklı terimlerle otomatik yeniden dener |
| `UsageLimits` | Her `agent.run()` çağrısında 8.000 token limiti |
| `result.usage()` | İleride Supabase'e maliyet loglama için hazır |
| `deps_type=AnalysisDeps` | Sözleşme türü ve API key runtime'da enjekte edilir |

### Mimari Karar

Agent modül seviyesinde `TestModel()` ile başlatılır; API key gerektirmez.  
Gerçek OpenAI modeli `agent.run(..., model=OpenAIModel("gpt-4o", api_key=key))` ile çalışma zamanında geçilir.  
GPT-5 çıktığında `agent.py:17` satırındaki model adını değiştirmek yeterli.

### Notlar

- OpenAI API key henüz alınmadı. `.env` dosyasına `OPENAI_API_KEY` eklendiğinde sistem hazır.
- `detect_contract_type()` fonksiyonu ile yüklenen PDF'in türü otomatik tespit edilebilir.
- Tüm importlar test edildi: `python -c "from app.core.agent import analyze_contract"` başarılı.

---

## [2026-03-24] RAG Vector Database Kurulumu

**Modül:** `backend/` | **Teknoloji:** ChromaDB + sentence-transformers (all-MiniLM-L6-v2)

### Oluşturulan Dosyalar

| Dosya | Açıklama |
|-------|----------|
| `backend/main.py` | FastAPI uygulama girişi, CORS ayarları |
| `backend/app/models.py` | Pydantic şemaları (`ClauseAnalysis`, `ContractAnalysisResult`, `LawChunk`, `RiskLevel`) |
| `backend/app/services/chroma_client.py` | ChromaDB PersistentClient singleton + koleksiyon yönetimi |
| `backend/app/services/rag_service.py` | Semantic search fonksiyonu (`search_relevant_laws`, `get_collection_stats`) |
| `backend/scripts/seed_laws.py` | Kanun JSON dosyalarını ChromaDB'ye yükleyen idempotent script |
| `backend/scripts/test_rag.py` | RAG arama kalitesini test eden script |
| `backend/requirements.txt` | Proje bağımlılıkları (fastapi, chromadb, pydantic-ai, openai, supabase, unstructured) |
| `backend/.env.example` | Ortam değişkeni şablonu |

### Kanun Verisi

| Dosya | Kanun | Madde Sayısı |
|-------|-------|--------------|
| `data/laws/borclar_kanunu_kira.json` | Türk Borçlar Kanunu (No: 6098) — Kira maddeleri | 13 |
| `data/laws/is_kanunu.json` | İş Kanunu (No: 4857) | 10 |

**Toplam:** 23 kanun maddesi ChromaDB koleksiyonuna (`turkish_laws`, cosine benzerlik) yüklendi.

### ChromaDB Koleksiyon Şeması

Her madde şu metadata ile saklanır:
```
id: "{kanun_no}-madde-{madde_no}"
document: madde metni (embedding kaynağı)
metadata: kanun_adi, kanun_no, madde_no, baslik, kategori, risk_etiketleri
```

### Notlar

- OpenAI API key olmadan lokal `all-MiniLM-L6-v2` modeli kullanılıyor (sentence-transformers). API key geldiğinde OpenAI embedding'e geçilecek.
- Türkçe sorgularda lokal modelin benzerlik skoru düşüyor; OpenAI `text-embedding-3-small` ile bu sorun çözülecek.
- `seed_laws.py` idempotent — tekrar çalıştırıldığında var olan kayıtları silip yeniden ekler.

---

## [2026-03-10] Supabase Veritabanı ve Auth Kurulumu

**Proje:** `madde_net` | **ID:** `dwiavsmqmixxnzdthrgc` | **Bölge:** `eu-central-1`

### Oluşturulan Tablolar

| Tablo | Açıklama |
|-------|----------|
| `profiles` | Kullanıcı profilleri — `auth.users` ile 1:1 ilişkili (id, email, full_name, avatar_url) |
| `documents` | Yüklenen PDF sözleşmeler (file_name, file_url, file_size, status) |
| `analyses` | AI analiz sonuçları (overall_risk_score, overall_risk_level, summary) |
| `analysis_items` | Madde bazlı risk detayları (original_text, plain_language, risk_color 🔴🟡🟢, legal_reference) |

### Tablo İlişkileri

```
auth.users ──1:1──► profiles ──1:N──► documents ──1:N──► analyses ──1:N──► analysis_items
```

### RLS (Row Level Security) Politikaları — 10 adet

- **profiles:** View own, Update own, Insert (auth trigger)
- **documents:** View own, Insert own, Delete own
- **analyses:** View own, Insert own
- **analysis_items:** View own, Insert own

> Tüm tablolarda RLS aktif — kullanıcılar yalnızca kendi verilerine erişebilir.

### Auth Mekanizması

- `handle_new_user()` fonksiyonu ve `on_auth_user_created` trigger'ı oluşturuldu
- Yeni kullanıcı kayıt olduğunda `profiles` tablosuna otomatik satır eklenir
- Kayıt sırasında `full_name` meta verisi alınır

### Güvenlik

- ✅ Supabase Security Advisor: **Sıfır uyarı**
- ✅ Tüm tablolarda RLS aktif
- ✅ `SECURITY DEFINER` ile trigger fonksiyonu korunuyor
