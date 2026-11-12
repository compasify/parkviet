import { GuestApiError } from './api';

// Refusals the page explains in its own words; anything else is generic.
const KNOWN = [
  'network',
  'rate_limited',
  'table_closed',
  'item_sold_out',
  'item_unavailable',
  'too_many_pending',
  'modifier_min',
  'modifier_max',
  'modifier_unknown',
  'note_too_long',
  'guest_order_invalid',
];

export function errorKey(error: unknown): string {
  const code = error instanceof GuestApiError ? error.code : 'unknown';
  return KNOWN.includes(code) ? `error_${code}` : 'error_unknown';
}

// Whether a refusal means the order may be sent again with the same key
// (nothing was recorded) or needs a new one (the cart must change first).
export function keepsKey(error: unknown): boolean {
  return (
    error instanceof GuestApiError && (error.code === 'network' || error.code === 'rate_limited')
  );
}
