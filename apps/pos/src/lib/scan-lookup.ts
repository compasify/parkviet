export type ScanCatalogItem = {
  id: string;
  name: string;
  sku: string;
  barcode: string | null;
  price: string | null;
};

export type ScanCatalogPage = {
  data: ScanCatalogItem[];
  meta: { count: number; ambiguous?: boolean };
};

export type ScanLookup =
  | { kind: 'match'; item: ScanCatalogItem }
  | { kind: 'no_price'; item: ScanCatalogItem }
  | { kind: 'ambiguous' }
  | { kind: 'none' };

// Largest page the catalog endpoint serves; used so an exact SKU is not hidden
// behind pagination of looser substring matches.
export const SCAN_LOOKUP_LIMIT = 100;

function single(item: ScanCatalogItem): ScanLookup {
  return item.price === null ? { kind: 'no_price', item } : { kind: 'match', item };
}

// A scan adds an item only when exactly one variant carries that exact barcode
// or, failing that, that exact SKU. Anything else is left to the cashier.
export async function resolveScanCode(
  code: string,
  fetchPage: (params: { q: string; barcode: boolean }) => Promise<ScanCatalogPage>,
): Promise<ScanLookup> {
  const trimmed = code.trim();
  if (!trimmed) return { kind: 'none' };
  const byBarcode = await fetchPage({ q: trimmed, barcode: true });
  const barcodeHits = byBarcode.data.filter((item) => item.barcode === trimmed);
  if (byBarcode.meta.ambiguous || byBarcode.meta.count > 1 || barcodeHits.length > 1)
    return { kind: 'ambiguous' };
  if (byBarcode.meta.count === 1 && barcodeHits.length === 1) return single(barcodeHits[0]);
  if (byBarcode.meta.count === 1) return { kind: 'ambiguous' };

  const bySku = await fetchPage({ q: trimmed, barcode: false });
  const skuHits = bySku.data.filter((item) => item.sku === trimmed);
  if (skuHits.length > 1) return { kind: 'ambiguous' };
  if (skuHits.length === 1) {
    // Results beyond the first page could hold another variant with this SKU.
    if (bySku.meta.count > bySku.data.length) return { kind: 'ambiguous' };
    return single(skuHits[0]);
  }
  return { kind: 'none' };
}
