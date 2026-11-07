import { describe, expect, it } from 'vitest';
import { createWorkspaceSerializer, isNewerWorkspace } from './workspace-serializer';

type W = { id: string; revision: number; lease_generation: number };

describe('workspace command serializer', () => {
  it('runs commands one at a time, each from the revision the previous one returned', async () => {
    const pending: number[] = [];
    const serializer = createWorkspaceSerializer<W>((_, count) => pending.push(count));
    const seen: number[] = [];
    let running = 0;
    const stale: W = { id: 'a', revision: 1, lease_generation: 1 };
    const results = await Promise.all(
      Array.from({ length: 5 }, () =>
        serializer.run(stale, async (current) => {
          running += 1;
          expect(running).toBe(1);
          seen.push(current.revision);
          await new Promise((resolve) => setTimeout(resolve, 1));
          running -= 1;
          return { ...current, revision: current.revision + 1 };
        }),
      ),
    );
    expect(seen).toEqual([1, 2, 3, 4, 5]);
    expect(results.map((result) => result.revision)).toEqual([2, 3, 4, 5, 6]);
    expect(pending.at(-1)).toBe(0);
    expect(serializer.pending('a')).toBe(0);
  });

  it('continues after a failed command and never regresses to an older snapshot', async () => {
    const serializer = createWorkspaceSerializer<W>();
    const failed = serializer.run({ id: 'a', revision: 3, lease_generation: 1 }, async () => {
      throw new Error('rejected');
    });
    const next = serializer.run({ id: 'a', revision: 2, lease_generation: 1 }, async (current) => ({
      ...current,
    }));
    await expect(failed).rejects.toThrow('rejected');
    expect((await next).revision).toBe(3);
    expect(serializer.latest('a')?.revision).toBe(3);
  });

  it('keeps workspaces independent', async () => {
    const serializer = createWorkspaceSerializer<W>();
    let release: () => void = () => undefined;
    const gate = new Promise<void>((resolve) => {
      release = resolve;
    });
    const slow = serializer.run({ id: 'a', revision: 1, lease_generation: 1 }, async (current) => {
      await gate;
      return current;
    });
    const other = await serializer.run(
      { id: 'b', revision: 7, lease_generation: 1 },
      async (current) => current,
    );
    expect(other.revision).toBe(7);
    expect(serializer.pending('a')).toBe(1);
    release();
    await slow;
  });

  it('orders snapshots by lease generation first, then revision', () => {
    const base = { id: 'a', revision: 5, lease_generation: 1 };
    expect(isNewerWorkspace({ ...base, revision: 6 }, base)).toBe(true);
    expect(isNewerWorkspace({ ...base, revision: 1, lease_generation: 2 }, base)).toBe(true);
    expect(isNewerWorkspace(base, base)).toBe(false);
  });
});
