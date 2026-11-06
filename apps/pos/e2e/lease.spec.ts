import { expect, test } from '@playwright/test';

test('two browser pages cannot silently edit the same workspace', async ({ context }, testInfo) => {
  let editor: string | null = null;
  let generation = 0;
  const workspace = () => ({
    id: 'ws_1', branch_id: 'br_1', register_id: 'reg_1', shift_id: 'sh_1',
    order_id: 'R123', revision: 0, lease_generation: generation,
    operational_status: 'editing', payments: false,
  });
  await context.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname;
    const method = request.method();
    if (path.endsWith('/pos/context/branches')) return route.fulfill({ json: { data: [{ id: 'br_1', name: 'Branch', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } } });
    if (path.endsWith('/pos/context/registers')) return route.fulfill({ json: { data: [{ id: 'reg_1', branch_id: 'br_1', name: 'Register', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } } });
    if (path.endsWith('/auth/login') || path.endsWith('/auth/refresh')) {
      return route.fulfill({ json: { token: 'test-token' } });
    }
    if (path.endsWith('/me')) return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Lan' } } });
    if (path.endsWith('/pos/context')) {
      const branch = url.searchParams.get('branch_id');
      const register = url.searchParams.get('register_id');
      return route.fulfill({ json: {
        staff: { id: 'stf_1', email: 'staff@example.test', full_name: 'Lan' },
        store: { id: 'store_1', name: 'Test', currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh' },
        capabilities: branch ? ['pos.shift.open', 'pos.workspace.takeover'] : [],
        branches: [{ id: 'br_1', name: 'Branch', status: 'active' }],
        registers: branch ? [{ id: 'reg_1', branch_id: 'br_1', name: 'Register', status: 'active' }] : [],
        shift: register ? { id: 'sh_1', owner_id: 'stf_1', opening_float: '0', currency: 'VND' } : null,
        selection: { branch_id: branch, register_id: register },
      } });
    }
    if (path.endsWith('/pos/workspaces') && method === 'GET') {
      return route.fulfill({ json: { data: [workspace()], meta: { page: 1, pages: 1, count: 1 } } });
    }
    const body = request.postDataJSON() as { editor_id: string; takeover?: boolean; lease_generation?: number };
    if (path.endsWith('/ws_1/lease') && method === 'POST') {
      if (editor && editor !== body.editor_id && !body.takeover) {
        return route.fulfill({ status: 409, json: { error: { code: 'conflict' } } });
      }
      editor = body.editor_id;
      generation += 1;
      return route.fulfill({ json: { data: workspace() } });
    }
    if (path.endsWith('/ws_1/lease') && method === 'PATCH') {
      if (editor !== body.editor_id || body.lease_generation !== generation) {
        return route.fulfill({ status: 409, json: { error: { code: 'conflict' } } });
      }
      return route.fulfill({ json: { data: workspace() } });
    }
    if (path.endsWith('/ws_1/park') && method === 'POST') {
      if (editor !== body.editor_id || body.lease_generation !== generation) {
        return route.fulfill({ status: 409, json: { error: { code: 'conflict' } } });
      }
      return route.fulfill({ json: { data: { ...workspace(), operational_status: 'parked', revision: 1 } } });
    }
    return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
  });

  const first = await context.newPage();
  const second = await context.newPage();
  for (const page of [first, second]) {
    await page.goto('/pos/login');
    await page.getByLabel('Email nhân viên').fill('staff@example.test');
    await page.getByLabel('Mật khẩu', { exact: true }).fill('password');
    await page.getByRole('button', { name: 'Đăng nhập vào bán hàng', exact: true }).click();
    await expect(page.getByRole('tab', { name: 'Hóa đơn 1' })).toBeVisible();
  }
  await expect(first.getByRole('searchbox', { name: 'Tìm hàng hoặc quét mã' })).toBeVisible();
  await expect(first.getByRole('complementary', { name: 'Thông tin thanh toán' })).toBeVisible();
  expect(await first.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth)).toBe(true);
  await first.screenshot({ path: testInfo.outputPath('pos-layout.png'), fullPage: true });
  await first.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();
  await expect(first.getByRole('button', { name: 'Tạm giữ' })).toBeEnabled();
  const rejectedClaim = second.waitForResponse((response) => response.url().endsWith('/ws_1/lease') && response.request().method() === 'POST');
  await second.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();
  expect((await rejectedClaim).status()).toBe(409);
  await expect(second.getByRole('button', { name: 'Nhận quyền sửa', exact: true })).toBeEnabled();
  await expect(second.getByText('Có thao tác chưa rõ kết quả.', { exact: false })).toHaveCount(0);
  await expect(second.getByRole('button', { name: 'Tạm giữ' })).toBeDisabled();
  await second.getByRole('button', { name: 'Tiếp quản quyền sửa' }).click();
  await expect(second.getByRole('button', { name: 'Tạm giữ' })).toBeEnabled();
  await first.getByRole('button', { name: 'Tạm giữ' }).click();
  await expect(first.getByRole('button', { name: 'Tạm giữ' })).toBeDisabled();
});
