import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';
import { extractStoreSlug } from './lib/utils/store-slug';

export function middleware(request: NextRequest) {
  const host = request.headers.get('host') || '';
  const slug = extractStoreSlug(host);
  const pathname = request.nextUrl.pathname;

  // If it's a store subdomain and not already on store routes
  if (slug && !pathname.startsWith('/store/') && !pathname.startsWith('/onboarding') && !pathname.startsWith('/api')) {
    // Redirect to store page
    return NextResponse.rewrite(new URL(`/store/${slug}${pathname === '/' ? '' : pathname}`, request.url));
  }

  // If it's main domain and trying to access store route, redirect to onboarding
  if (!slug && pathname.startsWith('/store/')) {
    return NextResponse.redirect(new URL('/onboarding', request.url));
  }

  return NextResponse.next();
}

export const config = {
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     */
    '/((?!_next/static|_next/image|favicon.ico).*)',
  ],
};
