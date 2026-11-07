import { expect, type Page, type Route, test } from '@playwright/test';

// Scale label scans against a mocked server that reads labels per branch, keeps
// idempotency receipts, refuses a reused measurement id and can lose responses.
type Line = {
  variantId: string;
  quantity: number;
  label?: { barcode: string; eventId: string; saleQuantity: string; baseQuantity: number };
};
type Product = { id: string; name: string; sku: string; barcode: string | null };
type LabelRead = { variantId: string; saleQuantity: string; baseQuantity: number };
type ItemPost = { key: string; expected: number; body: Record<string, unknown> };
type World = {
  revision: number;
  lines: Line[];
  products: Product[];
  // Labels the branch formats claim, by barcode; a string is the 409 refusal.
  labels: Record<string, LabelRead | string>;
  parses: string[];
  receipts: Map<string, unknown>;
  itemPosts: ItemPost[];
  dropItemResponses: number;
};

const WEIGHT_LABEL = '2100012005008';
const OTHER_LABEL = '2100012003004';
const BAD_LABEL = '2100012005009';

function newWorld(): World {
  return {
    revision: 0,
    lines: [],
    products: [
      { id: 'v_pork', name: 'Thịt heo ba chỉ', sku: 'PORK', barcode: null },
      { id: 'v_water', name: 'Nước suối', sku: 'WATER', barcode: '8930000000017' },
    ],
    labels: {
      [WEIGHT_LABEL]: { variantId: 'v_pork', saleQuantity: '0.5', baseQuantity: 500 },
      [OTHER_LABEL]: { variantId: 'v_pork', saleQuantity: '0.3', baseQuantity: 300 },
      [BAD_LABEL]: 'Label check digit is invalid.',
    },
    parses: [],
    receipts: new Map(),
    itemPosts: [],
    dropItemResponses: 0,
  };
}

function workspace(world: World) {
  return {
    id: 'ws_1',
    branch_id: 'br_1',
    register_id: 'reg_1',
    shift_id: 'sh_1',
    order_id: 'R-ws_1',
    revision: world.revision,
    lease_generation: 1,
    operational_status: 'editing',
    payments: false,
    note: null,
    customer: null,
    line_items: world.lines.map((line, index) => {
      const item = world.products.find((candidate) => candidate.id === line.variantId);
      return {
        id: `line_${index + 1}`,
        sale_line_id: `sale_${index + 1}`,
        variant_id: line.variantId,
        name: item?.name ?? line.variantId,
        sku: item?.sku ?? '',
        quantity: line.label ? line.label.baseQuantity : line.quantity,
        price: '120.0',
        unit_price: line.label ? '120000.0' : '5000.0',
        amount: line.label ? String(line.label.baseQuantity * 120) : String(5000 * line.quantity),
        discounts: [],
        kind: line.label ? 'measured' : 'ordinary',
        sale_quantity: line.label?.saleQuantity,
        sale_unit: line.label ? 'kg' : 'item',
        base_quantity: line.label?.baseQuantity ?? line.quantity,
        base_unit: line.label ? 'g' : 'item',
        label_barcode: line.label?.barcode ?? null,
        label_format_version: line.label ? 2 : null,
      };
    }),
  };
}

const conflict = (message: string) => ({ status: 409, json: { error: { code: 'conflict', message } } });

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
          capabilities: branch ? ['pos.shift.open'] : [],
          branches: [{ id: 'br_1', name: 'Branch', status: 'active' }],
          registers: branch ? [{ id: 'reg_1', branch_id: 'br_1', name: 'Register', status: 'active' }] : [],
          shift: register ? { id: 'sh_1', owner_id: 'stf_1', opening_float: '0', currency: 'VND' } : null,
          selection: { branch_id: branch, register_id: register },
        },
      });
    }
    const body = (request.postDataJSON() ?? {}) as Record<string, unknown>;
    if (path.endsWith('/pos/measurement_barcodes/parse')) {
      const barcode = String(body.barcode);
      world.parses.push(barcode);
      if (body.branch_id !== 'br_1') return route.fulfill({ status: 404, json: { error: { code: 'missing', message: 'Unknown branch.' } } });
      const label = world.labels[barcode];
      if (typeof label === 'string') return route.fulfill(conflict(label));
      if (!label) return route.fulfill({ json: { data: { kind: 'ordinary', barcode, measurement: null, capability: 'measured_labels' } } });
      const item = world.products.find((product) => product.id === label.variantId);
      return route.fulfill({
        json: {
          data: {
            kind: 'measured_label', barcode, capability: 'measured_labels', format_id: 'poslabel_1', format_version: 2,
            label_kind: 'weight', variant_id: label.variantId, name: item?.name, sku: item?.sku,
            sale_quantity: label.saleQuantity, sale_unit: 'kg', base_quantity: label.baseQuantity, base_unit: 'g',
            unit_price: '120000.0', currency: 'VND', line_amount: String(label.baseQuantity * 120), label_amount: null,
          },
        },
      });
    }
    if (path.endsWith('/pos/catalog')) {
      const q = url.searchParams.get('q') ?? '';
      const exact = url.searchParams.get('barcode') === 'true';
      const rows = world.products.filter((item) =>
        exact ? item.barcode === q : `${item.name} ${item.sku} ${item.barcode ?? ''}`.toLowerCase().includes(q.toLowerCase()),
      );
      return route.fulfill({
        json: {
          data: rows.map((item) => ({ ...item, price: '5000.0', product_id: `p_${item.id}`, compare_at_price: null, currency: 'VND', stock_on_hand: 10 })),
          meta: { page: 1, pages: 1, count: rows.length, ambiguous: false },
        },
      });
    }
    if (path.endsWith('/pos/workspaces') && method === 'GET') {
      return route.fulfill({ json: { data: [workspace(world)], meta: { page: 1, pages: 1, count: 1 } } });
    }
    if (path.endsWith('/pos/workspaces/ws_1') && method === 'GET') return route.fulfill({ json: { data: workspace(world) } });
    if (path.endsWith('/pos/workspaces/ws_1/lease')) return route.fulfill({ json: { data: workspace(world) } });
    if (path.endsWith('/pos/workspaces/ws_1/items') && method === 'POST') {
      const key = String(body.idempotency_key);
      world.itemPosts.push({ key, expected: Number(body.expected_revision), body });
      const drop = () => {
        world.dropItemResponses -= 1;
        return route.abort('failed');
      };
      const replay = world.receipts.get(key);
      if (replay) return world.dropItemResponses > 0 ? drop() : route.fulfill({ json: replay });
      if (body.expected_revision !== world.revision) return route.fulfill(conflict('Revision changed.'));
      if (body.label_barcode) {
        const barcode = String(body.label_barcode);
        const eventId = String(body.measurement_event_id ?? '');
        const label = world.labels[barcode];
        if (!label || typeof label === 'string') return route.fulfill(conflict('Barcode is not a scale label of this branch.'));
        // The label alone decides the line; the client must not supply its own figures.
        if (['variant_id', 'quantity', 'sale_quantity', 'price_override'].some((field) => field in body))
          return route.fulfill(conflict('A scale label already carries its quantity and price.'));
        if (world.lines.some((line) => line.label?.eventId === eventId)) return route.fulfill(conflict('This measurement was already added.'));
        world.lines.push({ variantId: label.variantId, quantity: 1, label: { barcode, eventId, saleQuantity: label.saleQuantity, baseQuantity: label.baseQuantity } });
      } else {
        const existing = body.merge ? world.lines.find((line) => !line.label && line.variantId === body.variant_id) : undefined;
        if (existing) existing.quantity += Number(body.quantity);
        else world.lines.push({ variantId: String(body.variant_id), quantity: Number(body.quantity) });
      }
      world.revision += 1;
      const result = { data: workspace(world) };
      world.receipts.set(key, result);
      return world.dropItemResponses > 0 ? drop() : route.fulfill({ json: result });
    }
    if (path.endsWith('/pos/command_receipts')) {
      const receipt = world.receipts.get(url.searchParams.get('idempotency_key') ?? '');
      return receipt ? route.fulfill({ json: receipt }) : route.fulfill({ status: 404, json: { error: { code: 'missing', message: 'No receipt.' } } });
    }
    return route.fulfill({ status: 404, json: { error: { code: 'missing', message: 'Not mocked.' } } });
  });
}

async function signInAndClaim(page: Page) {
  await page.goto('/pos/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('password');
  await page.getByRole('button', { name: 'Đăng nhập vào bán hàng', exact: true }).click();
  await expect(page.getByRole('tab', { name: 'Hóa đơn 1' })).toBeVisible();
  await page.locator('[role="tab"][data-workspace-id="ws_1"]').click();
  await page.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();
  await expect(page.getByRole('button', { name: 'Tạm giữ' })).toBeEnabled();
}

// A scanner types the whole code within milliseconds outside any text field.
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

const labelPosts = (world: World, barcode: string) => world.itemPosts.filter((post) => post.body.label_barcode === barcode);

test('a weight label scan adds its own line from the label with a measurement id', async ({ page }) => {
  const world = newWorld();
  await installApi(page, world);
  await signInAndClaim(page);
  await scan(page, WEIGHT_LABEL);
  await expect.poll(() => world.lines.length).toBe(1);
  const [post] = labelPosts(world, WEIGHT_LABEL);
  expect(post.body).toMatchObject({ label_barcode: WEIGHT_LABEL, expected_revision: 0, lease_generation: 1 });
  expect(post.body.measurement_event_id).toMatch(/^[0-9a-f-]{36}$/);
  for (const field of ['variant_id', 'quantity', 'sale_quantity', 'price_override']) expect(post.body).not.toHaveProperty(field);
  const basket = page.getByRole('table', { name: 'Hàng trong đơn' });
  await expect(basket.locator('.basket-line-name strong')).toHaveText(['Thịt heo ba chỉ']);
  await expect(basket.getByText(`Tem cân ${WEIGHT_LABEL} · mẫu tem phiên bản 2`)).toBeVisible();
  // The label fixes the package's quantity, so the basket does not offer to edit it.
  await expect(basket.locator('input[id^="quantity-"]').first()).toBeDisabled();
  await expect(basket.getByText('0.5 kg (500 g)', { exact: false })).toBeVisible();

  // Each scan is a new weighing: the same and another label never merge into it.
  await scan(page, WEIGHT_LABEL, OTHER_LABEL);
  await expect.poll(() => world.lines.length).toBe(3);
  const events = world.itemPosts.map((item) => item.body.measurement_event_id);
  expect(new Set(events).size).toBe(3);
  expect(world.itemPosts.map((item) => item.expected)).toEqual([0, 1, 2]);
  await expect(basket.locator('td.basket-index')).toHaveCount(3);
});

test('a label scan whose response is lost is retried with the same key and measurement id', async ({ page }) => {
  const world = newWorld();
  await installApi(page, world);
  await signInAndClaim(page);
  world.dropItemResponses = 3;
  await scan(page, WEIGHT_LABEL);
  const retry = page.getByRole('button', { name: 'Thử lại quét' });
  await expect(retry).toBeVisible({ timeout: 15_000 });
  expect(world.lines).toHaveLength(1);
  await retry.click();
  await expect(page.getByRole('button', { name: 'Thử lại quét' })).toHaveCount(0);
  await expect(page.getByRole('table', { name: 'Hàng trong đơn' }).locator('td.basket-index')).toHaveCount(1);
  const posts = labelPosts(world, WEIGHT_LABEL);
  expect(posts.length).toBeGreaterThan(1);
  expect(new Set(posts.map((post) => post.key)).size).toBe(1);
  expect(new Set(posts.map((post) => post.body.measurement_event_id)).size).toBe(1);
  expect(posts.every((post) => post.expected === 0)).toBe(true);
  // The label was read once; retries replay the add, they do not parse again.
  expect(world.parses).toEqual([WEIGHT_LABEL]);
  expect(world.lines).toHaveLength(1);
});

test('an ordinary code is not a label and falls back to the barcode lookup', async ({ page }) => {
  const world = newWorld();
  await installApi(page, world);
  await signInAndClaim(page);
  await scan(page, '8930000000017');
  await expect.poll(() => world.lines).toEqual([{ variantId: 'v_water', quantity: 1 }]);
  expect(world.parses).toEqual(['8930000000017']);
  expect(world.itemPosts[0].body).toMatchObject({ variant_id: 'v_water', quantity: 1, merge: true });
  expect(world.itemPosts[0].body).not.toHaveProperty('label_barcode');
  expect(world.itemPosts[0].body).not.toHaveProperty('measurement_event_id');
  await expect(page.locator('.basket-line-label')).toHaveCount(0);
});

test('a refused label shows the server reason and adds nothing', async ({ page }) => {
  const world = newWorld();
  await installApi(page, world);
  await signInAndClaim(page);
  await scan(page, BAD_LABEL);
  await expect(page.getByText(`Tem cân ${BAD_LABEL} không hợp lệ: Label check digit is invalid. Chưa thêm gì.`)).toBeVisible();
  await page.waitForTimeout(300);
  expect(world.itemPosts).toHaveLength(0);
  expect(world.lines).toHaveLength(0);
  await expect(page.getByRole('button', { name: 'Thử lại quét' })).toHaveCount(0);
  // The queue keeps working after the refusal.
  await scan(page, WEIGHT_LABEL);
  await expect.poll(() => world.lines.length).toBe(1);
});
