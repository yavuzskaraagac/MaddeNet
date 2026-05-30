'use client'

import { useEffect, useState } from 'react'
import { useParams, useRouter } from 'next/navigation'
import { Download, ArrowLeft, Scale, ChevronLeft, ChevronRight, CheckCircle, X, MessageCircle } from 'lucide-react'
import { RiskBadge } from '@/components/analysis/RiskBadge'
import { getAnalysis } from '@/lib/api'
import type { ContractAnalysisResult, ClauseAnalysis, RiskLevel } from '@/lib/types'
import { SOZLESME_TURU_LABELS } from '@/lib/types'

const borderLeft = (level: RiskLevel) => ({
  RED: 'var(--risk-high)',
  YELLOW: 'var(--risk-mid)',
  GREEN: 'var(--risk-safe)',
}[level])

function AnnotCard({ clause, index, isActive, onSelect }: { clause: ClauseAnalysis; index: number; isActive: boolean; onSelect: () => void }) {
  const border = borderLeft(clause.risk_seviyesi)
  const numBg = { RED: { bg: 'var(--risk-high-soft)', border: 'var(--risk-high-ring)', color: 'var(--risk-high)' }, YELLOW: { bg: 'var(--risk-mid-soft)', border: 'var(--risk-mid-ring)', color: 'var(--risk-mid)' }, GREEN: { bg: 'var(--risk-safe-soft)', border: 'var(--risk-safe-ring)', color: 'var(--risk-safe)' } }[clause.risk_seviyesi]

  return (
    <article
      onClick={onSelect}
      style={{ padding: '28px 32px', borderBottom: '1px solid var(--border-subtle)', cursor: 'pointer', background: isActive ? 'var(--bg-card)' : 'transparent', transition: 'background 0.15s' }}
    >
      <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 14 }}>
        <span style={{ width: 32, height: 32, borderRadius: 8, background: numBg.bg, border: `1px solid ${numBg.border}`, color: numBg.color, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', fontFamily: 'JetBrains Mono, monospace', fontWeight: 600, fontSize: 13, flexShrink: 0 }}>
          {String.fromCharCode(65 + index)}
        </span>
        <h3 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 17, fontWeight: 600, letterSpacing: '-0.01em', margin: 0, flex: 1, color: 'var(--text)' }}>
          Madde {clause.madde_no || index + 1}
        </h3>
        <RiskBadge level={clause.risk_seviyesi} size="sm" />
      </div>

      <blockquote style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 13.5, fontStyle: 'italic', lineHeight: 1.55, color: 'var(--text-soft)', margin: '0 0 16px', padding: '12px 16px', background: 'var(--bg-card)', borderLeft: `2px solid ${border}`, borderRadius: '0 6px 6px 0' }}>
        &ldquo;{clause.madde_metni?.slice(0, 200)}{clause.madde_metni?.length > 200 ? '…' : ''}&rdquo;
      </blockquote>

      <div style={{ fontSize: 13, lineHeight: 1.6, color: 'var(--text-soft)' }}>
        <p style={{ margin: '0 0 10px' }}>{clause.aciklama}</p>
      </div>

      {/* Law link */}
      {clause.kanun_dayanagi && (
        <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '12px 14px', background: 'var(--accent-soft)', border: '1px solid var(--accent-ring)', borderRadius: 'var(--r-sm)', marginTop: 14 }}>
          <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 12, color: 'var(--accent)', background: 'var(--bg-elevated)', border: '1px solid var(--accent-ring)', padding: '2px 7px', borderRadius: 4, fontWeight: 500, flexShrink: 0 }}>{clause.kanun_dayanagi}</span>
          <span style={{ fontSize: 12.5, color: 'var(--text-soft)', flex: 1 }}>Kanun referansı</span>
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="var(--accent)" strokeWidth="1.8"><path d="M7 7h10v10"/><path d="M7 17 17 7"/></svg>
        </div>
      )}

      {/* Suggestion */}
      {clause.oneri && (
        <div style={{ marginTop: 16, padding: '14px 16px', borderRadius: 'var(--r-sm)', background: 'var(--risk-safe-soft)', border: '1px solid var(--risk-safe-ring)' }}>
          <h4 style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10.5, color: 'var(--risk-safe)', textTransform: 'uppercase' as const, letterSpacing: '0.1em', margin: '0 0 6px', fontWeight: 500, display: 'flex', alignItems: 'center', gap: 6 }}>
            <svg width="11" height="11" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><polyline points="9 11 12 14 22 4"/><path d="M21 12v7a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11"/></svg>
            Öneri
          </h4>
          <p style={{ margin: 0, fontSize: 13, lineHeight: 1.55, color: 'var(--text-soft)' }}>{clause.oneri}</p>
        </div>
      )}

      {/* Actions */}
      <div style={{ display: 'flex', gap: 6, marginTop: 16 }}>
        {[
          { icon: <CheckCircle size={11} />, label: 'Kabul' },
          { icon: <X size={11} />, label: 'Reddet' },
          { icon: <MessageCircle size={11} />, label: 'Avukata sor' },
        ].map(({ icon, label }) => (
          <button key={label} style={{ background: 'var(--bg-inset)', border: '1px solid var(--border)', color: 'var(--text-soft)', fontFamily: 'inherit', fontSize: 12, padding: '6px 11px', borderRadius: 6, cursor: 'pointer', display: 'inline-flex', alignItems: 'center', gap: 5 }}>
            {icon} {label}
          </button>
        ))}
        <button style={{ background: 'var(--bg-inset)', border: '1px solid var(--border)', color: 'var(--text-soft)', fontFamily: 'inherit', fontSize: 12, padding: '6px 11px', borderRadius: 6, cursor: 'pointer', marginLeft: 'auto' }}>⋯</button>
      </div>
    </article>
  )
}

export default function AnalysisPage() {
  const { id } = useParams<{ id: string }>()
  const router = useRouter()
  const [result, setResult] = useState<ContractAnalysisResult | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [activeIdx, setActiveIdx] = useState(0)

  useEffect(() => {
    if (!id) return
    getAnalysis(id)
      .then(setResult)
      .catch((e) => setError(e.message || 'Yüklenemedi'))
      .finally(() => setLoading(false))
  }, [id])

  if (loading) return (
    <div style={{ height: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--bg)' }}>
      <p style={{ color: 'var(--text-muted)' }}>Analiz yükleniyor…</p>
    </div>
  )

  if (error || !result) return (
    <div style={{ textAlign: 'center', padding: 48 }}>
      <p style={{ color: 'var(--risk-high)', marginBottom: 16 }}>{error ?? 'Bulunamadı'}</p>
      <button onClick={() => router.back()} style={{ color: 'var(--accent)', background: 'none', border: 'none', cursor: 'pointer' }}>← Geri dön</button>
    </div>
  )

  const overallLevel: RiskLevel = result.genel_risk_skoru >= 70 ? 'RED' : result.genel_risk_skoru >= 40 ? 'YELLOW' : 'GREEN'
  const activeClause: ClauseAnalysis | undefined = result.maddeler[activeIdx]

  return (
    <div style={{ display: 'grid', gridTemplateRows: '56px 1fr', height: '100vh', overflow: 'hidden', background: 'var(--bg)' }}>
      {/* Topbar */}
      <header style={{ borderBottom: '1px solid var(--border)', background: 'color-mix(in srgb, var(--bg) 85%, transparent)', backdropFilter: 'blur(12px)', display: 'flex', alignItems: 'center', padding: '0 20px', gap: 16 }}>
        <button onClick={() => router.back()} style={{ display: 'flex', alignItems: 'center', gap: 5, padding: '5px 10px', background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-sm)', color: 'var(--text-soft)', cursor: 'pointer', fontSize: 12.5 }}>
          <ArrowLeft size={12} /> Geri
        </button>

        <div style={{ display: 'flex', alignItems: 'center', gap: 10, flex: 1, fontSize: 13, color: 'var(--text-muted)' }}>
          <a href="/dashboard" style={{ color: 'var(--text-muted)' }}>Belgelerim</a>
          <span style={{ color: 'var(--text-faint)' }}>/</span>
          <b style={{ color: 'var(--text)', fontWeight: 500 }}>
            {SOZLESME_TURU_LABELS[result.sozlesme_turu]}
          </b>
        </div>

        {/* Score pill */}
        <span style={{ display: 'inline-flex', alignItems: 'center', gap: 8, background: 'var(--risk-high-soft)', border: '1px solid var(--risk-high-ring)', borderRadius: 'var(--r-full)', padding: '4px 12px 4px 4px', fontSize: 12, color: 'var(--risk-high)' }}>
          <span style={{ background: 'var(--risk-high)', color: '#fff', borderRadius: 'var(--r-full)', padding: '2px 9px', fontFamily: 'Newsreader, Georgia, serif', fontSize: 13, fontWeight: 500 }}>{result.genel_risk_skoru}</span>
          Yüksek risk
        </span>

        {/* View toggle */}
        <div style={{ display: 'inline-flex', background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-sm)', padding: 3 }}>
          <button style={{ background: 'transparent', border: 0, padding: '5px 11px', borderRadius: 5, color: 'var(--text-muted)', cursor: 'pointer', fontSize: 12.5 }}>Liste</button>
          <button style={{ background: 'var(--bg-card-hover)', border: 0, padding: '5px 11px', color: 'var(--text)', borderRadius: 5, cursor: 'pointer', fontSize: 12.5 }}>Bölünmüş</button>
        </div>

        <button style={{ display: 'inline-flex', alignItems: 'center', gap: 6, background: 'var(--bg-card)', border: '1px solid var(--border)', color: 'var(--text-soft)', borderRadius: 'var(--r-sm)', padding: '6px 11px', fontSize: 12.5, cursor: 'pointer' }}>
          <Download size={13} /> PDF
        </button>
      </header>

      {/* Split panes */}
      <div style={{ display: 'grid', gridTemplateColumns: '1.3fr 1fr', minHeight: 0, overflow: 'hidden' }}>
        {/* LEFT: Document pane */}
        <section style={{ borderRight: '1px solid var(--border)', overflowY: 'auto', background: 'var(--bg-deep)', padding: '40px 56px 80px', position: 'relative' }}>
          {/* Dot grid overlay */}
          <div style={{ position: 'absolute', inset: 0, backgroundImage: 'radial-gradient(circle at center, var(--grid-line) 1px, transparent 1px)', backgroundSize: '24px 24px', opacity: 0.4, pointerEvents: 'none' }} />

          {/* Paper */}
          <div style={{ position: 'relative', zIndex: 1, maxWidth: 660, margin: '0 auto', background: 'var(--bg-elevated)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)', padding: '56px 64px', boxShadow: 'var(--shadow-lg)', fontFamily: 'Newsreader, Georgia, serif', fontSize: 14, lineHeight: 1.75, color: 'var(--text-soft)' }}>
            {/* Paper head */}
            <div style={{ textAlign: 'center', borderBottom: '1px solid var(--border)', paddingBottom: 24, marginBottom: 28 }}>
              <div style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10.5, color: 'var(--text-faint)', letterSpacing: '0.15em', textTransform: 'uppercase', marginBottom: 8 }}>SÖZLEŞME · {result.maddeler.length} MADDE</div>
              <h1 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 24, fontWeight: 600, margin: '0 0 6px', color: 'var(--text)', letterSpacing: '-0.015em' }}>{SOZLESME_TURU_LABELS[result.sozlesme_turu]}</h1>
              <p style={{ margin: 0, fontFamily: 'Inter, sans-serif', fontSize: 12, color: 'var(--text-muted)' }}>Belge ID: {result.belge_id?.slice(0, 16)}…</p>
            </div>

            {/* Annotated clauses */}
            {result.maddeler.map((clause, i) => {
              const isActiveClause = i === activeIdx
              const annotColor = { RED: 'var(--risk-high)', YELLOW: 'var(--risk-mid)', GREEN: 'var(--risk-safe)' }[clause.risk_seviyesi]
              const annotBg = { RED: 'var(--risk-high-soft)', YELLOW: 'var(--risk-mid-soft)', GREEN: 'var(--risk-safe-soft)' }[clause.risk_seviyesi]

              return (
                <div key={i}>
                  <h2 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 17, fontWeight: 600, color: 'var(--text)', margin: '28px 0 10px', letterSpacing: '-0.01em' }}>
                    <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: 'var(--text-faint)', marginRight: 10, fontWeight: 500, letterSpacing: '0.06em' }}>M.{clause.madde_no || i + 1}</span>
                    Madde {clause.madde_no || i + 1}
                  </h2>
                  <p style={{ margin: '0 0 14px', cursor: 'pointer' }} onClick={() => setActiveIdx(i)}>
                    <span style={{ background: isActiveClause ? annotBg : 'transparent', borderBottom: `2px solid ${annotColor}`, padding: '0 3px 1px', transition: 'background 0.15s', borderRadius: isActiveClause ? 3 : 0, boxShadow: isActiveClause ? `0 0 0 2px ${annotColor}` : 'none' }}>
                      {clause.madde_metni}
                      <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 9.5, background: annotColor, color: '#fff', padding: '0 5px', borderRadius: 8, verticalAlign: 'super', marginLeft: 3, lineHeight: 1.5, fontWeight: 600 }}>
                        {String.fromCharCode(65 + i)}
                      </span>
                    </span>
                  </p>
                </div>
              )
            })}
          </div>
        </section>

        {/* RIGHT: Analysis pane */}
        <section style={{ overflowY: 'auto', background: 'var(--bg)' }}>
          {/* Sticky header */}
          <div style={{ padding: '28px 32px 20px', borderBottom: '1px solid var(--border)', background: 'var(--bg-card)', position: 'sticky', top: 0, zIndex: 5, backdropFilter: 'blur(12px)' }}>
            <div style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: 'var(--accent)', letterSpacing: '0.12em', textTransform: 'uppercase' as const, marginBottom: 8, display: 'flex', alignItems: 'center', gap: 8 }}>
              <span style={{ width: 6, height: 6, borderRadius: '50%', background: 'var(--accent)', boxShadow: '0 0 0 4px var(--accent-soft)', animation: 'pulse 2s ease-in-out infinite', flexShrink: 0 }} />
              YAPAY ZEKÂ ANALİZİ · MADDE {activeClause?.madde_no || activeIdx + 1}
            </div>
            <h2 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 22, fontWeight: 500, letterSpacing: '-0.02em', margin: '0 0 6px', color: 'var(--text)' }}>
              <em style={{ fontStyle: 'italic', color: borderLeft(activeClause?.risk_seviyesi ?? 'GREEN'), fontWeight: 400 }}>
                {activeClause?.aciklama?.split(' ').slice(0, 6).join(' ')}…
              </em>
            </h2>
            <div style={{ fontSize: 12.5, color: 'var(--text-muted)' }}>
              {result.maddeler.length} madde · {result.maddeler.filter(m => m.risk_seviyesi === 'RED').length} yüksek riskli
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', gap: 18, marginTop: 16 }}>
              <div style={{ display: 'flex', gap: 6 }}>
                <button onClick={() => setActiveIdx(Math.max(0, activeIdx - 1))} style={{ background: 'var(--bg-inset)', border: '1px solid var(--border)', color: 'var(--text-muted)', width: 28, height: 28, borderRadius: 6, cursor: 'pointer', display: 'inline-flex', alignItems: 'center', justifyContent: 'center' }}>
                  <ChevronLeft size={13} />
                </button>
                <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11.5, color: 'var(--text-muted)', padding: '0 6px', display: 'inline-flex', alignItems: 'center' }}>
                  <b style={{ color: 'var(--text)', fontWeight: 500 }}>{activeIdx + 1}</b>&nbsp;/&nbsp;{result.maddeler.length}
                </span>
                <button onClick={() => setActiveIdx(Math.min(result.maddeler.length - 1, activeIdx + 1))} style={{ background: 'var(--bg-inset)', border: '1px solid var(--border)', color: 'var(--text-muted)', width: 28, height: 28, borderRadius: 6, cursor: 'pointer', display: 'inline-flex', alignItems: 'center', justifyContent: 'center' }}>
                  <ChevronRight size={13} />
                </button>
              </div>
              <a style={{ fontSize: 12, color: 'var(--accent)', cursor: 'pointer' }}>Tüm maddeleri gör →</a>
            </div>
          </div>

          {/* Annotation cards */}
          {result.maddeler.map((clause, i) => (
            <AnnotCard
              key={i}
              clause={clause}
              index={i}
              isActive={i === activeIdx}
              onSelect={() => setActiveIdx(i)}
            />
          ))}

          {/* Footer */}
          <div style={{ padding: '20px 32px 32px' }}>
            <div style={{ fontSize: 11.5, color: 'var(--text-muted)', lineHeight: 1.55, padding: '12px 14px', background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-sm)', display: 'flex', gap: 10 }}>
              <Scale size={14} style={{ color: 'var(--risk-mid)', flexShrink: 0 }} />
              <span>
                <b style={{ color: 'var(--text-soft)', fontWeight: 500 }}>Bir avukata danışmanızı öneririz.</b>{' '}
                MaddeNet hukuki danışmanlık platformu değildir; sunulan analizler bilgilendirme amaçlıdır.
              </span>
            </div>
          </div>
        </section>
      </div>

      <style>{`@keyframes pulse { 0%, 100% { box-shadow: 0 0 0 4px var(--accent-soft); } 50% { box-shadow: 0 0 0 7px transparent; } }`}</style>
    </div>
  )
}
