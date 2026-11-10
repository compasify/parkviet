import type { PosVariantUnit } from '@parkviet/pos-shared/types/pos-context'
import { useQuery } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'
export function useVariantUnit(
  storeId: string | null,
  branchId: string | null,
  variantId: string | null,
) {
  const snapshot = useSession()
  return useQuery({
    queryKey: posKey(snapshot.storeId, 'variant-unit', storeId, branchId, variantId),
    enabled: snapshot.status === 'authenticated' && Boolean(storeId && branchId && variantId),
    queryFn: () =>
      posRequest<{ data: PosVariantUnit }>('GET', '/pos/units/variant', {
        params: { branch_id: branchId ?? undefined, variant_id: variantId ?? undefined },
      }),
  })
}
export type VariantUnitInput = {
  branch_id: string
  variant_id: string
  sale_unit: string
  base_unit: string
  price_unit: string
  ratio_numerator: number
  ratio_denominator: number
  tracked_mode: string
  label_code: string
}
export const saveVariantUnit = (input: VariantUnitInput) =>
  posRequest<{ data: PosVariantUnit }>('PUT', '/pos/units/variant', { body: input })
