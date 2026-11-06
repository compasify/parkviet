import { useQuery } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import type { PosVariantUnit } from '../lib/pos-context';
import { posFailureKey } from '../lib/request-failure';
import { SessionSuperseded } from '../lib/session-coordinator';
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

export type PosTraceability = {
  variant_id: string;
  tracked_mode: string;
  draft_selection: boolean;
  reservation: string;
  serial_units: unknown[];
  lots: unknown[];
};

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
        return await session.request<{ data: PosTraceability }>('GET', '/pos/traceability', {
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
