import { expect, type Page, test } from '@playwright/test';

type Attempt = Record<string, unknown> & { id: string; kind: string; amount: string; status: string };

type MockWorkspace = {
  id: string;
  order_id: string;
  total: number;
  revision: number;
  status: 'editing' | 'completed';
  attempts: Attempt[];
  received: number;
  allocated: number;
  changeDue: number;
};

type ConfirmBody = {
  handed_amount?: string;
  reference?: string;
  receiving_account?: string;
  received_amount?: string;
};

const money = (value: number) => `${value}.0`;

function serialize(ws: MockWorkspace) {
  return {
    id: ws.id,
    branch_id: 'br_1',
    register_id: 'reg_1',
    shift_id: 'sh_1',
    order_id: ws.order_id,
    revision: ws.revision,
    lease_generation: 1,
    operational_status: ws.status,
    payments: ws.attempts.some((attempt) => attempt.status !== 'canceled'),
    line_items: [
      {
        id: `line_${ws.id}`,
        variant_id: 'variant_1',
        product_id: 'prod_1',
        name: 'Áo xanh',
        sku: 'AO-1',
        quantity: 1,
        price: money(ws.total),
        amount: money(ws.total),
        discounts: [],
        sale_line_id: `sale_${ws.id}`,
        kind: 'ordinary',
      },
    ],
    customer: null,
    discount: null,
    totals: {
      item_total: money(ws.total),
      discount_total: '0.0',
      manual_discount_total: '0.0',
      included_tax_total: '0.0',
      additional_tax_total: '0.0',
      total: money(ws.total),
      currency: 'VND',
    },
    financial: {
      received: money(ws.received),
      allocated: money(ws.allocated),
      unapplied: '0.0',
      remaining: money(ws.total - ws.allocated),
      change_due: money(ws.changeDue),
      attempts: ws.attempts,
    },
  };
}

// In-memory POS API: every money rule the client must not bypass is checked
// here the way the server does, and each request body is kept for assertions.
async function mockPos(
  page: Page,
  workspaces: Array<Pick<MockWorkspace, 'id' | 'order_id' | 'total'>>,
  options: { rejectConfirm?: (body: ConfirmBody) => string | null } = {},
) {
  const state = new Map<string, MockWorkspace>(
    workspaces.map((ws) => [
      ws.id,
      {
        ...ws,
        revision: 1,
        status: 'editing',
        attempts: [],
        received: 0,
        allocated: 0,
        changeDue: 0,
      },
    ]),
  );
  const prepared: Array<{ workspace: string; body: Record<string, unknown> }> = [];
  const confirmed: Array<{ workspace: string; body: ConfirmBody }> = [];

  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname;
    const method = request.method();
    const conflict = (message: string) =>
      route.fulfill({ status: 409, json: { error: { code: 'conflict', message } } });
    if (path.endsWith('/pos/context/branches'))
      return route.fulfill({
        json: {
          data: [{ id: 'br_1', name: 'Branch', status: 'active' }],
          meta: { page: 1, pages: 1, count: 1 },
        },
      });
    if (path.endsWith('/pos/context/registers'))
      return route.fulfill({
        json: {
          data: [{ id: 'reg_1', branch_id: 'br_1', name: 'Register', status: 'active' }],
          meta: { page: 1, pages: 1, count: 1 },
        },
      });
    if (path.endsWith('/auth/login') || path.endsWith('/auth/refresh'))
      return route.fulfill({ json: { token: 'test-token' } });
    if (path.endsWith('/me'))
      return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Lan' } } });
    if (path.endsWith('/pos/context')) {
      const branch = url.searchParams.get('branch_id');
      const register = url.searchParams.get('register_id');
      return route.fulfill({
        json: {
          staff: { id: 'stf_1', email: 'staff@example.test', full_name: 'Lan' },
          store: {
            id: 'store_1',
            name: 'Test',
            currency: 'VND',
            locale: 'vi',
            timezone: 'Asia/Ho_Chi_Minh',
          },
          capabilities: branch
            ? ['pos.shift.open', 'pos.payment.collect', 'pos.payment.resolve']
            : [],
          branches: [{ id: 'br_1', name: 'Branch', status: 'active' }],
          registers: branch
            ? [{ id: 'reg_1', branch_id: 'br_1', name: 'Register', status: 'active' }]
            : [],
          shift: register
            ? { id: 'sh_1', owner_id: 'stf_1', opening_float: '0', currency: 'VND' }
            : null,
          selection: { branch_id: branch, register_id: register },
        },
      });
    }
    if (path.endsWith('/pos/workspaces') && method === 'GET')
      return route.fulfill({
        json: {
          data: [...state.values()].map(serialize),
          meta: { page: 1, pages: 1, count: state.size },
        },
      });
    if (path.endsWith('/pos/received_funds'))
      return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0 } } });
    if (path.endsWith('/pos/command_receipts'))
      return route.fulfill({ status: 404, json: { error: { code: 'not_found' } } });

    const match = /\/pos\/workspaces\/(ws_\d+)(\/.*)?$/.exec(path);
    const ws = match ? state.get(match[1]) : undefined;
    if (!ws) return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
    const rest = match?.[2] ?? '';
    const reply = () => route.fulfill({ json: { data: serialize(ws) } });

    if (rest === '' && method === 'GET') return reply();
    if (rest === '/lease') return reply();
    if (rest === '/payment_methods')
      return route.fulfill({
        json: {
          data: [
            { id: 'posmethod-cash', code: 'cash', name: 'Cash', kind: 'cash', status: 'active', position: 0 },
            { id: 'posmethod-bank_manual', code: 'bank_transfer', name: 'Bank transfer', kind: 'bank_manual', status: 'active', position: 1 },
          ],
        },
      });
    if (rest === '/tender_attempts' && method === 'POST') {
      const body = request.postDataJSON() as { payment_method_id: string; amount: string };
      prepared.push({ workspace: ws.id, body });
      if (!/^\d+$/.test(body.amount)) return conflict('Amount must be whole VND.');
      ws.attempts = [
        ...ws.attempts,
        {
          id: `ten_${ws.id}_${ws.attempts.length + 1}`,
          workspace_id: ws.id,
          payment_method_id: body.payment_method_id,
          kind: body.payment_method_id.endsWith('cash') ? 'cash' : 'bank_manual',
          status: 'prepared',
          amount: money(Number(body.amount)),
          order_total_snapshot: money(ws.total),
          currency: 'VND',
          workspace_revision: ws.revision,
          received_funds_id: null,
          confirmed_at: null,
          canceled_at: null,
        },
      ];
      ws.revision += 1;
      return reply();
    }
    const attemptMatch = /^\/tender_attempts\/([^/]+)\/(confirm|cancel)$/.exec(rest);
    if (attemptMatch && method === 'POST') {
      const attempt = ws.attempts.find((item) => item.id === attemptMatch[1]);
      if (!attempt || attempt.status !== 'prepared') return conflict('Tender is not prepared.');
      if (attemptMatch[2] === 'cancel') {
        attempt.status = 'canceled';
        ws.revision += 1;
        return reply();
      }
      const body = request.postDataJSON() as ConfirmBody;
      confirmed.push({ workspace: ws.id, body });
      const rejected = options.rejectConfirm?.(body);
      if (rejected) return conflict(rejected);
      const applied = Number.parseInt(attempt.amount, 10);
      if (attempt.kind === 'cash') {
        const handed = Number(body.handed_amount);
        if (!(handed >= applied)) return conflict('Handed cash is less than the tender amount.');
        ws.changeDue += handed - applied;
      } else if (!body.reference || !body.receiving_account) {
        return route.fulfill({
          status: 422,
          json: { error: { code: 'validation_error', message: 'Reference is required.' } },
        });
      }
      ws.received += applied;
      ws.allocated += applied;
      attempt.status = 'confirmed';
      attempt.received_funds_id = `fund_${attempt.id}`;
      ws.revision += 1;
      return reply();
    }
    if (rest === '/complete' && method === 'POST') {
      if (ws.allocated !== ws.total) return conflict('Order is not fully paid.');
      ws.status = 'completed';
      ws.revision += 1;
      return reply();
    }
    if (rest === '/handover' && method === 'POST') return reply();
    return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
  });

  return { state, prepared, confirmed };
}

async function login(page: Page) {
  await page.goto('/pos/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('password');
  await page.getByRole('button', { name: 'Đăng nhập vào bán hàng', exact: true }).click();
  await expect(page.getByRole('tab').first()).toBeVisible();
}

async function openTab(page: Page, workspaceId: string) {
  await page.locator(`[role="tab"][data-workspace-id="${workspaceId}"]`).click();
  await page.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();
  await expect(page.locator('.payment-panel')).toBeVisible();
}

test('split tender: bank 100 then cash handed 200/change 50, complete and handover', async ({ page }) => {
  const api = await mockPos(page, [{ id: 'ws_1', order_id: 'R250', total: 250 }]);
  await login(page);
  await openTab(page, 'ws_1');

  const panel = page.locator('.payment-panel');
  const checkout = page.getByRole('complementary', { name: 'Thông tin thanh toán' });
  await expect(checkout).toContainText('Tổng đơn hàng');
  await expect(checkout).toContainText('250 ₫');
  await panel.getByRole('button', { name: 'Chuyển khoản', exact: true }).click();
  await panel.getByLabel('Chuyển khoản').fill('100');
  await expect(panel.getByLabel('Tiền mặt')).toHaveValue('150');
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await dialog.getByLabel('Mã tham chiếu giao dịch').fill('FT001');
  await dialog.getByLabel('Tài khoản nhận').fill('VCB-123');
  await dialog.getByLabel('Khách đưa').fill('200');
  await expect(dialog).toContainText('50 ₫');
  await dialog.getByRole('button', { name: 'Kết thúc', exact: true }).click();
  await expect(panel.getByText('Đã thu (đã xác nhận)')).toBeVisible();
  await expect(panel.getByText('Tiền thừa trả khách')).toBeVisible();
  await expect(panel.locator('.payment-summary')).toContainText('50');
  await panel.getByRole('button', { name: 'Hoàn tất đơn' }).click();
  await page.getByRole('button', { name: 'Giao hàng tại quầy' }).click();
  await expect(page.getByText('Đã giao hàng tại quầy.')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Giao hàng tại quầy' })).toHaveCount(0);
  expect(api.confirmed.map((item) => item.body.handed_amount ?? item.body.reference).sort()).toEqual(
    ['200', 'FT001'],
  );
});

test('grouped VND amounts are read as thousands and sent canonical', async ({ page }) => {
  const api = await mockPos(page, [{ id: 'ws_1', order_id: 'R300', total: 300000 }]);
  await login(page);
  await openTab(page, 'ws_1');
  const panel = page.locator('.payment-panel');
  await panel.getByLabel('Tiền mặt').fill('150.000');
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  await expect(page.getByRole('dialog')).toBeVisible();
  expect(api.prepared.map((item) => item.body.amount)).toEqual(['150000']);

  const dialog = page.getByRole('dialog');
  await dialog.getByLabel('Khách đưa').fill('200,000');
  await expect(dialog).toContainText('Số tiền không hợp lệ');
  await expect(dialog.getByRole('button', { name: 'Kết thúc', exact: true })).toBeDisabled();
  await dialog.getByLabel('Khách đưa').fill('200.000');
  await expect(dialog).toContainText('50.000 ₫');
  await dialog.getByRole('button', { name: 'Kết thúc', exact: true }).click();
  await expect(panel.getByText('Đã thu (đã xác nhận)')).toBeVisible();
  expect(api.confirmed.map((item) => item.body.handed_amount)).toEqual(['200000']);
});

test('handed cash below the tender blocks confirmation', async ({ page }) => {
  const api = await mockPos(page, [{ id: 'ws_1', order_id: 'R250', total: 250000 }]);
  await login(page);
  await openTab(page, 'ws_1');
  await page.locator('.payment-panel').getByRole('button', { name: 'Thanh toán', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await expect(dialog.getByLabel('Khách đưa')).toHaveValue('');
  await expect(dialog.getByRole('button', { name: 'Kết thúc', exact: true })).toBeDisabled();
  await dialog.getByLabel('Khách đưa').fill('100.000');
  await expect(dialog).toContainText('Khách đưa chưa đủ');
  await expect(dialog.getByRole('button', { name: 'Kết thúc', exact: true })).toBeDisabled();
  await dialog.getByLabel('Khách đưa').press('Enter');
  expect(api.confirmed).toEqual([]);
});

test('a server conflict on confirm shows its own message and leaves nothing pending', async ({ page }) => {
  await mockPos(page, [{ id: 'ws_1', order_id: 'R250', total: 250000 }], {
    rejectConfirm: () => 'Shift is closed for this register.',
  });
  await login(page);
  await openTab(page, 'ws_1');
  await page.locator('.payment-panel').getByRole('button', { name: 'Thanh toán', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await dialog.getByLabel('Khách đưa').fill('250.000');
  await dialog.getByRole('button', { name: 'Kết thúc', exact: true }).click();
  await expect(dialog.getByRole('alert')).toContainText('Shift is closed for this register.');
  await expect(page.getByText('Có khoản thu chưa rõ kết quả')).toHaveCount(0);
});

test('bank evidence starts empty and is required', async ({ page }) => {
  const api = await mockPos(page, [{ id: 'ws_1', order_id: 'R250', total: 250000 }]);
  await login(page);
  await openTab(page, 'ws_1');
  const panel = page.locator('.payment-panel');
  await panel.getByRole('button', { name: 'Chuyển khoản', exact: true }).click();
  await panel.getByRole('button', { name: 'Tiền mặt', exact: true }).click();
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await expect(dialog.getByLabel('Mã tham chiếu giao dịch')).toHaveValue('');
  await expect(dialog.getByLabel('Tài khoản nhận')).toHaveValue('');
  await expect(dialog.locator('svg.payment-qr-svg')).toHaveCount(0);
  const finish = dialog.getByRole('button', { name: 'Kết thúc', exact: true });
  await expect(finish).toBeDisabled();
  await dialog.getByLabel('Mã tham chiếu giao dịch').fill('FT777');
  await expect(finish).toBeDisabled();
  await dialog.getByLabel('Tài khoản nhận').fill('VCB-0011');
  await dialog.getByLabel('Số tiền thực nhận').fill('200.000');
  await expect(finish).toBeDisabled();
  await dialog.getByLabel('Số tiền thực nhận').fill('260.000');
  await finish.click();
  await expect(panel.getByText('Đã thu (đã xác nhận)')).toBeVisible();
  expect(api.confirmed.map((item) => item.body)).toEqual([
    expect.objectContaining({
      reference: 'FT777',
      receiving_account: 'VCB-0011',
      received_amount: '260000',
    }),
  ]);
});

test('a held bank tender on one order does not block selling on another', async ({ page }) => {
  const api = await mockPos(page, [
    { id: 'ws_1', order_id: 'R250', total: 250000 },
    { id: 'ws_2', order_id: 'R120', total: 120000 },
  ]);
  await login(page);
  await openTab(page, 'ws_1');
  const panel = page.locator('.payment-panel');
  await panel.getByRole('button', { name: 'Chuyển khoản', exact: true }).click();
  await panel.getByRole('button', { name: 'Tiền mặt', exact: true }).click();
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await expect(dialog).toBeVisible();
  await expect(dialog.getByLabel('Mã tham chiếu giao dịch')).toBeFocused();
  await dialog.getByRole('button', { name: 'Để chờ, bán đơn khác' }).click();
  await expect(dialog).toHaveCount(0);
  await expect(panel.getByRole('button', { name: 'Tiếp tục thanh toán' })).toBeVisible();

  // Tab B: a plain cash sale with change.
  await openTab(page, 'ws_2');
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  await dialog.getByLabel('Khách đưa').fill('200.000');
  await expect(dialog).toContainText('80.000 ₫');
  await dialog.getByRole('button', { name: 'Kết thúc', exact: true }).click();
  await expect(panel.locator('.payment-summary')).toContainText('80.000');
  await panel.getByRole('button', { name: 'Hoàn tất đơn' }).click();
  await expect(page.getByRole('button', { name: 'Giao hàng tại quầy' })).toBeVisible();
  expect(api.state.get('ws_2')?.status).toBe('completed');

  // Tab A still holds its prepared bank tender and can resume it.
  expect(api.state.get('ws_1')?.attempts.map((attempt) => attempt.status)).toEqual(['prepared']);
  await page.locator('[role="tab"][data-workspace-id="ws_1"]').click();
  await page.getByRole('button', { name: 'Tiếp tục thanh toán' }).click();
  await expect(dialog).toContainText('250.000 ₫');
  await page.keyboard.press('Escape');
  await expect(dialog).toHaveCount(0);
  expect(api.state.get('ws_1')?.attempts.map((attempt) => attempt.status)).toEqual(['prepared']);
});

test('closing the evidence dialog never cancels; cancel needs confirmation', async ({ page }) => {
  const api = await mockPos(page, [{ id: 'ws_1', order_id: 'R250', total: 250000 }]);
  await login(page);
  await openTab(page, 'ws_1');
  const panel = page.locator('.payment-panel');
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await dialog.getByRole('button', { name: 'Để chờ', exact: true }).click();
  await expect(dialog).toHaveCount(0);
  expect(api.state.get('ws_1')?.attempts.map((attempt) => attempt.status)).toEqual(['prepared']);

  await panel.getByRole('button', { name: 'Tiếp tục thanh toán' }).click();
  await dialog.getByRole('button', { name: 'Hủy khoản đang chuẩn bị' }).click();
  await dialog.getByRole('button', { name: 'Không', exact: true }).click();
  expect(api.state.get('ws_1')?.attempts.map((attempt) => attempt.status)).toEqual(['prepared']);
  await dialog.getByRole('button', { name: 'Hủy khoản đang chuẩn bị' }).click();
  await dialog.getByRole('button', { name: 'Xác nhận hủy' }).click();
  await expect(dialog).toHaveCount(0);
  expect(api.state.get('ws_1')?.attempts.map((attempt) => attempt.status)).toEqual(['canceled']);
});

test('the tender evidence print keeps its own content when receipt print styles are loaded', async ({
  page,
}) => {
  await mockPos(page, [{ id: 'ws_1', order_id: 'R250', total: 250000 }]);
  await login(page);
  await openTab(page, 'ws_1');
  await page.locator('.payment-panel').getByRole('button', { name: 'Thanh toán', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await expect(dialog.getByLabel('Khách đưa')).toBeVisible();
  // Receipt print rules apply only while a receipt prints, never to this print.
  await page.emulateMedia({ media: 'print' });
  await expect(dialog.getByLabel('Khách đưa')).toBeVisible();
  await expect(dialog.getByRole('button', { name: 'Kết thúc', exact: true })).toBeVisible();
  await page.emulateMedia({ media: 'screen' });
});
