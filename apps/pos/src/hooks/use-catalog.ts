import { useQuery } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import { posFailureKey } from '../lib/request-failure';
import { SessionSuperseded } from '../lib/session-coordinator';
import { useSession } from './use-session';

export type CatalogPage = {
  data: {
    id: string;
    product_id: string;
    name: string;
    sku: string;
    barcode: string | null;
    price: string | null;
    compare_at_price: string | null;
    currency: string;
    stock_on_hand: number | null;
  }[];
  meta: { page: number; pages: number; count: number; ambiguous: boolean };
};

export function useCatalog(
  storeId: string | null,
  branchId: string | null,
  query: string,
  page: number,
) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'catalog', snapshot.generation, storeId, branchId, query, page],
    enabled: snapshot.status === 'authenticated' && Boolean(storeId && branchId),
    queryFn: () => fetchCatalogPage(branchId, { q: query, page, limit: 25 }),
  });
}

export async function fetchCatalogPage(
  branchId: string | null,
  options: { q: string; page?: number; limit?: number; barcode?: boolean },
): Promise<CatalogPage> {
  try {
    return await session.request<CatalogPage>('GET', '/pos/catalog', {
      params: {
        branch_id: branchId ?? undefined,
        q: options.q,
        page: String(options.page ?? 1),
        limit: String(options.limit ?? 25),
        barcode: options.barcode ? 'true' : undefined,
      },
    });
  } catch (error) {
    if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized')
      session.abandon();
    throw error;
  }
}

// Asks the branch's label formats whether a scanned code is a scale label.
// Returns the raw `data`; the caller validates it before use.
export async function parseMeasurementBarcode(branchId: string, barcode: string): Promise<unknown> {
  try {
    const result = await session.request<{ data: unknown }>(
      'POST',
      '/pos/measurement_barcodes/parse',
      { body: { branch_id: branchId, barcode } },
    );
    return result.data;
  } catch (error) {
    if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized')
      session.abandon();
    throw error;
  }
}
