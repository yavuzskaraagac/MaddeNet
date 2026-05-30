export type RiskLevel = 'RED' | 'YELLOW' | 'GREEN'

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
  aciklama: string
  kanun_dayanagi: string
  oneri: string
  rag_bulunan: boolean
  rag_max_benzerlik: number | null
}

export interface ContractAnalysisResult {
  belge_id: string
  sozlesme_turu: SozlesmeTuru
  maddeler: ClauseAnalysis[]
  genel_risk_skoru: number
}

export interface DocumentRecord {
  id: string
  user_id: string
  filename: string
  file_size: number
  status: 'pending' | 'processing' | 'completed' | 'failed'
  storage_path: string | null
  created_at: string
  updated_at: string
}

export interface AnalysisRecord {
  id: string
  document_id: string
  user_id: string
  sozlesme_turu: SozlesmeTuru
  madde_sayisi: number
  genel_risk_skoru: number
  sonuc: ContractAnalysisResult | null
  status: 'pending' | 'processing' | 'completed' | 'failed'
  created_at: string
}

export const SOZLESME_TURU_LABELS: Record<SozlesmeTuru, string> = {
  kira: 'Kira Sözleşmesi',
  is_sozlesmesi: 'İş Sözleşmesi',
  ticari: 'Ticari Sözleşme',
  tuketici: 'Tüketici Sözleşmesi',
  genel: 'Genel Sözleşme',
}

export const RISK_LABELS: Record<RiskLevel, string> = {
  RED: 'YÜKSEK RİSK',
  YELLOW: 'DİKKAT',
  GREEN: 'UYGUN',
}
