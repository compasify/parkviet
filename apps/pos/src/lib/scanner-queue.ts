// This queue is intentionally in-memory. It does not make a scan durable or
// replace the server's idempotency receipt and revision checks.
export type ScanIntent = Readonly<{
  workspaceId: string;
  sequence: number;
  idempotencyKey: string;
  barcode: string;
}>;

export type ScanResult = 'applied' | 'rejected' | 'unknown';

type WorkspaceQueue = {
  nextSequence: number;
  pending: ScanIntent[];
  running: boolean;
  blocked: boolean;
};

export function createScannerQueue(
  send: (intent: ScanIntent) => Promise<ScanResult>,
  newKey: () => string = () => crypto.randomUUID(),
) {
  const workspaces = new Map<string, WorkspaceQueue>();

  function state(workspaceId: string): WorkspaceQueue {
    let queue = workspaces.get(workspaceId);
    if (!queue) {
      queue = { nextSequence: 1, pending: [], running: false, blocked: false };
      workspaces.set(workspaceId, queue);
    }
    return queue;
  }

  async function drain(queue: WorkspaceQueue) {
    if (queue.running || queue.blocked) return;
    queue.running = true;
    try {
      while (queue.pending.length && !queue.blocked) {
        const intent = queue.pending[0];
        let result: ScanResult;
        try {
          result = await send(intent);
        } catch {
          result = 'unknown';
        }
        if (result === 'unknown') queue.blocked = true;
        else queue.pending.shift();
      }
    } finally {
      queue.running = false;
    }
  }

  return {
    enqueue(workspaceId: string, barcode: string): ScanIntent {
      if (!workspaceId || !barcode) throw new Error('workspace and barcode are required');
      const queue = state(workspaceId);
      const intent = Object.freeze({
        workspaceId,
        barcode,
        sequence: queue.nextSequence++,
        idempotencyKey: newKey(),
      });
      queue.pending.push(intent);
      void drain(queue);
      return intent;
    },
    // Retry only the same head intent/key. The caller must first reconcile an
    // unknown outcome or use a server endpoint that safely replays that key.
    retry(workspaceId: string) {
      const queue = workspaces.get(workspaceId);
      if (!queue?.blocked) return;
      queue.blocked = false;
      void drain(queue);
    },
    // Use only after authoritative reconciliation; a timeout is not rejection.
    resolve(workspaceId: string, sequence: number, result: Exclude<ScanResult, 'unknown'>) {
      const queue = workspaces.get(workspaceId);
      if (!queue?.blocked || queue.pending[0]?.sequence !== sequence) return false;
      if (result !== 'applied' && result !== 'rejected') return false;
      queue.pending.shift();
      queue.blocked = false;
      void drain(queue);
      return true;
    },
    snapshot(workspaceId: string) {
      const queue = workspaces.get(workspaceId);
      return { pending: [...(queue?.pending ?? [])], blocked: queue?.blocked ?? false };
    },
  };
}

// Global keyboard capture must not consume text entry or composition events.
export function shouldCaptureScannerKey(event: KeyboardEvent): boolean {
  if (
    event.isComposing ||
    event.keyCode === 229 ||
    event.ctrlKey ||
    event.altKey ||
    event.metaKey
  ) {
    return false;
  }
  return !event.composedPath().some((target) => {
    if (!(target instanceof HTMLElement)) return false;
    return (
      target.isContentEditable ||
      target.matches(
        'input, textarea, select, [role="textbox"], [contenteditable]:not([contenteditable="false"])',
      )
    );
  });
}

export type ScannerKeyEvent = Pick<KeyboardEvent, 'key' | 'timeStamp'>;

// A barcode scanner types a burst of characters followed by Enter. Characters
// arriving slower than a person can type reset the burst, so ordinary keyboard
// use outside text fields never becomes a scan.
export function createScannerKeyBuffer({ maxGapMs = 100, minLength = 3, maxLength = 200 } = {}) {
  let buffer = '';
  let last = Number.NEGATIVE_INFINITY;

  function reset() {
    buffer = '';
    last = Number.NEGATIVE_INFINITY;
  }

  return {
    reset,
    // Returns the scanned code when this keystroke completes a scan.
    push(event: ScannerKeyEvent, capture: boolean): string | null {
      if (!capture) {
        reset();
        return null;
      }
      const gap = event.timeStamp - last;
      if (event.key === 'Enter') {
        const code = buffer;
        const fresh = gap <= maxGapMs;
        reset();
        return fresh && code.length >= minLength ? code : null;
      }
      if (event.key.length !== 1) return null;
      if (gap > maxGapMs || buffer.length >= maxLength) buffer = '';
      buffer += event.key;
      last = event.timeStamp;
      return null;
    },
  };
}
