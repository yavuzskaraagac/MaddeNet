'use client'

import { useState } from 'react'
import { ChevronDown, ChevronUp, Scale, Sparkles } from 'lucide-react'
import type { ClauseAnalysis } from '@/lib/types'
import { RiskBadge } from './RiskBadge'

interface ClauseCardProps {
  clause: ClauseAnalysis
  index: number
}

const borderColors = {
  red: 'var(--risk-high)',
  yellow: 'var(--risk-mid)',
  green: 'var(--risk-safe)',
}

export function ClauseCard({ clause, index }: ClauseCardProps) {
  const [open, setOpen] = useState(false)
  const borderColor = borderColors[clause.risk_seviyesi]

  return (
    <div
      style={{
        background: 'var(--bg-card)',
        border: '1px solid var(--border)',
        borderLeft: `4px solid ${borderColor}`,
        borderRadius: 'var(--r-md)',
        overflow: 'hidden',
        transition: 'background 0.15s',
      }}
    >
      {/* Header */}
      <div style={{ padding: '16px 20px' }}>
        <div style={{ display: 'flex', alignItems: 'flex-start', gap: 12, justifyContent: 'space-between' }}>
          <div style={{ flex: 1, minWidth: 0 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}>
              <span
                style={{
                  fontFamily: 'JetBrains Mono, monospace',
                  fontSize: 10.5,
                  color: 'var(--text-faint)',
                  letterSpacing: '0.08em',
                }}
              >
                MADDE {clause.madde_no || index + 1}
              </span>
              <RiskBadge level={clause.risk_seviyesi} size="sm" />
              {clause.rag_bulunan && (
                <span
                  title="Gerçek kanun veritabanından doğrulandı"
                  style={{
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: 3,
                    padding: '1px 6px',
                    borderRadius: 'var(--r-full)',
                    background: 'var(--accent-soft)',
                    border: '1px solid var(--accent-ring)',
                    fontSize: 10,
                    color: 'var(--accent)',
                  }}
                >
                  <Sparkles size={9} />
                  RAG
                </span>
              )}
            </div>
            <p
              style={{
                fontSize: 13,
                color: 'var(--text-soft)',
                lineHeight: 1.5,
                display: '-webkit-box',
                WebkitLineClamp: open ? 'none' : 2,
                WebkitBoxOrient: 'vertical',
                overflow: 'hidden',
              }}
            >
              {clause.sade_aciklama}
            </p>
          </div>

          <button
            onClick={() => setOpen(!open)}
            style={{
              flexShrink: 0,
              padding: '6px',
              borderRadius: 'var(--r-sm)',
              background: 'var(--bg-inset)',
              border: '1px solid var(--border)',
              color: 'var(--text-muted)',
              cursor: 'pointer',
              display: 'flex',
              alignItems: 'center',
            }}
          >
            {open ? <ChevronUp size={14} /> : <ChevronDown size={14} />}
          </button>
        </div>

        {/* Kanun referansı */}
        {clause.kanun_dayanagi && (
          <div
            style={{
              display: 'inline-flex',
              alignItems: 'center',
              gap: 5,
              marginTop: 8,
              padding: '3px 8px',
              borderRadius: 'var(--r-sm)',
              background: 'var(--bg-inset)',
              border: '1px solid var(--border)',
            }}
          >
            <Scale size={11} color="var(--text-faint)" />
            <span
              style={{
                fontFamily: 'JetBrains Mono, monospace',
                fontSize: 10.5,
                color: 'var(--text-muted)',
              }}
            >
              {clause.kanun_dayanagi}
            </span>
          </div>
        )}
      </div>

      {/* Expanded content */}
      {open && (
        <div
          style={{
            borderTop: '1px solid var(--border)',
            padding: '14px 20px',
            background: 'var(--bg-inset)',
          }}
        >
          {/* Madde metni */}
          <div style={{ marginBottom: 14 }}>
            <p
              style={{
                fontFamily: 'JetBrains Mono, monospace',
                fontSize: 10,
                color: 'var(--text-faint)',
                letterSpacing: '0.1em',
                textTransform: 'uppercase',
                marginBottom: 6,
              }}
            >
              Sözleşme Metni
            </p>
            <p style={{ fontSize: 12.5, color: 'var(--text-soft)', lineHeight: 1.6, fontStyle: 'italic' }}>
              {clause.madde_metni}
            </p>
          </div>

          {/* Öneri */}
          {clause.oneri && (
            <div
              style={{
                padding: '12px 14px',
                borderRadius: 'var(--r-sm)',
                background: 'var(--bg-card)',
                border: `1px solid ${borderColor}33`,
              }}
            >
              <p
                style={{
                  fontFamily: 'JetBrains Mono, monospace',
                  fontSize: 10,
                  color: 'var(--text-faint)',
                  letterSpacing: '0.1em',
                  textTransform: 'uppercase',
                  marginBottom: 6,
                }}
              >
                Öneri
              </p>
              <p style={{ fontSize: 13, color: 'var(--text)', lineHeight: 1.55 }}>
                {clause.oneri}
              </p>
            </div>
          )}

          <p
            style={{
              marginTop: 12,
              fontSize: 11,
              color: 'var(--text-faint)',
              fontStyle: 'italic',
            }}
          >
            * Bu açıklama bilgilendirme amaçlıdır. Hukuki bağlayıcılığı yoktur.
          </p>
        </div>
      )}
    </div>
  )
}
