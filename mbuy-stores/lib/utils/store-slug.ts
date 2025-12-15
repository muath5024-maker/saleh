/**
 * Extract store slug from Host header
 * Examples:
 * - ali-shop.mbuy.pro -> ali-shop
 * - www.mbuy.pro -> null (main site)
 * - mbuy.pro -> null (main site)
 * - localhost:3000 -> null (development)
 */
export function extractStoreSlug(host: string | null): string | null {
  if (!host) return null;
  
  const MAIN_DOMAIN = process.env.NEXT_PUBLIC_MAIN_DOMAIN || 'mbuy.pro';
  
  // Remove port if present
  const hostWithoutPort = host.split(':')[0].toLowerCase();
  
  // Check if it's a subdomain of mbuy.pro
  if (hostWithoutPort.endsWith(`.${MAIN_DOMAIN}`)) {
    const subdomain = hostWithoutPort.replace(`.${MAIN_DOMAIN}`, '');
    // Exclude www and api subdomains
    if (subdomain && subdomain !== 'www' && subdomain !== 'api') {
      return subdomain;
    }
  }
  
  return null;
}

/**
 * Get store slug from request headers (server-side)
 */
export function getStoreSlugFromHeaders(headers: Headers): string | null {
  const host = headers.get('host') || headers.get('x-forwarded-host');
  return extractStoreSlug(host);
}

/**
 * Validate slug format
 */
export function validateSlug(slug: string): boolean {
  const slugRegex = /^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/;
  return slugRegex.test(slug.toLowerCase());
}
