import { expect, type Page, test } from '@playwright/test';
import { goToMenuPage, openUserMenu } from './support/menu';
import {
  addSheet,
  completeAndHandOver,
  FULL_CASHIER,
  installRetailApi,
  login,
  newWorld,
  openTab,
  payCash,
} from './support/retail-api';

// Branch modules (plan 261108-1830, phase 3): a module that is off hides its
// setup entry points only. Selling, receipts and returns never change, and a
// hidden page opened by URL still opens with a "branch has not turned on …"
// note. Presentation fixtures only: no real account privileges.

const TRACE_OFF = { 'retail.units': true, 'retail.measured': true, 'retail.traceability': false };
const KEEPER = [...FULL_CASHIER, 'pos.inventory.manage'];
const TRACE_NOTE = 'Chi nhánh chưa bật chức năng Serial, lô, hạn dùng';

async function addSerials(page: Page, search: string, serials: string[]) {
  await page.getByRole('searchbox', { name: 'Tìm hàng hoặc quét mã' }).fill(search);
  await page.getByRole('button', { name: 'Tìm hàng', exact: true }).click();
  await page.locator('details.catalog-advanced summary').first().click();
  const form = page.locator('.add-item-form');
  await form.getByRole('textbox', { name: /^Serial/ }).fill(`${serials.join('\n')}\n`);
  await form.getByRole('button', { name: 'Thêm vào đơn' }).click();
}

test('traceability off hides the stock page and tracking setup, and a tracked SKU still sells by serial', async ({ page }) => {
  const world = newWorld({ capabilities: KEEPER, modules: TRACE_OFF, moduleUsage: { 'retail.traceability': false } });
  addSheet(world, 'ws_1');
  await installRetailApi(page, world);
  await login(page);

  const menu = await openUserMenu(page);
  await expect(menu.getByRole('link', { name: 'Ca & két', exact: true })).toBeVisible();
  await expect(menu.getByRole('link', { name: 'Truy xuất tồn kho', exact: true })).toHaveCount(0);
  await page.keyboard.press('Escape');

  // The sale screen is untouched: the serial field is there and the sale completes.
  await openTab(page, 'ws_1');
  await addSerials(page, 'DT-1', ['SN-1']);
  await expect(page.locator('.basket-lines')).toContainText('Serial: SN-1 · đang giữ');
  await payCash(page, '2.500.000');
  await completeAndHandOver(page);
  expect(world.serialStock.has('SN-1')).toBe(false);

  // The page itself still opens by URL and says why setup is missing.
  await page.goto('/inventory');
  await expect(page.getByRole('heading', { name: 'Truy xuất tồn kho', level: 1 })).toBeVisible();
  await expect(page.getByRole('note').filter({ hasText: TRACE_NOTE })).toBeVisible();
  await expect(page.getByRole('table', { name: 'Mặt hàng theo dõi' })).toContainText('Điện thoại A');
  await expect(page.getByRole('button', { name: /^Khai báo tồn đầu kỳ/ })).toHaveCount(0);
  await expect(page.getByRole('tab', { name: 'Nhập hàng', exact: true })).toHaveCount(0);
});

test('traceability off keeps receiving reachable while the store still tracks SKUs, without opening balances', async ({ page }) => {
  const world = newWorld({ capabilities: KEEPER, modules: TRACE_OFF, moduleUsage: { 'retail.traceability': true } });
  await installRetailApi(page, world);
  await login(page);
  await goToMenuPage(page, 'Truy xuất tồn kho');
  await expect(page.getByRole('heading', { name: 'Truy xuất tồn kho', level: 1 })).toBeVisible();
  await expect(page.getByRole('note').filter({ hasText: TRACE_NOTE })).toBeVisible();
  await expect(page.getByRole('tab', { name: 'Nhập hàng', exact: true })).toBeVisible();
  await expect(page.getByRole('tab', { name: 'Chuyển kho', exact: true })).toBeVisible();
  await expect(page.getByRole('table', { name: 'Mặt hàng theo dõi' })).toContainText('Điện thoại A');
  await expect(page.getByRole('button', { name: /^Khai báo tồn đầu kỳ/ })).toHaveCount(0);
});

test('a server without modules hides nothing: stock page, receiving and opening balances stay', async ({ page }) => {
  const world = newWorld({ capabilities: KEEPER });
  await installRetailApi(page, world);
  await login(page);
  await goToMenuPage(page, 'Truy xuất tồn kho');
  await expect(page.getByRole('tab', { name: 'Nhập hàng', exact: true })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Khai báo tồn đầu kỳ Điện thoại A', exact: true })).toBeVisible();
  await expect(page.getByRole('note').filter({ hasText: 'Chi nhánh chưa bật chức năng' })).toHaveCount(0);
});

for (const [profile, view, other] of [
  ['nha_thuoc', 'list', 'cards'],
  ['thoi_trang', 'cards', 'list'],
] as const) {
  test(`a ${profile} branch opens the catalogue as ${view}, and the cashier's choice stays`, async ({ page }) => {
    const world = newWorld({
      modules: { 'retail.units': true, 'retail.traceability': true },
      profile: { key: profile, version: 1, display: { catalog_view: view } },
    });
    addSheet(world, 'ws_1');
    await installRetailApi(page, world);
    await login(page);
    await openTab(page, 'ws_1');
    await page.getByRole('searchbox', { name: 'Tìm hàng hoặc quét mã' }).fill('Gạo');
    await page.getByRole('button', { name: 'Tìm hàng', exact: true }).click();
    const results = page.getByRole('list', { name: 'Kết quả tìm hàng' });
    await expect(results).toHaveClass(new RegExp(`catalog-results--${view}`));
    await expect(page.getByRole('button', { name: view === 'list' ? 'Danh sách' : 'Thẻ', exact: true })).toHaveAttribute(
      'aria-pressed',
      'true',
    );
    await page.getByRole('button', { name: other === 'list' ? 'Danh sách' : 'Thẻ', exact: true }).click();
    await expect(results).toHaveClass(new RegExp(`catalog-results--${other}`));
  });
}

// Store administration of one branch with scale labels and serial/lot
// tracking off. Its modules come from GET /branches/:id/modules (no branch is
// selected in the context of an administrator).
type Write = { method: string; path: string; body: Record<string, unknown> | null };
const staff = { id: 'staff_admin', full_name: 'Quản trị Hiền', email: 'admin@example.test' };
const branch = {
  id: 'branch_main', name: 'Siêu thị Hiền', code: 'main', status: 'active', timezone: 'Asia/Ho_Chi_Minh',
  stock_location_id: 'stock_main', receiving_stock_location_id: null, receiving_note: null,
  return_window_days: 7, lot_selection: 'cashier_pick', adjustment_approval_threshold: null,
};

async function installAdmin(page: Page, modules: Record<string, boolean>) {
  const writes: Write[] = [];
  const modulesRead: string[] = [];
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname.replace('/api/v3/admin', '');
    const method = request.method();
    const body = method === 'GET' || method === 'DELETE' ? null : ((request.postDataJSON() ?? {}) as Record<string, unknown>);
    if (method !== 'GET' && !/\/auth\//.test(path)) writes.push({ method, path, body });
    if (/\/auth\/(login|refresh)$/.test(path)) return route.fulfill({ json: { token: 'fixture-only' } });
    if (path === '/me') return route.fulfill({ json: { user: staff } });
    if (path === '/pos/context')
      return route.fulfill({
        json: {
          staff, store: { id: 'store_1', name: 'Siêu thị Hiền', currency: 'VND' }, administration: { read: true, write: true },
          capabilities: [], modules: {}, module_usage: { 'retail.traceability': false }, profile: null,
          onboarding: { required: false, can_setup: true },
          branches: [branch], registers: [], shift: null, selection: { branch_id: url.searchParams.get('branch_id'), register_id: null },
        },
      });
    if (path === '/pos/branches') return route.fulfill({ json: { data: [branch], meta: { next: null } } });
    if (path === '/pos/branches/branch_main' && method === 'PATCH') return route.fulfill({ json: { data: { ...branch, ...body } } });
    if (path === '/pos/configuration/locations')
      return route.fulfill({ json: { data: [{ id: 'stock_main', name: 'Kho hàng trung tâm', active: true }], meta: { next: null } } });
    if (path === '/pos/branches/branch_main/modules') {
      modulesRead.push(path);
      return route.fulfill({ json: { data: { branch_id: branch.id, modules, settings: [] } } });
    }
    if (path === '/pos/branches/branch_main/products')
      return route.fulfill({
        json: { data: [{ id: 'prod_rice', name: 'Gạo ST25', status: 'active', skus: ['ST25-5KG'], assigned: true }], meta: { page: 1, pages: 1, count: 1, next: null } },
      });
    if (path === '/pos/branches/branch_main/label_formats')
      return route.fulfill({
        json: {
          data: [{
            id: 'poslabel_1', branch_id: branch.id, name: 'Cân quầy thịt', prefix: '21', kind: 'weight', item_code_length: 5, value_length: 5,
            value_decimals: 0, value_unit_code: 'g', price_tolerance: '0.0', version: 1, status: 'active',
          }],
          meta: { page: 1, pages: 1, count: 1, next: null },
        },
      });
    if (path === '/pos/catalog')
      return route.fulfill({
        json: {
          data: [{ id: 'variant_rice_5', product_id: 'prod_rice', name: 'Gạo ST25', sku: 'ST25-5KG', barcode: null, price: '180000.0', compare_at_price: null, currency: 'VND', stock_on_hand: 4 }],
          meta: { page: 1, pages: 1, count: 1, ambiguous: false },
        },
      });
    if (path === '/pos/units')
      return route.fulfill({
        json: { data: [
          { id: 'u1', code: 'item', name: 'Cái', dimension: 'count', base_code: 'item', factor_to_base: '1', sale_precision: 0, version: 1 },
          { id: 'u4', code: 'case', name: 'Thùng', dimension: 'count', base_code: 'item', factor_to_base: '1', sale_precision: 0, version: 1 },
        ] },
      });
    if (path === '/pos/units/variant' && method === 'GET')
      return route.fulfill({
        json: { data: { variant_id: 'variant_rice_5', sale_unit: 'item', base_unit: 'item', price_unit: 'item', ratio_numerator: 1, ratio_denominator: 1, tracked_mode: 'none', version: 1, status: 'active', label_code: null } },
      });
    // The branch turned conversion off after the page loaded: the server refuses.
    if (path === '/pos/units/variant' && method === 'PUT')
      return route.fulfill({
        status: 409,
        json: { error: { code: 'conflict', message: 'Module retail.units is turned off.', details: { reason: 'module_disabled', module: 'retail.units' } } },
      });
    if (path === '/pos/feature_flags')
      return route.fulfill({
        json: { data: { branch_id: branch.id, features: { traceability: true }, switches: { traceability: { store: true, branch_override: null, effective: true } }, settings: [] } },
      });
    return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0, next: null } } });
  });
  return { writes, modulesRead };
}

async function signInAsAdmin(page: Page) {
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('admin@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('fixture-only');
  await page.getByRole('button', { name: 'Đăng nhập quản trị', exact: true }).click();
  await expect(page).toHaveURL(/\/settings$/);
}

test('branch settings follow the modules of that branch, and a hidden page still opens by URL', async ({ page }) => {
  const { writes, modulesRead } = await installAdmin(page, { 'retail.units': true, 'retail.measured': false, 'retail.traceability': false });
  await signInAsAdmin(page);

  // Scale labels are off: the branch row offers no label formats.
  const products = page.getByRole('link', { name: 'Hàng bán tại chi nhánh Siêu thị Hiền', exact: true });
  await expect(products).toBeVisible();
  await expect.poll(() => modulesRead.length).toBeGreaterThan(0);
  await expect(page.getByRole('link', { name: 'Mẫu tem cân Siêu thị Hiền', exact: true })).toHaveCount(0);

  // Tracking is off: the branch editor does not offer lot picking, and saving
  // sends the stored value back unchanged.
  await page.getByRole('button', { name: 'Chỉnh sửa Siêu thị Hiền', exact: true }).click();
  const editor = page.getByRole('dialog');
  await expect(editor.getByLabel('Số ngày cho phép trả hàng', { exact: false })).toBeVisible();
  await expect(editor.getByRole('combobox', { name: 'Kho bán hàng' })).toBeVisible();
  await expect(editor.getByRole('combobox', { name: /^Chọn lô khi bán/ })).toHaveCount(0);
  await editor.getByLabel('Tên hiển thị', { exact: true }).fill('Siêu thị Hiền 2');
  await editor.getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect(editor).toHaveCount(0);
  expect(writes.at(-1)).toMatchObject({ method: 'PATCH', path: '/pos/branches/branch_main', body: { lot_selection: 'cashier_pick' } });

  // The SKU editor keeps units and hides tracking and the label code.
  await products.click();
  const sections = page.getByRole('navigation', { name: 'Cấu hình chi nhánh' });
  await expect(sections.getByRole('link', { name: 'Hàng bán tại chi nhánh', exact: true })).toBeVisible();
  await expect(sections.getByRole('link', { name: 'Mẫu tem cân', exact: true })).toHaveCount(0);
  await page.getByRole('button', { name: 'Đơn vị và mã tem Gạo ST25', exact: true }).click();
  const dialog = page.getByRole('dialog', { name: 'Đơn vị và mã tem cân' });
  await expect(dialog.getByLabel('Đơn vị bán')).toHaveValue('item');
  await expect(dialog.getByLabel('Theo dõi hàng')).toHaveCount(0);
  await expect(dialog.getByLabel('Mã hàng trên tem cân')).toHaveCount(0);
  await expect(dialog.getByRole('note').filter({ hasText: TRACE_NOTE })).toBeVisible();
  await expect(dialog.getByRole('note').filter({ hasText: 'Chi nhánh chưa bật chức năng Hàng cân, tem cân' })).toBeVisible();

  // A module_disabled refusal reads as its own sentence, not a generic error.
  await dialog.getByLabel('Đơn vị bán').selectOption('case');
  await dialog.getByLabel('Tỷ lệ quy đổi (tử số)').fill('24');
  await dialog.getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect(dialog.getByRole('alert')).toHaveText(
    'Chi nhánh chưa bật chức năng Quy đổi đơn vị; máy chủ không ghi nhận quy đổi mới. Việc bán hàng không bị ảnh hưởng.',
  );
  // The unsaved edit asks before closing.
  page.once('dialog', (confirm) => void confirm.accept());
  await dialog.getByRole('button', { name: 'Hủy', exact: true }).click();
  await expect(dialog).toHaveCount(0);

  // Opened by URL, the label formats page lists the formats and says why it
  // takes no new ones; switching a format off stays.
  await page.goto('/settings/branches/branch_main/label-formats');
  await expect(page.getByRole('list', { name: 'Danh sách mẫu tem cân' })).toContainText('Cân quầy thịt');
  await expect(page.getByRole('note').filter({ hasText: 'Chi nhánh chưa bật chức năng Hàng cân, tem cân' })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Thêm mẫu tem' })).toHaveCount(0);
  await expect(page.getByRole('button', { name: 'Chỉnh sửa Cân quầy thịt' })).toHaveCount(0);
  await expect(page.getByRole('button', { name: 'Ngừng mẫu tem Cân quầy thịt', exact: true })).toBeVisible();
});

test('branch settings with every module on look as before', async ({ page }) => {
  await installAdmin(page, { 'retail.units': true, 'retail.measured': true, 'retail.traceability': true });
  await signInAsAdmin(page);
  await expect(page.getByRole('link', { name: 'Mẫu tem cân Siêu thị Hiền', exact: true })).toBeVisible();
  await page.getByRole('button', { name: 'Chỉnh sửa Siêu thị Hiền', exact: true }).click();
  await expect(page.getByRole('dialog').getByRole('combobox', { name: /^Chọn lô khi bán/ })).toHaveValue('cashier_pick');
  await page.getByRole('dialog').getByRole('button', { name: 'Đóng', exact: true }).first().click();
  await page.getByRole('link', { name: 'Hàng bán tại chi nhánh Siêu thị Hiền', exact: true }).click();
  await page.getByRole('button', { name: 'Đơn vị và mã tem Gạo ST25', exact: true }).click();
  const dialog = page.getByRole('dialog', { name: 'Đơn vị và mã tem cân' });
  await expect(dialog.getByLabel('Theo dõi hàng')).toBeVisible();
  await expect(dialog.getByLabel('Mã hàng trên tem cân')).toBeVisible();
  await expect(dialog.getByRole('note').filter({ hasText: 'Chi nhánh chưa bật chức năng' })).toHaveCount(0);
});
