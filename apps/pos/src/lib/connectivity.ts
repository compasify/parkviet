// Whether this counter reaches the server. The browser's own online flag
// only knows about the network card, so a request that failed on the way
// (no status) makes the counter ask the server directly; two failed asks in
// a row mean offline, and while offline it keeps asking until one answers.

export type Connectivity = { online: boolean };

// Any answer below these means the server is there, even a refusal.
const UNREACHABLE = new Set([502, 503, 504]);
const PROBE_TIMEOUT_MS = 4_000;
const PROBE_FAILURES = 2;
const OFFLINE_PROBE_MS = 15_000;

export function createConnectivity(options: {
  probeUrl: string;
  fetcher?: typeof fetch;
  initiallyOnline?: boolean;
  setTimer?: (run: () => void, ms: number) => unknown;
  clearTimer?: (timer: unknown) => void;
}) {
  const fetcher = options.fetcher ?? ((...args: Parameters<typeof fetch>) => fetch(...args));
  const setTimer =
    options.setTimer ?? ((run: () => void, ms: number) => globalThis.setTimeout(run, ms));
  const clearTimer =
    options.clearTimer ??
    ((timer: unknown) => globalThis.clearTimeout(timer as ReturnType<typeof setTimeout>));
  let state: Connectivity = { online: options.initiallyOnline ?? true };
  let probing: Promise<boolean> | null = null;
  let timer: unknown = null;
  const listeners = new Set<() => void>();

  function publish(online: boolean) {
    if (state.online === online) return;
    state = { online };
    for (const listener of listeners) listener();
  }

  async function reachable(): Promise<boolean> {
    const controller = typeof AbortController === 'undefined' ? null : new AbortController();
    const timeout = setTimer(() => controller?.abort(), PROBE_TIMEOUT_MS);
    try {
      const response = await fetcher(options.probeUrl, {
        method: 'GET',
        cache: 'no-store',
        credentials: 'omit',
        signal: controller?.signal,
      });
      return !UNREACHABLE.has(response.status);
    } catch {
      return false;
    } finally {
      clearTimer(timeout);
    }
  }

  function schedule() {
    if (timer !== null) clearTimer(timer);
    timer = state.online
      ? null
      : setTimer(() => {
          timer = null;
          void check();
        }, OFFLINE_PROBE_MS);
  }

  async function probeOnce(): Promise<boolean> {
    for (let attempt = 0; attempt < PROBE_FAILURES; attempt++) {
      if (await reachable()) return true;
    }
    return false;
  }

  // Asks the server now; resolves to whether it answered.
  function check(): Promise<boolean> {
    probing ??= probeOnce()
      .then((online) => {
        publish(online);
        schedule();
        return online;
      })
      .finally(() => {
        probing = null;
      });
    return probing;
  }

  return {
    subscribe(listener: () => void) {
      listeners.add(listener);
      return () => {
        listeners.delete(listener);
      };
    },
    getSnapshot() {
      return state;
    },
    check,
    // A request failed before any answer: find out whether the server is gone.
    reportNetworkFailure() {
      void check();
    },
    // The browser lost the network: no point asking.
    browserOffline() {
      publish(false);
      schedule();
    },
    browserOnline() {
      void check();
    },
  };
}

// The API is served at the site root, whatever path the POS is mounted on.
// Unsigned, it answers 401 at once: enough to know the server is there.
export const connectivity = createConnectivity({
  probeUrl: `${globalThis.location?.origin ?? ''}/api/v3/admin/pos/offline_snapshot`,
  initiallyOnline: globalThis.navigator?.onLine !== false,
});

if (typeof window !== 'undefined') {
  window.addEventListener('offline', () => connectivity.browserOffline());
  window.addEventListener('online', () => connectivity.browserOnline());
}
