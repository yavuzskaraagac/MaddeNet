export type RiskLevel = 'red' | 'yellow' | 'green'

export type SozlesmeTuru =
  | 'kira'
  | 'is_sozlesmesi'
  | 'ticari'
  | 'tuketici'
  | 'genel'

export interface ClauseAnalysis {
  madde_no: string
  madde_metni: string
  risk_seviyesi: RiskLevel
  sade_aciklama: string
  kanun_dayanagi: string | null
  kanun_maddesi: string | null
  oneri: string | null
  rag_bulunan: boolean
  rag_max_benzerlik: number | null
}

export interface AnalysisDetail {
  id: string
  belge_id: string
  sozlesme_turu: SozlesmeTuru
  genel_risk_skoru: number
  genel_risk_seviyesi: RiskLevel
  maddeler: ClauseAnalysis[]
  created_at: string
}

export interface AnalysisSummary {
  id: string
  belge_id: string
  sozlesme_turu: SozlesmeTuru
  genel_risk_skoru: number
  genel_risk_seviyesi: RiskLevel
  madde_sayisi: number
  created_at: string
}

export interface DocumentRecord {
  id: string
  file_name: string
  file_url: string
  file_size: number
  status: 'uploaded' | 'processing' | 'analyzed' | 'error'
  created_at: string
}

// Backward compat aliases
export type ContractAnalysisResult = AnalysisDetail
export type AnalysisRecord = AnalysisSummary

export const SOZLESME_TURU_LABELS: Record<SozlesmeTuru, string> = {
  kira: 'Kira Sözleşmesi',
  is_sozlesmesi: 'İş Sözleşmesi',
  ticari: 'Ticari Sözleşme',
  tuketici: 'Tüketici Sözleşmesi',
  genel: 'Genel Sözleşme',
}

export const RISK_LABELS: Record<RiskLevel, string> = {
  red: 'YÜKSEK RİSK',
  yellow: 'DİKKAT',
  green: 'UYGUN',
}
