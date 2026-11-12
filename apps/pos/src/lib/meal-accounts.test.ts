import { parseVndInput } from '@parkviet/pos-shared/money';
import { describe, expect, it } from 'vitest';
import {
  mealDue,
  mealReasonKey,
  normalizeMealAccount,
  normalizeMealEntries,
  normalizeMealStatus,
  parseSignedVnd,
} from './meal-accounts';

const account = {
  id: 'posmeal_1',
  employee_code: 'NV001',
  name: 'Nguyễn An',
  phone: null,
  customer_id: 'poscustomer_1',
  group_label: 'Kho',
  sponsor: { id: 'possponsor_1', name: 'Công ty A' },
  pay_mode: 'sponsor_subsidy',
  daily_meal_limit: 2,
  meal_windows: [{ key: 'lunch', from: '10:30', to: '13:30', limit: 1 }, { from: 'x' }],
  low_balance_threshold: '50000.0',
  balance: '120000.0',
  currency: 'VND',
  status: 'active',
  revision: 3,
  updated_at: '2026-11-12T03:00:00Z',
};

describe('meal accounts', () => {
  it('reads an account and drops rows the server would never send', () => {
    expect(normalizeMealAccount(account)).toMatchObject({
      id: 'posmeal_1',
      employee_code: 'NV001',
      sponsor: { id: 'possponsor_1', name: 'Công ty A' },
      pay_mode: 'sponsor_subsidy',
      meal_windows: [{ key: 'lunch', from: '10:30', to: '13:30', limit: 1 }],
      balance: '120000.0',
    });
    expect(normalizeMealAccount({ ...account, status: 'gone' })).toBeNull();
    expect(normalizeMealAccount({ ...account, employee_code: '' })).toBeNull();
    expect(normalizeMealAccount(null)).toBeNull();
    expect(normalizeMealAccount({ ...account, sponsor: null })?.sponsor).toBeNull();
  });

  it('reads the meal status with its split plan', () => {
    const status = normalizeMealStatus({
      ...account,
      meals_today: 1,
      meals_left: null,
      low_balance: true,
      wallet_covers: false,
      plan: { sponsor_amount: '25000.0', employee_amount: '10000.0', sponsor_unavailable: true },
    });
    expect(status).toMatchObject({ meals_today: 1, meals_left: null, low_balance: true });
    expect(status?.plan).toMatchObject({
      sponsor_amount: '25000.0',
      employee_amount: '10000.0',
      sponsor_unavailable: true,
    });
    expect(normalizeMealStatus({ ...account, plan: null })?.plan).toBeNull();
  });

  it('reads wallet history entries with signed amounts', () => {
    expect(
      normalizeMealEntries([
        { id: 'e1', kind: 'top_up', amount: '100000.0', actor: { id: 's', name: 'Lan' } },
        { id: 'e2', kind: 'spend', amount: '-35000.0', order_number: 'R100' },
        { id: 'e3', kind: 'bogus', amount: '1.0' },
        { id: 'e4', kind: 'adjust', amount: 'abc' },
      ]),
    ).toMatchObject([
      { id: 'e1', kind: 'top_up', actor: 'Lan' },
      { id: 'e2', kind: 'spend', amount: '-35000.0', order_number: 'R100' },
    ]);
    expect(normalizeMealEntries('nope')).toEqual([]);
  });

  it('splits what is still due between the sponsor and the eater', () => {
    const plan = normalizeMealStatus({
      ...account,
      plan: { sponsor_amount: '25000.0', employee_amount: '10000.0' },
    })?.plan;
    expect(mealDue('35000.0', plan)).toEqual({ sponsor: 25000n, eater: 10000n });
    expect(mealDue('25000.0', plan)).toEqual({ sponsor: 25000n, eater: 0n });
    expect(mealDue('0.0', plan)).toEqual({ sponsor: 25000n, eater: 0n });
    expect(mealDue('35000.0', null)).toEqual({ sponsor: 0n, eater: 35000n });
    expect(mealDue(undefined, null)).toEqual({ sponsor: 0n, eater: 0n });
  });

  it('names the refusal reasons that have their own text', () => {
    expect(mealReasonKey('meal_duplicate_swipe')).toBe('mealReason_meal_duplicate_swipe');
    expect(mealReasonKey('sponsor_limit')).toBe('mealReason_sponsor_limit');
    expect(mealReasonKey('lease_stale')).toBeNull();
    expect(mealReasonKey(null)).toBeNull();
  });

  it('reads a signed correction amount', () => {
    expect(parseSignedVnd('-10.000', parseVndInput)).toBe('-10000');
    expect(parseSignedVnd('+5000', parseVndInput)).toBe('5000');
    expect(parseSignedVnd('20000', parseVndInput)).toBe('20000');
    expect(parseSignedVnd('0', parseVndInput)).toBeNull();
    expect(parseSignedVnd('-1,5', parseVndInput)).toBeNull();
  });
});
