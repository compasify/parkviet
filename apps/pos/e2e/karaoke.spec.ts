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

type Clock = { id: string; resourceId: string; workspaceId: string; status: 'running' | 'stopped'; amount: string };
type Recorded = { starts: Array<Record<string, unknown>>; stops: string[] };

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
        state: clock?.status === 'running' ? 'playing' : orders.length ? 'occupied' : 'available',
        guest_count: null, seated_minutes: orders.length ? 40 : null,
        subtotal: orders.length ? '0.0' : null, currency: orders.length ? 'VND' : null,
        payment_requested: false, edited_after_prebill: false,
        next_reservation: null, buffet_ends_at: null,
        timed: clock
          ? {
              id: clock.id, workspace_id: clock.workspaceId, status: clock.status,
              started_at: '2026-11-12T14:00:00Z',
              stopped_at: clock.status === 'stopped' ? SERVER_NOW : null,
              planned_end_at: null, played_minutes: 40, quote_amount: clock.amount, ending_soon: false,
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
    played_minutes: 40, billed_minutes: 45, amount: clock.amount, currency: 'VND', segments: [],
    quote: { final: clock.status === 'stopped', played_minutes: 40, billed_minutes: 45, amount: clock.amount, lines: [] },
  };
}

async function installClocks(page: Page, world: World): Promise<Recorded> {
  const recorded: Recorded = { starts: [], stops: [] };
  const clocks: Clock[] = [];
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
    const clock: Clock = { id: `postimed_${clocks.length + 1}`, resourceId, workspaceId: sheet.id, status: 'running', amount: '75000.0' };
    clocks.push(clock);
    return route.fulfill({ status: 201, json: { data: { workspace: serialize(world, sheet), timed_session: session(clock) } } });
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
    return route.fulfill({ json: { data: { timed_session: session(clock) } } });
  });
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
