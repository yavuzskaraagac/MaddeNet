import Link from 'next/link'
import { Logo } from '@/components/brand/Logo'
import { ThemeToggle } from '@/components/layout/ThemeToggle'
import { ArrowRight } from 'lucide-react'

export default function LandingPage() {
  return (
    <div style={{ minHeight: '100vh', background: 'var(--bg-deep)' }}>
      {/* Nav */}
      <nav style={{ position: 'relative', zIndex: 10, maxWidth: 1240, margin: '0 auto', padding: '20px 32px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', borderBottom: '1px solid var(--border-subtle)' }}>
        <Logo size="md" />
        <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
          <ThemeToggle />
          <Link href="/auth" style={{ padding: '7px 16px', borderRadius: 'var(--r-sm)', fontSize: 13, color: 'var(--text-soft)', border: '1px solid var(--border)', background: 'var(--bg-card)' }}>
            Giriş yap
          </Link>
          <Link href="/auth?mode=signup" style={{ padding: '7px 16px', borderRadius: 'var(--r-sm)', fontSize: 14, color: '#fff', background: 'var(--accent)', fontWeight: 500, boxShadow: '0 8px 24px var(--accent-glow), 0 0 0 1px var(--accent-ring)' }}>
            Ücretsiz başla
          </Link>
        </div>
      </nav>

      {/* Hero */}
      <section style={{ position: 'relative', overflow: 'hidden', padding: '80px 32px 0', textAlign: 'center' }}>
        {/* Animated background */}
        <div style={{ position: 'absolute', inset: 0, background: 'radial-gradient(ellipse 80% 60% at 50% 0%, var(--accent-glow) 0%, transparent 60%), radial-gradient(ellipse 60% 50% at 80% 30%, var(--accent-soft) 0%, transparent 60%), radial-gradient(ellipse 50% 40% at 20% 40%, var(--accent-soft) 0%, transparent 60%), linear-gradient(180deg, var(--bg-deep) 0%, var(--bg) 80%)', zIndex: 0 }} />
        {/* Grid overlay */}
        <div style={{ position: 'absolute', inset: 0, backgroundImage: 'linear-gradient(var(--grid-line) 1px, transparent 1px), linear-gradient(90deg, var(--grid-line) 1px, transparent 1px)', backgroundSize: '56px 56px', maskImage: 'radial-gradient(ellipse at center, black 20%, transparent 70%)', WebkitMaskImage: 'radial-gradient(ellipse at center, black 20%, transparent 70%)', zIndex: 0 }} />
        {/* Aurora */}
        <div style={{ position: 'absolute', inset: '-40% -20% auto -20%', height: 700, background: 'conic-gradient(from 180deg at 50% 50%, transparent 0deg, var(--accent-glow) 60deg, var(--accent-soft) 140deg, var(--accent-soft) 220deg, transparent 360deg)', filter: 'blur(70px)', opacity: 0.7, animation: 'spin 22s linear infinite', zIndex: 0 }} />

        <div style={{ position: 'relative', zIndex: 2, maxWidth: 920, margin: '0 auto' }}>
          {/* Eyebrow */}
          <div style={{ display: 'inline-flex', alignItems: 'center', gap: 8, padding: '5px 12px 5px 6px', borderRadius: 'var(--r-full)', background: 'var(--bg-card)', border: '1px solid var(--border)', fontSize: 12.5, color: 'var(--text-soft)', marginBottom: 28, backdropFilter: 'blur(8px)' }}>
            <span style={{ background: 'var(--accent-soft)', color: 'var(--accent-hover)', border: '1px solid var(--accent-ring)', padding: '1px 8px', borderRadius: 'var(--r-full)', fontSize: 11, fontWeight: 500, letterSpacing: '0.02em' }}>YENİ</span>
            RAG destekli kanun veritabanı — 2.392 madde
          </div>

          <h1 style={{ fontFamily: 'Newsreader, Georgia, serif', fontWeight: 500, fontSize: 'clamp(44px, 6vw, 76px)', lineHeight: 1.05, letterSpacing: '-0.035em', margin: '0 0 24px', color: 'var(--text)' }}>
            Sözleşmenizin<br />
            gizli risklerini{' '}
            <em style={{ fontStyle: 'italic', fontWeight: 400, background: 'linear-gradient(135deg, var(--accent-hover) 0%, var(--accent-hover) 50%, var(--accent) 100%)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent' }}>keşfedin.</em>
          </h1>

          <p style={{ fontSize: 19, lineHeight: 1.55, color: 'var(--text-soft)', maxWidth: 620, margin: '0 auto 38px' }}>
            Kira, iş ve ticari sözleşmelerinizi yapay zekâ ile saniyeler içinde tarayın. Riskli maddeleri renkli kodlu, anlaşılır bir dille — her zaman ilgili kanun maddesine bağlı olarak — önünüze koyalım.
          </p>

          <div style={{ display: 'flex', gap: 12, justifyContent: 'center', alignItems: 'center', marginBottom: 22 }}>
            <Link href="/auth?mode=signup" style={{ display: 'inline-flex', alignItems: 'center', gap: 8, padding: '13px 22px', borderRadius: 'var(--r-sm)', background: 'var(--accent)', color: '#fff', fontSize: 15, fontWeight: 500, boxShadow: '0 1px 0 rgba(255,255,255,0.18) inset, 0 8px 24px var(--accent-glow), 0 0 0 1px var(--accent-ring), 0 0 60px var(--accent-glow)' }}>
              Ücretsiz Analiz Et <ArrowRight size={14} />
            </Link>
            <a href="#how" style={{ padding: '12px 18px', borderRadius: 'var(--r-sm)', fontSize: 14, color: 'var(--text-soft)', border: '1px solid var(--border)', background: 'var(--bg-card)' }}>
              Nasıl çalıştığını gör
            </a>
          </div>
        </div>

        {/* Hero Preview Mockup */}
        <div style={{ position: 'relative', zIndex: 2, maxWidth: 1080, margin: '60px auto 0', padding: '0 32px' }}>
          <div style={{ background: 'var(--bg-elevated)', border: '1px solid var(--border-strong)', borderRadius: 18, boxShadow: 'var(--shadow-lg), 0 0 0 1px var(--bg-card), 0 30px 80px -20px var(--accent-glow)', overflow: 'hidden', transform: 'perspective(1800px) rotateX(2deg)' }}>
            {/* Browser bar */}
            <div style={{ display: 'flex', alignItems: 'center', gap: 8, padding: '12px 16px', borderBottom: '1px solid var(--border)', background: 'var(--bg-inset)' }}>
              <div style={{ display: 'flex', gap: 6 }}>
                {['#C75D5D', '#C99B4B', '#6FA88A'].map((c, i) => <span key={i} style={{ width: 11, height: 11, borderRadius: '50%', background: 'var(--border-strong)' }} />)}
              </div>
              <span style={{ marginLeft: 12, fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: 'var(--text-faint)', background: 'var(--bg-inset)', padding: '4px 10px', borderRadius: 6, border: '1px solid var(--border-subtle)' }}>
                maddenet.app / analiz / kira-sozlesmesi-2026.pdf
              </span>
            </div>
            {/* Preview body */}
            <div style={{ display: 'grid', gridTemplateColumns: '1.4fr 1fr', minHeight: 380 }}>
              {/* Left: clauses */}
              <div style={{ padding: '28px 30px', borderRight: '1px solid var(--border)' }}>
                <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10.5, color: 'var(--text-faint)', letterSpacing: '0.08em', textTransform: 'uppercase', marginBottom: 8 }}>KİRA SÖZLEŞMESİ · 14 MADDE</p>
                <h3 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 22, fontWeight: 600, margin: '0 0 18px', letterSpacing: '-0.01em', color: 'var(--text)' }}>Kira Sözleşmesi — Beyoğlu / İstanbul</h3>
                {[
                  { num: 'M.7', text: 'Tek taraflı erken fesih halinde 6 ay kira bedeli ceza-i şart.', sub: 'TBK m.299 ile çelişiyor olabilir', level: 'high', pill: 'Yüksek', color: 'var(--risk-high)' },
                  { num: 'M.9', text: 'Yıllık kira artışı, TÜFE ortalamasının üzerinde belirleniyor.', sub: 'TBK m.344 — yasal sınırı aşıyor', level: 'mid', pill: 'Dikkat', color: 'var(--risk-mid)' },
                  { num: 'M.12', text: 'Depozito iadesi koşulları net ve süreli düzenlenmiş.', sub: 'TBK m.342 — uyumlu', level: 'safe', pill: 'Uygun', color: 'var(--risk-safe)' },
                ].map(({ num, text, sub, color, pill }) => (
                  <div key={num} style={{ display: 'flex', gap: 10, padding: '12px 14px', borderRadius: 10, background: 'var(--bg-card)', border: '1px solid var(--border)', marginBottom: 8, position: 'relative', overflow: 'hidden' }}>
                    <span style={{ position: 'absolute', left: 0, top: 0, bottom: 0, width: 3, background: color }} />
                    <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: 'var(--text-faint)', marginTop: 1, paddingLeft: 4 }}>{num}</span>
                    <div style={{ flex: 1 }}>
                      <p style={{ fontSize: 13, color: 'var(--text-soft)', lineHeight: 1.4, margin: 0 }}>{text}</p>
                      <small style={{ display: 'block', fontFamily: 'JetBrains Mono, monospace', fontSize: 10.5, color: 'var(--text-faint)', marginTop: 3 }}>{sub}</small>
                    </div>
                    <span style={{ padding: '2px 8px', borderRadius: 'var(--r-full)', background: color + '20', color, border: `1px solid ${color}40`, fontSize: 11, fontWeight: 500, whiteSpace: 'nowrap', alignSelf: 'flex-start' }}>{pill}</span>
                  </div>
                ))}
              </div>
              {/* Right: gauge */}
              <div style={{ padding: '28px 24px', background: 'var(--bg-inset)' }}>
                <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10.5, color: 'var(--text-faint)', letterSpacing: '0.08em', textTransform: 'uppercase', marginBottom: 16 }}>GENEL RİSK SKORU</p>
                <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', padding: '8px 0 16px' }}>
                  <div style={{ position: 'relative', width: 168, height: 168 }}>
                    <svg viewBox="0 0 100 100" style={{ width: '100%', height: '100%', transform: 'rotate(-90deg)' }}>
                      <circle cx="50" cy="50" r="42" stroke="var(--bg-inset)" strokeWidth="8" fill="none" />
                      <circle cx="50" cy="50" r="42" stroke="url(#gauge-grad)" strokeWidth="8" fill="none" strokeLinecap="round" strokeDasharray="263.9" strokeDashoffset="92" />
                      <defs>
                        <linearGradient id="gauge-grad" x1="0" y1="0" x2="1" y2="1">
                          <stop offset="0%" stopColor="var(--risk-safe)" />
                          <stop offset="50%" stopColor="var(--risk-mid)" />
                          <stop offset="100%" stopColor="var(--risk-high)" />
                        </linearGradient>
                      </defs>
                    </svg>
                    <div style={{ position: 'absolute', inset: 0, display: 'flex', alignItems: 'center', justifyContent: 'center', flexDirection: 'column', fontFamily: 'Newsreader, Georgia, serif' }}>
                      <b style={{ fontSize: 44, fontWeight: 500, letterSpacing: '-0.03em', color: 'var(--risk-mid)', lineHeight: 1 }}>65</b>
                      <span style={{ fontFamily: 'Inter, sans-serif', fontSize: 11, color: 'var(--text-faint)', letterSpacing: '0.05em', textTransform: 'uppercase', marginTop: 4 }}>orta risk</span>
                    </div>
                  </div>
                  <div style={{ marginTop: 12, display: 'flex', gap: 14, fontSize: 11.5, color: 'var(--text-muted)' }}>
                    {[['var(--risk-high)', '3 Yüksek'], ['var(--risk-mid)', '5 Dikkat'], ['var(--risk-safe)', '6 Uygun']].map(([color, label]) => (
                      <span key={label} style={{ display: 'inline-flex', alignItems: 'center', gap: 5 }}>
                        <span style={{ width: 8, height: 8, borderRadius: '50%', background: color }} />{label}
                      </span>
                    ))}
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="how" style={{ position: 'relative', padding: '100px 32px 60px', maxWidth: 1180, margin: '0 auto' }}>
        <p style={{ textAlign: 'center', fontFamily: 'JetBrains Mono, monospace', fontSize: 11.5, letterSpacing: '0.12em', color: 'var(--accent)', textTransform: 'uppercase', marginBottom: 14 }}>3 ADIMDA ANALİZ</p>
        <h2 style={{ textAlign: 'center', fontFamily: 'Newsreader, Georgia, serif', fontSize: 42, fontWeight: 500, letterSpacing: '-0.03em', margin: '0 0 60px', color: 'var(--text)' }}>
          Yüklemekten <em style={{ fontStyle: 'italic', color: 'var(--accent-hover)', fontWeight: 400 }}>anlamaya</em> kadar,<br />saniyeler içinde.
        </h2>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 1, background: 'var(--border)', border: '1px solid var(--border)', borderRadius: 'var(--r-lg)', overflow: 'hidden' }}>
          {[
            { n: '1', step: 'YÜKLE', title: "PDF'i sürükleyin, bırakın.", desc: 'Kira, iş, ticari veya tüketici sözleşmenizi yükleyin. Belgeleriniz uçtan uca şifrelenir.', glyph: (
              <svg width="56" height="56" viewBox="0 0 64 64" fill="none">
                <rect x="14" y="10" width="36" height="46" rx="3" stroke="currentColor" strokeWidth="1.2" strokeDasharray="3 3"/>
                <path d="M22 30h20M22 36h20M22 42h13" stroke="currentColor" strokeWidth="1.2"/>
                <circle cx="48" cy="48" r="10" fill="var(--bg)" stroke="var(--accent-deep)" strokeWidth="1.5"/>
                <path d="M48 44v8M44 48h8" stroke="var(--accent-deep)" strokeWidth="1.5" strokeLinecap="round"/>
              </svg>
            ) },
            { n: '2', step: 'ANALİZ ET', title: 'Yapay zekâ, kanunla karşılaştırır.', desc: 'RAG mimarisi her maddeyi gerçek kanun veritabanımıza karşı doğrular. Halüsinasyon yok — sadece referanslı sonuçlar.', glyph: (
              <svg width="80" height="56" viewBox="0 0 80 56" fill="none">
                <rect x="6" y="14" width="22" height="28" rx="2" stroke="currentColor" strokeWidth="1.2"/>
                <path d="M10 22h14M10 28h14M10 34h9" stroke="currentColor" strokeWidth="1.2"/>
                <path d="M30 28h12M36 24l6 4-6 4" stroke="var(--accent-deep)" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round"/>
                <rect x="44" y="14" width="30" height="28" rx="3" stroke="var(--accent-deep)" strokeWidth="1.5"/>
                <path d="M52 28a7 7 0 1 0 14 0a7 7 0 1 0-14 0" stroke="var(--accent-hover)" strokeWidth="1.2"/>
                <circle cx="59" cy="28" r="2" fill="var(--accent-deep)"/>
              </svg>
            ) },
            { n: '3', step: 'ANLA', title: 'Renkli kodlu, sade dilde.', desc: 'Kırmızı, sarı, yeşil. Her madde için somut öneri, kanun referansı ve uygulanabilir aksiyon. PDF olarak indirin.', glyph: (
              <svg width="120" height="56" viewBox="0 0 120 56" fill="none">
                <rect x="10" y="22" width="100" height="10" rx="2" stroke="currentColor" strokeWidth="1.2"/>
                <rect x="10" y="22" width="28" height="10" fill="var(--risk-high)" opacity="0.85"/>
                <rect x="38" y="22" width="34" height="10" fill="var(--risk-mid)" opacity="0.85"/>
                <rect x="72" y="22" width="38" height="10" fill="var(--risk-safe)" opacity="0.85"/>
              </svg>
            ) },
          ].map(({ n, step, title, desc, glyph }) => (
            <div key={n} style={{ background: 'var(--bg-deep)', padding: '36px 32px', position: 'relative' }}>
              <div style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: 'var(--text-faint)', letterSpacing: '0.08em', marginBottom: 18, display: 'flex', alignItems: 'center', gap: 8 }}>
                <span style={{ width: 22, height: 22, borderRadius: 6, background: 'var(--accent-soft)', border: '1px solid var(--accent-ring)', color: 'var(--accent-hover)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', fontWeight: 500, fontSize: 11 }}>{n}</span>
                {step}
              </div>
              <h3 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 22, fontWeight: 600, letterSpacing: '-0.015em', margin: '0 0 10px', color: 'var(--text)' }}>{title}</h3>
              <p style={{ fontSize: 14, lineHeight: 1.6, color: 'var(--text-muted)', margin: '0 0 22px' }}>{desc}</p>
              <div style={{ height: 84, borderTop: '1px solid var(--border)', marginTop: 24, paddingTop: 18, display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--text-faint)' }}>
                {glyph}
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Stats section */}
      <div style={{ maxWidth: 1180, margin: '60px auto 0', padding: '0 32px', display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 1, background: 'var(--border)', border: '1px solid var(--border)', borderRadius: 'var(--r-lg)', overflow: 'hidden' }}>
        {[
          { num: '2.392', label: 'Kanun Maddesi', sub: 'Türk hukuku, sürekli güncellenen' },
          { num: '4', label: 'Sözleşme Türü', sub: 'Kira, iş, ticari, tüketici' },
          { num: '<30s', label: 'Analiz Süresi', sub: 'GPT-4o + RAG pipeline' },
          { num: '%100', label: 'Kanun Referanslı', sub: 'Halüsinasyon yok, daima kaynaklı' },
        ].map(({ num, label, sub }) => (
          <div key={label} style={{ background: 'var(--bg-deep)', padding: '28px 24px' }}>
            <div style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 40, fontWeight: 500, letterSpacing: '-0.03em', background: 'linear-gradient(180deg, var(--text) 0%, var(--accent) 100%)', WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent', lineHeight: 1, marginBottom: 8 }}>{num}</div>
            <div style={{ fontSize: 13, color: 'var(--text-muted)', lineHeight: 1.4 }}>{label}</div>
            <div style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10.5, color: 'var(--text-faint)', marginTop: 6 }}>{sub}</div>
          </div>
        ))}
      </div>

      {/* Trust band */}
      <div style={{ maxWidth: 1180, margin: '80px auto 0', padding: '28px 32px', textAlign: 'center', borderTop: '1px solid var(--border)', borderBottom: '1px solid var(--border)' }}>
        <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: 'var(--text-faint)', letterSpacing: '0.1em', textTransform: 'uppercase', marginBottom: 20 }}>DAYANDIRILAN MEVZUAT</p>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', gap: 56, flexWrap: 'wrap', color: 'var(--text-muted)', fontFamily: 'Newsreader, Georgia, serif', fontSize: 18, fontStyle: 'italic', letterSpacing: '-0.01em' }}>
          <span>Türk Borçlar Kanunu</span>
          <span style={{ width: 1, height: 16, background: 'var(--border)' }} />
          <span>İş Kanunu</span>
          <span style={{ width: 1, height: 16, background: 'var(--border)' }} />
          <span>Tüketicinin Korunması Kanunu</span>
          <span style={{ width: 1, height: 16, background: 'var(--border)' }} />
          <span>Ticaret Kanunu</span>
        </div>
      </div>

      {/* Footer */}
      <footer style={{ marginTop: 80, borderTop: '1px solid var(--border)' }}>
        <div style={{ maxWidth: 1180, margin: '0 auto', padding: '36px 32px', display: 'flex', alignItems: 'center', justifyContent: 'space-between', gap: 32 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 20 }}>
            <Logo size="sm" href="/" />
            <span style={{ width: 1, height: 20, background: 'var(--border)', flexShrink: 0 }} />
            <span style={{ fontSize: 13.5, color: 'var(--text-muted)', letterSpacing: '-0.01em' }}>Sözleşmeni anla, riskini bil.</span>
          </div>
          <nav style={{ display: 'flex', alignItems: 'center', gap: 28 }}>
            {[['Analiz başlat', '/upload'], ['Dashboard', '/dashboard'], ['Kanun veritabanı', '#']].map(([label, href]) => (
              <Link key={label} href={href} style={{ fontSize: 13.5, color: 'var(--text-soft)' }}>{label}</Link>
            ))}
          </nav>
        </div>

        {/* Legal disclaimer */}
        <div style={{ maxWidth: 1180, margin: '0 auto', padding: '0 32px 28px', display: 'flex', alignItems: 'flex-start', gap: 14 }}>
          <span style={{ flexShrink: 0, width: 32, height: 32, borderRadius: 9, background: 'var(--risk-mid-soft)', border: '1px solid var(--risk-mid-ring)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', color: 'var(--risk-mid)', fontSize: 15, marginTop: 2 }}>⚖</span>
          <div style={{ flex: 1, padding: '14px 18px', background: 'var(--risk-mid-soft)', border: '1px solid var(--risk-mid-ring)', borderRadius: 'var(--r-md)', fontSize: 13, lineHeight: 1.65, color: 'var(--text-soft)' }}>
            <strong style={{ color: 'var(--text)', fontWeight: 600, display: 'block', marginBottom: 4 }}>MaddeNet bir hukuki danışmanlık platformu değildir.</strong>
            Sunulan analizler yalnızca bilgilendirme ve farkındalık amaçlıdır. Tüm sonuçlar "Bir avukata danışmanızı öneririz" notu ile birlikte sunulur. MaddeNet&apos;in sağladığı içerikler hukuki tavsiye niteliği taşımaz; somut hukuki sorunlarınız için lütfen bir hukuk profesyoneline başvurun.
          </div>
        </div>

        <div style={{ maxWidth: 1180, margin: '0 auto', padding: '18px 32px', borderTop: '1px solid var(--border-subtle)', display: 'flex', justifyContent: 'space-between' }}>
          <span style={{ fontSize: 12, color: 'var(--text-faint)' }}>© 2026 MaddeNet · Tüm hakları saklıdır.</span>
        </div>
      </footer>

      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  )
}
