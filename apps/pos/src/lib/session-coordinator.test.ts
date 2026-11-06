import { beforeEach, describe, expect, it, vi } from 'vitest';
import {
  createSessionCoordinator,
  type SessionMessage,
  SessionSuperseded,
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
