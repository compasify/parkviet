import { describe, expect, it } from 'vitest';
import en from '../locales/en.json';
import vi from '../locales/vi.json';
import {
  VIETQR_CONFLICT_REASONS,
  type VietqrTenderSummary,
  vietqrConflictKey,
  vietqrEvidence,
  vietqrTimeLeft,
} from './vietqr';

const waiting: VietqrTenderSummary = {
  status: 'allocated',
  amount: 100000,
  attempt_id: 'tat_1',
  attempt_status: 'prepared',
};

describe('VietQR evidence', () => {
  it('confirms with the webhook once the bank reported the transfer', () => {
    expect(vietqrEvidence({ ...waiting, status: 'confirmed' }, null)).toEqual({
      evidenceKind: 'vietqr_webhook',
    });
    expect(
      vietqrEvidence({ ...waiting, status: 'confirmed' }, { reference: 'FT1', account: '01' }),
    ).toEqual({ evidenceKind: 'vietqr_webhook' });
  });

  it('attests by hand with the bank details as optional notes', () => {
    expect(vietqrEvidence(waiting, null)).toBeNull();
    expect(vietqrEvidence(waiting, { reference: ' ', account: '' })).toEqual({
      evidenceKind: 'vietqr_manual',
    });
    expect(vietqrEvidence(waiting, { reference: ' ', account: '0123' })).toEqual({
      evidenceKind: 'vietqr_manual',
      receivingAccount: '0123',
    });
    expect(vietqrEvidence(waiting, { reference: ' FT1 ', account: ' 0123 ' })).toEqual({
      evidenceKind: 'vietqr_manual',
      reference: 'FT1',
      receivingAccount: '0123',
    });
  });

  it('counts the QR down and stops at expiry', () => {
    const now = Date.parse('2026-11-08T10:00:00Z');
    expect(vietqrTimeLeft('2026-11-08T10:14:05Z', now)).toBe('14:05');
    expect(vietqrTimeLeft('2026-11-08T09:59:59Z', now)).toBeNull();
    expect(vietqrTimeLeft(null, now)).toBeNull();
  });

  it('explains every VietQR refusal in both languages', () => {
    for (const reason of VIETQR_CONFLICT_REASONS) {
      const key = vietqrConflictKey(reason) as string;
      expect(en).toHaveProperty([key]);
      expect(vi).toHaveProperty([key]);
    }
    expect(vietqrConflictKey('credit_limit_exceeded')).toBeNull();
  });
});
