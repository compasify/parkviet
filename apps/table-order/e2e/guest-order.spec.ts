import { expect, type Page, test } from '@playwright/test';

// A guest's phone at a table, against a mocked guest API: the sticker's code
// is exchanged for a session and leaves the address, a dish is picked with
// its options, the order waits for staff and then shows as sent to the
// kitchen, and staff are called. Presentation fixtures only.

const CODE = 'Zk3_9qLmT0aBcDeFgHiJkA';
const TOKEN = 'guest-session-token-0123456789';

type Api = {
  status: 'open' | 'table_closed';
  orders: Record<string, unknown>[];
  requests: Record<string, unknown>[];
  submitted: { body: Record<string, unknown>; key: string | null }[];
  authorizations: (string | null)[];
};

const session = (status: Api['status']) => ({
  id: 'posguest_1',
  status,
  expires_at: '2026-11-12T16:00:00Z',
  table: { name: 'Bàn 4', kind: 'table' },
  branch: { name: 'Quận 1', store_name: 'Quán Trà' },
  currency: 'VND',
  approval: 'staff_approval',
  timed: false,
});

const menu = {
  currency: 'VND',
  etag: 'e1',
  categories: [
    { id: 'cat_tea', name: 'Trà', position: 1, color: null },
    { id: 'cat_cake', name: 'Bánh', position: 2, color: null },
  ],
  items: [
    {
      id: 'mi_tea',
      name: 'Trà đào',
      kind: 'single',
      menu_category_id: 'cat_tea',
      position: 1,
      image_url: null,
      sold_out: false,
      modifier_group_ids: ['grp_sugar', 'grp_top'],
      components: [],
      variants: [
        { id: 'v_tea_m', name: 'M', price: '30000.0', price_label: null },
        { id: 'v_tea_l', name: 'L', price: '35000.0', price_label: null },
      ],
    },
    {
      id: 'mi_flan',
      name: 'Bánh flan',
      kind: 'single',
      menu_category_id: 'cat_cake',
      position: 2,
      image_url: null,
      sold_out: true,
      modifier_group_ids: [],
      components: [],
      variants: [{ id: 'v_flan', name: null, price: '15000.0', price_label: null }],
    },
  ],
  modifier_groups: [
    {
      id: 'grp_sugar',
      name: 'Đường',
      min_select: 1,
      max_select: 1,
      allow_quantity: false,
      required: true,
      options: [
        { id: 'opt_full', name: '100%', price_delta: '0.0', default_selected: false },
        { id: 'opt_half', name: '50%', price_delta: '0.0', default_selected: false },
      ],
    },
    {
      id: 'grp_top',
      name: 'Topping',
      min_select: 0,
      max_select: 2,
      allow_quantity: false,
      required: false,
      options: [
        { id: 'opt_pearl', name: 'Trân châu', price_delta: '5000.0', default_selected: false },
      ],
    },
  ],
};

async function install(page: Page, api: Api) {
  await page.route('**/api/v3/pos_guest/**', async (route) => {
    const request = route.request();
    const path = new URL(request.url()).pathname.replace(/^.*\/api\/v3\/pos_guest/, '');
    const method = request.method();
    if (!(path === '/session' && method === 'POST'))
      api.authorizations.push(request.headers().authorization ?? null);
    if (path === '/session' && method === 'POST') {
      const body = request.postDataJSON() as { table_code?: string };
      if (body.table_code !== CODE)
        return route.fulfill({ status: 404, json: { error: { code: 'table_code_invalid', message: 'x' } } });
      return route.fulfill({ status: 201, json: { data: { ...session(api.status), token: TOKEN } } });
    }
    if (request.headers().authorization !== `Guest ${TOKEN}`)
      return route.fulfill({ status: 401, json: { error: { code: 'session_invalid', message: 'x' } } });
    if (path === '/session') return route.fulfill({ json: { data: session(api.status) } });
    if (path === '/menu') return route.fulfill({ json: { data: menu } });
    if (path === '/order')
      return route.fulfill({
        json: {
          data: {
            lines: api.orders.some((order) => order.status === 'accepted')
              ? [{ name: 'Trà đào', size: 'L', quantity: '2.0', options: ['50%', 'Trân châu'], amount: '80000.0', kitchen: 'sent' }]
              : [],
            subtotal: api.orders.some((order) => order.status === 'accepted') ? '80000.0' : null,
            has_timed: false,
            orders: api.orders,
            requests: api.requests,
          },
        },
      });
    if (path === '/guest_orders') {
      const body = request.postDataJSON() as Record<string, unknown>;
      api.submitted.push({ body, key: request.headers()['idempotency-key'] ?? null });
      const order = {
        id: 'posguestorder_1',
        status: 'pending',
        reject_reason: null,
        items: [{ name: 'Trà đào', size: 'L', quantity: 2, amount: '80000.0', options: ['50%', 'Trân châu'] }],
        quoted_total: '80000.0',
        currency: 'VND',
        created_at: '2026-11-12T12:00:00Z',
      };
      api.orders = [order];
      return route.fulfill({ status: 201, json: { data: order } });
    }
    if (path === '/requests') {
      const body = request.postDataJSON() as { kind: string };
      const row = { id: 'posguestreq_1', kind: body.kind, status: 'open', created_at: '2026-11-12T12:01:00Z' };
      api.requests = [row];
      return route.fulfill({ status: 201, json: { data: row } });
    }
    return route.fulfill({ status: 404, json: { error: { code: 'not_found', message: 'x' } } });
  });
}

const newApi = (status: Api['status'] = 'open'): Api => ({
  status,
  orders: [],
  requests: [],
  submitted: [],
  authorizations: [],
});

test('orders a dish with options, waits for staff, then sees it sent to the kitchen', async ({ page }) => {
  const api = newApi();
  await install(page, api);
  await page.goto(`/table/t/${CODE}`);

  await expect(page.getByRole('heading', { name: 'Bàn 4 · Quận 1' })).toBeVisible();
  // The code leaves the address once exchanged.
  await expect(page).toHaveURL(/\/table\/$/);
  await expect(page.getByTestId('menu-item-mi_flan')).toBeDisabled();
  await expect(page.getByTestId('menu-item-mi_flan')).toContainText('Hết món');

  await page.getByTestId('menu-item-mi_tea').click();
  await page.getByRole('radio', { name: /^L / }).check();
  // Sugar is required: nothing can be added until it is chosen.
  await expect(page.getByTestId('add-to-cart')).toBeDisabled();
  await page.getByLabel('50%').check();
  await page.getByLabel('Trân châu').check();
  await page.getByRole('button', { name: 'Thêm', exact: true }).click();
  await page.getByLabel('Ghi chú cho bếp').fill('ít đá');
  await expect(page.getByTestId('add-to-cart')).toContainText('80.000');
  await page.getByTestId('add-to-cart').click();

  await page.getByTestId('tab-cart').click();
  await expect(page.getByTestId('tab-cart')).toContainText('(2)');
  await expect(page.getByTestId('cart-line')).toContainText('Trà đào');
  await expect(page.getByTestId('cart-total')).toContainText('80.000');
  await page.getByTestId('send-order').click();

  const order = page.getByTestId('order-posguestorder_1');
  await expect(order).toContainText('Đang chờ xác nhận');
  expect(api.submitted).toHaveLength(1);
  expect(api.submitted[0].key).toEqual(expect.any(String));
  expect(api.submitted[0].body).toEqual({
    items: [
      {
        variant_id: 'v_tea_l',
        quantity: 2,
        modifiers: [
          { option_id: 'opt_half', quantity: 1 },
          { option_id: 'opt_pearl', quantity: 1 },
        ],
        note: 'ít đá',
      },
    ],
  });

  // Staff accept: the next poll shows it in the kitchen and on the table.
  api.orders = [{ ...api.orders[0], status: 'accepted' }];
  await expect(order).toContainText('Đã gửi bếp', { timeout: 8_000 });
  await expect(page.getByTestId('table-lines')).toContainText('2 × Trà đào (L)');

  await page.getByTestId('call-staff').click();
  await expect(page.getByText('Đã gọi phục vụ, nhân viên sẽ đến ngay.')).toBeVisible();
  await expect(page.getByTestId('call-staff')).toBeDisabled();

  // Every call carried the session token in the header, never in the URL.
  expect(api.authorizations.every((value) => value === `Guest ${TOKEN}`)).toBe(true);
  expect(page.url()).not.toContain(TOKEN);
});

test('shows a rejection with its reason', async ({ page }) => {
  const api = newApi();
  api.orders = [
    {
      id: 'posguestorder_9',
      status: 'rejected',
      reject_reason: 'Món đã hết',
      items: [{ name: 'Bánh flan', size: null, quantity: 1, amount: '15000.0', options: [] }],
      quoted_total: '15000.0',
      currency: 'VND',
      created_at: '2026-11-12T12:00:00Z',
    },
  ];
  await install(page, api);
  await page.goto(`/table/t/${CODE}`);
  await page.getByTestId('tab-table').click();
  await expect(page.getByTestId('order-posguestorder_9')).toContainText('Bị từ chối: Món đã hết');
});

test('reads the menu only at a closed table and orders once staff open it', async ({ page }) => {
  const api = newApi('table_closed');
  await install(page, api);
  await page.goto(`/table/t/${CODE}`);

  await expect(page.getByTestId('table-closed')).toContainText('Bàn chưa mở');
  await page.getByTestId('menu-item-mi_tea').click();
  await page.getByLabel('100%').check();
  await page.getByTestId('add-to-cart').click();
  await page.getByTestId('tab-cart').click();
  await expect(page.getByTestId('send-order')).toBeDisabled();
  await page.getByTestId('tab-table').click();
  await expect(page.getByTestId('request-bill')).toHaveCount(0);
  await expect(page.getByTestId('call-staff')).toBeEnabled();

  api.status = 'open';
  await page.getByRole('button', { name: 'Bàn đã mở? Thử lại' }).click();
  await expect(page.getByTestId('table-closed')).toHaveCount(0);
  await page.getByTestId('tab-cart').click();
  await expect(page.getByTestId('send-order')).toBeEnabled();
});

test('refuses a code that no longer works and asks for a scan without one', async ({ page }) => {
  const api = newApi();
  await install(page, api);
  await page.goto('/table/t/AAAAAAAAAAAAAAAAAAAAAA');
  await expect(page.getByTestId('phase')).toHaveText('Mã QR này không còn dùng được. Nhờ nhân viên giúp nhé.');

  await page.goto('/table/');
  await expect(page.getByTestId('phase')).toHaveText(
    'Hãy quét mã QR dán trên bàn để xem thực đơn và gọi món.',
  );
});
