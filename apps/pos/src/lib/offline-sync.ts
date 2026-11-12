import { ingestBody, offlineKey } from './offline-sales';
import { emitOfflineChanged, offlineDb, type QueuedSale, queuedSales } from './offline-store';
import { conflictReason, failureStatus } from './request-failure';

// Sends the offline sales of a cashier to the server one at a time, oldest
// first, each under its own key `offline:<id>`: a reply lost on the way is
// answered from the same receipt next time, so a sale is never charged
// twice. The server prices it again and completes it or holds it for
// review; either way it has the sale, and this browser forgets it. A sale the
// server refuses for good stays here, marked, until it is sent again.

type Request = <T>(
  method: string,
  path: string,
  options?: { body?: unknown; idempotencyKey?: string },
) => Promise<T>;

export type OfflineSaleResult = {
  id: string;
  offline_id: string;
  provisional_number: string;
  status: 'completed' | 'needs_review' | 'rejected';
  review_reason: string | null;
  order_number: string | null;
};

export type SyncOutcome = {
  completed: number;
  review: number;
  failed: number;
  // Why the pass stopped before the end: no network, signed out, or the
  // server asked to wait. The sales left are sent on the next pass.
  stopped: 'network' | 'unauthorized' | 'retry' | null;
};

// Refusals the server may answer differently later: wait and send again.
const TRANSIENT_REASONS = new Set(['command_in_progress', 'lease_busy']);

function transient(error: unknown) {
  const status = failureStatus(error);
  if (status === undefined || status === 408 || status === 429 || status >= 500) return true;
  return TRANSIENT_REASONS.has(conflictReason(error) ?? '');
}

function errorLabel(error: unknown) {
  const status = failureStatus(error);
  const reason = conflictReason(error);
  return reason ? `${status}:${reason}` : String(status ?? 'network');
}

async function withLock<T>(run: () => Promise<T>): Promise<T> {
  // One pass per browser: two tabs never send the same sale at once.
  const locks = globalThis.navigator?.locks;
  if (locks) return locks.request('parkviet-pos-offline-sync', () => run());
  return run();
}

let running: Promise<SyncOutcome> | null = null;

export function syncOfflineSales(options: {
  request: Request;
  staffId: string;
  storeId: string;
  // `failed` sales are sent again only when the cashier asks.
  retryFailed?: boolean;
  now?: () => Date;
}): Promise<SyncOutcome> {
  running ??= withLock(() => pass(options)).finally(() => {
    running = null;
  });
  return running;
}

async function pass(options: {
  request: Request;
  staffId: string;
  storeId: string;
  retryFailed?: boolean;
  now?: () => Date;
}): Promise<SyncOutcome> {
  const outcome: SyncOutcome = { completed: 0, review: 0, failed: 0, stopped: null };
  const now = options.now ?? (() => new Date());
  const db = offlineDb();
  const sales = await queuedSales(options.staffId, options.storeId);
  try {
    for (const sale of sales) {
      if (sale.status === 'failed' && !options.retryFailed) {
        outcome.failed++;
        continue;
      }
      try {
        const result = await options.request<{ data: OfflineSaleResult }>(
          'POST',
          '/pos/offline_sales',
          { body: ingestBody(sale, now()), idempotencyKey: offlineKey(sale.offlineId) },
        );
        await db.deleteSale(sale.offlineId);
        if (result.data.status === 'completed') outcome.completed++;
        else outcome.review++;
      } catch (error) {
        const status = failureStatus(error);
        if (status === 401) {
          outcome.stopped = 'unauthorized';
          break;
        }
        if (transient(error)) {
          outcome.stopped = status === undefined ? 'network' : 'retry';
          break;
        }
        const failed: QueuedSale = {
          ...sale,
          status: 'failed',
          attempts: sale.attempts + 1,
          lastError: errorLabel(error),
        };
        await db.putSale(failed);
        outcome.failed++;
      }
    }
  } finally {
    emitOfflineChanged();
  }
  return outcome;
}
