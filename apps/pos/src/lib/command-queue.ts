export class CommandConflict extends Error {
  constructor() {
    super('command-conflict');
    this.name = 'CommandConflict';
  }
}

export function commandDigest(body: Record<string, unknown>) {
  const sorted: Record<string, unknown> = {};
  for (const key of Object.keys(body).sort()) sorted[key] = body[key];
  return JSON.stringify(sorted);
}

export function createCommandQueue() {
  const tails = new Map<string, Promise<void>>();
  const sent = new Map<string, { digest: string; promise: Promise<unknown> }>();
  const pending = new Map<string, number>();

  function bump(workspaceId: string, delta: number) {
    const next = (pending.get(workspaceId) ?? 0) + delta;
    if (next <= 0) pending.delete(workspaceId);
    else pending.set(workspaceId, next);
  }

  return {
    enqueue<T>(workspaceId: string, key: string, digest: string, run: () => Promise<T>) {
      const slot = `${workspaceId}\n${key}`;
      const existing = sent.get(slot);
      if (existing) {
        if (existing.digest !== digest) return Promise.reject(new CommandConflict());
        return existing.promise as Promise<T>;
      }
      bump(workspaceId, 1);
      const tail = tails.get(workspaceId) ?? Promise.resolve();
      const next = tail.then(run, run);
      sent.set(slot, { digest, promise: next });
      tails.set(
        workspaceId,
        next.then(
          () => undefined,
          () => undefined,
        ),
      );
      void next.then(
        () => bump(workspaceId, -1),
        () => {
          bump(workspaceId, -1);
          sent.delete(slot);
        },
      );
      return next;
    },
    hasPending(workspaceId?: string) {
      if (workspaceId) return pending.has(workspaceId);
      return pending.size > 0;
    },
  };
}

export const commandQueue = createCommandQueue();
