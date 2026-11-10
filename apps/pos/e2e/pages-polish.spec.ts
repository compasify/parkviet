import { readFileSync, writeFileSync } from 'node:fs';
import { expect, type Page, test, type TestInfo } from '@playwright/test';
import { pickOption } from './support/searchable-select';

// Isolated UI fixtures: no real account, funds or financial writes.
const branches = [
  { id: 'br_1', name: 'Siêu thị Hiền', code: 'STH', timezone: 'Asia/Ho_Chi_Minh', status: 'active' },
  { id: 'br_2', name: 'Chi nhánh Quận 3', code: 'Q3', timezone: 'Asia/Ho_Chi_Minh', status: 'active' },
];
const fund = (id: string, available: string, status = 'received') => ({
  id, branch_id: 'br_1', workspace_id: 'ws_1', shift_id: 'shift_1', kind: 'cash', status,
  handed_amount: '200000', applied_amount: '125000', change_amount: '0', received_net: '200000',
  currency: 'VND', reference: `GD-${id}`, allocated: available === '75000' ? '125000' : '200000', payout_reserved: '0', paid_out: '0', available,
  allocations: [{ id: `alloc_${id}`, order_id: 'R-001', workspace_id: 'ws_1', amount: '125000', currency: 'VND', status: 'active' }], payouts: [],
});

async function setup(page: Page, capabilities = ['pos.topology.manage', 'pos.payment.resolve']) {
  const state = { mode: 'ok', detailError: false, hits: [] as string[], writes: [] as { path: string; body: Record<string, unknown> }[], release: () => {} };
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname;
    state.hits.push(path);
    if (/\/auth\/(login|refresh)$/.test(path)) return route.fulfill({ json: { token: 'ui-fixture' } });
    if (path.endsWith('/me')) return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Thu ngân Hiền' } } });
    if (path.endsWith('/pos/context')) return route.fulfill({ json: {
      administration: { read: capabilities.includes('pos.topology.manage'), write: capabilities.includes('pos.topology.manage') },
      staff: { id: 'staff_1', email: 'staff@example.test', full_name: 'Thu ngân Hiền' },
      store: { id: 'store_1', name: 'Siêu thị Hiền', currency: 'VND' }, capabilities,
      branches, registers: [], shift: null,
      selection: { branch_id: url.searchParams.get('branch_id'), register_id: null },
    } });
    if (request.method() === 'POST') {
      state.writes.push({ path, body: request.postDataJSON() });
      // Only the membership test may write; all financial routes deliberately fail.
      if (path.endsWith('/pos/memberships')) return route.fulfill({ json: { data: { id: 'membership_2' } } });
      return route.fulfill({ status: 403, json: { error: { code: 'access_denied' } } });
    }
    if (path.endsWith('/pos/branches') || path.endsWith('/pos/context/branches')) return route.fulfill({ json: { data: branches, meta: { page: 1, pages: 1 } } });
    if (path.endsWith('/pos/memberships')) return route.fulfill({ json: { data: [{ id: 'mem_1', staff_id: 'staff_1', branch_id: 'br_1', status: 'active', capabilities }], meta: { page: 1, pages: 1 } } });
    if (path.endsWith('/pos/configuration/staff')) return route.fulfill({ json: { data: [{ id: 'staff_1', full_name: 'Thu ngân Hiền', email: 'staff@example.test' }, { id: 'staff_2', full_name: 'Nhân viên hai', email: 'second@example.test' }] } });
    if (path.endsWith('/pos/received_funds')) {
      if (state.mode === 'loading') await new Promise<void>((resolve) => { state.release = resolve; });
      if (state.mode === 'error') return route.fulfill({ status: 422, json: { error: { code: 'invalid' } } });
      const rows = state.mode === 'empty' || url.searchParams.get('branch_id') === 'br_2' || url.searchParams.get('page') === '2'
        ? [] : [fund('zero', '0'), fund('zero_decimal', '0.0'), fund('open', '75000'), fund('review', '0.00', 'attention')];
      return route.fulfill({ json: { data: rows, meta: { page: Number(url.searchParams.get('page') || 1), pages: 2, count: 4 } } });
    }
    if (/\/pos\/received_funds\/[^/]+$/.test(path)) {
      if (state.detailError) return route.fulfill({ status: 422, json: { error: { code: 'invalid' } } });
      return route.fulfill({ json: { data: fund(path.split('/').pop()!, '75000') } });
    }
    return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0 } } });
  });
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('fixture-only');
  await page.getByRole('button', { name: 'Đăng nhập bán hàng', exact: true }).click();
  await expect(page.locator('.header-user')).toHaveText('Thu ngân Hiền');
  return state;
}

async function chooseBranch(page: Page, id: string) {
  await page.locator('.pos-context-details > summary').click();
  await pickOption(page.locator('.context-popover'), 'Chi nhánh', id);
  await page.keyboard.press('Escape');
  await expect(page.locator('.pos-context-details')).not.toHaveAttribute('open');
  await expect(page.locator('.pos-context-details > summary')).toContainText(branches.find((branch) => branch.id === id)!.name);
}

async function capture(page: Page, testInfo: TestInfo, name: string) {
  await page.screenshot({ path: testInfo.outputPath(`${name}.png`), fullPage: true });
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
  const tooSmall = await page.evaluate(() => Array.from(document.querySelectorAll('button, input, select, summary, a[href]')).filter((el) => {
    if (!el.checkVisibility() || el.closest('.visually-hidden') || el.classList.contains('skip-link')) return false;
    if (el instanceof HTMLInputElement && el.type === 'checkbox') el = el.closest('label')!;
    const rect = el.getBoundingClientRect();
    return rect.width < 43.5 || rect.height < 43.5;
  }).map((el) => `${el.tagName}: ${el.textContent?.trim()}`));
  expect(tooSmall).toEqual([]);
  if (testInfo.project.name === 'desktop') {
    const html = await page.locator('.pos-layout').evaluate((el) => el.outerHTML);
    const css = readFileSync('src/styles.css', 'utf8');
    writeFileSync(testInfo.outputPath(`${name}.html`), `<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>POS UI fixture — no real transaction</title><style>${css}</style></head><body>${html}</body></html>`);
  }
}

test('login shares register styling, reveals password and handles pending / failed authentication', async ({ page }, testInfo) => {
  let release = () => {};
  await page.route('**/api/v3/admin/auth/login', async (route) => {
    await new Promise<void>((resolve) => { release = resolve; });
    await route.fulfill({ status: 401, json: { error: { code: 'unauthorized' } } });
  });
  await page.goto('/login');
  await expect(page.locator('.header')).toHaveCSS('background-color', 'rgb(7, 86, 154)');
  await expect(page.getByText('Phiên chỉ lưu trong bộ nhớ trình duyệt.')).toHaveCount(0);
  const saleButton = page.getByRole('button', { name: 'Đăng nhập bán hàng', exact: true });
  const adminLink = page.getByRole('link', { name: 'Đăng nhập quản trị', exact: true });
  const saleBox = (await saleButton.boundingBox())!;
  const adminBox = (await adminLink.boundingBox())!;
  expect(saleBox.y).toBeCloseTo(adminBox.y, 1);
  expect(adminBox.x).toBeGreaterThan(saleBox.x);
  await capture(page, testInfo, 'login');
  const password = page.getByLabel('Mật khẩu', { exact: true });
  await password.fill('fixture-only');
  await page.getByRole('button', { name: 'Hiện mật khẩu' }).click();
  await expect(password).toHaveAttribute('type', 'text');
  await page.getByRole('button', { name: 'Ẩn mật khẩu' }).click();
  await expect(password).toHaveAttribute('type', 'password');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await saleButton.click();
  await expect(password).toBeDisabled();
  const waitingButton = page.getByRole('button', { name: 'Đang xử lý…', exact: true });
  await expect(waitingButton).toHaveCount(1);
  await expect(waitingButton).toBeDisabled();
  release();
  await expect(page.getByRole('alert')).toContainText('Không thể đăng nhập');
  await expect(password).toHaveValue('');
  await expect(page.getByLabel('Email nhân viên')).toHaveValue('staff@example.test');
  await capture(page, testInfo, 'login-error');
});

test('funds and attention show scoped details, exact money and correct canonical zero filtering', async ({ page }, testInfo) => {
  const state = await setup(page);
  await page.goto('/funds');
  await expect(page.getByText('Mở bộ chọn chi nhánh / quầy', { exact: false })).toBeVisible();
  await chooseBranch(page, 'br_1');
  await expect(page.locator('.fund-row')).toHaveCount(4);
  await page.locator('.fund-row').filter({ hasText: 'GD-open' }).click();
  if (testInfo.project.name !== 'desktop') await expect(page.locator('.fund-detail h2')).toBeFocused();
  await expect(page.locator('.fund-detail')).toContainText('200.000 ₫');
  await expect(page.locator('.fund-breakdown')).toContainText('75.000 ₫');
  await capture(page, testInfo, 'funds');
  await page.locator('.fund-detail .page-disclosure > summary').filter({ hasText: 'Hoàn tiền' }).click();
  await expect(page.getByLabel('Người nhận', { exact: true })).toBeVisible();
  await capture(page, testInfo, 'funds-payout-form');
  await chooseBranch(page, 'br_2');
  await expect(page.locator('.fund-detail')).not.toContainText('200.000 ₫');
  await expect(page.locator('.liability-payouts')).toHaveCount(0);
  await expect(page.getByText('Chưa có khoản tiền đã nhận ở trang này.')).toBeVisible();
  await chooseBranch(page, 'br_1');
  await page.locator('.pos-page-nav').getByRole('link', { name: 'Cần chú ý' }).click();
  await expect(page.locator('.fund-row')).toHaveCount(2);
  await expect(page.locator('.fund-list')).not.toContainText('GD-zero');
  await capture(page, testInfo, 'attention');
  await page.getByRole('button', { name: 'Trang sau' }).click();
  await expect(page.getByText('Không có khoản thu cần chú ý trên trang này.')).toBeVisible();
  expect(state.writes).toEqual([]);
});

test('funds distinguish loading, error, detail failure and empty states without claiming success', async ({ page }, testInfo) => {
  const state = await setup(page);
  state.mode = 'loading';
  await page.goto('/funds');
  await chooseBranch(page, 'br_1');
  await expect(page.locator('.funds-list-panel .page-state--loading')).toBeVisible();
  await capture(page, testInfo, 'funds-loading');
  state.release();
  await expect(page.locator('.fund-row')).toHaveCount(4);
  state.detailError = true;
  await page.locator('.fund-row').first().click();
  await expect(page.locator('.fund-detail [role="alert"]')).toContainText('Dữ liệu gửi lên không hợp lệ.');
  state.mode = 'error';
  await page.getByRole('button', { name: 'Tải lại', exact: true }).click();
  await expect(page.locator('.funds-list-panel [role="alert"]')).toContainText('Dữ liệu gửi lên không hợp lệ.');
  await capture(page, testInfo, 'funds-error');
  state.mode = 'empty';
  await page.locator('.funds-list-panel').getByRole('button', { name: 'Thử lại' }).click();
  await expect(page.getByText('Chưa có khoản tiền đã nhận ở trang này.')).toBeVisible();
  await capture(page, testInfo, 'funds-empty');
  expect(state.writes).toEqual([]);
});

test('direct secondary URLs preserve permission boundaries', async ({ page }, testInfo) => {
  const state = await setup(page, []);
  for (const path of ['funds', 'payment-attention']) {
    await page.goto(`/${path}`);
    await expect(page.locator('.pos-page .page-state')).toContainText('Tài khoản này chưa được phép');
    await expect(page.locator('.pos-page form')).toHaveCount(0);
    await capture(page, testInfo, `${path}-denied`);
  }
  expect(state.hits.some((path) => /\/pos\/(branches|memberships|received_funds)/.test(path))).toBe(false);
  expect(state.writes).toEqual([]);
});

test('collection-only staff can view funds but cannot access reconciliation actions', async ({ page }, testInfo) => {
  const state = await setup(page, ['pos.payment.collect']);
  await page.goto('/funds');
  await chooseBranch(page, 'br_1');
  await page.locator('.fund-row').first().click();
  await expect(page.getByText('Chỉ xem. Cần quyền xử lý khoản thu')).toBeVisible();
  await expect(page.locator('.liability-payouts')).toHaveCount(0);
  await expect(page.locator('.pos-page-nav').getByRole('link', { name: 'Cần chú ý' })).toHaveCount(0);
  await capture(page, testInfo, 'funds-readonly');
  await page.goto('/payment-attention');
  await expect(page.locator('.pos-page .page-state')).toContainText('Tài khoản này chưa được phép');
  expect(state.writes).toEqual([]);
});
