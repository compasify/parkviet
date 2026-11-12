import { expect, type Page, type Route, test } from '@playwright/test';
import { goToMenuPage } from './support/menu';
import {
  addLine,
  addSheet,
  completeAndHandOver,
  FULL_CASHIER,
  installRetailApi,
  login,
  newWorld,
  openTab,
  payCash,
  type Sheet,
  serialize,
  sheetTotal,
  type World,
} from './support/retail-api';

// A rest stop: a coach pulls in and the cashier records it from the bar on
// the sales screen, puts three orders on it and takes them in cash at full
// price. When the coach leaves the visit is closed with its commission, and
// paying the driver in cash asks for a cash out; once a second person
// confirms it the drawer's expected cash is lower by the commission. The rule,
// the snapshot and paying once are decided on the server.
// Presentation fixtures only: no real account privileges.

const SHEETS = ['ws_coach_1', 'ws_coach_2', 'ws_coach_3'];
const PER_COACH = 100000;
const PER_GUEST = 5000;

type Visit = Record<string, unknown> & { id: string; status: string; guest_count: number };

function stopWorld(): { world: World; sheets: Sheet[] } {
  const world = newWorld({
    capabilities: [...FULL_CASHIER, 'pos.vehicle_visit.operate', 'pos.vehicle_visit.manage'],
    modules: { 'fnb.vehicle_commission': true },
  });
  // Twenty bottles of water each: 100.000 ₫ an order.
  const sheets = SHEETS.map((id) => {
    const sheet = addSheet(world, id);
    addLine(world, sheet, 'v_water', 20);
    return sheet;
  });
  return { world, sheets };
}

// The coach visit endpoints, in front of the retail server.
async function installVisitApi(page: Page, world: World) {
  const visits: Visit[] = [];
  const pays: Record<string, unknown>[] = [];
  const reply = (route: Route, value: unknown, code = 200) =>
    route.fulfill({ status: code, json: { data: value } });
  const payoutStatus = (visit: Visit) => {
    if (visit.status !== 'paid') return null;
    const request = world.cashRequests.find((row) => row.id === visit.cash_movement_request_id);
    return request?.status === 'confirmed' ? 'paid' : (request?.status ?? null);
  };
  const view = (visit: Visit) => ({ ...visit, payout_status: payoutStatus(visit), warnings: [] });
  await page.route('**/api/v3/admin/**', async (route) => {
    const request = route.request();
    const url = new URL(request.url());
    const path = url.pathname.replace(/^.*\/api\/v3\/admin/, '');
    const body = (request.method() === 'GET' ? {} : (request.postDataJSON() ?? {})) as Record<string, unknown>;
    if (path === '/pos/vehicle_visits' && request.method() === 'GET') {
      const statuses = (url.searchParams.get('status') ?? '').split(',').filter(Boolean);
      return reply(route, visits.filter((visit) => statuses.length === 0 || statuses.includes(visit.status)).map(view));
    }
    if (path === '/pos/vehicle_visits') {
      const visit: Visit = {
        id: `posvisit_${visits.length + 1}`, branch_id: 'br_1', bus_operator: null,
        plate: String(body.plate).toUpperCase().replace(/[^A-Z0-9]/g, ''), vehicle_type: body.vehicle_type,
        driver_name: null, driver_phone: null, guest_count: Number(body.guest_count ?? 0),
        arrived_at: new Date().toISOString(), closes_at: new Date(Date.now() + 3_600_000).toISOString(),
        closed_at: null, auto_closed: false, status: 'open', business_date: '2026-11-12',
        revenue_amount: null, commission_amount: null, currency: 'VND', commission: null,
        payout_method: null, cash_movement_request_id: null, transfer_reference: null,
        void_reason: null, revision: 1, workspaces_count: 0,
      };
      visits.push(visit);
      return reply(route, view(visit), 201);
    }
    const attach = /^\/pos\/workspaces\/([\w-]+)\/vehicle_visit$/.exec(path);
    if (attach) {
      const sheet = world.sheets.get(attach[1]);
      if (!sheet) return route.fallback();
      if (sheet.status === 'completed')
        return route.fulfill({
          status: 409,
          json: { error: { code: 'conflict', message: 'Completed.', details: { reason: 'workspace_completed' } } },
        });
      sheet.vehicleVisitId = (body.visit_id as string | null) ?? null;
      sheet.revision += 1;
      return reply(route, serialize(world, sheet));
    }
    const command = /^\/pos\/vehicle_visits\/(posvisit_\d+)\/(close|pay)$/.exec(path);
    if (command) {
      const visit = visits.find((row) => row.id === command[1]);
      if (!visit) return route.fallback();
      if (command[2] === 'close') {
        const sheets = [...world.sheets.values()].filter(
          (sheet) => sheet.vehicleVisitId === visit.id && sheet.status === 'completed',
        );
        const revenue = sheets.reduce((sum, sheet) => sum + sheetTotal(world, sheet), 0);
        const amount = PER_COACH + PER_GUEST * visit.guest_count;
        Object.assign(visit, {
          status: 'closed', closed_at: new Date().toISOString(), revenue_amount: `${revenue}.0`,
          commission_amount: `${amount}.0`, workspaces_count: sheets.length, revision: visit.revision + 1,
          commission: {
            rule: { id: 'poscommrule_1', name: 'Hoa hồng chung' }, guest_count: visit.guest_count,
            revenue: `${revenue}.0`, vehicle_type: visit.vehicle_type, vehicle_amount: `${PER_COACH}.0`,
            guest_amount: `${PER_GUEST * visit.guest_count}.0`, amount: `${amount}.0`, qualified: true, reason: null,
          },
        });
        return reply(route, view(visit));
      }
      pays.push(body);
      if (visit.status !== 'closed')
        return route.fulfill({
          status: 409,
          json: { error: { code: 'conflict', message: 'Paid.', details: { reason: 'vehicle_visit_paid' } } },
        });
      const cashOut = {
        id: `poscashreq_${world.cashRequests.length + 1}`, shift_id: 'sh_1', kind: 'cash_out',
        amount: String(Number.parseInt(String(visit.commission_amount), 10)),
        reason: `Hoa hồng xe ${visit.plate}`, evidence_reference: visit.id, status: 'requested',
      };
      world.cashRequests.push(cashOut);
      Object.assign(visit, {
        status: 'paid', payout_method: 'cash', cash_movement_request_id: cashOut.id, revision: visit.revision + 1,
      });
      return reply(route, view(visit));
    }
    return route.fallback();
  });
  return { visits, pays };
}

// A second person confirms the cash out from the POS dashboard: the drawer
// gives the money.
function confirmCashOut(world: World, id: string) {
  const row = world.cashRequests.find((item) => item.id === id);
  if (!row) throw new Error(`no cash request ${id}`);
  row.status = 'confirmed';
  world.drawer -= Number.parseInt(String(row.amount), 10);
}

const expectedCash = (world: World) => world.shift.openingFloat + world.drawer;

test('a new coach takes three orders at full price, closes with its commission and is paid once in cash', async ({ page }) => {
  const { world, sheets } = stopWorld();
  await installRetailApi(page, world);
  const api = await installVisitApi(page, world);
  await login(page);
  await openTab(page, SHEETS[0]);

  const bar = page.getByRole('region', { name: 'Xe đang ở trạm' });
  await expect(bar).toContainText('Chưa có xe nào ở trạm.');
  await bar.getByRole('button', { name: 'Xe mới' }).click();
  await bar.getByLabel('Biển số').fill('51b-123.45');
  await bar.getByLabel('Số khách').fill('20');
  await bar.getByRole('button', { name: 'Ghi nhận xe' }).click();
  await expect(bar.getByRole('status')).toHaveText('Đã ghi nhận xe 51B12345.');
  const coach = bar.getByRole('button', { name: /51B12345/ });
  await expect(coach).toContainText('20 khách');

  for (const id of SHEETS) {
    await openTab(page, id);
    await coach.click();
    await expect(coach).toHaveAttribute('aria-pressed', 'true');
    await payCash(page, '100.000');
    await completeAndHandOver(page);
  }
  // Each order was taken at its full price: the commission is not a discount.
  for (const sheet of sheets) {
    expect(sheet).toMatchObject({ status: 'completed', vehicleVisitId: 'posvisit_1' });
    expect(sheetTotal(world, sheet)).toBe(100000);
  }
  const afterSales = expectedCash(world);
  expect(afterSales).toBe(300000);

  await goToMenuPage(page, 'Lượt xe');
  await page.getByRole('button', { name: '51B12345' }).click();
  const detail = page.getByRole('region', { name: 'Lượt xe 51B12345' });
  await detail.getByRole('button', { name: 'Xe đã đi — chốt' }).click();
  await expect(detail).toContainText('Hoa hồng chung');
  await expect(detail).toContainText('300.000');
  await expect(detail).toContainText('200.000');

  await detail.getByRole('button', { name: /Chi 200\.000/ }).click();
  await expect(page.getByRole('status').filter({ hasText: 'Đã tạo phiếu chi tiền mặt' })).toBeVisible();
  expect(api.pays).toHaveLength(1);
  expect(api.pays[0]).toMatchObject({ payout_method: 'cash' });
  expect(api.pays[0]).toHaveProperty('idempotency_key');
  expect(world.cashRequests).toEqual([
    expect.objectContaining({ kind: 'cash_out', amount: '200000', reason: 'Hoa hồng xe 51B12345', status: 'requested' }),
  ]);
  // Waiting for the second person, the drawer has not given anything yet.
  expect(expectedCash(world)).toBe(afterSales);
  await expect(detail.getByRole('button', { name: /Chi 200\.000/ })).toHaveCount(0);

  confirmCashOut(world, String(world.cashRequests[0].id));
  expect(expectedCash(world)).toBe(afterSales - 200000);

  await page.getByLabel('Trạng thái').selectOption('paid');
  await expect(page.getByRole('row', { name: /51B12345/ })).toContainText('Đã chi');
  expect(world.cashRequests).toHaveLength(1);
});
