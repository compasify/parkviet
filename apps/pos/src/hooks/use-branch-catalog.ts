import type { LabelFormat } from '@parkviet/pos-shared/label-format';
import { useQuery } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import { posFailureKey } from '../lib/request-failure';
import { SessionSuperseded } from '../lib/session-coordinator';
import { useSession } from './use-session';

export type BranchProduct = {
  id: string;
  name: string;
  status: string;
  skus: string[];
  assigned: boolean;
};

export type BranchProductPage = {
  data: BranchProduct[];
  meta: { page: number; pages: number; count: number };
};

export type AssignmentFilter = 'all' | 'assigned' | 'unassigned';

export type UnitDefinition = {
  id: string;
  code: string;
  name: string;
  dimension: string;
  base_code: string;
  sale_precision: number;
};

export const BRANCH_PRODUCTS_PAGE_SIZE = 25;

async function request<T>(
  method: string,
  path: string,
  options?: { body?: unknown; params?: Record<string, string | undefined> },
): Promise<T> {
  try {
    return await session.request<T>(method, path, options);
  } catch (error) {
    if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized')
      session.abandon();
    throw error;
  }
}

export const branchProductsKey = (generation: number, branchId: string | null) =>
  ['pos', 'branch-products', generation, branchId] as const;
export const labelFormatsKey = (generation: number, branchId: string | null) =>
  ['pos', 'label-formats', generation, branchId] as const;

export function useBranchProducts(
  branchId: string | null,
  filter: { q: string; assigned: AssignmentFilter; page: number },
  enabled: boolean,
) {
  const snapshot = useSession();
  return useQuery({
    queryKey: [
      ...branchProductsKey(snapshot.generation, branchId),
      filter.q,
      filter.assigned,
      filter.page,
    ],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
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
  });
}

export function assignBranchProduct(branchId: string, productId: string) {
  return request('POST', `/pos/branches/${branchId}/products`, {
    body: { product_id: productId },
  });
}

export function removeBranchProduct(branchId: string, productId: string) {
  return request('DELETE', `/pos/branches/${branchId}/products/${productId}`);
}

export function useLabelFormats(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: labelFormatsKey(snapshot.generation, branchId),
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    queryFn: async () => {
      const data: LabelFormat[] = [];
      let page: number | null = 1;
      while (page !== null) {
        const result: { data: LabelFormat[]; meta?: { next: number | null } } = await request(
          'GET',
          `/pos/branches/${branchId}/label_formats`,
          { params: { limit: '100', page: String(page) } },
        );
        data.push(...result.data);
        page = result.meta?.next ?? null;
      }
      return data;
    },
  });
}

export function saveLabelFormat(
  branchId: string,
  formatId: string | undefined,
  body: Record<string, unknown>,
) {
  return request<{ data: LabelFormat }>(
    formatId ? 'PATCH' : 'POST',
    `/pos/branches/${branchId}/label_formats${formatId ? `/${formatId}` : ''}`,
    { body },
  );
}

export function disableLabelFormat(branchId: string, formatId: string) {
  return request<{ data: LabelFormat }>(
    'POST',
    `/pos/branches/${branchId}/label_formats/${formatId}/disable`,
    { body: {} },
  );
}

export function useUnitDefinitions(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'unit-definitions', snapshot.generation, branchId],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    queryFn: () =>
      request<{ data: UnitDefinition[] }>('GET', '/pos/units', {
        params: { branch_id: branchId ?? undefined },
      }),
  });
}
