import { describe, expect, it } from 'vitest';
import { parseCountQuantity, parseMeasuredQuantity } from './quantity';

describe('sale quantities', () => {
  it('accepts only whole counts from 1 to the server maximum for ordinary items', () => {
    expect(parseCountQuantity('3')).toBe(3);
    expect(parseCountQuantity(' 007 ')).toBe(7);
    expect(parseCountQuantity('10000')).toBe(10000);
    for (const bad of ['0', '10001', '1.5', '2.0', '-1', '', 'abc', '1e3', '99999999999999999999'])
      expect(parseCountQuantity(bad)).toBeNull();
  });

  it('keeps measured quantities as exact positive decimal strings', () => {
    expect(parseMeasuredQuantity('1.250')).toBe('1.25');
    expect(parseMeasuredQuantity('0.001')).toBe('0.001');
    for (const bad of ['0', '0.000', '-1', '1,5', ''])
      expect(parseMeasuredQuantity(bad)).toBeNull();
  });
});
