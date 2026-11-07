// Branch feature flags: a manager can switch off each risky capability per
// branch. A switched-off feature hides or disables its entry points only; the
// pages that finish what was already started (pending payments, attention,
// refund resolution, receipts, existing returns) stay reachable, and the
// server refuses new commands with 409 `feature_disabled` either way.
export const POS_FEATURES = [
  'credit',
  'returns',
  'refunds',
  'exchanges',
  'traceability',
  'customer_display',
  'cash_moves',
  'exports',
] as const;

export type PosFeature = (typeof POS_FEATURES)[number];

export type PosFeatureFlags = Partial<Record<PosFeature, boolean>>;

export function isPosFeature(value: unknown): value is PosFeature {
  return typeof value === 'string' && (POS_FEATURES as readonly string[]).includes(value);
}

// Keeps only known flags with a real boolean; anything else reads as off.
export function normalizeFeatures(value: unknown): PosFeatureFlags | null {
  if (typeof value !== 'object' || value === null || Array.isArray(value)) return null;
  const record = value as Record<string, unknown>;
  return Object.fromEntries(POS_FEATURES.map((feature) => [feature, record[feature] === true]));
}

// A server without branch flags sends no `features` object: nothing is hidden.
// Once it sends one, a feature is on only when its flag is exactly `true`, so a
// missing or malformed flag fails closed.
export function featureEnabled(
  features: PosFeatureFlags | null | undefined,
  feature: PosFeature,
): boolean {
  if (features === null || features === undefined) return true;
  return features[feature] === true;
}

export function contextFeature(
  context: { features?: PosFeatureFlags | null } | undefined,
  feature: PosFeature,
): boolean {
  return featureEnabled(context?.features, feature);
}

// One stored switch: the store default (no branch) or a branch override.
export type FeatureSetting = {
  feature: PosFeature;
  enabled: boolean;
  branch_id: string | null;
  reason: string;
  changed_by_name: string | null;
  changed_at: string | null;
};

export type BranchFeatures = {
  branch_id: string;
  // Effective flags of the branch: store default on and not switched off here.
  features: PosFeatureFlags;
  store_defaults: PosFeatureFlags;
  // True where the branch switched the feature off.
  branch_off: PosFeatureFlags;
  settings: FeatureSetting[];
};

// The branch's own switch of a feature: false when switched off there, null
// when the branch follows the store.
export function branchOverride(flags: BranchFeatures, feature: PosFeature): false | null {
  return flags.branch_off[feature] === true ? false : null;
}

// Why a feature is off at the branch: the store keeps it off, or the branch did.
export function offReason(flags: BranchFeatures, feature: PosFeature): 'store' | 'branch' | null {
  if (flags.features[feature] === true) return null;
  if (flags.store_defaults[feature] !== true) return 'store';
  return branchOverride(flags, feature) === false ? 'branch' : 'store';
}
