'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { FileText, Trash2, Play, Download, AlertCircle, CheckCircle, Clock, Loader2 } from 'lucide-react'
import { listDocuments, deleteDocument, startAnalysis, getDocumentDownloadUrl } from '@/lib/api'
import type { DocumentRecord, SozlesmeTuru } from '@/lib/types'
import { SOZLESME_TURU_LABELS } from '@/lib/types'
import { toast } from 'sonner'
import { useRouter } from 'next/navigation'

function formatBytes(bytes: number) {
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`
  return `${(bytes / 1024 / 1024).toFixed(2)} MB`
}

function formatDate(iso: string) {
  return new Date(iso).toLocaleDateString('tr-TR', { day: 'numeric', month: 'short', year: 'numeric' })
}

const statusConfig = {
  analyzed:   { label: 'Tamamlandı', color: 'var(--risk-safe)', bg: 'var(--risk-safe-soft)', ring: 'var(--risk-safe-ring)', icon: <CheckCircle size={11} /> },
  processing: { label: 'İşleniyor',  color: 'var(--risk-mid)',  bg: 'var(--risk-mid-soft)',  ring: 'var(--risk-mid-ring)',  icon: <Loader2 size={11} style={{ animation: 'spin 1s linear infinite' }} /> },
  uploaded:   { label: 'Yüklendi',   color: 'var(--text-muted)', bg: 'var(--bg-inset)', ring: 'var(--border)', icon: <Clock size={11} /> },
  error:      { label: 'Hata',       color: 'var(--risk-high)', bg: 'var(--risk-high-soft)', ring: 'var(--risk-high-ring)', icon: <AlertCircle size={11} /> },
}

export default function DocumentsPage() {
  const router = useRouter()
  const [docs, setDocs] = useState<DocumentRecord[]>([])
  const [loading, setLoading] = useState(true)
  const [analyzing, setAnalyzing] = useState<string | null>(null)

  useEffect(() => {
    listDocuments()
      .then(setDocs)
      .catch(() => toast.error('Belgeler yüklenemedi'))
      .finally(() => setLoading(false))
  }, [])

  async function handleDelete(id: string, name: string) {
    if (!confirm(`"${name}" belgesini silmek istediğinizden emin misiniz?`)) return
    try {
      await deleteDocument(id)
      setDocs(prev => prev.filter(d => d.id !== id))
      toast.success('Belge silindi')
    } catch {
      toast.error('Silinemedi')
    }
  }

  async function handleAnalyze(doc: DocumentRecord) {
    setAnalyzing(doc.id)
    try {
      const analysis = await startAnalysis(doc.id, 'genel' as SozlesmeTuru)
      toast.success('Analiz başlatıldı')
      router.push(`/analysis/${analysis.id}`)
    } catch {
      toast.error('Analiz başlatılamadı')
      setAnalyzing(null)
    }
  }

  return (
    <div style={{ padding: '32px 32px 80px', maxWidth: 1000 }}>
      <div style={{ marginBottom: 28 }}>
        <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11.5, color: 'var(--accent)', letterSpacing: '0.12em', textTransform: 'uppercase', marginBottom: 8 }}>Belgelerim</p>
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end' }}>
          <div>
            <h1 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 32, fontWeight: 500, letterSpacing: '-0.025em', margin: '0 0 6px', color: 'var(--text)' }}>
              Yüklenen <em style={{ fontStyle: 'italic', color: 'var(--accent-hover)', fontWeight: 400 }}>belgeler</em>
            </h1>
            <p style={{ color: 'var(--text-muted)', fontSize: 14, margin: 0 }}>Sisteme yüklediğiniz tüm PDF belgeler</p>
          </div>
          <Link href="/upload" style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '9px 16px', background: 'var(--accent)', color: '#fff', borderRadius: 'var(--r-sm)', fontSize: 13, fontWeight: 500, boxShadow: 'var(--shadow-glow)', textDecoration: 'none' }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2"><path d="M12 5v14M5 12h14"/></svg>
            Yeni Belge Yükle
          </Link>
        </div>
      </div>

      <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)', overflow: 'hidden' }}>
        {loading ? (
          <div style={{ padding: '64px', textAlign: 'center', color: 'var(--text-muted)', fontSize: 13 }}>
            <Loader2 size={24} style={{ animation: 'spin 1s linear infinite', margin: '0 auto 12px', display: 'block', color: 'var(--accent)' }} />
            Yükleniyor…
          </div>
        ) : docs.length === 0 ? (
          <div style={{ padding: '64px', textAlign: 'center' }}>
            <div style={{ width: 56, height: 56, borderRadius: 12, background: 'var(--bg-inset)', border: '1px solid var(--border)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px' }}>
              <FileText size={24} color="var(--text-faint)" />
            </div>
            <p style={{ color: 'var(--text-muted)', fontSize: 14, marginBottom: 16 }}>Henüz belge yüklenmedi.</p>
            <Link href="/upload" style={{ display: 'inline-flex', alignItems: 'center', gap: 6, padding: '9px 18px', background: 'var(--accent)', color: '#fff', borderRadius: 'var(--r-sm)', fontSize: 13, fontWeight: 500, textDecoration: 'none' }}>
              İlk Belgenizi Yükleyin
            </Link>
          </div>
        ) : (
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13.5 }}>
            <thead>
              <tr>
                {['Dosya Adı', 'Boyut', 'Durum', 'Yüklenme Tarihi', 'İşlemler'].map((h) => (
                  <th key={h} style={{ fontWeight: 500, textAlign: 'left', color: 'var(--text-faint)', fontSize: 11.5, textTransform: 'uppercase' as const, letterSpacing: '0.06em', padding: '12px 22px', borderBottom: '1px solid var(--border)', background: 'var(--bg-inset)' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {docs.map((doc) => {
                const st = statusConfig[doc.status]
                return (
                  <tr key={doc.id} style={{ borderBottom: '1px solid var(--border-subtle)' }}>
                    <td style={{ padding: '14px 22px' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                        <div style={{ width: 32, height: 32, borderRadius: 7, background: 'var(--accent-soft)', border: '1px solid var(--accent-ring)', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                          <FileText size={15} color="var(--accent)" />
                        </div>
                        <div>
                          <p style={{ margin: 0, color: 'var(--text)', fontWeight: 500, fontSize: 13.5 }}>{doc.file_name}</p>
                          <p style={{ margin: 0, fontFamily: 'JetBrains Mono, monospace', fontSize: 10, color: 'var(--text-faint)', marginTop: 2 }}>{doc.id.slice(0, 8)}…</p>
                        </div>
                      </div>
                    </td>
                    <td style={{ padding: '14px 22px', color: 'var(--text-soft)', fontSize: 12.5 }}>{formatBytes(doc.file_size)}</td>
                    <td style={{ padding: '14px 22px' }}>
                      <span style={{ display: 'inline-flex', alignItems: 'center', gap: 5, padding: '3px 9px', borderRadius: 'var(--r-full)', background: st.bg, border: `1px solid ${st.ring}`, color: st.color, fontSize: 11.5, fontWeight: 500 }}>
                        {st.icon}
                        {st.label}
                      </span>
                    </td>
                    <td style={{ padding: '14px 22px', color: 'var(--text-soft)', fontSize: 12.5 }}>{formatDate(doc.created_at)}</td>
                    <td style={{ padding: '14px 22px' }}>
                      <div style={{ display: 'flex', gap: 6, alignItems: 'center' }}>
                        {doc.status === 'analyzed' && (
                          <button
                            onClick={() => handleAnalyze(doc)}
                            disabled={analyzing === doc.id}
                            title="Yeniden analiz et"
                            style={{ display: 'inline-flex', alignItems: 'center', gap: 5, padding: '5px 10px', background: 'var(--accent-soft)', border: '1px solid var(--accent-ring)', borderRadius: 6, fontSize: 12, color: 'var(--accent)', cursor: 'pointer', fontFamily: 'inherit' }}
                          >
                            {analyzing === doc.id ? <Loader2 size={11} style={{ animation: 'spin 1s linear infinite' }} /> : <Play size={11} />}
                            Analiz Et
                          </button>
                        )}
                        {doc.status === 'error' && (
                          <button
                            onClick={() => handleAnalyze(doc)}
                            disabled={analyzing === doc.id}
                            title="Tekrar dene"
                            style={{ display: 'inline-flex', alignItems: 'center', gap: 5, padding: '5px 10px', background: 'var(--risk-high-soft)', border: '1px solid var(--risk-high-ring)', borderRadius: 6, fontSize: 12, color: 'var(--risk-high)', cursor: 'pointer', fontFamily: 'inherit' }}
                          >
                            <Play size={11} /> Tekrar Dene
                          </button>
                        )}
                        <button
                          onClick={async () => {
                            try {
                              const { url, file_name } = await getDocumentDownloadUrl(doc.id)
                              const a = document.createElement('a')
                              a.href = url
                              a.download = file_name
                              a.click()
                            } catch {
                              toast.error('İndirme bağlantısı alınamadı')
                            }
                          }}
                          title="İndir"
                          style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', width: 28, height: 28, borderRadius: 6, background: 'var(--bg-inset)', border: '1px solid var(--border)', color: 'var(--text-faint)', cursor: 'pointer' }}
                        >
                          <Download size={12} />
                        </button>
                        <button onClick={() => handleDelete(doc.id, doc.file_name)} title="Sil" style={{ display: 'inline-flex', alignItems: 'center', justifyContent: 'center', width: 28, height: 28, borderRadius: 6, background: 'transparent', border: '1px solid var(--border)', color: 'var(--text-faint)', cursor: 'pointer' }}>
                          <Trash2 size={12} />
                        </button>
                      </div>
                    </td>
                  </tr>
                )
              })}
            </tbody>
          </table>
        )}
      </div>

      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  )
}
