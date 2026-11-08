import { expect, type Page, test } from '@playwright/test';
import { receiptTemplateApi } from './support/receipt-templates';

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
  evidence_kind?: string;
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
  options: { rejectConfirm?: (body: ConfirmBody) => string | null; vietqr?: boolean } = {},
) {
  // Attempts the bank has reported a VietQR transfer for (the webhook landed).
  const bankReported = new Set<string>();
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
  // The store's print templates; each prints on its own paper.
  const templates = receiptTemplateApi([
    { id: 'postpl_sale', type: 'sale', name: 'Bán hàng K80', paper: '80mm', isDefault: true },
    { id: 'postpl_a5', type: 'sale', name: 'Bán hàng A5', paper: 'a5' },
    { id: 'postpl_ticket', type: 'payment_ticket', name: 'Thanh toán K80', paper: '80mm', isDefault: true },
    { id: 'postpl_k58', type: 'payment_ticket', name: 'Thanh toán K58', paper: '58mm' },
  ]);

  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname;
    const method = request.method();
    if (await templates.handle(route, path.replace(/^.*\/api\/v3\/admin/, ''), url, method)) return;
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
            ...(options.vietqr
              ? [{ id: 'posmethod-vietqr', code: 'vietqr', name: 'VietQR', kind: 'vietqr', status: 'active', position: 2 }]
              : []),
          ],
        },
      });
    const qrMatch = /^\/tender_attempts\/([^/]+)\/vietqr$/.exec(rest);
    if (qrMatch && method === 'GET') {
      const attempt = ws.attempts.find((item) => item.id === qrMatch[1]);
      if (!attempt) return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
      return route.fulfill({
        json: {
          data: {
            status: bankReported.has(attempt.id) || attempt.status === 'confirmed' ? 'confirmed' : 'allocated',
            amount: Number.parseInt(attempt.amount, 10),
            currency: 'VND',
            qr_url: `/qr/${attempt.id}.png`,
            bank_name: 'Vietcombank',
            account_number: '0123456789',
            account_name: 'PARK VIET',
            transfer_content: `MMO${ws.order_id}`,
            expires_at: new Date(Date.now() + 15 * 60_000).toISOString(),
            attempt_id: attempt.id,
            attempt_status: attempt.status,
          },
        },
      });
    }
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
          kind: body.payment_method_id.endsWith('cash')
            ? 'cash'
            : body.payment_method_id.endsWith('vietqr')
              ? 'vietqr'
              : 'bank_manual',
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
      } else if (attempt.kind === 'vietqr' && body.evidence_kind === 'vietqr_webhook') {
        if (!bankReported.has(attempt.id))
          return route.fulfill({
            status: 409,
            json: { error: { code: 'conflict', message: 'Not received.', details: { reason: 'vietqr_not_received' } } },
          });
      } else if (attempt.kind === 'bank_manual' && (!body.reference || !body.receiving_account)) {
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

  return { state, prepared, confirmed, bankReported };
}

async function login(page: Page) {
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('password');
  await page.getByRole('button', { name: 'Đăng nhập bán hàng', exact: true }).click();
  await expect(page.getByRole('tab').first()).toBeVisible();
}

async function openTab(page: Page, workspaceId: string) {
  await page.locator(`[role="tab"][data-workspace-id="${workspaceId}"]`).click();
  await page.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();
  await expect(page.locator('.payment-panel')).toBeVisible();
}

test('the URL and page title follow the selected invoice tab, and a link opens its tab', async ({ page }) => {
  await mockPos(page, [
    { id: 'ws_1', order_id: 'R250', total: 250 },
    { id: 'ws_2', order_id: 'R251', total: 100 },
  ]);
  await login(page);
  const tab = (id: string) => page.locator(`[role="tab"][data-workspace-id="${id}"]`);

  await tab('ws_2').click();
  await expect(page).toHaveURL(/[?&]order=R251\b/);
  await expect(page).toHaveTitle(/^R251 · Hóa đơn \d+ – ParkViet POS$/);
  await tab('ws_1').click();
  await expect(page).toHaveURL(/[?&]order=R250\b/);
  await expect(page).toHaveTitle(/^R250 · /);

  // A reload or a shared link opens that order's tab, not the remembered one.
  await page.goto('/?order=R251');
  await expect(tab('ws_2')).toHaveAttribute('aria-selected', 'true');
  await expect(page).toHaveURL(/[?&]order=R251\b/);
  await expect(page).toHaveTitle(/^R251 · /);

  // An unknown order falls back to the selected tab and fixes the URL.
  await page.goto('/?order=R999');
  await expect(page).toHaveURL(/[?&]order=R25[01]\b/);

  // Other pages keep the plain app title.
  await page.goto('/orders');
  await expect(page).toHaveTitle('ParkViet POS');
});

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
  // The invoice preview repeats these labels while the dialog is open.
  await expect(dialog).toHaveCount(0);
  await expect(panel.getByText('Đã thu (đã xác nhận)')).toBeVisible();
  await expect(panel.getByText('Tiền thừa trả khách')).toBeVisible();
  await expect(panel.locator('.payment-summary')).toContainText('50');
  await page.getByRole('button', { name: 'Giao hàng tại quầy' }).click();
  await expect(page.getByText('Đã giao hàng tại quầy.')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Giao hàng tại quầy' })).toHaveCount(0);
  expect(api.confirmed.map((item) => item.body.handed_amount ?? item.body.reference).sort()).toEqual(
    ['200', 'FT001'],
  );

  // "In hóa đơn" opens a print popup over the sale instead of leaving it.
  await page.route('**/pos/receipts/lookup?*', (route) =>
    route.fulfill({
      json: {
        data: {
          id: 'posreceipt_R250',
          source_type: 'sale',
          number: 'HD-0001',
          branch_id: 'branch_1',
          issued_at: '2026-11-07T03:00:00Z',
          issued_late: false,
          disclaimer: 'Phiếu bán hàng POS — không phải hóa đơn điện tử',
          printed: false,
          copy_count: 0,
          document: { title: 'PHIẾU BÁN HÀNG', currency: 'VND', lines: [], totals: { item_total: '250', total: '250' } },
        },
      },
    }),
  );
  const url = page.url();
  await panel.getByRole('button', { name: 'In hóa đơn', exact: true }).click();
  const receiptDialog = page.getByRole('dialog');
  await expect(receiptDialog).toContainText('HD-0001');
  await expect(receiptDialog.getByTestId('receipt-sheet')).toContainText('PHIẾU BÁN HÀNG');
  // The paper follows the print template.
  const templates = receiptDialog.getByRole('radiogroup', { name: 'Mẫu in' });
  await expect(templates.getByRole('radio')).toHaveCount(2);
  await expect(templates.getByRole('radio', { name: 'Bán hàng K80 · 80mm' })).toBeChecked();
  await expect(receiptDialog.getByTestId('receipt-sheet')).toHaveAttribute('data-paper', '80mm');
  await templates.getByRole('radio', { name: 'Bán hàng A5 · A5' }).check();
  await expect(receiptDialog.getByTestId('receipt-sheet')).toHaveAttribute('data-paper', 'a5');
  expect(page.url()).toBe(url);
  await page.keyboard.press('Escape');
  await expect(receiptDialog).toHaveCount(0);
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
  await dialog.getByRole('button', { name: 'Hủy bỏ', exact: true }).click();
  await expect(dialog).toHaveCount(0);
  await expect(panel.getByRole('button', { name: 'Tiếp tục thanh toán' })).toBeVisible();

  // Tab B: a plain cash sale with change.
  await openTab(page, 'ws_2');
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  await dialog.getByLabel('Khách đưa').fill('200.000');
  await expect(dialog).toContainText('80.000 ₫');
  await dialog.getByRole('button', { name: 'Kết thúc', exact: true }).click();
  await expect(panel.locator('.payment-summary')).toContainText('80.000');
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

test('"Đưa đủ" fills the exact cash due and the thermal preview shows the invoice table', async ({
  page,
}) => {
  const api = await mockPos(page, [{ id: 'ws_1', order_id: 'R250', total: 250000 }]);
  await login(page);
  await openTab(page, 'ws_1');
  await page.locator('.payment-panel').getByRole('button', { name: 'Thanh toán', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await expect(dialog.getByRole('columnheader', { name: 'Giảm giá' })).toBeVisible();
  const preview = dialog.getByTestId('invoice-ticket');
  await expect(preview).toContainText('HÓA ĐƠN THANH TOÁN');
  // The store default payment ticket template, on its paper.
  const templates = dialog.getByRole('radiogroup', { name: 'Mẫu in' });
  await expect(templates.getByRole('radio', { name: 'Thanh toán K80 · 80mm' })).toBeChecked();
  await expect(preview).toHaveAttribute('data-paper', '80mm');
  await dialog.getByRole('button', { name: 'Đưa đủ' }).click();
  await expect(dialog.getByLabel('Khách đưa')).toHaveValue('250000');
  await expect(dialog.getByRole('button', { name: 'Kết thúc', exact: true })).toBeFocused();
  await expect(preview).toContainText('Khách đưa');
  await templates.getByRole('radio', { name: 'Thanh toán K58 · 58mm' }).check();
  await expect(preview).toHaveAttribute('data-paper', '58mm');
  await expect(preview).toContainText('Khách đưa');
  await dialog.getByRole('button', { name: 'Kết thúc', exact: true }).click();
  await expect(dialog).toHaveCount(0);
  expect(api.confirmed.map((item) => item.body.handed_amount)).toEqual(['250000']);
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

test('VietQR: shows the QR, waits for the bank and confirms from its notification', async ({ page }) => {
  const api = await mockPos(page, [{ id: 'ws_1', order_id: 'R500', total: 500000 }], { vietqr: true });
  await login(page);
  await openTab(page, 'ws_1');

  const panel = page.locator('.payment-panel');
  // With VietQR offered, "Chuyển khoản" is the VietQR tender: no QR-less twin.
  await expect(panel.getByRole('button', { name: 'VietQR', exact: true })).toHaveCount(0);
  await expect(panel.getByRole('button', { name: 'Chuyển khoản', exact: true })).toHaveCount(1);
  await panel.getByRole('button', { name: 'Chuyển khoản', exact: true }).click();
  await panel.getByRole('button', { name: 'Tiền mặt', exact: true }).click();
  await expect(panel.getByLabel('Chuyển khoản', { exact: true })).toHaveValue('500000');
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();

  const dialog = page.getByRole('dialog', { name: 'Chuyển khoản VietQR' });
  await expect(dialog.getByRole('img', { name: 'Mã VietQR để quét bằng ứng dụng ngân hàng' })).toHaveAttribute(
    'src',
    '/qr/ten_ws_1_1.png',
  );
  await expect(dialog).toContainText('0123456789');
  await expect(dialog).toContainText('MMOR500');
  await expect(dialog).toContainText('Đang chờ ngân hàng');
  await expect(dialog.getByRole('button', { name: 'Kết thúc', exact: true })).toBeDisabled();

  api.bankReported.add('ten_ws_1_1');
  await expect(dialog).toContainText('Ngân hàng đã báo nhận tiền', { timeout: 10_000 });
  await expect(dialog.getByRole('button', { name: 'Kết thúc', exact: true })).toBeFocused();
  await dialog.getByRole('button', { name: 'Kết thúc', exact: true }).click();
  await expect(panel.getByText('Đã thu (đã xác nhận)')).toBeVisible();
  expect(api.prepared.map((item) => item.body.payment_method_id)).toEqual(['posmethod-vietqr']);
  expect(api.confirmed.map((item) => item.body.evidence_kind)).toEqual(['vietqr_webhook']);
});

test('a manual bank tender held from before VietQR switches to a VietQR QR of the same amount', async ({ page }) => {
  const api = await mockPos(page, [{ id: 'ws_1', order_id: 'R160', total: 160000 }], { vietqr: true });
  const ws = api.state.get('ws_1');
  if (!ws) throw new Error('missing workspace');
  ws.attempts.push({
    id: 'ten_ws_1_1',
    workspace_id: 'ws_1',
    payment_method_id: 'posmethod-bank_manual',
    kind: 'bank_manual',
    status: 'prepared',
    amount: money(160000),
    order_total_snapshot: money(160000),
    currency: 'VND',
    workspace_revision: 1,
    received_funds_id: null,
    confirmed_at: null,
    canceled_at: null,
  });
  await login(page);
  await openTab(page, 'ws_1');

  await page.locator('.payment-panel').getByRole('button', { name: 'Tiếp tục thanh toán' }).click();
  const bankDialog = page.getByRole('dialog', { name: 'Xác nhận chuyển khoản' });
  await bankDialog.getByRole('button', { name: 'Hiện mã VietQR' }).click();

  const dialog = page.getByRole('dialog', { name: 'Chuyển khoản VietQR' });
  await expect(dialog.getByRole('img', { name: 'Mã VietQR để quét bằng ứng dụng ngân hàng' })).toHaveAttribute(
    'src',
    '/qr/ten_ws_1_2.png',
  );
  await expect(dialog.getByRole('button', { name: 'Hiện mã VietQR' })).toHaveCount(0);
  expect(ws.attempts.map((item) => [item.kind, item.status])).toEqual([
    ['bank_manual', 'canceled'],
    ['vietqr', 'prepared'],
  ]);
  expect(api.prepared.map((item) => [item.body.payment_method_id, item.body.amount])).toEqual([
    ['posmethod-vietqr', '160000'],
  ]);
});

test('VietQR attested by hand saves without any bank details', async ({ page }) => {
  const api = await mockPos(page, [{ id: 'ws_1', order_id: 'R300', total: 300000 }], { vietqr: true });
  await login(page);
  await openTab(page, 'ws_1');

  const panel = page.locator('.payment-panel');
  await panel.getByRole('button', { name: 'Chuyển khoản', exact: true }).click();
  await panel.getByRole('button', { name: 'Tiền mặt', exact: true }).click();
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  const dialog = page.getByRole('dialog', { name: 'Chuyển khoản VietQR' });
  await dialog.getByRole('button', { name: 'Xác nhận đã chuyển', exact: true }).click();
  await dialog.getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect(dialog).toBeHidden();
  await expect(page.getByRole('button', { name: 'Giao hàng tại quầy' })).toBeVisible();
  const evidence = api.confirmed.map((item) => item.body);
  expect(evidence).toHaveLength(1);
  expect(evidence[0]).toMatchObject({ evidence_kind: 'vietqr_manual', receiving_account: '0123456789' });
  expect(evidence[0]).not.toHaveProperty('reference');
});

test('VietQR split with cash, attested by hand when no bank notification comes', async ({ page }) => {
  const api = await mockPos(page, [{ id: 'ws_1', order_id: 'R100', total: 100000 }], { vietqr: true });
  await login(page);
  await openTab(page, 'ws_1');

  const panel = page.locator('.payment-panel');
  await panel.getByRole('button', { name: 'Chuyển khoản', exact: true }).click();
  await panel.getByLabel('Tiền mặt').fill('40000');
  await expect(panel.getByLabel('Chuyển khoản', { exact: true })).toHaveValue('60000');
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await expect(dialog.getByLabel('Khách đưa')).toBeEnabled();
  expect(api.prepared.map((item) => [item.body.payment_method_id, item.body.amount])).toEqual([
    ['posmethod-cash', '40000'],
    ['posmethod-vietqr', '60000'],
  ]);

  await dialog.getByLabel('Khách đưa').fill('50000');
  await expect(dialog.getByRole('button', { name: 'Kết thúc', exact: true })).toBeDisabled();
  await dialog.getByRole('button', { name: 'Xác nhận đã chuyển', exact: true }).click();
  // The bank details are optional notes: the cashier may still add them.
  await expect(dialog.getByRole('button', { name: 'Lưu', exact: true })).toBeFocused();
  await expect(dialog.getByRole('button', { name: 'Kết thúc', exact: true })).toBeEnabled();
  await dialog.locator('input[name="vietqr_reference"]').fill('FT-HAND-1');
  await dialog.getByRole('button', { name: 'Kết thúc', exact: true }).click();
  await expect(dialog).toBeHidden();
  await expect(page.getByRole('button', { name: 'Giao hàng tại quầy' })).toBeVisible();
  const evidence = api.confirmed.map((item) => item.body);
  expect(evidence).toContainEqual(expect.objectContaining({ evidence_kind: 'cash_count', handed_amount: '50000' }));
  expect(evidence).toContainEqual(
    expect.objectContaining({ evidence_kind: 'vietqr_manual', reference: 'FT-HAND-1', receiving_account: '0123456789' }),
  );
});

// The sale receipt of ws_1 for the print popup, recording prints like the server.
async function mockSaleReceipt(page: Page) {
  const prints: Record<string, unknown>[] = [];
  const receipt = () => ({
    id: 'posreceipt_R250',
    source_type: 'sale',
    number: 'HD-0001',
    branch_id: 'br_1',
    issued_at: '2026-11-07T03:00:00Z',
    issued_late: false,
    disclaimer: 'Phiếu bán hàng POS — không phải hóa đơn điện tử',
    printed: prints.length > 0,
    copy_count: Math.max(prints.length - 1, 0),
    document: { title: 'PHIẾU BÁN HÀNG', currency: 'VND', lines: [], totals: { item_total: '250000', total: '250000' } },
  });
  await page.route('**/pos/receipts/lookup?*', (route) => route.fulfill({ json: { data: receipt() } }));
  await page.route('**/pos/receipts/posreceipt_R250/prints', (route) => {
    prints.push((route.request().postDataJSON() ?? {}) as Record<string, unknown>);
    const copyNumber = prints.length - 1;
    return route.fulfill({
      status: 201,
      json: {
        data: {
          print: { id: `posprint_${prints.length}`, copy: copyNumber > 0, copy_number: copyNumber, label: null, printed_at: '2026-11-07T03:01:00Z' },
          receipt: receipt(),
        },
      },
    });
  });
  await page.addInitScript(() => {
    window.print = () => {
      const sheet = window.document.querySelector('[data-testid="receipt-print-sheet"]');
      const seen = window as unknown as { receiptPrints?: string[] };
      seen.receiptPrints = [...(seen.receiptPrints ?? []), sheet?.getAttribute('data-print-id') ?? ''];
    };
  });
  return prints;
}

const receiptPrints = (page: Page) =>
  page.evaluate(() => (window as unknown as { receiptPrints?: string[] }).receiptPrints ?? []);

async function payInCash(page: Page) {
  await page.locator('.payment-panel').getByRole('button', { name: 'Thanh toán', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await dialog.getByRole('button', { name: 'Đưa đủ' }).click();
  await dialog.getByRole('button', { name: 'Kết thúc', exact: true }).click();
  await expect(page.getByRole('button', { name: 'Giao hàng tại quầy' })).toBeVisible();
}

test('a device set to print automatically prints the sale receipt as soon as the payment completes', async ({ page }) => {
  await mockPos(page, [{ id: 'ws_1', order_id: 'R250', total: 250000 }]);
  const prints = await mockSaleReceipt(page);
  await page.addInitScript(() => localStorage.setItem('parkviet-pos:auto-print:sale', 'on'));
  await login(page);
  await openTab(page, 'ws_1');
  await payInCash(page);

  const receiptDialog = page.getByRole('dialog');
  await expect(receiptDialog).toContainText('HD-0001');
  await expect.poll(() => receiptPrints(page)).toEqual(['posprint_1']);
  // Recorded like a print by hand.
  expect(prints).toHaveLength(1);
  expect(prints[0]).toHaveProperty('idempotency_key');
  await expect(receiptDialog.getByRole('status').filter({ hasText: 'Đã ghi nhận bản gốc' })).toBeVisible();
  await expect(receiptDialog.getByRole('checkbox', { name: /Tự in phiếu bán hàng/ })).toBeChecked();
});

test('automatic printing is off by default and set per device', async ({ page, browser }) => {
  await mockPos(page, [{ id: 'ws_1', order_id: 'R250', total: 250000 }]);
  const prints = await mockSaleReceipt(page);
  await login(page);
  await openTab(page, 'ws_1');
  await payInCash(page);
  // Nothing opens or prints by itself.
  await expect(page.getByRole('dialog')).toHaveCount(0);
  expect(await receiptPrints(page)).toEqual([]);
  expect(prints).toEqual([]);

  await page.locator('.payment-panel').getByRole('button', { name: 'In hóa đơn', exact: true }).click();
  const autoPrint = page.getByRole('dialog').getByRole('checkbox', { name: /Tự in phiếu bán hàng/ });
  await expect(autoPrint).not.toBeChecked();
  await autoPrint.check();
  expect(await page.evaluate(() => localStorage.getItem('parkviet-pos:auto-print:sale'))).toBe('on');
  // Opening the popup by hand or turning the setting on prints nothing.
  expect(prints).toEqual([]);

  // Another device keeps its own setting.
  const other = await browser.newContext();
  const otherPage = await other.newPage();
  await otherPage.goto(page.url());
  expect(await otherPage.evaluate(() => localStorage.getItem('parkviet-pos:auto-print:sale'))).toBeNull();
  await other.close();

  await autoPrint.uncheck();
  expect(await page.evaluate(() => localStorage.getItem('parkviet-pos:auto-print:sale'))).toBeNull();
});
