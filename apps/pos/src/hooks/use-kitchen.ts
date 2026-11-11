import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import type { PosWorkspace } from '../lib/pos-context';
import { useSession } from './use-session';

export type PosKitchenTicketItem = {
  id: string;
  sale_line_id: string;
  name: string;
  modifiers: { name: string; group_name?: string | null; quantity: number }[];
  components: { name: string; quantity: string }[];
  note: string | null;
  quantity: string;
  status: 'new' | 'preparing' | 'ready' | 'served' | 'voided';
};

// What one send told one station; written once, only item statuses move.
export type PosKitchenTicket = {
  id: string;
  workspace_id: string;
  kitchen_station_id: string;
  station_name: string;
  sequence: number;
  service_mode: string;
  sent_at: string;
  done: boolean;
  items: PosKitchenTicketItem[];
};

export function kitchenTicketsKey(generation: number, workspaceId: string) {
  return ['pos', 'kitchen-tickets', generation, workspaceId] as const;
}

// The order's kitchen history. A send (the workspace revision moves) and
// `kitchen_ticket.updated` read it again.
export function useKitchenTickets(workspace: PosWorkspace, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: [...kitchenTicketsKey(snapshot.generation, workspace.id), workspace.revision],
    enabled: enabled && snapshot.status === 'authenticated',
    queryFn: async () =>
      (
        await session.request<{ data: PosKitchenTicket[] }>(
          'GET',
          `/pos/workspaces/${workspace.id}/kitchen_tickets`,
        )
      ).data,
  });
}

// The branch's call numbers today: preparing while the kitchen works, ready
// once every item is done and not handed over yet.
export type PickupQueue = {
  preparing: { number: number; workspace_id: string }[];
  ready: { number: number; workspace_id: string; guest_name: string | null; ready_at: string }[];
};

export function kitchenOrdersKey(generation: number, branchId: string | null) {
  return ['pos', 'kitchen-orders', generation, branchId] as const;
}

// The counter's pickup queue, read again on `kitchen_ticket.updated` and,
// while the socket is down, every few seconds.
export function usePickupQueue(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  const client = useQueryClient();
  const key = kitchenOrdersKey(snapshot.generation, branchId);
  const query = useQuery({
    queryKey: key,
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    refetchInterval: 10_000,
    queryFn: async () =>
      (
        await session.request<{ data: PickupQueue }>('GET', '/pos/kitchen/orders', {
          params: { branch_id: branchId ?? undefined },
        })
      ).data,
  });
  // "Đã giao": every ready item of the order is served; it leaves the board.
  const serve = useMutation({
    mutationFn: async (workspaceId: string) => {
      const idempotencyKey = crypto.randomUUID();
      return session.request('POST', `/pos/kitchen/orders/${workspaceId}/serve`, {
        body: { idempotency_key: idempotencyKey },
        idempotencyKey,
      });
    },
    onSuccess: (_result, workspaceId) =>
      client.setQueryData<PickupQueue>(key, (current) =>
        current
          ? { ...current, ready: current.ready.filter((row) => row.workspace_id !== workspaceId) }
          : current,
      ),
    onSettled: () => void client.invalidateQueries({ queryKey: key }),
  });
  return { query, serve };
}

// Prints the cup labels of one line, or of the whole order, again.
export function useCupLabelReprint() {
  return useMutation({
    mutationFn: async (input: { workspaceId: string; saleLineId?: string }) => {
      const idempotencyKey = crypto.randomUUID();
      return (
        await session.request<{ data: { jobs: { id: string }[] } }>(
          'POST',
          `/pos/workspaces/${input.workspaceId}/cup_labels`,
          {
            body: { sale_line_id: input.saleLineId, idempotency_key: idempotencyKey },
            idempotencyKey,
          },
        )
      ).data;
    },
  });
}
