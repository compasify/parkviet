import type { PosOrderDetail, PosOrderRow } from '@parkviet/pos-shared/returns'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { posRequest as request } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { dayRange, type Page, pageParams } from '../lib/table-params'
import { useSession } from './use-session'

export const ORDER_STATUSES = ['all', 'debt', 'returned', 'refund_pending'] as const
export type OrderStatus = (typeof ORDER_STATUSES)[number]
export type OrderFilters = { status: OrderStatus; registerId?: string; cashierId?: string }

// The order history endpoint filters by number, branch days, one register,
// one cashier and one status, newest first; the table's search, date filter
// and page map onto those.
export function fetchOrders(
  branchId: string,
  filters: OrderFilters,
  params: Record<string, unknown>,
): Promise<Page<PosOrderRow>> {
  const number = typeof params.number === 'string' ? params.number.trim().slice(0, 64) : ''
  return request('GET', '/pos/orders', {
    params: {
      branch_id: branchId,
      number: number || undefined,
      ...dayRange(params, 'placed_at'),
      register_id: filters.registerId || undefined,
      cashier_id: filters.cashierId || undefined,
      status: filters.status,
      ...pageParams(params),
    },
  })
}

export function useOrder(orderId: string, branchId: string | null) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'order', branchId, orderId),
    enabled: status === 'authenticated' && Boolean(branchId),
    queryFn: async () =>
      (
        await request<{ data: PosOrderDetail }>('GET', `/pos/orders/${orderId}`, {
          params: { branch_id: branchId ?? undefined },
        })
      ).data,
  })
}

// Orders still waiting for a refund payout at the branch, for the home page.
export function useRefundPendingCount(branchId: string | null, enabled: boolean) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'orders', 'refund-pending-count', branchId),
    enabled: enabled && status === 'authenticated' && Boolean(branchId),
    refetchInterval: 30_000,
    queryFn: async () =>
      (
        await request<Page<PosOrderRow>>('GET', '/pos/orders', {
          params: { branch_id: branchId ?? undefined, status: 'refund_pending', limit: '1' },
        })
      ).meta.count,
  })
}

// A resolver finishes a short handover once the shelf was corrected. One
// idempotency key per action; the order views refresh either way.
export function useReconcileHandover() {
  const { storeId } = useSession()
  const client = useQueryClient()
  return useMutation({
    mutationFn: async (orderId: string) => {
      const key = crypto.randomUUID()
      try {
        return (
          await request<{ data: { stock_discrepancies: unknown[] } }>(
            'POST',
            `/pos/orders/${orderId}/reconcile_handover`,
            { body: { idempotency_key: key }, idempotencyKey: key },
          )
        ).data
      } finally {
        await Promise.all(
          ['orders', 'order'].map((resource) =>
            client.invalidateQueries({ queryKey: ['pos', storeId, resource] }),
          ),
        )
      }
    },
  })
}
