// Delivery orders ("Đơn cần giao"): sales marked for delivery, pending until
// staff mark them delivered. Every figure comes from the server; these
// helpers only read, normalise what the cashier types and format.

export type DeliveryStatus = 'pending' | 'delivered';

export type PosDeliveryRow = {
  id: string;
  status: DeliveryStatus;
  deliverer: string | null;
  fee: string;
  delivered_at: string | null;
  delivered_by: string | null;
  order_id: string;
  order_number: string;
  workspace_id: string;
  placed_at: string | null;
  currency: string;
  total: string;
  paid: string;
  owed: string;
  customer: { name: string | null; phone: string | null; address: string | null } | null;
};

// Staff who sell or collect at the branch see the list and hand orders over.
export function canHandleDeliveries(capabilities: readonly string[] | undefined): boolean {
  return Boolean(
    capabilities?.includes('pos.shift.open') || capabilities?.includes('pos.payment.collect'),
  );
}

// A phone link the phone app opens: digits and a leading plus only.
export function telHref(phone: string | null | undefined): string | null {
  const raw = (phone ?? '').trim();
  const digits = raw.replace(/[^\d]/g, '');
  if (!digits) return null;
  return `tel:${raw.startsWith('+') ? '+' : ''}${digits}`;
}

// The fee as typed ("20.000", "20,000", "20 000" or "20000") in whole đồng,
// '0' when left empty, null when it is not a whole amount.
export function normalizeDeliveryFee(value: string): string | null {
  const text = value.trim().replace(/[\s.,]/g, '');
  if (text === '') return '0';
  if (!/^\d{1,9}$/.test(text)) return null;
  return String(Number(text));
}

// The deliverer as the server keeps it: inner spaces collapsed, at most 80.
export function normalizeDeliverer(value: string): string {
  return value.replace(/\s+/g, ' ').trim().slice(0, 80);
}

// Locale keys for the server's delivery refusals; others use the generic text.
export function deliveryFailureKey(reason: string | null): string | null {
  if (reason === 'delivery_fee_invalid') return 'deliveryFeeInvalid';
  if (reason === 'deliverer_invalid') return 'deliveryDelivererInvalid';
  if (reason === 'delivery_not_placed') return 'deliveriesNotPlaced';
  return null;
}

export const hasOwed = (row: Pick<PosDeliveryRow, 'owed'>) => /[1-9]/.test(row.owed);
