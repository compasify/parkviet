import { expect, type Page, test } from '@playwright/test';
import { installDashboardShell } from './support/dashboard';
import { posContext } from './support/pos-context';

// Server information for store administrators: the address in pairing QR
// codes, TLS mode and the health rows. Presentation fixture only.
const healthy = {
  generated_at: '2026-11-11T10:00:00Z',
  version: { app: 'v1.2.3', spree: '6.0.3', rails: '8.1.1' },
  server: { public_base_url: 'http://192.168.1.10', tls_mode: 'none' },
  database: { ok: true, latency_ms: 1.2 },
  jobs: { ok: true, in_puma: true, processes: 1, ready: 0, oldest_ready_age_seconds: null, failed: 0 },
  realtime: { ok: true, adapter: 'solid_cable', probe_ms: 104.5, measured_at: '2026-11-11T10:00:00Z' },
  printing: { pending: 2, oldest_pending_age_seconds: 300, failed_last_24h: 0, failed_window_hours: 24 },
  outbound: { pending: 3, failed: 0, oldest_pending_age_seconds: 7200 },
  vietqr: { last_received_at: '2026-11-11T09:30:00Z', unmatched: 0 },
  backup: { configured: true, last_at: '2026-11-10T19:30:00Z', count: 14 },
};

async function install(page: Page, status: unknown, options: { read?: boolean; write?: boolean } = {}) {
  const calls: string[] = [];
  await page.route('**/api/v3/admin/**', async (route) => {
    const url = new URL(route.request().url());
    const path = url.pathname.replace('/api/v3/admin', '');
    if (path === '/pos/context') {
      return route.fulfill({ json: posContext(url, { capabilities: [], admin: options.read !== false }) });
    }
    if (path === '/pos/system_status') {
      calls.push(path);
      return route.fulfill({ json: { data: status } });
    }
    if (path.startsWith('/pos/')) return route.fulfill({ json: { data: [] } });
    return route.fallback();
  });
  await installDashboardShell(page, { authenticated: true, ...options });
  return calls;
}

test('shows the pairing address, TLS mode and healthy rows', async ({ page }) => {
  const calls = await install(page, healthy);
  await page.goto('/store_1/settings/system');

  await expect(page.getByRole('heading', { name: 'Thông tin server' })).toBeVisible();
  await expect(page.getByTestId('system-public-url')).toHaveText('http://192.168.1.10');
  await expect(page.getByText('HTTP trong mạng của quán')).toBeVisible();
  await expect(page.getByText('v1.2.3 · Spree 6.0.3 · Rails 8.1.1')).toBeVisible();
  await expect(page.getByTestId('system-realtime')).toContainText('104.5 ms');
  await expect(page.getByTestId('system-printing')).toContainText('2 lệnh chờ in, 0 lệnh lỗi trong 24 giờ qua.');
  await expect(page.getByTestId('system-outbound')).toContainText('3 việc chờ');
  await expect(page.getByTestId('system-outbound')).toContainText('Lâu nhất: 2 giờ.');
  await expect(page.getByTestId('system-backup')).toContainText('đang giữ 14 bản');
  for (const row of ['database', 'jobs', 'realtime', 'printing', 'outbound', 'vietqr', 'backup']) {
    await expect(page.getByTestId(`system-${row}`)).toContainText('Ổn');
  }

  const before = calls.length;
  await page.getByTestId('system-status-refresh').click();
  await expect.poll(() => calls.length).toBeGreaterThan(before);
});

test('flags what needs a look when the address is unset and work is stuck', async ({ page }) => {
  await install(page, {
    ...healthy,
    server: { public_base_url: null, tls_mode: 'unset' },
    jobs: { ok: false, in_puma: true, processes: 0, ready: 5, oldest_ready_age_seconds: 900, failed: 1 },
    printing: { ...healthy.printing, failed_last_24h: 4 },
    vietqr: { last_received_at: null, unmatched: 0 },
    backup: { configured: false, last_at: null, count: 0 },
  });
  await page.goto('/store_1/settings/system');

  await expect(page.getByTestId('system-public-url')).toContainText('Chưa đặt');
  await expect(page.getByText('Chưa đặt (POS_TLS_MODE)')).toBeVisible();
  await expect(page.getByTestId('system-jobs')).toContainText('Cần xem');
  await expect(page.getByTestId('system-printing')).toContainText('Cần xem');
  await expect(page.getByTestId('system-vietqr')).toContainText('xác nhận chuyển khoản bằng tay');
  await expect(page.getByTestId('system-backup')).toContainText('chưa có thư mục sao lưu');
  await expect(page.getByTestId('system-backup')).toContainText('Cần xem');
});

test('is listed in store settings for administrators', async ({ page }) => {
  await install(page, healthy);
  await page.goto('/store_1/settings');
  await page.getByRole('link', { name: 'Thông tin server' }).click();
  await expect(page).toHaveURL(/\/store_1\/settings\/system$/);
});

test('stays closed to staff without store administration', async ({ page }) => {
  const calls = await install(page, healthy, { read: false, write: false });
  await page.goto('/store_1/settings/system');

  await expect(page.getByText('Bạn không có quyền xem trang này.')).toBeVisible();
  expect(calls).toEqual([]);
});
