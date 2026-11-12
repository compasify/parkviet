import { describe, expect, it, vi } from 'vitest';
import { createConnectivity } from './connectivity';

function harness(responses: Array<number | 'fail'>) {
  const timers: Array<() => void> = [];
  const fetcher = vi.fn(async () => {
    const next = responses.shift() ?? 'fail';
    if (next === 'fail') throw new TypeError('Failed to fetch');
    return new Response(null, { status: next });
  });
  const connectivity = createConnectivity({
    probeUrl: 'http://pos.test/api/v3/admin/pos/offline_snapshot',
    fetcher: fetcher as unknown as typeof fetch,
    setTimer: (run, ms) => {
      // Only the slow offline re-check is kept; probe timeouts never fire.
      if (ms > 5_000) timers.push(run);
      return timers.length;
    },
    clearTimer: () => undefined,
  });
  return { connectivity, fetcher, timers };
}

describe('connectivity', () => {
  it('stays online while the server answers, even with a refusal', async () => {
    const { connectivity } = harness([401]);
    expect(await connectivity.check()).toBe(true);
    expect(connectivity.getSnapshot().online).toBe(true);
  });

  it('goes offline after two unanswered asks and back once the server answers', async () => {
    const { connectivity, fetcher, timers } = harness(['fail', 502, 'fail', 200]);
    expect(await connectivity.check()).toBe(false);
    expect(fetcher).toHaveBeenCalledTimes(2);
    expect(connectivity.getSnapshot().online).toBe(false);
    // While offline it asks again on its own.
    expect(timers).toHaveLength(1);
    timers.shift()?.();
    await vi.waitFor(() => expect(connectivity.getSnapshot().online).toBe(true));
  });

  it('a single lost request is not an outage', async () => {
    const { connectivity } = harness(['fail', 200]);
    expect(await connectivity.check()).toBe(true);
  });

  it('the browser losing the network is offline at once', () => {
    const { connectivity, fetcher } = harness([]);
    const listener = vi.fn();
    connectivity.subscribe(listener);
    connectivity.browserOffline();
    expect(connectivity.getSnapshot().online).toBe(false);
    expect(listener).toHaveBeenCalledOnce();
    expect(fetcher).not.toHaveBeenCalled();
  });
});
