import { useQuery } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import type { PosVariantUnit } from '../lib/pos-context';
import { posFailureKey } from '../lib/request-failure';
import { SessionSuperseded } from '../lib/session-coordinator';
import type { PosTraceStatus } from '../lib/traceability';
import { useSession } from './use-session';

export function useVariantUnit(
  storeId: string | null,
  branchId: string | null,
  variantId: string | null,
) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'variant-unit', snapshot.generation, storeId, branchId, variantId],
    enabled: snapshot.status === 'authenticated' && Boolean(storeId && branchId && variantId),
    queryFn: async () => {
      try {
        return await session.request<{ data: PosVariantUnit }>('GET', '/pos/units/variant', {
          params: { branch_id: branchId ?? undefined, variant_id: variantId ?? undefined },
        });
      } catch (error) {
        if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized')
          session.abandon();
        throw error;
      }
    },
  });
}

export function useTraceability(
  storeId: string | null,
  branchId: string | null,
  variantId: string | null,
) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'traceability', snapshot.generation, storeId, branchId, variantId],
    enabled: snapshot.status === 'authenticated' && Boolean(storeId && branchId && variantId),
    queryFn: async () => {
      try {
        return await session.request<{ data: PosTraceStatus }>('GET', '/pos/traceability', {
          params: { branch_id: branchId ?? undefined, variant_id: variantId ?? undefined },
        });
      } catch (error) {
        if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized')
          session.abandon();
        throw error;
      }
    },
  });
}

export type VariantUnitInput = {
  branch_id: string;
  variant_id: string;
  sale_unit: string;
  base_unit: string;
  price_unit: string;
  ratio_numerator: number;
  ratio_denominator: number;
  tracked_mode: string;
  // Blank clears the code; the server owns uniqueness across SKUs.
  label_code: string;
};

export async function saveVariantUnit(input: VariantUnitInput) {
  try {
    return await session.request<{ data: PosVariantUnit }>('PUT', '/pos/units/variant', {
      body: input,
    });
  } catch (error) {
    if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized')
      session.abandon();
    throw error;
  }
}
