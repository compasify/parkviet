import { expect, type Page, test } from '@playwright/test';
import { picker, pickOption } from './support/searchable-select';

async function install(page: Page, branchCount: number, registerCounts: number[], optionsError = false) {
  const branches = Array.from({ length: branchCount }, (_, i) => ({ id: `br_${i + 1}`, name: `Chi nhánh ${i + 1}`, status: 'active' }));
  const registers = (branchId: string | null) => Array.from({ length: branchId ? registerCounts[Number(branchId.split('_')[1]) - 1] : 0 }, (_, i) => ({ id: `${branchId}_reg_${i + 1}`, branch_id: branchId, name: `Quầy ${i + 1}`, status: 'active' }));
  const state = { writes: [] as { path: string; body: Record<string, unknown> }[], shift: null as Record<string, unknown> | null, workspaces: [] as Record<string, unknown>[], next: 0 };
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname;
    const method = request.method();
    if (/\/auth\/(login|refresh)$/.test(path)) return route.fulfill({ json: { token: 'context-fixture' } });
    if (path.endsWith('/me')) return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Thu ngân' } } });
    if (path.endsWith('/pos/context')) {
      const branchId = url.searchParams.get('branch_id');
      const registerId = url.searchParams.get('register_id');
      return route.fulfill({ json: { staff: { id: 'staff_1', email: 'staff@example.test', full_name: 'Thu ngân' }, store: { id: 'store_1', currency: 'VND' },
        branches, registers: registers(branchId), capabilities: ['pos.shift.open'],
        selection: { branch_id: branchId, register_id: registerId }, shift: state.shift,
      } });
    }
    if (path.endsWith('/pos/context/branches') || path.endsWith('/pos/context/registers')) {
      if (optionsError) return route.fulfill({ status: 403, json: { error: { code: 'access_denied' } } });
      const rows = path.endsWith('/branches') ? branches : registers(url.searchParams.get('branch_id'));
      return route.fulfill({ json: { data: rows, meta: { page: 1, pages: rows.length ? 1 : 0, count: rows.length } } });
    }
    if (method !== 'GET') state.writes.push({ path, body: request.postDataJSON() });
    if (path.endsWith('/pos/shifts') && method === 'POST') {
      const body = request.postDataJSON();
      state.shift = { id: 'shift_1', branch_id: body.branch_id || 'br_1', register_id: body.register_id || null, owner_id: 'staff_1', status: 'open', currency: 'VND', opening_float: body.opening_float };
      return route.fulfill({ json: { data: state.shift } });
    }
    if (path.endsWith('/pos/workspaces')) {
      if (method === 'GET') return route.fulfill({ json: { data: [...state.workspaces].reverse(), meta: { page: 1, pages: 1, count: state.workspaces.length } } });
      const body = request.postDataJSON();
      const row = { id: `ws_${++state.next}`, order_id: `or_private_${state.next}`, branch_id: body.branch_id || 'br_1', register_id: body.register_id || null, shift_id: 'shift_1', operational_status: 'editing', revision: 0, lease_generation: 1, payments: false, line_items: [] };
      state.workspaces.push(row);
      return route.fulfill({ json: { data: row } });
    }
    const id = path.match(/\/workspaces\/(ws_\d+)/)?.[1];
    if (id) return route.fulfill({ json: { data: state.workspaces.find((row) => row.id === id) } });
    return route.fulfill({ json: { data: [], meta: { page: 1, pages: 0, count: 0 } } });
  });
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('fixture-only');
  await page.getByRole('button', { name: 'Đăng nhập vào bán hàng', exact: true }).click();
  return state;
}

test('sole branch and sole register are selected without any popup or write', async ({ page }) => {
  const state = await install(page, 1, [1]);
  await expect(page.locator('.pos-context-details > summary')).toContainText('Quầy 1');
  await expect(page.getByRole('dialog')).toHaveCount(0);
  await page.locator('.pos-context-details > summary').click();
  await expect(picker(page, 'Chi nhánh')).toHaveAttribute('data-value', 'br_1');
  await expect(picker(page, 'Quầy')).toHaveAttribute('data-value', 'br_1_reg_1');
  expect(state.writes).toEqual([]);
});

test('multiple branches prompt once; sole register auto-selects after choosing branch', async ({ page }, testInfo) => {
  const state = await install(page, 2, [1, 1]);
  const dialog = page.getByRole('dialog', { name: 'Chọn nơi bán hàng' });
  await expect(dialog).toBeVisible();
  await page.screenshot({ path: testInfo.outputPath('context-choice.png'), fullPage: true });
  await pickOption(dialog, 'Chi nhánh', 'br_2');
  await expect(dialog).not.toBeVisible();
  await expect(page.locator('.pos-context-details > summary')).toContainText('Chi nhánh 2');
  await expect(page.locator('.pos-context-details > summary')).toContainText('Quầy 1');
  expect(state.writes).toEqual([]);
});

test('sole branch and multiple registers prompt only for the remaining choice', async ({ page }) => {
  await install(page, 1, [2]);
  const dialog = page.getByRole('dialog');
  await expect(dialog).toBeVisible();
  await expect(picker(dialog, 'Chi nhánh')).toHaveAttribute('data-value', 'br_1');
  await pickOption(dialog, 'Quầy', 'br_1_reg_2');
  await expect(dialog).not.toBeVisible();
  await page.reload();
  await expect(page.locator('.pos-context-details > summary')).toContainText('Quầy 2');
  await expect(page.getByRole('dialog')).toHaveCount(0);
});

test('no-register branch hides the control and supports a real-shaped branch shift and invoice commands', async ({ page }, testInfo) => {
  const state = await install(page, 1, [0]);
  await expect(page.getByRole('button', { name: 'Mở ca', exact: true })).toBeVisible();
  await expect(page.getByRole('dialog')).toHaveCount(0);
  await page.locator('.pos-context-details > summary').click();
  await expect(page.getByRole('combobox', { name: 'Quầy', exact: true })).toHaveCount(0);
  await page.keyboard.press('Escape');
  await page.getByRole('button', { name: 'Mở ca', exact: true }).click();
  await expect(page.getByRole('button', { name: 'Đơn nháp mới' })).toBeEnabled();
  for (let i = 1; i <= 3; i++) {
    await page.getByRole('button', { name: 'Đơn nháp mới' }).click();
    await expect(page.getByRole('tab', { name: `Hóa đơn ${i}`, exact: true })).toHaveAttribute('aria-selected', 'true');
  }
  await expect(page.getByRole('tablist')).not.toContainText('or_private');
  const firstLabels = await page.getByRole('tab').allTextContents();
  await page.getByRole('tab', { name: 'Hóa đơn 2', exact: true }).click();
  await page.locator('.order-more > summary').click();
  await page.getByRole('button', { name: 'Đóng tab', exact: true }).click();
  await page.getByRole('button', { name: 'Đơn nháp mới' }).click();
  await expect(page.getByRole('tab', { name: 'Hóa đơn 4', exact: true })).toBeVisible();
  await expect(page.getByRole('tab', { name: 'Hóa đơn 1', exact: true })).toBeVisible();
  await expect(page.getByRole('tab', { name: 'Hóa đơn 3', exact: true })).toBeVisible();
  await page.reload();
  await expect(page.getByRole('tab', { name: 'Hóa đơn 4', exact: true })).toHaveAttribute('aria-selected', 'true');
  const readOnlyNotice = page.locator('.lease-notice');
  await expect(readOnlyNotice).toBeVisible();
  expect(await readOnlyNotice.evaluate((el) => el.getBoundingClientRect().height)).toBeLessThanOrEqual(52);
  const claimButton = readOnlyNotice.getByRole('button', { name: 'Nhận quyền sửa', exact: true });
  expect(await claimButton.evaluate((el) => el.getBoundingClientRect().height)).toBeGreaterThanOrEqual(32);
  expect(await claimButton.evaluate((el) => el.getBoundingClientRect().height)).toBeLessThanOrEqual(36);
  expect(await claimButton.evaluate((el) => getComputedStyle(el).fontSize)).toBe(await page.getByRole('button', { name: 'Đơn nháp mới' }).evaluate((el) => getComputedStyle(el).fontSize));
  const explanation = readOnlyNotice.getByText('Mỗi hóa đơn chỉ cho một tab hoặc máy', { exact: false });
  await expect(explanation).not.toBeVisible();
  await readOnlyNotice.locator('.lease-help > summary').click();
  await expect(explanation).toBeVisible();
  await expect(readOnlyNotice).toContainText('Thông báo này không có nghĩa là tài khoản của bạn bị mất quyền.');
  await expect(readOnlyNotice).toContainText('Bấm “Nhận quyền sửa” để tiếp tục.');
  await page.screenshot({ path: testInfo.outputPath('read-only-explanation.png'), fullPage: true });
  await readOnlyNotice.locator('.lease-help > summary').click();
  await expect(explanation).not.toBeVisible();
  await expect.poll(() => page.getByRole('tablist').evaluate((list) => {
    const selected = list.querySelector('[aria-selected="true"]');
    if (!selected) return false;
    const bounds = list.getBoundingClientRect();
    const tab = selected.getBoundingClientRect();
    return tab.left >= bounds.left - 1 && tab.right <= bounds.right + 1;
  })).toBe(true);
  expect(firstLabels.map((value) => value.trim())).toEqual(['Hóa đơn 1', 'Hóa đơn 2', 'Hóa đơn 3']);
  expect(state.writes.find((write) => write.path.endsWith('/shifts'))?.body).toEqual({ branch_id: 'br_1', opening_float: '0' });
  const creates = state.writes.filter((write) => write.path.endsWith('/workspaces'));
  expect(creates).toHaveLength(4);
  for (const write of creates) {
    expect(write.body.branch_id).toBe('br_1');
    expect(write.body.register_id).toBeUndefined();
    expect(write.body.editor_id).toBeTruthy();
    expect(write.body.idempotency_key).toBeTruthy();
  }
  expect(await page.locator('.header').evaluate((el) => el.getBoundingClientRect().height)).toBeLessThanOrEqual(56);
  expect(await page.getByRole('tab').first().evaluate((el) => el.getBoundingClientRect().height)).toBeLessThanOrEqual(46);
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  await page.screenshot({ path: testInfo.outputPath('compact-header-tabs.png'), fullPage: true });
});

test('failed option requests cannot become a branch-only selling session', async ({ page }) => {
  const state = await install(page, 1, [0], true);
  await expect(page.getByRole('dialog')).toBeVisible();
  await expect(page.getByRole('dialog').getByRole('alert')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Mở ca', exact: true })).toHaveCount(0);
  await expect(page.getByRole('button', { name: 'Đơn nháp mới' })).toBeDisabled();
  expect(state.writes).toEqual([]);
});

test('recovery check explains missing, denied and failed lookups, retaining evidence until confirmed', async ({ page }) => {
  const state = await install(page, 1, [0]);
  await expect(page.getByRole('button', { name: 'Mở ca', exact: true })).toBeVisible();
  let status = 404;
  const lookups: string[] = [];
  await page.route('**/pos/command_receipts?*', (route) => {
    lookups.push(new URL(route.request().url()).searchParams.get('idempotency_key') ?? '');
    return route.fulfill({ status, json: status === 200 ? { data: { id: 'ws_1' } } : { error: { code: 'lookup_error' } } });
  });
  await page.evaluate(() => {
    const scope = JSON.stringify(['staff_1', 'store_1', 'ws_1', '/pos/workspaces/ws_1/lease', '{}']);
    sessionStorage.setItem('parkviet-pos-uncertain-intents', JSON.stringify({ [scope]: { key: 'original-key', savedAt: Date.now() } }));
    window.dispatchEvent(new Event('pos:uncertain-intents-changed'));
  });
  const check = page.getByRole('button', { name: 'Kiểm tra kết quả thao tác', exact: true });
  const result = page.locator('.recovery-check-result');
  for (const [code, message] of [[404, 'chưa tìm thấy kết quả'], [403, 'quyền truy cập'], [503, 'lỗi kết nối hoặc máy chủ']] as const) {
    status = code;
    await check.click();
    await expect(result).toContainText(message);
    await expect(check).toBeEnabled();
    expect(await page.evaluate(() => Object.keys(JSON.parse(sessionStorage.getItem('parkviet-pos-uncertain-intents') ?? '{}')).length)).toBe(1);
  }
  status = 200;
  await check.click();
  await expect(result).toContainText('Đã xác minh 1 thao tác');
  await expect(check).toHaveCount(0);
  // Read-only SDK retries on 503 are allowed, but may never mint a replacement key.
  expect(lookups.length).toBeGreaterThanOrEqual(4);
  expect([...new Set(lookups)]).toEqual(['original-key']);
  expect(state.writes).toEqual([]);
});

test('reload lease conflict waits without repeated reloads, then claims and keeps editing', async ({ page }) => {
  const state = await install(page, 1, [0]);
  await page.getByRole('button', { name: 'Mở ca', exact: true }).click();
  await page.getByRole('button', { name: 'Đơn nháp mới' }).click();
  await expect(page.getByRole('tab', { name: 'Hóa đơn 1', exact: true })).toBeVisible();
  await page.reload();
  const claim = page.getByRole('button', { name: 'Nhận quyền sửa', exact: true });
  await expect(claim).toBeVisible();
  await page.clock.install();
  let claims = 0;
  let heartbeats = 0;
  await page.route('**/pos/command_receipts?*', (route) => route.fulfill({ status: 404, json: { error: { code: 'record_not_found' } } }));
  await page.route('**/pos/workspaces/ws_1/lease', (route) => {
    if (route.request().method() === 'PATCH') {
      heartbeats++;
      return route.fulfill({ json: { data: state.workspaces[0] } });
    }
    claims++;
    if (claims === 1) return route.fulfill({ status: 409, json: { error: { code: 'conflict', message: 'Workspace is being edited elsewhere.', details: { reason: 'lease_busy', retry_after_seconds: 2 } } } });
    state.workspaces[0].lease_generation = 2;
    return route.fulfill({ json: { data: state.workspaces[0] } });
  });
  await claim.click();
  await expect(page.getByRole('alert')).toContainText('Không cần tải lại trang.');
  await expect(claim).toBeDisabled();
  await expect(page.locator('.lease-wait')).toContainText('2 giây');
  await page.clock.fastForward(2100);
  await expect(claim).toBeEnabled();
  expect(claims).toBe(1);
  await claim.click();
  await expect(page.getByRole('button', { name: 'Tạm giữ', exact: true })).toBeEnabled();
  await expect(page.locator('.lease-notice')).toHaveCount(0);
  await page.clock.fastForward(41000);
  await expect.poll(() => heartbeats).toBeGreaterThanOrEqual(2);
  await expect(page.getByRole('button', { name: 'Tạm giữ', exact: true })).toBeEnabled();
  expect(claims).toBe(2);
});

test('a lost command response still warns and survives reload with the original idempotency key', async ({ page }) => {
  const state = await install(page, 1, [0]);
  await page.getByRole('button', { name: 'Mở ca', exact: true }).click();
  await expect(page.getByRole('button', { name: 'Đơn nháp mới' })).toBeEnabled();
  const keys: string[] = [];
  let loseResponse = true;
  await page.route('**/pos/workspaces', (route) => {
    if (route.request().method() !== 'POST') return route.fallback();
    keys.push(route.request().postDataJSON().idempotency_key);
    return loseResponse ? route.abort('connectionfailed') : route.fallback();
  });
  await page.getByRole('button', { name: 'Đơn nháp mới' }).click();
  const warning = page.getByText('Có thao tác chưa rõ kết quả.', { exact: false });
  await expect(warning).toBeVisible();
  page.once('dialog', (dialog) => dialog.accept());
  await page.reload();
  await expect(warning).toBeVisible();
  loseResponse = false;
  await page.getByRole('button', { name: 'Đơn nháp mới' }).click();
  await expect(page.getByRole('tab', { name: 'Hóa đơn 1', exact: true })).toBeVisible();
  await expect(warning).toHaveCount(0);
  expect(keys.length).toBeGreaterThanOrEqual(2);
  expect([...new Set(keys)]).toHaveLength(1);
  expect(state.workspaces).toHaveLength(1);
});
