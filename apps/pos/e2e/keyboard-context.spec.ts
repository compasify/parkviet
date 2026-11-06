import { expect, type Page, type Route, test } from '@playwright/test';

// Keyboard-only path from login to an open shift, and context switches whose
// earlier response arrives late, on every configured viewport.
type World = {
  shiftOpen: boolean;
  shiftPosts: Record<string, unknown>[];
  slowRegisterId?: string;
  slowStartedAt?: number;
  lateServedAt?: number;
};

const branch = {
  id: 'br_1',
  name: 'Quan 1',
  code: 'q1',
  timezone: 'Asia/Ho_Chi_Minh',
  status: 'active',
  stock_location_id: 'sl_1',
  receiving_stock_location_id: null,
  receiving_note: null,
};
const otherBranch = { ...branch, id: 'br_2', name: 'Quan 2', code: 'q2' };
const register = { id: 'reg_1', branch_id: 'br_1', name: 'Quay 1', code: 'q1', status: 'active' };
const otherRegister = { ...register, id: 'reg_2', name: 'Quay 2', code: 'q2' };
const shift = {
  id: 'sh_1',
  branch_id: 'br_1',
  register_id: 'reg_1',
  status: 'open',
  opening_float: '50000.0',
  currency: 'VND',
  owner_id: 'stf_1',
  opened_at: '2026-11-06T07:00:00Z',
  reports: false,
};

function context(world: World, url: URL) {
  const branchSelected = url.searchParams.get('branch_id') === branch.id;
  const requested = url.searchParams.get('register_id');
  const registerId = branchSelected && (requested === register.id || requested === otherRegister.id) ? requested : null;
  return {
    administration: { read: false, write: false },
    staff: { id: 'stf_1', email: 'lan@example.com', full_name: 'Lan' },
    store: { id: 'store_1', name: 'Park Viet', currency: 'VND', locale: 'vi', timezone: 'Asia/Ho_Chi_Minh' },
    capabilities: branchSelected ? ['pos.shift.open'] : [],
    branches: [branch, otherBranch],
    registers: branchSelected ? [register, otherRegister] : [],
    shift: registerId === register.id && world.shiftOpen ? shift : null,
    selection: {
      branch_id: branchSelected ? branch.id : null,
      register_id: registerId,
    },
  };
}

async function installApi(page: Page, world: World) {
  await page.route('**/api/v3/admin/**', async (route: Route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname;
    const method = request.method();
    const page1 = { page: 1, pages: 1, count: 2 };
    if (method === 'POST' && (path.endsWith('/auth/login') || path.endsWith('/auth/refresh'))) {
      return route.fulfill({ json: { token: 'session-token' } });
    }
    if (method === 'GET' && path.endsWith('/me')) {
      return route.fulfill({ json: { user: { email: 'lan@example.com', full_name: 'Lan' } } });
    }
    if (method === 'GET' && path.endsWith('/pos/context')) {
      const body = context(world, url);
      if (world.slowRegisterId && url.searchParams.get('register_id') === world.slowRegisterId) {
        world.slowStartedAt = Date.now();
        await new Promise((resolve) => setTimeout(resolve, 2000));
        world.lateServedAt = Date.now();
      }
      return route.fulfill({ json: body });
    }
    if (path.endsWith('/pos/context/branches')) return route.fulfill({ json: { data: [branch, otherBranch], meta: page1 } });
    if (path.endsWith('/pos/context/registers')) return route.fulfill({ json: { data: [register, otherRegister], meta: page1 } });
    if (method === 'GET' && path.endsWith('/pos/workspaces')) {
      return route.fulfill({ json: { data: [], meta: { page: 1, pages: 0, count: 0 } } });
    }
    if (method === 'POST' && path.endsWith('/pos/shifts')) {
      const body = request.postDataJSON() as Record<string, unknown>;
      world.shiftPosts.push(body);
      if (body.opening_float === '-1') {
        return route.fulfill({
          status: 422,
          json: { error: { code: 'validation_error', message: 'Opening float is invalid', details: { opening_float: ['is invalid'] } } },
        });
      }
      world.shiftOpen = true;
      return route.fulfill({ status: 201, json: { data: shift } });
    }
    return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
  });
}

async function tabUntilFocused(page: Page, target: ReturnType<Page['getByLabel']>, limit = 40) {
  for (let step = 0; step < limit; step += 1) {
    if (await target.evaluate((element) => element === document.activeElement)) return;
    await page.keyboard.press('Tab');
  }
  await expect(target).toBeFocused();
}

test('login, choose branch and register, and open a shift with the keyboard only', async ({ page }) => {
  const world: World = { shiftOpen: false, shiftPosts: [] };
  await installApi(page, world);
  await page.goto('/pos/login');

  const email = page.getByLabel('Email nhân viên');
  await tabUntilFocused(page, email);
  await page.keyboard.type('lan@example.com');
  await tabUntilFocused(page, page.getByLabel('Mật khẩu', { exact: true }));
  await page.keyboard.type('secret');
  await page.keyboard.press('Enter');

  const setup = page.getByRole('dialog', { name: 'Chọn nơi bán hàng' });
  const branchSelect = setup.getByLabel('Chi nhánh');
  await expect(branchSelect).toBeFocused();
  await page.keyboard.press('ArrowDown');
  await expect(branchSelect).toHaveValue(branch.id);

  const registerSelect = setup.getByLabel('Quầy');
  await expect(registerSelect).toBeEnabled();
  await tabUntilFocused(page, registerSelect);
  await page.keyboard.press('ArrowDown');
  await expect(setup).toBeHidden();

  const float = page.getByLabel('Tiền đầu ca');
  await tabUntilFocused(page, float);
  await page.keyboard.press('ControlOrMeta+A');
  await page.keyboard.type('-1');
  await page.keyboard.press('Enter');
  await expect(page.getByRole('alert').filter({ hasText: 'Dữ liệu gửi lên không hợp lệ.' })).toBeVisible();
  await expect(float).toBeFocused();
  await expect(page.getByRole('button', { name: 'Mở ca' })).toBeVisible();

  await page.keyboard.press('ControlOrMeta+A');
  await page.keyboard.type('50000');
  await page.keyboard.press('Enter');
  await expect(page.getByRole('button', { name: 'Mở ca' })).toHaveCount(0);
  await expect(page.getByText('Ca đang mở', { exact: true })).toBeAttached();
  expect(world.shiftPosts).toEqual([
    { register_id: register.id, opening_float: '-1' },
    { register_id: register.id, opening_float: '50000' },
  ]);
});

test('switching register never shows the previous register shift while the new context loads', async ({
  page,
}) => {
  const world: World = { shiftOpen: true, shiftPosts: [] };
  await installApi(page, world);
  await page.goto('/pos/login');
  await page.getByLabel('Email nhân viên').fill('lan@example.com');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('secret');
  await page.getByRole('button', { name: 'Đăng nhập vào bán hàng', exact: true }).click();

  const setup = page.getByRole('dialog', { name: 'Chọn nơi bán hàng' });
  await setup.getByLabel('Chi nhánh').selectOption(branch.id);
  await setup.getByLabel('Quầy').selectOption(register.id);
  await expect(setup).toBeHidden();
  await expect(page.getByText('Ca đang mở', { exact: true })).toBeAttached();

  // The second register answers slowly: the first register's shift must not linger
  // and the selector stays locked until the new context resolves.
  world.slowRegisterId = otherRegister.id;
  const picker = page.locator('.pos-context-details');
  const summary = picker.locator('summary');
  await summary.click();
  await picker.getByLabel('Quầy').selectOption(otherRegister.id);
  await expect.poll(() => world.slowStartedAt ?? 0).toBeGreaterThan(0);
  expect(world.lateServedAt).toBeUndefined();
  await expect(page.getByText('Ca đang mở', { exact: true })).toHaveCount(0);
  if (!(await picker.evaluate((element) => (element as HTMLDetailsElement).open))) await summary.click();
  await expect(picker.getByLabel('Quầy')).toBeDisabled();

  await expect.poll(() => world.lateServedAt ?? 0, { timeout: 5000 }).toBeGreaterThan(0);
  await expect(summary).toContainText('Quay 2');
  await expect(page.getByText('Ca đang mở', { exact: true })).toHaveCount(0);
  await expect(page.getByRole('button', { name: 'Mở ca' })).toBeVisible();
});
