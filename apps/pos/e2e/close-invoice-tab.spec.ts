import { expect, test } from '@playwright/test';

const base = { branch_id: 'br_1', register_id: 'reg_1', shift_id: 'sh_1', revision: 0, lease_generation: 1, operational_status: 'editing', payments: false };
const empty = { ...base, id: 'ws_E', order_id: 'E', line_items: [], customer: null, note: null };
const blankNew = { ...empty, id: 'ws_new', order_id: 'NEW' };
const filled = {
  ...base,
  id: 'ws_F',
  order_id: 'F',
  note: null,
  customer: { id: 'pc_1', name: 'Chị An', phone: '0900000000', email: null, customer_id: null, has_account: false },
  line_items: [{ id: 'li_1', variant_id: 'v_1', product_id: 'p_1', name: 'Gạo', sku: 'G1', quantity: 2, price: '10000', amount: '20000', discounts: [] }],
  totals: { item_total: '20000', discount_total: '0', manual_discount_total: '0', included_tax_total: '0', additional_tax_total: '0', total: '20000', currency: 'VND' },
};
// List rows carry no lines, customer or totals.
function summary(workspace: Record<string, unknown>) {
  const { line_items: _lines, customer: _customer, totals: _totals, ...rest } = workspace;
  return rest;
}

test('the close button drops a blank invoice tab at once and asks before closing one with work', async ({ page }) => {
  const canceled: string[] = [];
  // Drafts the POS created, newest last: ws_new, then ws_new2.
  const created: Record<string, unknown>[] = [];
  const blankNew2 = { ...empty, id: 'ws_new2', order_id: 'NEW2' };
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname;
    if (path.endsWith('/pos/context/branches')) return route.fulfill({ json: { data: [{ id: 'br_1', name: 'Branch', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } } });
    if (path.endsWith('/pos/context/registers')) return route.fulfill({ json: { data: [{ id: 'reg_1', branch_id: 'br_1', name: 'Register', status: 'active' }], meta: { page: 1, pages: 1, count: 1 } } });
    if (path.endsWith('/auth/login') || path.endsWith('/auth/refresh')) return route.fulfill({ json: { token: 'test-token' } });
    if (path.endsWith('/me')) return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Lan' } } });
    if (path.endsWith('/pos/context')) {
      const branch = url.searchParams.get('branch_id');
      const register = url.searchParams.get('register_id');
      return route.fulfill({ json: {
        staff: { id: 'stf_1', email: 'staff@example.test', full_name: 'Lan' },
        store: { id: 'store_1', name: 'Test', currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh' },
        capabilities: branch ? ['pos.shift.open'] : [],
        branches: [{ id: 'br_1', name: 'Branch', status: 'active' }],
        registers: branch ? [{ id: 'reg_1', branch_id: 'br_1', name: 'Register', status: 'active' }] : [],
        shift: register ? { id: 'sh_1', register_id: 'reg_1', owner_id: 'stf_1', opening_float: '0', currency: 'VND' } : null,
        selection: { branch_id: branch, register_id: register },
      } });
    }
    if (path.endsWith('/pos/workspaces') && request.method() === 'GET') {
      const rows = [filled, empty].map(summary);
      for (const draft of created)
        if (!canceled.includes(draft.id as string)) rows.unshift(summary(draft));
      return route.fulfill({ json: { data: rows, meta: { page: 1, pages: 1, count: rows.length } } });
    }
    if (path.endsWith('/pos/workspaces/ws_E') && request.method() === 'GET') return route.fulfill({ json: { data: empty } });
    if (path.endsWith('/pos/workspaces/ws_F') && request.method() === 'GET') return route.fulfill({ json: { data: filled } });
    if (path.endsWith('/pos/workspaces/ws_new') && request.method() === 'GET') return route.fulfill({ json: { data: blankNew } });
    if (path.endsWith('/pos/workspaces/ws_new2') && request.method() === 'GET') return route.fulfill({ json: { data: blankNew2 } });
    if (path.endsWith('/pos/workspaces') && request.method() === 'POST') {
      const draft = created.length === 0 ? blankNew : blankNew2;
      created.push(draft);
      return route.fulfill({ json: { data: draft } });
    }
    if (path.endsWith('/pos/workspaces/ws_new/cancel') && request.method() === 'POST') {
      canceled.push('ws_new');
      return route.fulfill({ json: { data: { ...blankNew, revision: 1, operational_status: 'canceled' } } });
    }
    if (path.endsWith('/ws_new/lease')) return route.fulfill({ json: { data: blankNew } });
    if (path.endsWith('/ws_new2/lease')) return route.fulfill({ json: { data: blankNew2 } });
    return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
  });
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('password');
  await page.getByRole('button', { name: 'Đăng nhập bán hàng', exact: true }).click();
  const workspace = page.getByRole('region', { name: 'Đơn nháp trên quầy này' });
  const tab = (id: string) => workspace.locator(`[role="tab"][data-workspace-id="${id}"]`);
  const closeButton = (id: string) => workspace.locator(`.workspace-tab:has([data-workspace-id="${id}"]) .workspace-tab-close`);
  await expect(tab('ws_E')).toBeVisible();

  // A blank tab the cashier never touched disappears without a question.
  await tab('ws_E').hover();
  await closeButton('ws_E').click();
  await expect(tab('ws_E')).toHaveCount(0);
  await expect(page.getByRole('dialog')).toHaveCount(0);

  // A tab with a customer and lines asks first; going back keeps it.
  await tab('ws_F').hover();
  await closeButton('ws_F').click();
  const dialog = page.getByRole('dialog');
  await expect(dialog).toContainText('Khách hàng: Chị An');
  await expect(dialog).toContainText('1 dòng hàng (2 sản phẩm)');
  await dialog.getByRole('button', { name: 'Quay lại' }).click();
  await expect(dialog).toHaveCount(0);
  await expect(tab('ws_F')).toBeVisible();
  await tab('ws_F').hover();
  await closeButton('ws_F').click();
  await page.getByRole('dialog').getByRole('button', { name: 'Đóng tab, giữ đơn nháp' }).click();
  await expect(tab('ws_F')).toHaveCount(0);
  expect(canceled).toEqual([]);

  // Closing the last tab never leaves the counter without an invoice.
  await expect(tab('ws_new')).toBeVisible();
  await expect(tab('ws_new')).toHaveAttribute('aria-selected', 'true');

  // A blank draft this register opened is canceled on the server, not left
  // behind, and its place is taken by a fresh one.
  await tab('ws_new').hover();
  await closeButton('ws_new').click();
  await expect(tab('ws_new')).toHaveCount(0);
  expect(canceled).toEqual(['ws_new']);
  await expect(tab('ws_new2')).toBeVisible();
  expect(created).toHaveLength(2);
});
