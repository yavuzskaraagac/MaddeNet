<div align="center">

# ⚖ MaddeNet

### Yapay Zeka Destekli Sözleşme Risk Analiz Platformu

**PDF sözleşmelerinizi yükleyin. Gizli riskleri anında görün.**

[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?style=flat-square&logo=fastapi)](https://fastapi.tiangolo.com)
[![Next.js](https://img.shields.io/badge/Web-Next.js%2016-000000?style=flat-square&logo=nextdotjs)](https://nextjs.org)
[![Flutter](https://img.shields.io/badge/Mobile-Flutter%203.44-02569B?style=flat-square&logo=flutter)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Database-Supabase-3ECF8E?style=flat-square&logo=supabase)](https://supabase.com)
[![OpenAI](https://img.shields.io/badge/AI-GPT--4o-412991?style=flat-square&logo=openai)](https://openai.com)

</div>

---

## Nedir?

MaddeNet; hukuk bilgisi olmayan bireyler ve küçük işletmeler için geliştirilmiş bir **Legal-Tech SaaS** platformudur. Kira sözleşmesi, iş sözleşmesi ve ticari sözleşme gibi karmaşık PDF belgelerini yapay zeka ile analiz eder; her maddeyi **🔴 Yüksek Risk / 🟡 Dikkat / 🟢 Uygun** olarak sınıflandırır, ağır hukuki terimleri sade Türkçe ile açıklar ve ilgili Türk kanun maddelerini gösterir.

> ⚠️ **MaddeNet bağlayıcı hukuki danışmanlık vermez.** Bir analiz ve farkındalık aracıdır.

---

## Özellikler

| Özellik | Açıklama |
|---------|----------|
| 📄 **PDF Yükleme** | Sözleşme türü seçerek PDF yükle |
| 🤖 **AI Analizi** | GPT-4o + ChromaDB RAG ile her madde ayrı analiz edilir |
| 🔴🟡🟢 **Risk Kodlaması** | Her madde renk kodlu risk seviyesiyle gösterilir |
| ⚖️ **Kanun Dayanağı** | İlgili Türk Borçlar Kanunu / İş Kanunu maddeleri |
| 💬 **Sade Açıklama** | Hukuki terminoloji vatandaş diline çevrilir |
| 💡 **Öneri** | Her riskli madde için pratik tavsiyeler |
| 📊 **Risk Skoru** | 0-100 arası genel sözleşme risk puanı |
| 📱 **Mobil + Web** | Flutter Android uygulaması + Next.js web arayüzü |
| 📥 **PDF Raporu** | Analiz sonuçlarını PDF olarak indir ve paylaş |

---

## Ekran Görüntüleri

<table>
  <tr>
    <td align="center"><b>Ana Sayfa</b></td>
    <td align="center"><b>Analiz Sonuçları</b></td>
    <td align="center"><b>Belgelerim</b></td>
    <td align="center"><b>Profil</b></td>
  </tr>
  <tr>
    <td>Dashboard istatistik kartları, son analizler ve risk dağılımı</td>
    <td>Her madde için renkli sol çizgi, kanun referansı ve öneri</td>
    <td>Yüklenen PDF'ler, PDF görüntüleme ve analiz bağlantısı</td>
    <td>Toplam analiz sayısı, üyelik tarihi ve ayarlar</td>
  </tr>
</table>

---

## Mimari

```
maddenet/
├── backend/                    # Python FastAPI — AI Core
│   ├── app/
│   │   ├── api/                # REST endpoint'leri
│   │   │   ├── documents.py    # PDF yükleme, listeleme, indirme
│   │   │   ├── analyses.py     # Analiz başlatma ve sorgulama
│   │   │   ├── users.py        # Kullanıcı profili
│   │   │   └── deps.py         # Supabase JWT doğrulama
│   │   ├── core/
│   │   │   ├── agent.py        # Pydantic AI agent + RAG tool
│   │   │   └── prompts.py      # Türkçe sistem promptları
│   │   └── services/
│   │       ├── analysis_service.py  # PDF → AI → Supabase pipeline
│   │       ├── rag_service.py       # ChromaDB semantic search
│   │       └── document_service.py  # Storage CRUD
│   └── main.py
│
├── frontend/                   # Next.js 16 — Web Arayüzü
│   └── src/
│       ├── app/
│       │   ├── page.tsx            # Landing sayfası
│       │   ├── (auth)/auth/        # Giriş / Kayıt
│       │   ├── (dashboard)/        # Dashboard, Upload
│       │   └── analysis/[id]/      # Analiz sonuçları
│       ├── components/
│       │   ├── analysis/           # RiskBadge, RiskGauge, ClauseCard
│       │   └── layout/             # Sidebar, ThemeProvider
│       └── lib/
│           ├── api.ts              # Axios API client
│           └── types.ts            # TypeScript tipleri
│
└── mobile/                     # Flutter — Android Uygulaması
    └── lib/
        ├── screens/            # 9 ekran
        ├── models/             # Analysis, Document modelleri
        ├── services/           # ApiService, PdfService
        ├── providers/          # AuthProvider, ThemeProvider
        ├── widgets/            # RiskPill, MnCard, BrandMark
        └── theme/              # MnColors token sistemi
```

---

## Teknoloji Yığını

### Backend
| Katman | Teknoloji |
|--------|-----------|
| Framework | FastAPI (Python 3.11+) — tüm I/O async |
| AI Orchestration | **Pydantic AI** — yapılandırılmış çıktı, hallüsinasyon önleme |
| Dil Modeli | OpenAI GPT-4o |
| Vektör Veritabanı | **ChromaDB** — 2.392 Türk kanun maddesi (RAG) |
| İlişkisel DB + Auth | **Supabase** (PostgreSQL + Row Level Security) |
| Dosya Depolama | Supabase Storage (private bucket, imzalı URL) |
| PDF İşleme | pypdf |

### Web Frontend
| Katman | Teknoloji |
|--------|-----------|
| Framework | Next.js 16 — App Router |
| Dil | TypeScript (strict mode) |
| Stil | TailwindCSS |
| HTTP Client | Axios + JWT interceptor |
| Auth | Supabase Auth |

### Mobil
| Katman | Teknoloji |
|--------|-----------|
| Framework | Flutter 3.44 (Android) |
| State | Provider |
| Navigasyon | GoRouter |
| HTTP | Dio (receiveTimeout: 180s) |
| Auth | supabase_flutter |
| PDF Görüntüle | url_launcher |
| PDF Oluştur | pdf + printing |

---

## Analiz Pipeline'ı

```
1. Kullanıcı PDF yükler
       ↓
2. FastAPI → Supabase Storage'a kaydeder
       ↓
3. pypdf ile metin çıkarılır
       ↓
4. Pydantic AI Agent her madde için:
       ├── ChromaDB'ye semantic search ("kanun_ara" tool)
       ├── İlgili Türk kanun maddelerini bulur
       └── GPT-4o ile risk analizi yapar
       ↓
5. Yapılandırılmış çıktı (risk_seviyesi, sade_aciklama,
   kanun_dayanagi, oneri) Supabase'e kaydedilir
       ↓
6. Web ve mobil istemciye JSON döner
```

**Hallüsinasyon Önleme:** Agent, kanun maddesini önce ChromaDB'de doğrular. Benzerlik skoru 0.45 altında kalırsa kanun uydurma yasaktır — sarı risk + avukat yönlendirmesi atanır.

---

## Kurulum

### Gereksinimler

- Python 3.11+
- Node.js 18+
- Flutter 3.44+
- Supabase hesabı
- OpenAI API key

### Backend

```bash
cd backend
pip install -r requirements.txt

# .env dosyasını oluştur
cp .env.example .env
# OPENAI_API_KEY, SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY değerlerini doldur

# ChromaDB'ye kanun verilerini yükle
python scripts/seed_laws.py

# Sunucuyu başlat
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### Web Frontend

```bash
cd frontend
npm install

# .env.local dosyasını oluştur
cp .env.local.example .env.local
# NEXT_PUBLIC_SUPABASE_URL, NEXT_PUBLIC_SUPABASE_ANON_KEY, NEXT_PUBLIC_API_URL değerlerini doldur

npm run dev
# → http://localhost:3000
```

### Mobil (Android)

```bash
cd mobile
flutter pub get

# Android emülatör başlat
flutter emulators --launch Pixel_7

# Uygulamayı çalıştır
flutter run
```

> **Not:** Android emülatöründe backend adresi `http://10.0.2.2:8000` olarak tanımlıdır (localhost yerine).

---

## API Endpoint'leri

| Method | Endpoint | Açıklama |
|--------|----------|----------|
| `POST` | `/api/documents/upload` | PDF yükle |
| `GET` | `/api/documents` | Belgelerimi listele |
| `GET` | `/api/documents/{id}/download` | 60s imzalı indirme URL'i |
| `DELETE` | `/api/documents/{id}` | Belgeyi sil |
| `POST` | `/api/analyses` | Analiz başlat |
| `GET` | `/api/analyses` | Analizlerimi listele |
| `GET` | `/api/analyses/{id}` | Analiz detayı |
| `DELETE` | `/api/analyses/{id}` | Analizi sil |
| `GET` | `/api/users/me` | Profil bilgisi |
| `GET` | `/api/rag/stats` | ChromaDB istatistikleri |

Swagger UI: `http://localhost:8000/docs`

---

## Desteklenen Sözleşme Türleri

| Kod | Tür |
|-----|-----|
| `kira` | Kira Sözleşmesi |
| `is_sozlesmesi` | İş Sözleşmesi |
| `ticari` | Ticari Sözleşme |
| `tuketici` | Tüketici Sözleşmesi |
| `genel` | Genel Sözleşme |

---

## RAG Veritabanı

ChromaDB'de **2.392 Türk kanun maddesi** vektör olarak saklanmaktadır:

- Türk Borçlar Kanunu (No: 6098) — kira, ödeme, fesih maddeleri
- İş Kanunu (No: 4857) — çalışma koşulları, işten çıkarma
- Tüketici Kanunu ve diğerleri

Arama motoru: `all-MiniLM-L6-v2` (sentence-transformers), min. benzerlik eşiği: **0.45**

---

## Güvenlik

- **Row Level Security:** Her kullanıcı yalnızca kendi belgelerine ve analizlerine erişebilir
- **JWT Doğrulama:** Tüm endpoint'ler Supabase Bearer token gerektirir
- **Private Storage:** PDF dosyaları public URL ile erişilemez; yalnızca 60 saniyelik imzalı URL
- **Hallüsinasyon Koruması:** ChromaDB doğrulaması olmadan kanun referansı üretilemez

---

## Tasarım Sistemi

| Token | Koyu Tema | Açık Tema |
|-------|-----------|-----------|
| Arka plan | `#0B0B0E` | `#FAFAF6` |
| Kart | `#16161B` | `#FFFFFF` |
| Aksan | `#C89A5C` | `#9A6F3C` |
| Yüksek risk | `#C75D5D` | `#B14848` |
| Orta risk | `#C99B4B` | `#B07F2E` |
| Güvenli | `#6FA88A` | `#4F8770` |

Yazı tipleri: **Newsreader** (başlıklar) · **Inter** (metin) · **JetBrains Mono** (kod/kanun ref)

---

<div align="center">

**MaddeNet** — Sözleşmelerinizi anlamak artık herkesin hakkı.

</div>
