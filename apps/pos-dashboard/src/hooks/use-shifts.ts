import type {
  CashMovementRequest,
  CashReconciliation,
  CustodyOutcome,
  OpenShiftRow,
  PendingClose,
  ReconcileCandidates,
  ShiftCloseState,
  ShiftClosure,
  ShiftCount,
} from '@parkviet/pos-shared/shifts'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { runMoneyCommand } from '../lib/money-command'
import { posRequest as request } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { dayRange, type Page, pageParams } from '../lib/table-params'
import { localList } from '../tables/local-list'
import { useSession } from './use-session'

// Shift management of the selected branch: shifts left open, drawer requests
// waiting for a second person, counts waiting for a variance approval, the
// closure history and late-cash reconciliation. Every command carries a
// stable intent so a lost response is never posted twice.
const SHIFT_RESOURCES = [
  'shift-close',
  'cash-requests',
  'pending-closes',
  'cash-reconcile',
  'context',
]

function useRefreshShifts() {
  const { storeId } = useSession()
  const client = useQueryClient()
  return () =>
    Promise.all(
      SHIFT_RESOURCES.map((resource) =>
        client.invalidateQueries({ queryKey: ['pos', storeId, resource] }),
      ),
    )
}

// Short working lists of the branch, read whole and searched in the table.
async function branchList<T>(
  path: string,
  branchId: string,
  params: Record<string, unknown>,
  text: (row: T) => string,
  extra: Record<string, string> = {},
  keep: (row: T) => boolean = () => true,
): Promise<Page<T>> {
  const rows = await request<{ data: T[] }>('GET', path, {
    params: { branch_id: branchId, ...extra },
  })
  return localList(rows.data.filter(keep), params, { searchParam: 'search', text })
}

// Shifts still open at the branch, other than the reader's own.
export const fetchOpenShifts = (
  branchId: string,
  ownShiftId: string | null,
  params: Record<string, unknown>,
) =>
  branchList<OpenShiftRow>(
    '/pos/shift_closures/open',
    branchId,
    params,
    (row) => [row.owner_name, row.register].join(' '),
    {},
    (row) => row.id !== ownShiftId,
  )

// Cash out / safe drop requests of colleagues waiting for a second person.
export const fetchCashRequests = (
  branchId: string,
  staffId: string | null,
  params: Record<string, unknown>,
) =>
  branchList<CashMovementRequest>(
    '/pos/cash_movement_requests',
    branchId,
    params,
    (row) => [row.requester_name, row.reason, row.evidence_reference].join(' '),
    { status: 'requested', limit: '50' },
    (row) => row.requester_id !== staffId,
  )

// Closing counts whose variance exceeds the branch threshold.
export const fetchPendingCloses = (branchId: string, params: Record<string, unknown>) =>
  branchList<PendingClose>('/pos/shift_closures/pending', branchId, params, (row) =>
    [row.owner_name, row.register, row.reason].join(' '),
  )

export const fetchReconciliations = (branchId: string, params: Record<string, unknown>) =>
  branchList<CashReconciliation>(
    '/pos/cash_reconciliations',
    branchId,
    params,
    (row) => [row.reason, row.actor_name, row.custody_reference].join(' '),
    { limit: '20' },
  )

export function useReconcileCandidates(branchId: string) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'cash-reconcile', branchId, 'candidates'),
    enabled: status === 'authenticated',
    queryFn: async () =>
      (
        await request<{ data: ReconcileCandidates }>(
          'GET',
          '/pos/cash_reconciliations/candidates',
          {
            params: { branch_id: branchId },
          },
        )
      ).data,
  })
}

export type ClosureRow = {
  closure_id: string
  shift_id: string
  register: string | null
  cashier: string
  opened_at: string
  closed_at: string
  opening_float: string
  expected: string
  counted: string
  variance: string
  reason: string | null
  approver: string | null
  reconciled: string
  currency: string
}

// Closed shifts by close time, from the closures report: branch days, today
// when the date filter is empty.
// Report meta carries the date range in `from`/`to`, so the table's paging
// numbers are rebuilt from page, limit and count.
export async function fetchClosures(
  branchId: string,
  params: Record<string, unknown>,
): Promise<Page<ClosureRow>> {
  const { from, to } = dayRange(params, 'closed_at')
  const result = await request<{
    data: ClosureRow[]
    meta: { page: number; limit: number; count: number; pages: number }
  }>('GET', '/pos/reports/closures', {
    params: { branch_id: branchId, from: from ?? to, to: to ?? from, ...pageParams(params) },
  })
  const { page, limit, count, pages } = result.meta
  const start = (page - 1) * limit
  return {
    data: result.data,
    meta: {
      page,
      limit,
      count,
      pages,
      from: result.data.length ? start + 1 : 0,
      to: start + result.data.length,
      previous: page > 1 ? page - 1 : null,
      next: page < pages ? page + 1 : null,
    },
  }
}

export function useShiftCloseState(shiftId: string | null, poll = false) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'shift-close', 'state', shiftId),
    enabled: status === 'authenticated' && Boolean(shiftId),
    refetchInterval: poll ? 5000 : false,
    queryFn: async () =>
      (await request<{ data: ShiftCloseState }>('GET', `/pos/shifts/${shiftId}/closure`)).data,
  })
}

export function useDecideCashRequest() {
  const { storeId } = useSession()
  const refresh = useRefreshShifts()
  return useMutation({
    mutationFn: (input: {
      request: CashMovementRequest
      decision: 'confirm' | 'cancel'
      note?: string
    }) =>
      runMoneyCommand<CashMovementRequest>(
        `${storeId}:${input.request.id}:cash_request:${input.decision}`,
        `/pos/cash_movement_requests/${input.request.id}/${input.decision}`,
        { note: input.note || undefined },
      ),
    onSettled: refresh,
  })
}

// One intent per shift revision: a recount after a lost response reuses the
// pending key, and a recovered result may be an earlier count of it.
export function useCountShift() {
  const { storeId } = useSession()
  const client = useQueryClient()
  const refresh = useRefreshShifts()
  return useMutation({
    mutationFn: (input: { shiftId: string; revision: number; counted: string; reason?: string }) =>
      runMoneyCommand<ShiftCount>(
        `${storeId}:${input.shiftId}:shift_count:${input.revision}`,
        `/pos/shifts/${input.shiftId}/count`,
        { counted: input.counted, reason: input.reason || undefined },
      ),
    onSuccess: (result, input) => {
      client.setQueryData<ShiftCloseState>(
        posKey(storeId, 'shift-close', 'state', input.shiftId),
        (state) =>
          state
            ? {
                ...state,
                count: result.data,
                shift: { ...state.shift, revision: result.data.revision },
              }
            : state,
      )
    },
    onSettled: refresh,
  })
}

export function useCloseShift() {
  const { storeId } = useSession()
  const refresh = useRefreshShifts()
  return useMutation({
    mutationFn: (input: { shiftId: string; revision: number; reason?: string }) =>
      runMoneyCommand<ShiftClosure>(
        `${storeId}:${input.shiftId}:shift_close:${input.revision}`,
        `/pos/shifts/${input.shiftId}/close`,
        { reason: input.reason || undefined },
      ),
    onSettled: refresh,
  })
}

export function useApproveClose() {
  const { storeId } = useSession()
  const refresh = useRefreshShifts()
  return useMutation({
    mutationFn: (input: { shiftId: string; revision: number }) =>
      runMoneyCommand<ShiftCount>(
        `${storeId}:${input.shiftId}:shift_approve_close:${input.revision}`,
        `/pos/shifts/${input.shiftId}/close_approval`,
        { revision: input.revision },
      ),
    onSettled: refresh,
  })
}

export type ReconcileInput = {
  branchId: string
  intent: string
  outcome: CustodyOutcome
  reason: string
  amount?: string
  closureId?: string
  fundsId?: string
  targetShiftId?: string
  custodyReference?: string
}

export function useReconcileLateCash() {
  const { storeId } = useSession()
  const refresh = useRefreshShifts()
  return useMutation({
    mutationFn: (input: ReconcileInput) =>
      runMoneyCommand<CashReconciliation>(
        `${storeId}:${input.branchId}:cash_reconcile:${input.intent}`,
        '/pos/cash_reconciliations',
        {
          branch_id: input.branchId,
          outcome: input.outcome,
          reason: input.reason,
          amount: input.amount || undefined,
          closure_id: input.closureId || undefined,
          funds_id: input.fundsId || undefined,
          target_shift_id: input.targetShiftId || undefined,
          custody_reference: input.custodyReference || undefined,
        },
      ),
    onSettled: refresh,
  })
}
