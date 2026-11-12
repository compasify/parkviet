import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import { normalizeKioskOrders } from '../lib/kiosk-orders';
import { pollInterval } from '../lib/realtime';
import { useRealtimeStatus } from './use-branch-events';
import { useSession } from './use-session';
import { abandonIfNeeded } from './use-tenders';

// Without the branch stream the tray is read again every ten seconds.
export const KIOSK_TRAY_FALLBACK_POLL_MS = 10_000;

export function kioskOrdersKey(generation: number, branchId: string | null) {
  return ['pos', 'kiosk-orders', generation, branchId] as const;
}

// The counter's kiosk tray: orders kiosks left for a cashier.
// `kiosk_order.waiting` and `kiosk.updated` invalidate it through the branch
// stream (lib/realtime). Taking one goes through useWorkspaces, which holds
// the order's lease; canceling an abandoned one is here.
export function useKioskOrders(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  const realtime = useRealtimeStatus();
  const client = useQueryClient();
  const key = kioskOrdersKey(snapshot.generation, branchId);
  const orders = useQuery({
    queryKey: key,
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    refetchInterval: pollInterval(realtime, KIOSK_TRAY_FALLBACK_POLL_MS),
    queryFn: async () => {
      try {
        const result = await session.request<{ data: unknown }>('GET', '/pos/kiosk_orders', {
          params: { branch_id: branchId ?? undefined },
        });
        return normalizeKioskOrders(result.data);
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
  });
  const refresh = () => void client.invalidateQueries({ queryKey: key });
  const cancel = useMutation({
    mutationFn: (id: string) => {
      const idempotencyKey = crypto.randomUUID();
      return session.request<{ data: unknown }>('POST', `/pos/kiosk_orders/${id}/cancel`, {
        body: { idempotency_key: idempotencyKey },
        idempotencyKey,
      });
    },
    onSettled: refresh,
  });
  return { orders, cancel, refresh };
}
