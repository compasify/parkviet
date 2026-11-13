import { describe, expect, it } from 'vitest';
import { cashSuggestions, evenShare, groupVndDigits } from './cash-suggestions';

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
