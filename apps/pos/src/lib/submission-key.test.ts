import { describe, expect, it } from 'vitest';
import { createSubmissionKey, customerSubmissionContent } from './submission-key';

describe('submission idempotency key', () => {
  it('reuses the key for an identical resubmission until it succeeds', () => {
    let n = 0;
    const keys = createSubmissionKey(() => `k${++n}`);
    expect(keys.keyFor('a')).toBe('k1');
    expect(keys.keyFor('a')).toBe('k1');
    keys.settle('a');
    expect(keys.keyFor('a')).toBe('k2');
  });

  it('starts a new key when the submitted content changes', () => {
    let n = 0;
    const keys = createSubmissionKey(() => `k${++n}`);
    expect(keys.keyFor('a')).toBe('k1');
    expect(keys.keyFor('b')).toBe('k2');
    keys.settle('a');
    expect(keys.keyFor('b')).toBe('k2');
  });

  it('treats blank and missing optional customer fields as the same content', () => {
    expect(
      customerSubmissionContent({ branchId: 'br', name: 'Lan', phone: '090', email: '' }),
    ).toBe(customerSubmissionContent({ branchId: 'br', name: 'Lan', phone: '090' }));
    expect(customerSubmissionContent({ branchId: 'br', name: 'Lan', phone: '090' })).not.toBe(
      customerSubmissionContent({ branchId: 'br', name: 'Lan', phone: '091' }),
    );
  });
});
