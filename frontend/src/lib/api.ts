import axios from 'axios'
import { createClient } from './supabase'
import type { AnalysisDetail, AnalysisSummary, DocumentRecord, SozlesmeTuru } from './types'

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000',
})

// Token'ı al: önce Supabase session, yoksa localStorage fallback
api.interceptors.request.use(async (config) => {
  const supabase = createClient()
  const { data } = await supabase.auth.getSession()
  const token = data.session?.access_token
    ?? (typeof window !== 'undefined' ? localStorage.getItem('sb-access-token') : null)

  if (token) {
    config.headers.Authorization = `Bearer ${token}`
  }
  return config
})

// 401 gelince session'ı temizle ve login'e yönlendir
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      const supabase = createClient()
      await supabase.auth.signOut()
      if (typeof window !== 'undefined') {
        window.location.href = '/auth'
      }
    }
    return Promise.reject(error)
  }
)

export async function uploadDocument(
  file: File,
  sozlesmeTuru: SozlesmeTuru
): Promise<DocumentRecord> {
  const form = new FormData()
  form.append('file', file)
  form.append('sozlesme_turu', sozlesmeTuru)
  const { data } = await api.post<DocumentRecord>('/api/documents/upload', form, {
    headers: { 'Content-Type': 'multipart/form-data' },
  })
  return data
}

export async function startAnalysis(
  documentId: string,
  sozlesmeTuru: SozlesmeTuru
): Promise<AnalysisSummary> {
  const { data } = await api.post<AnalysisSummary>('/api/analyses', {
    belge_id: documentId,
    sozlesme_turu: sozlesmeTuru,
  })
  return data
}

export async function getAnalysis(id: string): Promise<AnalysisDetail> {
  const { data } = await api.get<AnalysisDetail>(`/api/analyses/${id}`)
  return data
}

export async function listAnalyses(): Promise<AnalysisSummary[]> {
  const { data } = await api.get<{ analizler: AnalysisSummary[]; toplam: number }>('/api/analyses')
  return data.analizler
}

export async function listDocuments(): Promise<DocumentRecord[]> {
  const { data } = await api.get<{ belgeler: DocumentRecord[]; toplam: number }>('/api/documents')
  return data.belgeler
}

export async function deleteAnalysis(id: string): Promise<void> {
  await api.delete(`/api/analyses/${id}`)
}

export async function deleteDocument(id: string): Promise<void> {
  await api.delete(`/api/documents/${id}`)
}

export async function getRagStats(): Promise<{ toplam_kanun_maddesi: number }> {
  const { data } = await api.get('/api/rag/stats')
  return data
}

export async function getDocumentDownloadUrl(id: string): Promise<{ url: string; file_name: string }> {
  const { data } = await api.get(`/api/documents/${id}/download`)
  return data
}
