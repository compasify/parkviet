import { expect, type Page, type Route, test } from '@playwright/test';
import { isRefusal, menuBody, priceMenuAdd, teaMenu } from './support/menu-api';
import { installRetailApi, login, newWorld, STAFF_ID, setNetwork, type World } from './support/retail-api';

// Selling cash sales while the server is out of reach: the counter keeps
// the sales with provisional numbers, sends each under its own offline key
// once the server answers, and the server prices them again. A sale whose
// price changed waits for review instead of being dropped.
// Presentation fixtures only: no real account privileges.

type OfflineRow = Record<string, unknown> & { id: string; status: string; collected_total: string; handed_amount: string };

type OfflineServer = {
  snapshots: number;
  // Every ingest the server received, by key, with what it answered.
  ingests: Array<{ key: string; body: Record<string, unknown> }>;
  results: Map<string, OfflineRow>;
  loseNextReply: boolean;
  resolves: Array<Record<string, unknown>>;
};

const money = (value: number) => `${value}.0`;

function snapshotBody(world: World) {
  if (!world.menu) throw new Error('menu world required');
  return {
    store: { id: 'store_1', name: 'ParkViet', currency: 'VND', profile: {} },
    branch: { id: 'br_1', name: 'Chi nhánh 1', code: 'CN1', timezone: 'Asia/Ho_Chi_Minh' },
    register: { id: 'reg_1', name: 'Quầy 1', code: 'Q1' },
    staff: { id: STAFF_ID, name: 'Lan' },
    shift: { id: 'sh_1', opened_at: '2026-11-07T01:00:00Z' },
    offline: { allowed: true, reason: null },
    menu: menuBody(world.menu),
    etag: 'snap-1',
    generated_at: new Date().toISOString(),
    max_age_seconds: 43200,
  };
}

// The server side of offline sales, as Ingest and Resolve behave: prices
// again from today's menu, completes in cash or holds for review, and
// answers a replayed key with what it answered before.
async function installOfflineServer(page: Page, world: World): Promise<OfflineServer> {
  const server: OfflineServer = { snapshots: 0, ingests: [], results: new Map(), loseNextReply: false, resolves: [] };
  const handler = async (route: Route) => {
    if (world.offline) return route.abort('internetdisconnected');
    const request = route.request();
    const path = new URL(request.url()).pathname.replace(/^.*\/api\/v3\/admin/, '');
    const method = request.method();
    if (path === '/pos/offline_snapshot') {
      server.snapshots += 1;
      return route.fulfill({ json: { data: snapshotBody(world) } });
    }
    if (path === '/pos/offline_sales' && method === 'GET')
      return route.fulfill({ json: { data: [...server.results.values()].filter((row) => row.status === 'needs_review') } });
    if (path === '/pos/offline_sales' && method === 'POST') {
      const key = request.headers()['idempotency-key'] ?? '';
      const body = request.postDataJSON() as Record<string, unknown>;
      server.ingests.push({ key, body });
      if (key !== `offline:${body.offline_id}`) return route.fulfill({ status: 409, json: { error: { code: 'conflict', details: { reason: 'offline_key_mismatch' } } } });
      let row = server.results.get(key);
      if (!row) {
        row = ingest(world, body);
        server.results.set(key, row);
      }
      if (server.loseNextReply) {
        server.loseNextReply = false;
        return route.abort('connectionreset');
      }
      return route.fulfill({ json: { data: row } });
    }
    const resolve = /^\/pos\/offline_sales\/([^/]+)\/resolve$/.exec(path);
    if (resolve && method === 'POST') {
      const body = request.postDataJSON() as Record<string, unknown>;
      server.resolves.push(body);
      const row = [...server.results.values()].find((entry) => entry.id === resolve[1]);
      if (!row || row.status !== 'needs_review') return route.fulfill({ status: 409, json: { error: { code: 'conflict', details: { reason: 'offline_sale_settled' } } } });
      const total = Number.parseFloat(String(row.current_total));
      world.drawer += total;
      Object.assign(row, { status: 'completed', resolution: body.mode, order_number: 'R-OFF-1' });
      return route.fulfill({ json: { data: row } });
    }
    return route.fallback();
  };
  await page.route('**/api/v3/admin/pos/offline_s*', handler);
  await page.route('**/api/v3/admin/pos/offline_sales/**', handler);
  return server;
}

function ingest(world: World, body: Record<string, unknown>): OfflineRow {
  const menu = world.menu;
  if (!menu) throw new Error('menu world required');
  const lines = body.lines as Array<{ variant_id: string; quantity: number; modifiers: unknown; name: string; unit_price: string }>;
  let current = 0;
  for (const line of lines) {
    const item = menu.items.find((row) => row.variantId === line.variant_id);
    if (!item) throw new Error(`unknown ${line.variant_id}`);
    const priced = priceMenuAdd(menu, item, { modifiers: line.modifiers });
    if (isRefusal(priced)) throw new Error(priced.reason);
    current += priced.unitPrice * line.quantity;
  }
  const collected = Number.parseFloat(String(body.total));
  const completed = current === collected;
  if (completed) world.drawer += current;
  world.counter += 1;
  return {
    id: `posoffline_${world.counter}`,
    offline_id: String(body.offline_id),
    provisional_number: String(body.provisional_number),
    status: completed ? 'completed' : 'needs_review',
    branch_id: 'br_1',
    register_id: 'reg_1',
    shift_id: 'sh_1',
    staff: { id: STAFF_ID, name: 'Lan' },
    client_sold_at: String(body.client_sold_at),
    clock_check: false,
    clock_skew_seconds: 0,
    collected_total: money(collected),
    handed_amount: String(body.handed_amount),
    currency: 'VND',
    lines,
    review_reason: completed ? null : 'price_changed',
    review_details: {},
    workspace_id: completed ? null : `ws_off_${world.counter}`,
    order_number: completed ? `R-OFF-${world.counter}` : null,
    call_number: null,
    current_total: money(current),
    resolution: null,
    resolution_note: null,
    resolved_at: null,
  };
}

const tile = (page: Page, name: string) =>
  page.getByRole('list', { name: 'Thực đơn' }).getByRole('button', { name, exact: true });

async function sellCash(page: Page, handed: string) {
  const cart = page.getByRole('complementary', { name: 'Đơn offline' });
  await cart.getByLabel('Khách đưa').fill(handed);
  await cart.getByRole('button', { name: 'Thu tiền mặt' }).click();
  await expect(cart.getByText(/Đã lưu đơn OFF-Q1-\d{6}-\d{3}, chờ đồng bộ\./)).toBeVisible();
}

test('cash sales made offline are sent once the server answers, a changed price waits for review', async ({ page, context }) => {
  const world = newWorld({ modules: { 'fnb.menu': true }, menu: teaMenu() });
  await installRetailApi(page, world);
  const server = await installOfflineServer(page, world);
  await login(page);
  // The register keeps its offline snapshot while online.
  await expect.poll(() => server.snapshots).toBeGreaterThan(0);

  await setNetwork(context, world, false);
  await page.getByRole('link', { name: 'Bán offline (chỉ tiền mặt)' }).click();
  await expect(page.getByRole('heading', { name: 'Bán offline', level: 1 })).toBeVisible();
  await expect(page.getByText(/chỉ thu tiền mặt, chỉ món trong thực đơn/)).toBeVisible();
  await page.getByText('Không làm được khi offline').click();
  await expect(page.getByText('Chuyển khoản, VietQR, thẻ, ví, thẻ tiền')).toBeVisible();

  // Nothing is taken without enough cash.
  await tile(page, 'Bánh flan').click();
  const cart = page.getByRole('complementary', { name: 'Đơn offline' });
  await cart.getByLabel('Khách đưa').fill('10000');
  await expect(cart.getByRole('button', { name: 'Thu tiền mặt' })).toBeDisabled();
  await sellCash(page, '20000');
  await expect(cart.getByText('Tiền thừa')).toHaveCount(0);
  // The provisional slip is ready to print, never as a receipt.
  const slip = page.getByTestId('receipt-print-sheet');
  await expect(slip).toContainText('PHIẾU TẠM – CHƯA ĐỒNG BỘ');
  await expect(slip).toContainText(/OFF-Q1-\d{6}-001/);
  await expect(slip).toContainText('Bánh flan');

  await tile(page, 'Trà đào').click();
  await tile(page, 'Trà đào').click();
  await expect(cart).toContainText('50.000 ₫');
  await sellCash(page, '50000');

  await tile(page, 'Trà sữa').click();
  const sheet = page.getByRole('dialog', { name: 'Trà sữa' });
  await sheet.getByRole('button', { name: 'Thêm vào đơn' }).click();
  await expect(cart).toContainText('30.000 ₫');
  await sellCash(page, '50.000');
  await expect(page.getByText('3 đơn offline chờ đồng bộ.')).toBeVisible();
  expect(server.ingests).toHaveLength(0);

  // Meanwhile the flan price went up on the server.
  const flan = world.menu?.items.find((item) => item.variantId === 'v_flan');
  if (flan) flan.price = 18000;
  // The first reply is lost on the way: the server has the sale, the counter does not know.
  server.loseNextReply = true;
  await setNetwork(context, world, true);
  await expect(page.getByText('Máy chủ đã trả lời lại.')).toBeVisible();
  await page.getByRole('link', { name: 'Về màn bán hàng' }).first().click();
  await expect(page.locator('.header-user')).toHaveText('Lan');

  const banner = page.locator('.offline-banner');
  await expect(banner.getByRole('link', { name: '1 đơn offline cần xem lại' })).toBeVisible();
  await expect(banner).not.toContainText('chờ đồng bộ');

  // Sent oldest first, the lost one again under the same key, never charged twice.
  const keys = server.ingests.map((row) => row.key);
  expect(keys[0]).toBe(keys[1]);
  expect(new Set(keys).size).toBe(3);
  expect(server.results.size).toBe(3);
  expect(server.ingests.every((row) => row.key === `offline:${row.body.offline_id}`)).toBe(true);
  expect(world.drawer).toBe(50000 + 30000);

  await banner.getByRole('link', { name: '1 đơn offline cần xem lại' }).click();
  const card = page.locator('.offline-review-card');
  await expect(card).toContainText('Giá đã đổi so với lúc bán');
  await expect(card).toContainText('15.000 ₫');
  await expect(card).toContainText('18.000 ₫');
  await card.getByRole('button', { name: 'Thu theo giá hiện tại' }).click();
  await expect(page.getByText('Không có đơn offline nào cần xem lại.')).toBeVisible();
  expect(server.resolves).toEqual([expect.objectContaining({ mode: 'current_price' })]);
  // The shift's cash: two sales at the collected price, the third at today's.
  expect(world.drawer).toBe(50000 + 30000 + 18000);
});

test('offline selling refuses without a snapshot of an open shift', async ({ page, context }) => {
  const world = newWorld({ modules: { 'fnb.menu': true }, menu: teaMenu() });
  await installRetailApi(page, world);
  await login(page);
  await expect(page.locator('.pos-context-details summary')).toContainText('Quầy 1');
  await setNetwork(context, world, false);
  // No snapshot was stored (the server never gave one): no way in.
  await expect(page.getByText('Máy này chưa có dữ liệu bán offline: cần mở ca và có mạng ít nhất một lần.')).toBeVisible();
  await expect(page.getByRole('link', { name: 'Bán offline (chỉ tiền mặt)' })).toHaveCount(0);
});
