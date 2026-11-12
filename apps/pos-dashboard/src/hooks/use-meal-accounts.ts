import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import type {
  MealAccount,
  MealAccountStatus,
  MealEntry,
  MealPayMode,
  MealSponsor,
  MealWindow,
  SubsidyMode,
} from '../lib/meal-accounts'
import { posRequest as request } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { type Page, pageParams } from '../lib/table-params'
import { localList } from '../tables/local-list'
import { useSession } from './use-session'

// Canteen accounts and sponsors belong to the store; every call names the
// branch the work is done at, where the module must be on.

async function write<T>(method: 'POST' | 'PATCH', path: string, body: Record<string, unknown>) {
  const key = crypto.randomUUID()
  const result = await request<{ data: T }>(method, path, {
    body: { ...body, idempotency_key: key },
    idempotencyKey: key,
  })
  return result.data
}

export type MealAccountFilters = { status?: MealAccountStatus; sponsorId?: string }

// The server searches by code, name or group and pages the list.
export function fetchMealAccounts(
  branchId: string,
  filters: MealAccountFilters,
  params: Record<string, unknown>,
) {
  const term = String(params.search ?? '').trim()
  return request<Page<MealAccount>>('GET', '/pos/meal_accounts', {
    params: {
      branch_id: branchId,
      q: term || undefined,
      status: filters.status,
      meal_sponsor_id: filters.sponsorId,
      ...pageParams(params),
    },
  })
}

// The wallet history of one account, newest first.
export function useMealEntries(branchId: string, accountId: string | null, page: number) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'meal-accounts', branchId, 'entries', accountId, page),
    enabled: status === 'authenticated' && Boolean(accountId),
    queryFn: () =>
      request<Page<MealEntry>>('GET', `/pos/meal_accounts/${accountId}/entries`, {
        params: { branch_id: branchId, page: String(page), limit: '25' },
      }),
  })
}

// Sponsors are few; one page of up to 100 serves the pickers and the list.
export const mealSponsorsQuery = (storeId: string, branchId: string) => ({
  queryKey: posKey(storeId, 'meal-sponsors', branchId),
  queryFn: () =>
    request<Page<MealSponsor>>('GET', '/pos/meal_sponsors', {
      params: { branch_id: branchId, limit: '100' },
    }),
  staleTime: 5_000,
})

export function useMealSponsors(branchId: string, enabled = true) {
  const { storeId, status } = useSession()
  return useQuery({
    ...mealSponsorsQuery(storeId, branchId),
    enabled: enabled && status === 'authenticated',
  })
}

export function sponsorList(rows: MealSponsor[], params: Record<string, unknown>) {
  return localList(rows, params, {
    searchParam: 'search',
    text: (row) => [row.name, row.customer_name, row.customer_phone].join(' '),
  })
}

export type MealAccountInput = {
  employee_code: string
  name: string
  phone: string | null
  email?: string | null
  group_label: string | null
  meal_sponsor_id: string | null
  pay_mode: MealPayMode
  daily_meal_limit: number | null
  meal_windows: MealWindow[]
  low_balance_threshold: string | null
}

function useInvalidate(...resources: string[]) {
  const { storeId } = useSession()
  const client = useQueryClient()
  return () =>
    Promise.all(
      resources.map((resource) =>
        client.invalidateQueries({ queryKey: ['pos', storeId, resource] }),
      ),
    )
}

type MealAccountChange = Partial<MealAccountInput> & { status?: MealAccountStatus }
export type MealAccountSave =
  | { accountId?: undefined; values: MealAccountInput }
  | { accountId: string; values: MealAccountChange }

// Adds an account, changes it, or locks and unlocks it (`status` alone).
export function useSaveMealAccount(branchId: string) {
  const invalidate = useInvalidate('meal-accounts', 'meal-sponsors')
  return useMutation({
    mutationFn: (input: MealAccountSave) => {
      const body = { branch_id: branchId, ...input.values }
      return input.accountId
        ? write<MealAccount>('PATCH', `/pos/meal_accounts/${input.accountId}`, body)
        : write<MealAccount>('POST', '/pos/meal_accounts', body)
    },
    onSettled: invalidate,
  })
}

// All or nothing: the whole file is imported or nothing is.
export function useImportMealAccounts(branchId: string) {
  const invalidate = useInvalidate('meal-accounts', 'meal-sponsors')
  return useMutation({
    mutationFn: (csv: string) =>
      write<{ created: number; updated: number }>('POST', '/pos/meal_accounts/import', {
        branch_id: branchId,
        csv,
      }),
    onSettled: invalidate,
  })
}

export type MealSponsorInput = {
  name?: string
  phone?: string | null
  email?: string | null
  statement_day?: number
  subsidy_mode?: SubsidyMode
  subsidy_value?: string
  subsidy_daily_cap?: string | null
  status?: 'active' | 'suspended'
  // Credit terms go through the credit configuration and need credit management.
  credit_limit?: string
  due_days?: number
}

export function useSaveMealSponsor(branchId: string) {
  const invalidate = useInvalidate('meal-sponsors', 'meal-accounts', 'credit-accounts')
  return useMutation({
    mutationFn: (input: { sponsorId?: string; values: MealSponsorInput }) => {
      const body = { branch_id: branchId, ...input.values }
      return input.sponsorId
        ? write<MealSponsor>('PATCH', `/pos/meal_sponsors/${input.sponsorId}`, body)
        : write<MealSponsor>('POST', '/pos/meal_sponsors', body)
    },
    onSettled: invalidate,
  })
}
