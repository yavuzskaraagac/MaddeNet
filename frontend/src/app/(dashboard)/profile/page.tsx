'use client'

import { useEffect, useState } from 'react'
import { createClient } from '@/lib/supabase'
import { listAnalyses } from '@/lib/api'
import { User, Mail, Calendar, BarChart2, Shield, Pencil, Check, X } from 'lucide-react'
import { toast } from 'sonner'

function formatDate(iso: string) {
  return new Date(iso).toLocaleDateString('tr-TR', { day: 'numeric', month: 'long', year: 'numeric' })
}

function getInitials(name: string) {
  const parts = name.split(/[\s._-]/)
  if (parts.length >= 2) return (parts[0][0] + parts[1][0]).toUpperCase()
  return name.slice(0, 2).toUpperCase()
}

export default function ProfilePage() {
  const [email, setEmail] = useState('')
  const [createdAt, setCreatedAt] = useState('')
  const [analysisCount, setAnalysisCount] = useState(0)
  const [loading, setLoading] = useState(true)

  // Kullanıcı adı değiştirme
  const [displayName, setDisplayName] = useState('')
  const [editingName, setEditingName] = useState(false)
  const [newName, setNewName] = useState('')
  const [savingName, setSavingName] = useState(false)

  useEffect(() => {
    const supabase = createClient()
    Promise.all([
      supabase.auth.getSession(),
      listAnalyses(),
    ]).then(([{ data }, analyses]) => {
      const session = data.session
      if (session?.user) {
        setEmail(session.user.email ?? '')
        setCreatedAt(session.user.created_at ?? '')
        // user_metadata.full_name varsa kullan, yoksa email prefix
        const name = session.user.user_metadata?.full_name || session.user.email?.split('@')[0] || ''
        setDisplayName(name)
        setNewName(name)
      }
      setAnalysisCount(analyses.length)
    }).catch(() => {}).finally(() => setLoading(false))
  }, [])

  async function handleSaveName() {
    if (!newName.trim()) { toast.error('Kullanıcı adı boş olamaz'); return }
    if (newName.trim() === displayName) { setEditingName(false); return }
    setSavingName(true)
    try {
      const supabase = createClient()
      const { error } = await supabase.auth.updateUser({
        data: { full_name: newName.trim() },
      })
      if (error) throw error
      setDisplayName(newName.trim())
      setEditingName(false)
      toast.success('Kullanıcı adı güncellendi')
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Güncellenemedi')
    } finally {
      setSavingName(false)
    }
  }

  const initials = displayName ? getInitials(displayName) : 'MN'

  if (loading) {
    return (
      <div style={{ padding: '64px', textAlign: 'center', color: 'var(--text-muted)', fontSize: 13 }}>
        Yükleniyor…
      </div>
    )
  }

  return (
    <div style={{ padding: '32px 32px 80px', maxWidth: 720 }}>
      <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11.5, color: 'var(--accent)', letterSpacing: '0.12em', textTransform: 'uppercase', marginBottom: 8 }}>Hesap</p>
      <h1 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 32, fontWeight: 500, letterSpacing: '-0.025em', margin: '0 0 28px', color: 'var(--text)' }}>
        Profilim
      </h1>

      {/* Avatar + info */}
      <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)', padding: '28px', display: 'flex', alignItems: 'center', gap: 24, marginBottom: 20 }}>
        <div style={{ width: 72, height: 72, borderRadius: '50%', background: 'linear-gradient(135deg, var(--accent-hover) 0%, var(--accent-deep) 100%)', border: '2px solid var(--border-strong)', fontFamily: 'Newsreader, Georgia, serif', color: '#fff', fontWeight: 500, fontSize: 26, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0, boxShadow: 'var(--shadow-glow)' }}>
          {initials}
        </div>
        <div style={{ flex: 1 }}>
          {editingName ? (
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 6 }}>
              <input
                autoFocus
                value={newName}
                onChange={(e) => setNewName(e.target.value)}
                onKeyDown={(e) => { if (e.key === 'Enter') handleSaveName(); if (e.key === 'Escape') setEditingName(false) }}
                style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 20, fontWeight: 500, color: 'var(--text)', background: 'var(--bg-inset)', border: '1px solid var(--accent)', borderRadius: 'var(--r-sm)', padding: '6px 12px', outline: 'none', width: 260 }}
              />
              <button
                onClick={handleSaveName}
                disabled={savingName}
                style={{ width: 32, height: 32, borderRadius: 8, background: 'var(--risk-safe)', border: 'none', color: '#fff', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
              >
                <Check size={14} />
              </button>
              <button
                onClick={() => { setEditingName(false); setNewName(displayName) }}
                style={{ width: 32, height: 32, borderRadius: 8, background: 'var(--bg-inset)', border: '1px solid var(--border)', color: 'var(--text-muted)', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
              >
                <X size={14} />
              </button>
            </div>
          ) : (
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 6 }}>
              <h2 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 22, fontWeight: 500, letterSpacing: '-0.015em', margin: 0, color: 'var(--text)' }}>
                {displayName}
              </h2>
              <button
                onClick={() => setEditingName(true)}
                title="Kullanıcı adını düzenle"
                style={{ width: 28, height: 28, borderRadius: 7, background: 'var(--bg-inset)', border: '1px solid var(--border)', color: 'var(--text-faint)', cursor: 'pointer', display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}
              >
                <Pencil size={12} />
              </button>
            </div>
          )}
          <p style={{ margin: 0, fontSize: 13.5, color: 'var(--text-muted)' }}>{email}</p>
        </div>
      </div>

      {/* Stats */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 14, marginBottom: 20 }}>
        {[
          { icon: <BarChart2 size={16} />, label: 'Toplam Analiz', value: String(analysisCount) },
          { icon: <Calendar size={16} />, label: 'Üyelik Tarihi', value: createdAt ? formatDate(createdAt) : '—' },
          { icon: <Shield size={16} />, label: 'Hesap Durumu', value: 'Aktif' },
        ].map(({ icon, label, value }) => (
          <div key={label} style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)', padding: '18px 20px' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 10, color: 'var(--text-muted)', fontSize: 12.5 }}>
              <span style={{ color: 'var(--accent)' }}>{icon}</span>
              {label}
            </div>
            <div style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 20, fontWeight: 500, letterSpacing: '-0.01em', color: 'var(--text)' }}>{value}</div>
          </div>
        ))}
      </div>

      {/* Account info */}
      <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)', overflow: 'hidden' }}>
        <div style={{ padding: '16px 22px', borderBottom: '1px solid var(--border)' }}>
          <h3 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 16, fontWeight: 600, margin: 0, color: 'var(--text)' }}>Hesap Bilgileri</h3>
        </div>
        {[
          { icon: <Mail size={14} />, label: 'E-posta', value: email },
          { icon: <User size={14} />, label: 'Kullanıcı Adı', value: displayName },
          { icon: <Shield size={14} />, label: 'Kimlik Doğrulama', value: 'E-posta / Şifre' },
        ].map(({ icon, label, value }, i, arr) => (
          <div key={label} style={{ display: 'flex', alignItems: 'center', padding: '16px 22px', borderBottom: i < arr.length - 1 ? '1px solid var(--border-subtle)' : 'none' }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, color: 'var(--text-muted)', fontSize: 13, width: 200 }}>
              <span style={{ color: 'var(--accent)' }}>{icon}</span>
              {label}
            </div>
            <div style={{ fontSize: 13.5, color: 'var(--text)' }}>{value}</div>
          </div>
        ))}
      </div>

      <p style={{ marginTop: 20, fontSize: 12, color: 'var(--text-faint)', lineHeight: 1.55 }}>
        Şifre değiştirme ve hesap silme için <a href="/settings" style={{ color: 'var(--accent)', textDecoration: 'none' }}>Ayarlar</a> sayfasına gidin.
      </p>
    </div>
  )
}
