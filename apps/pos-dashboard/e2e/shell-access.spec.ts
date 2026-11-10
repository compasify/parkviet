import { expect, type Page, test } from '@playwright/test';
import { installDashboardShell } from './support/dashboard';

async function installContext(
  page: Page,
  role: 'owner' | 'reader' | 'manager' | 'none',
  authenticated = true,
  channelStatus: 'active' | 'missing' | 'inactive' = 'active',
) {
  const requests: { path: string; store: string | undefined }[] = [];
  await page.route('**/api/v3/admin/pos/**', async (route) => {
    const url = new URL(route.request().url());
    requests.push({
      path: url.pathname,
      store: route.request().headers()['x-spree-store-id'],
    });
    if (url.pathname.endsWith('/context')) {
      return route.fulfill({
        json: {
          sales_channel: { id: channelStatus === 'missing' ? null : 'ch_pos', code: 'pos', name: 'POS', status: channelStatus },
          staff: { id: 'staff_admin', email: 'admin@example.test', full_name: 'Quản trị Hiền' },
          store: { id: 'store_1', name: 'Siêu thị Hiền', currency: 'VND', timezone: 'Asia/Ho_Chi_Minh' },
          administration: { read: role === 'owner' || role === 'reader', write: role === 'owner' },
          capabilities: role === 'manager' ? ['pos.topology.manage'] : [],
          branches: [{
            id: 'branch_main', name: 'Chi nhánh chính', code: 'main', status: 'active',
            timezone: 'Asia/Ho_Chi_Minh', stock_location_id: 'stock_main',
            receiving_stock_location_id: null, receiving_note: null,
          }],
          registers: [], shift: null,
          selection: { branch_id: url.searchParams.get('branch_id'), register_id: null },
        },
      });
    }
    if (url.pathname.endsWith('/feature_flags')) {
      return route.fulfill({ json: { data: {
        branch_id: 'branch_main', features: {}, store_defaults: {}, settings: [],
      } } });
    }
    return route.fulfill({ json: { data: [], meta: { next: null } } });
  });
  await installDashboardShell(page, {
    authenticated,
    read: role === 'owner' || role === 'reader',
    write: role === 'owner',
  });
  return requests;
}

for (const status of ['missing', 'inactive'] as const) {
  test(`channel ${status} shows setup guidance without blocking administration`, async ({ page }) => {
    await installContext(page, 'owner', true, status);
    await page.goto('/store_1/branches');
    await expect(page.getByRole('heading', { name: 'Chi nhánh', exact: true })).toBeVisible();
    await expect(page.getByRole('status').filter({ hasText: status === 'missing' ? 'Chưa có kênh POS' : 'Kênh POS đã ngừng hoạt động' })).toBeVisible();
    await expect(page.getByRole('status').filter({ hasText: 'Kênh bán hàng' })).toContainText('mã pos');
  });
}

test('protected URLs require a dashboard session', async ({ page }) => {
  await installDashboardShell(page);
  await page.goto('/store_1/features');
  await expect(page).toHaveURL(/\/login(?:\?|$)/);
  await expect(page.locator('input[type="email"]')).toBeVisible();
  await expect(page.locator('input[type="password"]')).toBeVisible();
});

test('admin sign-in survives a reload and sign-out clears the protected session', async ({ page }) => {
  await installContext(page, 'owner', false);
  const errors: string[] = [];
  page.on('pageerror', (error) => errors.push(error.message));
  await page.goto('/login');
  await page.locator('input[type="email"]').fill('admin@example.test');
  await page.locator('input[type="password"]').fill('presentation-fixture-only');
  await page.locator('form button[type="submit"]').click();
  await expect(page).toHaveURL(/\/store_1(?:\/|$)/);
  await page.goto('/store_1/branches');
  await expect(page.getByRole('heading', { name: 'Chi nhánh', exact: true })).toBeVisible();
  await page.reload();
  await expect(page.getByRole('heading', { name: 'Chi nhánh', exact: true })).toBeVisible();
  await page.getByRole('button', { name: /User menu|Trình đơn người dùng/, exact: true }).click();
  await page.getByRole('menuitem', { name: /Log out|Đăng xuất/, exact: true }).click();
  await expect(page).toHaveURL(/\/login(?:\?|$)/);
  await page.goto('/store_1/branches');
  await expect(page).toHaveURL(/\/login(?:\?|$)/);
  expect(errors).toEqual([]);
});

test('an account without POS permissions cannot open topology directly', async ({ page }) => {
  await installContext(page, 'none');
  await page.goto('/store_1/branches');
  await expect(page.getByRole('heading', { name: 'Không có quyền truy cập', exact: true })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Thêm chi nhánh', exact: true })).toHaveCount(0);
});

test('a branch manager cannot open store administration directly', async ({ page }) => {
  await installContext(page, 'manager');
  await page.goto('/store_1/branches?branch=branch_main');
  await expect(page.getByRole('heading', { name: 'Không có quyền truy cập', exact: true })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Thêm chi nhánh', exact: true })).toHaveCount(0);
});

test('read-only topology has no create action and requests use the route store', async ({ page }) => {
  const requests = await installContext(page, 'reader');
  await page.goto('/store_1/branches');
  await expect(page.getByRole('heading', { name: 'Chi nhánh', exact: true })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Thêm chi nhánh', exact: true })).toHaveCount(0);
  expect(requests.length).toBeGreaterThan(0);
  expect(requests.every((request) => request.store === 'store_1')).toBe(true);
});
