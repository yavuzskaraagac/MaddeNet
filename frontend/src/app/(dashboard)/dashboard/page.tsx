'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { RiskBadge } from '@/components/analysis/RiskBadge'
import { listAnalyses, deleteAnalysis } from '@/lib/api'
import { createClient } from '@/lib/supabase'
import type { AnalysisSummary, RiskLevel } from '@/lib/types'
import { SOZLESME_TURU_LABELS } from '@/lib/types'
import { toast } from 'sonner'

type FilterKey = 'Tümü' | 'Yüksek' | 'Dikkat' | 'Uygun'

const riskFilterMap: Record<FilterKey, RiskLevel | null> = {
  Tümü: null,
  Yüksek: 'red',
  Dikkat: 'yellow',
  Uygun: 'green',
}

function formatDate(iso: string) {
  return new Date(iso).toLocaleDateString('tr-TR', { day: 'numeric', month: 'short', year: 'numeric' })
}

function scoreColor(s: number) {
  return s >= 70 ? 'var(--risk-high)' : s >= 40 ? 'var(--risk-mid)' : 'var(--risk-safe)'
}

export default function DashboardPage() {
  const [analyses, setAnalyses] = useState<AnalysisSummary[]>([])
  const [loading, setLoading] = useState(true)
  const [filter, setFilter] = useState<FilterKey>('Tümü')
  const [userName, setUserName] = useState<string>('kullanıcı')

  useEffect(() => {
    const supabase = createClient()
    // Paralel çalıştır — biri diğerini beklemesin
    Promise.all([
      supabase.auth.getSession(),
      listAnalyses(),
    ]).then(([{ data: { session } }, data]) => {
      const email = session?.user?.email
      if (email) setUserName(email.split('@')[0])
      setAnalyses(data)
    }).catch((e) => {
      toast.error('Veriler yüklenemedi: ' + (e?.message || 'Bağlantı hatası'))
    }).finally(() => setLoading(false))
  }, [])

  async function handleDelete(id: string) {
    try {
      await deleteAnalysis(id)
      setAnalyses(prev => prev.filter(a => a.id !== id))
      toast.success('Analiz silindi')
    } catch {
      toast.error('Silinemedi')
    }
  }

  const filtered = analyses.filter(a => {
    const target = riskFilterMap[filter]
    return target === null || a.genel_risk_seviyesi === target
  })

  const totalAnalyses = analyses.length
  const avgScore = totalAnalyses > 0
    ? Math.round(analyses.reduce((s, a) => s + a.genel_risk_skoru, 0) / totalAnalyses)
    : 0
  const highCount = analyses.filter(a => a.genel_risk_seviyesi === 'red').length
  const midCount = analyses.filter(a => a.genel_risk_seviyesi === 'yellow').length
  const safeCount = analyses.filter(a => a.genel_risk_seviyesi === 'green').length
  const highPct = totalAnalyses > 0 ? Math.round((highCount / totalAnalyses) * 100) : 0
  const midPct = totalAnalyses > 0 ? Math.round((midCount / totalAnalyses) * 100) : 0
  const safePct = totalAnalyses > 0 ? Math.round((safeCount / totalAnalyses) * 100) : 0

  const recentActivity = [...analyses]
    .sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime())
    .slice(0, 4)

  return (
    <div style={{ padding: '32px 32px 80px', maxWidth: 1320 }}>
      {/* Page head */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginBottom: 28 }}>
        <div>
          <h1 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 32, fontWeight: 500, letterSpacing: '-0.025em', margin: '0 0 6px', color: 'var(--text)' }}>
            İyi günler, <em style={{ fontStyle: 'italic', color: 'var(--accent-hover)', fontWeight: 400 }}>{userName}</em>.
          </h1>
          <p style={{ color: 'var(--text-muted)', fontSize: 14, margin: 0 }}>
            Analizlerinizi inceleyin ve yeni sözleşme yükleyin.
          </p>
        </div>
        <div style={{ display: 'flex', gap: 10 }}>
          <Link href="/upload" style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '8px 14px', background: 'var(--accent)', color: '#fff', border: 'none', borderRadius: 'var(--r-sm)', fontSize: 13, fontWeight: 500, boxShadow: 'var(--shadow-glow)', textDecoration: 'none' }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2"><path d="M12 5v14M5 12h14"/></svg>
            Yeni Analiz
          </Link>
        </div>
      </div>

      {/* KPI Cards */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 16, marginBottom: 32 }}>
        {[
          { glow: 'var(--accent-soft)', label: 'Toplam Analiz', icon: <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M3 3v18h18"/><path d="m19 9-5 5-4-4-3 3"/></svg>, value: String(totalAnalyses), valueColor: 'var(--text)', delta: totalAnalyses > 0 ? 'tamamlanmış' : 'henüz analiz yok', deltaColor: 'var(--text-muted)' },
          { glow: 'rgba(16,185,129,0.18)', label: 'Yüksek Riskli', icon: <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><path d="M12 9v4M12 17h.01"/></svg>, value: String(highCount), valueColor: highCount > 0 ? 'var(--risk-high)' : 'var(--text)', delta: 'kırmızı riskli belge', deltaColor: 'var(--text-muted)' },
          { glow: 'rgba(245,158,11,0.18)', label: 'Ortalama Risk', icon: <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>, value: totalAnalyses > 0 ? String(avgScore) : '—', valueColor: scoreColor(avgScore), delta: 'ortalama skor', deltaColor: 'var(--text-muted)' },
          { glow: 'rgba(16,185,129,0.18)', label: 'Uygun', icon: <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><polyline points="20 6 9 17 4 12"/></svg>, value: String(safeCount), valueColor: safeCount > 0 ? 'var(--risk-safe)' : 'var(--text)', delta: 'düşük riskli belge', deltaColor: 'var(--text-muted)' },
        ].map(({ glow, label, icon, value, valueColor, delta, deltaColor }) => (
          <div key={label} style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)', padding: '20px 22px', position: 'relative', overflow: 'hidden' }}>
            <div style={{ position: 'absolute', inset: 'auto auto -40px -40px', width: 120, height: 120, background: `radial-gradient(circle, ${glow} 0%, transparent 70%)`, pointerEvents: 'none' }} />
            <div style={{ fontSize: 12.5, color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: 8 }}>
              <span style={{ width: 22, height: 22, borderRadius: 6, background: 'var(--bg-inset)', border: '1px solid var(--border)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-soft)' }}>{icon}</span>
              {label}
            </div>
            <div style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 36, fontWeight: 500, letterSpacing: '-0.025em', margin: '12px 0 6px', lineHeight: 1, color: valueColor }}>{value}</div>
            <div style={{ fontSize: 12, color: deltaColor }}>{delta}</div>
          </div>
        ))}
      </div>

      {/* Legal banner */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px', background: 'var(--risk-mid-soft)', border: '1px solid var(--risk-mid-ring)', borderRadius: 'var(--r-sm)', marginBottom: 28, fontSize: 13, color: 'var(--text-soft)' }}>
        <span style={{ width: 24, height: 24, borderRadius: 6, background: 'var(--risk-mid-soft)', color: 'var(--risk-mid)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center' }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8"><circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16h.01" strokeLinecap="round"/></svg>
        </span>
        <span>Analizler <strong style={{ color: 'var(--text)' }}>bilgilendirme amaçlıdır</strong>. Hukuki karar almadan önce bir avukata danışınız.</span>
      </div>

      {/* 2-col grid */}
      <div style={{ display: 'grid', gridTemplateColumns: '1.5fr 1fr', gap: 16, alignItems: 'start' }}>
        {/* Left: table */}
        <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)', overflow: 'hidden' }}>
          <div style={{ padding: '18px 22px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderBottom: '1px solid var(--border)' }}>
            <h3 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 18, fontWeight: 600, margin: 0, letterSpacing: '-0.01em', color: 'var(--text)' }}>Son Analizler</h3>
            <div style={{ display: 'inline-flex', background: 'var(--bg-inset)', border: '1px solid var(--border)', borderRadius: 'var(--r-sm)', overflow: 'hidden' }}>
              {(['Tümü', 'Yüksek', 'Dikkat', 'Uygun'] as const).map((f) => (
                <button key={f} onClick={() => setFilter(f)} style={{ background: filter === f ? 'var(--bg-card-hover)' : 'transparent', border: 0, color: filter === f ? 'var(--text)' : 'var(--text-muted)', fontFamily: 'inherit', fontSize: 12, padding: '5px 11px', cursor: 'pointer' }}>{f}</button>
              ))}
            </div>
          </div>

          {loading ? (
            <div style={{ padding: '48px 22px', textAlign: 'center', color: 'var(--text-muted)', fontSize: 13 }}>Yükleniyor…</div>
          ) : filtered.length === 0 ? (
            <div style={{ padding: '48px 22px', textAlign: 'center' }}>
              <p style={{ color: 'var(--text-muted)', fontSize: 13, marginBottom: 16 }}>
                {totalAnalyses === 0 ? 'Henüz analiz yok. İlk sözleşmenizi yükleyin.' : 'Bu filtreye uygun analiz bulunamadı.'}
              </p>
              {totalAnalyses === 0 && (
                <Link href="/upload" style={{ display: 'inline-flex', alignItems: 'center', gap: 6, padding: '8px 16px', background: 'var(--accent)', color: '#fff', borderRadius: 'var(--r-sm)', fontSize: 13, fontWeight: 500, textDecoration: 'none' }}>
                  Yeni Analiz Başlat
                </Link>
              )}
            </div>
          ) : (
            <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13.5 }}>
              <thead>
                <tr>
                  {['Belge', 'Tür', 'Risk', 'Skor', 'Tarih', ''].map((h) => (
                    <th key={h} style={{ fontWeight: 500, textAlign: 'left', color: 'var(--text-faint)', fontSize: 11.5, textTransform: 'uppercase' as const, letterSpacing: '0.06em', padding: '12px 22px', borderBottom: '1px solid var(--border)', background: 'var(--bg-inset)' }}>{h}</th>
                  ))}
                </tr>
              </thead>
              <tbody>
                {filtered.map((a) => (
                  <tr key={a.id} style={{ borderBottom: '1px solid var(--border-subtle)' }}>
                    <td style={{ padding: '14px 22px' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 10, color: 'var(--text)', fontWeight: 500 }}>
                        <div style={{ width: 30, height: 30, borderRadius: 6, background: 'var(--accent-soft)', border: '1px solid var(--accent-ring)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--accent-hover)', flexShrink: 0 }}>
                          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                        </div>
                        <div>
                          <Link href={`/analysis/${a.id}`} style={{ color: 'inherit', textDecoration: 'none' }}>
                            {SOZLESME_TURU_LABELS[a.sozlesme_turu]}
                          </Link>
                          <div style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10.5, color: 'var(--text-faint)', marginTop: 2, fontWeight: 400 }}>{a.madde_sayisi} madde</div>
                        </div>
                      </div>
                    </td>
                    <td style={{ padding: '14px 22px' }}><span style={{ padding: '2px 8px', borderRadius: 'var(--r-full)', background: 'var(--bg-inset)', border: '1px solid var(--border)', fontSize: 11.5, color: 'var(--text-muted)' }}>{SOZLESME_TURU_LABELS[a.sozlesme_turu]}</span></td>
                    <td style={{ padding: '14px 22px' }}><RiskBadge level={a.genel_risk_seviyesi} size="sm" /></td>
                    <td style={{ padding: '14px 22px' }}><span style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 16, fontWeight: 500, letterSpacing: '-0.01em', color: scoreColor(a.genel_risk_skoru) }}>{a.genel_risk_skoru}</span></td>
                    <td style={{ padding: '14px 22px', color: 'var(--text-soft)', fontSize: 12.5 }}>{formatDate(a.created_at)}</td>
                    <td style={{ padding: '14px 22px' }}>
                      <div style={{ display: 'flex', gap: 4, justifyContent: 'flex-end' }}>
                        <Link href={`/analysis/${a.id}`} style={{ background: 'transparent', border: 0, color: 'var(--text-faint)', cursor: 'pointer', padding: 6, borderRadius: 6, display: 'inline-flex', alignItems: 'center' }}>
                          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>
                        </Link>
                        <button onClick={() => handleDelete(a.id)} style={{ background: 'transparent', border: 0, color: 'var(--text-faint)', cursor: 'pointer', padding: 6, borderRadius: 6 }}>
                          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 0 1-2 2H8a2 2 0 0 1-2-2L5 6"/><path d="M10 11v6M14 11v6"/><path d="M9 6V4h6v2"/></svg>
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>

        {/* Right column */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          {/* Risk Distribution */}
          <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)', overflow: 'hidden' }}>
            <div style={{ padding: '18px 22px 14px', borderBottom: '1px solid var(--border)' }}>
              <h3 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 16, fontWeight: 600, margin: 0, color: 'var(--text)' }}>Risk Dağılımı</h3>
            </div>
            <div style={{ padding: 22 }}>
              <div style={{ display: 'flex', alignItems: 'flex-end', gap: 20, marginBottom: 22 }}>
                <div style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 56, fontWeight: 500, letterSpacing: '-0.03em', color: scoreColor(avgScore), lineHeight: 0.9 }}>{totalAnalyses > 0 ? avgScore : '—'}</div>
                <div>
                  <div style={{ fontSize: 13, color: 'var(--text)' }}>Ortalama risk skoru</div>
                  <div style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 2 }}>{totalAnalyses} tamamlanmış analiz</div>
                </div>
              </div>
              {totalAnalyses > 0 ? (
                <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
                  {[
                    { color: 'var(--risk-high)', label: 'Yüksek risk', count: `${highCount} belge · %${highPct}`, pct: `${highPct}%` },
                    { color: 'var(--risk-mid)', label: 'Dikkat', count: `${midCount} belge · %${midPct}`, pct: `${midPct}%` },
                    { color: 'var(--risk-safe)', label: 'Uygun', count: `${safeCount} belge · %${safePct}`, pct: `${safePct}%` },
                  ].map(({ color, label, count, pct }) => (
                    <div key={label} style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 13 }}>
                        <span style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
                          <span style={{ width: 7, height: 7, borderRadius: '50%', background: color }} />
                          {label}
                        </span>
                        <b style={{ fontFamily: 'JetBrains Mono, monospace', fontWeight: 500 }}>{count}</b>
                      </div>
                      <div style={{ height: 6, background: 'var(--bg-inset)', borderRadius: 6, overflow: 'hidden' }}>
                        <div style={{ height: '100%', width: pct, background: color, borderRadius: 6 }} />
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <p style={{ color: 'var(--text-muted)', fontSize: 13 }}>Henüz analiz bulunmuyor.</p>
              )}
            </div>
          </div>

          {/* Activity */}
          <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)', overflow: 'hidden' }}>
            <div style={{ padding: '18px 22px 14px', borderBottom: '1px solid var(--border)' }}>
              <h3 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 16, fontWeight: 600, margin: 0, color: 'var(--text)' }}>Son Etkinlik</h3>
            </div>
            {recentActivity.length === 0 ? (
              <div style={{ padding: '24px 22px', color: 'var(--text-muted)', fontSize: 13 }}>Henüz etkinlik yok.</div>
            ) : (
              <div>
                {recentActivity.map((a, i) => {
                  const iconStyle = a.genel_risk_seviyesi === 'red'
                    ? { color: 'var(--risk-high)', borderColor: 'var(--risk-high-ring)', background: 'var(--risk-high-soft)' }
                    : a.genel_risk_seviyesi === 'yellow'
                    ? { color: 'var(--risk-mid)', borderColor: 'var(--risk-mid-ring)', background: 'var(--risk-mid-soft)' }
                    : { color: 'var(--risk-safe)', borderColor: 'var(--risk-safe-ring)', background: 'var(--risk-safe-soft)' }
                  const icon = a.genel_risk_seviyesi === 'red' ? '!' : a.genel_risk_seviyesi === 'yellow' ? '~' : '✓'
                  return (
                    <div key={a.id} style={{ display: 'flex', gap: 12, padding: '14px 22px', borderTop: i > 0 ? '1px solid var(--border-subtle)' : 'none', fontSize: 13 }}>
                      <span style={{ flexShrink: 0, width: 28, height: 28, borderRadius: 7, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', border: '1px solid var(--border)', ...iconStyle, fontSize: 13 }}>{icon}</span>
                      <div>
                        <p style={{ margin: 0, lineHeight: 1.5, color: 'var(--text-soft)' }}>
                          <Link href={`/analysis/${a.id}`} style={{ color: 'inherit' }}>{SOZLESME_TURU_LABELS[a.sozlesme_turu]}</Link>{' '}analizi tamamlandı · Skor: <b style={{ color: scoreColor(a.genel_risk_skoru) }}>{a.genel_risk_skoru}</b>
                        </p>
                        <small style={{ color: 'var(--text-faint)', fontFamily: 'JetBrains Mono, monospace', fontSize: 10.5 }}>{formatDate(a.created_at)}</small>
                      </div>
                    </div>
                  )
                })}
              </div>
            )}
          </div>
        </div>
      </div>

      {/* FAB */}
      <Link href="/upload" style={{ position: 'fixed', bottom: 28, right: 32, height: 52, padding: '0 22px 0 18px', background: 'linear-gradient(180deg, var(--accent-hover) 0%, var(--accent-deep) 100%)', color: '#fff', border: 0, borderRadius: 26, fontFamily: 'inherit', fontSize: 14, fontWeight: 500, display: 'inline-flex', alignItems: 'center', gap: 9, cursor: 'pointer', boxShadow: '0 12px 32px -8px var(--accent-glow), 0 0 0 1px var(--accent-ring), 0 0 0 8px var(--accent-soft), inset 0 1px 0 rgba(255,255,255,0.2)', zIndex: 50, textDecoration: 'none' }}>
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4"><path d="M12 5v14M5 12h14"/></svg>
        Yeni Analiz
      </Link>
    </div>
  )
}
