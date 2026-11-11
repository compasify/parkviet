import { type BrowserContext, expect, type Page, test, type WebSocketRoute } from '@playwright/test';
import { liveExpect, liveLogin, liveNewDraft, requireLive } from './support/live';
import { addSheet, installRetailApi, login, newWorld, openTab, scan, tab } from './support/retail-api';

const BARCODE = '8930000000011';
const NAME = 'Gạo ST25';

// Answers the Action Cable protocol for the mocked suite. Playwright's mocked
// socket reports no subprotocol, which the client would refuse.
function cableHub() {
  const sockets = new Map<WebSocketRoute, string | null>();
  return {
    async install(context: BrowserContext) {
      await context.routeWebSocket(/\/cable/, (socket) => {
        sockets.set(socket, null);
        socket.send(JSON.stringify({ type: 'welcome' }));
        socket.onMessage((raw) => {
          const data = JSON.parse(String(raw)) as { command: string; identifier: string };
          if (data.command !== 'subscribe') return;
          sockets.set(socket, data.identifier);
          socket.send(JSON.stringify({ identifier: data.identifier, type: 'confirm_subscription' }));
        });
        socket.onClose(() => sockets.delete(socket));
      });
      await context.addInitScript(() => {
        window.WebSocket = new Proxy(window.WebSocket, {
          construct(target, args, newTarget) {
            const socket = Reflect.construct(target, args, newTarget) as WebSocket;
            Object.defineProperty(socket, 'protocol', { value: 'actioncable-v1-json' });
            return socket;
          },
        });
      });
    },
    publish(id: string, revision: number) {
      const message = { event: 'workspace.updated', id, branch_id: 'br_1', revision, at: new Date().toISOString(), refs: {} };
      for (const [socket, identifier] of sockets) {
        if (identifier) socket.send(JSON.stringify({ identifier, message }));
      }
    },
    async dropAll() {
      await Promise.all([...sockets.keys()].map((socket) => socket.close()));
    },
  };
}

const live = (page: Page) => expect(page.locator('.realtime-status[data-status="connected"]')).toBeVisible({ timeout: 10_000 });

test('a line added in one tab shows in another tab of the branch within two seconds', async ({ browser }) => {
  const world = newWorld();
  const sheet = addSheet(world, 'ws_1');
  const hub = cableHub();
  const first = await browser.newContext();
  const second = await browser.newContext();
  try {
    for (const context of [first, second]) {
      await installRetailApi(context, world);
      await hub.install(context);
    }
    const a = await first.newPage();
    const b = await second.newPage();
    await login(a);
    await login(b);
    await openTab(a, 'ws_1');
    await tab(b, 'ws_1').click();
    await Promise.all([live(a), live(b)]);
    await expect(b.locator('.basket-panel')).not.toContainText(NAME);

    await scan(a, BARCODE);
    await expect.poll(() => sheet.lines.length).toBe(1);
    await expect(a.locator('.basket-panel')).toContainText(NAME);
    hub.publish('ws_1', sheet.revision);

    await expect(b.locator('.basket-panel')).toContainText(NAME, { timeout: 2_000 });
  } finally {
    await first.close();
    await second.close();
  }
});

test('a reconnect refetches what changed while the socket was down', async ({ browser }) => {
  const world = newWorld();
  const sheet = addSheet(world, 'ws_1');
  const hub = cableHub();
  const first = await browser.newContext();
  const second = await browser.newContext();
  try {
    for (const context of [first, second]) {
      await installRetailApi(context, world);
      await hub.install(context);
    }
    const a = await first.newPage();
    const b = await second.newPage();
    await login(a);
    await login(b);
    await openTab(a, 'ws_1');
    await tab(b, 'ws_1').click();
    await Promise.all([live(a), live(b)]);

    await hub.dropAll();
    await expect(b.locator('.realtime-status[data-status="connected"]')).toHaveCount(0);
    await scan(a, BARCODE);
    await expect.poll(() => sheet.lines.length).toBe(1);

    await live(b);
    await expect(b.locator('.basket-panel')).toContainText(NAME, { timeout: 2_000 });
  } finally {
    await first.close();
    await second.close();
  }
});

test('real API: a line added in one tab shows in another tab within two seconds', async ({ browser }) => {
  test.setTimeout(180_000);
  const fixture = requireLive();
  const rice = fixture.products.rice;
  const first = await browser.newContext();
  const second = await browser.newContext();
  try {
    const a = await first.newPage();
    const b = await second.newPage();
    await liveLogin(a, fixture);
    const listed = b.waitForResponse((response) => /\/pos\/workspaces\?/.test(response.url()) && response.ok(), { timeout: 60_000 });
    await liveLogin(b, fixture);
    // The two-second promise starts once a socket is up and the other tab has
    // its list, so only an event can bring the new draft in. Getting there on
    // the development API takes longer, and a code reload drops every socket.
    const liveConnected = (page: Page) =>
      liveExpect(page.locator('.realtime-status[data-status="connected"]')).toBeVisible({ timeout: 45_000 });
    await listed;
    await liveExpect(b.getByText('Đang tải danh sách đơn nháp…')).toHaveCount(0);
    await Promise.all([liveConnected(a), liveConnected(b)]);
    const draft = await liveNewDraft(a);

    const draftTab = tab(b, draft.id);
    await liveExpect(draftTab).toBeVisible();
    // Opening a draft takes its edit lease; focusing the first window takes it
    // back, and the other one stays on the draft as a viewer.
    const leaseClaim = (page: Page) =>
      page.waitForResponse((response) => response.url().endsWith(`/pos/workspaces/${draft.id}/lease`) && response.request().method() === 'POST' && response.ok(), { timeout: 45_000 });
    const openedByB = leaseClaim(b);
    await draftTab.click();
    await openedByB;
    await liveExpect(a.getByRole('button', { name: 'Tạm giữ' })).toBeDisabled({ timeout: 30_000 });
    const reclaimedByA = leaseClaim(a);
    await a.evaluate(() => window.dispatchEvent(new Event('focus')));
    await reclaimedByA;
    await liveExpect(a.getByRole('button', { name: 'Tạm giữ' })).toBeEnabled({ timeout: 30_000 });
    await liveExpect(b.locator('.basket-panel')).not.toContainText(rice.name);

    await scan(a, rice.barcode);
    await liveExpect(a.locator('.basket-panel')).toContainText(rice.name, { timeout: 45_000 });

    await expect(b.locator('.basket-panel')).toContainText(rice.name, { timeout: 2_000 });
  } finally {
    await first.close();
    await second.close();
  }
});
