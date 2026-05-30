'use client'

import { useState, useRef } from 'react'
import { useRouter } from 'next/navigation'
import { Upload, FileText, CheckCircle, Loader2, Scale } from 'lucide-react'
import { uploadDocument, startAnalysis } from '@/lib/api'
import type { SozlesmeTuru } from '@/lib/types'
import { SOZLESME_TURU_LABELS } from '@/lib/types'
import { toast } from 'sonner'

const STEPS = ['Yükle', 'İşle', 'Analiz Et', 'Tamamlandı']

const STAGES = [
  'PDF dosyası okunuyor ve metne dönüştürülüyor',
  'Sözleşme maddeleri tespit ediliyor',
  'RAG — kanun veritabanında arama yapılıyor',
  'GPT-4o ile her madde değerlendiriliyor',
  'Risk seviyeleri ve öneriler oluşturuluyor',
  'Sonuçlar kaydediliyor',
]

export default function UploadPage() {
  const router = useRouter()
  const inputRef = useRef<HTMLInputElement>(null)
  const [file, setFile] = useState<File | null>(null)
  const [sozlesmeTuru, setSozlesmeTuru] = useState<SozlesmeTuru>('genel')
  const [step, setStep] = useState(0)
  const [activeStage, setActiveStage] = useState(-1)
  const [doneStages, setDoneStages] = useState<number[]>([])
  const [progress, setProgress] = useState(0)
  const [dragging, setDragging] = useState(false)
  const [showModal, setShowModal] = useState(false)

  function handleFile(f: File) {
    if (!f.name.endsWith('.pdf')) { toast.error('Sadece PDF dosyaları desteklenir'); return }
    setFile(f)
  }

  function handleDrop(e: React.DragEvent) {
    e.preventDefault(); setDragging(false)
    const f = e.dataTransfer.files[0]; if (f) handleFile(f)
  }

  async function handleSubmit() {
    if (!file) return
    setShowModal(true); setStep(1); setActiveStage(0); setProgress(5)

    const advanceStage = (stage: number, pct: number) => {
      setActiveStage(stage); setProgress(pct)
      if (stage > 0) setDoneStages(prev => [...prev, stage - 1])
    }

    try {
      advanceStage(0, 10)
      const doc = await uploadDocument(file, sozlesmeTuru)
      advanceStage(1, 25); setStep(2)
      await new Promise(r => setTimeout(r, 300))
      advanceStage(2, 40)
      const analysis = await startAnalysis(doc.id, sozlesmeTuru)
      advanceStage(3, 60)
      await new Promise(r => setTimeout(r, 400))
      advanceStage(4, 80)
      await new Promise(r => setTimeout(r, 400))
      advanceStage(5, 95)
      await new Promise(r => setTimeout(r, 300))
      setDoneStages([0, 1, 2, 3, 4, 5]); setProgress(100); setStep(3)
      await new Promise(r => setTimeout(r, 600))
      router.push(`/analysis/${analysis.id}`)
    } catch (err: unknown) {
      toast.error(err instanceof Error ? err.message : 'Hata oluştu')
      setShowModal(false); setStep(0); setActiveStage(-1); setDoneStages([]); setProgress(0)
    }
  }

  const isRunning = step > 0 && step < 3

  return (
    <div style={{ padding: '32px', maxWidth: 820, margin: '0 auto' }}>
      {/* Header */}
      <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11.5, color: 'var(--accent)', letterSpacing: '0.12em', textTransform: 'uppercase', marginBottom: 10 }}>Yeni Analiz</p>
      <h1 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 36, fontWeight: 500, letterSpacing: '-0.03em', color: 'var(--text)', marginBottom: 10 }}>
        Sözleşmenizi <em style={{ fontStyle: 'italic', color: 'var(--accent-hover)', fontWeight: 400 }}>yükleyin</em>
      </h1>
      <p style={{ fontSize: 14.5, color: 'var(--text-muted)', lineHeight: 1.55, maxWidth: 520, marginBottom: 36 }}>
        PDF dosyanızı yükleyin, türünü seçin. Yapay zeka dakikalar içinde sözleşmenizin risklerini analiz eder.
      </p>

      {/* Step indicator */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', marginBottom: 36, background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)', overflow: 'hidden' }}>
        {STEPS.map((s, i) => {
          const isActive = step === i + 1 || (step === 0 && i === 0)
          const isDone = step > i + 1 || step === 3
          return (
            <div key={s} style={{ padding: '18px 22px', borderRight: i < 3 ? '1px solid var(--border)' : 'none', background: isActive ? 'linear-gradient(180deg, var(--accent-soft), transparent)' : 'transparent', transition: 'background 0.3s' }}>
              <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 10.5, color: 'var(--text-faint)', letterSpacing: '0.08em', marginBottom: 4 }}>{String(i + 1).padStart(2, '0')}</p>
              <div style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 16, fontWeight: 500, color: isActive || isDone ? 'var(--text)' : 'var(--text-muted)', display: 'flex', alignItems: 'center', gap: 8 }}>
                {isDone ? <CheckCircle size={18} color="var(--risk-safe)" /> :
                  isActive && step > 0 ? <Loader2 size={18} color="var(--accent)" style={{ animation: 'spin 1s linear infinite' }} /> :
                  <span style={{ width: 22, height: 22, borderRadius: '50%', background: isActive ? 'var(--accent)' : 'var(--bg-inset)', border: '1px solid var(--border)', display: 'inline-flex', alignItems: 'center', justifyContent: 'center', fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: isActive ? '#fff' : 'var(--text-faint)' }}>{i + 1}</span>}
                {s}
              </div>
            </div>
          )
        })}
      </div>

      {/* Dropzone */}
      <div
        onDragOver={(e) => { e.preventDefault(); setDragging(true) }}
        onDragLeave={() => setDragging(false)}
        onDrop={handleDrop}
        onClick={() => !isRunning && inputRef.current?.click()}
        style={{ border: `1.5px dashed ${dragging ? 'var(--accent)' : file ? 'var(--risk-safe)' : 'var(--border-strong)'}`, borderRadius: 'var(--r-md)', padding: '56px 24px', textAlign: 'center', cursor: isRunning ? 'default' : 'pointer', background: dragging ? 'var(--accent-soft)' : file ? 'var(--risk-safe-soft)' : `radial-gradient(ellipse at center, ${dragging ? 'var(--accent-soft)' : 'var(--bg-inset)'} 0%, transparent 70%), var(--bg-card)`, transition: 'all 0.2s', marginBottom: 24 }}
      >
        <input ref={inputRef} type="file" accept=".pdf" style={{ display: 'none' }} onChange={(e) => { if (e.target.files?.[0]) handleFile(e.target.files[0]) }} />
        {file ? (
          <div>
            <div style={{ width: 64, height: 64, borderRadius: 12, background: 'var(--risk-safe-soft)', border: '1px solid var(--risk-safe-ring)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 16px' }}>
              <FileText size={28} color="var(--risk-safe)" />
            </div>
            <p style={{ fontSize: 15, color: 'var(--text)', fontWeight: 500, marginBottom: 4 }}>{file.name}</p>
            <p style={{ fontSize: 12.5, color: 'var(--text-muted)' }}>{(file.size / 1024 / 1024).toFixed(2)} MB</p>
            {!isRunning && <p style={{ marginTop: 10, fontSize: 12, color: 'var(--text-faint)' }}>Değiştirmek için tıklayın</p>}
          </div>
        ) : (
          <div>
            <div style={{ width: 64, height: 64, borderRadius: 12, background: 'linear-gradient(180deg, var(--bg-elevated), var(--bg-card))', border: '1px solid var(--border)', display: 'flex', alignItems: 'center', justifyContent: 'center', margin: '0 auto 20px', boxShadow: 'var(--shadow-md)' }}>
              <Upload size={26} color="var(--text-faint)" />
            </div>
            <p style={{ fontSize: 15, color: 'var(--text)', marginBottom: 8 }}>PDF&apos;inizi sürükleyin veya tıklayın</p>
            <p style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: 'var(--text-faint)', letterSpacing: '0.06em' }}>SADECE PDF · MAKSİMUM 20 MB</p>
          </div>
        )}
      </div>

      {/* Config grid */}
      <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 16, marginBottom: 28 }}>
        <div style={{ padding: '16px 18px', background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)' }}>
          <label style={{ display: 'block', fontSize: 12.5, color: 'var(--text-muted)', marginBottom: 8, fontWeight: 500 }}>Sözleşme Türü</label>
          <div style={{ position: 'relative' }}>
            <select
              value={sozlesmeTuru}
              onChange={(e) => setSozlesmeTuru(e.target.value as SozlesmeTuru)}
              disabled={isRunning}
              style={{ width: '100%', padding: '9px 32px 9px 12px', background: 'var(--bg-inset)', border: '1px solid var(--border)', borderRadius: 'var(--r-sm)', color: 'var(--text)', fontSize: 13.5, cursor: isRunning ? 'not-allowed' : 'pointer', appearance: 'none' }}
            >
              {Object.entries(SOZLESME_TURU_LABELS).map(([value, label]) => (
                <option key={value} value={value}>{label}</option>
              ))}
            </select>
            <span style={{ position: 'absolute', right: 10, top: '50%', transform: 'translateY(-50%)', pointerEvents: 'none', color: 'var(--text-faint)' }}>▾</span>
          </div>
        </div>
        <div style={{ padding: '16px 18px', background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)' }}>
          <label style={{ display: 'block', fontSize: 12.5, color: 'var(--text-muted)', marginBottom: 8, fontWeight: 500 }}>Analiz Derinliği</label>
          <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
            {['Standart (önerilen)', 'Detaylı (daha yavaş)'].map((opt, i) => (
              <label key={opt} style={{ display: 'flex', alignItems: 'center', gap: 8, cursor: 'pointer', fontSize: 13, color: i === 0 ? 'var(--text)' : 'var(--text-muted)' }}>
                <input type="radio" name="depth" defaultChecked={i === 0} style={{ accentColor: 'var(--accent)' }} />
                {opt}
              </label>
            ))}
          </div>
        </div>
      </div>

      {/* CTA bar */}
      <div style={{ padding: '16px 20px', background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-md)', display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 20 }}>
        <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
          <div style={{ width: 36, height: 36, borderRadius: 10, background: 'var(--accent-soft)', border: '1px solid var(--accent-ring)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Scale size={16} color="var(--accent)" />
          </div>
          <div>
            <p style={{ margin: 0, fontSize: 13.5, color: 'var(--text)', fontWeight: 450 }}>2.392 kanun maddesiyle karşılaştırılacak</p>
            <p style={{ margin: 0, fontSize: 11.5, color: 'var(--text-muted)' }}>Türk Borçlar Kanunu, İş Kanunu ve diğerleri</p>
          </div>
        </div>
        <button
          onClick={handleSubmit}
          disabled={!file || isRunning}
          style={{ display: 'inline-flex', alignItems: 'center', gap: 8, padding: '11px 28px', background: !file || isRunning ? 'var(--bg-inset)' : 'var(--accent)', color: !file || isRunning ? 'var(--text-faint)' : '#fff', border: '1px solid var(--border)', borderRadius: 'var(--r-sm)', fontSize: 14, fontWeight: 500, cursor: !file || isRunning ? 'not-allowed' : 'pointer', boxShadow: file && !isRunning ? 'var(--shadow-glow)' : 'none', transition: 'all 0.2s' }}
        >
          {isRunning ? <><Loader2 size={15} style={{ animation: 'spin 1s linear infinite' }} /> Analiz ediliyor…</> : <><Scale size={15} /> Analizi Başlat</>}
        </button>
      </div>

      {/* Privacy note */}
      <div style={{ display: 'flex', gap: 10, padding: '12px 16px', background: 'var(--bg-card)', border: '1px solid var(--border)', borderRadius: 'var(--r-sm)', fontSize: 12.5, color: 'var(--text-muted)', lineHeight: 1.55 }}>
        <Scale size={14} style={{ flexShrink: 0, marginTop: 1, color: 'var(--text-soft)' }} />
        <span>Belgeleriniz yalnızca analiz amacıyla işlenir ve güvenli şekilde saklanır. <b style={{ color: 'var(--text-soft)', fontWeight: 500 }}>Sonuçlar hukuki tavsiye niteliği taşımaz.</b></span>
      </div>

      {/* Analysis Overlay Modal */}
      {showModal && (
        <div style={{ position: 'fixed', inset: 0, background: 'rgba(5, 11, 20, 0.75)', backdropFilter: 'blur(16px)', zIndex: 100, display: 'flex', alignItems: 'center', justifyContent: 'center', padding: 40 }}>
          <div style={{ width: '100%', maxWidth: 620, background: 'linear-gradient(180deg, var(--bg-elevated) 0%, var(--bg-deep) 100%)', border: '1px solid var(--border-strong)', borderRadius: 'var(--r-lg)', boxShadow: 'var(--shadow-lg), 0 0 0 1px var(--bg-card)', overflow: 'hidden' }}>
            {/* Header */}
            <div style={{ padding: '28px 32px 22px', borderBottom: '1px solid var(--border)' }}>
              <h2 style={{ fontFamily: 'Newsreader, Georgia, serif', fontSize: 24, fontWeight: 500, letterSpacing: '-0.02em', margin: '0 0 6px', color: 'var(--text)' }}>
                {step === 3 ? 'Analiz tamamlandı!' : 'Analiz yapılıyor…'}
              </h2>
              <p style={{ fontSize: 13.5, color: 'var(--text-muted)', margin: 0 }}>
                {file?.name} · {SOZLESME_TURU_LABELS[sozlesmeTuru]}
              </p>
              {/* Progress bar */}
              <div style={{ height: 4, background: 'var(--bg-inset)', borderRadius: 4, overflow: 'hidden', margin: '18px 0 4px' }}>
                <div style={{ height: '100%', width: `${progress}%`, background: 'linear-gradient(90deg, var(--accent-hover), var(--accent-deep))', borderRadius: 4, transition: 'width 0.5s ease', boxShadow: '0 0 10px var(--accent-glow)' }} />
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: 'var(--text-faint)' }}>
                <span>İşlem sürüyor</span>
                <span>%{progress}</span>
              </div>
            </div>

            {/* Stage list */}
            <ul style={{ padding: '20px 32px', listStyle: 'none', margin: 0, display: 'flex', flexDirection: 'column', gap: 4 }}>
              {STAGES.map((label, i) => {
                const isDone = doneStages.includes(i)
                const isAct = activeStage === i
                return (
                  <li key={i} style={{ display: 'flex', alignItems: 'center', gap: 14, padding: '12px 0', borderBottom: i < STAGES.length - 1 ? '1px dashed var(--border-subtle)' : 'none', color: isDone ? 'var(--text-soft)' : isAct ? 'var(--text)' : 'var(--text-faint)' }}>
                    <span style={{ width: 24, height: 24, borderRadius: '50%', background: isDone ? 'var(--risk-safe)' : isAct ? 'var(--accent)' : 'var(--bg-inset)', border: `1px solid ${isDone ? 'var(--risk-safe)' : isAct ? 'var(--accent)' : 'var(--border)'}`, display: 'inline-flex', alignItems: 'center', justifyContent: 'center', color: isDone || isAct ? '#fff' : 'var(--text-faint)', flexShrink: 0, fontFamily: 'JetBrains Mono, monospace', fontSize: 11, boxShadow: isAct ? '0 0 0 4px var(--accent-soft)' : 'none' }}>
                      {isDone ? '✓' : isAct ? <span style={{ width: 12, height: 12, border: '2px solid rgba(255,255,255,0.3)', borderTopColor: '#fff', borderRadius: '50%', animation: 'spin 0.8s linear infinite', display: 'block' }} /> : i + 1}
                    </span>
                    <span style={{ fontSize: 14, fontWeight: isAct ? 500 : 450, flex: 1 }}>{label}</span>
                    {isAct && <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: 'var(--accent)' }}>çalışıyor…</span>}
                    {isDone && <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: 11, color: 'var(--text-faint)' }}>✓</span>}
                  </li>
                )
              })}
            </ul>

            {/* Note */}
            <div style={{ margin: '0 32px 28px', padding: '14px 16px', border: '1px solid var(--border)', borderRadius: 'var(--r-sm)', background: 'var(--bg-card)', display: 'flex', gap: 12, fontSize: 12.5, lineHeight: 1.55, color: 'var(--text-muted)' }}>
              <Scale size={14} style={{ color: 'var(--text-soft)', flexShrink: 0, marginTop: 1 }} />
              <span><b style={{ color: 'var(--text-soft)', fontWeight: 500 }}>Bilgilendirme amaçlıdır.</b> Sonuçlar hukuki tavsiye niteliği taşımaz.</span>
            </div>
          </div>
        </div>
      )}

      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>
    </div>
  )
}
