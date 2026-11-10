import { describe, expect, it } from 'vitest';
import {
  barcodeWidthMm,
  CODE128_PATTERNS,
  CODE128_STOP,
  code128Bars,
  code128Values,
  MAX_BARCODE_LENGTH,
} from './code128';

// Runs of equal modules: bar, space, bar, …
const runs = (pattern: string) => (pattern.match(/1+|0+/g) ?? []).map((run) => run.length);

describe('Code 128 patterns', () => {
  it('has one distinct, well-formed symbol per value', () => {
    expect(CODE128_PATTERNS).toHaveLength(106);
    expect(new Set(CODE128_PATTERNS).size).toBe(106);
    for (const pattern of CODE128_PATTERNS) {
      expect(pattern).toMatch(/^1[01]{9}0$/);
      const widths = runs(pattern);
      // Three bars and three spaces of one to four modules.
      expect(widths).toHaveLength(6);
      expect(widths.every((width) => width >= 1 && width <= 4)).toBe(true);
      // Bars always cover an even number of modules.
      const bars = widths.filter((_, index) => index % 2 === 0).reduce((a, b) => a + b, 0);
      expect(bars % 2).toBe(0);
    }
    expect(runs(CODE128_STOP)).toEqual([2, 3, 3, 1, 1, 1, 2]);
  });
});

describe('Code 128 encoding', () => {
  it('starts in set B and ends with the weighted check value', () => {
    // R=50, D=36, 3=19, 0=16: 104 + 50 + 36·2 + 19·3 + 16·4 + 16·5 = 427 ≡ 15.
    expect(code128Values('RD300')).toEqual([104, 50, 36, 19, 16, 16, 15]);
    expect(code128Values('HT000012-BS')?.at(-1)).toBeLessThan(103);
  });

  it('refuses text set B cannot carry or that is too long', () => {
    expect(code128Values('')).toBeNull();
    expect(code128Values('Đơn1')).toBeNull();
    expect(code128Values('A\tB')).toBeNull();
    expect(code128Values('9'.repeat(MAX_BARCODE_LENGTH))).not.toBeNull();
    expect(code128Values('9'.repeat(MAX_BARCODE_LENGTH + 1))).toBeNull();
  });

  it('lays the symbols out as merged bars', () => {
    const result = code128Bars('R1');
    // Start, two characters and the check value, then the stop.
    expect(result?.modules).toBe(4 * 11 + 13);
    const covered = result?.bars.reduce((total, bar) => total + bar.width, 0);
    const ones = [104, 50, 17, (104 + 50 + 17 * 2) % 103]
      .map((value) => CODE128_PATTERNS[value] ?? '')
      .join('')
      .concat(CODE128_STOP)
      .replace(/0/g, '').length;
    expect(covered).toBe(ones);
    expect(result?.bars[0]).toEqual({ x: 0, width: 2 });
    expect(code128Bars('Đ')).toBeNull();
  });
});

describe('barcode width', () => {
  it('prints at the preferred module width, narrower when needed, and not below the minimum', () => {
    // R100245: start, 7 characters, check, stop and quiet zones = 132 modules.
    expect(barcodeWidthMm('R100245', 72)).toBeCloseTo(132 * 0.33);
    expect(barcodeWidthMm('R100245', 40)).toBe(40);
    expect(barcodeWidthMm('R100245', 30)).toBeNull();
    // 10 characters (154 modules) fit a 58mm roll only squeezed to about 0.31mm.
    expect(barcodeWidthMm('HD00001234', 48)).toBe(48);
    // 24 characters need 80mm even at the minimum: A4 and A5 only.
    expect(barcodeWidthMm('9'.repeat(24), 72)).toBeNull();
    expect(barcodeWidthMm('9'.repeat(24), 128)).toBeCloseTo(319 * 0.33);
    expect(barcodeWidthMm('Đ', 186)).toBeNull();
  });
});
