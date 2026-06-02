import { NextResponse, type NextRequest } from 'next/server'

export async function GET(request: NextRequest) {
  const { origin } = new URL(request.url)
  // Email onayından sonra dashboard'a yönlendir
  return NextResponse.redirect(`${origin}/dashboard`)
}
