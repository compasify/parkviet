import { expect, test } from '@playwright/test';

test('reload restores the selected draft and page from the server without restoring the lease', async ({ page }) => {
  let releaseCreate: () => void = () => {};
  let movedDraft = false;
  let receiptAvailable = false;
  const createGate = new Promise<void>((resolve) => { releaseCreate = resolve; });
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname;
    if (path.endsWith('/pos/context/branches')) return route.fulfill({ json: { data: [{ id: 'br_1', name: 'Branch', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } } });
    if (path.endsWith('/pos/context/registers')) return route.fulfill({ json: { data: [{ id: 'reg_1', branch_id: 'br_1', name: 'Register', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } } });
    if (path.endsWith('/auth/login') || path.endsWith('/auth/refresh')) return route.fulfill({ json: { token: 'test-token' } });
    if (path.endsWith('/me')) return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Lan' } } });
    if (path.endsWith('/pos/context')) {
      const branch = url.searchParams.get('branch_id');
      const register = url.searchParams.get('register_id');
      return route.fulfill({ json: {
        staff: { id: 'stf_1', email: 'staff@example.test', full_name: 'Lan' },
        store: { id: 'store_1', name: 'Test', currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh' },
        capabilities: branch ? ['pos.shift.open'] : [],
        branches: [{ id: 'br_1', name: 'Branch', status: 'active' }],
        registers: branch ? [{ id: 'reg_1', branch_id: 'br_1', name: 'Register', status: 'active' }] : [],
        shift: register ? { id: 'sh_1', register_id: 'reg_1', owner_id: 'stf_1', opening_float: '0', currency: 'VND' } : null,
        selection: { branch_id: branch, register_id: register },
      } });
    }
    if (path.endsWith('/pos/workspaces') && request.method() === 'GET') {
      const currentPage = Number(url.searchParams.get('page') ?? '1');
      const ids = currentPage === 1 ? ['A1', 'A2'] : movedDraft ? ['B1', 'B3'] : ['B1', 'B2'];
      return route.fulfill({ json: {
        data: ids.map((id) => ({ id: `ws_${id}`, branch_id: 'br_1', register_id: 'reg_1', shift_id: 'sh_1', order_id: id, revision: 0, lease_generation: 1, operational_status: 'editing', payments: false })),
        meta: { page: currentPage, pages: 2, count: 4 },
      } });
    }
    if (path.endsWith('/pos/workspaces/ws_B2') && request.method() === 'GET') {
      return route.fulfill({ json: { data: { id: 'ws_B2', branch_id: 'br_1', register_id: 'reg_1', shift_id: 'sh_1', order_id: 'B2', revision: 2, lease_generation: 1, operational_status: 'parked', payments: false } } });
    }
    if (path.endsWith('/pos/command_receipts')) {
      return receiptAvailable
        ? route.fulfill({ json: { data: { id: 'ws_recovered' } } })
        : route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
    }
    if (path.endsWith('/pos/workspaces') && request.method() === 'POST') {
      await createGate;
      return route.fulfill({ json: { data: { id: 'ws_new', order_id: 'NEW', branch_id: 'br_1', register_id: 'reg_1', shift_id: 'sh_1', revision: 0, lease_generation: 1, operational_status: 'editing', payments: false } } });
    }
    return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
  });
  await page.goto('/pos/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('password');
  await page.getByRole('button', { name: 'Đăng nhập vào bán hàng', exact: true }).click();
  const workspace = page.getByRole('region', { name: 'Đơn nháp trên quầy này' });
  await expect(workspace.locator('[role="tab"][data-workspace-id="ws_A1"]')).toBeVisible();
  const createStarted = page.waitForRequest((request) => request.url().endsWith('/pos/workspaces') && request.method() === 'POST');
  await workspace.getByRole('button', { name: 'Đơn nháp mới' }).click();
  await createStarted;
  await workspace.locator('[role="tab"][data-workspace-id="ws_A2"]').click();
  const createFinished = page.waitForResponse((response) => response.url().endsWith('/pos/workspaces') && response.request().method() === 'POST');
  releaseCreate();
  await createFinished;
  await expect(workspace.locator('[role="tab"][data-workspace-id="ws_A2"]')).toHaveAttribute('aria-selected', 'true');
  await workspace.getByRole('button', { name: 'Trang sau' }).click();
  await workspace.locator('[role="tab"][data-workspace-id="ws_B2"]').click();
  await expect(workspace.locator('[role="tab"][data-workspace-id="ws_B2"]')).toHaveAttribute('aria-selected', 'true');
  movedDraft = true;
  await page.reload();
  await page.locator('.pos-context-details > summary').click();
  await expect(page.getByRole('combobox', { name: 'Quầy' })).toHaveValue('reg_1');
  await expect(workspace.locator('[role="tab"][data-workspace-id="ws_B2"]')).toHaveAttribute('aria-selected', 'true');
  await expect(workspace.locator('[role="tab"][data-workspace-id="ws_B2"]')).toHaveAttribute('title', 'Tạm giữ');
  await expect(workspace.getByRole('button', { name: 'Mở lại đơn' })).toBeDisabled();
  await page.locator('.pos-context-details > summary').click();
  await workspace.locator('.order-more > summary').click();
  await workspace.getByRole('button', { name: 'Đóng tab' }).click();
  await expect(workspace.locator('[role="tab"][data-workspace-id="ws_B2"]')).toHaveCount(0);
  await page.reload();
  await expect(workspace.getByRole('button', { name: 'Hiện lại các đơn đã đóng giao diện' })).toBeVisible();
  await expect(workspace.locator('[role="tab"][data-workspace-id="ws_B2"]')).toHaveCount(0);
  await workspace.getByRole('button', { name: 'Hiện lại các đơn đã đóng giao diện' }).click();
  await page.evaluate(() => {
    const scope = JSON.stringify(['stf_1', 'store_1', 'register:reg_1', '/pos/workspaces', '{}']);
    sessionStorage.setItem('parkviet-pos-uncertain-intents', JSON.stringify({ [scope]: { key: crypto.randomUUID(), savedAt: Date.now() } }));
    window.dispatchEvent(new Event('pos:uncertain-intents-changed'));
  });
  const warning = page.getByText('Có thao tác chưa rõ kết quả.', { exact: false });
  await expect(warning).toBeVisible();
  expect(await page.evaluate(() => {
    const event = new Event('beforeunload', { cancelable: true });
    window.dispatchEvent(event);
    return event.defaultPrevented;
  })).toBe(true);
  page.once('dialog', (dialog) => dialog.accept());
  await page.reload();
  await expect(warning).toBeVisible();
  page.once('dialog', (dialog) => dialog.dismiss());
  await page.locator('.pos-context-details > summary').click();
  await page.getByRole('button', { name: 'Đăng xuất' }).click();
  await expect(warning).toBeVisible();
  await page.locator('.pos-context-details > summary').click();
  await page.getByRole('button', { name: 'Kiểm tra kết quả thao tác' }).click();
  await expect(warning).toBeVisible();
  await expect(page.getByRole('button', { name: 'Kiểm tra kết quả thao tác' })).toBeEnabled();
  receiptAvailable = true;
  await page.getByRole('button', { name: 'Kiểm tra kết quả thao tác' }).click();
  await expect(warning).toHaveCount(0);
});
