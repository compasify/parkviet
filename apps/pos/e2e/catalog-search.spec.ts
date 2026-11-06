import { expect, test } from '@playwright/test';

test('catalog search is scoped to the selected branch and remains read-only', async ({ page }) => {
  await page.route('**/api/v3/admin/**', async (route) => {
    const url = new URL(route.request().url());
    const path = url.pathname;
    if (path.endsWith('/pos/context/branches')) return route.fulfill({ json: { data: [{ id: 'br_1', name: 'Branch', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } } });
    if (path.endsWith('/pos/context/registers')) return route.fulfill({ json: { data: [], meta: { page: 1, pages: 0, count: 0 } } });
    if (path.endsWith('/auth/login') || path.endsWith('/auth/refresh')) return route.fulfill({ json: { token: 'test-token' } });
    if (path.endsWith('/me')) return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Lan' } } });
    if (path.endsWith('/pos/context')) {
      const branch = url.searchParams.get('branch_id');
      return route.fulfill({ json: {
        staff: { id: 'stf_1', email: 'staff@example.test', full_name: 'Lan' },
        store: { id: 'store_1', name: 'Test', currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh' },
        capabilities: [], branches: [{ id: 'br_1', name: 'Branch', status: 'active' }], registers: [], shift: null,
        selection: { branch_id: branch, register_id: null },
      } });
    }
    if (path.endsWith('/pos/catalog')) {
      expect(url.searchParams.get('branch_id')).toBe('br_1');
      expect(['', 'ao']).toContain(url.searchParams.get('q'));
      return route.fulfill({ json: { data: [
        { id: 'variant_1', product_id: 'prod_1', name: 'Áo xanh', sku: 'AO', barcode: '123', price: '100.0', compare_at_price: '120.0', currency: 'VND', stock_on_hand: 3 },
        { id: 'variant_2', product_id: 'prod_2', name: 'Áo đỏ', sku: 'DO', barcode: null, price: '90.0', compare_at_price: null, currency: 'VND', stock_on_hand: null },
      ], meta: { page: 1, pages: 1, count: 1, ambiguous: false } } });
    }
    return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
  });
  await page.goto('/pos/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('password');
  await page.getByRole('button', { name: 'Đăng nhập vào bán hàng', exact: true }).click();
  await expect(page.locator('.pos-context-details > summary')).toContainText('Branch');
  await page.getByRole('searchbox', { name: 'Tìm hàng hoặc quét mã' }).fill('ao');
  await page.getByRole('button', { name: 'Tìm hàng', exact: true }).click();
  const product = page.getByRole('list', { name: 'Kết quả tìm hàng' }).locator('li').first();
  await expect(product).toContainText('100 ₫');
  await expect(product.locator('del')).toHaveText('120 ₫');
  await expect(product.locator('.catalog-meta')).toHaveText('AO · Tồn kho: 3');
  await expect(page.getByText('Tồn kho: chưa rõ')).toBeVisible();
  await page.getByRole('button', { name: 'Danh sách', exact: true }).click();
  await expect(page.getByRole('list', { name: 'Kết quả tìm hàng' })).toHaveClass(/catalog-results--list/);
  const thumbBox = await product.locator('.catalog-image').boundingBox();
  expect(thumbBox).toMatchObject({ width: 30, height: 30 });
  await page.getByRole('button', { name: 'Thẻ', exact: true }).click();
  await expect(page.getByRole('list', { name: 'Kết quả tìm hàng' })).toHaveClass(/catalog-results--cards/);
  await expect(page.getByText('Tồn thực tế không bảo đảm', { exact: false })).toHaveCount(0);
  await expect(page.getByRole('complementary', { name: 'Thông tin thanh toán' })).toContainText('Chọn đơn');
});
