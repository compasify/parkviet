import { expect, type Page, type Route, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import { installRetailApi, login, newWorld, type World } from './support/retail-api';

// A GrabFood order typed in at the counter: picked from the menu at the
// platform's price, listed in the platform tray (never as a tab), marked
// ready and handed to the driver. Presentation fixtures only: no real
// account privileges.

const MODULES = { 'fnb.menu': true, 'fnb.kitchen': true, 'fnb.order_number': true, 'fnb.delivery_platforms': true };

type Platforms = { entered: Record<string, unknown>[]; orders: Record<string, unknown>[]; calls: string[] };

function order(body: Record<string, unknown>, status: string) {
  return {
    id: 'posplatorder_1',
    workspace_id: 'ws_platform',
    order_id: 'or_platform',
    order_number: 7,
    business_date: '2026-11-11',
    platform: body.platform,
    platform_order_ref: body.platform_order_ref,
    pickup_code: body.pickup_code ?? null,
    status,
    gross_amount: '36000.0',
    commission_rate: '25.0',
    commission_amount: '9000.0',
    net_amount: '27000.0',
    currency: 'VND',
    entered_at: '2026-11-11T10:00:00.000+07:00',
    ready_at: null,
    completed_at: null,
    canceled_at: null,
    cancel_reason: null,
    settled_at: null,
    settlement_reference: null,
    items: [{ name: 'Bánh flan', quantity: '2.0', modifiers: [], note: null }],
  };
}

async function installPlatformApi(page: Page, _world: World, platforms: Platforms) {
  await page.route('**/api/v3/admin/pos/**', async (route: Route) => {
    const request = route.request();
    const path = new URL(request.url()).pathname.replace(/^.*\/api\/v3\/admin/, '');
    if (path === '/pos/platform_settings')
      return route.fulfill({
        json: {
          data: {
            module_enabled: true,
            platforms: [
              { platform: 'grabfood', status: 'active', commission_rate: '25.0', updated_at: null },
              { platform: 'shopeefood', status: 'disabled', commission_rate: '0.0', updated_at: null },
            ],
          },
        },
      });
    if (path === '/pos/platform_orders' && request.method() === 'GET')
      return route.fulfill({ json: { data: platforms.orders, meta: { page: 1, pages: 1, count: platforms.orders.length } } });
    if (path === '/pos/platform_orders' && request.method() === 'POST') {
      const body = request.postDataJSON() as Record<string, unknown>;
      platforms.entered.push(body);
      platforms.orders = [order(body, 'accepted')];
      return route.fulfill({ status: 201, json: { data: platforms.orders[0] } });
    }
    const action = /^\/pos\/platform_orders\/([^/]+)\/(ready|complete|cancel)$/.exec(path);
    if (action) {
      platforms.calls.push(action[2]);
      const current = platforms.orders[0] ?? {};
      const status = action[2] === 'ready' ? 'ready' : action[2] === 'complete' ? 'completed' : 'canceled';
      const next = { ...current, status };
      platforms.orders = status === 'ready' ? [next] : [];
      return route.fulfill({ json: { data: next } });
    }
    return route.fallback();
  });
}

test('enters a GrabFood order at the platform price, readies it and hands it to the driver', async ({ page }) => {
  const world = newWorld({ modules: MODULES, menu: teaMenu() });
  const platforms: Platforms = { entered: [], orders: [], calls: [] };
  await installRetailApi(page, world);
  await installPlatformApi(page, world, platforms);
  await login(page);

  await page.getByTestId('platform-enter').click();
  const form = page.getByTestId('platform-order-form');
  await expect(form.locator('[data-platform="grabfood"]')).toHaveAttribute('aria-pressed', 'true');
  await expect(form.locator('[data-platform="shopeefood"]')).toHaveCount(0);
  await form.getByTestId('platform-order-ref').fill('GF-1001');
  await form.getByTestId('platform-pickup-code').fill('A12');
  await form.getByRole('button', { name: 'Bánh flan' }).click();
  await form.getByLabel('Số lượng Bánh flan').fill('2');
  await expect(form.getByTestId('platform-line')).toContainText('15.000');
  await form.getByTestId('platform-line-price').fill('18.000');
  await expect(form.getByTestId('platform-order-total')).toContainText('36.000');
  await form.getByTestId('platform-order-submit').click();

  await expect(form).toHaveCount(0);
  expect(platforms.entered).toHaveLength(1);
  expect(platforms.entered[0]).toMatchObject({
    platform: 'grabfood',
    platform_order_ref: 'GF-1001',
    pickup_code: 'A12',
    lines: [{ variant_id: 'v_flan', quantity: 2, platform_price: '18000' }],
  });
  expect(platforms.entered[0].editor_id).toEqual(expect.any(String));

  // The tray lists it; the tabs never do.
  const row = page.getByTestId('platform-order-posplatorder_1');
  await expect(row).toContainText('GrabFood');
  await expect(row).toContainText('GF-1001');
  await expect(row).toContainText('Mã lấy A12');
  await expect(row).toContainText('2 × Bánh flan');
  await expect(page.locator('[data-workspace-id="ws_platform"]')).toHaveCount(0);

  await row.getByRole('button', { name: 'Sẵn sàng' }).click();
  await expect(row).toHaveAttribute('data-status', 'ready');
  await page.getByTestId('platform-complete-posplatorder_1').click();
  await expect(page.getByTestId('platform-order-posplatorder_1')).toHaveCount(0);
  expect(platforms.calls).toEqual(['ready', 'complete']);
});
