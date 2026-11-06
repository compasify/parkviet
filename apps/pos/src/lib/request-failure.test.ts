import { describe, expect, it } from 'vitest';
import { leaseConflict, posFailureKey } from './request-failure';

describe('lease conflict metadata', () => {
  it('preserves generic conflict handling while exposing an actionable lease reason', () => {
    const error = { status: 409, details: { reason: 'lease_busy', retry_after_seconds: 43.2 } };
    expect(posFailureKey(error)).toBe('conflict');
    expect(leaseConflict(error)).toEqual({ reason: 'lease_busy', seconds: 44 });
    expect(leaseConflict({ status: 409, details: { reason: 'lease_stale' } })?.reason).toBe(
      'lease_stale',
    );
  });
  it('rejects unrelated errors and bounds untrusted retry delays', () => {
    expect(leaseConflict(null)).toBeNull();
    expect(leaseConflict({ status: 403, details: { reason: 'lease_busy' } })).toBeNull();
    expect(leaseConflict({ status: 409, details: { reason: 'revision_changed' } })).toBeNull();
    expect(
      leaseConflict({ status: 409, details: { reason: 'lease_busy', retry_after_seconds: -10 } })
        ?.seconds,
    ).toBe(1);
    expect(
      leaseConflict({
        status: 409,
        details: { reason: 'lease_busy', retry_after_seconds: Infinity },
      })?.seconds,
    ).toBe(120);
  });
});
