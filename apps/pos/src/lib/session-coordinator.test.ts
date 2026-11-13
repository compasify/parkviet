import { beforeEach, describe, expect, it, vi } from 'vitest';
import {
  chooseStore,
  createSessionCoordinator,
  needsStoreChoice,
  type SessionMessage,
  SessionSuperseded,
  type StoreChoice,
} from './session-coordinator';

const sdk = vi.hoisted(() => ({ create: vi.fn() }));
vi.mock('@spree/admin-sdk', () => ({ createAdminClient: sdk.create }));

function client() {
  return {
    auth: {
      login: vi.fn().mockResolvedValue({ token: 'access' }),
      logout: vi.fn().mockResolvedValue(undefined),
      refresh: vi.fn().mockResolvedValue({ token: 'rotated' }),
    },
    setToken: vi.fn(),
    setStore: vi.fn(),
    me: {
      get: vi.fn().mockResolvedValue({ user: { email: 'staff@example.test', full_name: 'Lan' } }),
    },
    request: vi.fn(),
    onUnauthorized: vi.fn(),
  };
}

beforeEach(() => {
  sdk.create.mockReset();
});

function coordinator() {
  return createSessionCoordinator({ origin: 'http://localhost' });
}

describe('phiên nhân viên', () => {
  it('forwards the caller idempotency key to the SDK', async () => {
    const api = client();
    sdk.create.mockReturnValue(api);
    const session = coordinator();
    await session.request('POST', '/pos/workspaces', {
      body: { idempotency_key: 'stable-key' },
      idempotencyKey: 'stable-key',
    });
    expect(api.request).toHaveBeenCalledWith('POST', '/pos/workspaces', {
      body: { idempotency_key: 'stable-key' },
      idempotencyKey: 'stable-key',
    });
  });
  it('passes the SDK access token to the identity request', async () => {
    const api = client();
    sdk.create.mockReturnValue(api);
    const session = coordinator();
    const result = await session.login('staff@example.test', 'password');
    expect(result.user.email).toBe('staff@example.test');
    expect(api.setToken).toHaveBeenCalledWith('access');
    expect(api.auth.login).toHaveBeenCalledWith({
      email: 'staff@example.test',
      password: 'password',
    });
    expect(session.getSnapshot()).toMatchObject({ status: 'authenticated', name: 'Lan' });
  });

  it('discards the client if fetching identity fails', async () => {
    const first = client();
    const next = client();
    first.me.get.mockRejectedValue(new Error('network'));
    sdk.create.mockReturnValueOnce(first).mockReturnValue(next);
    const session = coordinator();
    await expect(session.login('staff@example.test', 'password')).rejects.toThrow('network');
    await session.login('staff@example.test', 'password');
    expect(next.auth.login).toHaveBeenCalledOnce();
  });

  it('drops the local client before attempting remote logout', async () => {
    const first = client();
    const next = client();
    first.auth.logout.mockRejectedValue(new Error('offline'));
    sdk.create.mockReturnValueOnce(first).mockReturnValue(next);
    const session = coordinator();
    await expect(session.logout()).rejects.toThrow('offline');
    await session.login('staff@example.test', 'password');
    expect(next.auth.login).toHaveBeenCalledOnce();
    expect(session.getSnapshot().status).toBe('authenticated');
  });

  it('ignores a login result that arrives after logout', async () => {
    const first = client();
    const next = client();
    let resolveLogin: (value: { token: string }) => void = () => {};
    first.auth.login.mockImplementation(
      () =>
        new Promise((resolve) => {
          resolveLogin = resolve;
        }),
    );
    sdk.create.mockReturnValueOnce(first).mockReturnValue(next);
    const session = coordinator();
    const pending = session.login('staff@example.test', 'password');
    const loggedOut = session.logout();
    resolveLogin({ token: 'late' });
    await expect(pending).rejects.toBeInstanceOf(SessionSuperseded);
    await loggedOut;
    expect(first.setToken).not.toHaveBeenCalled();
    expect(next.setToken).not.toHaveBeenCalled();
    expect(first.me.get).not.toHaveBeenCalled();
    expect(session.getSnapshot().status).toBe('anonymous');
  });

  it('hands a socket the young access token without rotating the cookie', async () => {
    const api = client();
    sdk.create.mockReturnValue(api);
    const session = coordinator();
    await session.login('staff@example.test', 'password');

    await expect(session.socketToken()).resolves.toBe('access');
    expect(api.auth.refresh).not.toHaveBeenCalled();
  });

  it('refreshes before handing a socket an access token that may have expired', async () => {
    vi.useFakeTimers();
    try {
      const api = client();
      sdk.create.mockReturnValue(api);
      const session = coordinator();
      await session.login('staff@example.test', 'password');
      vi.advanceTimersByTime(61_000);

      await expect(session.socketToken()).resolves.toBe('rotated');
      expect(api.auth.refresh).toHaveBeenCalledOnce();
    } finally {
      vi.useRealTimers();
    }
  });

  it('reuses a token that states its expiry until shortly before it expires', async () => {
    vi.useFakeTimers();
    try {
      const api = client();
      const exp = Math.floor(Date.now() / 1000) + 300;
      const token = `h.${btoa(JSON.stringify({ exp })).replace(/=+$/, '')}.s`;
      api.auth.login.mockResolvedValue({ token });
      sdk.create.mockReturnValue(api);
      const session = coordinator();
      await session.login('staff@example.test', 'password');

      vi.advanceTimersByTime(260_000);
      await expect(session.socketToken()).resolves.toBe(token);
      expect(api.auth.refresh).not.toHaveBeenCalled();

      vi.advanceTimersByTime(15_000);
      await expect(session.socketToken()).resolves.toBe('rotated');
      expect(api.auth.refresh).toHaveBeenCalledOnce();
    } finally {
      vi.useRealTimers();
    }
  });

  it('keeps the session when a refresh is rate limited', async () => {
    const api = client();
    sdk.create.mockReturnValue(api);
    const session = coordinator();
    await session.login('staff@example.test', 'password');
    api.auth.refresh.mockRejectedValue(Object.assign(new Error('slow down'), { status: 429 }));

    await session.resume();

    expect(session.getSnapshot().status).toBe('authenticated');
  });

  it('hands a rate limited refresh to the request instead of reporting it unauthorized', async () => {
    const api = client();
    let onUnauthorized: (() => Promise<boolean>) | undefined;
    api.onUnauthorized = vi.fn((handler: () => Promise<boolean>) => {
      onUnauthorized = handler;
    });
    sdk.create.mockReturnValue(api);
    const session = coordinator();
    await session.login('staff@example.test', 'password');
    const limited = Object.assign(new Error('slow down'), { status: 429 });
    api.auth.refresh.mockRejectedValue(limited);

    await expect(onUnauthorized?.()).rejects.toBe(limited);
  });

  it('still reports a refused refresh as unauthorized', async () => {
    const api = client();
    let onUnauthorized: (() => Promise<boolean>) | undefined;
    api.onUnauthorized = vi.fn((handler: () => Promise<boolean>) => {
      onUnauthorized = handler;
    });
    sdk.create.mockReturnValue(api);
    const session = coordinator();
    await session.login('staff@example.test', 'password');
    api.auth.refresh.mockRejectedValue(Object.assign(new Error('expired'), { status: 401 }));

    await expect(onUnauthorized?.()).resolves.toBe(false);
  });

  it('forgets the access token on logout', async () => {
    const first = client();
    const second = client();
    sdk.create.mockReturnValueOnce(first).mockReturnValue(second);
    const session = coordinator();
    await session.login('staff@example.test', 'password');
    await session.logout();

    await expect(session.socketToken()).resolves.toBe('rotated');
    expect(second.auth.refresh).toHaveBeenCalledOnce();
  });

  it('takes the refresh lock before rotating the cookie', async () => {
    const api = client();
    sdk.create.mockReturnValue(api);
    let locked = 0;
    const session = createSessionCoordinator({
      origin: 'http://localhost',
      lock: async (run) => {
        locked += 1;
        return run();
      },
    });
    await expect(session.refresh()).resolves.toBe('rotated');
    expect(locked).toBe(1);
    expect(api.auth.refresh).toHaveBeenCalledOnce();
  });

  it('shares one refresh across overlapping callers', async () => {
    const api = client();
    let resolveRefresh: (value: { token: string }) => void = () => {};
    api.auth.refresh.mockImplementation(
      () =>
        new Promise((resolve) => {
          resolveRefresh = resolve;
        }),
    );
    sdk.create.mockReturnValue(api);
    const session = coordinator();
    const first = session.refresh();
    const second = session.refresh();
    resolveRefresh({ token: 'rotated' });
    await expect(first).resolves.toBe('rotated');
    await expect(second).resolves.toBe('rotated');
    expect(api.auth.refresh).toHaveBeenCalledOnce();
    expect(api.setToken).toHaveBeenCalledTimes(2);
    expect(api.setToken).toHaveBeenCalledWith('rotated');
  });

  it('does not apply a refresh that finishes after logout', async () => {
    const first = client();
    const next = client();
    let resolveRefresh: (value: { token: string }) => void = () => {};
    first.auth.refresh.mockImplementation(
      () =>
        new Promise((resolve) => {
          resolveRefresh = resolve;
        }),
    );
    sdk.create.mockReturnValueOnce(first).mockReturnValue(next);
    const session = coordinator();
    const pending = session.refresh();
    const loggedOut = session.logout();
    resolveRefresh({ token: 'rotated' });
    await expect(pending).rejects.toBeInstanceOf(SessionSuperseded);
    await loggedOut;
    expect(first.setToken).not.toHaveBeenCalled();
    expect(next.setToken).not.toHaveBeenCalled();
  });

  it('clears other tabs without broadcasting a credential', async () => {
    const api = client();
    sdk.create.mockReturnValue(api);
    const messages: unknown[] = [];
    let handler: (data: SessionMessage) => void = () => {};
    const session = createSessionCoordinator({
      origin: 'http://localhost',
      createClient: () => api,
      channel: {
        postMessage: (data) => messages.push(data),
        subscribe: (next) => {
          handler = next;
          return () => {};
        },
      },
    });
    await session.login('staff@example.test', 'password');
    handler({ type: 'pos.session', event: 'cleared' });
    expect(session.getSnapshot().status).toBe('anonymous');
    expect(api.auth.logout).not.toHaveBeenCalled();
    expect(JSON.stringify(messages)).not.toContain('access');
  });

  it('locks the tab when resume cannot refresh', async () => {
    const api = client();
    sdk.create.mockReturnValue(api);
    const cleared = vi.fn();
    const session = createSessionCoordinator({ origin: 'http://localhost', onCleared: cleared });
    await session.login('staff@example.test', 'password');
    cleared.mockClear();
    api.auth.refresh.mockRejectedValue(Object.assign(new Error('expired'), { status: 401 }));
    await session.resume();
    expect(session.getSnapshot().status).toBe('anonymous');
    expect(cleared).toHaveBeenCalledOnce();
  });

  it('keeps the cashier signed in when resume gets no answer from the server', async () => {
    const api = client();
    sdk.create.mockReturnValue(api);
    const cleared = vi.fn();
    const session = createSessionCoordinator({ origin: 'http://localhost', onCleared: cleared });
    await session.login('staff@example.test', 'password');
    cleared.mockClear();
    api.auth.refresh.mockRejectedValue(new TypeError('Failed to fetch'));
    await session.resume();
    expect(session.getSnapshot().status).toBe('authenticated');
    expect(cleared).not.toHaveBeenCalled();
  });

  it('restores a session from the refresh cookie after reload', async () => {
    const api = client();
    sdk.create.mockReturnValue(api);
    const session = coordinator();
    await session.restore();
    expect(api.auth.refresh).toHaveBeenCalledOnce();
    expect(api.me.get).toHaveBeenCalledOnce();
    expect(session.getSnapshot()).toMatchObject({
      status: 'authenticated',
      email: 'staff@example.test',
    });
  });
});

describe('cửa hàng của phiên', () => {
  const retail = { id: 'st_retail', name: 'Bán lẻ', code: 'retail' };
  const restaurant = { id: 'st_food', name: 'Nhà hàng', code: 'food' };

  function staffOf(api: ReturnType<typeof client>, stores: StoreChoice[]) {
    api.me.get.mockResolvedValue({
      user: { email: 'staff@example.test', full_name: 'Lan', stores },
    });
    return api;
  }

  function remembering(initial: string | null) {
    let value = initial;
    return {
      read: () => value,
      write: vi.fn((storeId: string) => {
        value = storeId;
      }),
    };
  }

  it('sells for the only store without asking', async () => {
    const api = staffOf(client(), [restaurant]);
    sdk.create.mockReturnValue(api);
    const session = createSessionCoordinator({ origin: 'http://localhost' });
    await session.login('staff@example.test', 'password');
    expect(api.setStore).toHaveBeenCalledWith('st_food');
    expect(session.getSnapshot().storeId).toBe('st_food');
    expect(needsStoreChoice(session.getSnapshot())).toBe(false);
  });

  it('asks a cashier of several stores which one to sell for', async () => {
    const api = staffOf(client(), [retail, restaurant]);
    sdk.create.mockReturnValue(api);
    const session = createSessionCoordinator({ origin: 'http://localhost' });
    await session.login('staff@example.test', 'password');
    expect(api.setStore).not.toHaveBeenCalled();
    expect(needsStoreChoice(session.getSnapshot())).toBe(true);
  });

  it('reopens the remembered store after a reload', async () => {
    const api = staffOf(client(), [retail, restaurant]);
    sdk.create.mockReturnValue(api);
    const session = createSessionCoordinator({
      origin: 'http://localhost',
      storeMemory: remembering('st_food'),
    });
    await session.restore();
    expect(api.setStore).toHaveBeenCalledWith('st_food');
    expect(session.getSnapshot().storeId).toBe('st_food');
  });

  it('ignores a remembered store the cashier no longer works in', () => {
    expect(chooseStore([retail, restaurant], 'st_gone')).toBeNull();
    expect(chooseStore([], 'st_gone')).toBeNull();
  });

  it('falls back to the default store only when the cashier works there', () => {
    const main = { ...retail, default: true };
    expect(chooseStore([main, restaurant], null)).toBe('st_retail');
    expect(chooseStore([main, restaurant], 'st_food')).toBe('st_food');
    expect(
      chooseStore(
        [
          { ...restaurant, default: false },
          { ...retail, id: 'st_bar' },
        ],
        null,
      ),
    ).toBeNull();
  });

  it('reopens the default store after a reload without asking', async () => {
    const api = staffOf(client(), [{ ...retail, default: true }, restaurant]);
    sdk.create.mockReturnValue(api);
    const session = createSessionCoordinator({ origin: 'http://localhost' });
    await session.restore();
    expect(api.setStore).toHaveBeenCalledWith('st_retail');
    expect(needsStoreChoice(session.getSnapshot())).toBe(false);
  });

  it('asks which store on a fresh sign-in, even with a default or remembered store', async () => {
    const api = staffOf(client(), [{ ...retail, default: true }, restaurant]);
    sdk.create.mockReturnValue(api);
    const session = createSessionCoordinator({
      origin: 'http://localhost',
      storeMemory: remembering('st_food'),
    });
    await session.login('staff@example.test', 'password');
    expect(api.setStore).not.toHaveBeenCalled();
    expect(needsStoreChoice(session.getSnapshot())).toBe(true);
  });

  it('signs in straight to the store the dashboard link named', async () => {
    const api = staffOf(client(), [retail, restaurant]);
    sdk.create.mockReturnValue(api);
    const session = createSessionCoordinator({
      origin: 'http://localhost',
      storeMemory: { ...remembering('st_retail'), requested: () => 'st_food' },
    });
    await session.login('staff@example.test', 'password');
    expect(api.setStore).toHaveBeenCalledWith('st_food');
    expect(needsStoreChoice(session.getSnapshot())).toBe(false);
  });

  it('switches store on a fresh client and drops answers for the previous one', async () => {
    const first = staffOf(client(), [retail, restaurant]);
    const next = staffOf(client(), [retail, restaurant]);
    sdk.create.mockReturnValueOnce(first).mockReturnValue(next);
    const memory = remembering(null);
    const session = createSessionCoordinator({ origin: 'http://localhost', storeMemory: memory });
    await session.login('staff@example.test', 'password');
    let answer: (value: unknown) => void = () => undefined;
    first.request.mockReturnValue(
      new Promise((resolve) => {
        answer = resolve;
      }),
    );
    const late = session.request('GET', '/pos/context');
    const before = session.getSnapshot().generation;

    session.selectStore('st_food');
    answer({});

    await expect(late).rejects.toBeInstanceOf(SessionSuperseded);
    expect(next.setToken).toHaveBeenCalledWith('access');
    expect(next.setStore).toHaveBeenCalledWith('st_food');
    expect(next.onUnauthorized).toHaveBeenCalledOnce();
    expect(memory.write).toHaveBeenCalledWith('st_food');
    expect(session.getSnapshot()).toMatchObject({ storeId: 'st_food', status: 'authenticated' });
    expect(session.getSnapshot().generation).toBeGreaterThan(before);
  });

  it('refuses a store the cashier has no role in', async () => {
    const api = staffOf(client(), [retail, restaurant]);
    sdk.create.mockReturnValue(api);
    const session = createSessionCoordinator({ origin: 'http://localhost' });
    await session.login('staff@example.test', 'password');
    expect(() => session.selectStore('st_other')).toThrow('unknown-store');
  });
});
