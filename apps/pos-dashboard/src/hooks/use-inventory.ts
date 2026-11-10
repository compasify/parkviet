import { definitiveRejection } from '@parkviet/pos-shared/request-failure'
import type {
  AdjustmentStatus,
  PosAdjustment,
  PosLot,
  PosSerialUnit,
  PosTraceStatus,
  RecallResult,
} from '@parkviet/pos-shared/traceability'
import type { PaginationMeta } from '@spree/dashboard-ui'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { useRef, useState, useSyncExternalStore } from 'react'
import { tableMeta } from '../components/inventory/inventory-helpers'
import { runMoneyCommand } from '../lib/money-command'
import { posRequest as request } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'

type ServerMeta = { page?: number; pages?: number; count?: number; limit?: number }
type ServerPage<T> = { data: T[]; meta?: ServerMeta }
export type TablePage<T> = { data: T[]; meta: PaginationMeta }

// Lists the forms pick from are capped by the server; a code filter narrows them.
export const FORM_LIST_LIMIT = 100
export const ADJUSTMENT_POLL_MS = 12_000
export const OPENING_PATH = '/pos/inventory/opening_balances'

const tableLimit = (params: Record<string, unknown>, fallback: number) =>
  String(Math.min(100, Math.max(1, Number(params.limit) || fallback)))
const term = (params: Record<string, unknown>) =>
  typeof params.search === 'string' ? params.search.trim() || undefined : undefined

async function paged<T>(
  path: string,
  params: Record<string, string | undefined>,
): Promise<TablePage<T>> {
  const page = await request<ServerPage<T>>('GET', path, { params })
  return { data: page.data, meta: tableMeta(page.meta, page.data.length, Number(params.limit)) }
}

// Tracked variants of the branch with their enrolment and reconciliation.
export const fetchInventoryVariants = async (branchId: string) =>
  (
    await request<{ data: PosTraceStatus[] }>('GET', '/pos/inventory/variants', {
      params: { branch_id: branchId },
    })
  ).data

export function useInventoryVariants(branchId: string, enabled = true) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'inventory', 'variants', branchId),
    enabled: enabled && status === 'authenticated',
    queryFn: () => fetchInventoryVariants(branchId),
  })
}

// The lot list: the table's search box is the lot code, the status filter is
// the server's single `status`.
export function fetchLots(
  branchId: string,
  status: string | undefined,
  params: Record<string, unknown>,
) {
  return paged<PosLot>('/pos/lots', {
    branch_id: branchId,
    q: term(params),
    status: status || undefined,
    page: String(Math.max(1, Number(params.page) || 1)),
    limit: tableLimit(params, 50),
  })
}

// Lots of one variant for the transfer and count forms: up to the server cap,
// narrowed by a lot code prefix when a variant has more.
export function useFormLots(
  branchId: string,
  variantId: string | undefined,
  filters: { q: string; status?: string },
  enabled: boolean,
) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'inventory', 'lots', branchId, 'form', variantId, filters),
    enabled: enabled && status === 'authenticated' && Boolean(variantId),
    queryFn: () =>
      request<ServerPage<PosLot>>('GET', '/pos/lots', {
        params: {
          branch_id: branchId,
          variant_id: variantId,
          q: filters.q.trim() || undefined,
          status: filters.status || undefined,
          page: '1',
          limit: String(FORM_LIST_LIMIT),
        },
      }),
  })
}

export function fetchSerialUnits(branchId: string, params: Record<string, unknown>) {
  return paged<PosSerialUnit>('/pos/serial_units', {
    branch_id: branchId,
    q: term(params),
    page: String(Math.max(1, Number(params.page) || 1)),
    limit: tableLimit(params, 50),
  })
}

export function fetchAdjustments(
  branchId: string,
  status: AdjustmentStatus | '',
  params: Record<string, unknown>,
) {
  return paged<PosAdjustment>('/pos/inventory/adjustments', {
    branch_id: branchId,
    status: status || undefined,
    page: String(Math.max(1, Number(params.page) || 1)),
    limit: tableLimit(params, 25),
  })
}

export type RecallQuery = { kind: 'lot_code' | 'serial'; value: string }
export type RecallPage = {
  data: RecallResult
  meta: { page: number; limit: number; count: number; pages: number; truncated: boolean }
}

// Where a lot or serial went: stock that still holds it and the sales that
// took it, a page of sales at a time. Customers come masked from the server.
export const recallKey = (storeId: string, query: RecallQuery, page: number) =>
  posKey(storeId, 'inventory', 'recall', query, page)
export const fetchRecall = (query: RecallQuery, page: number) =>
  request<RecallPage>('GET', '/pos/inventory/recall', {
    params: { [query.kind]: query.value, page: String(page), limit: '50' },
  })

export function useRecall(query: RecallQuery | null) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: recallKey(storeId, query ?? { kind: 'lot_code', value: '' }, 1),
    enabled: status === 'authenticated' && Boolean(query?.value),
    queryFn: () => fetchRecall(query as RecallQuery, 1),
  })
}

export type InventoryCommandInput = {
  branchId: string
  // Names the command in its idempotency intent, e.g. 'receive'.
  action: string
  path: string
  body: Record<string, unknown>
}

type Handlers<T> = { onSuccess?: (data: T) => void; onError?: (error: unknown) => void }

// Opening balances sent from this tab whose outcome is unknown, by store,
// branch and variant: the variant list offers to check them again with the
// very body sent before, so the same idempotency key answers from its receipt.
const uncertainOpenings = new Map<string, Record<string, unknown>>()
const openingListeners = new Set<() => void>()
let openingVersion = 0
const openingKey = (storeId: string, branchId: string, variantId: unknown) =>
  `${storeId}:${branchId}:${String(variantId)}`

function setOpening(key: string, body: Record<string, unknown> | null) {
  if (body) uncertainOpenings.set(key, body)
  else if (!uncertainOpenings.delete(key)) return
  openingVersion += 1
  for (const listener of openingListeners) listener()
}

export function useUncertainOpenings(branchId: string) {
  const { storeId } = useSession()
  useSyncExternalStore(
    (listener) => {
      openingListeners.add(listener)
      return () => openingListeners.delete(listener)
    },
    () => openingVersion,
  )
  return (variantId: string) => uncertainOpenings.get(openingKey(storeId, branchId, variantId))
}

// One stock command with a durable intent: the same content reuses its key
// until the outcome is known, so a lost response is checked against its
// receipt and resent under the same key, never as a second receipt or
// transfer. While the outcome is unknown the form stays locked on that
// content until "check again" settles it.
export function useInventoryCommand<T>() {
  const { storeId } = useSession()
  const client = useQueryClient()
  const [uncertain, setUncertain] = useState<InventoryCommandInput | null>(null)
  const handlers = useRef<Handlers<T>>({})
  const mutation = useMutation({
    mutationFn: async (input: InventoryCommandInput) =>
      (
        await runMoneyCommand<T>(
          `${storeId}:${input.branchId}:inventory.${input.action}:${input.path}:${JSON.stringify(input.body)}`,
          input.path,
          input.body,
        )
      ).data,
    onSettled: () => client.invalidateQueries({ queryKey: ['pos', storeId, 'inventory'] }),
  })

  function run(input: InventoryCommandInput, next: Handlers<T> = {}) {
    handlers.current = next
    const opening =
      input.path === OPENING_PATH
        ? openingKey(storeId, input.branchId, input.body.variant_id)
        : null
    mutation.mutate(input, {
      onSuccess: (data) => {
        setUncertain(null)
        if (opening) setOpening(opening, null)
        handlers.current.onSuccess?.(data)
      },
      onError: (error) => {
        // A refusal rolled the command back; anything else may have committed.
        const unknown = !definitiveRejection(error)
        setUncertain(unknown ? input : null)
        if (opening) setOpening(opening, unknown ? input.body : null)
        handlers.current.onError?.(error)
      },
    })
  }

  return {
    run,
    isPending: mutation.isPending,
    uncertain: uncertain !== null,
    recheck() {
      if (uncertain) run(uncertain, handlers.current)
    },
  }
}
