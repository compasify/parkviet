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
    queryFn: async () => {
      try {
        return await session.request<CatalogPage>('GET', '/pos/catalog', {
          params: { branch_id: branchId ?? undefined, q: query, page: String(page), limit: '25' },
        });
      } catch (error) {
        if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized')
          session.abandon();
        throw error;
      }
    },
  });
}
