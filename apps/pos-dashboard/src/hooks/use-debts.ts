import { matchesDebtor } from '@parkviet/pos-shared/debt-reminder'
import type { PosRefundRequest, PosReturn, PosReturnRow } from '@parkviet/pos-shared/returns'
import type {
  PosCreditAccount,
  PosCreditRequest,
  PosCustomerProfile,
  PosReceivable,
  PosReceivableAccount,
} from '@parkviet/pos-shared/types/pos-context'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { runMoneyCommand } from '../lib/money-command'
import { posRequest as request } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { type Page, pageParams } from '../lib/table-params'
import { localList } from '../tables/local-list'
import { useSession } from './use-session'

export const RECEIVABLE_STATUSES = ['open', 'overdue', 'all'] as const
export type ReceivableStatus = (typeof RECEIVABLE_STATUSES)[number]

export type ReceivableAccounts = {
  data: PosReceivableAccount[]
  meta: { count: number; totals: Record<string, string> }
}

// Non-money writes carry one idempotency key per user action.
async function write<T>(method: 'POST' | 'PATCH', path: string, body: Record<string, unknown>) {
  const key = crypto.randomUUID()
  const result = await request<{ data: T }>(method, path, {
    body: { ...body, idempotency_key: key },
    idempotencyKey: key,
  })
  return result.data
}

// Customers who owe at the branch with the aging totals; contacts come back
// masked for readers who may not see them.
export const receivableAccountsQuery = (storeId: string, branchId: string) => ({
  queryKey: posKey(storeId, 'receivables', branchId, 'accounts'),
  queryFn: () =>
    request<ReceivableAccounts>('GET', '/pos/receivables/customers', {
      params: { branch_id: branchId },
    }),
  staleTime: 5_000,
})

export function useReceivableAccounts(branchId: string) {
  const { storeId, status } = useSession()
  return useQuery({
    ...receivableAccountsQuery(storeId, branchId),
    enabled: status === 'authenticated',
  })
}

// The customers list is one response; the table searches it by name (accents
// optional) or the phone digits the reader sees, and pages it locally.
export function debtorList(accounts: ReceivableAccounts, params: Record<string, unknown>) {
  const term = String(params.search ?? '')
  return localList(
    accounts.data.filter((row) => matchesDebtor(row, term)),
    { ...params, search: undefined },
    { searchParam: 'search', text: () => '' },
  )
}

export function fetchReceivables(
  branchId: string,
  filters: { status: ReceivableStatus; customerId?: string | null },
  params: Record<string, unknown>,
) {
  return request<Page<PosReceivable>>('GET', '/pos/receivables', {
    params: {
      branch_id: branchId,
      status: filters.status,
      customer_id: filters.customerId ?? undefined,
      ...pageParams(params),
    },
  })
}

export function useCustomerReceivables(
  branchId: string | null,
  customerId: string | null,
  status: ReceivableStatus,
  page: number,
) {
  const { storeId, status: auth } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'receivables', branchId, 'customer', customerId, status, page),
    enabled: auth === 'authenticated' && Boolean(branchId && customerId),
    queryFn: () => fetchReceivables(branchId ?? '', { status, customerId }, { page, limit: 50 }),
  })
}

// Notes that a debt reminder was shared or copied ("Nhắc lần cuối").
export function useRemindDebt() {
  const { storeId } = useSession()
  const client = useQueryClient()
  return useMutation({
    mutationFn: (input: { branchId: string; creditAccountId: string; via: 'share' | 'copy' }) =>
      write<{ credit_account_id: string; last_reminded_at: string }>(
        'POST',
        `/pos/receivables/customers/${input.creditAccountId}/remind`,
        { branch_id: input.branchId, via: input.via },
      ),
    onSettled: () => client.invalidateQueries({ queryKey: ['pos', storeId, 'receivables'] }),
  })
}

export async function fetchCreditAccounts(branchId: string, params: Record<string, unknown>) {
  const rows = await request<Page<PosCreditAccount>>('GET', '/pos/credit_accounts', {
    params: { branch_id: branchId, limit: '100' },
  })
  return localList(rows.data, params, {
    searchParam: 'search',
    text: (row) => [row.customer_name, row.customer_phone].join(' '),
  })
}

export function useCustomerSearch(branchId: string | null, query: string) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'customers', branchId, query.trim()),
    enabled: status === 'authenticated' && Boolean(branchId && query.trim()),
    queryFn: () =>
      request<{ data: PosCustomerProfile[] }>('GET', '/pos/customers', {
        params: { branch_id: branchId ?? undefined, q: query.trim(), page: '1' },
      }),
  })
}

export type CreditTermsInput = {
  branchId: string
  accountId?: string
  customerId?: string
  creditLimit?: string
  dueDays?: number
  status?: 'active' | 'suspended'
}

// Opens a credit account for a customer or changes its terms or status.
export function useConfigureCredit() {
  const { storeId } = useSession()
  const client = useQueryClient()
  return useMutation({
    mutationFn: (input: CreditTermsInput) => {
      const body = {
        branch_id: input.branchId,
        customer_id: input.accountId ? undefined : input.customerId,
        credit_limit: input.creditLimit,
        due_days: input.dueDays,
        status: input.status,
      }
      return input.accountId
        ? write<PosCreditAccount>('PATCH', `/pos/credit_accounts/${input.accountId}`, body)
        : write<PosCreditAccount>('POST', '/pos/credit_accounts', body)
    },
    onSettled: () => client.invalidateQueries({ queryKey: ['pos', storeId, 'credit-accounts'] }),
  })
}

export async function fetchCreditRequests(branchId: string, params: Record<string, unknown>) {
  const rows = await request<Page<PosCreditRequest>>('GET', '/pos/credit_requests', {
    params: { branch_id: branchId, limit: '100' },
  })
  return localList(rows.data, params, {
    searchParam: 'search',
    text: (row) => [row.order_number, row.customer.name, row.requester.name].join(' '),
  })
}

export function useDecideCredit() {
  const { storeId } = useSession()
  const client = useQueryClient()
  return useMutation({
    mutationFn: (input: {
      requestId: string
      decision: 'approve' | 'reject' | 'revoke'
      reason?: string
    }) =>
      write<PosCreditRequest>(
        'POST',
        `/pos/credit_requests/${input.requestId}/${input.decision}`,
        input.decision === 'reject' ? { reason: input.reason } : {},
      ),
    onSettled: () => client.invalidateQueries({ queryKey: ['pos', storeId, 'credit-requests'] }),
  })
}

// Returns waiting for an approver (cross-branch, outside the window, damaged
// goods) that hold no live approval yet.
export async function fetchPendingReturns(branchId: string, params: Record<string, unknown>) {
  const rows = await request<Page<PosReturnRow>>('GET', '/pos/returns', {
    params: { branch_id: branchId, status: 'pending_approval', limit: '100' },
  })
  return localList(
    rows.data.filter((row) => row.approval?.status !== 'active'),
    params,
    {
      searchParam: 'search',
      text: (row) => [row.return_number, row.order_number, row.reason].join(' '),
    },
  )
}

// Refund payouts still waiting: for an approval, or with an unknown outcome.
export async function fetchWaitingRefunds(branchId: string, params: Record<string, unknown>) {
  const rows = await request<Page<PosRefundRequest>>('GET', '/pos/refund_requests', {
    params: { branch_id: branchId, status: 'reserved,unknown', limit: '100' },
  })
  return localList(rows.data, params, {
    searchParam: 'search',
    text: (row) => [row.order_number, row.beneficiary_reference].join(' '),
  })
}

export type ApprovalDecision =
  | { kind: 'return.approve'; returnId: string }
  | { kind: 'return.cancel'; returnId: string; reason: string }
  | { kind: 'refund.approve'; refundId: string }
  | {
      kind: 'refund.resolve'
      refundId: string
      outcome: 'failed_no_effect' | 'cancel'
      reference?: string
      reason?: string
    }

// An approver's decisions on returns and refund payouts. Approvals bind to
// the requester, the record, its revision and amount; resolving a payout is
// a money command, so a retry after a lost response replays the same key.
export function useReturnDecisions() {
  const { storeId } = useSession()
  const client = useQueryClient()
  return useMutation({
    mutationFn: async (input: ApprovalDecision): Promise<unknown> => {
      if (input.kind === 'return.approve')
        return write<PosReturn>('POST', `/pos/returns/${input.returnId}/approve`, {})
      if (input.kind === 'return.cancel')
        return write<PosReturn>('POST', `/pos/returns/${input.returnId}/cancel`, {
          reason: input.reason,
        })
      if (input.kind === 'refund.approve')
        return write<PosRefundRequest>('POST', `/pos/refund_requests/${input.refundId}/approve`, {})
      const body = {
        outcome: input.outcome,
        reference: input.reference || undefined,
        reason: input.reason || undefined,
      }
      return runMoneyCommand<PosRefundRequest>(
        `${storeId}:${input.refundId}:refund.resolve:${input.outcome}`,
        `/pos/refund_requests/${input.refundId}/resolution`,
        body,
      )
    },
    onSettled: () =>
      Promise.all(
        ['returns', 'refund-requests', 'orders'].map((resource) =>
          client.invalidateQueries({ queryKey: ['pos', storeId, resource] }),
        ),
      ),
  })
}
