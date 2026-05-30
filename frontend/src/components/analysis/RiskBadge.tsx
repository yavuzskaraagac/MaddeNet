import type { RiskLevel } from '@/lib/types'
import { RISK_LABELS } from '@/lib/types'

interface RiskBadgeProps {
  level: RiskLevel
  size?: 'sm' | 'md'
}

const styles: Record<RiskLevel, { bg: string; color: string; border: string }> = {
  RED: {
    bg: 'var(--risk-high-soft)',
    color: 'var(--risk-high)',
    border: 'var(--risk-high-ring)',
  },
  YELLOW: {
    bg: 'var(--risk-mid-soft)',
    color: 'var(--risk-mid)',
    border: 'var(--risk-mid-ring)',
  },
  GREEN: {
    bg: 'var(--risk-safe-soft)',
    color: 'var(--risk-safe)',
    border: 'var(--risk-safe-ring)',
  },
}

export function RiskBadge({ level, size = 'md' }: RiskBadgeProps) {
  const s = styles[level]
  return (
    <span
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: 5,
        padding: size === 'sm' ? '2px 7px' : '3px 10px',
        borderRadius: 'var(--r-full)',
        background: s.bg,
        color: s.color,
        border: `1px solid ${s.border}`,
        fontFamily: 'JetBrains Mono, monospace',
        fontSize: size === 'sm' ? 10 : 11,
        fontWeight: 600,
        letterSpacing: '0.05em',
        whiteSpace: 'nowrap',
      }}
    >
      <span
        style={{
          width: size === 'sm' ? 5 : 6,
          height: size === 'sm' ? 5 : 6,
          borderRadius: '50%',
          background: s.color,
          flexShrink: 0,
        }}
      />
      {RISK_LABELS[level]}
    </span>
  )
}
