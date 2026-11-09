import { describe, expect, it } from 'vitest';
import {
  matchingPreset,
  ORDER_SOURCES,
  orderSourceOf,
  orderSourceRows,
  rangePreset,
} from './order-source';

describe('order sources', () => {
  it('keeps the fixed list and falls back to counter', () => {
    expect(ORDER_SOURCES).toEqual(['counter', 'facebook', 'zalo', 'other']);
    expect(orderSourceOf('zalo')).toBe('zalo');
    expect(orderSourceOf(undefined)).toBe('counter');
    expect(orderSourceOf('tiktok')).toBe('counter');
  });

  it('lists every source in order, with zeros for missing or malformed rows', () => {
    const rows = orderSourceRows([
      { order_source: 'zalo', orders: 2, sales_total: '60000.0', owed: '10000.0' },
      { order_source: 'facebook', orders: 1, sales_total: '20000.0', owed: '0.0' },
      'junk',
      null,
    ]);
    expect(rows.map((row) => row.order_source)).toEqual(['counter', 'facebook', 'zalo', 'other']);
    expect(rows[0]).toEqual({ order_source: 'counter', orders: 0, sales_total: '0', owed: '0' });
    expect(rows[2]).toEqual({
      order_source: 'zalo',
      orders: 2,
      sales_total: '60000.0',
      owed: '10000.0',
    });
    expect(orderSourceRows(undefined)).toHaveLength(4);
  });
});

describe('report range presets', () => {
  it('gives today, the last 7 days and this month as branch days', () => {
    expect(rangePreset('today', '2026-11-09')).toEqual({ from: '2026-11-09', to: '2026-11-09' });
    expect(rangePreset('last7', '2026-11-09')).toEqual({ from: '2026-11-03', to: '2026-11-09' });
    expect(rangePreset('last7', '2026-03-02')).toEqual({ from: '2026-02-24', to: '2026-03-02' });
    expect(rangePreset('month', '2026-11-09')).toEqual({ from: '2026-11-01', to: '2026-11-09' });
  });

  it('finds the preset a range matches', () => {
    expect(matchingPreset({ from: '2026-11-09', to: '2026-11-09' }, '2026-11-09')).toBe('today');
    expect(matchingPreset({ from: '2026-11-01', to: '2026-11-09' }, '2026-11-09')).toBe('month');
    expect(matchingPreset({ from: '2026-11-02', to: '2026-11-09' }, '2026-11-09')).toBeNull();
    // On the 1st, "this month" is today: today wins.
    expect(matchingPreset({ from: '2026-11-01', to: '2026-11-01' }, '2026-11-01')).toBe('today');
  });
});
