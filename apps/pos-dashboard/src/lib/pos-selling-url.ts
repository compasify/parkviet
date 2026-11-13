type SellingLocation = {
  baseUrl?: string
  development?: boolean
  // Where this app runs; a path-only base (`/pos/`) is resolved against it.
  origin?: string
}

const currentLocation = (): SellingLocation => ({
  baseUrl: import.meta.env.VITE_POS_URL,
  development: import.meta.env.DEV,
  origin: globalThis.location?.origin,
})

// Origins are deployment configuration. Never put a token in these URLs:
// the selling app establishes its own session at its origin. A production
// build without configuration must not send staff to localhost. A path-only
// base means the counter is served by the same server (the production image
// puts it at /pos/), so one build works on any address.
function sellingBase(location: SellingLocation): URL | null {
  const configured = location.baseUrl?.trim()
  const base = configured || (location.development ? 'http://localhost:5175' : null)
  if (!base) return null
  const sameOrigin = base.startsWith('/') && !base.startsWith('//')
  if (sameOrigin && !location.origin) return null
  try {
    const url = sameOrigin ? new URL(base, location.origin) : new URL(base)
    if (url.protocol !== 'https:' && url.protocol !== 'http:') return null
    if (url.username || url.password) return null
    url.search = ''
    url.hash = ''
    return url
  } catch {
    return null
  }
}

const basePath = (url: URL) => url.pathname.replace(/\/+$/, '')
const identity = (value: string | null | undefined) =>
  Boolean(value && /^[a-zA-Z0-9_-]+$/.test(value))

// True when this build knows where the counter runs, so the switch can be shown.
export function posSellingConfigured(location: SellingLocation = currentLocation()): boolean {
  return sellingBase(location) !== null
}

// The counter's sale screen for this store, and the branch the dashboard has
// open when one is selected. The selling app reads both and then keeps its
// own session.
export function posSellingUrl(
  storeId: string | null | undefined,
  branchId?: string | null,
  location: SellingLocation = currentLocation(),
): string | null {
  if (!identity(storeId)) return null
  const url = sellingBase(location)
  if (!url) return null
  url.pathname = `${basePath(url)}/`
  url.searchParams.set('store', storeId as string)
  if (identity(branchId)) url.searchParams.set('branch', branchId as string)
  return url.toString()
}
