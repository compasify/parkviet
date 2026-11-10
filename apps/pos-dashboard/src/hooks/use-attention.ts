import { parseMoneyInput } from '@parkviet/pos-shared/money'
import { useQuery } from '@tanstack/react-query'
import { posRequest as request } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import type { Page } from '../lib/table-params'
import { useSession } from './use-session'

// A count read from at most one page of rows; `more` means the page was full
// and further rows were not counted.
export type AttentionCount = { count: number; more: boolean }

type Rows<T> = { data: T[]; meta?: { pages?: number } }
const counted = <T>(rows: Rows<T>, keep: (row: T) => boolean): AttentionCount => ({
  count: rows.data.filter(keep).length,
  more: (rows.meta?.pages ?? 1) > 1,
})

function useAttentionQuery(
  resource: string,
  branchId: string | null,
  enabled: boolean,
  read: (branchId: string) => Promise<AttentionCount>,
) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: posKey(storeId, resource, 'attention', branchId),
    enabled: enabled && status === 'authenticated' && Boolean(branchId),
    refetchInterval: 30_000,
    queryFn: () => read(branchId ?? ''),
  })
}

// Received money not fully applied or not yet identified, as the payment
// attention list of the selling app shows it.
export function useFundsAttention(branchId: string | null, enabled: boolean) {
  return useAttentionQuery('received-funds', branchId, enabled, async (branch) =>
    counted(
      await request<Page<{ status: string; available: string }>>('GET', '/pos/received_funds', {
        params: { branch_id: branch, limit: '100' },
      }),
      (fund) => fund.status === 'attention' || parseMoneyInput(fund.available) !== '0',
    ),
  )
}

// Credit sales waiting for an approver (the list also holds live approvals).
export function useCreditRequestsAttention(branchId: string | null, enabled: boolean) {
  return useAttentionQuery('credit-requests', branchId, enabled, async (branch) =>
    counted(
      await request<Page<{ status: string }>>('GET', '/pos/credit_requests', {
        params: { branch_id: branch, limit: '100' },
      }),
      (row) => row.status === 'pending',
    ),
  )
}

// Cash in/out waiting for someone other than the requester to confirm it.
export function useCashRequestsAttention(
  branchId: string | null,
  staffId: string | null,
  enabled: boolean,
) {
  return useAttentionQuery('cash-requests', branchId, enabled, async (branch) =>
    counted(
      await request<Rows<{ requester_id: string }>>('GET', '/pos/cash_movement_requests', {
        params: { branch_id: branch, status: 'requested', limit: '100' },
      }),
      (row) => row.requester_id !== staffId,
    ),
  )
}

// Shifts still open at the branch that a recovery manager may close.
export function useOpenShiftsAttention(
  branchId: string | null,
  ownShiftId: string | null,
  enabled: boolean,
) {
  return useAttentionQuery('shift-close', branchId, enabled, async (branch) =>
    counted(
      await request<Rows<{ id: string }>>('GET', '/pos/shift_closures/open', {
        params: { branch_id: branch },
      }),
      (row) => row.id !== ownShiftId,
    ),
  )
}
