import { useQuery } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'
export type CatalogPage = {
  data: {
    id: string
    product_id: string
    name: string
    sku: string
    barcode: string | null
    price: string | null
    compare_at_price: string | null
    currency: string
    stock_on_hand: number | null
  }[]
  meta: { page: number; pages: number; count: number; ambiguous: boolean }
}
export function useCatalog(
  storeId: string | null,
  branchId: string | null,
  query: string,
  page: number,
) {
  const snapshot = useSession()
  return useQuery({
    queryKey: posKey(snapshot.storeId, 'catalog', storeId, branchId, query, page),
    enabled: snapshot.status === 'authenticated' && Boolean(storeId && branchId),
    queryFn: () => fetchCatalogPage(branchId, { q: query, page, limit: 25 }),
  })
}
export function fetchCatalogPage(
  branchId: string | null,
  options: { q: string; page?: number; limit?: number; barcode?: boolean },
): Promise<CatalogPage> {
  return posRequest('GET', '/pos/catalog', {
    params: {
      branch_id: branchId ?? undefined,
      q: options.q,
      page: String(options.page ?? 1),
      limit: String(options.limit ?? 25),
      barcode: options.barcode ? 'true' : undefined,
    },
  })
}
