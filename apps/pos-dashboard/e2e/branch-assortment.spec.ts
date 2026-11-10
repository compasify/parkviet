import { expect, type Page, test } from '@playwright/test';
import { installDashboardShell } from './support/dashboard';

type Product = { id: string; name: string; status: string; skus: string[]; assigned: boolean };
type Format = { id: string; name: string; prefix: string; kind: string; item_code_length: number; value_length: number; value_decimals: number; value_unit_code: string | null; price_tolerance: string; version: number; status: string };
const staff = { id: 'staff_admin', full_name: 'Quản trị Hiền', email: 'admin@example.test' };
const branch = { id: 'branch_main', name: 'Siêu thị Hiền', code: 'main', status: 'active', timezone: 'Asia/Ho_Chi_Minh', stock_location_id: 'stock_main', receiving_stock_location_id: null, receiving_note: null };
const variants = [
  { id: 'variant_rice_5', product_id: 'prod_rice', name: 'Gạo ST25', sku: 'ST25-5KG', barcode: '8930000000500', price: '180000.0', currency: 'VND', stock_on_hand: 4 },
  { id: 'variant_rice_bulk', product_id: 'prod_rice', name: 'Gạo ST25', sku: 'ST25-BULK', barcode: null, price: '36000.0', currency: 'VND', stock_on_hand: 50 },
];
async function install(page: Page, access = { read: true, write: true }) {
  const products: Product[] = [{ id: 'prod_rice', name: 'Gạo ST25', status: 'active', skus: ['ST25-5KG', 'ST25-BULK'], assigned: true }, ...Array.from({ length: 29 }, (_, i) => ({ id: `prod_${i + 1}`, name: `Sản phẩm ${String(i + 1).padStart(2, '0')}`, status: 'active', skus: [`SP-${i + 1}`], assigned: false }))];
  const formats: Format[] = [{ id: 'poslabel_1', name: 'Cân quầy thịt', prefix: '21', kind: 'weight', item_code_length: 5, value_length: 5, value_decimals: 0, value_unit_code: 'g', price_tolerance: '0.0', version: 1, status: 'active' }];
  const units: Record<string, Record<string, unknown>> = { variant_rice_bulk: { variant_id: 'variant_rice_bulk', sale_unit: 'kg', base_unit: 'g', price_unit: 'kg', ratio_numerator: 1, ratio_denominator: 1, tracked_mode: 'none', version: 1, status: 'active', label_code: null } };
  const state = { writes: [] as { method: string; path: string; body: Record<string, unknown> | null }[], productQueries: [] as Record<string, string>[], failNextProductWrite: '', takenLabelCodes: new Set(['99999']) };
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request(); const url = new URL(request.url()); const path = url.pathname.replace('/api/v3/admin', ''); const method = request.method();
    const body = method === 'GET' || method === 'DELETE' ? null : request.postDataJSON() as Record<string, unknown>;
    if (method !== 'GET' && !path.includes('/auth/')) state.writes.push({ method, path, body });
    const conflict = (message: string) => route.fulfill({ status: 409, json: { error: { code: 'conflict', message } } });
    if (path === '/pos/context') return route.fulfill({ json: { staff, store: { id: 'store_1', name: 'Siêu thị Hiền', currency: 'VND' }, administration: access, capabilities: [], branches: [branch], registers: [], shift: null, selection: { branch_id: url.searchParams.get('branch_id'), register_id: null } } });
    if (path === '/pos/branches') return route.fulfill({ json: { data: [branch], meta: { next: null } } });
    if (path === '/pos/configuration/locations') return route.fulfill({ json: { data: [{ id: 'stock_main', name: 'Kho hàng trung tâm', active: true }] } });
    const productMatch = /^\/pos\/branches\/branch_main\/products(?:\/([^/]+))?$/.exec(path);
    if (productMatch && method === 'GET') {
      const params = Object.fromEntries(url.searchParams.entries()); state.productQueries.push(params); const q = (params.q ?? '').toLocaleLowerCase();
      const rows = products.filter((p) => (!q || p.name.toLocaleLowerCase().includes(q) || p.skus.some((sku) => sku.toLocaleLowerCase().includes(q))) && (params.assigned === undefined || String(p.assigned) === params.assigned));
      const limit = Number(params.limit || 25); const current = Number(params.page || 1); const pages = Math.ceil(rows.length / limit);
      const data = rows.slice((current - 1) * limit, current * limit); const from = data.length ? (current - 1) * limit + 1 : 0;
      return route.fulfill({ json: { data, meta: { page: current, limit, pages, count: rows.length, from, to: data.length ? from + data.length - 1 : 0, previous: current > 1 ? current - 1 : null, next: current < pages ? current + 1 : null } } });
    }
    if (productMatch) {
      const id = method === 'POST' ? String(body?.product_id) : productMatch[1]; const product = products.find((p) => p.id === id);
      if (!product) return route.fulfill({ status: 404, json: { error: { code: 'not_found' } } });
      if (state.failNextProductWrite === id) { state.failNextProductWrite = ''; return conflict('Product is archived.'); }
      product.assigned = method === 'POST'; return method === 'POST' ? route.fulfill({ status: 201, json: { data: { branch_id: branch.id, product_id: id } } }) : route.fulfill({ status: 204, body: '' });
    }
    const formatMatch = /^\/pos\/branches\/branch_main\/label_formats(?:\/([^/]+))?(\/disable)?$/.exec(path);
    if (formatMatch && method === 'GET') return route.fulfill({ json: { data: formats, meta: { next: null } } });
    if (formatMatch && method === 'POST' && !formatMatch[1]) {
      if (formats.some((f) => f.status === 'active' && f.prefix === body?.prefix)) return conflict('Another active label format uses this prefix.');
      const created = { ...(body as unknown as Format), id: `poslabel_${formats.length + 1}`, version: 1, status: 'active' }; formats.push(created); return route.fulfill({ status: 201, json: { data: created } });
    }
    if (formatMatch?.[1]) { const format = formats.find((f) => f.id === formatMatch[1]); if (!format) return route.fulfill({ status: 404 }); if (formatMatch[2]) format.status = 'disabled'; else Object.assign(format, body, { version: format.version + 1 }); return route.fulfill({ json: { data: format } }); }
    if (path === '/pos/catalog') { const q = (url.searchParams.get('q') ?? '').toLocaleLowerCase(); const rows = variants.filter((v) => products.find((p) => p.id === v.product_id)?.assigned && v.name.toLocaleLowerCase().includes(q)); return route.fulfill({ json: { data: rows, meta: { page: 1, pages: 1, count: rows.length, ambiguous: false } } }); }
    if (path === '/pos/units') return route.fulfill({ json: { data: [
      { id: 'u1', code: 'item', name: 'Cái', dimension: 'count', base_code: 'item', factor_to_base: '1', sale_precision: 0, version: 1 },
      { id: 'u2', code: 'g', name: 'Gram', dimension: 'mass', base_code: 'g', factor_to_base: '1', sale_precision: 0, version: 1 },
      { id: 'u3', code: 'kg', name: 'Kilogram', dimension: 'mass', base_code: 'g', factor_to_base: '1000', sale_precision: 3, version: 1 },
    ] } });
    if (path === '/pos/units/variant' && method === 'GET') { const id = url.searchParams.get('variant_id') ?? ''; return route.fulfill({ json: { data: units[id] ?? { variant_id: id, sale_unit: 'item', base_unit: 'item', price_unit: 'item', ratio_numerator: 1, ratio_denominator: 1, tracked_mode: 'none', version: 1, status: 'default' } } }); }
    if (path === '/pos/units/variant' && method === 'PUT') { if (state.takenLabelCodes.has(String(body?.label_code))) return conflict('Label code is already used by another SKU.'); const id = String(body?.variant_id); units[id] = { ...body, version: 1, status: 'active' }; return route.fulfill({ json: { data: units[id] } }); }
    if (path === '/pos/feature_flags') return route.fulfill({ json: { data: { branch_id: branch.id, features: { traceability: false }, switches: { traceability: { store: false, branch_override: null, effective: false } }, settings: [] } } });
    return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0, next: null } } });
  });
  await installDashboardShell(page, { ...access, authenticated: true }); return { state, products, formats, units };
}
async function open(page: Page, section = 'products') { await page.goto(`/store_1/branches/branch_main/${section}`); }
// Spree's own strings are English under the dev server, which pre-bundles the
// framework without its locale files; the production build carries both.
const MENU = /^(Open actions|Mở menu thao tác)$/;
const assigned = (value: string) => `filters=${encodeURIComponent(JSON.stringify([{ id: 'f1', field: 'assigned', operator: 'in', value }]))}`;
async function act(page: Page, row: string, item: string) { await page.getByRole('row').filter({ hasText: row }).getByRole('button', { name: MENU }).click(); await page.getByRole('menuitem', { name: item, exact: true }).click(); }
async function select(page: Page, label: string, option: string) { await page.getByLabel(label, { exact: true }).click(); await page.getByRole('option', { name: option, exact: true }).click(); }
async function remove(page: Page, name: string) { await act(page, name, 'Gỡ khỏi chi nhánh'); await page.getByRole('dialog').getByRole('button', { name: 'Gỡ khỏi chi nhánh', exact: true }).click(); }
const fits = (page: Page) => page.evaluate(() => document.documentElement.scrollWidth <= innerWidth);

test('search, filters, pagination, assignment, removal and server conflicts retain authority', async ({ page }, testInfo) => {
  const { state, products } = await install(page); await open(page); const table = page.getByRole('table');
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Hàng bán tại chi nhánh · Siêu thị Hiền'); await expect(table.getByRole('row')).toHaveCount(26); await expect(page.getByText(/^1–25 (of|trong số) 30$/)).toBeVisible();
  await expect(page.locator('a[href="/store_1/branches/branch_main/products"]')).toHaveClass(/border-foreground/);
  await page.screenshot({ path: testInfo.outputPath('branch-products.png'), fullPage: true });
  await open(page, 'products?page=2'); await expect(table.getByRole('row')).toHaveCount(6); expect(state.productQueries.at(-1)).toMatchObject({ page: '2', limit: '25' }); expect(await fits(page)).toBe(true);
  await open(page, 'products?search=sp-12'); await expect(table.getByRole('row')).toHaveCount(2); expect(state.productQueries.at(-1)).toMatchObject({ q: 'sp-12', page: '1' });
  const row = table.getByRole('row').filter({ hasText: 'Sản phẩm 12' }); await expect(row).toContainText('chưa bán'); await act(page, 'Sản phẩm 12', 'Thêm vào chi nhánh'); await expect(row).toContainText('đang bán'); await expect(page.getByRole('status').filter({ hasText: 'Đã thêm “Sản phẩm 12” vào chi nhánh.' })).toBeVisible(); expect(state.writes.at(-1)).toEqual({ method: 'POST', path: '/pos/branches/branch_main/products', body: { product_id: 'prod_12' } });
  await open(page, `products?${assigned('true')}`); await expect(table.getByRole('row')).toHaveCount(3); expect(state.productQueries.at(-1)).toMatchObject({ assigned: 'true', page: '1' });
  await remove(page, 'Sản phẩm 12'); await expect(page.getByRole('status').filter({ hasText: 'Đã gỡ “Sản phẩm 12” khỏi chi nhánh.' })).toBeVisible(); await expect(table.getByRole('row')).toHaveCount(2); expect(state.writes.at(-1)).toMatchObject({ method: 'DELETE', path: '/pos/branches/branch_main/products/prod_12' });
  state.failNextProductWrite = 'prod_rice'; await remove(page, 'Gạo ST25'); await expect(page.getByRole('alert')).toHaveText('Không cập nhật được “Gạo ST25”: Product is archived.'); await expect(table.getByRole('row').filter({ hasText: 'Gạo ST25' })).toContainText('đang bán'); expect(products[0].assigned).toBe(true);
  await open(page, `products?${assigned('false')}`); await expect(page.getByText(/^1–25 (of|trong số) 29$/)).toBeVisible(); expect(state.productQueries.at(-1)).toMatchObject({ assigned: 'false' }); expect(await fits(page)).toBe(true);
  await open(page, `products?${assigned('true,false')}`); await expect(table.getByRole('row')).toHaveCount(26); expect(state.productQueries.at(-1)?.assigned).toBeUndefined();
});
test('label format layout validation, prefix conflicts, creation, editing and disabling', async ({ page }, testInfo) => {
  const { state, formats } = await install(page); await open(page, 'label-formats'); const table = page.getByRole('table'); await expect(table).toContainText('Tiền tố 21 · mã hàng 5 số · giá trị 5 số');
  await page.screenshot({ path: testInfo.outputPath('label-formats.png'), fullPage: true });
  await page.getByRole('button', { name: 'Thêm mẫu tem', exact: true }).click(); const dialog = page.getByRole('dialog', { name: 'Thêm mẫu tem cân' }); await dialog.getByLabel('Tên mẫu').fill('Tem giá quầy rau'); await select(page, 'Loại tem', 'Tem giá tiền');
  await dialog.getByLabel('Tiền tố').fill('2'); await dialog.getByLabel('Số chữ số mã hàng').fill('6'); await dialog.getByLabel('Số chữ số giá trị').fill('6'); await expect(dialog.getByText('Đang dùng 13/12 chữ số.', { exact: false })).toBeVisible(); await expect(dialog.getByText('Tiền tố + mã hàng + giá trị phải bằng đúng 12 chữ số.')).toBeVisible(); const save = dialog.getByRole('button', { name: 'Lưu', exact: true }); await expect(save).toBeDisabled(); await dialog.getByLabel('Số chữ số giá trị').press('Enter'); expect(state.writes).toEqual([]);
  await dialog.getByLabel('Tiền tố').fill('21'); await dialog.getByLabel('Số chữ số mã hàng').fill('5'); await dialog.getByLabel('Số chữ số giá trị').fill('5'); await dialog.getByLabel('Sai lệch giá cho phép').fill('500'); await expect(dialog.getByText('Đủ 12/12 chữ số', { exact: false })).toBeVisible(); await save.click(); await expect(dialog.getByRole('alert')).toHaveText('Another active label format uses this prefix.'); await dialog.getByLabel('Tiền tố').fill('22'); await save.click(); await expect(dialog).toHaveCount(0);
  expect(state.writes.at(-1)).toEqual({ method: 'POST', path: '/pos/branches/branch_main/label_formats', body: { name: 'Tem giá quầy rau', prefix: '22', kind: 'price', item_code_length: 5, value_length: 5, value_decimals: 0, value_unit_code: null, price_tolerance: '500' } }); await expect(table.getByRole('row')).toHaveCount(3);
  await table.getByRole('button', { name: /^Cân quầy thịt/ }).click(); const edit = page.getByRole('dialog', { name: 'Sửa mẫu tem cân' }); await select(page, 'Đơn vị khối lượng trên tem', 'kg'); await edit.getByLabel('Số chữ số thập phân').fill('3'); await edit.getByRole('button', { name: 'Lưu', exact: true }).click(); await expect(edit).toHaveCount(0); expect(state.writes.at(-1)).toMatchObject({ method: 'PATCH', path: '/pos/branches/branch_main/label_formats/poslabel_1', body: { value_unit_code: 'kg', value_decimals: 3 } }); await expect(table.getByRole('row').filter({ hasText: 'Cân quầy thịt' })).toContainText('phiên bản 2');
  await act(page, 'Cân quầy thịt', 'Ngừng hoạt động'); await page.getByRole('dialog').getByRole('button', { name: 'Ngừng hoạt động', exact: true }).click(); await expect(table.getByRole('row').filter({ hasText: 'Cân quầy thịt' })).toContainText('đã ngừng'); expect(state.writes.at(-1)).toMatchObject({ method: 'POST', path: '/pos/branches/branch_main/label_formats/poslabel_1/disable' }); expect(formats[0].status).toBe('disabled'); expect(await fits(page)).toBe(true);
});
test('SKU selection, tracking restrictions, invalid/duplicate label codes and exact unit payload', async ({ page }) => {
  const { state, units } = await install(page); await open(page); await act(page, 'Gạo ST25', 'Đơn vị và mã tem'); const dialog = page.getByRole('dialog', { name: 'Đơn vị và mã tem cân' });
  await expect(dialog.getByLabel('SKU', { exact: true })).toContainText('ST25-5KG'); await expect(dialog.getByLabel('Đơn vị bán')).toContainText('item'); await select(page, 'SKU', 'ST25-BULK'); await expect(dialog.getByLabel('Đơn vị bán')).toContainText('kg'); await expect(dialog.getByLabel('Đơn vị gốc')).toHaveValue('g');
  const tracking = dialog.getByLabel('Theo dõi hàng'); await expect(tracking).toHaveAccessibleDescription(/Cửa hàng chưa bật theo dõi lô và serial/); await tracking.click(); await expect(page.getByRole('option', { name: 'Theo lô', exact: true })).toHaveAttribute('data-disabled', ''); await expect(page.getByRole('option', { name: 'Theo số serial', exact: true })).toHaveAttribute('data-disabled', ''); await page.keyboard.press('Escape');
  const code = dialog.getByLabel('Mã hàng trên tem cân'); await code.fill('12a'); await expect(dialog.getByText('Mã tem chỉ gồm tối đa 8 chữ số.')).toBeVisible(); const save = dialog.getByRole('button', { name: 'Lưu', exact: true }); await expect(save).toBeDisabled(); await code.fill('99999'); await save.click(); await expect(dialog.getByRole('alert')).toHaveText('Label code is already used by another SKU.'); await code.fill('00120'); await save.click(); await expect(dialog.getByRole('status').filter({ hasText: 'Đã lưu đơn vị và mã tem.' })).toBeVisible();
  expect(state.writes.at(-1)).toEqual({ method: 'PUT', path: '/pos/units/variant', body: { branch_id: 'branch_main', variant_id: 'variant_rice_bulk', sale_unit: 'kg', base_unit: 'g', price_unit: 'kg', ratio_numerator: 1, ratio_denominator: 1, tracked_mode: 'none', label_code: '00120' } }); expect(units.variant_rice_bulk.label_code).toBe('00120'); await expect(code).toHaveValue('00120'); await dialog.getByRole('button', { name: 'Hủy', exact: true }).click(); await expect(dialog).toHaveCount(0);
});
test('read-only administrators can read units and formats without write controls', async ({ page }) => {
  const { state } = await install(page, { read: true, write: false }); await open(page); const table = page.getByRole('table'); await expect(table.getByRole('row')).toHaveCount(26); await expect(page.getByText('Bạn chỉ có quyền xem danh sách này.')).toBeVisible();
  await table.getByRole('row').filter({ hasText: 'Gạo ST25' }).getByRole('button', { name: MENU }).click(); await expect(page.getByRole('menuitem')).toHaveText(['Đơn vị và mã tem']); await page.keyboard.press('Escape');
  await act(page, 'Gạo ST25', 'Đơn vị và mã tem'); const dialog = page.getByRole('dialog', { name: 'Đơn vị và mã tem cân' }); await expect(dialog.getByLabel('Đơn vị bán')).toBeDisabled(); await expect(dialog.getByRole('button', { name: 'Lưu', exact: true })).toHaveCount(0); await dialog.getByRole('button', { name: 'Đóng', exact: true }).click(); await page.locator('a[href="/store_1/branches/branch_main/label-formats"]').click(); await expect(page.getByRole('table')).toContainText('Cân quầy thịt'); await expect(page.getByRole('button', { name: 'Thêm mẫu tem' })).toHaveCount(0); await expect(page.getByRole('table').getByRole('button', { name: /^Cân quầy thịt/ })).toHaveCount(0); expect(state.writes).toEqual([]);
});
