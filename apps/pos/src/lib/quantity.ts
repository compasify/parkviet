import { parseMoneyInput, parseVndAmount } from '@parkviet/pos-shared/money';

// The server rejects more than this many units of an ordinary item per line.
export const MAX_COUNT_QUANTITY = 10000;

// Ordinary items are counted in whole units; only measured items take decimals.
export function parseCountQuantity(input: string): number | null {
  if (!/^\d+$/.test(input.trim())) return null;
  const value = parseVndAmount(input);
  if (value === null) return null;
  const count = BigInt(value);
  return count >= 1n && count <= BigInt(MAX_COUNT_QUANTITY) ? Number(count) : null;
}

// Measured quantities stay canonical decimal strings; the server converts units.
export function parseMeasuredQuantity(input: string): string | null {
  const value = parseMoneyInput(input);
  return value !== null && /[1-9]/.test(value) ? value : null;
}
