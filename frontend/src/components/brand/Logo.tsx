import Link from 'next/link'

interface LogoProps {
  href?: string
  size?: 'sm' | 'md' | 'lg'
}

export function Logo({ href = '/', size = 'md' }: LogoProps) {
  const sizes = {
    sm: { mark: 26, font: 16, gap: 8 },
    md: { mark: 30, font: 18, gap: 10 },
    lg: { mark: 36, font: 22, gap: 12 },
  }
  const s = sizes[size]

  const content = (
    <span
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: s.gap,
        textDecoration: 'none',
        userSelect: 'none',
      }}
    >
      {/* AI Terazi logosu */}
      <span
        style={{
          width: s.mark,
          height: s.mark,
          borderRadius: 8,
          background: 'var(--accent)',
          display: 'inline-flex',
          alignItems: 'center',
          justifyContent: 'center',
          flexShrink: 0,
          boxShadow: 'var(--shadow-glow)',
        }}
      >
        <svg
          width={s.mark * 0.62}
          height={s.mark * 0.62}
          viewBox="0 0 20 20"
          fill="none"
        >
          {/* Terazi kolu */}
          <line x1="10" y1="3" x2="10" y2="16" stroke="white" strokeWidth="1.5" strokeLinecap="round" />
          {/* Yatay kol */}
          <line x1="3" y1="6" x2="17" y2="6" stroke="white" strokeWidth="1.5" strokeLinecap="round" />
          {/* Sol kefe bağlantısı */}
          <line x1="4" y1="6" x2="4" y2="10" stroke="white" strokeWidth="1.2" strokeLinecap="round" />
          {/* Sağ kefe bağlantısı */}
          <line x1="16" y1="6" x2="16" y2="9" stroke="white" strokeWidth="1.2" strokeLinecap="round" />
          {/* Sol kefe */}
          <path d="M2 10 Q4 12 6 10" stroke="white" strokeWidth="1.2" fill="none" strokeLinecap="round" />
          {/* Sağ kefe (hafif eğik - denge) */}
          <path d="M14 9 Q16 11 18 9" stroke="white" strokeWidth="1.2" fill="none" strokeLinecap="round" />
          {/* Taban */}
          <line x1="8" y1="16" x2="12" y2="16" stroke="white" strokeWidth="1.5" strokeLinecap="round" />
          {/* AI kıvılcımı */}
          <circle cx="10" cy="3" r="1.2" fill="white" opacity="0.9" />
        </svg>
      </span>

      {/* Wordmark */}
      <span
        style={{
          fontFamily: 'Newsreader, Georgia, serif',
          fontSize: s.font,
          fontWeight: 500,
          letterSpacing: '-0.03em',
          color: 'var(--text)',
        }}
      >
        MaddeNet
      </span>
    </span>
  )

  return href ? <Link href={href}>{content}</Link> : content
}
