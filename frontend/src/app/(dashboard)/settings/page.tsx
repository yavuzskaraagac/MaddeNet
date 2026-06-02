'use client'

import { useEffect, useState } from 'react'
import { useRouter } from 'next/navigation'
import { createClient } from '@/lib/supabase'
import { LogOut, Lock, Trash2, Mail, AlertTriangle, CheckCircle } from 'lucide-react'
import { toast } from 'sonner'

export default function SettingsPage() {
  const router = useRouter()
  const [email, setEmail] = useState('')
  const [newPassword, setNewPassword] = useState('')
  const [confirmPassword, setConfirmPassword] = useState('')
  const [pwLoading, setPwLoading] = useState(false)
  const [deleteConfirm, setDeleteConfirm] = useState('')
  const [showDeleteBox, setShowDeleteBox] = useState(false)

  useEffect(() => {
    const supabase = createClient()
    supabase.auth.getSession().then((res: Awaited<ReturnType<typeof supabase.auth.getSession>>) => {
      const session = res.data.session
      if (session?.user?.email) setEmail(session.user.email)
    })
  }, [])

  async function handleLogout() {
    const supabase = createClient()
    await supabase.auth.signOut()
    router.push('/auth')
  }

  async function handlePasswordChange(e: React.FormEvent) {
    e.preventDefault()
    if (newPassword.length < 6) {
      toast.error('Şifre en az 6 karakter olmalıdır')
      return
    }
    if (newPassword !== confirmPassword) {
      toast.error('Şifreler eşleşmiyor')
      return
    }
    setPwLoading(true)
    try {
      const supabase = createClient()
      const { error } = await supabase.auth.updateUser({ password: newPassword })
      if (error) throw error
      toast.success('Şifreniz güncellendi')
      setNewPassword('')
      setConfirmPassword('')
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Şifre güncellenemedi')
    } finally {
      setPwLoading(false)
    }
  }

  async function handleDeleteAccount() {
    if (deleteConfirm !== email) {
      toast.error('E-posta adresi eşleşmiyor')
      return
    }
    toast.info('Hesap silme özelliği yakında aktif olacak. Destek için iletişime geçin.')
    setShowDeleteBox(false)
  }

  const inputStyle: React.CSSProperties = {
    width: '100%',
    padding: '10px 14px',
    background: 'var(--bg-inset)',
    border: '1px solid var(--border)',
    borderRadius: 'var(--r-sm)',
    color: 'var(--text)',
    fontSize: 14,
    outline: 'none',
    fontFamily: 'inherit',
  }

  return (
    <div style={{ padding: '32px 32px 80px', maxWidth: 680 }}>
      <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11.5, color: 'var(--accent)', letterSpacing: '0.12em', textTransform: 'uppercase', marginBottom: 8 }}>Hesap</p>
      <h1 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 32, fontWeight: 500, letterSpacing: '-0.025em', margin: '0 0 28px', color: 'var(--text)' }}>
        Ayarlar
      </h1>

      {/* Account info */}
      <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)', overflow: 'hidden', marginBottom: 20 }}>
        <div style={{ padding: '16px 22px', borderBottom: '1px solid var(--border)', display: 'flex', alignItems: 'center', gap: 8 }}>
          <Mail size={15} color="var(--accent)" />
          <h3 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 16, fontWeight: 600, margin: 0, color: 'var(--text)' }}>E-posta</h3>
        </div>
        <div style={{ padding: '16px 22px', display: 'flex', alignItems: 'center', gap: 12 }}>
          <span style={{ fontSize: 14, color: 'var(--text)' }}>{email}</span>
          <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, padding: '2px 8px', borderRadius: 'var(--r-full)', background: 'var(--risk-safe-soft)', border: '1px solid var(--risk-safe-ring)', fontSize: 11, color: 'var(--risk-safe)' }}>
            <CheckCircle size={10} /> Doğrulandı
          </span>
        </div>
      </div>

      {/* Password change */}
      <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)', overflow: 'hidden', marginBottom: 20 }}>
        <div style={{ padding: '16px 22px', borderBottom: '1px solid var(--border)', display: 'flex', alignItems: 'center', gap: 8 }}>
          <Lock size={15} color="var(--accent)" />
          <h3 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 16, fontWeight: 600, margin: 0, color: 'var(--text)' }}>Şifre Değiştir</h3>
        </div>
        <form onSubmit={handlePasswordChange} style={{ padding: '20px 22px', display: 'flex', flexDirection: 'column', gap: 14 }}>
          <div>
            <label style={{ display: 'block', fontSize: 12.5, color: 'var(--text-muted)', marginBottom: 6 }}>Yeni Şifre</label>
            <input
              type="password"
              value={newPassword}
              onChange={(e) => setNewPassword(e.target.value)}
              placeholder="En az 6 karakter"
              style={inputStyle}
            />
          </div>
          <div>
            <label style={{ display: 'block', fontSize: 12.5, color: 'var(--text-muted)', marginBottom: 6 }}>Şifreyi Onayla</label>
            <input
              type="password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              placeholder="Tekrar girin"
              style={inputStyle}
            />
          </div>
          <div>
            <button
              type="submit"
              disabled={pwLoading || !newPassword || !confirmPassword}
              style={{ padding: '10px 20px', background: newPassword && confirmPassword ? 'var(--accent)' : 'var(--bg-inset)', color: newPassword && confirmPassword ? '#fff' : 'var(--text-faint)', border: '1px solid var(--border)', borderRadius: 'var(--r-sm)', fontSize: 13.5, fontWeight: 500, cursor: newPassword && confirmPassword ? 'pointer' : 'not-allowed', fontFamily: 'inherit', boxShadow: newPassword && confirmPassword ? 'var(--shadow-glow)' : 'none' }}
            >
              {pwLoading ? 'Güncelleniyor…' : 'Şifreyi Güncelle'}
            </button>
          </div>
        </form>
      </div>

      {/* Logout */}
      <div style={{ background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)', overflow: 'hidden', marginBottom: 20 }}>
        <div style={{ padding: '16px 22px', borderBottom: '1px solid var(--border)', display: 'flex', alignItems: 'center', gap: 8 }}>
          <LogOut size={15} color="var(--accent)" />
          <h3 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 16, fontWeight: 600, margin: 0, color: 'var(--text)' }}>Oturum</h3>
        </div>
        <div style={{ padding: '20px 22px' }}>
          <p style={{ fontSize: 13.5, color: 'var(--text-muted)', marginBottom: 16, lineHeight: 1.55 }}>
            Hesabınızdan çıkış yaparsanız tekrar giriş yapmanız gerekecektir.
          </p>
          <button
            onClick={handleLogout}
            style={{ display: 'inline-flex', alignItems: 'center', gap: 8, padding: '10px 20px', background: 'var(--bg-inset)', border: '1px solid var(--border)', borderRadius: 'var(--r-sm)', fontSize: 13.5, fontWeight: 500, color: 'var(--text)', cursor: 'pointer', fontFamily: 'inherit' }}
          >
            <LogOut size={14} /> Çıkış Yap
          </button>
        </div>
      </div>

      {/* Danger zone */}
      <div style={{ background: 'var(--bg-card)', border: '1px solid var(--risk-high-ring)', borderRadius: 'var(--r-md)', overflow: 'hidden' }}>
        <div style={{ padding: '16px 22px', borderBottom: '1px solid var(--risk-high-ring)', display: 'flex', alignItems: 'center', gap: 8, background: 'var(--risk-high-soft)' }}>
          <AlertTriangle size={15} color="var(--risk-high)" />
          <h3 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 16, fontWeight: 600, margin: 0, color: 'var(--risk-high)' }}>Tehlikeli Bölge</h3>
        </div>
        <div style={{ padding: '20px 22px' }}>
          <p style={{ fontSize: 13.5, color: 'var(--text-muted)', marginBottom: 16, lineHeight: 1.55 }}>
            Hesabınızı silerseniz tüm analizleriniz ve belgeleriniz kalıcı olarak kaldırılır. <strong style={{ color: 'var(--text)' }}>Bu işlem geri alınamaz.</strong>
          </p>
          {!showDeleteBox ? (
            <button
              onClick={() => setShowDeleteBox(true)}
              style={{ display: 'inline-flex', alignItems: 'center', gap: 8, padding: '10px 20px', background: 'transparent', border: '1px solid var(--risk-high-ring)', borderRadius: 'var(--r-sm)', fontSize: 13.5, fontWeight: 500, color: 'var(--risk-high)', cursor: 'pointer', fontFamily: 'inherit' }}
            >
              <Trash2 size={14} /> Hesabımı Sil
            </button>
          ) : (
            <div style={{ display: 'flex', flexDirection: 'column', gap: 12 }}>
              <p style={{ fontSize: 13, color: 'var(--text-soft)', margin: 0 }}>
                Onaylamak için e-posta adresinizi yazın: <strong>{email}</strong>
              </p>
              <input
                type="email"
                value={deleteConfirm}
                onChange={(e) => setDeleteConfirm(e.target.value)}
                placeholder={email}
                style={{ ...inputStyle, border: '1px solid var(--risk-high-ring)' }}
              />
              <div style={{ display: 'flex', gap: 10 }}>
                <button
                  onClick={handleDeleteAccount}
                  style={{ padding: '9px 18px', background: 'var(--risk-high)', color: '#fff', border: 'none', borderRadius: 'var(--r-sm)', fontSize: 13, fontWeight: 500, cursor: 'pointer', fontFamily: 'inherit' }}
                >
                  Hesabı Kalıcı Sil
                </button>
                <button
                  onClick={() => { setShowDeleteBox(false); setDeleteConfirm('') }}
                  style={{ padding: '9px 18px', background: 'transparent', border: '1px solid var(--border)', borderRadius: 'var(--r-sm)', fontSize: 13, color: 'var(--text-soft)', cursor: 'pointer', fontFamily: 'inherit' }}
                >
                  İptal
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
