import { describe, expect, it, vi } from 'vitest';
import { createScannerQueue, type ScanIntent, shouldCaptureScannerKey } from './scanner-queue';

async function flush() {
  await new Promise((resolve) => setTimeout(resolve, 0));
}

describe('scanner intents', () => {
  it('preserves 100 physical scans in order and binds each to its original workspace', async () => {
    const sent: ScanIntent[] = [];
    let release: (() => void) | undefined;
    const first = new Promise<void>((resolve) => {
      release = resolve;
    });
    let key = 0;
    const queue = createScannerQueue(
      async (intent) => {
        sent.push(intent);
        if (intent.workspaceId === 'a' && intent.sequence === 1) await first;
        return 'applied';
      },
      () => `key-${++key}`,
    );
    for (let i = 0; i < 100; i++) queue.enqueue('a', 'same-barcode');
    queue.enqueue('b', 'other');
    await flush();
    expect(sent.map((item) => item.workspaceId)).toEqual(['a', 'b']);
    release?.();
    await flush();
    const scans = sent.filter((item) => item.workspaceId === 'a');
    expect(scans.map((item) => item.sequence)).toEqual(
      Array.from({ length: 100 }, (_, i) => i + 1),
    );
    expect(new Set(scans.map((item) => item.idempotencyKey)).size).toBe(100);
    expect(queue.snapshot('a').pending).toHaveLength(0);
  });

  it('blocks later scans on an unknown outcome and retries the identical intent', async () => {
    const send = vi.fn().mockRejectedValueOnce(new Error('timeout')).mockResolvedValue('applied');
    const queue = createScannerQueue(send, () => 'key');
    const first = queue.enqueue('a', 'one');
    queue.enqueue('a', 'two');
    await flush();
    expect(queue.snapshot('a').blocked).toBe(true);
    expect(send).toHaveBeenCalledTimes(1);
    expect(queue.resolve('a', first.sequence + 1, 'applied')).toBe(false);
    queue.retry('a');
    await flush();
    expect(send).toHaveBeenCalledTimes(3);
    expect(send.mock.calls[1][0]).toBe(first);
    expect(queue.snapshot('a').pending).toHaveLength(0);
  });

  it('continues after an authoritative reconciliation without resending the head', async () => {
    const send = vi.fn().mockResolvedValueOnce('unknown').mockResolvedValue('applied');
    const queue = createScannerQueue(send, () => 'key');
    const first = queue.enqueue('a', 'one');
    queue.enqueue('a', 'two');
    await flush();
    expect(queue.resolve('a', first.sequence, 'applied')).toBe(true);
    await flush();
    expect(send).toHaveBeenCalledTimes(2);
    expect(send.mock.calls[1][0].barcode).toBe('two');
  });
});

describe('scanner keyboard exclusions', () => {
  it('does not capture composition, editable fields or browser shortcuts', () => {
    class Element {
      isContentEditable = false;
      constructor(private editable: boolean) {}
      matches() {
        return this.editable;
      }
    }
    vi.stubGlobal('HTMLElement', Element);
    try {
      const event = (changes: Record<string, unknown> = {}) =>
        ({
          isComposing: false,
          keyCode: 0,
          ctrlKey: false,
          altKey: false,
          metaKey: false,
          composedPath: () => [new Element(false)],
          ...changes,
        }) as unknown as KeyboardEvent;
      expect(shouldCaptureScannerKey(event())).toBe(true);
      expect(shouldCaptureScannerKey(event({ isComposing: true }))).toBe(false);
      expect(shouldCaptureScannerKey(event({ keyCode: 229 }))).toBe(false);
      expect(shouldCaptureScannerKey(event({ ctrlKey: true }))).toBe(false);
      expect(shouldCaptureScannerKey(event({ composedPath: () => [new Element(true)] }))).toBe(
        false,
      );
    } finally {
      vi.unstubAllGlobals();
    }
  });
});
