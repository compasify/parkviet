import { describe, expect, it } from 'vitest';
import { describeShiftFailure } from './shifts';

describe('branch feature refusals in POS workflows', () => {
  it('is used by shift and cash describers too', () => {
    const refusal = {
      status: 409,
      message: 'Feature cash_moves is disabled for this branch.',
      details: { reason: 'feature_disabled', feature: 'cash_moves' },
    };
    expect(describeShiftFailure(refusal, (key) => key)).toBe('featureDisabled_cash_moves');
  });
});
