import { describe, expect, it } from 'vitest';
import { canReadReceivables, parseDueDays } from './receivables';

describe('credit terms', () => {
  it('accepts whole due days up to ten years', () => {
    expect(parseDueDays('30')).toBe(30);
    expect(parseDueDays(' 0 ')).toBe(0);
    expect(parseDueDays('3650')).toBe(3650);
    expect(parseDueDays('3651')).toBeNull();
    expect(parseDueDays('1.5')).toBeNull();
    expect(parseDueDays('')).toBeNull();
  });
  it('lets branch members read receivables but not store-wide topology roles alone', () => {
    expect(canReadReceivables(['pos.shift.open'])).toBe(true);
    expect(canReadReceivables(['pos.topology.manage', 'pos.topology.recover'])).toBe(false);
    expect(canReadReceivables(undefined)).toBe(false);
  });
});
