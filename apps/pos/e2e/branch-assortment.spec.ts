import { expect, type Page, test } from '@playwright/test';

// Branch assortment, scale label formats and SKU label codes against a mocked
// Admin API. Presentation fixtures only: no real account privileges.
type Product = { id: string; name: string; status: string; skus: string[]; assigned: boolean };
type Format = {
  id: string; branch_id: string; name: string; prefix: string; kind: string; item_code_length: number; value_length: number;
  value_decimals: number; value_unit_code: string | null; price_tolerance: string; version: number; status: string;
};
type Write = { method: string; path: string; body: Record<string, unknown> | null };

const staff = { id: 'staff_admin', full_name: 'Quản trị Hiền', email: 'admin@example.test' };
const branch = { id: 'branch_main', name: 'Siêu thị Hiền', code: 'main', status: 'active', timezone: 'Asia/Ho_Chi_Minh', stock_location_id: 'stock_main', receiving_stock_location_id: null, receiving_note: null };
const variants = [
  { id: 'variant_rice_5', product_id: 'prod_rice', name: 'Gạo ST25', sku: 'ST25-5KG', barcode: '8930000000500', price: '180000.0', compare_at_price: null, currency: 'VND', stock_on_hand: 4 },
  { id: 'variant_rice_bulk', product_id: 'prod_rice', name: 'Gạo ST25', sku: 'ST25-BULK', barcode: null, price: '36000.0', compare_at_price: null, currency: 'VND', stock_on_hand: 50 },
];

async function install(page: Page, access = { read: true, write: true }) {
  const products: Product[] = [
    { id: 'prod_rice', name: 'Gạo ST25', status: 'active', skus: ['ST25-5KG', 'ST25-BULK'], assigned: true },
    ...Array.from({ length: 29 }, (_, index) => ({
      id: `prod_${index + 1}`, name: `Sản phẩm ${String(index + 1).padStart(2, '0')}`, status: 'active', skus: [`SP-${index + 1}`], assigned: false,
    })),
  ];
  const formats: Format[] = [
    { id: 'poslabel_1', branch_id: branch.id, name: 'Cân quầy thịt', prefix: '21', kind: 'weight', item_code_length: 5, value_length: 5, value_decimals: 0, value_unit_code: 'g', price_tolerance: '0.0', version: 1, status: 'active' },
  ];
  const units: Record<string, Record<string, unknown>> = {
    variant_rice_bulk: { variant_id: 'variant_rice_bulk', sale_unit: 'kg', base_unit: 'g', price_unit: 'kg', ratio_numerator: 1, ratio_denominator: 1, tracked_mode: 'none', version: 1, status: 'active', label_code: null },
  };
  const state = {
    writes: [] as Write[],
    productQueries: [] as Record<string, string>[],
    failNextProductWrite: '',
    takenLabelCodes: new Set(['99999']),
  };
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname.replace('/api/v3/admin', '');
    const method = request.method();
    const body = method === 'GET' || method === 'DELETE' ? null : ((request.postDataJSON() ?? {}) as Record<string, unknown>);
    if (method !== 'GET' && !/\/auth\//.test(path)) state.writes.push({ method, path, body });
    const conflict = (message: string) => route.fulfill({ status: 409, json: { error: { code: 'conflict', message } } });
    if (/\/auth\/(login|refresh)$/.test(path)) return route.fulfill({ json: { token: 'fixture-only' } });
    if (path === '/me') return route.fulfill({ json: { user: staff } });
    if (path === '/pos/context') return route.fulfill({ json: {
      staff, store: { id: 'store_1', name: 'Siêu thị Hiền', currency: 'VND' }, administration: access, capabilities: [],
      branches: [branch], registers: [], shift: null, selection: { branch_id: url.searchParams.get('branch_id'), register_id: null },
    } });
    if (path === '/pos/branches') return route.fulfill({ json: { data: [branch], meta: { next: null } } });
    if (path === '/pos/configuration/locations') return route.fulfill({ json: { data: [{ id: 'stock_main', name: 'Kho hàng trung tâm', active: true }], meta: { next: null } } });

    const productMatch = /^\/pos\/branches\/branch_main\/products(?:\/([^/]+))?$/.exec(path);
    if (productMatch && method === 'GET') {
      const params = Object.fromEntries(url.searchParams.entries());
      state.productQueries.push(params);
      const q = (params.q ?? '').toLocaleLowerCase();
      const rows = products.filter((product) =>
        (!q || product.name.toLocaleLowerCase().includes(q) || product.skus.some((sku) => sku.toLocaleLowerCase().includes(q))) &&
        (params.assigned === undefined || String(product.assigned) === params.assigned));
      const limit = Number(params.limit || 25);
      const current = Number(params.page || 1);
      const pages = Math.ceil(rows.length / limit);
      return route.fulfill({ json: { data: rows.slice((current - 1) * limit, current * limit), meta: { page: current, pages, count: rows.length, next: current < pages ? current + 1 : null } } });
    }
    if (productMatch) {
      const id = method === 'POST' ? String(body?.product_id) : productMatch[1];
      const product = products.find((item) => item.id === id);
      if (!product) return route.fulfill({ status: 404, json: { error: { code: 'not_found', message: 'Not found' } } });
      if (state.failNextProductWrite === id) {
        state.failNextProductWrite = '';
        return conflict('Product is archived.');
      }
      product.assigned = method === 'POST';
      return method === 'POST' ? route.fulfill({ status: 201, json: { data: { branch_id: branch.id, product_id: id } } }) : route.fulfill({ status: 204, body: '' });
    }

    const formatMatch = /^\/pos\/branches\/branch_main\/label_formats(?:\/([^/]+))?(\/disable)?$/.exec(path);
    if (formatMatch && method === 'GET') return route.fulfill({ json: { data: formats, meta: { page: 1, pages: 1, count: formats.length, next: null } } });
    if (formatMatch && method === 'POST' && !formatMatch[1]) {
      if (formats.some((format) => format.status === 'active' && format.prefix === body?.prefix)) return conflict('Another active label format uses this prefix.');
      const created = { ...(body as unknown as Format), id: `poslabel_${formats.length + 1}`, branch_id: branch.id, version: 1, status: 'active' };
      formats.push(created);
      return route.fulfill({ status: 201, json: { data: created } });
    }
    if (formatMatch?.[1]) {
      const format = formats.find((item) => item.id === formatMatch[1]);
      if (!format) return route.fulfill({ status: 404, json: { error: { code: 'not_found', message: 'Not found' } } });
      if (formatMatch[2]) format.status = 'disabled';
      else Object.assign(format, body, { version: format.version + 1 });
      return route.fulfill({ json: { data: format } });
    }

    if (path === '/pos/catalog') {
      const q = (url.searchParams.get('q') ?? '').toLocaleLowerCase();
      const rows = variants.filter((variant) => products.find((product) => product.id === variant.product_id)?.assigned && variant.name.toLocaleLowerCase().includes(q));
      return route.fulfill({ json: { data: rows, meta: { page: 1, pages: 1, count: rows.length, ambiguous: false } } });
    }
    if (path === '/pos/units') return route.fulfill({ json: { data: [
      { id: 'u1', code: 'item', name: 'Cái', dimension: 'count', base_code: 'item', factor_to_base: '1', sale_precision: 0, version: 1 },
      { id: 'u2', code: 'g', name: 'Gram', dimension: 'mass', base_code: 'g', factor_to_base: '1', sale_precision: 0, version: 1 },
      { id: 'u3', code: 'kg', name: 'Kilogram', dimension: 'mass', base_code: 'g', factor_to_base: '1000', sale_precision: 3, version: 1 },
    ] } });
    if (path === '/pos/units/variant' && method === 'GET') {
      const id = url.searchParams.get('variant_id') ?? '';
      return route.fulfill({ json: { data: units[id] ?? { variant_id: id, sale_unit: 'item', base_unit: 'item', price_unit: 'item', ratio_numerator: 1, ratio_denominator: 1, tracked_mode: 'none', version: 1, status: 'default' } } });
    }
    if (path === '/pos/units/variant' && method === 'PUT') {
      if (state.takenLabelCodes.has(String(body?.label_code))) return conflict('Label code is already used by another SKU.');
      const id = String(body?.variant_id);
      units[id] = { ...body, version: 1, status: 'active' };
      return route.fulfill({ json: { data: units[id] } });
    }
    // The store keeps serial and lot tracking off.
    if (path === '/pos/feature_flags' && method === 'GET')
      return route.fulfill({ json: { data: {
        branch_id: branch.id, features: { traceability: false },
        switches: { traceability: { store: false, branch_override: null, effective: false } }, settings: [],
      } } });
    return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0, next: null } } });
  });
  return { state, products, formats, units };
}

async function openBranchPage(page: Page, link: 'Hàng bán tại chi nhánh' | 'Mẫu tem cân') {
  await page.goto('/pos/login');
  await page.getByLabel('Email nhân viên').fill('admin@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('fixture-only');
  await page.getByRole('button', { name: 'Đăng nhập vào quản trị bán hàng', exact: true }).click();
  await expect(page).toHaveURL(/\/pos\/settings$/);
  await page.getByRole('link', { name: `${link} Siêu thị Hiền`, exact: true }).click();
}

const noHorizontalScroll = (page: Page) => page.evaluate(() => document.documentElement.scrollWidth <= innerWidth);

test('search, filter, page through, assign and remove branch products', async ({ page }) => {
  const { state, products } = await install(page);
  await openBranchPage(page, 'Hàng bán tại chi nhánh');
  await expect(page).toHaveURL(/\/pos\/settings\/branches\/branch_main\/products$/);
  await expect(page.getByRole('heading', { level: 1 })).toHaveText('Hàng bán tại chi nhánh · Siêu thị Hiền');
  const list = page.getByRole('list', { name: 'Danh sách sản phẩm của chi nhánh' });
  await expect(list.getByRole('listitem')).toHaveCount(25);
  await expect(page.getByText('Trang 1/2 · 30 sản phẩm')).toBeVisible();
  await page.getByRole('button', { name: 'Trang sau' }).click();
  await expect(list.getByRole('listitem')).toHaveCount(5);
  expect(await noHorizontalScroll(page)).toBe(true);

  await page.getByRole('searchbox', { name: 'Tìm sản phẩm' }).fill('sp-12');
  await expect(list.getByRole('listitem')).toHaveCount(1);
  expect(state.productQueries.at(-1)).toMatchObject({ q: 'sp-12', page: '1' });
  const row = list.getByRole('listitem').filter({ hasText: 'Sản phẩm 12' });
  await expect(row).toContainText('chưa bán');
  await row.getByRole('button', { name: 'Thêm vào chi nhánh Sản phẩm 12', exact: true }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã thêm “Sản phẩm 12” vào chi nhánh.' })).toBeVisible();
  await expect(row).toContainText('đang bán');
  expect(state.writes.at(-1)).toEqual({ method: 'POST', path: '/pos/branches/branch_main/products', body: { product_id: 'prod_12' } });

  await page.getByRole('searchbox', { name: 'Tìm sản phẩm' }).fill('');
  await page.getByLabel('Hiển thị').selectOption('assigned');
  await expect(list.getByRole('listitem')).toHaveCount(2);
  expect(state.productQueries.at(-1)).toMatchObject({ assigned: 'true', page: '1' });
  await list.getByRole('button', { name: 'Gỡ khỏi chi nhánh Sản phẩm 12', exact: true }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã gỡ “Sản phẩm 12” khỏi chi nhánh.' })).toBeVisible();
  await expect(list.getByRole('listitem')).toHaveCount(1);
  expect(state.writes.at(-1)).toMatchObject({ method: 'DELETE', path: '/pos/branches/branch_main/products/prod_12' });

  // A refused change keeps the row as the server has it and explains why.
  state.failNextProductWrite = 'prod_rice';
  await list.getByRole('button', { name: 'Gỡ khỏi chi nhánh Gạo ST25', exact: true }).click();
  await expect(page.getByRole('alert')).toHaveText('Không cập nhật được “Gạo ST25”: Product is archived.');
  await expect(list.getByRole('listitem').filter({ hasText: 'Gạo ST25' })).toContainText('đang bán');
  expect(products.find((product) => product.id === 'prod_rice')?.assigned).toBe(true);

  await page.getByLabel('Hiển thị').selectOption('unassigned');
  await expect(page.getByText('Trang 1/2 · 29 sản phẩm')).toBeVisible();
  expect(state.productQueries.at(-1)).toMatchObject({ assigned: 'false' });
  expect(await noHorizontalScroll(page)).toBe(true);
});

test('label formats block an invalid layout and can be created, edited and disabled', async ({ page }) => {
  const { state, formats } = await install(page);
  page.on('dialog', (dialog) => dialog.accept());
  await openBranchPage(page, 'Mẫu tem cân');
  const list = page.getByRole('list', { name: 'Danh sách mẫu tem cân' });
  await expect(list).toContainText('Tiền tố 21 · mã hàng 5 số · giá trị 5 số');

  await page.getByRole('button', { name: 'Thêm mẫu tem', exact: true }).click();
  const dialog = page.getByRole('dialog', { name: 'Thêm mẫu tem cân' });
  await dialog.getByLabel('Tên mẫu').fill('Tem giá quầy rau');
  await dialog.getByLabel('Loại tem').selectOption('price');
  await dialog.getByLabel('Tiền tố').fill('2');
  await dialog.getByLabel('Số chữ số mã hàng').fill('6');
  await dialog.getByLabel('Số chữ số giá trị').fill('6');
  await expect(dialog.getByText('Đang dùng 13/12 chữ số.', { exact: false })).toBeVisible();
  await expect(dialog.getByText('Tiền tố + mã hàng + giá trị phải bằng đúng 12 chữ số.')).toBeVisible();
  const save = dialog.getByRole('button', { name: 'Lưu', exact: true });
  await expect(save).toBeDisabled();
  await dialog.getByLabel('Số chữ số giá trị').press('Enter');
  expect(state.writes).toEqual([]);

  // A prefix already used by an active format is refused by the server.
  await dialog.getByLabel('Tiền tố').fill('21');
  await dialog.getByLabel('Số chữ số mã hàng').fill('5');
  await dialog.getByLabel('Số chữ số giá trị').fill('5');
  await dialog.getByLabel('Sai lệch giá cho phép').fill('500');
  await expect(dialog.getByText('Đủ 12/12 chữ số', { exact: false })).toBeVisible();
  await save.click();
  await expect(dialog.getByRole('alert')).toHaveText('Another active label format uses this prefix.');
  await dialog.getByLabel('Tiền tố').fill('22');
  await save.click();
  await expect(dialog).toHaveCount(0);
  expect(state.writes.at(-1)).toEqual({
    method: 'POST', path: '/pos/branches/branch_main/label_formats',
    body: { name: 'Tem giá quầy rau', prefix: '22', kind: 'price', item_code_length: 5, value_length: 5, value_decimals: 0, value_unit_code: null, price_tolerance: '500' },
  });
  await expect(list.getByRole('listitem')).toHaveCount(2);

  await list.getByRole('button', { name: 'Chỉnh sửa Cân quầy thịt', exact: true }).click();
  const edit = page.getByRole('dialog', { name: 'Sửa mẫu tem cân' });
  await edit.getByLabel('Đơn vị khối lượng trên tem').selectOption('kg');
  await edit.getByLabel('Số chữ số thập phân').fill('3');
  await edit.getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect(edit).toHaveCount(0);
  expect(state.writes.at(-1)).toMatchObject({ method: 'PATCH', path: '/pos/branches/branch_main/label_formats/poslabel_1', body: { value_unit_code: 'kg', value_decimals: 3 } });
  await expect(list.getByRole('listitem').filter({ hasText: 'Cân quầy thịt' })).toContainText('phiên bản 2');

  await list.getByRole('button', { name: 'Ngừng mẫu tem Cân quầy thịt', exact: true }).click();
  await expect(list.getByRole('listitem').filter({ hasText: 'Cân quầy thịt' })).toContainText('đã ngừng');
  expect(state.writes.at(-1)).toMatchObject({ method: 'POST', path: '/pos/branches/branch_main/label_formats/poslabel_1/disable' });
  expect(formats[0].status).toBe('disabled');
  expect(await noHorizontalScroll(page)).toBe(true);
});

test('a SKU label code is saved from the assortment row for the chosen variant', async ({ page }) => {
  const { state, units } = await install(page);
  await openBranchPage(page, 'Hàng bán tại chi nhánh');
  await page.getByRole('button', { name: 'Đơn vị và mã tem Gạo ST25', exact: true }).click();
  const dialog = page.getByRole('dialog', { name: 'Đơn vị và mã tem cân' });
  const variant = dialog.getByLabel('SKU', { exact: true });
  await expect(variant).toHaveValue('variant_rice_5');
  await expect(dialog.getByLabel('Đơn vị bán')).toHaveValue('item');
  await variant.selectOption('variant_rice_bulk');
  await expect(dialog.getByLabel('Đơn vị bán')).toHaveValue('kg');
  await expect(dialog.getByLabel('Đơn vị gốc')).toHaveValue('g');
  // Serial or lot tracking cannot be chosen while the store keeps it off.
  const tracking = dialog.getByLabel('Theo dõi hàng');
  await expect(tracking).toHaveAccessibleDescription(/Cửa hàng chưa bật theo dõi lô và serial/);
  await expect(tracking.locator('option[value="lot"]')).toHaveJSProperty('disabled', true);
  await expect(tracking.locator('option[value="serial"]')).toHaveJSProperty('disabled', true);
  await expect(tracking.locator('option[value="none"]')).toHaveJSProperty('disabled', false);

  const code = dialog.getByLabel('Mã hàng trên tem cân');
  await code.fill('12a');
  await expect(dialog.getByText('Mã tem chỉ gồm tối đa 8 chữ số.')).toBeVisible();
  const save = dialog.getByRole('button', { name: 'Lưu', exact: true });
  await expect(save).toBeDisabled();
  await code.fill('99999');
  await save.click();
  await expect(dialog.getByRole('alert')).toHaveText('Label code is already used by another SKU.');
  await code.fill('00120');
  await save.click();
  await expect(dialog.getByRole('status').filter({ hasText: 'Đã lưu đơn vị và mã tem.' })).toBeVisible();
  expect(state.writes.at(-1)).toEqual({
    method: 'PUT', path: '/pos/units/variant',
    body: { branch_id: 'branch_main', variant_id: 'variant_rice_bulk', sale_unit: 'kg', base_unit: 'g', price_unit: 'kg', ratio_numerator: 1, ratio_denominator: 1, tracked_mode: 'none', label_code: '00120' },
  });
  expect(units.variant_rice_bulk.label_code).toBe('00120');
  await expect(code).toHaveValue('00120');
  await dialog.getByRole('button', { name: 'Hủy', exact: true }).click();
  await expect(dialog).toHaveCount(0);
});

test('read-only administrators see the assortment and formats without write controls', async ({ page }) => {
  const { state } = await install(page, { read: true, write: false });
  await openBranchPage(page, 'Hàng bán tại chi nhánh');
  const list = page.getByRole('list', { name: 'Danh sách sản phẩm của chi nhánh' });
  await expect(list.getByRole('listitem')).toHaveCount(25);
  await expect(page.getByText('Bạn chỉ có quyền xem danh sách này.')).toBeVisible();
  await expect(list.getByRole('button', { name: /^(Thêm vào|Gỡ khỏi) chi nhánh/ })).toHaveCount(0);
  await page.getByRole('button', { name: 'Đơn vị và mã tem Gạo ST25', exact: true }).click();
  const dialog = page.getByRole('dialog', { name: 'Đơn vị và mã tem cân' });
  await expect(dialog.getByLabel('Đơn vị bán')).toBeDisabled();
  await expect(dialog.getByRole('button', { name: 'Lưu', exact: true })).toHaveCount(0);
  await dialog.getByRole('button', { name: 'Đóng', exact: true }).last().click();
  await page.getByRole('link', { name: 'Mẫu tem cân', exact: true }).click();
  await expect(page.getByRole('list', { name: 'Danh sách mẫu tem cân' })).toContainText('Cân quầy thịt');
  await expect(page.getByRole('button', { name: 'Thêm mẫu tem' })).toHaveCount(0);
  await expect(page.getByRole('button', { name: 'Chỉnh sửa Cân quầy thịt' })).toHaveCount(0);
  expect(state.writes).toEqual([]);
});
