import { readFileSync, writeFileSync } from 'node:fs';
import { expect, type Page, test } from '@playwright/test';

// Presentation fixtures only: these tests do not grant real account privileges.
async function install(page: Page, access = { read: true, write: true }) {
  const staff = [
    { id: 'staff_admin', full_name: 'Quản trị Hiền', email: 'admin@example.test' },
    { id: 'staff_lan', full_name: 'Nguyễn Thị Lan', email: 'lan@example.test' },
    { id: 'staff_an', full_name: 'Trần Văn An', email: 'an@example.test' },
  ];
  const branches = [{ id: 'branch_main', name: 'Siêu thị Hiền', code: 'main', status: 'active', timezone: 'Asia/Ho_Chi_Minh', stock_location_id: 'stock_main', receiving_stock_location_id: null as string | null, receiving_note: 'Nhận hàng tại cửa sau' }];
  const registers = [{ id: 'register_1', branch_id: 'branch_main', name: 'Quầy tầng một', code: 'q1', status: 'active' }];
  const memberships = [
    { id: 'membership_admin', staff_id: 'staff_admin', branch_id: 'branch_main', staff: staff[0], capabilities: ['pos.topology.recover'], status: 'active' },
    { id: 'membership_lan', staff_id: 'staff_lan', branch_id: 'branch_main', staff: staff[1], capabilities: ['pos.shift.open', 'pos.payment.collect'], status: 'active' },
  ];
  const state = { writes: [] as { method: string; path: string; body: Record<string, unknown> }[], staffPages: [] as number[], failOptions: false, failSave: false };
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname.replace('/api/v3/admin', '');
    if (/\/auth\/(login|refresh)$/.test(path)) return route.fulfill({ json: { token: 'fixture-only' } });
    if (path === '/me') return route.fulfill({ json: { user: staff[0] } });
    if (path === '/pos/context') return route.fulfill({ json: {
      staff: staff[0], store: { id: 'store_1', name: 'Siêu thị Hiền', currency: 'VND' },
      administration: access, capabilities: [], branches, registers: [], shift: null,
      selection: { branch_id: url.searchParams.get('branch_id'), register_id: null },
    } });
    if (path.startsWith('/pos/context/')) return route.fulfill({ json: { data: path.endsWith('branches') ? branches : [], meta: { page: 1, pages: 1, count: path.endsWith('branches') ? branches.length : 0 } } });
    if (path === '/pos/configuration/staff') {
      if (state.failOptions) return route.fulfill({ status: 403, json: { error: { code: 'access_denied' } } });
      const number = Number(url.searchParams.get('page'));
      state.staffPages.push(number);
      return route.fulfill({ json: { data: number === 1 ? staff.slice(0, 2) : staff.slice(2), meta: { next: number === 1 ? 2 : null } } });
    }
    if (path === '/pos/configuration/locations') return route.fulfill({ json: { data: [
      { id: 'stock_main', name: 'Kho hàng trung tâm', active: true }, { id: 'stock_returns', name: 'Kho tiếp nhận hàng', active: true },
    ] } });
    const resource = path.split('/')[2];
    const rows = resource === 'branches' ? branches : resource === 'registers' ? registers : resource === 'memberships' ? memberships : null;
    if (rows && request.method() === 'GET') return route.fulfill({ json: { data: rows } });
    if (rows && request.method() !== 'GET') {
      const body = request.postDataJSON();
      state.writes.push({ method: request.method(), path, body });
      if (state.failSave) return route.fulfill({ status: 422, json: { error: { code: 'validation_error', message: 'Code has already been taken' } } });
      const id = path.split('/')[3];
      const row = rows.find((item) => item.id === id);
      if (path.endsWith('/disable') || path.endsWith('/enable')) {
        if (row) row.status = path.endsWith('/disable') ? 'disabled' : 'active';
      } else if (request.method() === 'PATCH' && row) Object.assign(row, body);
      else (rows as unknown[]).push({ id: `${resource}_new`, status: 'active', ...body, ...(resource === 'memberships' ? { staff: staff.find((user) => user.id === body.staff_id) } : {}) });
      return route.fulfill({ json: { data: row ?? {} } });
    }
    return route.fulfill({ json: { data: [], meta: { page: 1, pages: 1, count: 0 } } });
  });
  return { state, branches, registers, memberships };
}

async function login(page: Page, administration = true) {
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('admin@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('fixture-only');
  await page.getByRole('button', { name: administration ? 'Đăng nhập vào quản trị bán hàng' : 'Đăng nhập vào bán hàng', exact: true }).click();
}

test('administration login uses store authority without a selling membership and shows a header cog', async ({ page }, testInfo) => {
  const { state } = await install(page);
  await login(page);
  await expect(page).toHaveURL(/\/settings$/);
  await expect(page.locator('.header-user')).toContainText('Quản trị Hiền');
  await expect(page.locator('.header-user .header-settings')).toBeVisible();
  await expect(page.getByRole('list', { name: 'Danh sách chi nhánh' })).toContainText('Kho hàng trung tâm');
  await expect(page.getByRole('button', { name: 'Thêm chi nhánh' })).toBeEnabled();
  expect(state.staffPages).toEqual(expect.arrayContaining([1, 2]));
  expect(state.writes).toEqual([]);
  await page.screenshot({ path: testInfo.outputPath('administration-branches.png'), fullPage: true });
  if (testInfo.project.name === 'desktop') {
    const html = await page.locator('.pos-layout').evaluate((element) => element.outerHTML);
    writeFileSync(testInfo.outputPath('administration-branches.html'), `<!doctype html><html lang="vi"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>POS administration — presentation fixture</title><style>${readFileSync('src/styles.css', 'utf8')}</style></head><body>${html}</body></html>`);
  }
  expect(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth)).toBe(true);
});

test('branch and register creation, editing, disabling and recovery use readable selectors', async ({ page }, testInfo) => {
  const { state } = await install(page);
  page.on('dialog', (dialog) => dialog.accept());
  await login(page);
  await page.getByRole('button', { name: 'Chỉnh sửa Siêu thị Hiền', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await dialog.getByLabel('Tên hiển thị').fill('Siêu thị Hiền · Trung tâm');
  await dialog.getByLabel('Kho nhận hàng', { exact: true }).selectOption('stock_returns');
  await dialog.getByLabel('Ghi chú nhận hàng').fill('Gọi trước khi nhận hàng');
  await dialog.getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect(dialog).toHaveCount(0);
  expect(state.writes[0]).toMatchObject({ method: 'PATCH', path: '/pos/branches/branch_main', body: { receiving_stock_location_id: 'stock_returns', receiving_note: 'Gọi trước khi nhận hàng' } });
  await page.getByRole('button', { name: 'Thêm chi nhánh', exact: true }).click();
  await dialog.getByLabel('Tên hiển thị').fill('Chi nhánh Quận 3');
  await dialog.getByLabel('Mã', { exact: true }).fill('q3');
  await dialog.getByLabel('Kho bán hàng', { exact: true }).selectOption('stock_main');
  await dialog.getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect(page.getByRole('list', { name: 'Danh sách chi nhánh' })).toContainText('Chi nhánh Quận 3');
  await page.getByRole('button', { name: 'Quầy bán hàng', exact: false }).click();
  const list = page.getByRole('list', { name: 'Danh sách quầy bán hàng' });
  await page.getByRole('button', { name: 'Thêm quầy', exact: true }).click();
  await dialog.getByLabel('Tên hiển thị').fill('Quầy tầng hai');
  await dialog.getByLabel('Mã', { exact: true }).fill('q2');
  await dialog.getByLabel('Chi nhánh', { exact: true }).selectOption('branch_main');
  await dialog.getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect(list).toContainText('Quầy tầng hai');
  await page.getByRole('button', { name: 'Chỉnh sửa Quầy tầng một', exact: true }).click();
  await dialog.getByLabel('Tên hiển thị').fill('Quầy ưu tiên');
  await expect(dialog.getByLabel('Chi nhánh', { exact: true })).toBeDisabled();
  await dialog.getByRole('button', { name: 'Lưu', exact: true }).click();
  const row = list.getByRole('listitem').filter({ hasText: 'Quầy ưu tiên' });
  await row.getByRole('button', { name: 'Ngừng hoạt động', exact: true }).click();
  await expect(row).toContainText('đã ngừng');
  await row.getByRole('button', { name: 'Kích hoạt lại', exact: true }).click();
  await expect(row).toContainText('đang dùng');
  await page.screenshot({ path: testInfo.outputPath('administration-registers.png'), fullPage: true });
});

test('staff permissions expose all capabilities and require confirmation for sensitive edits', async ({ page }, testInfo) => {
  const { state, memberships } = await install(page);
  await login(page);
  await page.getByRole('button', { name: 'Nhân viên & quyền', exact: false }).click();
  await page.getByRole('button', { name: 'Chỉnh sửa Nguyễn Thị Lan · lan@example.test', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await expect(dialog.locator('.admin-permissions input[type=checkbox]')).toHaveCount(18);
  await dialog.getByRole('checkbox', { name: 'Áp dụng giảm giá', exact: false }).check();
  await dialog.getByRole('checkbox', { name: 'Đổi giá bán', exact: false }).check();
  await expect(dialog.getByRole('button', { name: 'Lưu', exact: true })).toBeDisabled();
  await dialog.getByRole('checkbox', { name: 'Tôi xác nhận', exact: false }).check();
  await expect(dialog.locator('.admin-editor-context')).toBeVisible();
  await expect(dialog.locator('.admin-editor-context')).toContainText('lan@example.test');
  await page.screenshot({ path: testInfo.outputPath('administration-permission-editor.png') });
  expect(await dialog.evaluate((element) => element.scrollWidth <= element.clientWidth)).toBe(true);
  await dialog.getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect(dialog).toHaveCount(0);
  expect(state.writes[0]).toEqual({ method: 'PATCH', path: '/pos/memberships/membership_lan', body: { capabilities: ['pos.shift.open', 'pos.payment.collect', 'pos.discount.apply', 'pos.price.override'] } });
  expect(memberships).toHaveLength(2);
  await page.getByLabel('Tìm kiếm', { exact: true }).fill('lan@example.test');
  await expect(page.getByRole('list', { name: 'Danh sách nhân viên' }).getByRole('listitem')).toHaveCount(1);
  await page.screenshot({ path: testInfo.outputPath('administration-staff.png'), fullPage: true });
  await page.getByRole('button', { name: 'Cấp quyền nhân viên', exact: true }).click();
  await dialog.getByLabel('Chi nhánh', { exact: true }).selectOption('branch_main');
  await expect(dialog.getByLabel('Nhân viên', { exact: true }).locator('option')).toHaveText(['Chọn nhân viên', 'Trần Văn An · an@example.test']);
  await dialog.getByLabel('Nhân viên', { exact: true }).selectOption('staff_an');
  await dialog.getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect(dialog).toHaveCount(0);
  expect(state.writes[1]).toMatchObject({ method: 'POST', path: '/pos/memberships', body: { branch_id: 'branch_main', staff_id: 'staff_an', capabilities: ['pos.shift.open'] } });
});

test('cashiers cannot enter administration and readers cannot write', async ({ page }) => {
  const { state } = await install(page, { read: false, write: false });
  await login(page);
  await expect(page.getByText('Tài khoản chưa có quyền xem hoặc quản trị', { exact: false })).toBeVisible();
  await expect(page.locator('.header-settings')).toHaveCount(0);
  await expect(page.getByRole('button', { name: 'Thêm chi nhánh', exact: true })).toHaveCount(0);
  expect(state.staffPages).toEqual([]);
  expect(state.writes).toEqual([]);
});

test('read-only administration and failed option loads do not offer unsafe writes', async ({ page }) => {
  const { state } = await install(page, { read: true, write: false });
  await login(page);
  await expect(page.getByText('Chỉ xem', { exact: true })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Chỉnh sửa Siêu thị Hiền', exact: true })).toBeDisabled();
  expect(state.writes).toEqual([]);
});

test('validation failures retain the draft and failed option requests block editing', async ({ page }) => {
  const { state } = await install(page);
  await login(page);
  await page.getByRole('button', { name: 'Chỉnh sửa Siêu thị Hiền', exact: true }).click();
  const dialog = page.getByRole('dialog');
  await dialog.getByLabel('Tên hiển thị').fill('Tên chưa lưu');
  state.failSave = true;
  await dialog.getByRole('button', { name: 'Lưu', exact: true }).click();
  await expect(dialog.getByRole('alert')).toContainText('Code has already been taken');
  await expect(dialog.getByLabel('Tên hiển thị')).toHaveValue('Tên chưa lưu');
  page.once('dialog', (confirmation) => confirmation.accept());
  await dialog.getByRole('button', { name: 'Hủy', exact: true }).click();
  state.failOptions = true;
  await page.reload();
  await expect(page.getByText('Không tải được đầy đủ dữ liệu cấu hình.', { exact: false })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Thêm chi nhánh', exact: true })).toBeDisabled();
});
