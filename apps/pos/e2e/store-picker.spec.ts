import { expect, type Page, test } from '@playwright/test';

const stores = [
  { id: 'st_retail', name: 'Bán lẻ', code: 'retail' },
  { id: 'st_food', name: 'Nhà hàng', code: 'food' },
];

async function mockApi(page: Page, stores: { id: string; name: string; code: string }[]) {
  const contextStores: (string | undefined)[] = [];
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname;
    const storeId = request.headers()['x-spree-store-id'];
    const store = stores.find((item) => item.id === storeId) ?? { id: 'st_default', name: 'Mặc định' };
    if (path.endsWith('/auth/login') || path.endsWith('/auth/refresh')) return route.fulfill({ json: { token: 'test-token' } });
    if (path.endsWith('/me')) return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Lan', stores } } });
    if (path.endsWith('/pos/context/branches')) return route.fulfill({ json: { data: [{ id: `br_${store.id}`, name: `Chi nhánh ${store.name}`, status: 'active' }], meta: { page: 1, pages: 1, count: 1 } } });
    if (path.endsWith('/pos/context/registers')) return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0 } } });
    if (path.endsWith('/pos/context')) {
      contextStores.push(storeId);
      return route.fulfill({ json: {
        staff: { id: 'stf_1', email: 'staff@example.test', full_name: 'Lan' },
        store: { id: store.id, name: store.name, currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh' },
        capabilities: [],
        branches: [{ id: `br_${store.id}`, name: `Chi nhánh ${store.name}`, status: 'active' }],
        registers: [],
        shift: null,
        selection: { branch_id: url.searchParams.get('branch_id'), register_id: null },
      } });
    }
    return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
  });
  return contextStores;
}

async function signIn(page: Page) {
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('password');
  await page.getByRole('button', { name: 'Đăng nhập bán hàng', exact: true }).click();
}

test('a cashier of several stores picks the store the register sells for', async ({ page }) => {
  const contextStores = await mockApi(page, stores);
  await signIn(page);

  await expect(page.getByRole('heading', { name: 'Chọn cửa hàng' })).toBeVisible();
  expect(contextStores).toEqual([]);
  await page.getByRole('button', { name: 'Nhà hàng' }).click();

  await page.locator('.pos-context-details > summary').click();
  await expect(page.locator('.context-store')).toContainText('Nhà hàng');
  expect(contextStores.length).toBeGreaterThan(0);
  expect(new Set(contextStores)).toEqual(new Set(['st_food']));

  await page.getByRole('button', { name: 'Đổi cửa hàng' }).click();
  await expect(page.getByRole('button', { name: /Nhà hàng/ })).toHaveAttribute('aria-current', 'true');
  contextStores.length = 0;
  await page.getByRole('button', { name: 'Bán lẻ' }).click();
  await page.locator('.pos-context-details > summary').click();
  await expect(page.locator('.context-store')).toContainText('Bán lẻ');
  expect(new Set(contextStores)).toEqual(new Set(['st_retail']));

  contextStores.length = 0;
  await page.reload();
  await page.locator('.pos-context-details > summary').click();
  await expect(page.locator('.context-store')).toContainText('Bán lẻ');
  expect(new Set(contextStores)).toEqual(new Set(['st_retail']));
});

test('a cashier of a single store never sees the store picker', async ({ page }) => {
  await mockApi(page, stores.slice(0, 1));
  await signIn(page);
  await expect(page.locator('.pos-context-details > summary')).toContainText('Bán lẻ');
  await page.goto('/store');
  await expect(page).toHaveURL(/\/$/);
  await expect(page.getByRole('heading', { name: 'Chọn cửa hàng' })).toHaveCount(0);
  await page.locator('.pos-context-details > summary').click();
  await expect(page.getByRole('button', { name: 'Đổi cửa hàng' })).toHaveCount(0);
});
