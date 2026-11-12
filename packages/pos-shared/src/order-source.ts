import {
  ORDER_SOURCES,
  type OrderSource,
  PLATFORM_ORDER_SOURCES,
  type PlatformOrderSource,
} from './types/pos-context';

export {
  KIOSK_ORDER_SOURCE,
  ORDER_SOURCES,
  type OrderSource,
  PICKABLE_ORDER_SOURCES,
  type PickableOrderSource,
  PLATFORM_ORDER_SOURCES,
  type PlatformOrderSource,
} from './types/pos-context';

// A delivery platform's order: its source is fixed and its payment is the platform's.
export function isPlatformSource(value: unknown): value is PlatformOrderSource {
  return PLATFORM_ORDER_SOURCES.includes(value as PlatformOrderSource);
}

// What the server sent, or counter when it is missing (older payloads) or unknown.
export function orderSourceOf(value: unknown): OrderSource {
  return ORDER_SOURCES.includes(value as OrderSource) ? (value as OrderSource) : 'counter';
}

// Locale key of a source's short label ("Tại quầy", "Facebook", …).
export const orderSourceKey = (source: OrderSource) => `orderSource_${source}`;

export type OrderSourceRow = {
  order_source: OrderSource;
  orders: number;
  sales_total: string;
  owed: string;
};

// The sales report's per-source summary, in the fixed order, every source
// listed (zeros for missing ones); anything malformed is dropped.
export function orderSourceRows(value: unknown): OrderSourceRow[] {
  const rows = Array.isArray(value) ? value : [];
  return ORDER_SOURCES.map((source) => {
    const row = rows.find(
      (item): item is Record<string, unknown> =>
        typeof item === 'object' && item !== null && item.order_source === source,
    );
    return {
      order_source: source,
      orders: Number(row?.orders ?? 0) || 0,
      sales_total: typeof row?.sales_total === 'string' ? row.sales_total : '0',
      owed: typeof row?.owed === 'string' ? row.owed : '0',
    };
  });
}

// Quick date picks of a report, as branch days (YYYY-MM-DD).
export const RANGE_PRESETS = ['today', 'last7', 'month'] as const;
export type RangePreset = (typeof RANGE_PRESETS)[number];

export function rangePreset(preset: RangePreset, today: string): { from: string; to: string } {
  if (preset === 'month') return { from: `${today.slice(0, 8)}01`, to: today };
  if (preset === 'last7') {
    const date = new Date(`${today}T00:00:00Z`);
    date.setUTCDate(date.getUTCDate() - 6);
    return { from: date.toISOString().slice(0, 10), to: today };
  }
  return { from: today, to: today };
}

// The preset a range matches, if any, so its chip shows as picked.
export function matchingPreset(range: { from: string; to: string }, today: string) {
  return (
    RANGE_PRESETS.find((preset) => {
      const candidate = rangePreset(preset, today);
      return candidate.from === range.from && candidate.to === range.to;
    }) ?? null
  );
}
