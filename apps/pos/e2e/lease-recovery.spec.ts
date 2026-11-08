import { expect, type Page, type Route, test } from '@playwright/test';

// How a page reacts when the server says its lease is stale: a lapsed lease that
// nobody else took is reclaimed, a lease taken elsewhere turns the page read-only.
type World = {
  generation: number;
  editor: string | null;
  staleHeartbeats: number;
  takenElsewhere: boolean;
  payments: boolean;
  claims: number;
  notePosts: number;
};

const stale = { error: { code: 'conflict', message: 'Lease is stale.', details: { reason: 'lease_stale', current_revision: 0 } } };

function workspace(world: World) {
  return {
    id: 'ws_1',
    branch_id: 'br_1',
    register_id: 'reg_1',
    shift_id: 'sh_1',
    order_id: 'R123',
    revision: 0,
    lease_generation: world.generation,
    operational_status: 'editing',
    payments: world.payments,
    note: null,
    line_items: [],
  };
}

async function installApi(page: Page, world: World) {
  await page.route('**/api/v3/admin/**', async (route: Route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname;
    const method = request.method();
    const one = { page: 1, pages: 1, count: 1 };
    if (path.endsWith('/auth/login') || path.endsWith('/auth/refresh')) return route.fulfill({ json: { token: 'test-token' } });
    if (path.endsWith('/me')) return route.fulfill({ json: { user: { email: 'staff@example.test', full_name: 'Lan' } } });
    if (path.endsWith('/pos/context/branches')) {
      return route.fulfill({ json: { data: [{ id: 'br_1', name: 'Branch', status: 'active' }], meta: one } });
    }
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
    if (path.endsWith('/pos/workspaces') && method === 'GET') {
      return route.fulfill({ json: { data: [workspace(world)], meta: one } });
    }
    if (path.endsWith('/pos/workspaces/ws_1') && method === 'GET') return route.fulfill({ json: { data: workspace(world) } });
    const body = (request.postDataJSON() ?? {}) as { editor_id?: string; lease_generation?: number };
    if (path.endsWith('/ws_1/lease') && method === 'POST') {
      world.claims += 1;
      if (world.takenElsewhere) {
        return route.fulfill({
          status: 409,
          json: { error: { code: 'conflict', details: { reason: 'lease_busy', retry_after_seconds: 90 } } },
        });
      }
      world.editor = body.editor_id ?? null;
      world.generation += 1;
      return route.fulfill({ json: { data: workspace(world) } });
    }
    if (path.endsWith('/ws_1/lease') && method === 'PATCH') {
      if (world.staleHeartbeats > 0 || world.takenElsewhere || body.lease_generation !== world.generation) {
        world.staleHeartbeats = Math.max(0, world.staleHeartbeats - 1);
        return route.fulfill({ status: 409, json: stale });
      }
      return route.fulfill({ json: { data: workspace(world) } });
    }
    if (path.endsWith('/ws_1/note') && method === 'POST') {
      world.notePosts += 1;
      if (world.takenElsewhere) return route.fulfill({ status: 409, json: stale });
      return route.fulfill({ json: { data: workspace(world) } });
    }
    if (path.endsWith('/pos/command_receipts')) return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
    return route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
  });
}

async function signIn(page: Page) {
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('password');
  await page.getByRole('button', { name: 'Đăng nhập bán hàng', exact: true }).click();
  await expect(page.getByRole('tab', { name: 'Hóa đơn 1' })).toBeVisible();
}

test('a lapsed lease that nobody else took is reclaimed without dropping to read-only', async ({ page }) => {
  const world: World = { generation: 1, editor: null, staleHeartbeats: 0, takenElsewhere: false, payments: false, claims: 0, notePosts: 0 };
  await installApi(page, world);
  await signIn(page);

  // The first renewal after claiming finds the lease already lapsed.
  world.staleHeartbeats = 1;
  await page.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();
  await expect.poll(() => world.claims).toBe(2);
  await expect(page.getByRole('button', { name: 'Tạm giữ' })).toBeEnabled();
  await expect(page.getByRole('button', { name: 'Nhận quyền sửa', exact: true })).toHaveCount(0);
  await expect(page.getByText('Quyền sửa đã hết hạn hoặc không thể xác nhận.', { exact: false })).toHaveCount(0);
  expect(world.generation).toBe(3);
});

test('a lease taken elsewhere turns the page read-only after a rejected edit', async ({ page }) => {
  const world: World = { generation: 1, editor: null, staleHeartbeats: 0, takenElsewhere: false, payments: false, claims: 0, notePosts: 0 };
  await installApi(page, world);
  await signIn(page);
  await page.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();
  await expect(page.getByRole('button', { name: 'Tạm giữ' })).toBeEnabled();

  world.takenElsewhere = true;
  await page.getByText('Ghi chú tại quầy').first().click();
  await page.getByLabel('Ghi chú nội bộ của đơn nháp').fill('khach quay lai');
  await page.getByRole('button', { name: 'Lưu ghi chú' }).click();
  await expect.poll(() => world.notePosts).toBe(1);
  await expect(page.getByRole('button', { name: 'Nhận quyền sửa', exact: true })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Tạm giữ' })).toBeDisabled();
  await expect(page.getByLabel('Ghi chú nội bộ của đơn nháp')).toBeDisabled();
});

test('a draft with recorded payments cannot be canceled from the menu', async ({ page }) => {
  const world: World = { generation: 1, editor: null, staleHeartbeats: 0, takenElsewhere: false, payments: true, claims: 0, notePosts: 0 };
  await installApi(page, world);
  await signIn(page);
  await page.getByRole('button', { name: 'Nhận quyền sửa', exact: true }).click();
  await expect(page.getByRole('button', { name: 'Tạm giữ' })).toBeEnabled();
  await page.getByText('Thao tác khác').click();
  const cancel = page.getByRole('button', { name: 'Hủy nháp' });
  await expect(cancel).toBeDisabled();
  await expect(cancel).toHaveAttribute('title', /Đơn đã ghi nhận thanh toán/);
});
