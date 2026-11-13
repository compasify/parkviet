import { describe, expect, it } from 'vitest';
import {
  describeFailure,
  leaseConflict,
  posFailureKey,
  serverFailureDetail,
  snapshotLocked,
} from './request-failure';

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

describe('server failure detail', () => {
  const translate = (key: string) => `t:${key}`;

  it('surfaces the server message and field details for conflicts and validation errors', () => {
    expect(
      serverFailureDetail({
        status: 422,
        message: 'Quantity is invalid.',
        details: {
          quantity: ['must be at most 10000'],
          base: [{ code: 'x', message: 'Line is locked.' }],
        },
      }),
    ).toBe('Quantity is invalid. quantity: must be at most 10000 Line is locked.');
    expect(serverFailureDetail({ status: 409, message: 'Revision changed.' })).toBe(
      'Revision changed.',
    );
  });

  it('ignores generic transport text, other statuses and non-array details', () => {
    expect(
      serverFailureDetail({ status: 422, message: 'Request failed with status 422' }),
    ).toBeNull();
    expect(serverFailureDetail({ status: 403, message: 'Forbidden.' })).toBeNull();
    expect(serverFailureDetail(new Error('offline'))).toBeNull();
    expect(
      serverFailureDetail({ status: 409, message: '', details: { reason: 'revision_changed' } }),
    ).toBeNull();
    expect(serverFailureDetail({ status: 422, message: 'x'.repeat(900) })?.length).toBe(500);
  });

  it('uses lease guidance first, then server text, then the localized fallback', () => {
    expect(
      describeFailure(
        { status: 409, message: 'Lease is stale.', details: { reason: 'lease_stale' } },
        translate,
      ),
    ).toBe('t:leaseStale');
    expect(describeFailure({ status: 409, details: { reason: 'lease_busy' } }, translate)).toBe(
      't:leaseBusy',
    );
    expect(describeFailure({ status: 422, message: 'Too much.' }, translate, 'noteFailed')).toBe(
      'Too much.',
    );
    expect(
      describeFailure(
        { status: 422, message: 'Request failed with status 422' },
        translate,
        'noteFailed',
      ),
    ).toBe('t:noteFailed');
    expect(describeFailure({ status: 403 }, translate)).toBe('t:forbidden');
    expect(describeFailure(new TypeError('fetch failed'), translate)).toBe('t:offline');
  });
});

describe('POS channel setup failures', () => {
  it.each([
    'pos_channel_missing',
    'pos_channel_inactive',
    'pos_channel_mismatch',
    'pos_product_unavailable',
    'payment_method_unavailable',
  ])('translates %s rather than exposing the English server message', (reason) => {
    expect(
      describeFailure(
        { status: 409, message: 'Server message', details: { reason } },
        (key) => `t:${key}`,
      ),
    ).toBe(`t:${reason}`);
  });
});

describe('frozen basket', () => {
  it('recognizes a basket locked by a tender and words it like the local lock', () => {
    const error = {
      status: 409,
      message: 'Snapshot locked.',
      details: { reason: 'snapshot_locked' },
    };
    expect(snapshotLocked(error)).toBe(true);
    expect(snapshotLocked({ status: 422, details: { reason: 'snapshot_locked' } })).toBe(false);
    expect(snapshotLocked({ status: 409, details: { reason: 'revision_changed' } })).toBe(false);
    expect(describeFailure(error, (key) => `t:${key}`)).toBe('t:editLockedPayments');
  });
});
