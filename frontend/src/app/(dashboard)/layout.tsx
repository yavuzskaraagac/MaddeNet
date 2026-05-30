import { Sidebar } from '@/components/layout/Sidebar'
import { ThemeToggle } from '@/components/layout/ThemeToggle'

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  return (
    <div style={{ display: 'flex', minHeight: '100vh' }}>
      <Sidebar />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0 }}>
        {/* Topbar — 64px, sticky, search + avatar */}
        <header style={{ height: 64, borderBottom: '1px solid var(--border)', display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 32px', background: 'rgba(11, 11, 14, 0.7)', backdropFilter: 'blur(10px)', position: 'sticky', top: 0, zIndex: 10 }}>
          <div style={{ fontSize: 13, color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: 8 }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
            Çalışma alanım
            <span style={{ color: 'var(--text-faint)' }}>/</span>
            <b style={{ color: 'var(--text)', fontWeight: 500 }}>Dashboard</b>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            {/* Search */}
            <div style={{ width: 280, background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-sm)', padding: '7px 12px 7px 32px', position: 'relative', display: 'flex', alignItems: 'center' }}>
              <svg style={{ position: 'absolute', left: 10 }} width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
              <input placeholder="Sözleşme ara..." style={{ background: 'transparent', border: 0, outline: 0, color: 'var(--text)', fontFamily: 'inherit', fontSize: 13, width: '100%' }} />
              <kbd style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10, background: 'var(--bg-inset)', border: '1px solid var(--border)', padding: '1px 5px', borderRadius: 4, color: 'var(--text-faint)', marginLeft: 'auto', whiteSpace: 'nowrap' }}>⌘K</kbd>
            </div>
            <ThemeToggle />
            {/* Avatar */}
            <div style={{ width: 34, height: 34, borderRadius: '50%', background: 'linear-gradient(135deg, var(--accent-deep), var(--accent-deep))', border: '1px solid var(--border-strong)', fontFamily: 'Newsreader, Georgia, serif', color: '#fff', fontWeight: 500, fontSize: 13, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
              MN
            </div>
          </div>
        </header>
        <main style={{ flex: 1, overflow: 'auto' }}>
          {children}
        </main>
      </div>
    </div>
  )
}
