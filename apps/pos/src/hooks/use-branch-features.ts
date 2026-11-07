import { useQuery } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import {
  type BranchFeatures,
  type FeatureSetting,
  isPosFeature,
  normalizeFeatures,
  POS_FEATURES,
  type PosFeature,
} from '../lib/pos-features';
import { posFailureKey } from '../lib/request-failure';
import { SessionSuperseded } from '../lib/session-coordinator';
import { useSession } from './use-session';

type FeaturesResponse = {
  data: {
    branch_id?: string | null;
    features?: unknown;
    store_defaults?: unknown;
    switches?: unknown;
    settings?: unknown;
  };
};

export const branchFeaturesKey = (generation: number, branchId: string | null) =>
  ['pos', 'branch-features', generation, branchId] as const;

function toSetting(value: unknown): FeatureSetting[] {
  if (typeof value !== 'object' || value === null) return [];
  const row = value as Record<string, unknown>;
  if (!isPosFeature(row.feature) || typeof row.enabled !== 'boolean') return [];
  return [
    {
      feature: row.feature,
      enabled: row.enabled,
      branch_id: typeof row.branch_id === 'string' ? row.branch_id : null,
      reason: typeof row.reason === 'string' ? row.reason : '',
      changed_by_name: typeof row.changed_by_name === 'string' ? row.changed_by_name : null,
      changed_at: typeof row.changed_at === 'string' ? row.changed_at : null,
    },
  ];
}

// `switches` gives, per feature, the store default, the branch override (only
// ever `false`) and the effective value. Older answers carried the store
// defaults and the stored rows instead; both read the same way. A value the
// server did not send reads as off, like in the context.
function toBranchFeatures(branchId: string, response: FeaturesResponse): BranchFeatures {
  const id = response.data.branch_id ?? branchId;
  const settings = Array.isArray(response.data.settings)
    ? response.data.settings.flatMap(toSetting)
    : [];
  const switches =
    typeof response.data.switches === 'object' && response.data.switches !== null
      ? (response.data.switches as Record<string, Record<string, unknown> | undefined>)
      : null;
  const pick = (read: (feature: PosFeature) => boolean) =>
    Object.fromEntries(POS_FEATURES.map((feature) => [feature, read(feature)]));
  if (switches)
    return {
      branch_id: id,
      reported: true,
      features: pick((feature) => switches[feature]?.effective === true),
      store_defaults: pick((feature) => switches[feature]?.store === true),
      branch_off: pick((feature) => switches[feature]?.branch_override === false),
      settings,
    };
  return {
    branch_id: id,
    reported: normalizeFeatures(response.data.store_defaults) !== null,
    features: normalizeFeatures(response.data.features) ?? {},
    store_defaults: normalizeFeatures(response.data.store_defaults) ?? {},
    branch_off: pick((feature) =>
      settings.some((row) => row.feature === feature && row.branch_id === id && !row.enabled),
    ),
    settings,
  };
}

async function request(
  method: 'GET' | 'PUT',
  path: string,
  options: { body?: unknown; params?: Record<string, string> },
) {
  try {
    return await session.request<FeaturesResponse>(method, path, options);
  } catch (error) {
    if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized')
      session.abandon();
    throw error;
  }
}

export function useBranchFeatures(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: branchFeaturesKey(snapshot.generation, branchId),
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    queryFn: async () =>
      toBranchFeatures(
        branchId ?? '',
        await request('GET', '/pos/feature_flags', { params: { branch_id: branchId ?? '' } }),
      ),
  });
}

// A feature runs at a branch only when the store default is on and the branch
// has not switched it off. Without a branch id this sets the store default
// (store administrators); with one it sets the branch override, which can only
// switch the feature off (false) or drop that switch (null). The server
// requires a reason and audits every change.
export async function setFeature(
  feature: PosFeature,
  enabled: boolean | null,
  reason: string,
  branchId?: string,
) {
  await request('PUT', `/pos/feature_flags/${feature}`, {
    body: { ...(branchId ? { branch_id: branchId } : {}), enabled, reason },
  });
}
