import { expect, test } from '@playwright/test';

const workspace = (revision: number, financial?: Record<string, unknown>) => ({
  id: 'ws_1',
  branch_id: 'br_1',
  register_id: 'reg_1',
  shift_id: 'sh_1',
  order_id: 'R250',
  revision,
  lease_generation: 1,
  operational_status: revision >= 6 ? 'completed' : 'editing',
  payments: revision >= 3,
  line_items: [
    {
      id: 'line_1',
      variant_id: 'variant_1',
      product_id: 'prod_1',
      name: 'Áo xanh',
      sku: 'AO-1',
      quantity: 1,
      price: '250.0',
      amount: '250.0',
      discounts: [],
      sale_line_id: 'sale_1',
      kind: 'ordinary',
    },
  ],
  customer: null,
  discount: null,
  totals: {
    item_total: '250.0',
    discount_total: '0.0',
    manual_discount_total: '0.0',
    included_tax_total: '0.0',
    additional_tax_total: '0.0',
    total: '250.0',
    currency: 'VND',
  },
  financial: financial ?? {
    received: '0.0',
    allocated: '0.0',
    unapplied: '0.0',
    remaining: '250.0',
    change_due: '0.0',
    attempts: [],
  },
});

test('split tender: bank 100 then cash handed 200/change 50, complete and handover', async ({ page }) => {
  let revision = 0;
  let attempts: Array<Record<string, unknown>> = [];
  let received = '0.0';
  let allocated = '0.0';
  let remaining = '250.0';
  let changeDue = '0.0';
  const financial = () => ({
    received,
    allocated,
    unapplied: '0.0',
    remaining,
    change_due: changeDue,
    attempts,
  });
  const current = () => workspace(revision, financial());

  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname;
    const method = request.method();
    if (path.endsWith('/pos/context/branches')) return route.fulfill({ json: { data: [{ id: 'br_1', name: 'Branch', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } } });
    if (path.endsWith('/pos/context/registers')) return route.fulfill({ json: { data: [{ id: 'reg_1', branch_id: 'br_1', name: 'Register', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } } });
    if (path.endsWith('/auth/login') || path.endsWith('/auth/refresh')) {
      return route.fulfill({ json: { token: 'test-token' } });
    }
    if (path.endsWith('/me')) {
      return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Lan' } } });
    }
    if (path.endsWith('/pos/context')) {
      const branch = url.searchParams.get('branch_id');
      const register = url.searchParams.get('register_id');
      return route.fulfill({
        json: {
          staff: { id: 'stf_1', email: 'staff@example.test', full_name: 'Lan' },
          store: { id: 'store_1', name: 'Test', currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh' },
          capabilities: branch ? ['pos.shift.open', 'pos.payment.collect', 'pos.payment.resolve'] : [],
          branches: [{ id: 'br_1', name: 'Branch', status: 'active' }],
          registers: branch ? [{ id: 'reg_1', branch_id: 'br_1', name: 'Register', status: 'active' }] : [],
          shift: register
            ? { id: 'sh_1', owner_id: 'stf_1', opening_float: '0', currency: 'VND' }
            : null,
          selection: { branch_id: branch, register_id: register },
        },
      });
    }
    if (path.endsWith('/pos/workspaces') && method === 'GET') {
      return route.fulfill({
        json: { data: [workspace(revision)], meta: { page: 1, pages: 1, count: 1 } },
      });
    }
    if (path.endsWith('/pos/workspaces/ws_1') && method === 'GET') {
      return route.fulfill({ json: { data: current() } });
    }
    if (path.endsWith('/ws_1/lease') && method === 'POST') {
      revision = Math.max(revision, 0);
      return route.fulfill({ json: { data: current() } });
    }
    if (path.endsWith('/ws_1/lease') && method === 'PATCH') {
      return route.fulfill({ json: { data: current() } });
    }
    if (path.endsWith('/ws_1/payment_methods')) {
      return route.fulfill({
        json: {
          data: [
            { id: 'posmethod-cash', code: 'cash', name: 'Cash', kind: 'cash', status: 'active', position: 0 },
            { id: 'posmethod-bank_manual', code: 'bank_transfer', name: 'Bank transfer', kind: 'bank_manual', status: 'active', position: 1 },
          ],
        },
      });
    }
    if (path.endsWith('/pos/received_funds')) {
      return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0 } } });
    }
    if (path.endsWith('/ws_1/tender_attempts') && method === 'POST') {
      const body = request.postDataJSON() as { payment_method_id: string; amount: string };
      const kind = body.payment_method_id.endsWith('cash') ? 'cash' : 'bank_manual';
      const attempt = {
        id: `ten_${attempts.length + 1}`,
        workspace_id: 'ws_1',
        payment_method_id: body.payment_method_id,
        kind,
        status: 'prepared',
        amount: body.amount,
        order_total_snapshot: '250.0',
        currency: 'VND',
        workspace_revision: revision,
        received_funds_id: null,
        confirmed_at: null,
        canceled_at: null,
      };
      attempts = [...attempts, attempt];
      revision += 1;
      return route.fulfill({ json: { data: current() } });
    }
    if (path.includes('/tender_attempts/ten_') && path.endsWith('/confirm') && method === 'POST') {
      const body = request.postDataJSON() as { handed_amount?: string };
      const attemptId = path.split('/').at(-2);
      const attempt = attempts.find((item) => item.id === attemptId);
      if (!attempt) return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
      const applied = Number(attempt.amount);
      let handed = applied;
      if (attempt.kind === 'cash') {
        handed = Number(body.handed_amount ?? applied);
        changeDue = String(Math.max(handed - applied, 0));
      }
      received = String(Number(received) + applied);
      allocated = String(Number(allocated) + applied);
      remaining = String(250 - Number(allocated));
      attempts = attempts.map((item) =>
        item.id === attemptId ? { ...item, status: 'confirmed', received_funds_id: `fund_${attemptId}` } : item,
      );
      revision += 1;
      return route.fulfill({ json: { data: current() } });
    }
    if (path.endsWith('/ws_1/complete') && method === 'POST') {
      revision = 6;
      return route.fulfill({ json: { data: current() } });
    }
    if (path.endsWith('/ws_1/handover') && method === 'POST') {
      return route.fulfill({ json: { data: current() } });
    }
    return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
  });

  await page.goto('/pos/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('password');
  await page.getByRole('button', { name: 'Đăng nhập vào bán hàng', exact: true }).click();
  await expect(page.getByRole('tab', { name: 'Hóa đơn 1' })).toBeVisible();
  await page.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();

  const panel = page.locator('.payment-panel');
  const checkout = page.getByRole('complementary', { name: 'Thông tin thanh toán' });
  await expect(checkout.locator('.payment-panel')).toBeVisible();
  await expect(checkout).toContainText('Tổng đơn hàng');
  await expect(checkout).toContainText('250 ₫');
  await panel.getByRole('button', { name: 'Chuyển khoản', exact: true }).click();
  await panel.getByLabel('Chuyển khoản').fill('100');
  await expect(panel.getByLabel('Tiền mặt')).toHaveValue('150');
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  await panel.getByLabel('Mã tham chiếu giao dịch').fill('FT001');
  await panel.getByLabel('Tài khoản nhận').fill('VCB-123');
  await panel.getByLabel('Khách đưa').fill('200');
  await panel.getByRole('button', { name: 'Kết thúc', exact: true }).click();
  await expect(panel.getByText('Đã thu (đã xác nhận)')).toBeVisible();
  await expect(panel.getByText('Tiền thừa trả khách')).toBeVisible();
  await expect(panel.locator('.payment-summary')).toContainText('50');
  await panel.getByRole('button', { name: 'Hoàn tất đơn' }).click();
  await expect(page.getByRole('button', { name: 'Giao hàng tại quầy' })).toBeVisible();
  await page.getByRole('button', { name: 'Giao hàng tại quầy' }).click();
});
