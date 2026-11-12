import { expect, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import { addSheet, FULL_CASHIER, installRetailApi, newWorld, serialize, tab } from './support/retail-api';

// A cashier who may not void a sent dish asks the manager's phone instead of
// typing a code. The counter waits; once the manager grants it, the void goes
// through by itself with the granted approval. Presentation fixtures only.

const MODULES = { 'fnb.menu': true, resources: true, 'fnb.tables': true, 'fnb.kitchen': true };

test('asks the manager phone for a void and carries on once it is granted', async ({ context, page }) => {
  const world = newWorld({
    capabilities: [...FULL_CASHIER, 'pos.table.serve'],
    modules: MODULES,
    profile: { key: 'nha_hang', version: 1, display: { surface: 'menu_grid' } },
    menu: teaMenu(),
  });
  addSheet(world, 'ws_t1', { table: { id: 'posres_1', name: 'Bàn 1', label: null, guests: 2 } });
  await installRetailApi(context, world);
  await context.route('**/api/v3/admin/pos/resource_board**', (route) =>
    route.fulfill({
      json: { data: { branch_id: 'br_1', server_now: '2026-11-11T05:00:00Z', areas: [], resources: [] } },
    }),
  );

  const asked: Record<string, unknown>[] = [];
  const voids: Record<string, unknown>[] = [];
  let granted = false;
  const request = () => ({
    id: 'posapprovalreq_1',
    action: 'kitchen.void_sent',
    status: granted ? 'granted' : 'pending',
    approval_id: granted ? 'posappr_9' : null,
    reason: 'Khách đổi ý',
    decided_by_name: granted ? 'Chủ quán' : null,
    expires_at: '2026-11-11T05:10:00Z',
  });
  await context.route('**/api/v3/admin/pos/approval_requests**', (route) => {
    if (route.request().method() === 'POST') {
      asked.push(route.request().postDataJSON());
      return route.fulfill({ status: 201, json: { data: request() } });
    }
    return route.fulfill({ json: { data: request() } });
  });
  await context.route('**/api/v3/admin/pos/workspaces/*/sale_lines/*/kitchen_voids', (route) => {
    const body = route.request().postDataJSON();
    voids.push(body);
    const sheet = world.sheets.get('ws_t1');
    if (body.approval_id !== 'posappr_9' || !sheet)
      return route.fulfill({
        status: 409,
        json: { error: { code: 'conflict', message: 'approval', details: { reason: 'approval_required', action: 'kitchen.void_sent' } } },
      });
    return route.fulfill({ json: { data: serialize(world, sheet) } });
  });

  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill('staff@example.test');
  await page.getByLabel('Mật khẩu', { exact: true }).fill('password');
  await page.getByRole('button', { name: 'Đăng nhập bán hàng', exact: true }).click();
  await tab(page, 'ws_t1').click();
  await page.getByRole('list', { name: 'Thực đơn' }).getByRole('button', { name: 'Bánh flan', exact: true }).click();
  await expect.poll(() => world.sheets.get('ws_t1')?.lines.length).toBe(1);
  await page.getByRole('button', { name: /Báo bếp/ }).click();
  await expect.poll(() => world.sheets.get('ws_t1')?.kitchenSends?.length).toBe(1);

  await page.getByRole('button', { name: 'Giảm số lượng Bánh flan' }).click();
  const dialog = page.getByRole('dialog', { name: 'Hủy món đã báo bếp: Bánh flan' });
  await dialog.getByRole('button', { name: 'Gửi chủ duyệt' }).click();
  await expect(dialog.getByRole('status')).toContainText('đang chờ duyệt');
  expect(asked).toEqual([
    {
      branch_id: 'br_1',
      workspace_id: 'ws_t1',
      action_name: 'kitchen.void_sent',
      revision: String(world.sheets.get('ws_t1')?.revision),
      reason: 'Khách đổi ý',
    },
  ]);
  expect(voids).toHaveLength(0);

  // The manager grants it on their phone; the counter hears it and voids.
  granted = true;
  await expect(dialog).toHaveCount(0, { timeout: 15_000 });
  expect(voids.at(-1)).toMatchObject({ quantity: 1, reason_code: 'khach_doi_y', approval_id: 'posappr_9' });
});
