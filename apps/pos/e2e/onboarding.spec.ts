import { expect, type Page, test } from '@playwright/test';

// A store with neither a profile nor an active branch is set up in the POS
// dashboard. The sale screen only says so: whoever may set the store up gets
// a link to the dashboard's setup wizard, everyone else is asked to find a
// store administrator. Presentation fixtures only: no real account privileges.

const staff = { id: 'staff_owner', full_name: 'Chủ cửa hàng', email: 'owner@example.test' };

async function installSetupApi(page: Page, canSetup: boolean) {
  const writes: string[] = [];
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname.replace(/^.*\/api\/v3\/admin/, '');
    const method = request.method();
    if (/\/auth\/(login|refresh)$/.test(path)) return route.fulfill({ json: { token: 'fixture-only' } });
    if (path === '/auth/logout') return route.fulfill({ json: {} });
    if (path === '/me') return route.fulfill({ json: { user: staff } });
    if (path === '/pos/context')
      return route.fulfill({
        json: {
          staff,
          store: { id: 'store_new', name: 'Cửa hàng mới', currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh' },
          administration: { read: canSetup, write: canSetup },
          capabilities: [],
          features: {},
          modules: {},
          module_usage: {},
          profile: null,
          onboarding: { required: true, can_setup: canSetup },
          branches: [],
          registers: [],
          shift: null,
          selection: { branch_id: null, register_id: null },
        },
      });
    if (method !== 'GET') writes.push(`${method} ${path}`);
    return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0, next: null } } });
  });
  return writes;
}

async function signIn(page: Page) {
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('owner@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('fixture-only');
  await page.getByRole('button', { name: 'Đăng nhập bán hàng', exact: true }).click();
  await expect(page.locator('.header-user')).toHaveText('Chủ cửa hàng');
}

test('a store not set up yet points whoever may set it up to the dashboard setup, without leaving the sale screen', async ({ page }) => {
  const writes = await installSetupApi(page, true);
  await signIn(page);
  const note = page.getByRole('status').filter({ hasText: 'Cửa hàng chưa được thiết lập POS.' });
  await expect(note).toBeVisible();
  const link = note.getByRole('link', { name: 'Mở trang thiết lập', exact: true });
  await expect(link).toHaveAttribute('href', /^https?:\/\/[^/]+(\/[^?#]*)?\/store_new\/setup$/);
  await expect(link).toHaveAttribute('target', '_blank');
  expect(new URL(page.url()).pathname).toBe('/');
  // No wizard in the POS and no branch picker over the note.
  await expect(page.getByRole('radiogroup')).toHaveCount(0);
  await expect(page.getByRole('dialog', { name: 'Chọn nơi bán hàng' })).toHaveCount(0);
  expect(writes).toEqual([]);
});

test('without the setup permission the branch picker asks for a store administrator and links nowhere', async ({ page }) => {
  const writes = await installSetupApi(page, false);
  await signIn(page);
  const picker = page.getByRole('dialog', { name: 'Chọn nơi bán hàng' });
  await expect(picker.getByRole('status').filter({ hasText: 'Chưa có chi nhánh.' })).toContainText(
    'Nhờ quản trị cửa hàng thiết lập POS.',
  );
  await expect(page.getByText('Cửa hàng chưa được thiết lập POS.')).toHaveCount(0);
  await expect(page.getByRole('link', { name: 'Mở trang thiết lập' })).toHaveCount(0);
  expect(writes).toEqual([]);
});
