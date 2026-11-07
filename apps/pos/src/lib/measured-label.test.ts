import { describe, expect, it, vi } from 'vitest';
import { readMeasurementParse, resolveScan } from './measured-label';
import type { ScanCatalogPage } from './scan-lookup';

const label = {
  kind: 'measured_label',
  barcode: '2100012005008',
  capability: 'measured_labels',
  format_id: 'poslabel_1',
  format_version: 2,
  label_kind: 'weight',
  variant_id: 'variant_1',
  name: 'Thịt heo',
  sku: 'PORK',
  sale_quantity: '0.5',
  sale_unit: 'kg',
  base_quantity: 500,
  base_unit: 'g',
  unit_price: '120000.0',
  currency: 'VND',
  line_amount: '60000.0',
  label_amount: null,
};

const page = (data: ScanCatalogPage['data']): ScanCatalogPage => ({
  data,
  meta: { count: data.length },
});

describe('scan resolution with scale labels', () => {
  it('returns the server label without a catalog lookup', async () => {
    const parse = vi.fn().mockResolvedValue(label);
    const fetchPage = vi.fn();
    const outcome = await resolveScan(' 2100012005008 ', parse, fetchPage);
    expect(parse).toHaveBeenCalledWith('2100012005008');
    expect(fetchPage).not.toHaveBeenCalled();
    expect(outcome).toMatchObject({
      kind: 'label',
      label: { barcode: '2100012005008', variant_id: 'variant_1', sale_quantity: '0.5' },
    });
  });

  it('falls back to the exact barcode lookup for an ordinary code', async () => {
    const parse = vi
      .fn()
      .mockResolvedValue({ kind: 'ordinary', barcode: '893', measurement: null });
    const item = { id: 'v1', name: 'Nước', sku: 'W', barcode: '893', price: '5000' };
    const fetchPage = vi.fn().mockResolvedValue(page([item]));
    expect(await resolveScan('893', parse, fetchPage)).toEqual({ kind: 'match', item });
    expect(fetchPage).toHaveBeenCalledWith({ q: '893', barcode: true });
  });

  it('reports a refused label with the server explanation and adds nothing', async () => {
    const refusal = Object.assign(new Error('Label check digit is invalid.'), { status: 409 });
    const fetchPage = vi.fn();
    expect(
      await resolveScan('2100012005009', vi.fn().mockRejectedValue(refusal), fetchPage),
    ).toEqual({ kind: 'label_invalid', message: 'Label check digit is invalid.' });
    expect(fetchPage).not.toHaveBeenCalled();
  });

  it('lets network failures through so the scan stays pending', async () => {
    const offline = new TypeError('Failed to fetch');
    await expect(resolveScan('21', vi.fn().mockRejectedValue(offline), vi.fn())).rejects.toBe(
      offline,
    );
  });

  it('treats a malformed parse response as an unreadable label', async () => {
    expect(await resolveScan('21', vi.fn().mockResolvedValue({ kind: 'weird' }), vi.fn())).toEqual({
      kind: 'label_invalid',
      message: null,
    });
    expect(readMeasurementParse({ ...label, base_quantity: '500' })).toBeNull();
    expect(readMeasurementParse(null)).toBeNull();
  });

  it('does not ask the server about a blank code', async () => {
    const parse = vi.fn();
    expect(await resolveScan('  ', parse, vi.fn())).toEqual({ kind: 'none' });
    expect(parse).not.toHaveBeenCalled();
  });
});
