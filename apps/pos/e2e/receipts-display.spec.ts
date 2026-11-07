import { type BrowserContext, expect, type Page, type Route, test } from '@playwright/test';

// In-memory POS API for receipts and the customer display. The display
// channel enforces the display token and generation the way the server does;
// the test drives it into delayed, cached, failing and held responses.

const TTL = 2;
const money = (value: number) => `${value}.0`;

type DisplayMode = 'ok' | 'abort' | 'stale' | 'hold';

function workspace(id: string, number: string, total: number, attempts: unknown[] = []) {
  return {
    id,
    branch_id: 'br_1',
    register_id: 'reg_1',
    shift_id: 'sh_1',
    order_id: number,
    revision: 1,
    lease_generation: 1,
    operational_status: 'editing',
    payments: attempts.length > 0,
    line_items: [
      {
        id: `line_${id}`,
        variant_id: 'variant_1',
        product_id: 'prod_1',
        name: 'Gạo ST25',
        sku: 'GAO',
        quantity: 1,
        price: money(total),
        amount: money(total),
        discounts: [],
        sale_line_id: `sale_${id}`,
        kind: 'ordinary',
      },
    ],
    customer: null,
    discount: null,
    totals: {
      item_total: money(total),
      discount_total: '0.0',
      manual_discount_total: '0.0',
      included_tax_total: '0.0',
      additional_tax_total: '0.0',
      total: money(total),
      currency: 'VND',
    },
    financial: {
      received: '0.0',
      allocated: '0.0',
      unapplied: '0.0',
      remaining: money(total),
      change_due: '0.0',
      attempts,
    },
  };
}

const bankAttempt = {
  id: 'ten_a_1',
  workspace_id: 'ws_a',
  payment_method_id: 'posmethod-bank_manual',
  kind: 'bank_manual',
  status: 'prepared',
  amount: '120000.0',
  order_total_snapshot: '120000.0',
  currency: 'VND',
  workspace_revision: 1,
  received_funds_id: null,
  confirmed_at: null,
  canceled_at: null,
};

const ORDERS: Record<string, { number: string; total: number }> = {
  ws_a: { number: 'RA100', total: 120000 },
  ws_b: { number: 'RB200', total: 45000 },
};

function receipt(printed: boolean, copies: number) {
  return {
    id: 'posreceipt_1',
    source_type: 'sale',
    number: 'RD300',
    branch_id: 'br_1',
    issued_at: '2026-11-07T03:00:00Z',
    issued_late: false,
    disclaimer: 'Phiếu bán hàng POS — không phải hóa đơn điện tử',
    printed,
    copy_count: copies,
    document: {
      kind: 'sale',
      title: 'PHIẾU BÁN HÀNG',
      number: 'RD300',
      store: { name: 'Park Việt' },
      branch: { name: 'Chi nhánh 1', code: 'cn1' },
      register: 'Quầy 1',
      timezone: 'Asia/Ho_Chi_Minh',
      at: '2026-11-07T03:00:00Z',
      currency: 'VND',
      cashier: 'Lan',
      customer: { name: 'N••• V•• A•', phone: '•••••••567' },
      lines: [
        {
          name: 'Bia lon',
          sku: 'BIA',
          quantity: 24,
          sale_quantity: '1',
          sale_unit: 'Thùng',
          base_quantity: 24,
          base_unit: 'Lon',
          conversion: '1 Thùng = 24 Lon',
          unit_price: '240000.0',
          amount: '240000.0',
          discount: '0.0',
          net_amount: '240000.0',
          trace: [{ lot_code: 'L01', expiry_on: '2027-01-31', quantity: 24 }],
        },
      ],
      totals: {
        item_total: '240000.0',
        discount_total: '0.0',
        included_tax_total: '0.0',
        additional_tax_total: '0.0',
        total: '240000.0',
      },
      receipts: [{ method: 'cash', amount: '240000.0', handed: '300000.0', change: '60000.0' }],
      paid_total: '240000.0',
      credit: null,
    },
  };
}

async function mockPos(context: BrowserContext) {
  const display = {
    bound: false,
    status: 'active' as 'active' | 'revoked',
    generation: 0,
    sequence: 0,
    pinned: null as string | null,
    attempt: null as string | null,
    ackedGeneration: null as number | null,
    ackedAt: 0,
    mode: 'ok' as DisplayMode,
    staleSequence: 0,
    held: [] as Array<() => void>,
    acks: [] as Array<{ generation: number; lease_id: string }>,
    pins: [] as string[],
    revokes: [] as string[],
    stateReads: 0,
    seen: false,
    failCurrent: false,
    pairingCodes: [] as string[],
    printDelayMs: 0,
  };
  const printBodies: string[] = [];
  let prints = 0;
  let lookupStatus: 'posted' | 'open' = 'posted';

  const session = () =>
    display.bound
      ? {
          id: 'posdisplay_1',
          status: display.status,
          generation: display.generation,
          freshness_ttl_seconds: TTL,
          pinned_workspace_id: display.pinned,
          pinned_order_number: display.pinned ? ORDERS[display.pinned].number : null,
          pinned_tender_attempt_id: display.attempt,
          acked_generation: display.ackedGeneration,
          acked_at: display.ackedAt ? new Date(display.ackedAt).toISOString() : null,
          ack_current:
            display.ackedGeneration === display.generation && Date.now() - display.ackedAt < TTL * 1000,
          last_seen_at: display.seen ? new Date().toISOString() : null,
          token_expires_at: '2026-11-07T22:00:00Z',
        }
      : null;

  const state = () => {
    display.sequence += 1;
    const order = display.pinned ? ORDERS[display.pinned] : null;
    return {
      session_id: 'posdisplay_1',
      generation: display.generation,
      sequence: display.sequence,
      issued_at: new Date().toISOString(),
      lease_id: `lease-${display.generation}`,
      freshness_ttl_seconds: TTL,
      token_expires_at: '2026-11-07T22:00:00Z',
      branch_name: 'Chi nhánh 1',
      state: order ? 'order' : 'idle',
      order: order
        ? {
            number: order.number,
            currency: 'VND',
            lines: [{ name: 'Gạo ST25', quantity: '1', unit: null, amount: money(order.total) }],
            item_total: money(order.total),
            discount_total: '0.0',
            total: money(order.total),
            paid: '0.0',
            amount_due: money(order.total),
          }
        : null,
      payment: display.attempt
        ? {
            kind: 'bank_manual',
            amount: '120000.0',
            currency: 'VND',
            transfer_note: 'RA100',
            account_text: 'Vietcombank 0123456789 CONG TY PARK VIET',
          }
        : null,
    };
  };

  await context.route('**/api/v3/pos_display/**', async (route: Route) => {
    const request = route.request();
    const path = new URL(request.url()).pathname;
    if (path.endsWith('/pair')) {
      const code = String((request.postDataJSON() as { code?: string }).code ?? '')
        .toUpperCase()
        .replace(/[\s-]/g, '');
      const index = display.pairingCodes.indexOf(code);
      if (index < 0 || !display.bound)
        return route.fulfill({ status: 404, json: { error: { code: 'pairing_invalid' } } });
      display.pairingCodes.splice(index, 1);
      return route.fulfill({ json: { data: { token: 'tok-1', session_id: 'posdisplay_1' } } });
    }
    if (request.headers().authorization !== 'Display tok-1' || !display.bound || display.status !== 'active')
      return route.fulfill({ status: 401, json: { error: { code: 'display_unauthorized' } } });
    if (path.endsWith('/state')) {
      display.stateReads += 1;
      display.seen = true;
      if (display.mode === 'abort') return route.abort('internetdisconnected');
      if (display.mode === 'stale') {
        // A cached body: the same old sequence every time.
        return route.fulfill({ json: { data: { ...state(), sequence: display.staleSequence } } });
      }
      if (display.mode === 'hold') {
        await new Promise<void>((resolve) => display.held.push(resolve));
      }
      // The display may have given up on a held request already.
      return route.fulfill({ json: { data: state() } }).catch(() => undefined);
    }
    if (path.endsWith('/ack')) {
      const body = request.postDataJSON() as { generation: number; lease_id: string };
      display.acks.push(body);
      if (body.generation !== display.generation || body.lease_id !== `lease-${display.generation}`)
        return route.fulfill({ status: 409, json: { error: { code: 'generation_stale' } } });
      display.ackedGeneration = body.generation;
      display.ackedAt = Date.now();
      return route.fulfill({ json: { data: { generation: body.generation } } });
    }
    return route.fulfill({ status: 404, json: {} });
  });

  await context.route('**/api/v3/admin/**', async (route: Route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname.replace(/^.*\/api\/v3\/admin/, '');
    const method = request.method();
    const conflict = (reason: string) =>
      route.fulfill({ status: 409, json: { error: { code: 'conflict', message: reason, details: { reason } } } });
    if (path === '/auth/login' || path === '/auth/refresh')
      return route.fulfill({ json: { token: 'test-token' } });
    if (path === '/me')
      return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Lan' } } });
    if (path === '/pos/context/branches')
      return route.fulfill({
        json: { data: [{ id: 'br_1', name: 'Chi nhánh 1', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } },
      });
    if (path === '/pos/context/registers')
      return route.fulfill({
        json: {
          data: [{ id: 'reg_1', branch_id: 'br_1', name: 'Quầy 1', status: 'active' }],
          meta: { page: 1, pages: 1, count: 1 },
        },
      });
    if (path === '/pos/context') {
      const branch = url.searchParams.get('branch_id');
      const register = url.searchParams.get('register_id');
      return route.fulfill({
        json: {
          staff: { id: 'stf_1', email: 'staff@example.test', full_name: 'Lan' },
          store: { id: 'store_1', name: 'Park Việt', currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh' },
          capabilities: branch ? ['pos.shift.open', 'pos.payment.collect'] : [],
          branches: [{ id: 'br_1', name: 'Chi nhánh 1', status: 'active' }],
          registers: branch ? [{ id: 'reg_1', branch_id: 'br_1', name: 'Quầy 1', status: 'active' }] : [],
          shift: register ? { id: 'sh_1', owner_id: 'stf_1', opening_float: '0', currency: 'VND' } : null,
          selection: { branch_id: branch, register_id: register },
        },
      });
    }
    const workspaces = [workspace('ws_a', 'RA100', 120000, [bankAttempt]), workspace('ws_b', 'RB200', 45000)];
    if (path === '/pos/workspaces' && method === 'GET')
      return route.fulfill({ json: { data: workspaces, meta: { page: 1, pages: 1, count: 2 } } });
    const ws = /^\/pos\/workspaces\/(ws_[ab])(\/.*)?$/.exec(path);
    if (ws) {
      const found = workspaces.find((row) => row.id === ws[1]);
      if ((ws[2] ?? '') === '/payment_methods')
        return route.fulfill({
          json: {
            data: [
              { id: 'posmethod-cash', code: 'cash', name: 'Cash', kind: 'cash', status: 'active', position: 0 },
            ],
          },
        });
      return route.fulfill({ json: { data: found } });
    }
    if (path === '/pos/received_funds')
      return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0 } } });
    if (path === '/pos/command_receipts')
      return route.fulfill({ status: 404, json: { error: { code: 'not_found' } } });

    if (path === '/pos/display_sessions/current')
      return display.failCurrent
        ? route.fulfill({ status: 500, json: { error: { code: 'server_error' } } })
        : route.fulfill({ json: { data: session() } });
    if (path === '/pos/display_sessions' && method === 'POST') {
      display.bound = true;
      display.status = 'active';
      display.generation += 1;
      display.pinned = null;
      display.attempt = null;
      display.ackedGeneration = null;
      return route.fulfill({ status: 201, json: { data: session(), token: 'tok-1' } });
    }
    if (path === '/pos/display_sessions/posdisplay_1/pairing_code' && method === 'POST') {
      display.pairingCodes.push('ABCD2345');
      return route.fulfill({
        status: 201,
        json: { data: { code: 'ABCD2345', expires_at: new Date(Date.now() + 600_000).toISOString() } },
      });
    }
    const command = /^\/pos\/display_sessions\/posdisplay_1\/(pin|clear|revoke)$/.exec(path);
    if (command && method === 'POST') {
      const body = (request.postDataJSON() ?? {}) as Record<string, string | number | undefined>;
      if (command[1] !== 'revoke' && body.expected_generation !== display.generation)
        return conflict('generation_stale');
      if (command[1] === 'pin') {
        const target = String(body.workspace_id ?? '');
        display.pins.push(target);
        if (display.pinned && display.pinned !== target) return conflict('display_busy');
        const current = session();
        if (display.pinned !== target && !current?.ack_current) return conflict('display_ack_required');
        display.generation += 1;
        display.pinned = target;
        display.attempt = body.tender_attempt_id ? String(body.tender_attempt_id) : null;
      } else if (command[1] === 'clear') {
        display.generation += 1;
        display.pinned = null;
        display.attempt = null;
      } else {
        display.revokes.push(String(body.reason ?? ''));
        display.status = 'revoked';
        display.bound = false;
        return route.fulfill({ json: { data: { ...session(), status: 'revoked' } } });
      }
      return route.fulfill({ json: { data: session() } });
    }

    if (path === '/pos/receipts/lookup') {
      if (lookupStatus === 'open')
        return conflict('receipt_unavailable');
      return route.fulfill({ json: { data: receipt(prints > 0, Math.max(prints - 1, 0)) } });
    }
    if (path === '/pos/receipts/posreceipt_1' && method === 'GET')
      return route.fulfill({ json: { data: receipt(prints > 0, Math.max(prints - 1, 0)) } });
    if (path === '/pos/receipts/posreceipt_1/prints' && method === 'POST') {
      printBodies.push(request.headers()['idempotency-key'] ?? '');
      if (display.printDelayMs) await new Promise((resolve) => setTimeout(resolve, display.printDelayMs));
      const copyNumber = prints;
      prints += 1;
      return route.fulfill({
        status: 201,
        json: {
          data: {
            print: {
              id: `posprint_${prints}`,
              copy: copyNumber > 0,
              copy_number: copyNumber,
              label: copyNumber > 0 ? 'BẢN SAO' : null,
              printed_at: '2026-11-07T03:05:00Z',
            },
            receipt: receipt(true, copyNumber),
          },
        },
      });
    }
    return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
  });

  return {
    display,
    printBodies,
    setLookup(value: 'posted' | 'open') {
      lookupStatus = value;
    },
    release() {
      for (const resolve of display.held.splice(0)) resolve();
    },
  };
}

async function login(page: Page) {
  await page.goto('/pos/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('password');
  await page.getByRole('button', { name: 'Đăng nhập vào bán hàng', exact: true }).click();
  await expect(page.getByRole('tab').first()).toBeVisible();
}

async function pairDisplay(page: Page, api: { display: { pairingCodes: string[] } }) {
  if (!api.display.pairingCodes.includes('ABCD2345')) api.display.pairingCodes.push('ABCD2345');
  await page.goto('/pos/display');
  await page.getByLabel('Mã kết nối').fill('abcd-2345');
  await page.getByRole('button', { name: 'Kết nối', exact: true }).click();
}

async function setVisibility(page: Page, state: 'hidden' | 'visible') {
  await page.evaluate((value) => {
    Object.defineProperty(document, 'visibilityState', { configurable: true, get: () => value });
    document.dispatchEvent(new Event('visibilitychange'));
  }, state);
}

function displayControl(page: Page) {
  return page.getByRole('region', { name: 'Màn hình khách' });
}

test('pinning A and selling B in another tab never changes what the customer sees', async ({ context, page }) => {
  const api = await mockPos(context);
  await login(page);
  await page.locator('[role="tab"][data-workspace-id="ws_a"]').click();
  const control = displayControl(page);
  await control.getByRole('button', { name: 'Kết nối màn hình khách' }).click();
  // Not acknowledged yet: nobody can be shown.
  await expect(control.getByRole('button', { name: 'Hiện đơn này cho khách' })).toBeDisabled();

  // A separate device pairs with a short code; the token is never on screen.
  await control.getByText('Thiết bị màn hình').click();
  await control.getByRole('button', { name: 'Tạo mã kết nối thiết bị khác' }).click();
  await expect(control.getByTestId('display-pairing-code')).toHaveText('••••-••••');
  await control.getByRole('button', { name: 'Hiện mã' }).click();
  await expect(control.getByTestId('display-pairing-code')).toHaveText('ABCD-2345');
  await expect(control).not.toContainText('tok-1');
  const screen = await context.newPage();
  await screen.goto('/pos/display');
  await screen.getByLabel('Mã kết nối').fill('WRONG234');
  await screen.getByRole('button', { name: 'Kết nối', exact: true }).click();
  await expect(screen.getByRole('alert')).toContainText('không đúng hoặc đã hết hạn');
  await screen.getByLabel('Mã kết nối').fill('abcd-2345');
  await screen.getByRole('button', { name: 'Kết nối', exact: true }).click();
  await expect(screen.getByRole('heading', { name: /Xin chào quý khách/ })).toBeVisible();
  await expect(control.getByRole('button', { name: 'Hiện đơn này cho khách' })).toBeEnabled({ timeout: 10_000 });
  await control.getByRole('button', { name: /Hiện chuyển khoản/ }).click();
  await expect(screen.getByRole('heading', { name: 'Đơn RA100' })).toBeVisible();
  await expect(screen.getByTestId('display-payment')).toContainText('Vietcombank 0123456789');

  // The cashier moves to order B and keeps selling there.
  await page.locator('[role="tab"][data-workspace-id="ws_b"]').click();
  await expect(control).toContainText('Đang hiện đơn RA100');
  await expect(control.getByRole('button', { name: 'Hiện đơn này cho khách' })).toBeDisabled();
  await expect(control).toContainText('Màn hình đang hiện đơn khác');
  const reads = api.display.stateReads;
  await expect.poll(() => api.display.stateReads).toBeGreaterThan(reads + 2);
  await expect(screen.getByRole('heading', { name: 'Đơn RA100' })).toBeVisible();
  expect(api.display.pins).toEqual(['ws_a']);

  // Clear, wait for the display to confirm the clear, then show B.
  // Clearing never claims the photographed account or QR stopped working.
  await expect(control).toContainText('khách vẫn có thể chuyển tiền');
  await control.getByRole('button', { name: 'Xóa màn hình khách' }).click();
  await expect(control).toContainText('Đang trống');
  await expect(screen.getByRole('heading', { name: /Xin chào quý khách/ })).toBeVisible();
  await expect(control.getByRole('button', { name: 'Hiện đơn này cho khách' })).toBeEnabled({ timeout: 10_000 });
  await control.getByRole('button', { name: 'Hiện đơn này cho khách' }).click();
  await expect(screen.getByRole('heading', { name: 'Đơn RB200' })).toBeVisible();
  await expect(screen.getByTestId('display-payment')).toHaveCount(0);
});

test('without a current acknowledgement the next customer is blocked until the display is taken out of use', async ({
  context,
  page,
}) => {
  const api = await mockPos(context);
  await login(page);
  await page.locator('[role="tab"][data-workspace-id="ws_b"]').click();
  const control = displayControl(page);
  await control.getByRole('button', { name: 'Kết nối màn hình khách' }).click();
  await expect(control).toContainText('màn hình chưa xác nhận');
  await expect(control.getByRole('button', { name: 'Hiện đơn này cho khách' })).toBeDisabled();
  await expect(control).toContainText('Chờ màn hình khách xác nhận đã xóa');
  // No device ever read this display: there is nothing to declare unresponsive.
  await expect(control.getByRole('button', { name: 'Màn hình khách không phản hồi' })).toHaveCount(0);
  api.display.seen = true;

  // An acknowledgement that has expired is no proof either.
  api.display.ackedGeneration = api.display.generation;
  api.display.ackedAt = Date.now() - (TTL + 5) * 1000;
  await page.waitForTimeout(3500);
  await expect(control.getByRole('button', { name: 'Hiện đơn này cho khách' })).toBeDisabled();
  expect(api.display.pins).toEqual([]);

  // A failing freshness poll never reads as confirmed either.
  api.display.ackedAt = Date.now();
  api.display.failCurrent = true;
  await expect(control).toContainText('màn hình chưa xác nhận', { timeout: 10_000 });
  await expect(control.getByRole('button', { name: 'Hiện đơn này cho khách' })).toBeDisabled();
  api.display.failCurrent = false;
  api.display.ackedAt = Date.now() - (TTL + 5) * 1000;

  page.once('dialog', (dialog) => void dialog.accept());
  await control.getByRole('button', { name: 'Màn hình khách không phản hồi' }).click();
  await expect(control.getByRole('button', { name: 'Kết nối màn hình khách' })).toBeVisible();
  expect(api.display.revokes).toEqual(['unresponsive']);
});

test('a display that loses the server hides the transfer within the freshness window, whatever changed meanwhile', async ({
  context,
  page,
}) => {
  const api = await mockPos(context);
  api.display.bound = true;
  api.display.generation = 2;
  api.display.pinned = 'ws_a';
  api.display.attempt = 'ten_a_1';
  await pairDisplay(page, api);
  const payment = page.getByTestId('display-payment');
  for (const change of ['clear', 'cancel', 'settlement', 'rebind'] as const) {
    api.display.mode = 'ok';
    await expect(payment).toBeVisible();
    // The server moves on (clear, cancel, settle or rebind) but the display
    // is cut off right before it can learn about it.
    api.display.mode = 'abort';
    if (change === 'clear' || change === 'rebind') api.display.generation += 1;
    const cut = Date.now();
    await expect(page.getByTestId('display-stale')).toBeVisible({ timeout: (TTL + 2) * 1000 });
    expect(Date.now() - cut).toBeLessThanOrEqual((TTL + 1.5) * 1000);
    await expect(payment).toHaveCount(0);
    api.display.generation = 2;
    api.display.sequence += 10;
  }

  // Known offline: hidden at once, not after the window.
  api.display.mode = 'ok';
  await expect(payment).toBeVisible();
  await context.setOffline(true);
  await expect(payment).toHaveCount(0, { timeout: 500 });
  await context.setOffline(false);
  await expect(payment).toBeVisible({ timeout: 5000 });
});

test('cached or replayed responses never renew the display', async ({ context, page }) => {
  const api = await mockPos(context);
  api.display.bound = true;
  api.display.generation = 2;
  api.display.pinned = 'ws_a';
  api.display.attempt = 'ten_a_1';
  await pairDisplay(page, api);
  const payment = page.getByTestId('display-payment');
  await expect(payment).toBeVisible();
  // Responses keep arriving, but all carry a sequence the display already saw.
  api.display.staleSequence = 1;
  api.display.mode = 'stale';
  const reads = api.display.stateReads;
  await expect(page.getByTestId('display-stale')).toBeVisible({ timeout: (TTL + 2) * 1000 });
  expect(api.display.stateReads).toBeGreaterThan(reads);
  await page.waitForTimeout(1500);
  await expect(payment).toHaveCount(0);
  api.display.mode = 'ok';
  await expect(payment).toBeVisible();
});

test('sleep and resume hide the transfer before revalidating and show it only after a fresh answer', async ({
  context,
  page,
}) => {
  const api = await mockPos(context);
  api.display.bound = true;
  api.display.generation = 2;
  api.display.pinned = 'ws_a';
  api.display.attempt = 'ten_a_1';
  await pairDisplay(page, api);
  const payment = page.getByTestId('display-payment');
  await expect(payment).toBeVisible();
  api.display.mode = 'hold';
  await setVisibility(page, 'hidden');
  await expect(payment).toHaveCount(0);
  await setVisibility(page, 'visible');
  // Revalidation is still in flight: nothing is shown yet.
  await page.waitForTimeout(500);
  await expect(payment).toHaveCount(0);
  await expect(page.getByTestId('display-stale')).toBeVisible();
  api.display.mode = 'ok';
  api.release();
  await expect(payment).toBeVisible();
  expect(api.display.acks.at(-1)).toEqual({ generation: 2, lease_id: 'lease-2' });
});

type PrintSeen = { marker: string | null; sheet: string; printId: string | null; rules: string[] };

async function stubPrint(page: Page) {
  await page.addInitScript(() => {
    const seen: unknown[] = [];
    (window as unknown as { printed: unknown[] }).printed = seen;
    window.print = () => {
      const sheet = document.querySelector('[data-testid="receipt-print-sheet"]');
      const style = document.getElementById('pos-receipt-page-size') as HTMLStyleElement | null;
      seen.push({
        marker: document.documentElement.getAttribute('data-receipt-printing'),
        sheet: sheet?.textContent ?? '',
        printId: sheet?.getAttribute('data-print-id') ?? null,
        rules: [...(style?.sheet?.cssRules ?? [])].map((rule) => rule.cssText),
      });
    };
  });
}

const printed = (page: Page) =>
  page.evaluate(() => (window as unknown as { printed: PrintSeen[] }).printed);

test('prints the server snapshot on 80mm and A4 and labels every reprint as a copy', async ({
  context,
  page,
}) => {
  await stubPrint(page);
  const api = await mockPos(context);
  // The print is recorded slowly: nothing may print before the labelled sheet is there.
  api.display.printDelayMs = 700;
  await login(page);
  await page.goto('/pos/receipts?source=posworkspace_done');
  const sheet = page.getByTestId('receipt-sheet');
  await expect(sheet).toContainText('PHIẾU BÁN HÀNG');
  await expect(sheet).toContainText('1 Thùng = 24 Lon');
  await expect(sheet).toContainText('Lô: L01 · HSD: 31/01/2027');
  await expect(sheet).toContainText('07/11/2026 10:00');
  await expect(sheet).toContainText('Tiền thừa trả khách');
  await expect(sheet).toContainText('Phiếu bán hàng POS — không phải hóa đơn điện tử');
  await expect(sheet).not.toContainText('BẢN SAO');
  await expect(sheet).toHaveAttribute('data-paper', '80mm');

  await page.getByRole('button', { name: 'In hóa đơn', exact: true }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã ghi nhận bản gốc' })).toBeVisible();
  await expect.poll(async () => (await printed(page)).length).toBe(1);

  await page.getByLabel('A4').check();
  await expect(sheet).toHaveAttribute('data-paper', 'a4');
  await page.getByRole('button', { name: 'In lại (bản sao)' }).click();
  await expect(page.getByRole('status').filter({ hasText: 'bản sao lần 1' })).toBeVisible();
  await expect.poll(async () => (await printed(page)).length).toBe(2);
  await expect(sheet).toContainText('BẢN SAO');
  const [first, second] = await printed(page);
  expect(first).toMatchObject({ marker: '80mm', printId: 'posprint_1' });
  expect(first.sheet).toContain('PHIẾU BÁN HÀNG');
  expect(first.sheet).not.toContain('BẢN SAO');
  expect(first.rules.join(' ')).toContain('size: 80mm 297mm');
  expect(second).toMatchObject({ marker: 'a4', printId: 'posprint_2' });
  expect(second.sheet).toContain('BẢN SAO – lần 1');
  expect(second.rules.join(' ')).toMatch(/size: A4/i);
  // The marker and page size exist only while printing.
  expect(await page.evaluate(() => document.documentElement.hasAttribute('data-receipt-printing'))).toBe(false);
  expect(await page.evaluate(() => document.getElementById('pos-receipt-page-size'))).toBeNull();
  expect(new Set(api.printBodies).size).toBe(2);
});

test('a pre-bill prints from the print root, labelled as not paid', async ({ context, page }) => {
  await stubPrint(page);
  await mockPos(context);
  await login(page);
  await page.locator('[role="tab"][data-workspace-id="ws_b"]').click();
  await page.locator('.order-more summary').click();
  await page.getByRole('button', { name: 'In tạm tính' }).click();
  const dialog = page.getByRole('dialog');
  await expect(dialog).toContainText('TẠM TÍNH – CHƯA THANH TOÁN');
  await dialog.getByRole('button', { name: 'In phiếu tạm tính' }).click();
  await expect.poll(async () => (await printed(page)).length).toBe(1);
  const [seen] = await printed(page);
  expect(seen.marker).toBe('80mm');
  expect(seen.sheet).toContain('TẠM TÍNH – CHƯA THANH TOÁN');
  expect(seen.sheet).toContain('45.000 ₫');
  // The print copy sits at the end of <body>, outside the fixed dialog.
  expect(
    await page.evaluate(
      () => document.querySelector('.receipt-print-portal')?.parentElement === document.body,
    ),
  ).toBe(true);
});

test('an order that is not completed has no receipt to print', async ({ context, page }) => {
  const api = await mockPos(context);
  api.setLookup('open');
  await login(page);
  await page.goto('/pos/receipts?source=posworkspace_open');
  await expect(page.getByRole('alert')).toContainText('chưa có hóa đơn');
  await expect(page.getByTestId('receipt-sheet')).toHaveCount(0);
  expect(api.printBodies).toEqual([]);
});
