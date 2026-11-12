import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useCallback, useEffect, useState, useSyncExternalStore } from 'react';
import { session } from '../lib/app-session';
import { connectivity } from '../lib/connectivity';
import {
  emitOfflineChanged,
  OFFLINE_CHANGED,
  type OfflineSaleLine,
  type OfflineSnapshot,
  offlineDb,
  type QueuedSale,
  queuedSales,
  type StoredSnapshot,
} from '../lib/offline-store';
import { type SyncOutcome, syncOfflineSales } from '../lib/offline-sync';
import { failureStatus } from '../lib/request-failure';
import { useSession } from './use-session';

// How often the counter refreshes what it would sell offline from.
export const SNAPSHOT_REFRESH_MS = 10 * 60 * 1000;
// How often sales left in the queue are sent again while the server answers.
export const SYNC_RETRY_MS = 30_000;
const REVIEW_POLL_MS = 120_000;

export function useConnectivity() {
  return useSyncExternalStore(connectivity.subscribe, connectivity.getSnapshot);
}

// Re-reads on every change of the offline store, in this tab or another.
function useOfflineVersion() {
  const [version, setVersion] = useState(0);
  useEffect(() => {
    const bump = () => setVersion((value) => value + 1);
    window.addEventListener(OFFLINE_CHANGED, bump);
    // Another tab may have sold or sent sales meanwhile.
    window.addEventListener('focus', bump);
    return () => {
      window.removeEventListener(OFFLINE_CHANGED, bump);
      window.removeEventListener('focus', bump);
    };
  }, []);
  return version;
}

export function useStoredSnapshot() {
  const version = useOfflineVersion();
  const [state, setState] = useState<{ loaded: boolean; snapshot: StoredSnapshot | null }>({
    loaded: false,
    snapshot: null,
  });
  useEffect(() => {
    void version;
    let active = true;
    offlineDb()
      .getSnapshot()
      .then(
        (snapshot) => active && setState({ loaded: true, snapshot }),
        () => active && setState({ loaded: true, snapshot: null }),
      );
    return () => {
      active = false;
    };
  }, [version]);
  return state;
}

export type QueueState = { loaded: boolean; sales: QueuedSale[]; unreadable: boolean };

export function useOfflineQueue(staffId: string | null, storeId: string | null): QueueState {
  const version = useOfflineVersion();
  const [state, setState] = useState<QueueState>({ loaded: false, sales: [], unreadable: false });
  useEffect(() => {
    void version;
    let active = true;
    if (!staffId || !storeId) {
      setState({ loaded: true, sales: [], unreadable: false });
      return;
    }
    queuedSales(staffId, storeId).then(
      (sales) => active && setState({ loaded: true, sales, unreadable: false }),
      () => active && setState({ loaded: true, sales: [], unreadable: true }),
    );
    return () => {
      active = false;
    };
  }, [staffId, storeId, version]);
  return state;
}

// Keeps the offline snapshot of the selected register fresh while the
// counter is online: on opening, every ten minutes, when the shift changes
// and when the network comes back. A refusal (no longer allowed to sell
// there) drops the stored snapshot, so nobody sells offline from it.
export function useOfflineSnapshotRefresh(
  registerId: string | null,
  shiftId: string | null,
  enabled: boolean,
) {
  const snapshot = useSession();
  const { online } = useConnectivity();
  const active = enabled && online && snapshot.status === 'authenticated' && Boolean(registerId);
  useEffect(() => {
    void shiftId;
    if (!active || !registerId) return;
    let stopped = false;
    const refresh = async () => {
      try {
        const result = await session.request<{ data: OfflineSnapshot }>(
          'GET',
          '/pos/offline_snapshot',
          { params: { register_id: registerId } },
        );
        if (stopped) return;
        await offlineDb().putSnapshot({ data: result.data, savedAt: Date.now() });
        emitOfflineChanged();
      } catch (error) {
        const status = failureStatus(error);
        if (stopped || (status !== 403 && status !== 404)) return;
        const stored = await offlineDb()
          .getSnapshot()
          .catch(() => null);
        if (stored?.data.register.id === registerId) {
          await offlineDb().putSnapshot(null);
          emitOfflineChanged();
        }
      }
    };
    void refresh();
    const timer = window.setInterval(() => void refresh(), SNAPSHOT_REFRESH_MS);
    return () => {
      stopped = true;
      window.clearInterval(timer);
    };
  }, [active, registerId, shiftId]);
}

// Sends this cashier's offline sales while the server answers: at once, when
// the network comes back and every half minute while some are left.
export function useOfflineSync(staffId: string | null, storeId: string | null) {
  const snapshot = useSession();
  const { online } = useConnectivity();
  const queryClient = useQueryClient();
  const queue = useOfflineQueue(staffId, storeId);
  const [last, setLast] = useState<SyncOutcome | null>(null);
  const [syncing, setSyncing] = useState(false);
  const signedIn = snapshot.status === 'authenticated';
  const pending = queue.sales.filter((sale) => sale.status === 'pending').length;

  const run = useCallback(
    async (retryFailed = false) => {
      if (!staffId || !storeId || !signedIn) return null;
      setSyncing(true);
      try {
        const outcome = await syncOfflineSales({
          request: session.request,
          staffId,
          storeId,
          retryFailed,
        });
        setLast(outcome);
        if (outcome.completed + outcome.review > 0) {
          void queryClient.invalidateQueries({ queryKey: ['pos', 'offline-sales'] });
          void queryClient.invalidateQueries({ queryKey: ['pos', 'context'] });
        }
        return outcome;
      } catch {
        return null;
      } finally {
        setSyncing(false);
      }
    },
    [queryClient, signedIn, staffId, storeId],
  );

  useEffect(() => {
    if (!online || !signedIn || pending === 0) return;
    void run();
    const timer = window.setInterval(() => void run(), SYNC_RETRY_MS);
    return () => window.clearInterval(timer);
  }, [online, pending, run, signedIn]);

  return { queue, last, syncing, run };
}

export type OfflineSaleRecord = {
  id: string;
  offline_id: string;
  provisional_number: string;
  status: 'completed' | 'needs_review' | 'rejected';
  branch_id: string;
  register_id: string;
  shift_id: string;
  staff: { id: string; name: string };
  client_sold_at: string;
  clock_check: boolean;
  clock_skew_seconds: number;
  collected_total: string;
  handed_amount: string;
  currency: string;
  lines: Array<Omit<OfflineSaleLine, 'modifier_names'>>;
  review_reason: string | null;
  review_details: Record<string, unknown>;
  workspace_id: string | null;
  order_number: string | null;
  call_number: number | null;
  current_total: string | null;
  resolution: string | null;
  resolution_note: string | null;
  resolved_at: string | null;
};

export function offlineSalesKey(generation: number, branchId: string | null) {
  return ['pos', 'offline-sales', generation, branchId] as const;
}

// Offline sales of the branch waiting for review (a cashier sees their own).
export function useOfflineReviews(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: offlineSalesKey(snapshot.generation, branchId),
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    refetchInterval: REVIEW_POLL_MS,
    queryFn: async () => {
      const result = await session.request<{ data: OfflineSaleRecord[] }>(
        'GET',
        '/pos/offline_sales',
        { params: { branch_id: branchId ?? undefined } },
      );
      return result.data;
    },
  });
}

export type ResolveInput = {
  saleId: string;
  mode: 'accept_collected' | 'current_price' | 'edited';
  approvalId?: string;
  handedAmount?: string;
  note?: string;
  key: string;
};

export function useOfflineReviewCommands() {
  const queryClient = useQueryClient();
  const settle = () => queryClient.invalidateQueries({ queryKey: ['pos', 'offline-sales'] });
  const resolve = useMutation({
    mutationFn: (input: ResolveInput) =>
      session.request<{ data: OfflineSaleRecord }>(
        'POST',
        `/pos/offline_sales/${encodeURIComponent(input.saleId)}/resolve`,
        {
          body: {
            mode: input.mode,
            approval_id: input.approvalId,
            handed_amount: input.handedAmount,
            note: input.note,
          },
          idempotencyKey: input.key,
        },
      ),
    onSettled: settle,
  });
  const reject = useMutation({
    mutationFn: (input: { saleId: string; reason: string; key: string }) =>
      session.request<{ data: OfflineSaleRecord }>(
        'POST',
        `/pos/offline_sales/${encodeURIComponent(input.saleId)}/reject`,
        { body: { reason: input.reason }, idempotencyKey: input.key },
      ),
    onSettled: settle,
  });
  return { resolve, reject };
}
