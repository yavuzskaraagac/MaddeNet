'use client'

import { useEffect, useState } from 'react'
import { usePathname } from 'next/navigation'
import { Sidebar } from '@/components/layout/Sidebar'
import { ThemeToggle } from '@/components/layout/ThemeToggle'
import { createClient } from '@/lib/supabase'
import { LogOut } from 'lucide-react'

const PAGE_LABELS: Record<string, string> = {
  '/dashboard':  'Dashboard',
  '/upload':     'Yeni Analiz',
  '/documents':  'Belgelerim',
  '/profile':    'Profil',
  '/settings':   'Ayarlar',
}

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname()
  const [initials, setInitials] = useState('MN')
  const [userEmail, setUserEmail] = useState('')
  const [ready, setReady] = useState(false)
  const pageLabel = PAGE_LABELS[pathname] ?? 'Dashboard'

  useEffect(() => {
    const supabase = createClient()
    supabase.auth.getSession().then((res: { data: { session: { user?: { email?: string } } | null } }) => {
      const session = res.data.session
      const fallbackToken = typeof window !== 'undefined'
        ? localStorage.getItem('sb-access-token')
        : null

      if (!session && !fallbackToken) {
        // Oturum yok — login sayfasına yönlendir
        window.location.href = '/auth'
        return
      }
      const email = session?.user?.email ?? ''
      setUserEmail(email)
      if (email) {
        const parts = email.split('@')[0].split(/[._-]/)
        const ini = parts.length >= 2
          ? (parts[0][0] + parts[1][0]).toUpperCase()
          : parts[0].slice(0, 2).toUpperCase()
        setInitials(ini)
      }
      setReady(true)
    })
  }, [])

  async function handleLogout() {
    const supabase = createClient()
    await supabase.auth.signOut()
    window.location.href = '/auth'
  }

  // Session kontrol edilene kadar boş ekran göster (flash önle)
  if (!ready) {
    return (
      <div style={{ minHeight: '100vh', background: 'var(--bg-deep)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
        <div style={{ width: 32, height: 32, borderRadius: '50%', border: '2px solid var(--accent)', borderTopColor: 'transparent', animation: 'spin 0.8s linear infinite' }} />
        <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
      </div>
    )
  }

  return (
    <div style={{ display: 'flex', minHeight: '100vh' }}>
      <Sidebar />
      <div style={{ flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0 }}>
        <header style={{ height: 64, borderBottom: '1px solid var(--border)', display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '0 32px', background: 'rgba(11, 11, 14, 0.7)', backdropFilter: 'blur(10px)', position: 'sticky', top: 0, zIndex: 10 }}>
          <div style={{ fontSize: 13, color: 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: 8 }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.7"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/></svg>
            Çalışma alanım
            <span style={{ color: 'var(--text-faint)' }}>/</span>
            <b style={{ color: 'var(--text)', fontWeight: 500 }}>{pageLabel}</b>
          </div>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <ThemeToggle />
            <button
              onClick={handleLogout}
              title="Çıkış yap"
              style={{ width: 34, height: 34, borderRadius: 8, background: 'var(--bg-card)', border: '1px solid var(--border)', color: 'var(--text-muted)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}
            >
              <LogOut size={14} />
            </button>
            <div
              title={userEmail}
              style={{ width: 34, height: 34, borderRadius: '50%', background: 'linear-gradient(135deg, var(--accent-deep), var(--accent-deep))', border: '1px solid var(--border-strong)', fontFamily: 'Newsreader, Georgia, serif', color: '#fff', fontWeight: 500, fontSize: 13, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', cursor: 'default' }}
            >
              {initials}
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
