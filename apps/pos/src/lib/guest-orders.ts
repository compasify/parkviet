// Guests' orders and requests from the table QR, as staff read them
// (GET /pos/guest_orders, /pos/guest_requests). Read tolerantly: a row
// without an id is skipped, unknown statuses are kept as sent.

export type GuestOrderItem = {
  name: string;
  size: string | null;
  quantity: number;
  amount: string;
  note: string | null;
  options: string[];
  // After a decision: whether the item went onto the order, and why not.
  outcome: 'added' | 'left_out' | null;
  reason: string | null;
};

export type GuestOrder = {
  id: string;
  workspace_id: string;
  resource_id: string;
  table_name: string;
  area_id: string | null;
  status: string;
  automatic: boolean;
  items: GuestOrderItem[];
  quoted_total: string;
  currency: string;
  reject_reason: string | null;
  created_at: string;
};

export type GuestRequest = {
  id: string;
  resource_id: string;
  table_name: string;
  area_id: string | null;
  workspace_id: string | null;
  kind: 'call_staff' | 'request_bill' | string;
  status: string;
  created_at: string;
};

// Refusals the tray explains in its own words; others use the shared text.
export const GUEST_ORDER_REASONS = [
  'guest_order_decided',
  'reason_required',
  'reason_invalid',
  'qr_order_unavailable',
  'table_closed',
] as const;

// Quick reasons offered when rejecting; staff may also type their own.
export const REJECT_PRESETS = ['sold_out', 'kitchen_closed', 'ask_staff'] as const;

type Row = Record<string, unknown>;
const record = (value: unknown): Row | null =>
  typeof value === 'object' && value !== null && !Array.isArray(value) ? (value as Row) : null;
const text = (value: unknown) => (typeof value === 'string' ? value : '');
const textOrNull = (value: unknown) => (typeof value === 'string' && value ? value : null);
const rows = (value: unknown) => (Array.isArray(value) ? value : []);

function item(value: unknown): GuestOrderItem | null {
  const row = record(value);
  if (!row || typeof row.name !== 'string') return null;
  const options = rows(row.modifiers).flatMap((pick) => {
    const option = record(pick);
    if (!option || typeof option.name !== 'string') return [];
    const quantity = Number(option.quantity);
    return [quantity > 1 ? `${option.name} x${quantity}` : option.name];
  });
  return {
    name: row.name,
    size: textOrNull(row.size),
    quantity: Number(row.quantity) || 1,
    amount: text(row.amount) || '0',
    note: textOrNull(row.note),
    options,
    outcome: row.outcome === 'added' || row.outcome === 'left_out' ? row.outcome : null,
    reason: textOrNull(row.reason),
  };
}

export function normalizeGuestOrders(value: unknown): GuestOrder[] {
  return rows(value).flatMap((entry) => {
    const row = record(entry);
    if (!row || typeof row.id !== 'string' || !row.id) return [];
    return [
      {
        id: row.id,
        workspace_id: text(row.workspace_id),
        resource_id: text(row.resource_id),
        table_name: text(row.table_name),
        area_id: textOrNull(row.area_id),
        status: text(row.status),
        automatic: row.automatic === true,
        items: rows(row.items).flatMap((line) => {
          const parsed = item(line);
          return parsed ? [parsed] : [];
        }),
        quoted_total: text(row.quoted_total) || '0',
        currency: text(row.currency) || 'VND',
        reject_reason: textOrNull(row.reject_reason),
        created_at: text(row.created_at),
      },
    ];
  });
}

export function normalizeGuestRequests(value: unknown): GuestRequest[] {
  return rows(value).flatMap((entry) => {
    const row = record(entry);
    if (!row || typeof row.id !== 'string' || !row.id) return [];
    return [
      {
        id: row.id,
        resource_id: text(row.resource_id),
        table_name: text(row.table_name),
        area_id: textOrNull(row.area_id),
        workspace_id: textOrNull(row.workspace_id),
        kind: text(row.kind),
        status: text(row.status),
        created_at: text(row.created_at),
      },
    ];
  });
}

// How many things wait for staff: pending orders and open requests.
export function waitingCount(orders: GuestOrder[], requests: GuestRequest[]): number {
  return (
    orders.filter((order) => order.status === 'pending').length +
    requests.filter((request) => request.status === 'open').length
  );
}
