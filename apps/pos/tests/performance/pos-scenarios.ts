import { mkdirSync, writeFileSync } from 'node:fs';
import { dirname } from 'node:path';
import { expect, type Page, test } from '@playwright/test';
import {
  liveEnableFeatures,
  liveLogin,
  liveNewDraft,
  requireLive,
  restoreLiveFeatures,
} from '../../e2e/support/live';
import {
  addLine,
  addSheet,
  completeAndHandOver,
  installRetailApi,
  login,
  newWorld,
  openTab,
  scan,
} from '../../e2e/support/retail-api';

// UI timing harness for four cashier interactions, measured inside the page
// with the browser's Performance API (performance.mark/measure) from the
// action to the moment the result is on screen. It records numbers; it does
// not claim capacity. With the mocked API it measures the client only; with
// POS_PERF_LIVE=1 (and the live fixture of the e2e runs) it includes the
// development server. Targets are the plan's proposals for LAN staging.
//
//   pnpm test:perf                      mocked API, 20 samples per scenario
//   POS_PERF_LIVE=1 POS_LIVE_REVIEW=1 POS_LIVE_FIXTURE=… pnpm test:perf
//
// Output: POS_PERF_OUT or test-results/perf/pos-scenarios.json

type Step =
  | { click: string }
  | { clickText: string }
  | { fill: string; value: string };
type Done = { selector: string; text?: string } | { absent: string } | { count: string; atLeast: number };

const TARGETS_MS: Record<string, { p95: number; note: string }> = {
  tab_switch: { p95: 100, note: 'UI tab < 100 ms' },
  catalog_search: { p95: 500, note: 'search p95 < 500 ms' },
  draft_create: { p95: 700, note: 'draft p95 < 700 ms' },
  cash_confirmation: { p95: 2000, note: 'local confirmation p95 < 2 s' },
};

const samples = Number(process.env.POS_PERF_SAMPLES ?? (process.env.POS_PERF_LIVE === '1' ? 5 : 20));
const results: Record<string, number[]> = {};

// Runs the steps and waits for the result in one page task, so Playwright's
// own round trips are not in the number.
async function measure(page: Page, name: string, steps: Step[], done: Done) {
  const duration = await page.evaluate(
    async ({ name, steps, done }) => {
      const byText = (text: string) =>
        [...document.querySelectorAll<HTMLElement>('button, a, [role="tab"]')].find(
          (element) => element.textContent?.trim() === text && !(element as HTMLButtonElement).disabled,
        );
      const ready = () => {
        if ('absent' in done) return !document.querySelector(done.absent);
        if ('count' in done) return document.querySelectorAll(done.count).length >= done.atLeast;
        const element = document.querySelector(done.selector);
        return Boolean(element && (!done.text || element.textContent?.includes(done.text)));
      };
      const start = `${name}:start:${performance.now()}`;
      performance.mark(start);
      for (const step of steps) {
        if ('click' in step) (document.querySelector(step.click) as HTMLElement | null)?.click();
        else if ('clickText' in step) byText(step.clickText)?.click();
        else {
          const input = document.querySelector(step.fill) as HTMLInputElement;
          const setter = Object.getOwnPropertyDescriptor(HTMLInputElement.prototype, 'value')?.set;
          setter?.call(input, step.value);
          input.dispatchEvent(new Event('input', { bubbles: true }));
        }
      }
      const deadline = performance.now() + 15_000;
      await new Promise<void>((resolve, reject) => {
        const tick = () => {
          if (ready()) return resolve();
          if (performance.now() > deadline) return reject(new Error(`${name} did not finish`));
          requestAnimationFrame(tick);
        };
        tick();
      });
      const end = `${name}:end:${performance.now()}`;
      performance.mark(end);
      return performance.measure(name, start, end).duration;
    },
    { name, steps, done },
  );
  (results[name] ??= []).push(duration);
}

function percentile(values: number[], fraction: number) {
  const sorted = [...values].sort((a, b) => a - b);
  return sorted[Math.min(sorted.length - 1, Math.ceil(fraction * sorted.length) - 1)] ?? null;
}

test.afterAll(async ({ browserName }) => {
  if (Object.keys(results).length === 0) return;
  const live = process.env.POS_PERF_LIVE === '1';
  const scenarios = Object.fromEntries(
    Object.entries(results).map(([name, values]) => {
      const p95 = percentile(values, 0.95);
      return [
        name,
        {
          samples: values.length,
          p50_ms: percentile(values, 0.5),
          p95_ms: p95,
          max_ms: Math.max(...values),
          target: TARGETS_MS[name],
          // Targets are for the real API on LAN staging; a mocked run has no verdict.
          ...(live ? { within_target: p95 !== null && p95 <= TARGETS_MS[name].p95 } : {}),
          raw_ms: values.map((value) => Math.round(value * 10) / 10),
        },
      ];
    }),
  );
  const report = {
    generated_at: new Date().toISOString(),
    mode: live ? 'live development API' : 'mocked API (client only)',
    disclaimer:
      'UI timings of one browser on this machine. Not a load test and not a capacity claim; fill hardware, data and load in capacity-baseline.md before comparing with targets.',
    environment: {
      browser: browserName,
      platform: process.platform,
      node: process.version,
      cpus: (await import('node:os')).cpus().length,
      base_url: process.env.POS_TEST_PORT ? `http://127.0.0.1:${process.env.POS_TEST_PORT}` : 'default',
    },
    scenarios,
  };
  const out = process.env.POS_PERF_OUT ?? 'test-results/perf/pos-scenarios.json';
  mkdirSync(dirname(out), { recursive: true });
  writeFileSync(out, `${JSON.stringify(report, null, 2)}\n`);
  console.log(`POS performance results written to ${out}`);
});

const tabSelector = (id: string) => `[role="tab"][data-workspace-id="${id}"]`;
const activeTab = (page: Page) =>
  page.locator('[role="tab"][aria-selected="true"]').getAttribute('data-workspace-id');

test('mocked API: tab switch, catalog search, draft creation and cash confirmation', async ({ page }) => {
  test.skip(process.env.POS_PERF_LIVE === '1', 'Live mode runs the other scenario');
  test.setTimeout(300_000);
  const world = newWorld();
  addLine(world, addSheet(world, 'ws_0'), 'v_rice', 1);
  addLine(world, addSheet(world, 'ws_1'), 'v_water', 1);
  await installRetailApi(page, world);
  await login(page);
  await openTab(page, 'ws_0');

  for (let index = 0; index < samples; index += 1) {
    const target = index % 2 === 0 ? 'ws_1' : 'ws_0';
    await measure(page, 'tab_switch', [{ click: tabSelector(target) }], {
      selector: `${tabSelector(target)}[aria-selected="true"]`,
    });
  }
  for (let index = 0; index < samples; index += 1) {
    const query = index % 2 === 0 ? 'Hàng số' : 'Gạo';
    await measure(
      page,
      'catalog_search',
      [{ fill: 'input[type="search"]', value: query }, { clickText: 'Tìm hàng' }],
      { selector: '[aria-label="Kết quả tìm hàng"]', text: query === 'Gạo' ? 'Gạo ST25' : 'Hàng số 1' },
    );
  }
  for (let index = 0; index < samples; index += 1) {
    // A new draft becomes the active tab (the strip may overflow, so count is no signal).
    const before = await activeTab(page);
    await measure(page, 'draft_create', [{ clickText: 'Đơn nháp mới' }], {
      selector: `[role="tab"][aria-selected="true"]:not([data-workspace-id="${before}"])`,
    });
  }
  for (let index = 0; index < samples; index += 1) {
    // A fresh draft per sample: new, active and editable by this page.
    const before = await activeTab(page);
    await page.getByRole('button', { name: 'Đơn nháp mới' }).click();
    await expect.poll(() => activeTab(page)).not.toBe(before);
    await expect(page.getByRole('button', { name: 'Tạm giữ' })).toBeEnabled();
    await scan(page, '8930000000011');
    await expect(page.getByRole('table', { name: 'Hàng trong đơn' }).locator('td.basket-index')).toHaveCount(1);
    await page.locator('.payment-panel').getByRole('button', { name: 'Thanh toán', exact: true }).click();
    await expect(page.getByRole('dialog').getByLabel('Khách đưa')).toBeVisible();
    await measure(
      page,
      'cash_confirmation',
      [{ fill: '[role="dialog"] input[inputmode]', value: '100000' }, { clickText: 'Kết thúc' }],
      { absent: '[role="dialog"]' },
    );
  }
});

test.afterEach(async ({ request }) => restoreLiveFeatures(request));

test('live API: the same four interactions against the development server', async ({ page, request }) => {
  test.skip(process.env.POS_PERF_LIVE !== '1', 'Set POS_PERF_LIVE=1 with the live fixture to measure the real API');
  test.setTimeout(600_000);
  const fixture = requireLive();
  await liveEnableFeatures(request, fixture, []);
  await liveLogin(page, fixture);
  const rice = fixture.products.rice;
  const first = await liveNewDraft(page);
  const second = await liveNewDraft(page);
  for (let index = 0; index < samples; index += 1) {
    const target = index % 2 === 0 ? first.id : second.id;
    await measure(page, 'tab_switch', [{ click: tabSelector(target) }], {
      selector: `${tabSelector(target)}[aria-selected="true"]`,
    });
  }
  for (let index = 0; index < samples; index += 1) {
    await measure(
      page,
      'catalog_search',
      [{ fill: 'input[type="search"]', value: rice.name }, { clickText: 'Tìm hàng' }],
      { selector: '[aria-label="Kết quả tìm hàng"]', text: rice.name },
    );
  }
  for (let index = 0; index < samples; index += 1) {
    // A new draft becomes the active tab (the strip may overflow, so count is no signal).
    const before = await activeTab(page);
    await measure(page, 'draft_create', [{ clickText: 'Đơn nháp mới' }], {
      selector: `[role="tab"][aria-selected="true"]:not([data-workspace-id="${before}"])`,
    });
  }
  for (let index = 0; index < samples; index += 1) {
    await liveNewDraft(page);
    await scan(page, rice.barcode);
    await expect(page.getByRole('table', { name: 'Hàng trong đơn' }).locator('td.basket-index')).toHaveCount(1, { timeout: 20_000 });
    await page.locator('.payment-panel').getByRole('button', { name: 'Thanh toán', exact: true }).click();
    await expect(page.getByRole('dialog').getByLabel('Khách đưa')).toBeVisible({ timeout: 20_000 });
    await measure(
      page,
      'cash_confirmation',
      [{ fill: '[role="dialog"] input[inputmode]', value: String(rice.price) }, { clickText: 'Kết thúc' }],
      { absent: '[role="dialog"]' },
    );
    // Nothing paid is left open: it would block closing the fixture shift.
    await completeAndHandOver(page);
  }
});
