// Post-login return targets arrive through the URL, so they are untrusted.
// Only same-app relative paths are accepted; anything that could leave the
// origin (scheme, protocol-relative `//`, backslash tricks, control
// characters) or loop back into the sign-in screens is rejected.
const ORIGIN = 'http://pos-dashboard.invalid'
const MAX_LENGTH = 2048
const AUTH_PAGES = /^\/(?:login|forgot-password)(?:\/|$)/

function hasUnsafeCharacter(value: string): boolean {
  // Browsers treat `\` like `/` (`/\evil.test` is protocol-relative) and strip
  // tabs/newlines before parsing, so neither may appear anywhere.
  for (const char of value) {
    const code = char.charCodeAt(0)
    if (char === '\\' || code < 0x20 || code === 0x7f) return true
  }
  return false
}

export function safeRedirect(value: unknown): string | null {
  if (typeof value !== 'string' || value.length === 0 || value.length > MAX_LENGTH) return null
  if (!value.startsWith('/') || value.startsWith('//') || hasUnsafeCharacter(value)) return null
  let url: URL
  try {
    url = new URL(value, ORIGIN)
  } catch {
    return null
  }
  if (url.origin !== ORIGIN || AUTH_PAGES.test(url.pathname)) return null
  return value
}

// The search value the login route carries; `/` is the default landing page
// and is left out to keep the login URL clean.
export function loginRedirect(href: string): string | undefined {
  const target = safeRedirect(href)
  return target && target !== '/' ? target : undefined
}
