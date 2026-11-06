import { describe, expect, it } from 'vitest';
import { assignInvoiceNumbers, emptyOptions, onlyActiveOption } from './pos-selection-rules';

describe('selection defaults', () => {
  it('defaults only a complete sole active option, never a page or a disabled record', () => {
    const row = { id: 'br_1', status: 'active' };
    expect(onlyActiveOption({ data: [row], meta: { page: 1, pages: 1, count: 1 } })).toEqual(row);
    expect(onlyActiveOption({ data: [row], meta: { page: 1, pages: 2, count: 26 } })).toBeNull();
    expect(
      onlyActiveOption({ data: [{ ...row, status: 'disabled' }], meta: { page: 1, pages: 1 } }),
    ).toBeNull();
    expect(onlyActiveOption(undefined)).toBeNull();
  });
  it('does not treat missing or partial results as zero registers', () => {
    expect(emptyOptions(undefined)).toBe(false);
    expect(emptyOptions({ data: [], meta: { page: 1, pages: 2, count: 1 } })).toBe(false);
    expect(emptyOptions({ data: [], meta: { page: 1, pages: 0, count: 0 } })).toBe(true);
  });
});

describe('local invoice labels', () => {
  it('allocates in creation order and preserves existing labels on reordered results', () => {
    expect(assignInvoiceNumbers({}, ['a', 'b'], [])).toEqual({ a: 1, b: 2 });
    expect(assignInvoiceNumbers({ a: 1, b: 2 }, ['b', 'a', 'c'], [])).toEqual({ a: 1, b: 2, c: 3 });
  });
  it('uses the highest still-open number, without renumbering other tabs', () => {
    expect(assignInvoiceNumbers({ a: 1, b: 2, c: 3 }, ['a', 'c', 'd'], ['b'])).toEqual({
      a: 1,
      c: 3,
      d: 4,
    });
    expect(assignInvoiceNumbers({ a: 1, b: 2, c: 3 }, ['a', 'b', 'd'], ['c'])).toEqual({
      a: 1,
      b: 2,
      d: 3,
    });
    expect(assignInvoiceNumbers({ a: 1 }, ['b'], ['a'])).toEqual({ b: 1 });
  });
  it('keeps labels for still-open tabs that are not on the loaded server page', () => {
    expect(assignInvoiceNumbers({ a: 1, b: 2 }, ['c'], [])).toEqual({ a: 1, b: 2, c: 3 });
  });
});
