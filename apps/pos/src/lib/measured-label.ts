import { posFailureKey, serverFailureDetail } from './request-failure';
import { resolveScanCode, type ScanCatalogPage, type ScanLookup } from './scan-lookup';

// Server preview of a scale label. Display only: adding the line makes the
// server read the label again, so nothing here is sent back as a quantity or price.
export type MeasuredLabel = {
  kind: 'measured_label';
  barcode: string;
  variant_id: string;
  name: string;
  sku: string | null;
  sale_quantity: string;
  sale_unit: string;
  base_quantity: number;
  base_unit: string;
  unit_price: string | null;
  line_amount: string | null;
  label_amount: string | null;
  label_kind: 'weight' | 'price';
  format_version: number;
};

export type ScanOutcome =
  | ScanLookup
  | { kind: 'label'; label: MeasuredLabel }
  // A branch label format claimed the code but the server refused it; the
  // message is the server's explanation, or null when it gave none.
  | { kind: 'label_invalid'; message: string | null };

const text = (value: unknown): value is string => typeof value === 'string';
const optionalText = (value: unknown) => value === null || value === undefined || text(value);

// Validates the parse response at the boundary. Returns null for a malformed body.
export function readMeasurementParse(data: unknown): { kind: 'ordinary' } | MeasuredLabel | null {
  if (typeof data !== 'object' || data === null || !('kind' in data)) return null;
  if (data.kind === 'ordinary') return { kind: 'ordinary' };
  if (data.kind !== 'measured_label') return null;
  const label = data as Record<string, unknown>;
  if (
    !text(label.barcode) ||
    !text(label.variant_id) ||
    !text(label.name) ||
    !text(label.sale_quantity) ||
    !text(label.sale_unit) ||
    !text(label.base_unit) ||
    typeof label.base_quantity !== 'number' ||
    typeof label.format_version !== 'number' ||
    (label.label_kind !== 'weight' && label.label_kind !== 'price') ||
    !optionalText(label.sku) ||
    !optionalText(label.unit_price) ||
    !optionalText(label.line_amount) ||
    !optionalText(label.label_amount)
  )
    return null;
  return {
    kind: 'measured_label',
    barcode: label.barcode,
    variant_id: label.variant_id,
    name: label.name,
    sku: (label.sku as string | null | undefined) ?? null,
    sale_quantity: label.sale_quantity,
    sale_unit: label.sale_unit,
    base_quantity: label.base_quantity,
    base_unit: label.base_unit,
    unit_price: (label.unit_price as string | null | undefined) ?? null,
    line_amount: (label.line_amount as string | null | undefined) ?? null,
    label_amount: (label.label_amount as string | null | undefined) ?? null,
    label_kind: label.label_kind,
    format_version: label.format_version,
  };
}

// The branch's label formats decide first whether a code is a scale label.
// Only an ordinary code goes on to the exact barcode/SKU catalog lookup.
export async function resolveScan(
  code: string,
  parse: (barcode: string) => Promise<unknown>,
  fetchPage: (params: { q: string; barcode: boolean }) => Promise<ScanCatalogPage>,
): Promise<ScanOutcome> {
  const trimmed = code.trim();
  if (!trimmed) return { kind: 'none' };
  let parsed: ReturnType<typeof readMeasurementParse>;
  try {
    parsed = readMeasurementParse(await parse(trimmed));
  } catch (error) {
    if (posFailureKey(error) === 'conflict')
      return { kind: 'label_invalid', message: serverFailureDetail(error) };
    throw error;
  }
  if (parsed === null) return { kind: 'label_invalid', message: null };
  if (parsed.kind === 'measured_label') return { kind: 'label', label: parsed };
  return resolveScanCode(trimmed, fetchPage);
}
