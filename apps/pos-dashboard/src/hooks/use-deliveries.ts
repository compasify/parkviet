import type { DeliveryStatus, PosDeliveryRow } from '@parkviet/pos-shared/deliveries'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { posRequest as request } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import type { Page } from '../lib/table-params'
import { localList } from '../tables/local-list'
import { useSession } from './use-session'

const readDeliveries = (branchId: string, status: DeliveryStatus, limit: number) =>
  request<Page<PosDeliveryRow>>('GET', '/pos/deliveries', {
    params: { branch_id: branchId, status, page: '1', limit: String(limit) },
  })

// Pending deliveries of the branch (oldest first), or the ones delivered today:
// a short working list, read whole (as the counter screen does) so the table
// can search it by order, customer, phone, address or deliverer.
export async function fetchDeliveries(
  branchId: string,
  status: DeliveryStatus,
  params: Record<string, unknown>,
): Promise<Page<PosDeliveryRow>> {
  const rows = await readDeliveries(branchId, status, 100)
  return localList(rows.data, params, {
    searchParam: 'search',
    text: (row) =>
      [
        row.order_number,
        row.customer?.name,
        row.customer?.phone,
        row.customer?.address,
        row.deliverer,
      ].join(' '),
  })
}

export function usePendingDeliveryCount(branchId: string | null, enabled: boolean) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'deliveries', 'pending-count', branchId),
    enabled: enabled && status === 'authenticated' && Boolean(branchId),
    refetchInterval: 30_000,
    queryFn: async () => (await readDeliveries(branchId ?? '', 'pending', 1)).meta.count,
  })
}

// "Đã giao" (deliver) or back to "Chờ giao" (reopen). One key per action; the
// server changes nothing when the row is already in that status.
export function useChangeDelivery() {
  const { storeId } = useSession()
  const client = useQueryClient()
  return useMutation({
    mutationFn: async (input: { id: string; action: 'deliver' | 'reopen' }) => {
      const key = crypto.randomUUID()
      try {
        return (
          await request<{ data: PosDeliveryRow }>(
            'POST',
            `/pos/deliveries/${input.id}/${input.action}`,
            { body: { idempotency_key: key }, idempotencyKey: key },
          )
        ).data
      } finally {
        await client.invalidateQueries({ queryKey: ['pos', storeId, 'deliveries'] })
      }
    },
  })
}
