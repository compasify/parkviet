type DashboardLocation = {
  baseUrl?: string;
  development?: boolean;
};

// Origins are deployment configuration, not account state. Never put a token
// in this URL: the dashboard establishes its own admin session at its origin.
// A production build without configuration must not send staff to localhost.
export function posDashboardUrl(
  storeId: string | null | undefined,
  path = '',
  branchId?: string | null,
  location: DashboardLocation = {
    baseUrl: import.meta.env.VITE_POS_DASHBOARD_URL,
    development: import.meta.env.DEV,
  },
): string | null {
  const configured = location.baseUrl?.trim();
  const base = configured || (location.development ? 'http://localhost:5176' : null);
  if (!base || !storeId || storeId === '.' || storeId === '..') return null;
  try {
    const url = new URL(base);
    if (url.protocol !== 'https:' && url.protocol !== 'http:') return null;
    if (url.username || url.password) return null;
    // Accept route segments only. Reject URL-shaped paths and traversal rather
    // than allowing a caller to escape the configured deployment base path.
    const segments = path.split('/').filter(Boolean);
    if (segments.some((part) => !/^[a-zA-Z0-9_-]+$/.test(part))) return null;
    url.pathname = `${url.pathname.replace(/\/+$/, '')}/${encodeURIComponent(storeId)}${segments.length ? `/${segments.join('/')}` : ''}`;
    url.search = '';
    url.hash = '';
    if (branchId) url.searchParams.set('branch', branchId);
    return url.toString();
  } catch {
    return null;
  }
}
