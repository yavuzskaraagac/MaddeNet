import axios from 'axios'
import { createClient } from './supabase'
import type { AnalysisRecord, ContractAnalysisResult, DocumentRecord, SozlesmeTuru } from './types'

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:8000',
})

api.interceptors.request.use(async (config) => {
  const supabase = createClient()
  const { data: { session } } = await supabase.auth.getSession()
  if (session) {
    config.headers.Authorization = `Bearer ${session.access_token}`
  }
  return config
})

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
): Promise<AnalysisRecord> {
  const { data } = await api.post<AnalysisRecord>('/api/analyses', {
    document_id: documentId,
    sozlesme_turu: sozlesmeTuru,
  })
  return data
}

export async function getAnalysis(id: string): Promise<ContractAnalysisResult> {
  const { data } = await api.get<ContractAnalysisResult>(`/api/analyses/${id}`)
  return data
}

export async function listAnalyses(): Promise<AnalysisRecord[]> {
  const { data } = await api.get<AnalysisRecord[]>('/api/analyses')
  return data
}

export async function listDocuments(): Promise<DocumentRecord[]> {
  const { data } = await api.get<DocumentRecord[]>('/api/documents')
  return data
}

export async function deleteAnalysis(id: string): Promise<void> {
  await api.delete(`/api/analyses/${id}`)
}

export async function deleteDocument(id: string): Promise<void> {
  await api.delete(`/api/documents/${id}`)
}

export async function getRagStats(): Promise<{ toplam_madde: number }> {
  const { data } = await api.get('/api/rag/stats')
  return data
}
