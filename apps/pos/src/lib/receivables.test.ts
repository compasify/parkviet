import { describe, expect, it } from 'vitest';
import {
  amountSign,
  approvalExpired,
  canReadReceivables,
  cashChange,
  creditConflictKey,
  formatDueDate,
  formatInstant,
  planAllocations,
  previewAllocations,
  sumVnd,
} from './receivables';

describe('receivable display helpers', () => {
  it('reads the sign of canonical amounts instead of comparing strings', () => {
    expect(amountSign('0.0')).toBe(0);
    expect(amountSign('0')).toBe(0);
    expect(amountSign('0.00')).toBe(0);
    expect(amountSign('150000.0')).toBe(1);
    expect(amountSign('0.5')).toBe(1);
    expect(amountSign('-1.0')).toBe(-1);
    expect(amountSign(null)).toBe(0);
  });

  it('formats due dates as dd/MM/yyyy and instants in the store timezone', () => {
    expect(formatDueDate('2026-12-07')).toBe('07/12/2026');
    expect(formatDueDate(null)).toBe('—');
    expect(formatInstant('2026-11-07T17:30:00Z', 'vi-VN')).toContain('8/11/2026');
  });

  it('treats an approval as expired at or after its expiry time', () => {
    const now = Date.parse('2026-11-07T05:00:00Z');
    expect(approvalExpired('2026-11-07T05:00:00Z', now)).toBe(true);
    expect(approvalExpired('2026-11-07T05:05:00Z', now)).toBe(false);
    expect(approvalExpired(null, now)).toBe(true);
  });

  it('maps known conflict reasons to copy keys and ignores unknown ones', () => {
    expect(creditConflictKey('credit_limit_exceeded')).toBe('conflictReason_credit_limit_exceeded');
    expect(creditConflictKey('duplicate_reference')).toBe('conflictReason_duplicate_reference');
    expect(creditConflictKey('lease_stale')).toBeNull();
    expect(creditConflictKey(null)).toBeNull();
  });

  it('lets branch members read receivables but not store-role-only topology access', () => {
    expect(canReadReceivables(['pos.shift.open'])).toBe(true);
    expect(canReadReceivables(['pos.topology.manage', 'pos.topology.read'])).toBe(false);
    expect(canReadReceivables(undefined)).toBe(false);
  });
});

const debts = [
  { orderId: 'or_a', balance: '300000.0' },
  { orderId: 'or_b', balance: '200000.0' },
  { orderId: 'or_c', balance: '0.0' },
];

describe('debt collection preview', () => {
  it('sums canonical and plain whole VND without floating point', () => {
    expect(sumVnd(['300000.0', '200000', null, undefined])).toBe('500000');
    expect(sumVnd(['9007199254740993', '1'])).toBe('9007199254740994');
  });

  it('fills debts oldest first and stops when the money runs out', () => {
    expect(planAllocations('350000', debts)).toEqual([
      { orderId: 'or_a', amount: '300000' },
      { orderId: 'or_b', amount: '50000' },
    ]);
    expect(planAllocations('900000', debts)).toEqual([
      { orderId: 'or_a', amount: '300000' },
      { orderId: 'or_b', amount: '200000' },
    ]);
    expect(planAllocations('0', debts)).toEqual([]);
  });

  it('keeps an unallocated remainder and flags rows beyond the receipt or a debt', () => {
    const preview = previewAllocations('600000', planAllocations('600000', debts), debts);
    expect(preview).toEqual({
      allocated: '500000',
      unallocated: '100000',
      exceedsReceipt: false,
      overDebt: [],
      invalid: [],
    });

    const wrong = previewAllocations(
      '300000',
      [
        { orderId: 'or_a', amount: '310000' },
        { orderId: 'or_b', amount: '0' },
        { orderId: 'or_c', amount: '12,5' },
      ],
      debts,
    );
    expect(wrong.exceedsReceipt).toBe(true);
    expect(wrong.unallocated).toBe('0');
    expect(wrong.overDebt).toEqual(['or_a']);
    expect(wrong.invalid).toEqual(['or_b', 'or_c']);
  });

  it('computes cash change only when enough was handed', () => {
    expect(cashChange('400000', '350000')).toBe('50000');
    expect(cashChange('350000', '350000')).toBe('0');
    expect(cashChange('300000', '350000')).toBeNull();
    expect(cashChange(null, '350000')).toBeNull();
  });
});
