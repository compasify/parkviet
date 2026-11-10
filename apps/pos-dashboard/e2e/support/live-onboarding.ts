import { readFileSync } from 'node:fs';
import { type APIRequestContext, expect, test } from '@playwright/test';

// Opt-in dashboard onboarding runs against the real development API.
// They need POS_LIVE_REVIEW=1 and POS_LIVE_ONBOARDING_FIXTURE pointing at
// the JSON written by the synthetic fixture script.

// The development API answers slower than the mocks; every live step waits longer.
export const liveExpect = expect.configure({ timeout: 20_000 });

// Admin API as one of the fixture staff, for setup and for asserting facts.
// The API rate-limits logins, so each staff member signs in once per worker
// and a 429 waits for its Retry-After instead of failing the run.
const tokens = new Map<string, string>();

async function loginToken(request: APIRequestContext, account: { email: string; password: string }) {
  const cached = tokens.get(account.email);
  if (cached) return cached;
  for (let attempt = 0; attempt < 6; attempt += 1) {
    const login = await request.post('/api/v3/admin/auth/login', {
      data: { email: account.email, password: account.password },
    });
    if (login.status() === 429) {
      const wait = Number(login.headers()['retry-after'] ?? '20');
      await new Promise((resolve) => setTimeout(resolve, Math.min(Math.max(wait, 1), 60) * 1000));
      continue;
    }
    liveExpect(login.status()).toBe(200);
    const token = (await login.json()).token as string;
    tokens.set(account.email, token);
    return token;
  }
  throw new Error('Login stayed rate-limited');
}

// First-run setup against the real API: `pos-live-fixture.rb onboarding=N`
// makes N stores that were never set up, plus one owner with a role on each
// and no POS membership. Opt in with POS_LIVE_REVIEW=1 and
// POS_LIVE_ONBOARDING_FIXTURE pointing at that JSON.
export type LiveOnboardingStore = { store_id: string; name: string; stock_location_id: string; stock_location_name: string };
export type LiveOnboardingFixture = {
  tag: string;
  onboarding: true;
  owner: { email: string; password: string };
  stores: LiveOnboardingStore[];
};

export function requireLiveOnboarding(stores: number): LiveOnboardingFixture {
  const path = process.env.POS_LIVE_ONBOARDING_FIXTURE;
  const fixture =
    process.env.POS_LIVE_REVIEW === '1' && path ? (JSON.parse(readFileSync(path, 'utf8')) as LiveOnboardingFixture) : null;
  test.skip(
    !fixture,
    'Real API setup run: set POS_LIVE_REVIEW=1 and POS_LIVE_ONBOARDING_FIXTURE to the JSON of `pos-live-fixture.rb onboarding=2` (README)',
  );
  test.skip((fixture?.stores.length ?? 0) < stores, `Needs a fixture with at least ${stores} onboarding stores`);
  return fixture as LiveOnboardingFixture;
}

const STORE_HEADER = 'X-Spree-Store-Id';

// Admin API as the onboarding owner, on one onboarding store. Answers come
// back whatever their status; the caller asserts.
export async function liveStoreApi(request: APIRequestContext, fixture: LiveOnboardingFixture, storeId: string) {
  const token = await loginToken(request, fixture.owner);
  const headers = (key?: string) => ({
    authorization: `Bearer ${token}`,
    [STORE_HEADER]: storeId,
    ...(key ? { 'Idempotency-Key': key } : {}),
  });
  return {
    async get<T = unknown>(path: string, params: Record<string, string> = {}) {
      const response = await request.get(`/api/v3/admin${path}`, { headers: headers(), params });
      return { status: response.status(), body: (await response.json().catch(() => null)) as T };
    },
    async send<T = unknown>(method: 'POST' | 'PUT' | 'PATCH', path: string, data: unknown, key?: string) {
      const response = await request.fetch(`/api/v3/admin${path}`, { method, headers: headers(key), data });
      return { status: response.status(), body: (await response.json().catch(() => null)) as T };
    },
  };
}
