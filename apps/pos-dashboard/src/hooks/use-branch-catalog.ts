import type { LabelFormat } from '@parkviet/pos-shared/label-format'
import { queryClient } from '@spree/dashboard-core'
import { useMutation, useQuery } from '@tanstack/react-query'
import { posRequest as request } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'
import { allPages } from './use-topology'

export type BranchProduct = {
  id: string
  name: string
  status: string
  skus: string[]
  assigned: boolean
}
export type BranchProductPage = {
  data: BranchProduct[]
  meta: { page: number; pages: number; count: number }
}
export type AssignmentFilter = 'all' | 'assigned' | 'unassigned'
export type UnitDefinition = {
  id: string
  code: string
  name: string
  dimension: string
  base_code: string
  sale_precision: number
}
export const BRANCH_PRODUCTS_PAGE_SIZE = 25
export const branchProductsKey = (storeId: string, branchId: string | null) =>
  posKey(storeId, 'branch-products', branchId)
export const labelFormatsKey = (storeId: string, branchId: string | null) =>
  posKey(storeId, 'label-formats', branchId)
export function useBranchProducts(
  branchId: string | null,
  filter: { q: string; assigned: AssignmentFilter; page: number },
  enabled: boolean,
) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: [...branchProductsKey(storeId, branchId), filter.q, filter.assigned, filter.page],
    enabled: enabled && status === 'authenticated' && Boolean(branchId),
    placeholderData: (previous) => previous,
    queryFn: () =>
      request<BranchProductPage>('GET', `/pos/branches/${branchId}/products`, {
        params: {
          q: filter.q || undefined,
          assigned: filter.assigned === 'all' ? undefined : String(filter.assigned === 'assigned'),
          page: String(filter.page),
          limit: String(BRANCH_PRODUCTS_PAGE_SIZE),
        },
      }),
  })
}
export const assignBranchProduct = (branchId: string, productId: string) =>
  request('POST', `/pos/branches/${branchId}/products`, { body: { product_id: productId } })
export const removeBranchProduct = (branchId: string, productId: string) =>
  request('DELETE', `/pos/branches/${branchId}/products/${productId}`)
export function useLabelFormats(branchId: string | null, enabled: boolean) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: labelFormatsKey(storeId, branchId),
    enabled: enabled && status === 'authenticated' && Boolean(branchId),
    queryFn: async () =>
      (await allPages<LabelFormat>(`/pos/branches/${branchId}/label_formats`)).data,
  })
}
export const saveLabelFormat = (
  branchId: string,
  formatId: string | undefined,
  body: Record<string, unknown>,
) =>
  request<{ data: LabelFormat }>(
    formatId ? 'PATCH' : 'POST',
    `/pos/branches/${branchId}/label_formats${formatId ? `/${formatId}` : ''}`,
    { body },
  )
export const disableLabelFormat = (branchId: string, formatId: string) =>
  request<{ data: LabelFormat }>(
    'POST',
    `/pos/branches/${branchId}/label_formats/${formatId}/disable`,
    { body: {} },
  )
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
