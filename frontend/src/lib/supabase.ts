'use client'

import { createClient as _create } from '@supabase/supabase-js'

// Singleton — her render'da yeni client oluşturma
let _client: ReturnType<typeof _create> | null = null

export function createClient() {
  if (!_client) {
    _client = _create(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    )
  }
  return _client
}
