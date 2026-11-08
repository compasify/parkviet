import { readFileSync } from 'node:fs';
import { randomUUID } from 'node:crypto';
import { type APIRequestContext, expect, type Page, test } from '@playwright/test';
import { picker, pickerValue, pickOption } from './searchable-select';

// Opt-in runs against the real development API. They need POS_LIVE_REVIEW=1
// and POS_LIVE_FIXTURE pointing at the JSON written by the synthetic fixture
// script (apps/pos/e2e/support/pos-live-fixture.rb, see README). Each run
// creates its own drafts and orders on that fixture and deletes nothing; the
// script's `cleanup` closes what is left open and retires the fixture staff.

export type LiveProduct = { product_id: string; variant_id: string; barcode: string; name: string; price: number };
export type LiveFixture = {
  tag: string;
  branch_id: string;
  register_id: string;
  cashier: { email: string; password: string };
  manager: { email: string; password: string };
  label_code: string;
  products: Record<'rice' | 'water' | 'pork' | 'phone' | 'yogurt', LiveProduct>;
};

// The development API answers slower than the mocks; every live step waits longer.
export const liveExpect = expect.configure({ timeout: 20_000 });

export const LIVE_SKIP_REASON =
  'Real API run: set POS_LIVE_REVIEW=1 and POS_LIVE_FIXTURE to the JSON of a freshly provisioned synthetic fixture (README "Chạy với API thật")';

export function liveFixture(): LiveFixture | null {
  const path = process.env.POS_LIVE_FIXTURE;
  if (process.env.POS_LIVE_REVIEW !== '1' || !path) return null;
  return JSON.parse(readFileSync(path, 'utf8')) as LiveFixture;
}

// Skips the test unless the live run is enabled; returns the fixture.
export function requireLive(): LiveFixture {
  const fixture = liveFixture();
  test.skip(!fixture, LIVE_SKIP_REASON);
  return fixture as LiveFixture;
}

export async function liveLogin(page: Page, fixture: LiveFixture, who: 'cashier' | 'manager' = 'cashier') {
  await page.goto('/login');
  await page.getByLabel('Email nhân viên').fill(fixture[who].email);
  await page.getByLabel('Mật khẩu', { exact: true }).fill(fixture[who].password);
  await page.getByRole('button', { name: 'Đăng nhập bán hàng', exact: true }).click();
  await liveExpect(page.locator('.header-user')).not.toBeEmpty({ timeout: 60_000 });
  const chooser = page.getByRole('dialog', { name: 'Chọn nơi bán hàng' });
  const summary = page.locator('.pos-context-details > summary');
  await expect
    .poll(async () => (await chooser.isVisible()) || ((await summary.textContent()) ?? '').includes('Quầy:'), { timeout: 30_000 })
    .toBe(true);
  if (await chooser.isVisible()) await chooser.getByRole('button', { name: 'Để sau' }).click();
  await summary.click();
  if ((await pickerValue(page, 'Chi nhánh')) !== fixture.branch_id) await pickOption(page, 'Chi nhánh', fixture.branch_id);
  const register = picker(page, 'Quầy');
  // A branch with one register selects it on its own once the context loads.
  await expect
    .poll(async () => (await pickerValue(page, 'Quầy')) === fixture.register_id || (await register.isEnabled()), {
      timeout: 15_000,
    })
    .toBe(true);
  if ((await pickerValue(page, 'Quầy')) !== fixture.register_id) await pickOption(page, 'Quầy', fixture.register_id);
  await liveExpect(page.getByText('Ca đang mở', { exact: false }).first()).toBeAttached({ timeout: 15_000 });
  await page.locator('.pos-context-details').evaluate((element) => {
    (element as HTMLDetailsElement).open = false;
  });
}

// A newly created draft, selected and editable by this page.
export async function liveNewDraft(page: Page) {
  const created = page.waitForResponse(
    (response) => response.url().endsWith('/pos/workspaces') && response.request().method() === 'POST',
  );
  await page.getByRole('button', { name: 'Đơn nháp mới' }).click();
  const response = await created;
  liveExpect(response.status(), await response.text()).toBe(201);
  const draft = (await response.json()).data as { id: string; order_id: string };
  await liveExpect(page.locator(`[role="tab"][data-workspace-id="${draft.id}"]`)).toHaveAttribute('aria-selected', 'true');
  await liveExpect(page.getByRole('button', { name: 'Tạm giữ' })).toBeEnabled();
  return draft;
}

// Every risky feature starts off. A feature runs at a branch only when the
// store default is on and the branch has not switched it off, so the fixture
// manager (store `write_pos_topology`) turns the store default on and drops a
// branch switch-off, through the same endpoint and audit a person would use.
// The store default applies to every branch of the development store, so the
// previous state is remembered and put back by `restoreLiveFeatures`.
type Switch = { store: boolean; branch_override: boolean | null };
const restores: Array<{ fixture: LiveFixture; feature: string; before: Switch }> = [];

async function liveSwitches(manager: Awaited<ReturnType<typeof liveApi>>, fixture: LiveFixture) {
  type Flags = { data: { switches?: Record<string, Switch>; features: Record<string, boolean> } };
  return (await manager.get<Flags>('/pos/feature_flags', { branch_id: fixture.branch_id })).data;
}

export async function liveEnableFeatures(request: APIRequestContext, fixture: LiveFixture, features: string[]) {
  const manager = await liveApi(request, fixture, 'manager');
  const reason = `Kiểm thử e2e thật ${fixture.tag}`;
  const before = await liveSwitches(manager, fixture);
  for (const feature of features) {
    const previous = before.switches?.[feature] ?? { store: false, branch_override: null };
    restores.push({ fixture, feature, before: previous });
    if (!previous.store) {
      const store = await manager.send('PUT', `/pos/feature_flags/${feature}`, { enabled: true, reason });
      liveExpect(store.status, `${feature}: ${JSON.stringify(store.body)}`).toBe(200);
    }
    if (previous.branch_override === false) {
      const branch = await manager.send('PUT', `/pos/feature_flags/${feature}`, { branch_id: fixture.branch_id, enabled: null, reason });
      liveExpect(branch.status, `${feature}: ${JSON.stringify(branch.body)}`).toBe(200);
    }
  }
  const after = await liveSwitches(manager, fixture);
  for (const feature of features) liveExpect(after.features[feature], feature).toBe(true);
}

// Puts every switch a live test changed back the way it found it.
export async function restoreLiveFeatures(request: APIRequestContext) {
  while (restores.length) {
    const entry = restores.pop();
    if (!entry) break;
    const manager = await liveApi(request, entry.fixture, 'manager');
    const reason = `Khôi phục sau kiểm thử e2e thật ${entry.fixture.tag}`;
    if (entry.before.branch_override === false) {
      const branch = await manager.send('PUT', `/pos/feature_flags/${entry.feature}`, { branch_id: entry.fixture.branch_id, enabled: false, reason });
      liveExpect(branch.status, JSON.stringify(branch.body)).toBe(200);
    }
    if (!entry.before.store) {
      const store = await manager.send('PUT', `/pos/feature_flags/${entry.feature}`, { enabled: false, reason });
      liveExpect(store.status, JSON.stringify(store.body)).toBe(200);
    }
  }
}

// Admin API as one of the fixture staff, for setup and for asserting facts.
// The API rate-limits logins, so each staff member signs in once per worker
// and a 429 waits for its Retry-After instead of failing the run.
const tokens = new Map<string, string>();

async function apiToken(request: APIRequestContext, fixture: LiveFixture, who: 'cashier' | 'manager') {
  const cached = tokens.get(fixture[who].email);
  if (cached) return cached;
  for (let attempt = 0; attempt < 6; attempt += 1) {
    const login = await request.post('/api/v3/admin/auth/login', {
      data: { email: fixture[who].email, password: fixture[who].password },
    });
    if (login.status() === 429) {
      const wait = Number(login.headers()['retry-after'] ?? '20');
      await new Promise((resolve) => setTimeout(resolve, Math.min(Math.max(wait, 1), 60) * 1000));
      continue;
    }
    liveExpect(login.status()).toBe(200);
    const token = (await login.json()).token as string;
    tokens.set(fixture[who].email, token);
    return token;
  }
  throw new Error('Login stayed rate-limited');
}

export async function liveApi(request: APIRequestContext, fixture: LiveFixture, who: 'cashier' | 'manager') {
  const token = await apiToken(request, fixture, who);
  const headers = (key?: string) => ({ authorization: `Bearer ${token}`, ...(key ? { 'Idempotency-Key': key } : {}) });
  return {
    async get<T = unknown>(path: string, params: Record<string, string> = {}) {
      const response = await request.get(`/api/v3/admin${path}`, { headers: headers(), params });
      liveExpect(response.status(), `${path}: ${await response.text()}`).toBe(200);
      return (await response.json()) as T;
    },
    async send(method: 'POST' | 'PUT' | 'PATCH', path: string, data: Record<string, unknown>) {
      const key = randomUUID();
      const response = await request.fetch(`/api/v3/admin${path}`, {
        method,
        headers: headers(key),
        data: { ...data, idempotency_key: key },
      });
      return { status: response.status(), body: await response.json().catch(() => null), key };
    },
  };
}
