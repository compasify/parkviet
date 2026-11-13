import { expect, type Page, test } from '@playwright/test';
import { teaMenu } from './support/menu-api';
import { addSheet, FULL_CASHIER, installRetailApi, login, newWorld, serialize, type World } from './support/retail-api';

// A karaoke opens on its room board: each room's clock is the largest text,
// counted from the server's start on the server's clock (the page sends no
// time), amber in the last ten minutes of a package and grey while paused.
// Start, pause and resume, order and pay sit on the tile; the room's order
// pins its clock on the ticket; paying while the clock counts always asks
// "Dừng giờ và thanh toán P1?" and stops it first. Presentation fixtures
// only: no real account privileges.

const MODULES = {
  'fnb.menu': true,
  'fnb.kitchen': true,
  resources: true,
  'fnb.tables': true,
  timed_billing: true,
};
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
  // A start (and end) corrected by hand.
  startedAt?: string;
  endedAt?: string;
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
              rate_per_hour: clock.status === 'running' && !clock.packageCode ? '100000.0' : null,
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
        started_at: clock.startedAt ?? '2026-11-12T14:00:00Z', ended_at: clock.status === 'stopped' ? (clock.endedAt ?? SERVER_NOW) : null,
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
function orderView(world: World, workspaceId: string) {
  const sheet = world.sheets.get(workspaceId);
  return sheet ? serialize(world, sheet) : null;
}

async function installClocks(page: Page, world: World): Promise<Recorded> {
  const recorded: Recorded = { starts: [], stops: [], edits: [], pauses: [], resumes: [] };
  const clocks: Clock[] = [];
  // Every answer carrying a room's order carries its time line.
  world.decorate = (view) => {
    const clock = clocks.find((row) => row.workspaceId === view.id);
    if (!clock) return view;
    const line = {
      id: `li_${clock.id}`, sale_line_id: `possl_${clock.id}`, variant_id: 'v_time', product_id: 'p_time', name: 'Giờ hát',
      sku: '', quantity: 1, price: '0.0', unit_price: '0.0', list_price: '0.0', amount: '0.0', discounts: [], kind: 'timed',
      timed_session: session(clock),
    };
    return { ...view, line_items: [...view.line_items, line] };
  };
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
    if (body.ended_at) clock.endedAt = String(body.ended_at);
    return route.fulfill({ json: { data: { workspace: orderView(world, clock.workspaceId), timed_session: session(clock) } } });
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
    return route.fulfill({ status: 201, json: { data: { workspace: orderView(world, sheet.id), timed_session: session(clock) } } });
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
      json: { data: { workspace: orderView(world, clock.workspaceId), timed_session: session(clock) } },
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
        json: { data: { workspace: orderView(world, clock.workspaceId), timed_session: session(clock), warnings: [] } },
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

const rooms = (page: Page) => page.getByRole('region', { name: 'Bảng phòng' });
const room = (page: Page, name: string) => rooms(page).getByRole('article', { name, exact: true });
const ticket = (page: Page) => page.getByRole('complementary', { name: 'Phiếu bàn' });
const stopAndPay = (page: Page) => page.getByRole('dialog', { name: 'Dừng giờ và thanh toán P1?' });

function karaokeWorld(version = 3): World {
  return newWorld({
    capabilities: [...FULL_CASHIER, 'pos.table.serve', 'pos.timed.operate'],
    modules: MODULES,
    profile: { key: 'karaoke_bida', version, display: { surface: 'resource_board' } },
    menu: teaMenu(),
  });
}

// Starts P1's clock from its tile, through the room's panel.
async function startClock(page: Page, recorded: Recorded, packageCode?: string) {
  await room(page, 'P1').getByRole('button', { name: 'Bắt đầu', exact: true }).click();
  const panel = page.getByRole('dialog', { name: 'P1' });
  if (packageCode) await panel.getByLabel('Gói giờ').selectOption(packageCode);
  await panel.getByRole('button', { name: 'Bắt đầu tính giờ' }).click();
  await expect.poll(() => recorded.starts.length).toBe(1);
  await expect(panel).toHaveCount(0);
}

test('the room board starts a clock on the server time and stops it from the room', async ({ page }) => {
  const world = karaokeWorld();
  await installRetailApi(page, world);
  const recorded = await installClocks(page, world);
  await login(page);

  // The rooms are the first screen, each with its tone said in words.
  await expect(rooms(page)).toBeVisible();
  await expect(rooms(page).getByRole('button', { name: 'Phòng', exact: true })).toHaveAttribute('aria-pressed', 'true');
  const p1 = room(page, 'P1');
  await expect(p1).toHaveAttribute('data-tone', 'free');
  await expect(p1.locator('.room-tile-clock')).toHaveText('Trống');
  await expect(p1.getByRole('button', { name: 'Thanh toán', exact: true })).toBeDisabled();

  await startClock(page, recorded);
  // The page names the room and branch only: no start time.
  expect(recorded.starts[0]).toEqual(expect.objectContaining({ branch_id: 'br_1' }));
  expect(typeof recorded.starts[0].editor_id).toBe('string');
  expect(Object.keys(recorded.starts[0])).not.toContain('started_at');

  // The clock counts from the server's start on the server clock: 40 minutes in.
  await expect(p1).toHaveAttribute('data-tone', 'running');
  await expect(p1.locator('.room-tile-clock')).toHaveText(/^4\d:\d\d$/);
  // The tile says the hourly price the clock runs at now.
  await expect(p1.locator('.room-tile-status')).toHaveText('Đang chạy · Đếm lên · 100.000 ₫/giờ');
  await expect(p1.locator('.room-tile-money')).toContainText('75.000');
  await expect(p1.getByRole('button', { name: 'Tạm dừng', exact: true })).toBeVisible();

  // Stopping without paying stays in the room's panel.
  await p1.getByRole('button', { name: /^P1 · Đang chạy/ }).click();
  const panel = page.getByRole('dialog', { name: 'P1' });
  await expect(panel).toContainText('75.000');
  await panel.getByRole('button', { name: 'Dừng giờ' }).click();
  await expect.poll(() => recorded.stops).toEqual(['postimed_1']);
  await expect(panel).toContainText('100.000');
  await expect(panel).toContainText('Đã dừng lúc');
  await page.keyboard.press('Escape');
  await expect(p1).toHaveAttribute('data-tone', 'idle');
  await expect(p1.locator('.room-tile-status')).toContainText('Đã dừng lúc');
  await expect(p1.locator('.room-tile-status')).not.toContainText('/giờ');
  // Stopped and waiting for its payment: no new clock on top of it, only pay.
  await expect(p1.getByRole('button', { name: 'Bắt đầu', exact: true })).toHaveCount(0);
  await expect(p1.getByRole('button', { name: 'Thanh toán', exact: true })).toBeEnabled();
});

test('a room orders, sends to the kitchen and pays only once its clock is stopped', async ({ page }) => {
  const world = karaokeWorld();
  await installRetailApi(page, world);
  const recorded = await installClocks(page, world);
  await login(page);
  await startClock(page, recorded);

  // "Gọi món" opens the room's order with its clock pinned on the ticket.
  await room(page, 'P1').getByRole('button', { name: 'Gọi món', exact: true }).click();
  await expect(page).toHaveURL(/view=order/);
  const clock = ticket(page).getByRole('region', { name: 'Giờ chơi' });
  await expect(clock.locator('.timed-clock')).toHaveText(/^4\d:\d\d$/);
  await expect(clock).toContainText('Đang chạy');
  await expect(clock).toContainText('75.000');
  await expect(ticket(page).getByRole('button', { name: 'Về bảng bàn' })).toContainText('Phòng');
  await page.getByRole('list', { name: 'Thực đơn' }).getByRole('button', { name: 'Bánh flan', exact: true }).click();
  await expect(ticket(page).locator('.ticket-line')).toHaveCount(1);
  // The total says it holds the time so far, as an estimate.
  await expect(ticket(page).getByRole('button', { name: /^Thanh toán · tạm tính/ })).toContainText('90.000');
  await ticket(page).getByRole('button', { name: 'Gửi bếp (1)', exact: true }).click();
  await expect(page).toHaveURL(/view=board/);
  const sheetId = [...world.sheets.keys()].at(-1) ?? '';
  await expect.poll(() => world.sheets.get(sheetId)?.kitchenSends?.length).toBe(1);

  // Paying from the tile asks first; "Huỷ" leaves the clock counting.
  await room(page, 'P1').getByRole('button', { name: 'Thanh toán', exact: true }).click();
  await expect(stopAndPay(page)).toContainText('75.000');
  await stopAndPay(page).getByRole('button', { name: 'Huỷ' }).click();
  await expect(stopAndPay(page)).toHaveCount(0);
  expect(recorded.stops).toEqual([]);
  await expect(page).toHaveURL(/view=board/);

  // From the ticket the same question; yes stops the clock once, then pays.
  await room(page, 'P1').getByRole('button', { name: 'Gọi món', exact: true }).click();
  await ticket(page).getByRole('button', { name: /^Thanh toán/ }).click();
  await expect(stopAndPay(page)).toContainText('75.000');
  await stopAndPay(page).getByRole('button', { name: 'Dừng giờ và thanh toán' }).dblclick();
  await expect(page).toHaveURL(/view=pay/);
  expect(recorded.stops).toEqual(['postimed_1']);
  const pay = page.locator('.pay-screen');
  await expect(pay).toBeVisible();

  // Paid in cash, the room board comes back.
  await pay.getByRole('region', { name: 'Tiền mặt' }).getByRole('button', { name: 'Đúng 15.000' }).click();
  await pay.getByRole('button', { name: 'Hoàn tất · in hóa đơn' }).click();
  await expect.poll(() => world.sheets.get(sheetId)?.status).toBe('completed');
  await expect(page).toHaveURL(/view=board/);
  await expect(rooms(page)).toBeVisible();
});

test('a payment frame reached while the clock counts goes back and asks to stop it', async ({ page }) => {
  const world = karaokeWorld();
  await installRetailApi(page, world);
  const recorded = await installClocks(page, world);
  await login(page);
  await startClock(page, recorded);
  await room(page, 'P1').getByRole('button', { name: 'Gọi món', exact: true }).click();
  await expect(page).toHaveURL(/view=order/);

  // A link or history entry straight to the payment never shows it.
  const url = new URL(page.url());
  url.searchParams.set('view', 'pay');
  await page.goto(url.toString());
  await expect(stopAndPay(page)).toBeVisible();
  await expect(page).toHaveURL(/view=order/);
  await expect(page.locator('.pay-screen')).toHaveCount(0);
  expect(recorded.stops).toEqual([]);
});

test("a stretch of a running clock is corrected with a manager's approval", async ({ page }) => {
  const world = karaokeWorld();
  await installRetailApi(page, world);
  const recorded = await installClocks(page, world);
  await login(page);
  await startClock(page, recorded);
  await room(page, 'P1').getByRole('button', { name: 'Gọi món', exact: true }).click();

  // The pinned clock corrects its running stretch.
  await ticket(page).getByRole('button', { name: /^Sửa giờ P1/ }).click();
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
});

test('a room sold with a package counts down in amber, pauses grey and bills the free minutes', async ({ page }) => {
  const world = karaokeWorld(4);
  await installRetailApi(page, world);
  const recorded = await installClocks(page, world);
  await login(page);
  await startClock(page, recorded, 'goi2h');
  expect(recorded.starts[0]).toEqual(expect.objectContaining({ package_code: 'goi2h' }));
  expect(Object.keys(recorded.starts[0])).not.toContain('started_at');

  // Eight minutes to the package's end: amber, counting down, and in "Cần xử lý".
  const p1 = room(page, 'P1');
  await expect(p1).toHaveAttribute('data-tone', 'ending');
  await expect(p1.locator('.room-tile-clock')).toHaveText(/^0[78]:\d\d$/);
  await expect(p1.locator('.room-tile-status')).toHaveText('Sắp hết giờ · Gói giờ · còn lại');
  await expect(rooms(page).getByRole('button', { name: 'Cần xử lý 1' })).toBeVisible();

  // Pause and resume take one tap on the tile.
  await p1.getByRole('button', { name: 'Tạm dừng', exact: true }).click();
  await expect.poll(() => recorded.pauses).toEqual(['postimed_1']);
  await expect(p1).toHaveAttribute('data-tone', 'paused');
  await expect(p1.locator('.room-tile-status')).toContainText('Tạm dừng');
  await p1.getByRole('button', { name: 'Tiếp tục', exact: true }).click();
  await expect.poll(() => recorded.resumes).toEqual(['postimed_1']);
  await expect(p1).toHaveAttribute('data-tone', 'ending');

  // Stopped, the room's ticket shows the package and the free minutes at no charge.
  await p1.getByRole('button', { name: /^P1 · Sắp hết giờ/ }).click();
  await page.getByRole('dialog', { name: 'P1' }).getByRole('button', { name: 'Dừng giờ' }).click();
  await expect.poll(() => recorded.stops).toEqual(['postimed_1']);
  await page.keyboard.press('Escape');
  await p1.getByRole('button', { name: 'Gọi món', exact: true }).click();
  const clock = ticket(page).getByRole('region', { name: 'Giờ chơi' });
  await expect(clock.locator('.timed-band-bonus')).toContainText('Tặng · 15');
  await expect(clock.locator('.timed-band-bonus')).not.toContainText('₫');
  // The package and its price once, by its name.
  await expect(clock.locator('.timed-band-package')).toHaveCount(1);
  await expect(clock.locator('.timed-band-package')).toContainText('Gói 2 giờ');
  await expect(clock.locator('.timed-band-package')).toContainText('250.000');
  await expect(clock).not.toContainText('Gói giờ · Gói 2 giờ · 250.000');
});

test('a stopped stretch is still corrected after stop and pay, until the order is paid', async ({ page }) => {
  const world = karaokeWorld();
  await installRetailApi(page, world);
  const recorded = await installClocks(page, world);
  await login(page);
  await startClock(page, recorded);

  // Stop and pay from the tile, then back from the payment to the order.
  await room(page, 'P1').getByRole('button', { name: 'Thanh toán', exact: true }).click();
  await stopAndPay(page).getByRole('button', { name: 'Dừng giờ và thanh toán' }).click();
  await expect(page).toHaveURL(/view=pay/);
  expect(recorded.stops).toEqual(['postimed_1']);
  await page.getByRole('button', { name: 'Về đơn để gọi thêm món' }).click();
  await expect(page).toHaveURL(/view=order/);

  // The stopped stretch shows on the pinned clock and corrects its start.
  const clock = ticket(page).getByRole('region', { name: 'Giờ chơi' });
  await expect(clock).toContainText('Đã dừng lúc');
  await clock.getByRole('button', { name: /^Sửa giờ P1/ }).click();
  const dialog = page.getByRole('dialog', { name: 'Sửa giờ P1' });
  await expect(dialog.getByLabel('Giờ ra')).toBeVisible();
  await dialog.getByLabel('Giờ vào').fill('2026-11-12T20:45');
  await dialog.getByLabel('Lý do').fill('Bật giờ trễ');
  await dialog.getByLabel('Mã duyệt của quản lý').fill('posapproval_1');
  await dialog.getByRole('button', { name: 'Lưu giờ' }).click();

  await expect(dialog).toHaveCount(0);
  expect(recorded.edits).toHaveLength(1);
  expect(recorded.edits[0]).toEqual(
    expect.objectContaining({ reason: 'Bật giờ trễ', approval_id: 'posapproval_1', started_at: expect.any(String) }),
  );
  await expect(clock).toContainText('đã sửa');
});
