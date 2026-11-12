import { expect, test } from '@playwright/test';
import { installDashboardShell } from './support/dashboard';
import { BUSINESS_PROFILES } from './support/business-profiles';

// The original POS suite retains the sale/serial/receipt scenarios. These
// dashboard ports cover module configuration and unknown module visibility.
for (const enabled of [false, true]) test(`branch module settings render server switches ${enabled ? 'on' : 'off'} without changing sales`, async ({ page }) => {
  const modules = { 'retail.units': enabled, 'retail.measured': enabled, 'retail.traceability': enabled, 'future.module': true };
  const writes: string[] = [];
  const branch = { id: 'branch_main', name: 'Siêu thị Hiền', code: 'main', status: 'active', timezone: 'Asia/Ho_Chi_Minh', stock_location_id: 'stock_main', profile_key: 'khac' };
  await page.route('**/api/v3/admin/**', async (route) => {
    const url = new URL(route.request().url()); const path = url.pathname.replace('/api/v3/admin', '');
    if (route.request().method() !== 'GET') writes.push(path);
    if (path === '/pos/context') return route.fulfill({ json: { staff: { id: 'staff_admin', full_name: 'Quản trị Hiền' }, store: { id: 'store_1', name: branch.name, currency: 'VND' }, administration: { read: true, write: false }, capabilities: [], branches: [branch], registers: [], modules, selection: { branch_id: url.searchParams.get('branch_id'), register_id: null }, onboarding: { required: false, can_setup: false } } });
    if (path === '/pos/business_profiles') return route.fulfill({ json: { data: BUSINESS_PROFILES } });
    if (path === '/pos/branches/branch_main/modules') return route.fulfill({ json: { data: { branch_id: branch.id, modules, settings: [] } } });
    if (path === '/pos/branches' || path === '/pos/context/branches') return route.fulfill({ json: { data: [branch], meta: { next: null } } });
    return route.fulfill({ json: { data: [], meta: { next: null } } });
  });
  await installDashboardShell(page, { authenticated: true, write: false });
  await page.goto('/store_1/branches/branch_main');
  const list = page.getByRole('list', { name: 'Danh sách chức năng của chi nhánh' });
  // Every module the catalogue offers, plus the unknown server module.
  const offered = BUSINESS_PROFILES.modules.filter((item) => item.status === 'available').length;
  await expect(list.locator('li[data-module]')).toHaveCount(offered + 1);
  await expect(list.locator('[data-module="retail.traceability"]')).toContainText(enabled ? 'Đang bật' : 'Đang tắt');
  await expect(list.locator('[data-module="future.module"]')).toContainText('future.module');
  await expect(list.getByRole('button')).toHaveCount(0);
  expect(writes).toEqual([]);
});
