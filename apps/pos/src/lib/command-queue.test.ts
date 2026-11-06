import { describe, expect, it } from 'vitest';
import { CommandConflict, commandDigest, createCommandQueue } from './command-queue';
import { workspaceHint } from './workspace-channel';
import { clearLayout, readLayout, writeLayout } from './workspace-storage';

function deferred<T>() {
  let resolve: (value: T) => void = () => {};
  const promise = new Promise<T>((next) => {
    resolve = next;
  });
  return { promise, resolve };
}

describe('hàng đợi lệnh theo workspace', () => {
  it('runs one workspace at a time and keeps another workspace free', async () => {
    const queue = createCommandQueue();
    const first = deferred<string>();
    const order: string[] = [];
    const leading = queue.enqueue('a', '1', 'd1', () => first.promise);
    const trailing = queue.enqueue('a', '2', 'd2', async () => {
      order.push('second');
      return 'second';
    });
    const other = queue.enqueue('b', '1', 'd1', async () => {
      order.push('other');
      return 'other';
    });
    await expect(other).resolves.toBe('other');
    expect(order).toEqual(['other']);
    expect(queue.hasPending('a')).toBe(true);
    expect(queue.hasPending('b')).toBe(false);
    first.resolve('first');
    await expect(leading).resolves.toBe('first');
    await expect(trailing).resolves.toBe('second');
    expect(queue.hasPending()).toBe(false);
  });

  it('reuses the same key and rejects a different digest', async () => {
    const queue = createCommandQueue();
    let runs = 0;
    const run = () =>
      queue.enqueue('a', 'same', commandDigest({ qty: 1 }), async () => {
        runs += 1;
        return 'once';
      });
    await expect(Promise.all([run(), run()])).resolves.toEqual(['once', 'once']);
    expect(runs).toBe(1);
    await expect(
      queue.enqueue('a', 'same', commandDigest({ qty: 2 }), async () => 'no'),
    ).rejects.toBeInstanceOf(CommandConflict);
  });

  it('allows retry with the same key after a failed request', async () => {
    const queue = createCommandQueue();
    await expect(
      queue.enqueue('a', 'same', 'd', async () => {
        throw new Error('offline');
      }),
    ).rejects.toThrow('offline');
    await expect(queue.enqueue('a', 'same', 'd', async () => 'replayed')).resolves.toBe('replayed');
  });
});

describe('bố cục cục bộ', () => {
  it('stores ids only and drops a record that contains a credential', () => {
    const saved = new Map<string, string>();
    const storage = {
      getItem: (key: string) => saved.get(key) ?? null,
      setItem: (key: string, value: string) => {
        saved.set(key, value);
      },
      removeItem: (key: string) => {
        saved.delete(key);
      },
    };
    writeLayout(
      {
        staffId: 'staff',
        storeId: 'store',
        savedAt: 1_000,
        branchId: 'branch',
        registerId: null,
        openWorkspaceIds: ['ws'],
      },
      storage,
    );
    expect(readLayout('staff', 'store', storage, 1_000)?.openWorkspaceIds).toEqual(['ws']);
    expect(JSON.stringify([...saved.values()])).not.toContain('token');
    saved.set(
      'parkviet-pos-layout',
      JSON.stringify({ staffId: 'staff', storeId: 'store', savedAt: 1_000, token: 'secret' }),
    );
    expect(readLayout('staff', 'store', storage, 1_000)).toBeNull();
    expect(saved.size).toBe(0);
    clearLayout(storage);
  });

  it('does not put a credential on a workspace hint', () => {
    expect(JSON.stringify(workspaceHint('ws_1'))).not.toContain('token');
  });
});
