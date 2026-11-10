import {
  type BranchFeatures,
  type FeatureSetting,
  isPosFeature,
  normalizeFeatures,
  POS_FEATURES,
  type PosFeature,
} from '@parkviet/pos-shared/pos-features'
import { queryClient } from '@spree/dashboard-core'
import { useMutation, useQuery } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'

export const branchFeaturesKey = (storeId: string, branchId: string | null) =>
  posKey(storeId, 'branch-features', branchId)
export function toBranchFeatures(
  branchId: string,
  response: {
    data: {
      branch_id?: string | null
      features?: unknown
      store_defaults?: unknown
      switches?: unknown
      settings?: unknown
    }
  },
): BranchFeatures {
  const data = response.data
  const id = data.branch_id ?? branchId
  const settings: FeatureSetting[] = (Array.isArray(data.settings) ? data.settings : []).flatMap(
    (row) =>
      row && isPosFeature(row.feature) && typeof row.enabled === 'boolean'
        ? [
            {
              feature: row.feature,
              enabled: row.enabled,
              branch_id: typeof row.branch_id === 'string' ? row.branch_id : null,
              reason: typeof row.reason === 'string' ? row.reason : '',
              changed_by_name: typeof row.changed_by_name === 'string' ? row.changed_by_name : null,
              changed_at: typeof row.changed_at === 'string' ? row.changed_at : null,
            },
          ]
        : [],
  )
  const switches =
    typeof data.switches === 'object' && data.switches !== null
      ? (data.switches as Record<string, Record<string, unknown> | undefined>)
      : null
  const pick = (read: (feature: PosFeature) => boolean) =>
    Object.fromEntries(POS_FEATURES.map((feature) => [feature, read(feature)]))
  return switches
    ? {
        branch_id: id,
        reported: true,
        features: pick((f) => switches[f]?.effective === true),
        store_defaults: pick((f) => switches[f]?.store === true),
        branch_off: pick((f) => switches[f]?.branch_override === false),
        settings,
      }
    : {
        branch_id: id,
        reported: normalizeFeatures(data.store_defaults) !== null,
        features: normalizeFeatures(data.features) ?? {},
        store_defaults: normalizeFeatures(data.store_defaults) ?? {},
        branch_off: pick((f) =>
          settings.some((row) => row.feature === f && row.branch_id === id && !row.enabled),
        ),
        settings,
      }
}
export function useBranchFeatures(branchId: string | null, enabled: boolean) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: branchFeaturesKey(storeId, branchId),
    enabled: enabled && status === 'authenticated' && Boolean(branchId),
    queryFn: async () =>
      toBranchFeatures(
        branchId ?? '',
        await posRequest('GET', '/pos/feature_flags', { params: { branch_id: branchId ?? '' } }),
      ),
  })
}
export async function setFeature(
  feature: PosFeature,
  enabled: boolean | null,
  reason: string,
  branchId?: string,
) {
  await posRequest('PUT', `/pos/feature_flags/${feature}`, {
    body: { ...(branchId ? { branch_id: branchId } : {}), enabled, reason },
  })
}
export function useFeatureMutation() {
  const { storeId } = useSession()
  return useMutation({
    mutationFn: (input: {
      feature: PosFeature
      enabled: boolean | null
      reason: string
      branchId?: string
    }) => setFeature(input.feature, input.enabled, input.reason, input.branchId),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ['pos', storeId] }),
  })
}
