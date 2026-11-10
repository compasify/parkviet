import type { Page } from '@playwright/test';

// Mount AFTER a scenario's POS routes. Only the shared shell endpoints are
// handled here; all business requests fall through to that scenario's fixture.
// These presentation fixtures never grant permissions on the real API.
export async function installDashboardShell(
  page: Page,
  options: {
    read?: boolean;
    write?: boolean;
    storeId?: string;
    name?: string;
    authenticated?: boolean;
  } = {},
) {
  const storeId = options.storeId ?? 'store_1';
  const user = {
    id: 'staff_admin',
    email: 'admin@example.test',
    full_name: 'Quản trị Hiền',
    selected_locale: 'vi',
    stores: [{ id: storeId, name: options.name ?? 'Siêu thị Hiền', code: storeId }],
  };
  const store = {
    id: storeId,
    name: options.name ?? 'Siêu thị Hiền',
    code: storeId,
    default_currency: 'VND',
    default_locale: 'vi',
    admin_locale: 'vi',
    timezone: 'Asia/Ho_Chi_Minh',
    supported_currencies: ['VND'],
    supported_locales: ['vi', 'en'],
    available_locales: ['vi', 'en'],
  };
  let authenticated = options.authenticated ?? false;
  await page.addInitScript(() => localStorage.setItem('spree-admin-locale', 'vi'));
  await page.route('**/api/v3/admin/**', async (route) => {
    const path = new URL(route.request().url()).pathname.replace('/api/v3/admin', '');
    if (path === '/auth/login') {
      authenticated = true;
      return route.fulfill({ json: { token: 'presentation-fixture-only', user } });
    }
    if (path === '/auth/refresh') {
      return authenticated
        ? route.fulfill({ json: { token: 'presentation-fixture-only', user } })
        : route.fulfill({ status: 401, json: { error: { code: 'unauthorized' } } });
    }
    if (path === '/auth/logout') {
      authenticated = false;
      return route.fulfill({ status: 204 });
    }
    if (path === '/me') {
      return route.fulfill({
        json: {
          ...user,
          stores: [store],
          permissions: [],
          permission_keys: [
            ...(options.read !== false ? ['read_pos_topology'] : []),
            ...(options.write !== false ? ['write_pos_topology'] : []),
          ],
        },
      });
    }
    if (path === '/stores') return route.fulfill({ json: { data: [store] } });
    if (path === '/store' || path === `/stores/${storeId}`)
      return route.fulfill({ json: store });
    if (path === '/markets')
      return route.fulfill({ json: { data: [], meta: { next: null } } });
    return route.fallback();
  });
}
