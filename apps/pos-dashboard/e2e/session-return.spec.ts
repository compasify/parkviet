import { expect, type Page, test } from '@playwright/test';
import { DEFAULT_TEMPLATES } from '@parkviet/pos-shared/receipt-template/defaults';
import { installDashboardShell } from './support/dashboard';

// Presentation fixtures only: they never touch or grant access on the real API.
const staff = { id: 'staff_admin', email: 'admin@example.test', full_name: 'Quản trị Hiền' };
const branch = {
  id: 'branch_main', name: 'Chi nhánh chính', code: 'main', status: 'active',
  timezone: 'Asia/Ho_Chi_Minh', stock_location_id: 'stock_main',
  receiving_stock_location_id: null, receiving_note: null, return_window_days: 7,
};
const template = {
  id: 'postpl_1', document_type: 'sale', name: 'Phiếu bán hàng', paper: '80mm', status: 'active',
  is_default: true, current_version: 1, version: 1, updated_at: '2026-11-08T02:00:00Z',
  created_at: '2026-11-08T02:00:00Z', config: DEFAULT_TEMPLATES.sale,
  updated_by: { id: staff.id, name: staff.full_name },
};

async function install(page: Page, authenticated: boolean) {
  await page.route('**/api/v3/admin/pos/**', async (route) => {
    const url = new URL(route.request().url());
    const path = url.pathname.replace('/api/v3/admin', '');
    if (path === '/pos/context') {
      return route.fulfill({
        json: {
          staff,
          store: { id: 'store_1', name: 'Siêu thị Hiền', currency: 'VND', timezone: 'Asia/Ho_Chi_Minh' },
          administration: { read: true, write: true },
          capabilities: [], branches: [branch], registers: [], shift: null,
          selection: { branch_id: url.searchParams.get('branch_id'), register_id: null },
        },
      });
    }
    if (path === '/pos/branches') return route.fulfill({ json: { data: [branch], meta: { next: null } } });
    if (path === `/pos/receipt_templates/${template.id}`) return route.fulfill({ json: { data: template } });
    if (path === '/pos/receipt_templates') return route.fulfill({ json: { data: [template] } });
    return route.fulfill({ json: { data: [], meta: { next: null } } });
  });
  // Shell is last so only shell requests are consumed before POS fixtures.
  await installDashboardShell(page, { authenticated });
}

async function signIn(page: Page) {
  await expect(page).toHaveURL(/\/login\?/);
  await page.locator('input[type="email"]').fill('admin@example.test');
  await page.locator('input[type="password"]').fill('presentation-fixture-only');
  await page.locator('form button[type="submit"]').click();
}

test('a signed-out visit to a deep URL returns there after sign-in', async ({ page }) => {
  await install(page, false);
  const target = '/store_1/settings/receipt-templates/postpl_1?branch=branch_main';
  await page.goto(target);
  await signIn(page);
  await expect(page).toHaveURL((url) => url.pathname + url.search === target);
  await expect(page.getByLabel('Tên mẫu')).toHaveValue('Phiếu bán hàng');
});

test('an off-site redirect target is ignored', async ({ page }) => {
  await install(page, false);
  await page.goto(`/login?redirect=${encodeURIComponent('//evil.test/phish')}`);
  await page.locator('input[type="email"]').fill('admin@example.test');
  await page.locator('input[type="password"]').fill('presentation-fixture-only');
  await page.locator('form button[type="submit"]').click();
  await expect(page).toHaveURL(/^http:\/\/localhost:5176\/store_1(?:\/|$)/);
});

test('unsaved template edits survive losing the session', async ({ page }) => {
  await install(page, true);
  const target = '/store_1/settings/receipt-templates/postpl_1';
  await page.goto(target);
  const name = page.getByLabel('Tên mẫu');
  await expect(name).toHaveValue('Phiếu bán hàng');
  await name.fill('Phiếu bán hàng (nháp)');
  await expect(page.getByText('Chưa lưu', { exact: true })).toBeVisible();
  // End the session server-side, then reload: the refresh cookie no longer
  // works, so the app falls back to sign-in. Accept the unsaved-changes prompt.
  await page.evaluate(() => fetch('/api/v3/admin/auth/logout', { method: 'POST' }));
  page.once('dialog', (dialog) => void dialog.accept());
  await page.reload();
  await signIn(page);
  await expect(page).toHaveURL((url) => url.pathname === target);
  await expect(page.getByLabel('Tên mẫu')).toHaveValue('Phiếu bán hàng (nháp)');
  await expect(page.getByRole('status').filter({ hasText: 'Đã khôi phục bản nháp' })).toBeVisible();
  await expect(page.getByText('Chưa lưu', { exact: true })).toBeVisible();
});
