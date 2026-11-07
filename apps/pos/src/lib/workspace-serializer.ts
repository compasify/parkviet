type Versioned = { id: string; revision: number; lease_generation: number };

export function isNewerWorkspace(candidate: Versioned, current: Versioned): boolean {
  return (
    candidate.lease_generation > current.lease_generation ||
    (candidate.lease_generation === current.lease_generation &&
      candidate.revision > current.revision)
  );
}

// Every write for one workspace runs after the previous one settled and is
// built from the newest workspace the server returned. Without this, two
// commands started from the same render carry the same expected_revision and
// the second one is rejected as stale.
export function createWorkspaceSerializer<W extends Versioned>(
  onPendingChange?: (workspaceId: string, pending: number) => void,
) {
  const latest = new Map<string, W>();
  const tails = new Map<string, Promise<void>>();
  const counts = new Map<string, number>();

  function observe(workspace: W) {
    const current = latest.get(workspace.id);
    if (!current || !isNewerWorkspace(current, workspace)) latest.set(workspace.id, workspace);
  }

  function bump(workspaceId: string, delta: number) {
    const next = (counts.get(workspaceId) ?? 0) + delta;
    if (next <= 0) counts.delete(workspaceId);
    else counts.set(workspaceId, next);
    onPendingChange?.(workspaceId, Math.max(0, next));
  }

  return {
    observe,
    latest(workspaceId: string): W | undefined {
      return latest.get(workspaceId);
    },
    pending(workspaceId: string): number {
      return counts.get(workspaceId) ?? 0;
    },
    run<T extends W | undefined>(workspace: W, action: (current: W) => Promise<T>): Promise<T> {
      observe(workspace);
      const id = workspace.id;
      bump(id, 1);
      const previous = tails.get(id) ?? Promise.resolve();
      const next = previous.then(async () => {
        const result = await action(latest.get(id) ?? workspace);
        if (result) observe(result);
        return result;
      });
      tails.set(
        id,
        next.then(
          () => undefined,
          () => undefined,
        ),
      );
      return next.finally(() => bump(id, -1));
    },
  };
}
