import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import type { DeliveryStatus, PosDeliveryRow } from '../lib/deliveries';
import { useSession } from './use-session';
import { abandonIfNeeded } from './use-tenders';

type Page<T> = { data: T[]; meta: { page: number; pages: number; count: number } };

async function read<T>(path: string, params?: Record<string, string | undefined>): Promise<T> {
  try {
    return await session.request<T>('GET', path, { params });
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

// Pending deliveries of the branch (oldest first), or the ones delivered
// today. Refreshes every half minute: other devices sell and deliver too.
export function useDeliveries(branchId: string | null, status: DeliveryStatus, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'deliveries', snapshot.generation, branchId, status],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    refetchInterval: 30_000,
    queryFn: () =>
      read<Page<PosDeliveryRow>>('/pos/deliveries', {
        branch_id: branchId ?? undefined,
        status,
        limit: '100',
      }),
  });
}

// Names typed lately at the branch, for a quick pick on the sale screen.
export function useRecentDeliverers(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'deliverers', snapshot.generation, branchId],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    staleTime: 60_000,
    queryFn: async () =>
      (
        await read<{ data: string[] }>('/pos/deliveries/deliverers', {
          branch_id: branchId ?? undefined,
        })
      ).data,
  });
}

// "Đã giao" (deliver) or back to "Chờ giao" (reopen). One key per tap; the
// server changes nothing when the row is already in that status.
export function useChangeDelivery() {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (input: { id: string; action: 'deliver' | 'reopen' }) => {
      const key = crypto.randomUUID();
      try {
        const result = await session.request<{ data: PosDeliveryRow }>(
          'POST',
          `/pos/deliveries/${input.id}/${input.action}`,
          { body: { idempotency_key: key }, idempotencyKey: key },
        );
        return result.data;
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      } finally {
        await queryClient.invalidateQueries({
          queryKey: ['pos', 'deliveries', snapshot.generation],
        });
      }
    },
  });
}
