import { expect, type Page, type Route, test } from '@playwright/test';
import { goToMenuPage } from './support/menu';

type Status = 'active' | 'disabled';

type World = {
  recover: boolean;
  branchStatus: Status;
  membershipStatus: Status;
  hits: string[];
};

const branchId = 'br_1';
const registerId = 'reg_1';
const staffId = 'stf_1';
const membershipId = 'mem_1';

function capabilities(world: World) {
  const granted = ['pos.topology.manage'];
  if (world.recover) granted.push('pos.topology.recover');
  if (world.branchStatus === 'active' && world.membershipStatus === 'active') {
    granted.push('pos.shift.open');
  }
  return granted;
}

function branch(world: World) {
  return {
    id: branchId,
    name: 'Quan 1',
    code: 'q1',
    timezone: 'Asia/Ho_Chi_Minh',
    status: world.branchStatus,
    stock_location_id: 'sl_1',
    receiving_stock_location_id: null,
    receiving_note: null,
  };
}

function register(world: World) {
  return {
    id: registerId,
    branch_id: branchId,
    name: 'Quay 1',
    code: 'q1',
    status: world.branchStatus,
  };
}

function membership(world: World) {
  return {
    id: membershipId,
    branch_id: branchId,
    staff_id: staffId,
    staff: { id: staffId, email: 'lan@example.com', full_name: 'Lan' },
    capabilities: world.recover
      ? ['pos.topology.manage', 'pos.topology.recover', 'pos.shift.open']
      : ['pos.topology.manage', 'pos.shift.open'],
    status: world.membershipStatus,
  };
}

function context(world: World, url: URL) {
  const selectedBranch = url.searchParams.get('branch_id');
  const selectedRegister = url.searchParams.get('register_id');
  return {
    administration: { read: true, write: true },
    staff: { id: staffId, email: 'lan@example.com', full_name: 'Lan' },
    store: {
      id: 'store_1',
      name: 'Park Viet',
      currency: 'VND',
      locale: 'vi',
      timezone: 'Asia/Ho_Chi_Minh',
    },
    capabilities: selectedBranch === branchId ? capabilities(world) : ['pos.topology.manage'],
    branches: [branch(world)],
    registers: selectedBranch === branchId ? [register(world)] : [],
    shift:
      selectedRegister === registerId
        ? {
            id: 'sh_1',
            branch_id: branchId,
            register_id: registerId,
            status: 'open',
            opening_float: '10.0',
            currency: 'VND',
            owner_id: staffId,
            opened_at: '2026-11-04T07:00:00Z',
            reports: false,
          }
        : null,
    selection: {
      branch_id: selectedBranch === branchId ? branchId : null,
      register_id: selectedRegister === registerId ? registerId : null,
    },
  };
}

async function installApi(page: Page, world: World) {
  await page.route('**/api/v3/admin/**', async (route: Route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname;
    const method = request.method();
    world.hits.push(`${method} ${path}`);
    if (path.endsWith('/pos/configuration/staff')) return route.fulfill({ json: { data: [{ id: staffId, email: 'lan@example.com', full_name: 'Lan' }] } });
    if (path.endsWith('/pos/configuration/locations')) return route.fulfill({ json: { data: [{ id: 'sl_1', name: 'Kho chính', active: true }] } });
    if (path.endsWith('/pos/registers')) return route.fulfill({ json: { data: [register(world)] } });
    if (path.endsWith('/pos/context/branches')) return route.fulfill({ json: { data: [branch(world)], meta: { page: 1, pages: 1, count: 1 } } });
    if (path.endsWith('/pos/context/registers')) return route.fulfill({ json: { data: [register(world)], meta: { page: 1, pages: 1, count: 1 } } });

    if (method === 'POST' && path.endsWith('/auth/login')) {
      await route.fulfill({ json: { token: 'session-token' } });
      return;
    }
    if (method === 'POST' && path.endsWith('/auth/refresh')) {
      await route.fulfill({ json: { token: 'session-token' } });
      return;
    }
    if (method === 'POST' && path.endsWith('/auth/logout')) {
      await route.fulfill({ json: {} });
      return;
    }
    if (method === 'GET' && path.endsWith('/me')) {
      await route.fulfill({ json: { user: { email: 'lan@example.com', full_name: 'Lan' } } });
      return;
    }
    if (method === 'GET' && path.endsWith('/pos/context')) {
      await route.fulfill({ json: context(world, url) });
      return;
    }
    if (method === 'GET' && path.endsWith('/pos/branches')) {
      await route.fulfill({ json: { data: [branch(world)] } });
      return;
    }
    if (method === 'GET' && path.endsWith('/pos/memberships')) {
      await route.fulfill({ json: { data: [membership(world)] } });
      return;
    }
    if (method === 'GET' && path.endsWith('/pos/workspaces')) {
      await route.fulfill({
        json: {
          data: [
            {
              id: 'ws_1',
              branch_id: branchId,
              register_id: registerId,
              shift_id: 'sh_1',
              order_id: 'R123',
              revision: 1,
              lease_generation: 1,
              operational_status: 'editing',
              payments: false,
            },
          ],
          meta: { page: 1, pages: 1, count: 1 },
        },
      });
      return;
    }
    if (method === 'POST' && path.endsWith(`/pos/branches/${branchId}/disable`)) {
      world.branchStatus = 'disabled';
      await route.fulfill({ json: { data: branch(world) } });
      return;
    }
    if (method === 'POST' && path.endsWith(`/pos/branches/${branchId}/enable`)) {
      if (!world.recover) {
        await route.fulfill({ status: 403, json: { error: { code: 'access_denied' } } });
        return;
      }
      world.branchStatus = 'active';
      await route.fulfill({ json: { data: branch(world) } });
      return;
    }
    if (method === 'POST' && path.endsWith(`/pos/memberships/${membershipId}/disable`)) {
      world.membershipStatus = 'disabled';
      await route.fulfill({ json: { data: membership(world) } });
      return;
    }
    if (method === 'POST' && path.endsWith(`/pos/memberships/${membershipId}/enable`)) {
      if (!world.recover) {
        await route.fulfill({ status: 403, json: { error: { code: 'access_denied' } } });
        return;
      }
      world.membershipStatus = 'active';
      await route.fulfill({ json: { data: membership(world) } });
      return;
    }
    if (method === 'POST' && path.endsWith('/pos/workspaces')) {
      await route.fulfill({ status: 403, json: { error: { code: 'access_denied' } } });
      return;
    }
    await route.fulfill({ status: 404, json: { error: { code: 'missing' } } });
  });
}

async function openSession(page: Page) {
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('lan@example.com');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('secret');
  await page.getByRole('button', { name: 'Đăng nhập bán hàng', exact: true }).click();
  await expect(page.locator('.header-user')).toHaveText('Lan');
  await expect(page.getByText('Ca đang mở', { exact: true })).toBeAttached();
  await expect(page.getByRole('tab', { name: 'Hóa đơn 1' })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Đơn nháp mới' })).toBeEnabled();
}

test('an open session keeps history and locks writes when branch or staff is disabled', async ({
  page,
}) => {
  const world: World = {
    recover: false,
    branchStatus: 'active',
    membershipStatus: 'active',
    hits: [],
  };
  await installApi(page, world);
  page.on('dialog', (dialog) => dialog.accept());
  await openSession(page);

  await goToMenuPage(page, 'Cấu hình');
  await page.getByRole('button', { name: 'Nhân viên & quyền' }).click();
  const staffList = page.getByRole('list', { name: 'Danh sách nhân viên' });
  await staffList.getByRole('button', { name: 'Ngừng hoạt động', exact: true }).click();
  await expect(staffList.getByRole('listitem')).toContainText('lan@example.com');
  await expect(staffList.getByRole('listitem')).toContainText('đã ngừng');
  await expect(staffList.getByText('đã ngừng')).toBeVisible();
  await expect(staffList.getByRole('button', { name: 'Kích hoạt lại', exact: true })).toHaveCount(0);

  await page.getByRole('link', { name: 'Về quầy' }).click();
  await expect(page.locator('.header-user')).toHaveText('Lan');
  await expect(page.getByText('Ca đang mở', { exact: true })).toBeAttached();
  await expect(page.getByRole('tab', { name: 'Hóa đơn 1' })).toBeVisible();
  await expect(page.getByText('Ca và đơn đã có vẫn còn')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Đơn nháp mới' })).toBeDisabled();
  await expect(page.getByRole('button', { name: 'Tạm giữ' })).toBeDisabled();
  await expect(page.getByRole('button', { name: 'Mở ca' })).toHaveCount(0);

  await goToMenuPage(page, 'Cấu hình');
  const branchList = page.getByRole('list', { name: 'Danh sách chi nhánh' });
  await branchList.getByRole('button', { name: 'Ngừng hoạt động', exact: true }).click();
  await expect.poll(() => world.hits.join('\n')).toContain(`/pos/branches/${branchId}/disable`);
  await expect(branchList.getByRole('listitem')).toContainText('Quan 1');
  await expect(branchList.getByRole('listitem')).toContainText('đã ngừng');
  await expect(branchList.getByRole('button', { name: 'Kích hoạt lại', exact: true })).toHaveCount(0);
});

test('only the recover capability can enable a disabled branch or staff member', async ({
  page,
}) => {
  const world: World = {
    recover: true,
    branchStatus: 'active',
    membershipStatus: 'active',
    hits: [],
  };
  await installApi(page, world);
  page.on('dialog', (dialog) => dialog.accept());
  await openSession(page);
  await goToMenuPage(page, 'Cấu hình');

  const branchList = page.getByRole('list', { name: 'Danh sách chi nhánh' });
  await branchList.getByRole('button', { name: 'Ngừng hoạt động', exact: true }).click();
  await branchList.getByRole('button', { name: 'Kích hoạt lại', exact: true }).click();
  await expect(branchList.getByRole('listitem')).toContainText('đang dùng');
  await expect(branchList.getByRole('listitem')).toContainText('Quan 1');

  await page.getByRole('button', { name: 'Nhân viên & quyền' }).click();
  const staffList = page.getByRole('list', { name: 'Danh sách nhân viên' });
  await staffList.getByRole('button', { name: 'Ngừng hoạt động', exact: true }).click();
  await staffList.getByRole('button', { name: 'Kích hoạt lại', exact: true }).click();
  await expect(staffList.getByRole('listitem')).toContainText('đang dùng');
  await expect(staffList.getByRole('listitem')).toContainText('lan@example.com');

  await page.getByRole('link', { name: 'Về quầy' }).click();
  await expect(page.locator('.header-user')).toHaveText('Lan');
  await expect(page.getByText('Ca đang mở', { exact: true })).toBeAttached();
  await expect(page.getByRole('tab', { name: 'Hóa đơn 1' })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Đơn nháp mới' })).toBeEnabled();
});
