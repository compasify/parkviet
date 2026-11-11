import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import type { RealtimeEvent } from '../lib/realtime';

type Stream = { onEvent: (event: RealtimeEvent) => void; onConnected: () => void };

const hooks = vi.hoisted(() => ({
  effects: [] as { run: () => unknown; deps: readonly unknown[] }[],
  refs: new Map<number, { current: unknown }>(),
  refIndex: 0,
}));
const client = vi.hoisted(() => ({
  invalidateQueries: vi.fn(async () => undefined),
  isFetching: vi.fn(() => 0),
  findAll: vi.fn((): unknown[] => []),
}));
const stream = vi.hoisted(() => ({
  open: vi.fn(),
  close: vi.fn(),
  latest: null as Stream | null,
}));

vi.mock('react', () => ({
  useEffect: (run: () => unknown, deps: readonly unknown[]) => hooks.effects.push({ run, deps }),
  useRef: (initial: unknown) => {
    const index = hooks.refIndex++;
    if (!hooks.refs.has(index)) hooks.refs.set(index, { current: initial });
    return hooks.refs.get(index);
  },
  useSyncExternalStore: () => 'offline',
}));
vi.mock('@tanstack/react-query', () => {
  const queryClient = {
    invalidateQueries: client.invalidateQueries,
    isFetching: client.isFetching,
    getQueryCache: () => ({ findAll: client.findAll }),
  };
  return { useQueryClient: () => queryClient };
});
vi.mock('./use-session', () => ({
  useSession: () => ({ status: 'authenticated', generation: 3 }),
}));
vi.mock('../lib/app-session', () => ({ session: { socketToken: vi.fn() } }));
vi.mock('../lib/realtime', async (original) => ({
  ...(await original<typeof import('../lib/realtime')>()),
  openBranchStream: (options: Stream) => {
    stream.latest = options;
    stream.open();
    return stream.close;
  },
}));

const { LIST_REFETCH_MS, useBranchEvents } = await import('./use-branch-events');

// Renders the hook once and returns the dependencies of its stream effect.
function render(branchId: string | null, storeId: string | null) {
  hooks.effects.length = 0;
  hooks.refIndex = 0;
  // biome-ignore lint/correctness/useHookAtTopLevel: React is mocked here; this drives the hook directly.
  useBranchEvents(branchId, storeId);
  return hooks.effects;
}

function mount() {
  const effects = render('br_1', 'store_1');
  for (const effect of effects) effect.run();
  if (!stream.latest) throw new Error('stream did not open');
  return stream.latest;
}

const update = (id: string, revision: number): RealtimeEvent => ({
  event: 'workspace.updated',
  id,
  branch_id: 'br_1',
  revision,
  at: '2026-11-11T00:00:00.000Z',
  refs: {},
});

type Call = [{ queryKey?: readonly unknown[]; predicate?: unknown }, { cancelRefetch?: boolean }?];
const calls = () => client.invalidateQueries.mock.calls as unknown as Call[];
const creditCalls = () => calls().filter(([f]) => f.queryKey?.[1] === 'workspace-credit');
const workspaceCalls = () => calls().filter(([f]) => f.queryKey?.[1] === 'workspaces');

describe('useBranchEvents', () => {
  beforeEach(() => {
    vi.useFakeTimers();
    vi.clearAllMocks();
    client.isFetching.mockReturnValue(0);
    client.findAll.mockReturnValue([]);
    hooks.refs.clear();
    stream.latest = null;
  });
  afterEach(() => vi.useRealTimers());

  it('keeps the socket when only the store id changes', () => {
    const before = render('br_1', 'store_1').at(-1)?.deps;
    const blank = render('br_1', null).at(-1)?.deps;
    expect(blank).toEqual(before);
  });

  it('reopens the socket for another branch', () => {
    const before = render('br_1', 'store_1').at(-1)?.deps;
    const other = render('br_2', 'store_1').at(-1)?.deps;
    expect(other).not.toEqual(before);
  });

  it('still names the known store while the store id is blank', async () => {
    const events = mount();
    const [storeEffect] = render('br_1', null);
    storeEffect?.run();

    events.onEvent(update('ws_1', 2));
    await vi.advanceTimersByTimeAsync(150);

    expect(workspaceCalls()[0]?.[0].queryKey).toEqual(['pos', 'workspaces', 3, 'store_1']);
  });

  it('refetches everything on screen each time the stream connects', () => {
    const events = mount();
    events.onConnected();
    events.onConnected();
    expect(client.invalidateQueries).toHaveBeenCalledTimes(2);
    expect(client.invalidateQueries).toHaveBeenCalledWith({ refetchType: 'active' });
  });

  it('reloads the selected tab within the coalesce window, joining a read in flight', async () => {
    const events = mount();
    events.onEvent(update('ws_1', 2));
    await vi.advanceTimersByTimeAsync(150);

    expect(workspaceCalls()).toHaveLength(1);
    expect(workspaceCalls()[0]?.[1]).toEqual({ cancelRefetch: false });
  });

  it('forces one more read when the joined read was older than the event', async () => {
    client.findAll.mockReturnValueOnce([{}]);
    const events = mount();
    events.onEvent(update('ws_1', 2));
    await vi.advanceTimersByTimeAsync(150);

    expect(workspaceCalls()).toHaveLength(2);
    expect(workspaceCalls()[1]?.[1]).toBeUndefined();
  });

  it('refetches the list once for a burst, on the trailing edge', async () => {
    const events = mount();
    for (let revision = 1; revision <= 20; revision += 1)
      events.onEvent(update(`ws_${revision}`, 1));
    await vi.advanceTimersByTimeAsync(LIST_REFETCH_MS - 1);
    const beforeEdge = workspaceCalls().length;
    await vi.advanceTimersByTimeAsync(1);

    const afterEdge = workspaceCalls().slice(beforeEdge);
    expect(afterEdge).toHaveLength(1);
    expect(afterEdge[0]?.[1]).toEqual({ cancelRefetch: false });
  });

  it('waits out a list read already in flight', async () => {
    client.isFetching.mockReturnValueOnce(1);
    const events = mount();
    events.onEvent(update('ws_1', 2));
    await vi.advanceTimersByTimeAsync(LIST_REFETCH_MS);
    const selectedOnly = workspaceCalls().length;
    await vi.advanceTimersByTimeAsync(LIST_REFETCH_MS);

    expect(workspaceCalls()).toHaveLength(selectedOnly + 1);
  });

  it('reads the list again when a local mutation cancelled the read', async () => {
    const events = mount();
    events.onEvent(update('ws_1', 2));
    await vi.advanceTimersByTimeAsync(150);
    client.findAll.mockReturnValueOnce([{}]);
    await vi.advanceTimersByTimeAsync(LIST_REFETCH_MS - 150);
    const afterFirstRead = workspaceCalls().length;

    await vi.advanceTimersByTimeAsync(LIST_REFETCH_MS);

    expect(workspaceCalls()).toHaveLength(afterFirstRead + 1);
  });

  it('stops reading once the list is current', async () => {
    const events = mount();
    events.onEvent(update('ws_1', 2));
    await vi.advanceTimersByTimeAsync(LIST_REFETCH_MS);
    const settled = workspaceCalls().length;

    await vi.advanceTimersByTimeAsync(10 * LIST_REFETCH_MS);

    expect(workspaceCalls()).toHaveLength(settled);
  });

  it('still reloads credit state for the workspace', async () => {
    const events = mount();
    events.onEvent(update('ws_1', 2));
    await vi.advanceTimersByTimeAsync(150);
    expect(creditCalls()).toHaveLength(1);
  });

  it('drops an event of another branch', async () => {
    const events = mount();
    events.onEvent({ ...update('ws_1', 2), branch_id: 'br_2' });
    await vi.advanceTimersByTimeAsync(LIST_REFETCH_MS);
    expect(client.invalidateQueries).not.toHaveBeenCalled();
  });
});
