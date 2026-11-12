import { type Consumer, createConsumer } from '@rails/actioncable';
import type { InvalidateQueryFilters } from '@tanstack/react-query';
import { posWorkspacesKey, resourceBoardKey } from './query-keys';

export type RealtimeStatus = 'connected' | 'connecting' | 'offline';

export type RealtimeEvent = {
  event: string;
  id: string;
  branch_id: string;
  revision?: number;
  lease_generation?: number;
  at: string;
  refs: Record<string, string>;
};

export const CHANNEL = 'Spree::Pos::BranchChannel';
export const CONNECTED_POLL_MS = 60_000;
export const CONNECT_TIMEOUT_MS = 8_000;
const MAX_BACKOFF_MS = 60_000;

// A poll stretched this far relies on an event invalidating the same query, so
// only pass a query here when a published event covers everything it reads.
export function pollInterval(status: RealtimeStatus, fallbackMs: number) {
  return status === 'connected' ? CONNECTED_POLL_MS : fallbackMs;
}

// Half fixed, half random: tabs dropped together must not all return together.
export function backoffMs(attempt: number, random: () => number = Math.random) {
  const ceiling = Math.min(MAX_BACKOFF_MS, 1000 * 2 ** attempt);
  return ceiling / 2 + random() * (ceiling / 2);
}

type RealtimeScope = { generation: number; storeId: string | null };

function isAtLeast(held: number | undefined, announced: number | undefined) {
  return held !== undefined && announced !== undefined && held >= announced;
}

// The tab list reloads for any workspace of the branch, since a new one may
// belong in it.
export function workspaceListFilter(scope: RealtimeScope): InvalidateQueryFilters {
  const workspaces = posWorkspacesKey(scope.generation, scope.storeId);
  return {
    queryKey: workspaces,
    predicate: (query) => query.queryKey[workspaces.length] !== 'selected',
  };
}

// A list on screen still marked stale after its refresh settled: a local
// mutation cancels workspace reads in flight, so the event's read was dropped.
// A failed read is left to its own retries.
export function unreadWorkspaceListFilter(scope: RealtimeScope): InvalidateQueryFilters {
  const list = workspaceListFilter(scope);
  return {
    ...list,
    predicate: (query) =>
      (list.predicate?.(query) ?? true) &&
      query.isActive() &&
      query.state.isInvalidated &&
      query.state.status === 'success',
  };
}

// A selected tab reloads only for its own workspace, and only while what it
// holds is older than the event, which spares the tab that made the change.
// A lease claim leaves the revision alone, so both counters have to be current.
export function selectedWorkspaceFilter(
  event: RealtimeEvent,
  scope: RealtimeScope,
): InvalidateQueryFilters {
  const workspaces = posWorkspacesKey(scope.generation, scope.storeId);
  return {
    queryKey: workspaces,
    predicate: (query) => {
      if (query.queryKey[workspaces.length] !== 'selected') return false;
      if (query.queryKey.at(-1) !== event.id) return false;
      const held = (
        query.state.data as { data?: { revision?: number; lease_generation?: number } } | undefined
      )?.data;
      return !(
        isAtLeast(held?.revision, event.revision) &&
        isAtLeast(held?.lease_generation, event.lease_generation)
      );
    },
  };
}

// What else an event makes stale, beyond the workspace list and selected tab.
export function invalidationsFor(
  event: RealtimeEvent,
  scope: RealtimeScope,
): InvalidateQueryFilters[] {
  // The floor's table states are computed from the open orders of the branch.
  const board = { queryKey: resourceBoardKey(scope.generation) };
  switch (event.event) {
    case 'workspace.updated':
      return [{ queryKey: ['pos', 'workspace-credit', scope.generation, event.id] }, board];
    // A table asked for the bill.
    case 'payment.requested':
      return [board];
    // A granted reprint approval shows on the print queue's pre-bills.
    case 'approval.requested':
      return [
        { queryKey: ['pos', 'approvals', scope.generation] },
        { queryKey: ['pos', 'print-jobs', scope.generation] },
      ];
    case 'print_job.created':
      return [{ queryKey: ['pos', 'print-jobs', scope.generation] }];
    // The menu of the branch: sold-out marks show on the tiles at once.
    case 'menu.sold_out':
      return [{ queryKey: ['pos', 'menu', scope.generation] }];
    // A ticket sent or worked in the kitchen: the order's kitchen history and
    // the counter's pickup queue.
    case 'kitchen_ticket.updated':
      return [
        { queryKey: ['pos', 'kitchen-tickets', scope.generation] },
        { queryKey: ['pos', 'kitchen-orders', scope.generation] },
      ];
    // Guests' orders and requests from the table QR: the counter's tray.
    case 'guest_order.created':
    case 'guest_order.updated':
    case 'guest_request.created':
    case 'guest_request.updated':
      return [
        { queryKey: ['pos', 'guest-orders', scope.generation] },
        { queryKey: ['pos', 'guest-requests', scope.generation] },
      ];
    // Claims, prints and cancels of a job; other resources (tables among
    // them) announce through this event too and concern the floor instead.
    case 'resource.updated':
      return event.id.startsWith('posprintjob_')
        ? [{ queryKey: ['pos', 'print-jobs', scope.generation] }]
        : // A booking announces each table it holds.
          [board, { queryKey: ['pos', 'reservations', scope.generation] }];
    default:
      return [];
  }
}

function isRealtimeEvent(data: unknown): data is RealtimeEvent {
  const value = data as Partial<RealtimeEvent> | null;
  return typeof value?.event === 'string' && typeof value.id === 'string';
}

function createStatusStore() {
  let status: RealtimeStatus = 'offline';
  const listeners = new Set<() => void>();
  return {
    get: () => status,
    set(next: RealtimeStatus) {
      if (next === status) return;
      status = next;
      listeners.forEach((listener) => {
        listener();
      });
    },
    subscribe(listener: () => void) {
      listeners.add(listener);
      return () => {
        listeners.delete(listener);
      };
    },
  };
}

export const realtimeStatus = createStatusStore();

// Opens the branch stream and keeps it open until the returned function runs.
// Every attempt is a new consumer with a current token: Action Cable's own
// monitor would reconnect with the URL it started with, whose short-lived JWT
// has expired by then. A rejected subscription is final; polling carries on.
// `onConnected` runs on every confirmed subscription, the first included:
// anything read before the stream opened may have missed an event.
export function openBranchStream(options: {
  branchId: string;
  token: () => Promise<string>;
  onEvent: (event: RealtimeEvent) => void;
  onConnected: () => void;
  onStatus: (status: RealtimeStatus) => void;
  connect?: (url: string) => Consumer;
}) {
  const connect = options.connect ?? createConsumer;
  let closed = false;
  let attempt = 0;
  let consumer: Consumer | null = null;
  let retryTimer: ReturnType<typeof setTimeout> | undefined;
  let connectTimer: ReturnType<typeof setTimeout> | undefined;

  function teardown() {
    clearTimeout(connectTimer);
    clearTimeout(retryTimer);
    consumer?.disconnect();
    consumer = null;
  }

  function retry() {
    teardown();
    if (closed) return;
    options.onStatus('offline');
    retryTimer = setTimeout(() => void open(), backoffMs(attempt));
    attempt += 1;
  }

  async function open() {
    options.onStatus('connecting');
    let token: string;
    try {
      token = await options.token();
    } catch {
      retry();
      return;
    }
    if (closed) return;
    const current = connect(`/cable?token=${encodeURIComponent(token)}`);
    consumer = current;
    // The library's reopen schedules a timer that `disconnect` cannot cancel,
    // which would revive a consumer given up on. Stale sockets retry here.
    (current as unknown as { connection: { reopen: () => void } }).connection.reopen = () => {
      if (consumer === current) retry();
    };
    connectTimer = setTimeout(retry, CONNECT_TIMEOUT_MS);
    // A socket still connecting cannot be closed, so one abandoned meanwhile
    // is closed here, as soon as the server answers it.
    const abandoned = () => {
      if (consumer === current) return false;
      current.disconnect();
      return true;
    };
    current.subscriptions.create(
      { channel: CHANNEL, branch_id: options.branchId },
      {
        connected() {
          if (abandoned()) return;
          clearTimeout(connectTimer);
          attempt = 0;
          options.onStatus('connected');
          options.onConnected();
        },
        disconnected() {
          if (consumer === current) retry();
        },
        rejected() {
          if (abandoned()) return;
          teardown();
          options.onStatus('offline');
        },
        received(data: unknown) {
          if (consumer === current && isRealtimeEvent(data)) options.onEvent(data);
        },
      },
    );
  }

  void open();
  return () => {
    closed = true;
    teardown();
  };
}
