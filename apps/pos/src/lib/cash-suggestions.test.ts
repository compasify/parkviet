import { describe, expect, it } from 'vitest';
import { cashSuggestions, evenShare, groupVndDigits, payPreview } from './cash-suggestions';

describe('cashSuggestions', () => {
  it('rounds up to the notes a guest hands over, without repeats', () => {
    expect(cashSuggestions(672_400n)).toEqual([680_000n, 700_000n, 800_000n, 1_000_000n]);
  });

  it('skips a round amount itself, which the exact button already offers', () => {
    expect(cashSuggestions(100_000n)).toEqual([200_000n, 500_000n]);
  });

  it('offers nothing when nothing is due', () => {
    expect(cashSuggestions(0n)).toEqual([]);
    expect(cashSuggestions(-5n)).toEqual([]);
  });

  it('keeps to the limit', () => {
    expect(cashSuggestions(15_000n, 2)).toEqual([20_000n, 50_000n]);
  });
});

describe('groupVndDigits', () => {
  it('groups thousands with dots', () => {
    expect(groupVndDigits('1500000')).toBe('1.500.000');
    expect(groupVndDigits('900')).toBe('900');
  });
});

describe('evenShare', () => {
  it('rounds each part up so the parts cover the amount', () => {
    expect(evenShare(100_000n, 3)).toBe(33_334n);
    expect(evenShare(90_000n, 3)).toBe(30_000n);
  });

  it('keeps the amount for one part or less', () => {
    expect(evenShare(50_000n, 1)).toBe(50_000n);
    expect(evenShare(50_000n, 0)).toBe(50_000n);
    expect(evenShare(0n, 4)).toBe(0n);
  });
});

describe('payPreview', () => {
  it('pays what is due in cash and gives the rest back as change', () => {
    expect(payPreview({ due: 300_000n, share: null, cash: 500_000n, qr: 0n })).toEqual({
      cashTarget: 300_000n,
      cashPays: 300_000n,
      change: 200_000n,
      paysNow: 300_000n,
    });
  });

  it('takes a received QR off before the cash, as the server confirms it first', () => {
    expect(payPreview({ due: 300_000n, share: null, cash: 200_000n, qr: 150_000n })).toEqual({
      cashTarget: 150_000n,
      cashPays: 150_000n,
      change: 50_000n,
      paysNow: 300_000n,
    });
  });

  it('keeps the cash to an even part, after the QR as well', () => {
    expect(payPreview({ due: 300_000n, share: 100_000n, cash: 200_000n, qr: 0n })).toMatchObject({
      cashTarget: 100_000n,
      cashPays: 100_000n,
      change: 100_000n,
    });
    expect(
      payPreview({ due: 300_000n, share: 200_000n, cash: 200_000n, qr: 150_000n }),
    ).toMatchObject({
      cashTarget: 150_000n,
      cashPays: 150_000n,
      change: 50_000n,
      paysNow: 300_000n,
    });
  });

  it('pays part of what is due with too little cash, without change', () => {
    expect(payPreview({ due: 300_000n, share: null, cash: 100_000n, qr: 0n })).toEqual({
      cashTarget: 300_000n,
      cashPays: 100_000n,
      change: 0n,
      paysNow: 100_000n,
    });
  });

  it('takes no cash when the QR covers everything', () => {
    expect(payPreview({ due: 150_000n, share: null, cash: 50_000n, qr: 150_000n })).toEqual({
      cashTarget: 0n,
      cashPays: 0n,
      change: 0n,
      paysNow: 150_000n,
    });
    expect(payPreview({ due: 150_000n, share: null, cash: null, qr: 0n }).paysNow).toBe(0n);
  });
});
