'use client'

import { useState, Suspense } from 'react'
import { useRouter, useSearchParams } from 'next/navigation'
import { Logo } from '@/components/brand/Logo'
import { ThemeToggle } from '@/components/layout/ThemeToggle'
import { createClient } from '@/lib/supabase'
import { Scale, Eye, EyeOff } from 'lucide-react'
import { toast } from 'sonner'

function AuthForm() {
  const router = useRouter()
  const searchParams = useSearchParams()
  const [mode, setMode] = useState<'login' | 'signup'>(
    searchParams.get('mode') === 'signup' ? 'signup' : 'login'
  )
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [showPass, setShowPass] = useState(false)
  const [loading, setLoading] = useState(false)

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    const supabase = createClient()

    try {
      if (mode === 'signup') {
        if (password.length < 6) throw new Error('Şifre en az 6 karakter olmalıdır')
        const { data, error } = await supabase.auth.signUp({
          email,
          password,
          options: { emailRedirectTo: `${window.location.origin}/auth/callback` },
        })
        if (error) throw error
        if (data.session) {
          // Tam sayfa yönlendirme — session cookie'nin yazılmasını garantile
          window.location.href = '/dashboard'
        } else {
          toast.success('Onay e-postası gönderildi. E-postanızı kontrol edin.')
          setMode('login')
        }
      } else {
        const { data: loginData, error } = await supabase.auth.signInWithPassword({ email, password })
        if (error) {
          if (error.message.includes('Email not confirmed')) {
            throw new Error('E-posta adresiniz henüz doğrulanmamış. Gelen kutunuzu kontrol edin.')
          }
          throw error
        }
        // Token'ı localStorage'a manuel yaz — sonraki sayfada kesin okunabilsin
        if (loginData.session) {
          localStorage.setItem('sb-access-token', loginData.session.access_token)
          localStorage.setItem('sb-refresh-token', loginData.session.refresh_token ?? '')
        }
        window.location.href = '/dashboard'
      }
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Bir hata oluştu')
    } finally {
      setLoading(false)
    }
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
  }

  return (
    <div style={{ minHeight: '100vh', background: 'var(--bg-deep)', display: 'flex', flexDirection: 'column' }}>
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1.05fr', minHeight: '100vh' }}>
        {/* Left aside */}
        <div
          style={{
            position: 'relative',
            overflow: 'hidden',
            padding: '40px 56px',
            background: `
              radial-gradient(ellipse 70% 50% at 0% 0%, var(--accent-glow) 0%, transparent 60%),
              radial-gradient(ellipse 60% 50% at 100% 100%, var(--accent-soft) 0%, transparent 60%),
              linear-gradient(180deg, var(--bg-deep) 0%, var(--bg) 100%)
            `,
            display: 'flex',
            flexDirection: 'column',
            justifyContent: 'space-between',
            borderRight: '1px solid var(--border)',
          }}
        >
          <div style={{ position: 'absolute', inset: 0, backgroundImage: `linear-gradient(var(--grid-line) 1px, transparent 1px), linear-gradient(90deg, var(--grid-line) 1px, transparent 1px)`, backgroundSize: '48px 48px', maskImage: 'radial-gradient(ellipse at 30% 30%, black 0%, transparent 70%)', WebkitMaskImage: 'radial-gradient(ellipse at 30% 30%, black 0%, transparent 70%)' }} />

          <div style={{ position: 'relative', zIndex: 2 }}>
            <Logo size="md" />
          </div>

          <div style={{ position: 'relative', zIndex: 2, maxWidth: 460 }}>
            <h2
              style={{
                fontFamily: 'Newsreader, Georgia, serif',
                fontSize: 32,
                lineHeight: 1.25,
                letterSpacing: '-0.025em',
                margin: '80px 0 32px',
                color: 'var(--text)',
                fontWeight: 500,
              }}
            >
              Sözleşmelerinizi{' '}
              <em style={{ fontStyle: 'italic', color: 'var(--accent-hover)', fontWeight: 400 }}>anlayın</em>,
              risklerinizi bilin.
            </h2>

            {/* Sample excerpt card */}
            <div
              style={{
                background: 'var(--bg-elevated)',
                border: '1px solid var(--border-strong)',
                borderRadius: 14,
                padding: '20px 22px',
                boxShadow: 'var(--shadow-lg)',
              }}
            >
              <div
                style={{
                  display: 'flex',
                  justifyContent: 'space-between',
                  paddingBottom: 14,
                  marginBottom: 14,
                  borderBottom: '1px solid var(--border)',
                }}
              >
                <span
                  style={{
                    fontFamily: 'Newsreader, Georgia, serif',
                    fontSize: 14,
                    fontWeight: 600,
                    color: 'var(--text)',
                  }}
                >
                  Kira Sözleşmesi — Madde 5
                </span>
                <span
                  style={{
                    fontFamily: 'JetBrains Mono, monospace',
                    fontSize: 10.5,
                    color: 'var(--risk-high)',
                  }}
                >
                  YÜKSEK RİSK
                </span>
              </div>
              <p style={{ fontSize: 13, lineHeight: 1.55, color: 'var(--text-soft)' }}>
                Kira artışı{' '}
                <mark
                  style={{
                    background: 'var(--risk-high-soft)',
                    color: 'var(--risk-high)',
                    padding: '1px 4px',
                    borderRadius: 3,
                    textDecoration: 'underline',
                    textDecorationColor: 'var(--risk-high-ring)',
                    textUnderlineOffset: 3,
                  }}
                >
                  TÜFE + %30
                </mark>{' '}
                oranında yapılacaktır. Bu oran TBK Madde 344&apos;ü ihlal etmektedir.
              </p>
            </div>
          </div>

          <div style={{ position: 'relative', zIndex: 2 }}>
            <p style={{ fontSize: 11.5, color: 'var(--text-faint)' }}>
              © 2026 MaddeNet · Bilgilendirme amaçlıdır
            </p>
          </div>
        </div>

        {/* Right form */}
        <div
          style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            padding: '40px 56px',
            background: 'var(--bg)',
          }}
        >
          <div style={{ position: 'absolute', top: 20, right: 24 }}>
            <ThemeToggle />
          </div>

          <div style={{ width: '100%', maxWidth: 400 }}>
            <h1
              style={{
                fontFamily: 'Newsreader, Georgia, serif',
                fontSize: 28,
                fontWeight: 500,
                letterSpacing: '-0.025em',
                color: 'var(--text)',
                marginBottom: 6,
              }}
            >
              {mode === 'login' ? 'Tekrar hoşgeldiniz' : 'Hesap oluştur'}
            </h1>
            <p style={{ fontSize: 13.5, color: 'var(--text-muted)', marginBottom: 32 }}>
              {mode === 'login'
                ? 'E-posta ve şifrenizle giriş yapın.'
                : 'Ücretsiz hesabınızı oluşturun.'}
            </p>

            <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
              <div>
                <label style={{ display: 'block', fontSize: 12.5, color: 'var(--text-muted)', marginBottom: 5 }}>
                  E-posta
                </label>
                <input
                  type="email"
                  required
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  placeholder="ornek@eposta.com"
                  style={inputStyle}
                />
              </div>

              <div>
                <label style={{ display: 'block', fontSize: 12.5, color: 'var(--text-muted)', marginBottom: 5 }}>
                  Şifre
                </label>
                <div style={{ position: 'relative' }}>
                  <input
                    type={showPass ? 'text' : 'password'}
                    required
                    value={password}
                    onChange={(e) => setPassword(e.target.value)}
                    placeholder="••••••••"
                    style={{ ...inputStyle, paddingRight: 44 }}
                  />
                  <button
                    type="button"
                    onClick={() => setShowPass(!showPass)}
                    style={{
                      position: 'absolute',
                      right: 12,
                      top: '50%',
                      transform: 'translateY(-50%)',
                      background: 'none',
                      border: 'none',
                      cursor: 'pointer',
                      color: 'var(--text-faint)',
                      padding: 0,
                    }}
                  >
                    {showPass ? <EyeOff size={14} /> : <Eye size={14} />}
                  </button>
                </div>
              </div>

              <button
                type="submit"
                disabled={loading}
                style={{
                  marginTop: 6,
                  padding: '11px',
                  background: 'var(--accent)',
                  color: '#fff',
                  border: 'none',
                  borderRadius: 'var(--r-sm)',
                  fontSize: 14,
                  fontWeight: 500,
                  cursor: loading ? 'not-allowed' : 'pointer',
                  opacity: loading ? 0.7 : 1,
                  boxShadow: 'var(--shadow-glow)',
                }}
              >
                {loading ? 'Yükleniyor…' : mode === 'login' ? 'Giriş Yap' : 'Hesap Oluştur'}
              </button>
            </form>

            <p style={{ marginTop: 20, textAlign: 'center', fontSize: 13, color: 'var(--text-muted)' }}>
              {mode === 'login' ? 'Hesabınız yok mu?' : 'Zaten hesabınız var mı?'}{' '}
              <button
                onClick={() => setMode(mode === 'login' ? 'signup' : 'login')}
                style={{
                  background: 'none',
                  border: 'none',
                  color: 'var(--accent)',
                  cursor: 'pointer',
                  fontSize: 13,
                }}
              >
                {mode === 'login' ? 'Kayıt Ol' : 'Giriş Yap'}
              </button>
            </p>

            <div
              style={{
                marginTop: 24,
                padding: '10px 14px',
                background: 'var(--bg-inset)',
                border: '1px solid var(--border)',
                borderRadius: 'var(--r-sm)',
                display: 'flex',
                gap: 8,
              }}
            >
              <Scale size={12} style={{ flexShrink: 0, marginTop: 1 }} color="var(--text-faint)" />
              <p style={{ fontSize: 11, color: 'var(--text-faint)', lineHeight: 1.5 }}>
                MaddeNet&apos;e katılarak platformun yalnızca bilgilendirme amaçlı olduğunu
                kabul etmiş olursunuz.
              </p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default function AuthPage() {
  return (
    <Suspense>
      <AuthForm />
    </Suspense>
  )
}
