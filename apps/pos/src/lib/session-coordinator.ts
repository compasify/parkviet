import { createAdminClient } from '@spree/admin-sdk';

const SESSION_MESSAGE = 'pos.session';

export type SessionStatus = 'anonymous' | 'authenticated';

export type SessionSnapshot = {
  status: SessionStatus;
  generation: number;
  email: string;
  name: string;
};

export type SessionMessage = { type: typeof SESSION_MESSAGE; event: 'cleared' | 'refreshed' };

type StaffIdentity = { user: { email: string; full_name?: string | null } };

type PosApi = {
  auth: {
    login: (credentials: { email: string; password: string }) => Promise<{ token: string }>;
    logout: () => Promise<void>;
    refresh: () => Promise<{ token: string }>;
  };
  setToken: (token: string) => void;
  me: { get: () => Promise<StaffIdentity> };
  request: <T>(
    method: string,
    path: string,
    options?: {
      body?: unknown;
      params?: Record<string, string | undefined>;
      idempotencyKey?: string;
    },
  ) => Promise<T>;
  onUnauthorized?: (handler: () => Promise<boolean>) => void;
};

type SessionChannel = {
  postMessage: (data: SessionMessage) => void;
  subscribe: (handler: (data: SessionMessage) => void) => () => void;
};

type RefreshLock = <T>(run: () => Promise<T>) => Promise<T>;

export class SessionSuperseded extends Error {
  constructor() {
    super('session-superseded');
    this.name = 'SessionSuperseded';
  }
}

export function createSessionCoordinator(options: {
  origin: string;
  createClient?: () => PosApi;
  channel?: SessionChannel | null;
  lock?: RefreshLock;
  onCleared?: (explicitLogout: boolean) => void;
}) {
  const createClient =
    options.createClient ?? (() => createAdminClient({ baseUrl: options.origin }) as PosApi);
  let generation = 0;
  let client = createClient();
  let snapshot: SessionSnapshot = { status: 'anonymous', generation: 0, email: '', name: '' };
  let refreshFlight: Promise<string> | null = null;
  const listeners = new Set<() => void>();

  function publish(next: SessionSnapshot) {
    snapshot = next;
    listeners.forEach((listener) => {
      listener();
    });
  }

  function replaceClient() {
    client = createClient();
  }

  function clearLocal(nextGeneration: number, explicitLogout = false) {
    generation = nextGeneration;
    replaceClient();
    refreshFlight = null;
    publish({ status: 'anonymous', generation, email: '', name: '' });
    options.onCleared?.(explicitLogout);
  }

  async function withRefreshLock<T>(run: () => Promise<T>) {
    if (options.lock) return options.lock(run);
    const locks = globalThis.navigator?.locks;
    if (locks) return locks.request('parkviet-pos-refresh', () => run());
    return run();
  }

  function bindUnauthorized(active: PosApi, started: number) {
    active.onUnauthorized?.(async () => {
      if (started !== generation) return false;
      try {
        await refresh();
        return started === generation;
      } catch {
        return false;
      }
    });
  }

  async function refresh() {
    const started = generation;
    const active = client;
    if (!refreshFlight) {
      refreshFlight = withRefreshLock(async () => {
        const { token } = await active.auth.refresh();
        return token;
      }).finally(() => {
        refreshFlight = null;
      });
    }
    const token = await refreshFlight;
    if (started !== generation) throw new SessionSuperseded();
    active.setToken(token);
    options.channel?.postMessage({ type: SESSION_MESSAGE, event: 'refreshed' });
    return token;
  }

  if (options.channel) {
    options.channel.subscribe((data) => {
      if (data?.type !== SESSION_MESSAGE) return;
      if (data.event === 'cleared') clearLocal(generation + 1);
    });
  }

  function compactParams(params?: { branch_id?: string | null; register_id?: string | null }) {
    const query: Record<string, string> = {};
    if (params?.branch_id) query.branch_id = params.branch_id;
    if (params?.register_id) query.register_id = params.register_id;
    return query;
  }

  async function thisRequest<T>(
    method: string,
    path: string,
    options?: {
      body?: unknown;
      params?: Record<string, string | undefined>;
      idempotencyKey?: string;
    },
  ) {
    const started = generation;
    const active = client;
    const body = await active.request<T>(method, path, options);
    if (started !== generation) throw new SessionSuperseded();
    return body;
  }

  return {
    subscribe(listener: () => void) {
      listeners.add(listener);
      return () => listeners.delete(listener);
    },
    getSnapshot() {
      return snapshot;
    },
    async login(email: string, password: string) {
      const started = generation;
      const active = client;
      try {
        const { token } = await active.auth.login({ email, password });
        if (started !== generation) throw new SessionSuperseded();
        active.setToken(token);
        bindUnauthorized(active, started);
        const identity = await active.me.get();
        if (started !== generation) throw new SessionSuperseded();
        const name = identity.user.full_name || identity.user.email;
        publish({ status: 'authenticated', generation: started, email: identity.user.email, name });
        return identity;
      } catch (error) {
        if (started === generation) replaceClient();
        throw error;
      }
    },
    async logout() {
      const previous = client;
      clearLocal(generation + 1, true);
      options.channel?.postMessage({ type: SESSION_MESSAGE, event: 'cleared' });
      await previous.auth.logout();
    },
    abandon() {
      clearLocal(generation + 1);
      options.channel?.postMessage({ type: SESSION_MESSAGE, event: 'cleared' });
    },
    async restore() {
      if (snapshot.status === 'authenticated') return;
      const started = generation;
      const active = client;
      try {
        await refresh();
        if (started !== generation) throw new SessionSuperseded();
        bindUnauthorized(active, started);
        const identity = await active.me.get();
        if (started !== generation) throw new SessionSuperseded();
        publish({
          status: 'authenticated',
          generation: started,
          email: identity.user.email,
          name: identity.user.full_name || identity.user.email,
        });
      } catch (error) {
        if (started === generation) {
          // Preserve scoped unsent intentions when startup cannot reach the server.
          generation += 1;
          replaceClient();
          refreshFlight = null;
          publish({ status: 'anonymous', generation, email: '', name: '' });
        }
        if (error instanceof SessionSuperseded) throw error;
      }
    },
    async resume() {
      if (snapshot.status !== 'authenticated') return;
      try {
        await refresh();
      } catch (error) {
        if (error instanceof SessionSuperseded) return;
        clearLocal(generation + 1);
      }
    },
    refresh,
    async fetchContext<T>(params?: { branch_id?: string | null; register_id?: string | null }) {
      return thisRequest<T>('GET', '/pos/context', { params: compactParams(params) });
    },
    request: thisRequest,
  };
}

export function browserSessionChannel(): SessionChannel | null {
  if (typeof BroadcastChannel === 'undefined') return null;
  const channel = new BroadcastChannel('parkviet-pos-session');
  return {
    postMessage: (data) => channel.postMessage(data),
    subscribe: (handler) => {
      const listener = (event: MessageEvent<SessionMessage>) => handler(event.data);
      channel.addEventListener('message', listener);
      return () => channel.removeEventListener('message', listener);
    },
  };
}
