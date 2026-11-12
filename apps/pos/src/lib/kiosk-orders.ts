// Orders self-ordering kiosks left for the counter, as cashiers read them
// (GET /pos/kiosk_orders): the guest chose to pay at the counter, or the bank
// QR ran out. Read tolerantly: a row without an id is skipped.

export type KioskOrder = {
  id: string;
  order_number: string;
  call_number: number | null;
  status: string;
  register_name: string | null;
  total: string;
  currency: string;
  item_count: number;
  waiting_since: string;
  // Waiting longer than half an hour: the guest probably walked away.
  abandoned: boolean;
};

// Refusals the tray explains in its own words; others use the shared text.
export const KIOSK_ORDER_REASONS = [
  'kiosk_order_taken',
  'kiosk_qr_open',
  'kiosk_paid',
  'no_open_shift',
  'payments_recorded',
] as const;

type Row = Record<string, unknown>;
const record = (value: unknown): Row | null =>
  typeof value === 'object' && value !== null && !Array.isArray(value) ? (value as Row) : null;
const text = (value: unknown) => (typeof value === 'string' ? value : '');

export function normalizeKioskOrders(value: unknown): KioskOrder[] {
  const rows = Array.isArray(value) ? value : [];
  return rows.flatMap((item) => {
    const row = record(item);
    const id = text(row?.id);
    if (!row || !id) return [];
    const register = record(row.register);
    const callNumber = Number(row.call_number);
    return [
      {
        id,
        order_number: text(row.order_number),
        call_number: row.call_number === null || !Number.isInteger(callNumber) ? null : callNumber,
        status: text(row.status),
        register_name: register ? text(register.name) || null : null,
        total: text(row.total) || '0',
        currency: text(row.currency) || 'VND',
        item_count: Number(row.item_count) || 0,
        waiting_since: text(row.waiting_since),
        abandoned: row.abandoned === true,
      },
    ];
  });
}

// Whole minutes an order has waited at `now`, never below zero.
export function waitingMinutes(order: KioskOrder, now: number): number {
  const since = Date.parse(order.waiting_since);
  if (Number.isNaN(since)) return 0;
  return Math.max(0, Math.floor((now - since) / 60_000));
}

// Cashiers collect kiosk orders: they need to open a shift and take payments.
export function canCollectKioskOrders(capabilities: readonly string[] | undefined): boolean {
  return Boolean(
    capabilities?.includes('pos.shift.open') && capabilities.includes('pos.payment.collect'),
  );
}
