-- ============================================================
-- MaddeNet — Supabase Tablo Güncellemeleri (Migration)
-- ============================================================
-- Bu dosyayı Supabase Dashboard > SQL Editor'da çalıştırın.
-- Mevcut tablolara eksik kolonları ve Storage bucket'ını ekler.
-- Var olan veriler korunur (idempotent — tekrar çalıştırılabilir).
-- ============================================================


-- ── 1. documents tablosu güncellemeleri ─────────────────────

-- Dosyanın Storage'daki tam yolu (silme/indirme için gerekli)
ALTER TABLE documents
    ADD COLUMN IF NOT EXISTS storage_path TEXT;

-- Belge işleme durumu genişletildi
-- Yeni değerler: pending | processing | completed | failed
ALTER TABLE documents
    ALTER COLUMN status SET DEFAULT 'pending';


-- ── 2. analyses tablosu güncellemeleri ──────────────────────

-- Hangi sözleşme türü olduğu (kira, is_sozlesmesi vb.)
ALTER TABLE analyses
    ADD COLUMN IF NOT EXISTS sozlesme_turu TEXT NOT NULL DEFAULT 'genel';

-- Kaç madde analiz edildi (liste sayfasında göstermek için)
ALTER TABLE analyses
    ADD COLUMN IF NOT EXISTS madde_sayisi INTEGER NOT NULL DEFAULT 0;


-- ── 3. analysis_items tablosu güncellemeleri ────────────────

-- Sözleşmedeki madde numarası veya sırası ("1", "2a" vb.)
ALTER TABLE analysis_items
    ADD COLUMN IF NOT EXISTS madde_no TEXT;

-- Kanun madde numarası detayı ("Madde 301" gibi)
ALTER TABLE analysis_items
    ADD COLUMN IF NOT EXISTS kanun_maddesi TEXT;

-- RED/YELLOW maddeler için kullanıcıya pratik öneri
ALTER TABLE analysis_items
    ADD COLUMN IF NOT EXISTS oneri TEXT;

-- ChromaDB'de ilgili kanun bulundu mu?
ALTER TABLE analysis_items
    ADD COLUMN IF NOT EXISTS rag_bulunan BOOLEAN NOT NULL DEFAULT FALSE;

-- RAG aramasındaki en yüksek benzerlik skoru (0.0 - 1.0)
ALTER TABLE analysis_items
    ADD COLUMN IF NOT EXISTS rag_max_benzerlik FLOAT;


-- ── 4. Storage Bucket ────────────────────────────────────────
-- Supabase Dashboard > Storage > New Bucket
-- Bucket adı: contracts
-- Public: KAPALI (private — dosyalar sadece signed URL ile erişilebilir)
--
-- NOT: Storage bucket SQL ile oluşturulamaz.
-- Aşağıdaki adımları manuel yapın:
--   1. Supabase Dashboard'a gidin
--   2. Sol menüden "Storage" seçin
--   3. "New bucket" tıklayın
--   4. Bucket adı: contracts
--   5. Public bucket: KAPALI bırakın
--   6. "Save" tıklayın


-- ── 5. Storage RLS Politikaları ─────────────────────────────
-- Storage bucket oluşturduktan sonra bu politikaları uygulayın:

-- Kullanıcı kendi klasörüne yükleyebilir
-- (path: {user_id}/...)
INSERT INTO storage.policies (name, bucket_id, operation, definition)
VALUES (
    'Kullanici kendi klasorune yukleyebilir',
    'contracts',
    'INSERT',
    'auth.uid()::text = (storage.foldername(name))[1]'
)
ON CONFLICT DO NOTHING;

-- Kullanıcı kendi dosyalarını görebilir
INSERT INTO storage.policies (name, bucket_id, operation, definition)
VALUES (
    'Kullanici kendi dosyalarini gorebilir',
    'contracts',
    'SELECT',
    'auth.uid()::text = (storage.foldername(name))[1]'
)
ON CONFLICT DO NOTHING;

-- Kullanıcı kendi dosyalarını silebilir
INSERT INTO storage.policies (name, bucket_id, operation, definition)
VALUES (
    'Kullanici kendi dosyalarini silebilir',
    'contracts',
    'DELETE',
    'auth.uid()::text = (storage.foldername(name))[1]'
)
ON CONFLICT DO NOTHING;


-- ── 6. Doğrulama sorguları ───────────────────────────────────
-- Migration çalıştıktan sonra kolonları kontrol edin:

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'documents'
ORDER BY ordinal_position;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'analyses'
ORDER BY ordinal_position;

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'analysis_items'
ORDER BY ordinal_position;
