import { NextResponse, type NextRequest } from 'next/server'

// Auth kontrolü client-side layout'ta yapılıyor.
// Proxy sadece next-start için geçiş sağlar.
export function proxy(request: NextRequest) {
  return NextResponse.next()
}

export const config = {
  matcher: [],
}
