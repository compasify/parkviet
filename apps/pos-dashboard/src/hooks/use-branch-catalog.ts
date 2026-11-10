import type { LabelFormat } from '@parkviet/pos-shared/label-format'
import { queryClient } from '@spree/dashboard-core'
import type { PaginationMeta } from '@spree/dashboard-ui'
import { useMutation, useQuery } from '@tanstack/react-query'
import { posRequest as request } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'

export type BranchProduct = {
  id: string
  name: string
  status: string
  skus: string[]
  assigned: boolean
}
export type UnitDefinition = {
  id: string
  code: string
  name: string
  dimension: string
  base_code: string
  sale_precision: number
}
// Maps the shared ResourceTable's parameters onto the branch assortment endpoint,
// which searches with `q` and narrows with a single `assigned` flag. Every
// operator the filter toolbar offers on that column reduces to a set of flags.
export async function fetchBranchProducts(
  branchId: string,
  params: Record<string, unknown>,
): Promise<{ data: BranchProduct[]; meta: PaginationMeta }> {
  let flags = ['true', 'false']
  for (const [key, raw] of Object.entries(params)) {
    const operator = /^assigned_(not_in|in|not_eq|eq)$/.exec(key)?.[1]
    if (!operator) continue
    const values = (Array.isArray(raw) ? raw : [raw]).map(String)
    flags = flags.filter((flag) => values.includes(flag) !== operator.startsWith('not_'))
  }
  const limit = Number(params.limit) || 25
  if (flags.length === 0)
    return {
      data: [],
      meta: { page: 1, limit, count: 0, pages: 1, from: 0, to: 0, previous: null, next: null },
    }
  const search = typeof params.search === 'string' ? params.search.trim() : ''
  return request('GET', `/pos/branches/${branchId}/products`, {
    params: {
      q: search || undefined,
      assigned: flags.length === 1 ? flags[0] : undefined,
      page: String(params.page ?? 1),
      limit: String(limit),
    },
  })
}
export const assignBranchProduct = (branchId: string, productId: string) =>
  request('POST', `/pos/branches/${branchId}/products`, { body: { product_id: productId } })
export const removeBranchProduct = (branchId: string, productId: string) =>
  request('DELETE', `/pos/branches/${branchId}/products/${productId}`)
// Scale label formats are store-wide and picked per branch.
export const saveLabelFormat = (formatId: string | undefined, body: Record<string, unknown>) =>
  request<{ data: LabelFormat }>(
    formatId ? 'PATCH' : 'POST',
    `/pos/label_formats${formatId ? `/${formatId}` : ''}`,
    { body },
  )
export const disableLabelFormat = (formatId: string) =>
  request<{ data: LabelFormat }>('POST', `/pos/label_formats/${formatId}/disable`, { body: {} })
export function useUnitDefinitions(branchId: string | null, enabled: boolean) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'unit-definitions', branchId),
    enabled: enabled && status === 'authenticated' && Boolean(branchId),
    queryFn: () =>
      request<{ data: UnitDefinition[] }>('GET', '/pos/units', {
        params: { branch_id: branchId ?? undefined },
      }),
  })
}
export function useBranchCatalogMutation() {
  const { storeId } = useSession()
  return useMutation({
    mutationFn: ({ method, path, body }: { method: string; path: string; body?: unknown }) =>
      request(method, path, { body }),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['pos', storeId] }),
  })
}
