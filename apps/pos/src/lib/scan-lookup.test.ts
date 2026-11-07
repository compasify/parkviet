import { describe, expect, it, vi } from 'vitest';
import { resolveScanCode, type ScanCatalogItem, type ScanCatalogPage } from './scan-lookup';

const item = (id: string, sku: string, barcode: string | null, price: string | null = '1000') =>
  ({ id, name: id, sku, barcode, price }) satisfies ScanCatalogItem;
const page = (
  data: ScanCatalogItem[],
  count = data.length,
  ambiguous = false,
): ScanCatalogPage => ({
  data,
  meta: { count, ambiguous },
});

describe('scan code resolution', () => {
  it('adds the single exact barcode match without a second lookup', async () => {
    const fetchPage = vi.fn().mockResolvedValueOnce(page([item('v1', 'A', '893')]));
    expect(await resolveScanCode(' 893 ', fetchPage)).toEqual({
      kind: 'match',
      item: item('v1', 'A', '893'),
    });
    expect(fetchPage).toHaveBeenCalledTimes(1);
    expect(fetchPage).toHaveBeenCalledWith({ q: '893', barcode: true });
  });

  it('never guesses between several variants sharing a barcode', async () => {
    const fetchPage = vi
      .fn()
      .mockResolvedValueOnce(page([item('v1', 'A', '893'), item('v2', 'B', '893')], 2, true));
    expect(await resolveScanCode('893', fetchPage)).toEqual({ kind: 'ambiguous' });
  });

  it('falls back to an exact SKU, ignoring substring matches', async () => {
    const fetchPage = vi
      .fn()
      .mockResolvedValueOnce(page([]))
      .mockResolvedValueOnce(page([item('v1', 'AO-1', null), item('v2', 'AO', null)]));
    expect(await resolveScanCode('AO', fetchPage)).toEqual({
      kind: 'match',
      item: item('v2', 'AO', null),
    });
    expect(fetchPage).toHaveBeenLastCalledWith({ q: 'AO', barcode: false });
  });

  it('reports no match, unpriced items and SKUs that may continue on another page', async () => {
    const none = vi
      .fn()
      .mockResolvedValueOnce(page([]))
      .mockResolvedValueOnce(page([item('v', 'AOX', null)]));
    expect(await resolveScanCode('AO', none)).toEqual({ kind: 'none' });
    const unpriced = vi.fn().mockResolvedValueOnce(page([item('v1', 'A', '893', null)]));
    expect((await resolveScanCode('893', unpriced)).kind).toBe('no_price');
    const truncated = vi
      .fn()
      .mockResolvedValueOnce(page([]))
      .mockResolvedValueOnce(page([item('v2', 'AO', null)], 150));
    expect(await resolveScanCode('AO', truncated)).toEqual({ kind: 'ambiguous' });
    const empty = vi.fn();
    expect(await resolveScanCode('  ', empty)).toEqual({ kind: 'none' });
    expect(empty).not.toHaveBeenCalled();
  });
});
