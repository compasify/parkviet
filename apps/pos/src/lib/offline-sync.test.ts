import { afterEach, describe, expect, it, vi } from 'vitest';
import { createMemoryOfflineDb, type QueuedSale, queuedSales, setOfflineDb } from './offline-store';
import { syncOfflineSales } from './offline-sync';

afterEach(() => {
  setOfflineDb(null);
});

function sale(id: string, soldAt: string, staffId = 'staff_1'): QueuedSale {
  return {
    offlineId: id,
    staffId,
    storeId: 'store_1',
    branchId: 'posbranch_1',
    registerId: 'posreg_1',
    shiftId: 'posshift_1',
    provisionalNumber: `OFF-Q1-261112-${id}`,
    soldAt,
    total: '30000.00',
    handedAmount: '50000',
    currency: 'VND',
    lines: [
      {
        variant_id: 'variant_tea',
        quantity: 1,
        modifiers: [],
        note: null,
        name: 'Trà',
        unit_price: '30000.00',
      },
    ],
    status: 'pending',
    attempts: 0,
    lastError: null,
    savedAt: 1,
  };
}

async function seed(...sales: QueuedSale[]) {
  const db = createMemoryOfflineDb();
  setOfflineDb(db);
  for (const row of sales) await db.putSale(row);
  return db;
}

const answer = (status: 'completed' | 'needs_review') => ({
  data: {
    id: 'posoffline_1',
    offline_id: 'x',
    provisional_number: 'x',
    status,
    review_reason: null,
    order_number: null,
  },
});
const failure = (status?: number, reason?: string) =>
  Object.assign(
    new Error('failed'),
    status === undefined ? {} : { status, details: reason ? { reason } : {} },
  );

describe('offline sync', () => {
  it('sends the sales of the cashier oldest first, each under its own offline key', async () => {
    await seed(
      sale('002', '2026-11-12T09:10:00Z'),
      sale('001', '2026-11-12T09:00:00Z'),
      sale('003', '2026-11-12T09:20:00Z', 'staff_2'),
    );
    const request = vi
      .fn()
      .mockResolvedValueOnce(answer('completed'))
      .mockResolvedValueOnce(answer('needs_review'));

    const outcome = await syncOfflineSales({ request, staffId: 'staff_1', storeId: 'store_1' });

    expect(outcome).toEqual({ completed: 1, review: 1, failed: 0, stopped: null });
    expect(request.mock.calls.map((call) => call[2].idempotencyKey)).toEqual([
      'offline:001',
      'offline:002',
    ]);
    expect(request.mock.calls[0]?.[0]).toBe('POST');
    expect(request.mock.calls[0]?.[1]).toBe('/pos/offline_sales');
    // The server holds both now; another cashier's sale waits for them.
    expect(await queuedSales('staff_1', 'store_1')).toEqual([]);
    expect(await queuedSales('staff_2', 'store_1')).toHaveLength(1);
  });

  it('keeps a sale whose reply was lost and sends it again under the same key', async () => {
    await seed(sale('001', '2026-11-12T09:00:00Z'), sale('002', '2026-11-12T09:10:00Z'));
    const request = vi.fn().mockRejectedValueOnce(failure());

    const first = await syncOfflineSales({ request, staffId: 'staff_1', storeId: 'store_1' });
    expect(first.stopped).toBe('network');
    expect(request).toHaveBeenCalledTimes(1);
    expect(await queuedSales('staff_1', 'store_1')).toHaveLength(2);

    request.mockReset().mockResolvedValue(answer('completed'));
    await syncOfflineSales({ request, staffId: 'staff_1', storeId: 'store_1' });
    expect(request.mock.calls.map((call) => call[2].idempotencyKey)).toEqual([
      'offline:001',
      'offline:002',
    ]);
    expect(await queuedSales('staff_1', 'store_1')).toEqual([]);
  });

  it('stops for a sign-in or a busy server and leaves the queue as it was', async () => {
    await seed(sale('001', '2026-11-12T09:00:00Z'));
    for (const [error, stopped] of [
      [failure(401), 'unauthorized'],
      [failure(503), 'retry'],
      [failure(409, 'command_in_progress'), 'retry'],
    ] as const) {
      const request = vi.fn().mockRejectedValue(error);
      const outcome = await syncOfflineSales({ request, staffId: 'staff_1', storeId: 'store_1' });
      expect(outcome.stopped).toBe(stopped);
      expect((await queuedSales('staff_1', 'store_1'))[0]?.status).toBe('pending');
    }
  });

  it('marks a sale the server refuses for good, keeps it and goes on with the next', async () => {
    await seed(sale('001', '2026-11-12T09:00:00Z'), sale('002', '2026-11-12T09:10:00Z'));
    const request = vi
      .fn()
      .mockRejectedValueOnce(failure(409, 'offline_sale_invalid'))
      .mockResolvedValueOnce(answer('completed'));

    const outcome = await syncOfflineSales({ request, staffId: 'staff_1', storeId: 'store_1' });

    expect(outcome).toEqual({ completed: 1, review: 0, failed: 1, stopped: null });
    const [kept] = await queuedSales('staff_1', 'store_1');
    expect(kept).toMatchObject({
      offlineId: '001',
      status: 'failed',
      attempts: 1,
      lastError: '409:offline_sale_invalid',
    });

    // Not sent again on its own; only when the cashier asks.
    const again = vi.fn().mockResolvedValue(answer('completed'));
    await syncOfflineSales({ request: again, staffId: 'staff_1', storeId: 'store_1' });
    expect(again).not.toHaveBeenCalled();
    await syncOfflineSales({
      request: again,
      staffId: 'staff_1',
      storeId: 'store_1',
      retryFailed: true,
    });
    expect(again.mock.calls[0]?.[2].idempotencyKey).toBe('offline:001');
    expect(await queuedSales('staff_1', 'store_1')).toEqual([]);
  });

  it('runs one pass at a time', async () => {
    await seed(sale('001', '2026-11-12T09:00:00Z'));
    let release: (value: unknown) => void = () => undefined;
    const request = vi.fn().mockReturnValue(
      new Promise((resolve) => {
        release = resolve;
      }),
    );
    const first = syncOfflineSales({ request, staffId: 'staff_1', storeId: 'store_1' });
    const second = syncOfflineSales({ request, staffId: 'staff_1', storeId: 'store_1' });
    expect(second).toBe(first);
    release(answer('completed'));
    await first;
    expect(request).toHaveBeenCalledTimes(1);
  });
});
