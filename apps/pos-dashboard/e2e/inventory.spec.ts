import { expect, type Page, test } from '@playwright/test';
import { installDashboardShell } from './support/dashboard';
import { pageMeta, posContext } from './support/pos-context';

// Serial and lot stock of the selected branch against an in-memory POS API:
// variants and their opening balance, lot holds, transfers, counts with their
// approvals, and recall. Request bodies are kept for assertions.

function dayOffset(days: number) {
  return new Date(Date.now() + days * 86_400_000).toISOString().slice(0, 10);
}

type Write = { path: string; key: string | null; body: Record<string, unknown> };

function lot(id: string, code: string, extra: Record<string, unknown> = {}) {
  return {
    id, variant_id: 'v_yogurt', sku: 'SUA-1', name: 'Sữa chua', stock_location_id: 'stock_main', branch_id: 'branch_main',
    lot_code: code, expiry_on: dayOffset(10), status: 'active', received_quantity: 10, on_hand: 6, quarantined_quantity: 0,
    reserved: 1, committed: 1, available: 4, base_unit: 'hộp', source_lot_id: null, quarantine_reason: null,
    created_at: '2026-11-01T02:00:00Z', ...extra,
  };
}

function status(variant: 'phone' | 'yogurt', extra: Record<string, unknown> = {}) {
  const phone = variant === 'phone';
  return {
    variant_id: phone ? 'v_phone' : 'v_yogurt', sku: phone ? 'DT-1' : 'SUA-1', name: phone ? 'Điện thoại A' : 'Sữa chua',
    tracked_mode: phone ? 'serial' : 'lot', stock_location_id: 'stock_main', base_unit: phone ? 'cái' : 'hộp',
    sale_unit: phone ? 'cái' : 'hộp', enrolled: !phone, reconciled: !phone, sellable: !phone,
    blocked_reason: phone ? 'not_enrolled' : null, core_on_hand: phone ? 3 : 6, typed_on_hand: phone ? null : 6,
    lot_selection: 'fefo', lots: [], serials_available: phone ? 3 : 0, ...extra,
  };
}

function adjustment(id: string, requester: string, extra: Record<string, unknown> = {}) {
  return {
    id, branch_id: 'branch_main', variant_id: 'v_yogurt', sku: 'SUA-1', name: 'Sữa chua', reason: 'Đếm lại',
    status: 'pending_approval', requires_approval: true, delta: -3, revision: 1,
    lines: [{ kind: 'lot', lot_id: 'lot_1', lot_code: 'L-01', before: 6, after: 3, delta: -3 }],
    requester_id: requester, requester_name: requester === 'staff_admin' ? 'Quản trị Hiền' : 'Minh', approval: null,
    created_at: '2026-11-07T03:00:00Z', applied_at: null, ...extra,
  };
}

const MANAGER = ['pos.inventory.manage', 'pos.inventory.trace', 'pos.approval.grant'];
const MENU = /^(Open actions|Mở menu thao tác)$/;

async function install(page: Page, capabilities: string[]) {
  const variants = [status('phone'), status('yogurt')];
  const lots = [lot('lot_1', 'L-01'), lot('lot_2', 'L-02', { expiry_on: dayOffset(-5), status: 'expired' })];
  const adjustments = [adjustment('adj_1', 'staff_other'), adjustment('adj_2', 'staff_admin')];
  const state = { writes: [] as Write[], lists: [] as { path: string; params: Record<string, string> }[] };
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname.replace('/api/v3/admin', '');
    const params = Object.fromEntries(url.searchParams.entries());
    if (path === '/pos/context') {
      const context = posContext(url, { capabilities });
      return route.fulfill({
        json: {
          ...context,
          branches: [...context.branches, { ...context.branches[0], id: 'branch_2', name: 'Chi nhánh 2', code: 'b2' }],
        },
      });
    }
    if (request.method() === 'POST') {
      const body = request.postDataJSON() as Record<string, unknown>;
      state.writes.push({ path, key: request.headers()['idempotency-key'] ?? null, body });
      if (path === '/pos/inventory/opening_balances') {
        variants[0] = status('phone', { enrolled: true, reconciled: true, sellable: true, blocked_reason: null, typed_on_hand: 3 });
        return route.fulfill({ json: { data: variants[0] } });
      }
      const hold = /^\/pos\/lots\/([^/]+)\/quarantine$/.exec(path);
      if (hold) {
        lots[0] = { ...lots[0], status: 'quarantined', quarantine_reason: String(body.reason) };
        return route.fulfill({ json: { data: lots[0] } });
      }
      if (path === '/pos/inventory/transfers')
        return route.fulfill({ json: { data: { branch_id: 'branch_main', from: status('yogurt', { core_on_hand: 4 }), to: status('yogurt', { core_on_hand: 2 }) } } });
      if (path === '/pos/inventory/adjustments')
        return route.fulfill({ json: { data: adjustment('adj_3', 'staff_admin', { delta: -1 }) } });
      const decide = /^\/pos\/inventory\/adjustments\/([^/]+)\/(approve|apply|cancel)$/.exec(path);
      if (decide) {
        const index = adjustments.findIndex((row) => row.id === decide[1]);
        const next = decide[2] === 'approve'
          ? { ...adjustments[index], approval: { id: 'appr_1', status: 'active', expires_at: '2026-11-10T05:00:00Z' } }
          : { ...adjustments[index], status: decide[2] === 'apply' ? 'applied' : 'canceled' };
        if (decide[2] === 'approve') adjustments[index] = next;
        else adjustments.splice(index, 1);
        return route.fulfill({ json: { data: next } });
      }
      return route.fulfill({ status: 404, json: { error: { code: 'record_not_found', message: 'Not found' } } });
    }
    state.lists.push({ path, params });
    if (path === '/pos/inventory/variants') return route.fulfill({ json: { data: variants } });
    if (path === '/pos/lots') {
      const rows = lots.filter((row) => (!params.status || row.status === params.status) && (!params.variant_id || row.variant_id === params.variant_id));
      return route.fulfill({ json: { data: rows, meta: pageMeta(rows.length, 1, Number(params.limit || 50)) } });
    }
    if (path === '/pos/serial_units') {
      const rows = [{ id: 'su_1', variant_id: 'v_phone', sku: 'DT-1', name: 'Điện thoại A', serial: 'IMEI-1', status: 'in_stock', stock_location_id: 'stock_main', branch_id: 'branch_main', quarantine_reason: null, updated_at: '2026-11-08T02:00:00Z' }];
      return route.fulfill({ json: { data: rows, meta: pageMeta(rows.length) } });
    }
    if (path === '/pos/inventory/adjustments')
      return route.fulfill({ json: { data: adjustments, meta: pageMeta(adjustments.length) } });
    if (path === '/pos/inventory/recall')
      return route.fulfill({
        json: {
          data: {
            query: { lot_code: params.lot_code ?? null, serial: params.serial ?? null },
            lots: [lots[0]],
            serial_units: [],
            sales: [{ order_id: 'ord_1', order_number: 'P00042', branch_id: 'branch_main', branch_name: 'Chi nhánh chính', sold_at: '2026-11-09T03:00:00Z', sale_line_id: 'sl_1', sku: 'SUA-1', name: 'Sữa chua', quantity: 2, returned_quantity: 0, base_unit: 'hộp', lot_code: 'L-01', expiry_on: lots[0].expiry_on, serial: null, status: 'committed', customer: { id: 'c_1', name: 'Chị Lan', phone: '09******12' } }],
          },
          meta: { page: 1, limit: 50, count: 1, pages: 1, truncated: false },
        },
      });
    if (path.startsWith('/pos/')) return route.fulfill({ json: { data: [], meta: pageMeta(0) } });
    return route.fallback();
  });
  await installDashboardShell(page, { authenticated: true, read: false, write: false });
  return state;
}

test('a stock keeper enrols a serial variant and puts a lot on hold', async ({ page }, testInfo) => {
  const state = await install(page, MANAGER);
  await page.goto('/store_1/inventory');
  await expect(page).toHaveURL(/\/store_1\/inventory\/variants/);
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Truy xuất tồn kho');
  for (const name of ['Mặt hàng theo dõi', 'Lô hàng', 'Tra serial', 'Nhập hàng', 'Chuyển kho', 'Kiểm kê / điều chỉnh', 'Thu hồi'])
    await expect(page.getByRole('link', { name, exact: true })).toBeVisible();
  const table = page.getByRole('table');
  await expect(table.getByRole('row').filter({ hasText: 'Điện thoại A' })).toBeVisible();
  expect(state.lists.find((list) => list.path === '/pos/inventory/variants')?.params).toMatchObject({ branch_id: 'branch_main' });
  await page.screenshot({ path: testInfo.outputPath('inventory-variants.png'), fullPage: true });

  await table.getByRole('row').filter({ hasText: 'Điện thoại A' }).getByRole('button', { name: MENU }).click();
  await page.getByRole('menuitem', { name: 'Khai báo tồn đầu kỳ Điện thoại A' }).click();
  const dialog = page.getByRole('dialog');
  await dialog.getByRole('textbox').fill('IMEI-1\nIMEI-2\nIMEI-3');
  await dialog.getByRole('button', { name: 'Lưu tồn đầu kỳ' }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã khai báo tồn đầu kỳ cho Điện thoại A.' })).toBeVisible();
  const opening = state.writes.at(-1);
  expect(opening?.path).toBe('/pos/inventory/opening_balances');
  expect(opening?.body).toMatchObject({ branch_id: 'branch_main', variant_id: 'v_phone', serials: ['IMEI-1', 'IMEI-2', 'IMEI-3'] });
  expect(opening?.key).toBeTruthy();
  expect(opening?.body.idempotency_key).toBe(opening?.key);

  await page.getByRole('link', { name: 'Lô hàng', exact: true }).click();
  await expect(page).toHaveURL(/\/store_1\/inventory\/lots/);
  const lotRow = table.getByRole('row').filter({ hasText: 'L-01' });
  await expect(lotRow).toContainText('Sắp hết hạn');
  await expect(table.getByRole('row').filter({ hasText: 'L-02' })).toContainText('Hết hạn');
  await expect(table.getByRole('row').filter({ hasText: 'L-02' }).getByRole('button', { name: MENU })).toHaveCount(0);
  await lotRow.getByRole('button', { name: MENU }).click();
  await page.getByRole('menuitem', { name: 'Cách ly L-01' }).click();
  await page.getByRole('dialog').getByLabel('Lý do').fill('Bao bì móp');
  await page.getByRole('dialog').getByRole('button', { name: 'Cách ly' }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã cách ly L-01.' })).toBeVisible();
  expect(state.writes.at(-1)).toMatchObject({ path: '/pos/lots/lot_1/quarantine', body: { reason: 'Bao bì móp' } });
  await expect(lotRow).toContainText('Bao bì móp');
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
});

test('a stock keeper transfers lots and an approver decides counts', async ({ page }) => {
  const state = await install(page, MANAGER);
  await page.goto('/store_1/inventory/transfer');
  const form = page.getByRole('form', { name: 'Chuyển kho' });
  await form.getByRole('combobox', { name: 'Mặt hàng' }).click();
  await page.getByRole('option', { name: /Sữa chua · SUA-1/ }).click();
  await form.getByRole('combobox', { name: 'Chi nhánh nhận' }).click();
  await page.getByRole('option', { name: 'Chi nhánh 2' }).click();
  await form.getByLabel(/Lô L-01/).fill('5');
  await form.getByRole('button', { name: 'Chuyển kho' }).click();
  await expect(form.getByRole('alert')).toBeVisible();
  await form.getByLabel(/Lô L-01/).fill('2');
  await form.getByRole('button', { name: 'Chuyển kho' }).click();
  await expect(form.getByRole('status').first()).toContainText('Sữa chua');
  expect(state.writes.at(-1)).toMatchObject({
    path: '/pos/inventory/transfers',
    body: { from_branch_id: 'branch_main', to_branch_id: 'branch_2', variant_id: 'v_yogurt', lots: [{ lot_id: 'lot_1', quantity: 2 }] },
  });

  await page.getByRole('link', { name: 'Kiểm kê / điều chỉnh', exact: true }).click();
  const pending = page.getByRole('region', { name: 'Điều chỉnh chờ duyệt' });
  const other = pending.getByRole('row').filter({ hasText: 'Minh' });
  await other.getByRole('button', { name: MENU }).click();
  await expect(page.getByRole('menuitem', { name: 'Áp dụng' })).toHaveCount(0);
  await page.getByRole('menuitem', { name: 'Duyệt' }).click();
  await expect(pending.getByRole('status').filter({ hasText: 'Đã duyệt điều chỉnh Sữa chua.' })).toBeVisible();
  expect(state.writes.at(-1)).toMatchObject({ path: '/pos/inventory/adjustments/adj_1/approve', body: {} });

  const mine = pending.getByRole('row').filter({ hasText: 'Quản trị Hiền' });
  await mine.getByRole('button', { name: MENU }).click();
  await expect(page.getByRole('menuitem', { name: 'Duyệt' })).toHaveCount(0);
  await page.getByRole('menuitem', { name: 'Hủy điều chỉnh' }).click();
  await page.getByRole('dialog').getByLabel('Lý do').fill('Đếm nhầm');
  await page.getByRole('dialog').getByRole('button', { name: 'Hủy điều chỉnh' }).click();
  await expect(pending.getByRole('status').filter({ hasText: 'Đã hủy điều chỉnh Sữa chua.' })).toBeVisible();
  expect(state.writes.at(-1)).toMatchObject({ path: '/pos/inventory/adjustments/adj_2/cancel', body: { reason: 'Đếm nhầm' } });
});

test('a tracer finds where a lot went and an approver sees only counts', async ({ page }) => {
  await install(page, ['pos.inventory.trace']);
  await page.goto('/store_1/inventory/recall');
  await expect(page.getByRole('link', { name: 'Nhập hàng', exact: true })).toHaveCount(0);
  await page.getByLabel('Mã cần tìm').fill('L-01');
  await page.getByRole('button', { name: 'Tìm' }).click();
  await expect(page.getByRole('list', { name: /lô/i }).first()).toContainText('L-01');
  const sales = page.getByRole('region', { name: 'Đơn đã bán' });
  await expect(sales.getByRole('row').filter({ hasText: 'P00042' })).toContainText('Chị Lan');

  await page.unrouteAll({ behavior: 'ignoreErrors' });
  await install(page, ['pos.approval.grant']);
  await page.goto('/store_1/inventory');
  await expect(page).toHaveURL(/\/store_1\/inventory\/adjust/);
  await expect(page.getByRole('form', { name: 'Kiểm kê / điều chỉnh' })).toHaveCount(0);
  await expect(page.getByRole('region', { name: 'Điều chỉnh chờ duyệt' }).getByRole('row').filter({ hasText: 'Minh' })).toBeVisible();
  await page.goto('/store_1/inventory/lots');
  await expect(page).toHaveURL(/\/store_1\/inventory\/adjust/);
});
