'use client'

import { useEffect, useState } from 'react'
import Link from 'next/link'
import { RiskBadge } from '@/components/analysis/RiskBadge'
import { listAnalyses, deleteAnalysis } from '@/lib/api'
import type { AnalysisRecord, RiskLevel } from '@/lib/types'
import { SOZLESME_TURU_LABELS } from '@/lib/types'
import { toast } from 'sonner'

const STATIC_ROWS = [
  { name: 'Kira Sözleşmesi — Beyoğlu', sub: '14 madde · 3 sayfa · 1.2 MB', tur: 'Kira', risk: 'RED' as RiskLevel, score: 81, tarih: '29 May 2026' },
  { name: 'Belirsiz Süreli İş Sözleşmesi', sub: '22 madde · 6 sayfa · 2.4 MB', tur: 'İş', risk: 'YELLOW' as RiskLevel, score: 58, tarih: '27 May 2026' },
  { name: 'Mal Tedarik Sözleşmesi — Acme Ltd.', sub: '31 madde · 9 sayfa · 3.1 MB', tur: 'Ticari', risk: 'YELLOW' as RiskLevel, score: 61, tarih: '24 May 2026' },
  { name: 'Mesafeli Satış Sözleşmesi', sub: '11 madde · 2 sayfa · 0.8 MB', tur: 'Tüketici', risk: 'GREEN' as RiskLevel, score: 28, tarih: '22 May 2026' },
]

const ACTIVITY = [
  { icon: '!', style: { color: 'var(--risk-high)', borderColor: 'var(--risk-high-ring)', background: 'var(--risk-high-soft)' }, text: 'Kira Sözleşmesi — Beyoğlu analizi tamamlandı, 3 yüksek riskli madde tespit edildi.', time: '29 May · 14:08' },
  { icon: '↑', style: { color: 'var(--accent)', borderColor: 'var(--accent-ring)', background: 'var(--accent-soft)' }, text: 'Hisse Devir Sözleşmesi başarıyla yüklendi, RAG kuyruğuna alındı.', time: '29 May · 13:54' },
  { icon: '✓', style: { color: 'var(--risk-safe)', borderColor: 'var(--risk-safe-ring)', background: 'var(--risk-safe-soft)' }, text: 'Mesafeli Satış Sözleşmesi kanun uyumluluğu yüksek bulundu (skor: 28).', time: '22 May · 10:21' },
  { icon: '§', style: {}, text: 'Kanun veritabanı güncellendi: TBK m.344 2026 değişiklikleri eklendi.', time: '20 May · 09:00' },
]

export default function DashboardPage() {
  const [analyses, setAnalyses] = useState<AnalysisRecord[]>([])
  const [filter, setFilter] = useState<'Tümü' | 'Yüksek' | 'Dikkat' | 'Uygun'>('Tümü')

  useEffect(() => {
    listAnalyses().then(setAnalyses).catch(() => {})
  }, [])

  const scoreColor = (s: number) => s >= 70 ? 'var(--risk-high)' : s >= 40 ? 'var(--risk-mid)' : 'var(--risk-safe)'

  return (
    <div style={{ padding: '32px 32px 80px', maxWidth: 1320 }}>
      {/* Page head */}
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginBottom: 28 }}>
        <div>
          <h1 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 32, fontWeight: 500, letterSpacing: '-0.025em', margin: '0 0 6px', color: 'var(--text)' }}>
            İyi günler, <em style={{ fontStyle: 'italic', color: 'var(--accent-hover)', fontWeight: 400 }}>kullanıcı</em>.
          </h1>
          <p style={{ color: 'var(--text-muted)', fontSize: 14, margin: 0 }}>
            Analizlerinizi inceleyin ve yeni sözleşme yükleyin.
          </p>
        </div>
        <div style={{ display: 'flex', gap: 10 }}>
          <button style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '8px 14px', background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-sm)', color: 'var(--text-soft)', cursor: 'pointer', fontSize: 13 }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>
            Rapor indir
          </button>
          <Link href="/upload" style={{ display: 'flex', alignItems: 'center', gap: 6, padding: '8px 14px', background: 'var(--accent)', color: '#fff', border: 'none', borderRadius: 'var(--r-sm)', fontSize: 13, fontWeight: 500, boxShadow: 'var(--shadow-glow)' }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2"><path d="M12 5v14M5 12h14"/></svg>
            Yeni Analiz
          </Link>
        </div>
      </div>

      {/* KPI Cards — 4 columns */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 16, marginBottom: 32 }}>
        {[
          { glow: 'var(--accent-soft)', label: 'Toplam Belge', icon: <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>, value: '24', valueColor: 'var(--text)', delta: '↑ 6 bu hafta', deltaColor: 'var(--risk-safe)', spark: <polyline points="0,22 12,18 24,20 36,12 48,15 60,7 72,9 80,4" stroke="var(--accent-hover)" strokeWidth="1.5" fill="none"/> },
          { glow: 'rgba(16,185,129,0.18)', label: 'Tamamlanan Analiz', icon: <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><polyline points="20 6 9 17 4 12"/></svg>, value: '21', valueColor: 'var(--text)', delta: '↑ %18 önceki aydan', deltaColor: 'var(--risk-safe)', spark: <polyline points="0,20 12,16 24,18 36,10 48,12 60,8 72,5 80,3" stroke="var(--risk-safe)" strokeWidth="1.5" fill="none"/> },
          { glow: 'rgba(245,158,11,0.18)', label: 'Ortalama Risk', icon: <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>, value: '58', valueColor: 'var(--risk-mid)', delta: '↓ 4 puan azaldı', deltaColor: 'var(--risk-high)', spark: <polyline points="0,8 12,10 24,9 36,14 48,12 60,18 72,16 80,21" stroke="var(--risk-mid)" strokeWidth="1.5" fill="none"/> },
          { glow: 'rgba(239,68,68,0.18)', label: 'Tespit edilen risk', icon: <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M10.29 3.86 1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><path d="M12 9v4M12 17h.01"/></svg>, value: '7', valueColor: 'var(--risk-high)', delta: '3 yüksek · 4 dikkat', deltaColor: 'var(--text-muted)', spark: null },
        ].map(({ glow, label, icon, value, valueColor, delta, deltaColor, spark }) => (
          <div key={label} style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)', padding: '20px 22px', position: 'relative', overflow: 'hidden' }}>
            <div style={{ position: 'absolute', inset: 'auto auto -40px -40px', width: 120, height: 120, background: `radial-gradient(circle, ${glow} 0%, transparent 70%)`, pointerEvents: 'none' }} />
            <div style={{ fontSize: 12.5, color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: 8 }}>
              <span style={{ width: 22, height: 22, borderRadius: 6, background: 'var(--bg-inset)', border: '1px solid var(--border)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-soft)' }}>{icon}</span>
              {label}
            </div>
            <div style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 36, fontWeight: 500, letterSpacing: '-0.025em', margin: '12px 0 6px', lineHeight: 1, color: valueColor }}>{value}</div>
            <div style={{ fontSize: 12, color: deltaColor, display: 'inline-flex', alignItems: 'center', gap: 4 }}>{delta}</div>
            {spark && (
              <svg style={{ position: 'absolute', bottom: 14, right: 16, opacity: 0.5 }} width="80" height="28" viewBox="0 0 80 28" fill="none">{spark}</svg>
            )}
          </div>
        ))}
      </div>

      {/* Legal banner */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '12px 16px', background: 'var(--risk-mid-soft)', border: '1px solid var(--risk-mid-ring)', borderRadius: 'var(--r-sm)', marginBottom: 28, fontSize: 13, color: 'var(--text-soft)' }}>
        <span style={{ width: 24, height: 24, borderRadius: 6, background: 'var(--risk-mid-soft)', color: 'var(--risk-mid)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center' }}>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.8"><circle cx="12" cy="12" r="9"/><path d="M12 8v5M12 16h.01" strokeLinecap="round"/></svg>
        </span>
        <span>Analizler <strong style={{ color: 'var(--text)' }}>bilgilendirme amaçlıdır</strong>. Hukuki karar almadan önce bir avukata danışınız.</span>
        <a href="#" style={{ marginLeft: 'auto', color: 'var(--text-muted)', fontSize: 12 }}>Detaylı bilgi →</a>
      </div>

      {/* 2-col grid: table + right panels */}
      <div style={{ display: 'grid', gridTemplateColumns: '1.5fr 1fr', gap: 16, alignItems: 'start' }}>
        {/* Left: table panel */}
        <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)', overflow: 'hidden' }}>
          <div style={{ padding: '18px 22px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderBottom: '1px solid var(--border)' }}>
            <h3 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 18, fontWeight: 600, margin: 0, letterSpacing: '-0.01em', color: 'var(--text)' }}>Son Analizler</h3>
            <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
              <div style={{ display: 'inline-flex', background: 'var(--bg-inset)', border: '1px solid var(--border)', borderRadius: 'var(--r-sm)', overflow: 'hidden' }}>
                {(['Tümü', 'Yüksek', 'Dikkat', 'Uygun'] as const).map((f) => (
                  <button key={f} onClick={() => setFilter(f)} style={{ background: filter === f ? 'var(--bg-card-hover)' : 'transparent', border: 0, color: filter === f ? 'var(--text)' : 'var(--text-muted)', fontFamily: 'inherit', fontSize: 12, padding: '5px 11px', cursor: 'pointer' }}>{f}</button>
                ))}
              </div>
            </div>
          </div>
          <table style={{ width: '100%', borderCollapse: 'collapse', fontSize: 13.5 }}>
            <thead>
              <tr>
                {['Belge', 'Tür', 'Risk', 'Skor', 'Tarih', ''].map((h) => (
                  <th key={h} style={{ fontWeight: 500, textAlign: 'left', color: 'var(--text-faint)', fontSize: 11.5, textTransform: 'uppercase' as const, letterSpacing: '0.06em', padding: '12px 22px', borderBottom: '1px solid var(--border)', background: 'var(--bg-inset)' }}>{h}</th>
                ))}
              </tr>
            </thead>
            <tbody>
              {STATIC_ROWS.filter(r => filter === 'Tümü' || (filter === 'Yüksek' && r.risk === 'RED') || (filter === 'Dikkat' && r.risk === 'YELLOW') || (filter === 'Uygun' && r.risk === 'GREEN')).map((row) => (
                <tr key={row.name} style={{ borderBottom: '1px solid var(--border-subtle)', transition: 'background 0.1s' }}>
                  <td style={{ padding: '14px 22px', color: 'var(--text-soft)' }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 10, color: 'var(--text)', fontWeight: 500 }}>
                      <div style={{ width: 30, height: 30, borderRadius: 6, background: 'var(--accent-soft)', border: '1px solid var(--accent-ring)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--accent-hover)', flexShrink: 0 }}>
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>
                      </div>
                      <div>
                        {row.name}
                        <div style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10.5, color: 'var(--text-faint)', marginTop: 2, fontWeight: 400 }}>{row.sub}</div>
                      </div>
                    </div>
                  </td>
                  <td style={{ padding: '14px 22px' }}><span style={{ padding: '2px 8px', borderRadius: 'var(--r-full)', background: 'var(--bg-inset)', border: '1px solid var(--border)', fontSize: 11.5, color: 'var(--text-muted)' }}>{row.tur}</span></td>
                  <td style={{ padding: '14px 22px' }}><RiskBadge level={row.risk} size="sm" /></td>
                  <td style={{ padding: '14px 22px' }}><span style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 16, fontWeight: 500, letterSpacing: '-0.01em', color: scoreColor(row.score) }}>{row.score}</span></td>
                  <td style={{ padding: '14px 22px', color: 'var(--text-soft)', fontSize: 12.5 }}>{row.tarih}</td>
                  <td style={{ padding: '14px 22px' }}>
                    <div style={{ display: 'flex', gap: 4, justifyContent: 'flex-end' }}>
                      {[
                        <svg key="eye" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>,
                        <svg key="dl" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/></svg>,
                        <svg key="more" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><circle cx="12" cy="12" r="1"/><circle cx="19" cy="12" r="1"/><circle cx="5" cy="12" r="1"/></svg>,
                      ].map((icon, i) => (
                        <button key={i} style={{ background: 'transparent', border: 0, color: 'var(--text-faint)', cursor: 'pointer', padding: 6, borderRadius: 6 }}>{icon}</button>
                      ))}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Right column */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
          {/* Risk Distribution */}
          <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)', overflow: 'hidden' }}>
            <div style={{ padding: '18px 22px 14px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderBottom: '1px solid var(--border)' }}>
              <h3 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 16, fontWeight: 600, margin: 0, color: 'var(--text)' }}>Risk Dağılımı</h3>
            </div>
            <div style={{ padding: 22 }}>
              <div style={{ display: 'flex', alignItems: 'flex-end', gap: 20, marginBottom: 22 }}>
                <div style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 56, fontWeight: 500, letterSpacing: '-0.03em', color: 'var(--risk-mid)', lineHeight: 0.9 }}>58</div>
                <div>
                  <div style={{ fontSize: 13, color: 'var(--text)' }}>Ortalama risk skoru</div>
                  <div style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 2 }}>21 tamamlanmış analiz · son 30 gün</div>
                </div>
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
                {[
                  { color: 'var(--risk-high)', label: 'Yüksek risk', count: '3 belge · %14', pct: '14%' },
                  { color: 'var(--risk-mid)', label: 'Dikkat', count: '10 belge · %48', pct: '48%' },
                  { color: 'var(--risk-safe)', label: 'Uygun', count: '8 belge · %38', pct: '38%' },
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
            </div>
          </div>

          {/* Activity */}
          <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)', overflow: 'hidden' }}>
            <div style={{ padding: '18px 22px 14px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderBottom: '1px solid var(--border)' }}>
              <h3 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 16, fontWeight: 600, margin: 0, color: 'var(--text)' }}>Etkinlik</h3>
              <a href="#" style={{ fontSize: 12, color: 'var(--accent)' }}>Tümünü gör</a>
            </div>
            <div>
              {ACTIVITY.map((item, i) => (
                <div key={i} style={{ display: 'flex', gap: 12, padding: '14px 22px', borderTop: i > 0 ? '1px solid var(--border-subtle)' : 'none', fontSize: 13 }}>
                  <span style={{ flexShrink: 0, width: 28, height: 28, borderRadius: 7, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-soft)', border: '1px solid var(--border)', background: 'var(--bg-inset)', ...item.style, fontSize: 13 }}>{item.icon}</span>
                  <div>
                    <p style={{ margin: 0, lineHeight: 1.5, color: 'var(--text-soft)' }}>{item.text}</p>
                    <small style={{ color: 'var(--text-faint)', fontFamily: 'JetBrains Mono, monospace', fontSize: 10.5 }}>{item.time}</small>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>

      {/* FAB */}
      <Link href="/upload" style={{ position: 'fixed', bottom: 28, right: 32, height: 52, padding: '0 22px 0 18px', background: 'linear-gradient(180deg, var(--accent-hover) 0%, var(--accent-deep) 100%)', color: '#fff', border: 0, borderRadius: 26, fontFamily: 'inherit', fontSize: 14, fontWeight: 500, display: 'inline-flex', alignItems: 'center', gap: 9, cursor: 'pointer', boxShadow: '0 12px 32px -8px var(--accent-glow), 0 0 0 1px var(--accent-ring), 0 0 0 8px var(--accent-soft), inset 0 1px 0 rgba(255,255,255,0.2)', zIndex: 50 }}>
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4"><path d="M12 5v14M5 12h14"/></svg>
        Yeni Analiz
      </Link>
    </div>
  )
}
