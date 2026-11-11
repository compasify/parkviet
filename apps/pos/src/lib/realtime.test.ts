import type { Consumer } from '@rails/actioncable';
import { type Query, QueryClient } from '@tanstack/react-query';
import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import {
  backoffMs,
  CONNECT_TIMEOUT_MS,
  CONNECTED_POLL_MS,
  invalidationsFor,
  openBranchStream,
  pollInterval,
  type RealtimeEvent,
  type RealtimeStatus,
  selectedWorkspaceFilter,
  unreadWorkspaceListFilter,
  workspaceListFilter,
} from './realtime';

const scope = { generation: 3, storeId: 'store_1' };

function event(overrides: Partial<RealtimeEvent> = {}): RealtimeEvent {
  return {
    event: 'workspace.updated',
    id: 'ws_1',
    branch_id: 'br_1',
    at: '2026-11-11T00:00:00.000Z',
    refs: {},
    ...overrides,
  };
}

type Filter = ReturnType<typeof workspaceListFilter>;

function matches(filter: Filter, key: readonly unknown[], data?: unknown) {
  const client = new QueryClient();
  const query = client
    .getQueryCache()
    .build(client, { queryKey: [...key], queryFn: () => null }) as unknown as Query;
  if (data !== undefined) query.setData(data);
  const prefix = filter.queryKey as readonly unknown[];
  const inPrefix = prefix.every((part, index) => query.queryKey[index] === part);
  return inPrefix && (filter.predicate?.(query) ?? true);
}

function matched(target: RealtimeEvent, key: readonly unknown[]) {
  return invalidationsFor(target, scope).some((filter) => matches(filter, key));
}

describe('print queue invalidation', () => {
  const queue = ['pos', 'print-jobs', 3, 'br_1'];

  it('refreshes the queue when a job is added, requeued or fails', () => {
    expect(matched(event({ event: 'print_job.created', id: 'posprintjob_1' }), queue)).toBe(true);
  });

  it('refreshes the queue when a job is claimed, printed or canceled', () => {
    expect(matched(event({ event: 'resource.updated', id: 'posprintjob_1' }), queue)).toBe(true);
  });

  it('leaves the queue alone for other resources', () => {
    expect(matched(event({ event: 'resource.updated', id: 'posprinter_1' }), queue)).toBe(false);
  });
});

describe('menu invalidation', () => {
  it('reads the menu again when an item is marked sold out or back on sale', () => {
    const menu = ['pos', 'menu', 3, 'br_1'];
    expect(matched(event({ event: 'menu.sold_out', id: 'posmenuitem_1' }), menu)).toBe(true);
    expect(matched(event({ event: 'print_job.created', id: 'posprintjob_1' }), menu)).toBe(false);
  });
});

const list = ['pos', 'workspaces', 3, 'store_1', 'br_1', null, 1];
const selected = (id: string) => ['pos', 'workspaces', 3, 'store_1', 'selected', 'br_1', null, id];

describe('workspaceListFilter', () => {
  it('matches the tab list and no selected tab', () => {
    expect(matches(workspaceListFilter(scope), list)).toBe(true);
    expect(matches(workspaceListFilter(scope), selected('ws_1'))).toBe(false);
  });

  it('never touches another session generation', () => {
    expect(matches(workspaceListFilter(scope), ['pos', 'workspaces', 2, 'store_1', 'br_1'])).toBe(
      false,
    );
  });
});

describe('unreadWorkspaceListFilter', () => {
  function listQuery(state: Partial<Query['state']>, active = true) {
    const client = new QueryClient();
    const query = client
      .getQueryCache()
      .build(client, { queryKey: list, queryFn: () => null }) as unknown as Query;
    query.setState({ ...query.state, status: 'success', ...state });
    vi.spyOn(query, 'isActive').mockReturnValue(active);
    return query;
  }
  const unread = (query: Query) => unreadWorkspaceListFilter(scope).predicate?.(query);

  it('finds a list on screen whose read was dropped', () => {
    expect(unread(listQuery({ isInvalidated: true }))).toBe(true);
  });

  it('ignores a current list, one off screen, and a failed read', () => {
    expect(unread(listQuery({ isInvalidated: false }))).toBe(false);
    expect(unread(listQuery({ isInvalidated: true }, false))).toBe(false);
    expect(unread(listQuery({ isInvalidated: true, status: 'error' }))).toBe(false);
  });
});

describe('selectedWorkspaceFilter', () => {
  const filter = selectedWorkspaceFilter(event({ revision: 5, lease_generation: 2 }), scope);
  const held = (revision: number, lease_generation = 2) => ({
    data: { revision, lease_generation },
  });

  it('reloads the matching tab while it holds an older revision', () => {
    expect(matches(filter, selected('ws_1'), held(4))).toBe(true);
  });

  it('skips a tab already at or past the event revision', () => {
    expect(matches(filter, selected('ws_1'), held(5))).toBe(false);
    expect(matches(filter, selected('ws_1'), held(6))).toBe(false);
  });

  it('reloads a tab when only the lease moved, so it learns it lost the draft', () => {
    expect(matches(filter, selected('ws_1'), held(5, 1))).toBe(true);
  });

  it('reloads a tab that holds nothing yet', () => {
    expect(matches(filter, selected('ws_1'))).toBe(true);
  });

  it('reloads when the event carries no revision', () => {
    expect(matches(selectedWorkspaceFilter(event(), scope), selected('ws_1'), held(9))).toBe(true);
  });

  it('leaves another selected tab and the list alone', () => {
    expect(matches(filter, selected('ws_2'), held(1))).toBe(false);
    expect(matches(filter, list)).toBe(false);
  });
});

describe('invalidationsFor', () => {
  it('reloads the credit state of that workspace, at any revision', () => {
    expect(matched(event(), ['pos', 'workspace-credit', 3, 'ws_1', 7])).toBe(true);
    expect(matched(event(), ['pos', 'workspace-credit', 3, 'ws_2', 7])).toBe(false);
  });

  it('reloads the print queue on approval.requested, for a granted reprint', () => {
    expect(matched(event({ event: 'approval.requested' }), ['pos', 'print-jobs', 3, 'br_1'])).toBe(
      true,
    );
  });

  it('reloads approvals on approval.requested', () => {
    expect(matched(event({ event: 'approval.requested' }), ['pos', 'approvals', 3, 'br_1'])).toBe(
      true,
    );
    expect(matched(event({ event: 'approval.requested' }), list)).toBe(false);
  });

  it('reloads the floor when a table, an order or a bill request changes', () => {
    const board = ['pos', 'resource-board', 3, 'br_1'];
    expect(matched(event(), board)).toBe(true);
    expect(matched(event({ event: 'resource.updated', id: 'posres_1' }), board)).toBe(true);
    expect(matched(event({ event: 'payment.requested' }), board)).toBe(true);
    expect(matched(event({ event: 'resource.updated', id: 'posprintjob_1' }), board)).toBe(false);
    expect(matched(event({ event: 'menu.sold_out' }), board)).toBe(false);
  });

  it('ignores an event this build does not know', () => {
    expect(invalidationsFor(event({ event: 'table.moved' }), scope)).toEqual([]);
  });
});

describe('pollInterval', () => {
  it('stretches only while the socket is confirmed open', () => {
    expect(pollInterval('connected', 5000)).toBe(CONNECTED_POLL_MS);
    expect(pollInterval('connecting', 5000)).toBe(5000);
    expect(pollInterval('offline', 5000)).toBe(5000);
  });
});

describe('backoffMs', () => {
  it('doubles up to a ceiling', () => {
    expect([0, 1, 2].map((attempt) => backoffMs(attempt, () => 1))).toEqual([1000, 2000, 4000]);
    expect(backoffMs(20, () => 1)).toBe(60_000);
  });

  it('spreads retries over the upper half of the delay', () => {
    expect(backoffMs(2, () => 0)).toBe(2000);
    expect(backoffMs(2, () => 0.5)).toBe(3000);
  });
});

type Mixin = {
  connected: () => void;
  disconnected: () => void;
  rejected: () => void;
  received: (data: unknown) => void;
};

function harness(tokenSource?: () => Promise<string>) {
  const consumers: {
    url: string;
    mixin: Mixin;
    params: unknown;
    disconnect: ReturnType<typeof vi.fn>;
    connection: { reopen?: () => void };
  }[] = [];
  const statuses: RealtimeStatus[] = [];
  const events: RealtimeEvent[] = [];
  const onConnected = vi.fn();
  const token = vi.fn(tokenSource ?? (async () => `jwt ${consumers.length}`));
  const close = openBranchStream({
    branchId: 'br_1',
    token,
    onEvent: (value) => events.push(value),
    onConnected,
    onStatus: (value) => statuses.push(value),
    connect: (url) => {
      const entry = {
        url,
        mixin: {} as Mixin,
        params: null as unknown,
        disconnect: vi.fn(),
        connection: {} as { reopen?: () => void },
      };
      consumers.push(entry);
      return {
        disconnect: entry.disconnect,
        connection: entry.connection,
        subscriptions: {
          create(params: unknown, mixin: Mixin) {
            entry.params = params;
            entry.mixin = mixin;
          },
        },
      } as unknown as Consumer;
    },
  });
  return { consumers, statuses, events, onConnected, token, close };
}

describe('openBranchStream', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    vi.spyOn(Math, 'random').mockReturnValue(1);
  });
  afterEach(() => {
    vi.restoreAllMocks();
    vi.useRealTimers();
  });

  const settle = () => vi.advanceTimersByTimeAsync(0);

  it('subscribes to the branch with an encoded token and reports connected', async () => {
    const stream = harness();
    expect(stream.statuses).toEqual(['connecting']);
    await settle();

    expect(stream.consumers[0]?.url).toBe('/cable?token=jwt%200');
    expect(stream.consumers[0]?.params).toEqual({
      channel: 'Spree::Pos::BranchChannel',
      branch_id: 'br_1',
    });
    stream.consumers[0]?.mixin.connected();
    expect(stream.statuses).toEqual(['connecting', 'connected']);
    expect(stream.onConnected).toHaveBeenCalledTimes(1);
    stream.close();
  });

  it('passes events on and drops anything else', async () => {
    const stream = harness();
    await settle();
    stream.consumers[0]?.mixin.received(event());
    stream.consumers[0]?.mixin.received({ nonsense: true });
    expect(stream.events).toHaveLength(1);
    stream.close();
  });

  it('reconnects with a new consumer and a new token, then reports each connection', async () => {
    const stream = harness();
    await settle();
    stream.consumers[0]?.mixin.connected();
    stream.consumers[0]?.mixin.disconnected();

    expect(stream.statuses.at(-1)).toBe('offline');
    expect(stream.consumers[0]?.disconnect).toHaveBeenCalled();
    await vi.advanceTimersByTimeAsync(backoffMs(0));

    expect(stream.token).toHaveBeenCalledTimes(2);
    expect(stream.consumers).toHaveLength(2);
    stream.consumers[1]?.mixin.connected();
    expect(stream.onConnected).toHaveBeenCalledTimes(2);
    stream.close();
  });

  it('gives up on a socket that never answers and backs off further each time', async () => {
    const stream = harness();
    await settle();
    await vi.advanceTimersByTimeAsync(CONNECT_TIMEOUT_MS);
    expect(stream.statuses.at(-1)).toBe('offline');

    await vi.advanceTimersByTimeAsync(backoffMs(0));
    expect(stream.consumers).toHaveLength(2);
    await vi.advanceTimersByTimeAsync(CONNECT_TIMEOUT_MS);
    await vi.advanceTimersByTimeAsync(backoffMs(0));
    expect(stream.consumers).toHaveLength(2);
    await vi.advanceTimersByTimeAsync(backoffMs(1) - backoffMs(0));
    expect(stream.consumers).toHaveLength(3);
    stream.close();
  });

  it('retries when no token can be had', async () => {
    const stream = harness(
      vi.fn().mockRejectedValueOnce(new Error('offline')).mockResolvedValue('jwt'),
    );
    await settle();
    expect(stream.statuses).toEqual(['connecting', 'offline']);
    expect(stream.consumers).toHaveLength(0);

    await vi.advanceTimersByTimeAsync(backoffMs(0));
    expect(stream.consumers).toHaveLength(1);
    stream.close();
  });

  it('stops for good when the subscription is rejected', async () => {
    const stream = harness();
    await settle();
    stream.consumers[0]?.mixin.rejected();

    expect(stream.statuses.at(-1)).toBe('offline');
    await vi.advanceTimersByTimeAsync(10 * 60_000);
    expect(stream.consumers).toHaveLength(1);
  });

  it('closes a socket abandoned while it was still connecting', async () => {
    const stream = harness();
    await settle();
    const first = stream.consumers[0];
    stream.close();
    first?.disconnect.mockClear();

    first?.mixin.connected();

    expect(first?.disconnect).toHaveBeenCalledTimes(1);
    expect(stream.statuses).not.toContain('connected');
  });

  it('routes a stale socket through a new consumer instead of the library reopen', async () => {
    const stream = harness();
    await settle();
    stream.consumers[0]?.mixin.connected();

    stream.consumers[0]?.connection.reopen?.();
    expect(stream.consumers[0]?.disconnect).toHaveBeenCalled();
    await vi.advanceTimersByTimeAsync(backoffMs(0));

    expect(stream.consumers).toHaveLength(2);
    expect(stream.token).toHaveBeenCalledTimes(2);
    stream.close();
  });

  it('cannot be revived by a reopen after it was given up on', async () => {
    const stream = harness();
    await settle();
    const first = stream.consumers[0];
    stream.close();
    first?.disconnect.mockClear();

    first?.connection.reopen?.();
    await vi.advanceTimersByTimeAsync(10 * 60_000);

    expect(stream.consumers).toHaveLength(1);
    expect(first?.disconnect).not.toHaveBeenCalled();
  });

  it('opens nothing once closed while waiting for a token', async () => {
    const stream = harness();
    stream.close();
    await settle();
    expect(stream.consumers).toHaveLength(0);
  });
});
