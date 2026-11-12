import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import { normalizeGuestOrders, normalizeGuestRequests } from '../lib/guest-orders';
import { pollInterval } from '../lib/realtime';
import { useRealtimeStatus } from './use-branch-events';
import { useSession } from './use-session';
import { abandonIfNeeded } from './use-tenders';

// Without the branch stream the tray is read again every ten seconds.
export const GUEST_TRAY_FALLBACK_POLL_MS = 10_000;

export function guestOrdersKey(generation: number, branchId: string | null) {
  return ['pos', 'guest-orders', generation, branchId] as const;
}

export function guestRequestsKey(generation: number, branchId: string | null) {
  return ['pos', 'guest-requests', generation, branchId] as const;
}

async function read(path: string, branchId: string | null) {
  try {
    return (
      await session.request<{ data: unknown }>('GET', path, {
        params: { branch_id: branchId ?? undefined, limit: '50' },
      })
    ).data;
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

function command(path: string, body: Record<string, unknown> = {}) {
  const idempotencyKey = crypto.randomUUID();
  return session.request<{ data: unknown }>('POST', path, {
    body: { ...body, idempotency_key: idempotencyKey },
    idempotencyKey,
  });
}

// The counter's QR tray: guests' orders waiting for staff and their open
// requests (call staff, the bill). `guest_order.*` and `guest_request.*`
// invalidate both through the branch stream (lib/realtime).
export function useGuestOrders(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  const realtime = useRealtimeStatus();
  const client = useQueryClient();
  const ordersKey = guestOrdersKey(snapshot.generation, branchId);
  const requestsKey = guestRequestsKey(snapshot.generation, branchId);
  const active = enabled && snapshot.status === 'authenticated' && Boolean(branchId);
  const refetchInterval = pollInterval(realtime, GUEST_TRAY_FALLBACK_POLL_MS);
  const orders = useQuery({
    queryKey: ordersKey,
    enabled: active,
    refetchInterval,
    queryFn: async () => normalizeGuestOrders(await read('/pos/guest_orders', branchId)),
  });
  const requests = useQuery({
    queryKey: requestsKey,
    enabled: active,
    refetchInterval,
    queryFn: async () => normalizeGuestRequests(await read('/pos/guest_requests', branchId)),
  });
  const refresh = () => {
    void client.invalidateQueries({ queryKey: ordersKey });
    void client.invalidateQueries({ queryKey: requestsKey });
    // Accepted items land on the table's order.
    void client.invalidateQueries({ queryKey: ['pos', 'workspaces', snapshot.generation] });
  };
  const accept = useMutation({
    mutationFn: (id: string) => command(`/pos/guest_orders/${id}/accept`),
    onSettled: refresh,
  });
  const reject = useMutation({
    mutationFn: (input: { id: string; reason: string }) =>
      command(`/pos/guest_orders/${input.id}/reject`, { reason: input.reason.trim() }),
    onSettled: refresh,
  });
  const done = useMutation({
    mutationFn: (id: string) => command(`/pos/guest_requests/${id}/done`),
    onSettled: refresh,
  });
  return { orders, requests, accept, reject, done };
}
