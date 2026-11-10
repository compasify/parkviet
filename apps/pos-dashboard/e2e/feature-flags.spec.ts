import { expect, type Page, test } from '@playwright/test';
import { POS_FEATURES } from '@parkviet/pos-shared/pos-features';
import { installDashboardShell } from './support/dashboard';

async function install(page: Page, mode: 'owner' | 'manager' | 'reader', unsupported = false) {
  const state = { store: Object.fromEntries(POS_FEATURES.map((key) => [key, mode !== 'owner'])), branch: {} as Record<string, boolean>, writes: [] as Record<string, unknown>[] };
  await page.route('**/api/v3/admin/**', async (route) => {
    const url = new URL(route.request().url());
    const path = url.pathname.replace('/api/v3/admin', '');
    const branch = { id: 'br_1', name: 'Chi nhánh chính', code: 'main', status: 'active', timezone: 'Asia/Ho_Chi_Minh', stock_location_id: 'stock_1' };
    if (path === '/pos/context') return route.fulfill({ json: { staff: { id: 'staff_admin', full_name: 'Quản trị Hiền' }, store: { id: 'store_1', name: 'Siêu thị Hiền', currency: 'VND' }, administration: { read: mode !== 'manager', write: mode === 'owner' }, capabilities: mode === 'manager' && url.searchParams.get('branch_id') === 'br_1' ? ['pos.topology.manage'] : [], branches: [branch], registers: [], selection: { branch_id: url.searchParams.get('branch_id'), register_id: null }, onboarding: { required: false, can_setup: mode === 'owner' } } });
    if (path === '/pos/branches' || path === '/pos/context/branches') return route.fulfill({ json: { data: [branch], meta: { next: null } } });
    if (path === '/pos/feature_flags') {
      if (unsupported) return route.fulfill({ status: 404, json: { error: { code: 'not_found' } } });
      return route.fulfill({ json: { data: { branch_id: 'br_1', switches: Object.fromEntries(POS_FEATURES.map((feature) => [feature, { store: state.store[feature], branch_override: state.branch[feature] ?? null, effective: state.store[feature] && state.branch[feature] !== false }])), settings: [] } } });
    }
    if (path.startsWith('/pos/feature_flags/') && route.request().method() === 'PUT') {
      const body = route.request().postDataJSON() as Record<string, unknown>;
      const feature = path.split('/').at(-1) as typeof POS_FEATURES[number];
      state.writes.push({ feature, ...body });
      if (body.branch_id) { if (body.enabled === null) delete state.branch[feature]; else state.branch[feature] = body.enabled === true; }
      else state.store[feature] = body.enabled === true;
      return route.fulfill({ json: { data: {} } });
    }
    return route.fulfill({ json: { data: [], meta: { next: null } } });
  });
  await installDashboardShell(page, { authenticated: true, read: mode !== 'manager', write: mode === 'owner' });
  await page.goto('/store_1/branches/br_1/features');
  return state;
}
const credit = (page: Page) => page.locator('li[data-feature="credit"]');

test('owner enables store default, disables branch, restores inheritance; every change needs a reason', async ({ page }) => {
  const state = await install(page, 'owner');
  const row = credit(page);
  await expect(row).toContainText('Tắt (cửa hàng chưa bật)');
  await row.getByRole('button', { name: 'Bật Bán ghi nợ cho cả cửa hàng' }).click();
  const save = row.getByRole('button', { name: 'Lưu thay đổi' });
  await expect(save).toBeDisabled(); await expect(row.getByLabel('Lý do (bắt buộc)')).toBeFocused();
  await row.getByLabel('Lý do (bắt buộc)').fill('Đã duyệt'); await save.click();
  await expect(row).toContainText('Đang bật');
  await row.getByRole('button', { name: 'Tắt tại chi nhánh này' }).click();
  await row.getByLabel('Lý do (bắt buộc)').fill('Kiểm kê'); await row.getByRole('button', { name: 'Lưu thay đổi' }).click();
  await expect(row).toContainText('Tắt tại chi nhánh');
  await row.getByRole('button', { name: 'Bỏ tắt tại chi nhánh' }).click();
  await row.getByLabel('Lý do (bắt buộc)').fill('Kiểm kê xong'); await row.getByRole('button', { name: 'Lưu thay đổi' }).click();
  await expect(page.getByRole('status').filter({ hasText: 'tại chi nhánh này đã theo cài đặt của cửa hàng' })).toBeVisible();
  expect(state.writes).toEqual([{ feature: 'credit', enabled: true, reason: 'Đã duyệt' }, { feature: 'credit', branch_id: 'br_1', enabled: false, reason: 'Kiểm kê' }, { feature: 'credit', branch_id: 'br_1', enabled: null, reason: 'Kiểm kê xong' }]);
});

test('manager can only switch off own branch, cannot enable store or restore branch', async ({ page }) => {
  const state = await install(page, 'manager');
  const row = credit(page);
  await expect(row.getByRole('button', { name: /cho cả cửa hàng/ })).toHaveCount(0);
  await row.getByRole('button', { name: 'Tắt tại chi nhánh này' }).click();
  await row.getByLabel('Lý do (bắt buộc)').fill('Chưa duyệt'); await row.getByRole('button', { name: 'Lưu thay đổi' }).click();
  await expect(row.getByRole('button')).toHaveCount(0);
  expect(state.writes).toEqual([{ feature: 'credit', branch_id: 'br_1', enabled: false, reason: 'Chưa duyệt' }]);
});

test('read-only administrator cannot write feature switches', async ({ page }) => {
  const state = await install(page, 'reader');
  await expect(page.getByRole('list', { name: 'Danh sách chức năng' })).toBeVisible();
  await expect(credit(page).getByRole('button')).toHaveCount(0);
  expect(state.writes).toEqual([]);
});

test('older API without feature settings reports unsupported instead of exposing switches', async ({ page }) => {
  const state = await install(page, 'owner', true);
  await expect(page.getByRole('alert')).toBeVisible();
  await expect(credit(page)).toHaveCount(0); expect(state.writes).toEqual([]);
});
