import { expect, type Page, type Route, test } from '@playwright/test';
import { goToMenuPage } from './support/menu';
import { teaMenu } from './support/menu-api';
import { FULL_CASHIER, installRetailApi, login, newWorld, serialize, sheetTotal, type World } from './support/retail-api';

// A rest stop sells at the quick counter. A coach pulls in and the cashier
// records it from the strip above the menu, puts three orders on it and takes
// them in cash (F1) at full price, each order on the ticket in turn. When the
// coach leaves the visit is closed from the strip with its commission, and
// paying the driver in cash asks for a cash out; once a second person
// confirms it the drawer's expected cash is lower by the commission. The rule,
// the snapshot and paying once are decided on the server.
// Presentation fixtures only: no real account privileges.

const ORDERS = 3;
const PER_COACH = 100000;
const PER_GUEST = 5000;

type Visit = Record<string, unknown> & { id: string; status: string; guest_count: number };

function stopWorld(capabilities = [...FULL_CASHIER, 'pos.vehicle_visit.operate', 'pos.vehicle_visit.manage']): World {
  return newWorld({
    capabilities,
    modules: { 'retail.units': true, 'fnb.menu': true, 'fnb.vehicle_commission': true },
    profile: { key: 'cang_tin_tram_dung', version: 1, display: { surface: 'menu_grid' } },
    menu: teaMenu(),
  });
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
  const attached = (visit: Visit) =>
    [...world.sheets.values()].filter((sheet) => sheet.vehicleVisitId === visit.id).length;
  const view = (visit: Visit) => ({
    ...visit,
    ...(visit.status === 'open' ? { workspaces_count: attached(visit) } : {}),
    payout_status: payoutStatus(visit),
    warnings: [],
  });
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

const ticket = (page: Page) => page.getByRole('complementary', { name: 'Phiếu quầy' });
const flan = (page: Page) => page.getByRole('list', { name: 'Thực đơn' }).getByRole('button', { name: 'Bánh flan', exact: true });

test('a new coach takes three orders at full price, closes from the strip with its commission and is paid once in cash', async ({ page }) => {
  const world = stopWorld();
  await installRetailApi(page, world);
  const api = await installVisitApi(page, world);
  await login(page);
  await expect(ticket(page)).toBeVisible();
  await expect(page.getByRole('tablist')).toHaveCount(0);

  const strip = page.getByRole('region', { name: 'Xe đang ở trạm' });
  await expect(strip).toContainText('Chưa có xe nào ở trạm.');
  await strip.getByRole('button', { name: '+ Lượt xe' }).click();
  await strip.getByLabel('Biển số').fill('51b-123.45');
  await strip.getByLabel('Số khách').fill('20');
  await strip.getByRole('button', { name: 'Ghi nhận xe' }).click();
  await expect(strip.getByRole('status')).toHaveText('Đã ghi nhận xe 51B12345.');
  const coach = strip.getByRole('button', { name: /^51B12345/ });
  await expect(coach).toContainText('20 khách');
  await expect(coach).toContainText('0 đơn');

  // Each guest's order goes on the coach, then F1 takes it in cash and the
  // next ticket is on the counter, not on the coach yet.
  const orders = [];
  for (let index = 0; index < ORDERS; index += 1) {
    await expect.poll(() => world.sheets.size).toBe(index + 1);
    const order = [...world.sheets.values()][index];
    orders.push(order);
    await expect(coach).toHaveAttribute('aria-pressed', 'false');
    await flan(page).click();
    await flan(page).click();
    await expect(ticket(page).getByTestId('quick-total')).toHaveText('30.000 ₫');
    await coach.click();
    await expect(coach).toHaveAttribute('aria-pressed', 'true');
    await expect(coach).toContainText(`${index + 1} đơn`);
    await page.keyboard.press('F1');
    await expect.poll(() => order.status).toBe('completed');
    await expect(ticket(page).getByTestId('quick-done')).toBeVisible();
  }
  // Each order was taken at its full price: the commission is not a discount.
  for (const order of orders) {
    expect(order).toMatchObject({ status: 'completed', vehicleVisitId: 'posvisit_1' });
    expect(sheetTotal(world, order)).toBe(30000);
  }
  const afterSales = expectedCash(world);
  expect(afterSales).toBe(90000);

  // A guest still ordering is on the coach: closing warns that the order
  // would not count, and the cashier keeps the visit open.
  await expect.poll(() => world.sheets.size).toBe(ORDERS + 1);
  await flan(page).click();
  await coach.click();
  await expect(coach).toHaveAttribute('aria-pressed', 'true');
  await strip.getByRole('button', { name: 'Chốt lượt xe 51B12345' }).click();
  await expect(strip.getByRole('alert')).toHaveText('Còn 1 đơn chưa thanh toán sẽ không tính hoa hồng.');
  await strip.getByRole('button', { name: 'Thôi' }).click();
  await coach.click();
  await expect(coach).toHaveAttribute('aria-pressed', 'false');

  // The coach leaves: closing asks once more, then the coach leaves the strip.
  await strip.getByRole('button', { name: 'Chốt lượt xe 51B12345' }).click();
  await expect(strip.getByRole('alert')).toHaveCount(0);
  await strip.getByRole('button', { name: 'Xe 51B12345 đã đi — chốt' }).click();
  await expect(strip.getByRole('status')).toHaveText('Đã chốt lượt xe 51B12345.');
  await expect(coach).toHaveCount(0);
  await expect(strip).toContainText('Chưa có xe nào ở trạm.');

  await goToMenuPage(page, 'Lượt xe');
  await page.getByRole('button', { name: '51B12345' }).click();
  const detail = page.getByRole('region', { name: 'Lượt xe 51B12345' });
  await expect(detail).toContainText('Hoa hồng chung');
  await expect(detail).toContainText('90.000');
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

test('a cashier without rights over coach visits puts orders on a coach but neither records nor closes one', async ({ page }) => {
  const world = stopWorld(FULL_CASHIER);
  await installRetailApi(page, world);
  const api = await installVisitApi(page, world);
  api.visits.push({
    id: 'posvisit_1', branch_id: 'br_1', bus_operator: null, plate: '51B12345', vehicle_type: 'seat_29',
    driver_name: null, driver_phone: null, guest_count: 20, arrived_at: new Date().toISOString(),
    closes_at: new Date(Date.now() + 3_600_000).toISOString(), closed_at: null, auto_closed: false, status: 'open',
    business_date: '2026-11-12', revenue_amount: null, commission_amount: null, currency: 'VND', commission: null,
    payout_method: null, cash_movement_request_id: null, transfer_reference: null, void_reason: null, revision: 1,
    workspaces_count: 0,
  });
  await login(page);
  await expect(ticket(page)).toBeVisible();

  const strip = page.getByRole('region', { name: 'Xe đang ở trạm' });
  const coach = strip.getByRole('button', { name: /^51B12345/ });
  await expect(coach).toBeVisible();
  await expect(strip.getByRole('button', { name: '+ Lượt xe' })).toHaveCount(0);
  await expect(strip.getByRole('button', { name: 'Chốt lượt xe 51B12345' })).toHaveCount(0);
  await flan(page).click();
  await coach.click();
  await expect(coach).toHaveAttribute('aria-pressed', 'true');
});
