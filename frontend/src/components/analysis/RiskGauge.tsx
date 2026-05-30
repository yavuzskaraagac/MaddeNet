'use client'

interface RiskGaugeProps {
  score: number
  size?: number
}

export function RiskGauge({ score, size = 120 }: RiskGaugeProps) {
  const clamped = Math.max(0, Math.min(100, score))
  const radius = (size - 16) / 2
  const circumference = 2 * Math.PI * radius
  const progress = (clamped / 100) * circumference
  const offset = circumference - progress

  const color =
    clamped >= 70
      ? 'var(--risk-high)'
      : clamped >= 40
      ? 'var(--risk-mid)'
      : 'var(--risk-safe)'

  const label =
    clamped >= 70 ? 'Yüksek Risk' : clamped >= 40 ? 'Orta Risk' : 'Düşük Risk'

  return (
    <div style={{ display: 'inline-flex', flexDirection: 'column', alignItems: 'center', gap: 6 }}>
      <svg width={size} height={size} style={{ transform: 'rotate(-90deg)' }}>
        {/* Track */}
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          stroke="var(--bg-inset)"
          strokeWidth={8}
        />
        {/* Progress */}
        <circle
          cx={size / 2}
          cy={size / 2}
          r={radius}
          fill="none"
          stroke={color}
          strokeWidth={8}
          strokeLinecap="round"
          strokeDasharray={circumference}
          strokeDashoffset={offset}
          style={{ transition: 'stroke-dashoffset 0.6s ease, stroke 0.3s ease' }}
        />
        {/* Score text (counter-rotate) */}
        <text
          x={size / 2}
          y={size / 2}
          textAnchor="middle"
          dominantBaseline="central"
          style={{
            transform: `rotate(90deg) translate(0, 0)`,
            transformOrigin: `${size / 2}px ${size / 2}px`,
            fontFamily: 'Newsreader, Georgia, serif',
            fontSize: size * 0.25,
            fontWeight: 500,
            fill: color,
          }}
        >
          {clamped}
        </text>
      </svg>
      <span
        style={{
          fontFamily: 'JetBrains Mono, monospace',
          fontSize: 11,
          color: 'var(--text-muted)',
          letterSpacing: '0.05em',
          textTransform: 'uppercase',
        }}
      >
        {label}
      </span>
    </div>
  )
}
