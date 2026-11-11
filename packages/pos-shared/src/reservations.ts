// Table bookings (`fnb.reservations`, GET /pos/reservations). A booking holds
// tables for a time; the server refuses overlaps. A deposit is money kept for
// the guest, never revenue: it comes off the bill of the seated party,
// goes back as a payout, or is kept as a taxed holding-fee sale — the last
// two only with an approval.

export const RESERVATIONS_MODULE = 'fnb.reservations';

export const RESERVATION_STATUSES = [
  'booked',
  'seated',
  'completed',
  'no_show',
  'canceled',
] as const;
export type ReservationStatus = (typeof RESERVATION_STATUSES)[number];

export const DEPOSIT_STATUSES = ['held', 'applied', 'refunded', 'forfeited'] as const;
export type DepositStatus = (typeof DEPOSIT_STATUSES)[number];

export const REFUND_DEPOSIT_ACTION = 'reservation.refund_deposit';
export const FORFEIT_DEPOSIT_ACTION = 'reservation.forfeit_deposit';

export type ReservationResource = {
  id: string;
  name: string;
  kind: string;
  area_id: string | null;
};

export type ReservationDeposit = {
  id: string;
  kind: string;
  amount: string;
  currency: string;
  status: DepositStatus;
  // What is left on its receipt, for the bill or a refund.
  available: string;
  received_at: string | null;
  resolved_at: string | null;
  resolution_order_id: string | null;
};

export type Reservation = {
  id: string;
  branch_id: string;
  status: ReservationStatus;
  source: string;
  guest_name: string;
  phone: string | null;
  party_size: number;
  note: string | null;
  starts_at: string;
  ends_at: string;
  revision: number;
  workspace_id: string | null;
  resources: ReservationResource[];
  deposits: ReservationDeposit[];
  deposit_held: string;
};

export type AvailableTable = ReservationResource & { capacity: number };

function record(value: unknown): Record<string, unknown> | null {
  return typeof value === 'object' && value !== null && !Array.isArray(value)
    ? (value as Record<string, unknown>)
    : null;
}

function text(value: unknown): string | null {
  return typeof value === 'string' ? value : null;
}

function int(value: unknown): number {
  return typeof value === 'number' && Number.isInteger(value) ? value : 0;
}

function oneOf<T extends string>(values: readonly T[], value: unknown, fallback: T): T {
  return values.includes(value as T) ? (value as T) : fallback;
}

function list<T>(value: unknown, read: (row: unknown) => T | null): T[] {
  return (Array.isArray(value) ? value : []).flatMap((row) => {
    const item = read(row);
    return item ? [item] : [];
  });
}

function resource(value: unknown): ReservationResource | null {
  const source = record(value);
  if (!source || typeof source.id !== 'string') return null;
  return {
    id: source.id,
    name: text(source.name) ?? '',
    kind: text(source.kind) ?? 'table',
    area_id: text(source.area_id),
  };
}

export function normalizeDeposit(value: unknown): ReservationDeposit | null {
  const source = record(value);
  if (!source || typeof source.id !== 'string') return null;
  return {
    id: source.id,
    kind: text(source.kind) ?? 'cash',
    amount: text(source.amount) ?? '0',
    currency: text(source.currency) ?? '',
    status: oneOf(DEPOSIT_STATUSES, source.status, 'held'),
    available: text(source.available) ?? '0',
    received_at: text(source.received_at),
    resolved_at: text(source.resolved_at),
    resolution_order_id: text(source.resolution_order_id),
  };
}

export function normalizeReservation(value: unknown): Reservation | null {
  const source = record(value);
  if (!source || typeof source.id !== 'string' || typeof source.starts_at !== 'string') return null;
  return {
    id: source.id,
    branch_id: text(source.branch_id) ?? '',
    status: oneOf(RESERVATION_STATUSES, source.status, 'booked'),
    source: text(source.source) ?? 'phone',
    guest_name: text(source.guest_name) ?? '',
    phone: text(source.phone),
    party_size: int(source.party_size),
    note: text(source.note),
    starts_at: source.starts_at,
    ends_at: text(source.ends_at) ?? source.starts_at,
    revision: int(source.revision),
    workspace_id: text(source.workspace_id),
    resources: list(source.resources, resource),
    deposits: list(source.deposits, normalizeDeposit),
    deposit_held: text(source.deposit_held) ?? '0',
  };
}

export function normalizeReservations(value: unknown): Reservation[] {
  return list(value, normalizeReservation).sort(
    (left, right) =>
      Date.parse(left.starts_at) - Date.parse(right.starts_at) || left.id.localeCompare(right.id),
  );
}

export function normalizeAvailableTables(value: unknown): AvailableTable[] {
  return list(value, (row) => {
    const base = resource(row);
    return base ? { ...base, capacity: int(record(row)?.capacity) } : null;
  });
}

// What the cashier may do with a booking now.
export function reservationActions(reservation: Pick<Reservation, 'status' | 'deposits'>) {
  const waiting = reservation.status === 'booked';
  const ended = reservation.status === 'canceled' || reservation.status === 'no_show';
  const held = reservation.deposits.some((row) => row.status === 'held');
  const refundable = reservation.deposits.some(
    (row) => (row.status === 'held' || row.status === 'applied') && Number(row.available) > 0,
  );
  return {
    seat: waiting,
    cancel: waiting,
    noShow: waiting,
    takeDeposit: waiting || reservation.status === 'seated',
    refundDeposit: refundable && reservation.status !== 'seated',
    forfeitDeposit: ended && held,
  };
}

// The minutes of a day a booking covers, clipped to the day, for a timeline row.
export function timelineSpan(
  reservation: Pick<Reservation, 'starts_at' | 'ends_at'>,
  dayStart: string,
): { start: number; end: number } | null {
  const origin = Date.parse(dayStart);
  const start = Date.parse(reservation.starts_at);
  const end = Date.parse(reservation.ends_at);
  if ([origin, start, end].some(Number.isNaN)) return null;
  const from = Math.max(0, Math.round((start - origin) / 60_000));
  const to = Math.min(24 * 60, Math.round((end - origin) / 60_000));
  return to > from ? { start: from, end: to } : null;
}

export function reservationStatusKey(status: ReservationStatus): string {
  return `reservationStatus_${status}`;
}

export function depositStatusKey(status: DepositStatus): string {
  return `depositStatus_${status}`;
}
