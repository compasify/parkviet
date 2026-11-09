import { describe, expect, it } from 'vitest';
import {
  branchOverride,
  contextFeature,
  featureEnabled,
  normalizeFeatures,
  offReason,
  POS_FEATURES,
} from './pos-features';
import { describeFailure, featureDisabledText } from './request-failure';
import { describeShiftFailure } from './shifts';

const translate = (key: string) => key;
const refusal = (details: Record<string, unknown>) => ({
  status: 409,
  message: 'Feature credit is disabled for this branch.',
  details: { reason: 'feature_disabled', ...details },
});

describe('branch feature flags', () => {
  it('hides nothing when the server sends no flags', () => {
    for (const feature of POS_FEATURES) {
      expect(featureEnabled(undefined, feature)).toBe(true);
      expect(featureEnabled(null, feature)).toBe(true);
      expect(contextFeature(undefined, feature)).toBe(true);
      expect(contextFeature({}, feature)).toBe(true);
    }
  });

  it('turns a feature on only for an explicit true once flags are sent', () => {
    const flags = normalizeFeatures({ credit: true, returns: 'yes', refunds: 1, unknown: true });
    expect(flags).toEqual({
      credit: true,
      returns: false,
      refunds: false,
      exchanges: false,
      traceability: false,
      customer_display: false,
      cash_moves: false,
      exports: false,
      vietqr: false,
      edit_lease: false,
      quick_credit: false,
    });
    expect(featureEnabled(flags, 'credit')).toBe(true);
    expect(featureEnabled(flags, 'returns')).toBe(false);
    expect(featureEnabled({}, 'exports')).toBe(false);
    expect(contextFeature({ features: { credit: false } }, 'credit')).toBe(false);
  });

  it('reads no flags from a value that is not an object', () => {
    expect(normalizeFeatures(undefined)).toBeNull();
    expect(normalizeFeatures(null)).toBeNull();
    expect(normalizeFeatures(['credit'])).toBeNull();
    expect(normalizeFeatures('credit')).toBeNull();
  });
});

describe('why a feature is off at a branch', () => {
  const flags = {
    branch_id: 'br_1',
    reported: true,
    features: { credit: false, returns: false, refunds: false, exports: true },
    store_defaults: { credit: false, returns: true, refunds: false, exports: true },
    branch_off: { returns: true, refunds: true },
    settings: [],
  };

  it('blames the store when its default is off and the branch when it switched off', () => {
    expect(offReason(flags, 'credit')).toBe('store');
    expect(offReason(flags, 'returns')).toBe('branch');
    expect(offReason(flags, 'exports')).toBeNull();
    expect(branchOverride(flags, 'returns')).toBe(false);
    expect(branchOverride(flags, 'credit')).toBeNull();
  });

  it('names the store first when both keep a feature off', () => {
    expect(offReason(flags, 'refunds')).toBe('store');
  });
});

describe('feature_disabled refusals', () => {
  it('names the feature the server refused', () => {
    expect(featureDisabledText(refusal({ feature: 'credit' }), translate)).toBe(
      'featureDisabled_credit',
    );
    expect(describeFailure(refusal({ feature: 'returns' }), translate)).toBe(
      'featureDisabled_returns',
    );
  });

  it('falls back to the generic text for a missing or unknown feature', () => {
    expect(describeFailure(refusal({}), translate)).toBe('featureDisabled');
    expect(describeFailure(refusal({ feature: 'teleport' }), translate)).toBe('featureDisabled');
  });

  it('is used by shift and cash describers too', () => {
    expect(describeShiftFailure(refusal({ feature: 'cash_moves' }), translate)).toBe(
      'featureDisabled_cash_moves',
    );
  });

  it('leaves other conflicts alone', () => {
    const other = { status: 409, message: 'Changed.', details: { reason: 'stale_revision' } };
    expect(featureDisabledText(other, translate)).toBeNull();
    expect(describeFailure(other, translate)).toBe('Changed.');
    expect(
      featureDisabledText({ status: 422, details: { reason: 'feature_disabled' } }, translate),
    ).toBeNull();
  });
});
