'use client'

import Link from 'next/link'
import { usePathname } from 'next/navigation'
import { Logo } from '@/components/brand/Logo'

const NAV = [
  {
    section: 'Çalışma alanı',
    items: [
      { href: '/dashboard', label: 'Dashboard', icon: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><rect x="3" y="3" width="7" height="7" rx="1.5"/><rect x="14" y="3" width="7" height="7" rx="1.5"/><rect x="3" y="14" width="7" height="7" rx="1.5"/><rect x="14" y="14" width="7" height="7" rx="1.5"/></svg> },
      { href: '/upload', label: 'Yeni Analiz', icon: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2"><path d="M12 5v14M5 12h14"/></svg>, accent: true },
      { href: '/dashboard', label: 'Belgelerim', icon: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/></svg>, count: '24' },
      { href: '/dashboard', label: 'Analizler', icon: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M3 3v18h18"/><path d="m19 9-5 5-4-4-3 3"/></svg> },
      { href: '/dashboard', label: 'Karşılaştırmalar', icon: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M21 12c0 4.97-4.03 9-9 9s-9-4.03-9-9 4.03-9 9-9c2.39 0 4.68.95 6.36 2.64"/><path d="M21 3v6h-6"/></svg>, count: '3' },
    ],
  },
  {
    section: 'Kütüphane',
    items: [
      { href: '/dashboard', label: 'Kanun Veritabanı', icon: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M3 19V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2v14"/><path d="M3 19h18"/><path d="M8 7h8M8 11h8M8 15h5"/></svg> },
      { href: '/dashboard', label: 'Şablonlar', icon: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M21 16V8a2 2 0 0 0-1-1.73l-7-4a2 2 0 0 0-2 0l-7 4A2 2 0 0 0 3 8v8a2 2 0 0 0 1 1.73l7 4a2 2 0 0 0 2 0l7-4A2 2 0 0 0 21 16z"/></svg> },
    ],
  },
  {
    section: 'Hesap',
    items: [
      { href: '/dashboard', label: 'Profil', icon: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg> },
      { href: '/dashboard', label: 'Ayarlar', icon: <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 1 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 1 1-2.83-2.83l.06-.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 1 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 1 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/></svg> },
    ],
  },
]

export function Sidebar() {
  const pathname = usePathname()

  return (
    <aside style={{ width: 244, background: 'linear-gradient(180deg, var(--bg-elevated) 0%, var(--bg-deep) 100%)', borderRight: '1px solid var(--border)', padding: '22px 14px', display: 'flex', flexDirection: 'column', gap: 6, height: '100vh', position: 'sticky', top: 0, overflow: 'hidden', flexShrink: 0 }}>
      {/* Brand */}
      <div style={{ padding: '4px 10px 20px', borderBottom: '1px solid var(--border)', marginBottom: 8 }}>
        <Logo href="/dashboard" size="sm" />
      </div>

      {NAV.map(({ section, items }) => (
        <div key={section}>
          <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10.5, color: 'var(--text-faint)', letterSpacing: '0.12em', textTransform: 'uppercase' as const, padding: '14px 10px 8px', margin: 0 }}>{section}</p>
          {items.map(({ href, label, icon, count, accent }) => {
            const isActive = pathname === href && href !== '/dashboard' || (href === '/dashboard' && pathname === '/dashboard')
            return (
              <Link
                key={label}
                href={href}
                style={{ display: 'flex', alignItems: 'center', gap: 11, padding: '8px 10px', borderRadius: 'var(--r-sm)', color: isActive ? 'var(--accent-hover)' : accent ? 'var(--accent)' : 'var(--text-soft)', background: isActive ? 'var(--accent-soft)' : 'transparent', boxShadow: isActive ? 'inset 0 0 0 1px var(--accent-ring)' : 'none', fontSize: 13.5, fontWeight: 450, textDecoration: 'none', position: 'relative', transition: 'all 0.15s', marginBottom: 2 }}
              >
                {isActive && <span style={{ position: 'absolute', left: -14, top: 8, bottom: 8, width: 2.5, borderRadius: 2, background: 'var(--accent)' }} />}
                <span style={{ width: 16, height: 16, flexShrink: 0, opacity: 0.85, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>{icon}</span>
                {label}
                {count && (
                  <span style={{ marginLeft: 'auto', fontFamily: 'JetBrains Mono, monospace', fontSize: 10.5, color: 'var(--text-faint)', background: 'var(--bg-card)', padding: '1px 6px', borderRadius: 4, border: '1px solid var(--border)' }}>{count}</span>
                )}
              </Link>
            )
          })}
        </div>
      ))}

      {/* Footer quota card */}
      <div style={{ marginTop: 'auto', paddingTop: 14, borderTop: '1px solid var(--border)' }}>
        <div style={{ padding: 14, background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12, marginBottom: 8 }}>
            <b style={{ fontWeight: 500, color: 'var(--text-soft)' }}>Kullanım</b>
            <span style={{ color: 'var(--text-muted)' }}>21 / 50 analiz</span>
          </div>
          <div style={{ height: 4, background: 'var(--bg-inset)', borderRadius: 4, overflow: 'hidden', marginBottom: 10 }}>
            <div style={{ height: '100%', width: '42%', background: 'linear-gradient(90deg, var(--accent-hover), var(--accent-deep))', borderRadius: 4 }} />
          </div>
          <p style={{ fontSize: 11.5, color: 'var(--text-muted)', margin: '0 0 10px', lineHeight: 1.4 }}>
            Analizler bilgilendirme amaçlıdır. Hukuki tavsiye değildir.
          </p>
          <Link href="/" style={{ display: 'block', textAlign: 'center', fontSize: 12.5, color: 'var(--accent)', padding: 7, border: '1px solid var(--accent-ring)', borderRadius: 6, background: 'var(--accent-soft)' }}>
            Ana Sayfa
          </Link>
        </div>
      </div>
    </aside>
  )
}
