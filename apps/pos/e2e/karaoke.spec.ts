import { expect, type Page, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import { addSheet, FULL_CASHIER, installRetailApi, login, newWorld, serialize, type World } from './support/retail-api';

// A karaoke room at the counter: the room board shows each room's clock,
// starting it opens the room's order on the server's time (the page sends
// no time), the clock counts from the server start, and stopping it shows the
// billed time charge. Presentation fixtures only: no real account privileges.

const MODULES = { 'fnb.menu': true, resources: true, 'fnb.tables': true, timed_billing: true };
const ROOMS = [
  { id: 'posres_1', name: 'P1', x: 0, y: 0 },
  { id: 'posres_2', name: 'VIP 1', x: 3, y: 0 },
];
const SERVER_NOW = '2026-11-12T14:40:00Z';

type Clock = {
  id: string;
  resourceId: string;
  workspaceId: string;
  status: 'running' | 'paused' | 'stopped';
  amount: string;
  // The prepaid package the clock was sold with.
  packageCode?: string;
  // A start corrected by hand.
  startedAt?: string;
};
type Recorded = {
  starts: Array<Record<string, unknown>>;
  stops: string[];
  edits: Array<Record<string, unknown>>;
  pauses: string[];
  resumes: string[];
};

const PACKAGE = { code: 'goi2h', name: 'Gói 2 giờ', minutes: 120, price: '250000.0' };

function board(world: World, clocks: Clock[]) {
  return {
    branch_id: 'br_1',
    server_now: SERVER_NOW,
    areas: [{ id: 'posarea_1', name: 'Tầng 2', position: 0, floor_width: 12, floor_height: 8 }],
    resources: ROOMS.map((room) => {
      const orders = [...world.sheets.values()].filter(
        (sheet) => sheet.table?.id === room.id && (sheet.status === 'editing' || sheet.status === 'parked'),
      );
      const clock = clocks.find((row) => row.resourceId === room.id && orders.some((sheet) => sheet.id === row.workspaceId));
      return {
        ...room, area_id: 'posarea_1', kind: 'room', capacity: 8, shape: 'rect', w: 2, h: 2, rotation: 0,
        manual_status: 'available',
        state: clock?.packageCode && clock.status !== 'stopped' ? 'ending_soon' : clock?.status === 'running' || clock?.status === 'paused' ? 'playing' : orders.length ? 'occupied' : 'available',
        guest_count: null, seated_minutes: orders.length ? 40 : null,
        subtotal: orders.length ? '0.0' : null, currency: orders.length ? 'VND' : null,
        payment_requested: false, edited_after_prebill: false,
        next_reservation: null, buffet_ends_at: null,
        timed: clock
          ? {
              id: clock.id, workspace_id: clock.workspaceId, status: clock.status,
              started_at: '2026-11-12T14:00:00Z',
              stopped_at: clock.status === 'stopped' ? SERVER_NOW : null,
              planned_end_at: clock.packageCode ? '2026-11-12T14:48:00Z' : null, played_minutes: 40, quote_amount: clock.amount,
              ending_soon: Boolean(clock.packageCode), paused_at: clock.status === 'paused' ? SERVER_NOW : null,
              prepaid_minutes: clock.packageCode ? PACKAGE.minutes : null, played_seconds: clock.status === 'stopped' ? null : 2400,
              package_ended: false, pause_too_long: false,
            }
          : null,
        orders: orders.map((sheet) => ({
          id: sheet.id, table_label: null, guest_count: null, total: serialize(world, sheet).totals.total,
          revision: sheet.revision, operational_status: sheet.status, payment_requested: false, prebilled: false,
          edited_after_prebill: false, pending_kitchen_items: 0,
        })),
      };
    }),
  };
}

function session(clock: Clock) {
  return {
    id: clock.id, status: clock.status, resource_id: clock.resourceId, resource_name: 'P1',
    started_at: '2026-11-12T14:00:00Z', stopped_at: clock.status === 'stopped' ? SERVER_NOW : null,
    played_minutes: 40, billed_minutes: 45, amount: clock.amount, currency: 'VND',
    segments: [
      {
        id: `${clock.id}_seg`, kind: 'play', resource_id: clock.resourceId, resource_name: 'P1',
        started_at: clock.startedAt ?? '2026-11-12T14:00:00Z', ended_at: clock.status === 'stopped' ? SERVER_NOW : null,
        rate_plan_id: null, rate_plan_name: null, rate_plan_version: null, edited: Boolean(clock.startedAt),
      },
    ],
    quote: {
      as_of: SERVER_NOW, final: clock.status === 'stopped', played_minutes: 40, billed_minutes: 45, amount: clock.amount,
      lines:
        clock.packageCode && clock.status === 'stopped'
          ? [
              { kind: 'package', starts_at: '2026-11-12T14:00:00Z', ends_at: '2026-11-12T14:40:00Z', minutes: 40, label: null, price_per_hour: '0.0', amount: '250000.0', promotion_id: null },
              { kind: 'bonus', starts_at: '2026-11-12T14:40:00Z', ends_at: '2026-11-12T14:55:00Z', minutes: 15, label: null, price_per_hour: '0.0', amount: '0.0', promotion_id: 'postpromo_1' },
            ]
          : [],
    },
    paused_at: clock.status === 'paused' ? SERVER_NOW : null,
    package: clock.packageCode ? PACKAGE : null,
    minutes_card: null,
  };
}

// The room's order as the server sends it: its time line carries the clock.
function orderView(world: World, clocks: Clock[], workspaceId: string) {
  const sheet = world.sheets.get(workspaceId);
  if (!sheet) return null;
  const view = serialize(world, sheet);
  const clock = clocks.find((row) => row.workspaceId === workspaceId);
  if (!clock) return view;
  const line = {
    id: `li_${clock.id}`, sale_line_id: `possl_${clock.id}`, variant_id: 'v_time', product_id: 'p_time', name: 'Giờ hát',
    sku: '', quantity: 1, price: '0.0', unit_price: '0.0', list_price: '0.0', amount: '0.0', discounts: [], kind: 'timed',
    timed_session: session(clock),
  };
  return { ...view, line_items: [...view.line_items, line] };
}

async function installClocks(page: Page, world: World): Promise<Recorded> {
  const recorded: Recorded = { starts: [], stops: [], edits: [], pauses: [], resumes: [] };
  const clocks: Clock[] = [];
  await page.route('**/api/v3/admin/pos/workspaces/*', (route) => {
    const id = /\/pos\/workspaces\/([^/]+)$/.exec(new URL(route.request().url()).pathname)?.[1];
    const view = route.request().method() === 'GET' && id ? orderView(world, clocks, id) : null;
    return view ? route.fulfill({ json: { data: view } }) : route.fallback();
  });
  await page.route('**/api/v3/admin/pos/timed_sessions/*/segments/*', (route) => {
    const parts = new URL(route.request().url()).pathname.split('/');
    const clock = clocks.find((row) => row.id === parts.at(-3));
    if (!clock) return route.fulfill({ status: 404, json: { error: { code: 'missing', message: 'missing' } } });
    const body = route.request().postDataJSON() as Record<string, unknown>;
    recorded.edits.push(body);
    if (!body.approval_id)
      return route.fulfill({
        status: 409,
        json: { error: { code: 'conflict', message: 'approval', details: { reason: 'approval_required', action: 'timed.edit_segment' } } },
      });
    clock.startedAt = String(body.started_at);
    return route.fulfill({ json: { data: { workspace: orderView(world, clocks, clock.workspaceId), timed_session: session(clock) } } });
  });
  await page.route('**/api/v3/admin/pos/resource_board**', (route) =>
    route.fulfill({ json: { data: board(world, clocks) } }),
  );
  await page.route('**/api/v3/admin/pos/resources/*/timed_sessions', (route) => {
    const request = route.request();
    const body = request.postDataJSON() as Record<string, unknown>;
    recorded.starts.push(body);
    const resourceId = new URL(request.url()).pathname.split('/').at(-2) ?? '';
    const room = ROOMS.find((row) => row.id === resourceId);
    if (!room) return route.fulfill({ status: 404, json: { error: { code: 'missing', message: 'missing' } } });
    const sheet = addSheet(world, `ws_k${world.sheets.size + 1}`, {
      editor: String(body.editor_id),
      table: { id: room.id, name: room.name, label: null, guests: null },
    });
    const clock: Clock = {
      id: `postimed_${clocks.length + 1}`, resourceId, workspaceId: sheet.id, status: 'running', amount: '75000.0',
      packageCode: typeof body.package_code === 'string' ? body.package_code : undefined,
    };
    clocks.push(clock);
    return route.fulfill({ status: 201, json: { data: { workspace: orderView(world, clocks, sheet.id), timed_session: session(clock) } } });
  });
  await page.route('**/api/v3/admin/pos/timed_sessions/*/quote', (route) => {
    const id = new URL(route.request().url()).pathname.split('/').at(-2);
    const clock = clocks.find((row) => row.id === id);
    return clock
      ? route.fulfill({ json: { data: session(clock) } })
      : route.fulfill({ status: 404, json: { error: { code: 'missing', message: 'missing' } } });
  });
  await page.route('**/api/v3/admin/pos/timed_sessions/*/stop', (route) => {
    const id = new URL(route.request().url()).pathname.split('/').at(-2) ?? '';
    recorded.stops.push(id);
    const clock = clocks.find((row) => row.id === id);
    if (!clock) return route.fulfill({ status: 404, json: { error: { code: 'missing', message: 'missing' } } });
    clock.status = 'stopped';
    clock.amount = '100000.0';
    return route.fulfill({
      json: { data: { workspace: orderView(world, clocks, clock.workspaceId), timed_session: session(clock) } },
    });
  });
  for (const verb of ['pause', 'resume'] as const)
    await page.route(`**/api/v3/admin/pos/timed_sessions/*/${verb}`, (route) => {
      const id = new URL(route.request().url()).pathname.split('/').at(-2) ?? '';
      const clock = clocks.find((row) => row.id === id);
      if (!clock) return route.fulfill({ status: 404, json: { error: { code: 'missing', message: 'missing' } } });
      (verb === 'pause' ? recorded.pauses : recorded.resumes).push(id);
      clock.status = verb === 'pause' ? 'paused' : 'running';
      return route.fulfill({
        json: { data: { workspace: orderView(world, clocks, clock.workspaceId), timed_session: session(clock), warnings: [] } },
      });
    });
  await page.route('**/api/v3/admin/pos/rate_plans?**', (route) =>
    route.fulfill({
      json: {
        data: [{ id: 'posrate_1', name: 'Phòng thường', resource_type_code: 'room', status: 'active', packages: [PACKAGE] }],
        meta: { weekend_days: [6, 0] },
      },
    }),
  );
  await page.route('**/api/v3/admin/pos/attendant_assignments**', (route) => route.fulfill({ json: { data: [] } }));
  return recorded;
}

const floor = (page: Page) => page.locator('.table-floor');
const tile = (page: Page, name: string) => floor(page).locator('.table-tile', { hasText: name });

test('a room clock starts and stops on the server time', async ({ page }) => {
  const world = newWorld({
    capabilities: [...FULL_CASHIER, 'pos.table.serve', 'pos.timed.operate'],
    modules: MODULES,
    profile: { key: 'karaoke_bida', version: 3, display: { surface: 'resource_board' } },
    menu: teaMenu(),
  });
  await installRetailApi(page, world);
  const recorded = await installClocks(page, world);
  await login(page);

  await expect(floor(page)).toBeVisible();
  await expect(floor(page).getByRole('button', { name: 'Phòng', exact: true })).toHaveAttribute('aria-pressed', 'true');
  await tile(page, 'P1').click();
  const panel = page.getByRole('complementary', { name: 'P1' });
  await panel.getByRole('button', { name: 'Bắt đầu tính giờ' }).click();

  // The page names the room and branch only: no start time.
  await expect.poll(() => recorded.starts.length).toBe(1);
  expect(recorded.starts[0]).toEqual(expect.objectContaining({ branch_id: 'br_1' }));
  expect(typeof recorded.starts[0].editor_id).toBe('string');
  expect(Object.keys(recorded.starts[0])).not.toContain('started_at');

  // Back on the floor the room is playing, its clock counted from the
  // server's start with the server clock: 40 minutes in.
  await page.getByRole('button', { name: 'Sơ đồ bàn', exact: true }).click();
  await expect(tile(page, 'P1')).toHaveAttribute('aria-label', 'P1 · Đang tính giờ');
  await expect(tile(page, 'P1').locator('.timed-clock')).toHaveText(/^4\d:\d\d$/);
  await tile(page, 'P1').click();
  await expect(panel).toContainText('75.000');

  await panel.getByRole('button', { name: 'Dừng giờ' }).click();
  await expect.poll(() => recorded.stops).toEqual(['postimed_1']);
  await expect(panel).toContainText('100.000');
  await expect(panel).toContainText('Đã dừng lúc');
});

test('checkout on a running room stops its clock first, then opens the payment', async ({ page }) => {
  const world = newWorld({
    capabilities: [...FULL_CASHIER, 'pos.table.serve', 'pos.timed.operate'],
    modules: MODULES,
    profile: { key: 'karaoke_bida', version: 3, display: { surface: 'resource_board' } },
    menu: teaMenu(),
  });
  await installRetailApi(page, world);
  const recorded = await installClocks(page, world);
  await login(page);

  await tile(page, 'P1').click();
  const panel = page.getByRole('complementary', { name: 'P1' });
  await panel.getByRole('button', { name: 'Bắt đầu tính giờ' }).click();
  await expect.poll(() => recorded.starts.length).toBe(1);
  await page.getByRole('button', { name: 'Sơ đồ bàn', exact: true }).click();
  await tile(page, 'P1').click();

  // No payment is tried while the clock runs: the server stops it first.
  await panel.getByRole('button', { name: 'Thanh toán', exact: true }).click();
  await expect.poll(() => recorded.stops).toEqual(['postimed_1']);
  await expect(page.locator('#pos-checkout')).toBeVisible();
});
test("a stretch of a running clock is corrected with a manager's approval", async ({ page }) => {
  const world = newWorld({
    capabilities: [...FULL_CASHIER, 'pos.table.serve', 'pos.timed.operate'],
    modules: MODULES,
    profile: { key: 'karaoke_bida', version: 3, display: { surface: 'resource_board' } },
    menu: teaMenu(),
  });
  await installRetailApi(page, world);
  const recorded = await installClocks(page, world);
  await login(page);

  await tile(page, 'P1').click();
  await page.getByRole('complementary', { name: 'P1' }).getByRole('button', { name: 'Bắt đầu tính giờ' }).click();
  await expect.poll(() => recorded.starts.length).toBe(1);

  // The time line shows its running quote and when the server read it.
  await expect(page.getByText(/Tạm tính đến \d\d:\d\d: 75\.000/)).toBeVisible();
  await page.getByRole('button', { name: /^Sửa giờ P1/ }).click();
  const dialog = page.getByRole('dialog', { name: 'Sửa giờ P1' });
  // A running stretch only moves its start.
  await expect(dialog.getByLabel('Giờ ra')).toHaveCount(0);
  await dialog.getByLabel('Giờ vào').fill('2026-11-12T20:45');
  await dialog.getByLabel('Lý do').fill('Bật giờ trễ');
  await dialog.getByLabel('Mã duyệt của quản lý').fill('posapproval_1');
  await dialog.getByRole('button', { name: 'Lưu giờ' }).click();

  await expect(dialog).toHaveCount(0);
  expect(recorded.edits).toHaveLength(1);
  expect(recorded.edits[0]).toEqual(
    expect.objectContaining({ reason: 'Bật giờ trễ', approval_id: 'posapproval_1', started_at: expect.any(String) }),
  );
  expect(Object.keys(recorded.edits[0])).not.toContain('ended_at');
  await expect(page.getByText('đã sửa')).toBeVisible();
});
test('a room sold with a package counts it down, pauses and resumes, and bills the free minutes', async ({ page }) => {
  const world = newWorld({
    capabilities: [...FULL_CASHIER, 'pos.table.serve', 'pos.timed.operate'],
    modules: MODULES,
    profile: { key: 'karaoke_bida', version: 4, display: { surface: 'resource_board' } },
    menu: teaMenu(),
  });
  await installRetailApi(page, world);
  const recorded = await installClocks(page, world);
  await login(page);

  await tile(page, 'P1').click();
  const panel = page.getByRole('complementary', { name: 'P1' });
  await panel.getByLabel('Gói giờ').selectOption('goi2h');
  await panel.getByRole('button', { name: 'Bắt đầu tính giờ' }).click();
  await expect.poll(() => recorded.starts.length).toBe(1);
  expect(recorded.starts[0]).toEqual(expect.objectContaining({ package_code: 'goi2h' }));
  expect(Object.keys(recorded.starts[0])).not.toContain('started_at');

  // The room is flagged by the server as ending soon, and its package counts down.
  await page.getByRole('button', { name: 'Sơ đồ bàn', exact: true }).click();
  await expect(floor(page).getByRole('button', { name: 'Sắp hết giờ 1' })).toBeVisible();
  await expect(tile(page, 'P1')).toHaveAttribute('aria-label', 'P1 · Sắp hết giờ');
  await tile(page, 'P1').click();
  await expect(panel).toContainText('Sắp hết giờ đặt');
  await expect(panel).toContainText(/Gói còn \d\d:\d\d/);

  await panel.getByRole('button', { name: 'Tạm dừng' }).click();
  await expect.poll(() => recorded.pauses).toEqual(['postimed_1']);
  await expect(panel).toContainText('Đang tạm dừng');
  await panel.getByRole('button', { name: 'Tính giờ tiếp' }).click();
  await expect.poll(() => recorded.resumes).toEqual(['postimed_1']);

  // Stopped, the bill shows the package and the free minutes at no charge.
  await panel.getByRole('button', { name: 'Dừng giờ' }).click();
  await expect.poll(() => recorded.stops).toEqual(['postimed_1']);
  await panel.getByRole('button', { name: /^Vào đơn/ }).click();
  await expect(page.locator('.basket-line-band-bonus')).toContainText('Tặng · 15');
  await expect(page.locator('.basket-line-band-bonus')).not.toContainText('₫');
  await expect(page.locator('.basket-line-band-package')).toContainText('250.000');
});