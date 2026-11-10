type DashboardLocation = {
  baseUrl?: string;
  development?: boolean;
};

const currentLocation = (): DashboardLocation => ({
  baseUrl: import.meta.env.VITE_POS_DASHBOARD_URL,
  development: import.meta.env.DEV,
});

// Origins are deployment configuration, not account state. Never put a token
// in these URLs: the dashboard establishes its own admin session at its origin.
// A production build without configuration must not send staff to localhost.
function dashboardBase(location: DashboardLocation): URL | null {
  const configured = location.baseUrl?.trim();
  const base = configured || (location.development ? 'http://localhost:5176' : null);
  if (!base) return null;
  try {
    const url = new URL(base);
    if (url.protocol !== 'https:' && url.protocol !== 'http:') return null;
    if (url.username || url.password) return null;
    url.search = '';
    url.hash = '';
    return url;
  } catch {
    return null;
  }
}

// The deployment path without its trailing slash ('' at the domain root).
const basePath = (url: URL) => url.pathname.replace(/\/+$/, '');

// The dashboard entry, where it signs in and picks the store itself.
export function posDashboardHomeUrl(
  location: DashboardLocation = currentLocation(),
): string | null {
  const url = dashboardBase(location);
  if (!url) return null;
  url.pathname = `${basePath(url)}/`;
  return url.toString();
}

export function posDashboardUrl(
  storeId: string | null | undefined,
  path = '',
  branchId?: string | null,
  location: DashboardLocation = currentLocation(),
): string | null {
  if (!storeId || storeId === '.' || storeId === '..') return null;
  const url = dashboardBase(location);
  if (!url) return null;
  // Accept route segments only. Reject URL-shaped paths and traversal rather
  // than allowing a caller to escape the configured deployment base path.
  const segments = path.split('/').filter(Boolean);
  if (segments.some((part) => !/^[a-zA-Z0-9_-]+$/.test(part))) return null;
  url.pathname = `${basePath(url)}/${encodeURIComponent(storeId)}${segments.length ? `/${segments.join('/')}` : ''}`;
  if (branchId) url.searchParams.set('branch', branchId);
  return url.toString();
}
