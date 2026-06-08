# MaddeNet — Geliştirme Günlüğü

Bu dosya, projeye eklenen her yeni özelliğin kaydını tutar.

---

## [2026-06-08] Flutter Android Mobil Uygulama

**Modül:** `mobile/` | **Teknoloji:** Flutter 3.44 + Provider + GoRouter + Dio + Supabase

### Amaç

Claude Design prototiplerinden yola çıkarak MaddeNet'in tam işlevsel Flutter Android mobil uygulaması oluşturuldu. Web platformundaki tasarım dili ve renk sistemi birebir Flutter'a aktarıldı.

---

### Mimari

| Katman | Teknoloji |
|--------|-----------|
| State Management | Provider (`ThemeProvider`, `AuthProvider`) |
| Navigasyon | GoRouter — ShellRoute (bottom nav) + nested routes |
| HTTP | Dio — base URL `http://10.0.2.2:8000` (emülatör → localhost) |
| Tema | `ThemeExtension` (`MnColors`) — dark/light token sistemi |
| Yazı Tipleri | Google Fonts: Newsreader + Inter + JetBrains Mono |
| Dosya Seçici | file_picker |
| Kalıcı Depolama | SharedPreferences (tema tercihi) |

### Yeni Dosyalar

| Dosya | Açıklama |
|-------|----------|
| `mobile/lib/main.dart` | Uygulama girişi — GoRouter tanımı, MultiProvider, SystemChrome edge-to-edge |
| `mobile/lib/theme/app_theme.dart` | `MnColors` ThemeExtension (24 token) + `AppTheme.dark()` / `AppTheme.light()` |
| `mobile/lib/providers/theme_provider.dart` | Karanlık/açık tema — SharedPreferences'a kalıcı |
| `mobile/lib/providers/auth_provider.dart` | Giriş / kayıt / çıkış — ApiService bağlantılı |
| `mobile/lib/services/api_service.dart` | Dio tabanlı API client — login, register, upload, analyses, documents, profile |
| `mobile/lib/models/analysis.dart` | `Clause` + `Analysis` Pydantic modelleri — risk hesaplama getter'ları |
| `mobile/lib/models/document.dart` | `Document` — status badge getter'ı |
| `mobile/lib/widgets/risk_pill.dart` | `RiskPill` renk kodlu risk etiketi + `RiskScoreBadge` |
| `mobile/lib/widgets/mn_card.dart` | `MnCard` (isteğe bağlı glow) + `MnLegalNote` |
| `mobile/lib/widgets/mn_button.dart` | `MnPrimaryButton` (amber gradient) + `MnGhostButton` + `MnDangerButton` |
| `mobile/lib/widgets/brand_mark.dart` | `BrandMark` + `BrandLogo` + `UserAvatar` |
| `mobile/lib/screens/splash_screen.dart` | Giriş ekranı — aura arka plan, grid çizgiler, yasal not |
| `mobile/lib/screens/auth_screen.dart` | Giriş / Kayıt sekmeleri — form doğrulama, yükleme durumu |
| `mobile/lib/screens/shell_screen.dart` | Bottom navigation shell — 4 sekme |
| `mobile/lib/screens/dashboard_screen.dart` | Ana sayfa — 4 istatistik kartı, son analizler, risk dağılım barı |
| `mobile/lib/screens/upload_screen.dart` | PDF yükleme — 4 adım göstergesi, sözleşme türü seçici |
| `mobile/lib/screens/analyzing_sheet.dart` | Analiz overlay — zamanlayıcı tabanlı ilerleme, 6 aşama |
| `mobile/lib/screens/results_screen.dart` | Sonuç ekranı — filtre chip'leri, madde kartları, kanun referansı |
| `mobile/lib/screens/documents_screen.dart` | Belgelerim — durum badge, görüntüle / indir / sil |
| `mobile/lib/screens/analyses_screen.dart` | Analizlerim — büyük risk skoru kartı, haftalık bar grafik |
| `mobile/lib/screens/profile_screen.dart` | Profil — avatar, istatistikler, aktivite listesi |
| `mobile/lib/screens/settings_screen.dart` | Ayarlar — tema toggle, şifre değiştirme, tehlikeli bölge |

### Ekranlar ve Navigasyon

```
/ (Splash)
├── /auth            → Giriş / Kayıt
├── /upload          → Yeni Analiz
│   └── AnalyzingSheet (overlay)
├── /results/:id     → Analiz Sonuçları
├── /settings        → Ayarlar
└── ShellRoute (bottom nav)
    ├── /dashboard   → Ana Sayfa
    ├── /documents   → Belgelerim
    ├── /analyses    → Analizlerim
    └── /profile     → Profil
```

### Tasarım Sistemi (Design Tokens)

| Token | Karanlık | Açık |
|-------|----------|------|
| Arka plan | `#0B0B0E` | `#FAFAF6` |
| Aksan | `#C89A5C` | `#9A6F3C` |
| Yüksek risk | `#C75D5D` | — |
| Orta risk | `#C99B4B` | — |
| Güvenli | `#6FA88A` | — |

### Derleme Düzeltmeleri

| Sorun | Çözüm |
|-------|-------|
| `flutter_plugin_android_lifecycle` compileSdk 36 gereksinimi | `pubspec.yaml`'a `dependency_overrides: flutter_plugin_android_lifecycle: 2.0.21` |
| `compileSdk` uyumsuzluğu | `android/app/build.gradle.kts`'de `compileSdk = 36` |
| Impeller renderer emülatör çöküşü | `AndroidManifest.xml`'e `EnableImpeller: false` |
| `DateFormat` locale hatası | `main.dart`'a `initializeDateFormatting('tr_TR', null)` |

### Sistem Durumu

| Bileşen | Durum |
|---------|-------|
| Flutter analyze | ✅ Sıfır hata |
| APK build | ✅ `app-debug.apk` |
| Emülatör (Pixel 7) | ✅ Çalışıyor |
| Backend bağlantısı | 🔄 Sonraki adım |

---

## [2026-06-02] Tam Uçtan Uca Entegrasyon, Hata Düzeltmeleri ve Yeni Özellikler

**Modül:** `frontend/` + `backend/` | **Teknoloji:** Next.js 16 + FastAPI + Supabase + Pydantic AI

### Amaç

Frontend ile backend tam olarak birleştirildi. Kritik kimlik doğrulama sorunları, veritabanı şema uyumsuzlukları, PDF işleme hataları ve performans sorunları çözüldü. Kullanıcının PDF yükleyip analiz yaptırabildiği, sonuçları görüntüleyebildiği ve PDF olarak indirebildiği eksiksiz bir akış sağlandı.

---

### Backend Düzeltmeleri

#### 1. `load_dotenv()` Eksikliği — Tüm 401 Hatalarının Kök Nedeni

`backend/main.py`

```python
# Eklendi — uvicorn .env dosyasını otomatik yüklemez
from dotenv import load_dotenv
load_dotenv()
```

Bu eksiklik nedeniyle `SUPABASE_URL` ve `SUPABASE_SERVICE_ROLE_KEY` ortam değişkenleri hiç yüklenmiyordu; tüm API istekleri 401 döndürüyordu.

#### 2. Veritabanı Şema Uyumsuzlukları — CHECK Constraint Hataları

`backend/app/models.py`

Supabase tablolarındaki gerçek CHECK constraint değerleri ile backend enum değerleri uyuşmuyordu:

| Tablo | Kolon | Eski (yanlış) | Yeni (doğru) |
|-------|-------|---------------|--------------|
| `documents` | `status` | `pending / completed / failed` | `uploaded / analyzed / error` |
| `analyses` | `overall_risk_level` | `red / yellow / green` | `high / medium / low` |
| `analysis_items` | `risk_color` | — | `red / yellow / green` ✓ |

`analysis_service.py`'e çift yönlü mapping eklendi: DB'ye yazarken `red→high`, okurken `high→red`.

#### 3. PDF Metin Çıkarma — `unstructured` → `pypdf`

`backend/app/services/analysis_service.py`

`unstructured[pdf]` paketi Python 3.13 ile uyumsuz ve Windows'ta kurulumu başarısız. Yerine `pypdf` kullanıldı — sıfır sistem bağımlılığı, Windows uyumlu.

```python
from pypdf import PdfReader
reader = PdfReader(io.BytesIO(pdf_bytes))
```

#### 4. Pydantic AI — `madde_dogrula` Tool Retry Sorunu

`backend/app/core/agent.py`

`madde_dogrula` tool'u ChromaDB'de bulamadığı kanunlar için `ModelRetry` fırlatıyordu. 2 deneme hakkı bitince `UnexpectedModelBehavior` → 500 hatası. Düzeltme: `ModelRetry` yerine bilgi mesajı döndür.

Ek olarak `analyze_contract` döngüsüne madde başına try/except eklendi — tek madde hatası tüm analizi çökertmiyor, varsayılan sarı risk atanıyor.

#### 5. Güvenli Dosya İndirme Endpoint'i

`backend/app/api/documents.py`

`contracts` bucket private olduğundan public URL 404 veriyordu. Yeni endpoint:

```
GET /api/documents/{id}/download → 60 saniyelik imzalı URL
```

---

### Frontend Düzeltmeleri

#### 1. Next.js 16 — `middleware.ts` → `proxy.ts`

Next.js 16'da `middleware` convention'ı `proxy` olarak yeniden adlandırıldı. Dosya ve export fonksiyon adı güncellendi. Auth guard proxy yerine dashboard layout'ta client-side yapılıyor.

#### 2. Supabase Client — `@supabase/ssr` → `@supabase/supabase-js`

Production build'de `@supabase/ssr`'ın `createBrowserClient` cookie okumasında tutarsızlık. Doğrudan `@supabase/supabase-js` kullanımına geçildi; session localStorage'da saklanıyor, sayfa yenilemede kaybolmuyor.

#### 3. Login Yönlendirme Race Condition

`frontend/src/app/(auth)/auth/page.tsx`

`router.push('/dashboard')` client-side navigation yaptığından session cookie henüz yazılmamış oluyordu. `window.location.href = '/dashboard'` ile tam sayfa yenilemeye geçildi.

#### 4. CSS ve Performans

- `shadcn/tailwind.css`, `@theme inline` bloğu ve Shadcn değişkenleri kaldırıldı
- `framer-motion`, `@base-ui/react`, `zustand`, `shadcn`, `clsx` gibi kullanılmayan paketler silindi (345 paket azaltıldı)
- `npm run dev` yerine `npm run build && npm start` — Turbopack derleme gecikmesi yok, anlık sayfa yüklemesi

#### 5. API Interceptor İyileştirmeleri

`frontend/src/lib/api.ts`

- 401 response interceptor eklendi — geçersiz/süresi dolmuş token otomatik temizlenir, `/auth`'a yönlendirilir
- Token hem Supabase session'dan hem localStorage fallback'ten okunur

---

### Yeni Sayfalar ve Özellikler

| Sayfa / Özellik | Açıklama |
|-----------------|----------|
| `/documents` | Yüklenen belgeler listesi — durum badge, imzalı indirme, analiz başlatma, silme |
| `/profile` | Kullanıcı profili — istatistikler, kullanıcı adı düzenleme (Supabase `user_metadata`) |
| `/settings` | Şifre değiştirme, çıkış, hesap silme (tehlikeli bölge) |
| **PDF İndir** | Analiz sonuçlarını temiz HTML raporu olarak PDF'e aktarır — sözleşme türü, risk özeti, tüm maddeler |
| **Kullanıcı Adı Değiştirme** | Profil sayfasında kalem ikonu ile inline düzenleme, Enter ile kaydetme |
| **Çıkış Yap** | Sidebar footer ve header'da çıkış butonu |

### Silinen Özellikler

- Analiz sayfasındaki **Kabul / Reddet / Avukata sor** butonları kaldırıldı

---

### Sistem Durumu

| Bileşen | Durum |
|---------|-------|
| Supabase bağlantısı | ✅ |
| ChromaDB (2.392 kanun) | ✅ |
| PDF yükleme | ✅ 201 Created |
| AI analiz pipeline | ✅ GPT-4o + RAG |
| Dashboard, Belgelerim, Profil, Ayarlar | ✅ |
| Auth (giriş / kayıt / çıkış) | ✅ |
| Güvenli dosya indirme | ✅ İmzalı URL |
| PDF rapor çıktısı | ✅ |

---

## [2026-05-30] Next.js Frontend Oluşturuldu

**Modül:** `frontend/` | **Teknoloji:** Next.js 16 + TypeScript + TailwindCSS + Shadcn UI + Supabase Auth

### Amaç

Claude Design'da hazırlanan HTML/CSS prototiplerinden yola çıkarak tam işlevsel Next.js App Router frontend'i oluşturuldu. Tüm sayfalar backend API'siyle entegre, koyu/açık tema destekli ve tasarım sistemine birebir uyumlu.

### Yeni Dosyalar

| Dosya | Açıklama |
|-------|----------|
| `frontend/src/app/page.tsx` | Landing sayfası — aurora hero, browser mockup, features grid, stats, trust band, yasal footer |
| `frontend/src/app/(auth)/auth/page.tsx` | Giriş/Kayıt — split layout, Supabase email+password auth |
| `frontend/src/app/(dashboard)/layout.tsx` | Dashboard layout — 244px sidebar, 64px sticky topbar, breadcrumb, arama |
| `frontend/src/app/(dashboard)/dashboard/page.tsx` | Dashboard — 4-kolon KPI kartları, risk dağılımı, etkinlik akışı, FAB |
| `frontend/src/app/(dashboard)/upload/page.tsx` | Yükleme sayfası — drag-drop, 4-adım stepper, analiz overlay modal |
| `frontend/src/app/analysis/[id]/page.tsx` | Analiz sonuçları — split-pane (belge + annotasyon), prev/next navigasyon |
| `frontend/src/components/brand/Logo.tsx` | AI Terazi SVG logosu + MaddeNet wordmark |
| `frontend/src/components/analysis/RiskBadge.tsx` | Risk rozeti (YÜKSEK RİSK / DİKKAT / UYGUN) |
| `frontend/src/components/analysis/RiskGauge.tsx` | Dairesel SVG risk skoru göstergesi (0-100) |
| `frontend/src/components/analysis/ClauseCard.tsx` | Madde kartı — renkli sol kenarlık, kanun ref, öneri, aksiyon butonları |
| `frontend/src/components/layout/Sidebar.tsx` | 3 bölümlü sidebar nav, count badge, quota kart |
| `frontend/src/components/layout/ThemeProvider.tsx` | next-themes dark/light tema sağlayıcı |
| `frontend/src/components/layout/ThemeToggle.tsx` | Koyu/açık tema toggle butonu |
| `frontend/src/lib/types.ts` | TypeScript tipleri — ClauseAnalysis, ContractAnalysisResult, RiskLevel vb. |
| `frontend/src/lib/supabase.ts` | Supabase browser client |
| `frontend/src/lib/api.ts` | axios API client — Supabase JWT interceptor, tüm endpoint fonksiyonları |
| `frontend/src/styles/tokens.css` | Claude Design'dan alınan CSS değişkenleri (koyu/açık tema) |
| `frontend/.env.local` | NEXT_PUBLIC_SUPABASE_URL, ANON_KEY, API_URL |

### Tasarım Sistemi

| Token | Değer |
|-------|-------|
| Tema | Koyu varsayılan (#0B0B0E), açık (#FAFAF6) |
| Aksan | Warm amber — koyu: #C89A5C, açık: #9A6F3C |
| Risk renkleri | Yüksek: #C75D5D · Orta: #C99B4B · Güvenli: #6FA88A |
| Yazı tipleri | Newsreader (serif başlıklar) + Inter (body) + JetBrains Mono (kanun ref) |

### Sayfa Özellikleri

**Landing (`/`)**
- Aurora animasyonu (conic-gradient + spin), dot grid overlay
- Browser mockup — sözleşme maddeleri + daire gauge preview
- 3-adım features grid (1px border separator, SVG glyph'lar)
- 4-kolon stats grid, mevzuat trust band
- Detaylı yasal uyarı footer (⚖ ikonlu)

**Auth (`/auth`)**
- Sol aside: gradient arkaplan, örnek sözleşme excerpt kartı
- Sağ form: email+password, login/signup geçişi, Supabase entegrasyonu

**Dashboard (`/dashboard`)**
- 4-kolon KPI kartları (radial glow + sparkline SVG)
- Sarı legal banner
- 1.5fr + 1fr iki sütunlu grid: analiz tablosu + sağ panel
- Sağ panel: Risk Dağılımı (56px skor + progress barlar) + Etkinlik akışı
- Gradient FAB (ring glow efekti)

**Upload (`/upload`)**
- Radial gradient drag-drop zone
- Config grid: tür seçici + analiz derinliği radio
- **Analiz overlay modal**: progress bar + 6 aşamalı stage list + spinner

**Analysis Results (`/analysis/[id]`)**
- **Split-pane layout** (1.3fr sol + 1fr sağ)
- Sol: kağıt görünümlü belge, tıklanabilir renkli annotasyon span'ları
- Sağ: pulse animasyonlu header, prev/next navigasyon, AnnotCard'lar
- AnnotCard: quote block, law-link, öneri kutusu, aksiyon butonları

### Teknoloji Kütüphaneleri

```
next@16.2.6, @supabase/supabase-js, @supabase/ssr
next-themes, framer-motion, axios, zustand
lucide-react, shadcn/ui (button, card, badge, accordion, sonner)
```

### Sistem Durumu

- `npm run dev` → `http://localhost:3000` ✓
- TypeScript strict — sıfır hata (`npx tsc --noEmit`) ✓
- Tüm sayfalar HTTP 200 ✓
- Backend: `http://localhost:8000` (ayrı terminal)

---

## [2026-05-29] Backend Yapılandırma, Supabase Kurulumu ve RAG Düzeltmeleri

**Modül:** `backend/` | **Teknoloji:** Supabase Management API + ChromaDB + Pydantic AI

### Amaç

Tüm ortam değişkenleri, veritabanı migration'ı ve Storage bucket kurulumu tamamlandı.
Uçtan uca analiz testi yapılarak sistemin gerçek OpenAI API key ile çalıştığı doğrulandı.
Test sırasında tespit edilen iki kritik hata düzeltildi.

### Yapılan Kurulum Adımları

| Adım | Açıklama |
|------|----------|
| `backend/.env` oluşturuldu | OpenAI, Supabase URL, Anon Key, Service Role Key, ChromaDB path |
| Supabase migration çalıştırıldı | Management API ile 8 yeni kolon eklendi (storage_path, sozlesme_turu, rag_bulunan vb.) |
| `contracts` Storage bucket oluşturuldu | Python client ile otomatik; Public: kapalı (private) |
| Storage RLS politikaları eklendi | INSERT / SELECT / DELETE — kullanıcı yalnızca kendi klasörüne erişir |
| ChromaDB doğrulandı | 2.392 kanun maddesi yüklü ve erişilebilir durumda |

### Düzeltilen Hatalar

**1. Pydantic AI v1.74.0 — OpenAI provider API değişikliği**

`backend/app/core/agent.py`

```python
# Eski (çalışmıyordu):
return OpenAIModel("gpt-4o", api_key=api_key)

# Yeni:
return OpenAIModel("gpt-4o", provider=OpenAIProvider(api_key=api_key))
```

Pydantic AI v1.74.0'da `OpenAIModel.__init__()` artık `api_key` parametresi almıyor;
bunun yerine `OpenAIProvider(api_key=...)` ile sarmalanması gerekiyor.

**2. ChromaDB kategori filtresi — sıfır sonuç döndürme**

`backend/app/services/rag_service.py`

ChromaDB metadata filtresinde `{"kategori": "kira"}` tam eşleşme arıyordu. Ancak kayıtlar
`"kira,kefalet,sozlesme"` şeklinde virgüllü saklandığından filtre 0 sonuç döndürüyor,
dolayısıyla tüm analizlerde `rag_bulunan=False` çıkıyordu.

Çözüm: ChromaDB where filtresi kaldırıldı, Python katmanında `kategori_filtre in r.kategori`
ile post-filter uygulandı.

### Uçtan Uca Test Sonuçları

8 maddelik örnek kira sözleşmesi analiz edildi:

| Madde | Risk | RAG | Doğruluk |
|-------|------|-----|----------|
| Taraflar | Yeşil | 0.62 | Doğru |
| Kiralanan | Yeşil | 0.70 | Doğru |
| TÜFE x2 artış | **Kırmızı** | 0.74 | Doğru — TBK 344 ihlali |
| 3 ay depozito | Sarı | 0.70 | Doğru |
| 3 gün tahliye | **Kırmızı** | 0.69 | Doğru — TBK 352 ihlali |
| Onarım kiracıya | Sarı | 0.70 | Doğru |
| Erken fesih cezası | **Kırmızı** | 0.71 | Doğru |
| DASK sigortası | Sarı | 0.66 | Doğru |

Genel risk skoru: **56/100** | Kırmızı: 3, Sarı: 3, Yeşil: 2

### Sistem Durumu

- `GET /health` → `{"status":"ok","version":"0.2.0"}` ✓
- `GET /api/rag/stats` → `{"toplam_kanun_maddesi":2392}` ✓
- Backend **production-ready** — sıradaki adım: Next.js frontend

---

## [2026-05-14] FastAPI Endpoint'leri ve Backend Tamamlama

**Modül:** `backend/app/api/` + `backend/app/services/` | **Teknoloji:** FastAPI + Supabase + Unstructured.io

### Amaç

AI çekirdeği ve RAG sistemi hazırdı; bu güncelleme ile uçtan uca çalışan HTTP API'ı yazıldı.
Web ve mobil istemciler artık PDF yükleyip analiz sonuçlarını alabilir.

### Yeni Dosyalar

| Dosya | Açıklama |
|-------|----------|
| `backend/app/api/deps.py` | Supabase JWT doğrulama middleware + OpenAI key injection |
| `backend/app/api/documents.py` | PDF yükleme, listeleme, detay, silme endpoint'leri |
| `backend/app/api/analyses.py` | Analiz başlatma, listeleme, detay, silme endpoint'leri |
| `backend/app/api/users.py` | Kullanıcı profil endpoint'i |
| `backend/app/api/rag.py` | ChromaDB istatistik endpoint'i |
| `backend/app/services/supabase_client.py` | Singleton Supabase service role client |
| `backend/app/services/document_service.py` | Storage yükleme/indirme/silme + documents tablosu CRUD |
| `backend/app/services/analysis_service.py` | PDF→metin→agent→Supabase tam pipeline |
| `backend/scripts/supabase_migration.sql` | Eksik tablo kolonlarını ekleyen idempotent migration |

### Endpoint Listesi (9 endpoint)

| Method | Endpoint | Açıklama |
|--------|----------|----------|
| `POST` | `/api/documents/upload` | PDF yükle → Supabase Storage |
| `GET` | `/api/documents` | Belgelerimi listele |
| `GET` | `/api/documents/{id}` | Tek belge detayı |
| `DELETE` | `/api/documents/{id}` | Belge + Storage + analizler sil |
| `POST` | `/api/analyses` | Belgeyi analiz et (tam pipeline) |
| `GET` | `/api/analyses` | Analizlerimi listele |
| `GET` | `/api/analyses/{id}` | Analiz detayı (tüm maddeler) |
| `DELETE` | `/api/analyses/{id}` | Analiz sil |
| `GET` | `/api/users/me` | Profil bilgisi |

### Analiz Pipeline Akışı

```
POST /api/analyses
  → Supabase Storage'dan PDF indir
  → Unstructured.io ile metne dönüştür (thread pool)
  → detect_contract_type() ile tür tespit et (opsiyonel)
  → analyze_contract() → Pydantic AI + ChromaDB RAG
  → analyses + analysis_items tablolarına kaydet
  → AnalysisDetailResponse dön
```

### Güncellenen Dosyalar

| Dosya | Değişiklik |
|-------|------------|
| `backend/main.py` | 4 router kayıt edildi, versiyon 0.2.0 |
| `backend/app/models.py` | Request/response şemaları eklendi; `DocumentStatus.PROCESSING` enum'u eklendi |
| `backend/.env.example` | `SUPABASE_SERVICE_ROLE_KEY` ve `SUPABASE_ANON_KEY` eklendi |

### Eksiksizlik Kontrolleri

- `SUPABASE_KEY` → `SUPABASE_SERVICE_ROLE_KEY` isim uyumsuzluğu giderildi
- `DocumentStatus.PROCESSING` eksik enum değeri eklendi
- Supabase `contracts` Storage bucket gerekliliği belgelendi
- `supabase_migration.sql` ile eksik kolonlar (storage_path, sozlesme_turu, madde_sayisi, rag_bulunan, rag_max_benzerlik vb.) eklendi

### Notlar

- Swagger UI: `http://localhost:8000/docs` — web ve mobil testleri buradan yapılabilir
- Auth: Supabase JWT Bearer token ile; login/register Supabase client-side halleder
- Analiz süresi: sözleşme uzunluğuna bağlı (her madde için 1 LLM çağrısı); ileride background task'a alınabilir

---

## [2026-04-06] RAG Entegrasyonu ve Hallüsinasyon Önleme

**Modül:** `backend/app/` | **Teknoloji:** ChromaDB + Pydantic AI ModelRetry

### Amaç

Hukuki platformlarda LLM'in var olmayan kanun maddeleri uydurması (hallüsinasyon) kabul
edilemez bir risk. Bu güncelleme ile AI ajanının karar vermeden önce ChromaDB'ye sorması
teknik olarak zorunlu hale getirildi ve doğrulama katmanları eklendi.

### Güncellenen Dosyalar

| Dosya | Değişiklik |
|-------|------------|
| `backend/app/services/rag_service.py` | `min_similarity=0.45` eşiği eklendi — düşük benzerlikli sonuçlar LLM'e gitmez |
| `backend/app/core/agent.py` | `madde_dogrula` tool eklendi; orkestrasyon katmanı RAG skorunu doğrudan ChromaDB'den okur |
| `backend/app/models.py` | `ClauseAnalysis`'e `rag_bulunan: bool` ve `rag_max_benzerlik: float` alanları eklendi |
| `backend/app/core/prompts.py` | Kanun bulunamazsa fallback kuralı eklendi (madde uydurma yasak) |

### Yeni Dosyalar

| Dosya | Açıklama |
|-------|----------|
| `backend/scripts/test_hallucination.py` | 5 bilinen Türk hukuku vakasıyla doğruluk testi — API key geldiğinde çalıştırılacak |

### Eklenen Önlemler

| Önlem | Nasıl Çalışır |
|-------|---------------|
| **Benzerlik Eşiği** | `search_relevant_laws(min_similarity=0.45)` — eşiğin altındaki kanun sonuçları filtrelenir |
| **`madde_dogrula` Tool** | LLM kanun_no + madde_no vererek tam metni çeker; var olmayan madde `ModelRetry` fırlatır |
| **RAG skoru çıktıda** | `rag_bulunan` ve `rag_max_benzerlik` LLM değil gerçek ChromaDB verisiyle doldurulur |
| **Fallback kuralı** | Kanun bulunamazsa: `yellow`, `kanun_dayanagi=null`, avukat yönlendirmesi |

### Doğrulama

```
Kayitli toollar: ['kanun_ara', 'madde_dogrula']
Alakasiz metin (min_similarity=0.45): 1 sonuc  (onceden: 3)
TUFE konusu: 3 sonuc, max benzerlik: 58.18%
ClauseAnalysis yeni alanlar: rag_bulunan, rag_max_benzerlik — OK
```

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
