import { expect, type Page, type Route, test } from '@playwright/test';

// Barcode scans and quick customer creation against a mocked server that keeps
// idempotency receipts, checks expected revisions and can lose responses.
type Line = { variantId: string; quantity: number };
type Product = { id: string; name: string; sku: string; barcode: string | null; price: string | null };
type Sheet = { id: string; revision: number; lines: Line[]; customer: { id: string; name: string; phone: string } | null };
type World = {
  generation: number;
  payments: boolean;
  sheets: Record<string, Sheet>;
  products: Product[];
  receipts: Map<string, unknown>;
  itemPosts: { key: string; expected: number; variantId: string }[];
  conflicts: number;
  // Requests to drop after the server already applied the first of them.
  dropItemResponses: number;
  customerPosts: { key: string; body: Record<string, unknown> }[];
  dropCustomerResponses: number;
  assignments: { workspaceId: string; profileId: string }[];
};

function product(index: number, barcode: string | null = `89300000${String(index).padStart(5, '0')}`): Product {
  return { id: `v_${index}`, name: `Hàng số ${index}`, sku: `SKU-${index}`, barcode, price: '10000.0' };
}

function newWorld(overrides: Partial<World> = {}): World {
  return {
    generation: 1,
    payments: false,
    sheets: { ws_1: { id: 'ws_1', revision: 0, lines: [], customer: null } },
    products: Array.from({ length: 20 }, (_, index) => product(index + 1)),
    receipts: new Map(),
    itemPosts: [],
    conflicts: 0,
    dropItemResponses: 0,
    customerPosts: [],
    dropCustomerResponses: 0,
    assignments: [],
    ...overrides,
  };
}

function workspace(world: World, sheet: Sheet) {
  return {
    id: sheet.id,
    branch_id: 'br_1',
    register_id: 'reg_1',
    shift_id: 'sh_1',
    order_id: `R-${sheet.id}`,
    revision: sheet.revision,
    lease_generation: world.generation,
    operational_status: 'editing',
    payments: world.payments,
    note: null,
    customer: sheet.customer
      ? { ...sheet.customer, email: null, customer_id: null, has_account: false }
      : null,
    line_items: sheet.lines.map((line, index) => {
      const item = world.products.find((candidate) => candidate.id === line.variantId);
      return {
        id: `line_${sheet.id}_${index + 1}`,
        sale_line_id: `sale_${sheet.id}_${index + 1}`,
        variant_id: line.variantId,
        name: item?.name ?? line.variantId,
        sku: item?.sku ?? '',
        quantity: line.quantity,
        price: '10000.0',
        unit_price: '10000.0',
        list_price: '10000.0',
        amount: String(10000 * line.quantity),
        kind: 'ordinary',
      };
    }),
  };
}

async function installApi(page: Page, world: World) {
  await page.route('**/api/v3/admin/**', async (route: Route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname;
    const method = request.method();
    const one = { page: 1, pages: 1, count: 1 };
    if (path.endsWith('/auth/login') || path.endsWith('/auth/refresh')) return route.fulfill({ json: { token: 'test-token' } });
    if (path.endsWith('/me')) return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Lan' } } });
    if (path.endsWith('/pos/context/branches')) return route.fulfill({ json: { data: [{ id: 'br_1', name: 'Branch', status: 'active' }], meta: one } });
    if (path.endsWith('/pos/context/registers')) {
      return route.fulfill({ json: { data: [{ id: 'reg_1', branch_id: 'br_1', name: 'Register', status: 'active' }], meta: one } });
    }
    if (path.endsWith('/pos/context')) {
      const branch = url.searchParams.get('branch_id');
      const register = url.searchParams.get('register_id');
      return route.fulfill({
        json: {
          staff: { id: 'stf_1', email: 'staff@example.test', full_name: 'Lan' },
          store: { id: 'store_1', name: 'Test', currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh' },
          capabilities: branch ? ['pos.shift.open', 'pos.customer.write'] : [],
          branches: [{ id: 'br_1', name: 'Branch', status: 'active' }],
          registers: branch ? [{ id: 'reg_1', branch_id: 'br_1', name: 'Register', status: 'active' }] : [],
          shift: register ? { id: 'sh_1', owner_id: 'stf_1', opening_float: '0', currency: 'VND' } : null,
          selection: { branch_id: branch, register_id: register },
        },
      });
    }
    // This branch has no scale label formats: every code is an ordinary barcode.
    if (path.endsWith('/pos/measurement_barcodes/parse')) {
      const barcode = String((request.postDataJSON() ?? {}).barcode ?? '');
      return route.fulfill({ json: { data: { kind: 'ordinary', barcode, measurement: null, capability: 'measured_labels' } } });
    }
    if (path.endsWith('/pos/catalog')) {
      const q = url.searchParams.get('q') ?? '';
      const exact = url.searchParams.get('barcode') === 'true';
      const rows = world.products.filter((item) =>
        exact ? item.barcode === q : `${item.name} ${item.sku} ${item.barcode ?? ''}`.toLowerCase().includes(q.toLowerCase()),
      );
      return route.fulfill({
        json: {
          data: rows.map((item) => ({ ...item, product_id: `p_${item.id}`, compare_at_price: null, currency: 'VND', stock_on_hand: 10 })),
          meta: { page: 1, pages: 1, count: rows.length, ambiguous: exact && rows.length > 1 },
        },
      });
    }
    if (path.endsWith('/pos/workspaces') && method === 'GET') {
      const sheets = Object.values(world.sheets);
      return route.fulfill({ json: { data: sheets.map((sheet) => workspace(world, sheet)), meta: { page: 1, pages: 1, count: sheets.length } } });
    }
    const match = /\/pos\/workspaces\/(ws_\d+)(\/.*)?$/.exec(path);
    const sheet = match ? world.sheets[match[1]] : undefined;
    if (sheet && !match?.[2] && method === 'GET') return route.fulfill({ json: { data: workspace(world, sheet) } });
    const body = (request.postDataJSON() ?? {}) as Record<string, unknown>;
    if (sheet && match?.[2] === '/lease') {
      if (method === 'POST') world.generation += 1;
      return route.fulfill({ json: { data: workspace(world, sheet) } });
    }
    if (path.endsWith('/pos/customers') && method === 'POST') {
      const key = String(body.idempotency_key);
      world.customerPosts.push({ key, body });
      if (!world.receipts.has(key)) {
        const id = `prof_${world.receipts.size + 1}`;
        world.receipts.set(key, { data: { id, name: body.name, phone: body.phone ?? null, email: body.email ?? null, customer_id: null, has_account: false, duplicates: [] } });
      }
      if (world.dropCustomerResponses > 0) {
        world.dropCustomerResponses -= 1;
        return route.abort('failed');
      }
      return route.fulfill({ status: 201, json: world.receipts.get(key) });
    }
    if (sheet && match?.[2] && method === 'POST') {
      const key = String(body.idempotency_key);
      const replay = world.receipts.get(key);
      if (match[2] === '/items') world.itemPosts.push({ key, expected: Number(body.expected_revision), variantId: String(body.variant_id) });
      if (replay) {
        if (match[2] === '/items' && world.dropItemResponses > 0) {
          world.dropItemResponses -= 1;
          return route.abort('failed');
        }
        return route.fulfill({ json: replay });
      }
      if (body.expected_revision !== sheet.revision || body.lease_generation !== world.generation) {
        world.conflicts += 1;
        return route.fulfill({ status: 409, json: { error: { code: 'conflict', message: 'Revision changed.', details: { reason: 'revision_changed', current_revision: sheet.revision } } } });
      }
      if (match[2] === '/items') {
        const existing = body.merge ? sheet.lines.find((line) => line.variantId === body.variant_id) : undefined;
        if (existing) existing.quantity += Number(body.quantity);
        else sheet.lines.push({ variantId: String(body.variant_id), quantity: Number(body.quantity) });
      } else if (match[2] === '/customer') {
        const profileId = String(body.profile_id);
        world.assignments.push({ workspaceId: sheet.id, profileId });
        sheet.customer = { id: profileId, name: 'Chị Mai', phone: '0901234567' };
      } else {
        return route.fulfill({ status: 404, json: { error: { code: 'missing', message: 'Not mocked.' } } });
      }
      sheet.revision += 1;
      const result = { data: workspace(world, sheet) };
      world.receipts.set(key, result);
      if (match[2] === '/items' && world.dropItemResponses > 0) {
        world.dropItemResponses -= 1;
        return route.abort('failed');
      }
      return route.fulfill({ json: result });
    }
    if (path.endsWith('/pos/command_receipts')) {
      const receipt = world.receipts.get(url.searchParams.get('idempotency_key') ?? '');
      return receipt ? route.fulfill({ json: receipt }) : route.fulfill({ status: 404, json: { error: { code: 'missing', message: 'No receipt.' } } });
    }
    return route.fulfill({ status: 404, json: { error: { code: 'missing', message: 'Not mocked.' } } });
  });
}

async function signInAndClaim(page: Page, workspaceId = 'ws_1') {
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('password');
  await page.getByRole('button', { name: 'Đăng nhập bán hàng', exact: true }).click();
  await expect(page.getByRole('tab', { name: 'Hóa đơn 1' })).toBeVisible();
  await page.locator(`[role="tab"][data-workspace-id="${workspaceId}"]`).click();
  await page.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();
  await expect(page.getByRole('button', { name: 'Tạm giữ' })).toBeEnabled();
}

// A hardware scanner is a keyboard that types a whole code within milliseconds,
// outside any text field. Playwright's keystrokes can arrive over 100ms apart
// on a loaded machine, which the page rightly treats as a person typing, so the
// burst is dispatched inside the page in one task, as a scanner would deliver it.
async function scan(page: Page, ...codes: string[]) {
  await page.evaluate((burst) => {
    (document.activeElement as HTMLElement | null)?.blur();
    const target = document.activeElement ?? document.body;
    for (const code of burst) {
      for (const key of [...code, 'Enter'])
        target.dispatchEvent(new KeyboardEvent('keydown', { key, bubbles: true, cancelable: true }));
    }
  }, codes);
}

test('a burst of scans adds every item in order, each from the previous revision', async ({ page }) => {
  const world = newWorld();
  await installApi(page, world);
  await signInAndClaim(page);
  await scan(page, ...world.products.map((item) => item.barcode ?? ''));
  await expect.poll(() => world.sheets.ws_1.lines.length, { timeout: 20_000 }).toBe(20);
  expect(world.conflicts).toBe(0);
  expect(world.itemPosts.map((post) => post.expected)).toEqual(Array.from({ length: 20 }, (_, i) => i));
  expect(world.itemPosts.map((post) => post.variantId)).toEqual(world.products.map((item) => item.id));
  expect(new Set(world.itemPosts.map((post) => post.key)).size).toBe(20);
  const basket = page.getByRole('table', { name: 'Hàng trong đơn' });
  await expect(basket.locator('td.basket-index')).toHaveCount(20);
  await expect(basket.locator('.basket-line-name strong')).toHaveText(world.products.map((item) => item.name));

  // Scanning a code already in the basket merges into its line.
  await scan(page, world.products[0].barcode ?? '');
  await expect.poll(() => world.sheets.ws_1.lines[0].quantity).toBe(2);
  expect(world.itemPosts.at(-1)?.expected).toBe(20);
  expect(world.conflicts).toBe(0);
});

test('a scan whose response is lost is retried with the same key and added once', async ({ page }) => {
  const world = newWorld();
  await installApi(page, world);
  await signInAndClaim(page);
  // Every automatic attempt fails, so the page must hold the scan for an explicit retry.
  world.dropItemResponses = 3;
  await scan(page, world.products[0].barcode ?? '');
  const retry = page.getByRole('button', { name: 'Thử lại quét' });
  await expect(retry).toBeVisible({ timeout: 15_000 });
  await expect(page.getByText('Chưa rõ kết quả quét mã', { exact: false })).toBeVisible();
  // A second scan waits behind the unknown one instead of racing it.
  await scan(page, world.products[1].barcode ?? '');
  await expect(page.getByRole('button', { name: 'Tạm giữ' })).toBeDisabled();
  expect(world.sheets.ws_1.lines).toEqual([{ variantId: 'v_1', quantity: 1 }]);
  await retry.click();
  await expect.poll(() => world.sheets.ws_1.lines.length).toBe(2);
  const first = world.itemPosts.filter((post) => post.variantId === 'v_1');
  expect(first.length).toBeGreaterThan(1);
  expect(new Set(first.map((post) => post.key)).size).toBe(1);
  expect(first.every((post) => post.expected === 0)).toBe(true);
  expect(world.sheets.ws_1.lines).toEqual([
    { variantId: 'v_1', quantity: 1 },
    { variantId: 'v_2', quantity: 1 },
  ]);
  expect(world.itemPosts.at(-1)).toMatchObject({ variantId: 'v_2', expected: 1 });
  expect(world.conflicts).toBe(0);
  await expect(page.getByRole('table', { name: 'Hàng trong đơn' }).locator('td.basket-index')).toHaveCount(2);
});

test('an ambiguous barcode adds nothing and shows the matching items to choose from', async ({ page }) => {
  const world = newWorld({
    products: [product(1, '8930000000999'), product(2, '8930000000999'), product(3)],
  });
  await installApi(page, world);
  await signInAndClaim(page);
  await scan(page, '8930000000999');
  await expect(page.getByText('Mã 8930000000999 khớp với nhiều mặt hàng', { exact: false })).toBeVisible();
  await expect(page.getByRole('searchbox', { name: 'Tìm hàng hoặc quét mã' })).toHaveValue('8930000000999');
  const results = page.getByRole('list', { name: 'Kết quả tìm hàng' });
  await expect(results.getByRole('button', { name: 'Thêm Hàng số 1', exact: true })).toBeEnabled();
  await expect(results.getByRole('button', { name: 'Thêm Hàng số 2', exact: true })).toBeEnabled();
  expect(world.itemPosts).toHaveLength(0);

  // An unknown code typed into the search box with Enter is not guessed either.
  const search = page.getByRole('searchbox', { name: 'Tìm hàng hoặc quét mã' });
  await search.fill('KHONG-CO');
  await search.press('Enter');
  await expect(page.getByText('Không có mặt hàng nào có mã vạch hoặc mã hàng đúng là KHONG-CO', { exact: false })).toBeVisible();
  expect(world.itemPosts).toHaveLength(0);

  // A unique code entered in the search box takes the same path as a scan.
  await search.fill('SKU-3');
  await search.press('Enter');
  await expect.poll(() => world.sheets.ws_1.lines).toEqual([{ variantId: 'v_3', quantity: 1 }]);
  await expect(search).toHaveValue('');
});

test('recorded payments lock every basket edit with an explanation', async ({ page }) => {
  const world = newWorld({ payments: true });
  world.sheets.ws_1.lines = [{ variantId: 'v_1', quantity: 2 }];
  world.sheets.ws_1.revision = 1;
  await installApi(page, world);
  await signInAndClaim(page);
  const reason = /Đơn đã ghi nhận thanh toán nên không thể sửa/;
  await expect(page.getByText(reason).first()).toBeVisible();
  const product1 = page.getByRole('button', { name: 'Thêm Hàng số 1', exact: true });
  await expect(product1).toBeDisabled();
  await expect(product1).toHaveAttribute('title', reason);
  for (const control of [
    page.getByRole('button', { name: 'Tăng số lượng Hàng số 1', exact: true }),
    page.getByRole('button', { name: 'Giảm số lượng Hàng số 1', exact: true }),
    page.getByRole('spinbutton', { name: 'Số lượng Hàng số 1', exact: true }),
    page.getByRole('button', { name: 'Xóa dòng Hàng số 1', exact: true }),
    page.getByRole('button', { name: 'Tạo khách nhanh' }),
  ]) {
    await expect(control).toBeDisabled();
    await expect(control).toHaveAttribute('title', reason);
  }
  await page.getByText('Ghi chú tại quầy').first().click();
  await expect(page.getByLabel('Ghi chú nội bộ của đơn nháp')).toBeDisabled();
  await scan(page, world.products[1].barcode ?? '');
  await page.waitForTimeout(300);
  expect(world.itemPosts).toHaveLength(0);
});

test('a quick-created customer survives a lost response and lands on the tab it was created from', async ({ page }) => {
  const world = newWorld();
  world.sheets.ws_2 = { id: 'ws_2', revision: 4, lines: [], customer: null };
  await installApi(page, world);
  await signInAndClaim(page, 'ws_2');
  await page.getByRole('button', { name: 'Tạo khách nhanh' }).click();
  await page.getByRole('textbox', { name: 'Tên khách', exact: true }).fill('Chị Mai');
  await page.getByRole('textbox', { name: 'Số điện thoại', exact: true }).fill('0901234567');
  world.dropCustomerResponses = 3;
  const submit = page.getByRole('button', { name: 'Tạo và gắn vào đơn' });
  await submit.click();
  await expect(page.locator('.customer-create-form').getByRole('alert')).toBeVisible({ timeout: 15_000 });
  await expect(page.locator('.customer-panel').getByRole('alert')).toHaveCount(1);
  expect(world.assignments).toHaveLength(0);
  await submit.click();
  await expect.poll(() => world.assignments).toEqual([{ workspaceId: 'ws_2', profileId: 'prof_1' }]);
  expect(world.customerPosts.length).toBeGreaterThan(1);
  expect(new Set(world.customerPosts.map((post) => post.key)).size).toBe(1);
  expect(world.customerPosts.every((post) => !('email' in post.body))).toBe(true);
  expect(world.receipts.size).toBeGreaterThan(0);
  expect(world.sheets.ws_1.customer).toBeNull();
  await expect(page.locator('.customer-selected')).toContainText('Chị Mai');
});
