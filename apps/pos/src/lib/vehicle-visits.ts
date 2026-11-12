// Coach visits at a rest stop as the counter reads them: the coach, its
// guests, the commission kept when it closed and how it was paid. Money stays
// the server's decimal strings.

export const VEHICLE_COMMISSION_MODULE = 'fnb.vehicle_commission';
export const VEHICLE_TYPES = ['seat_16', 'seat_29', 'seat_45', 'other'] as const;

export type VehicleType = (typeof VEHICLE_TYPES)[number];
export type VehicleVisitStatus = 'open' | 'closed' | 'paid' | 'voided';
export type VehiclePayoutStatus = 'requested' | 'paid' | 'canceled';

export type VehicleCommission = {
  amount: string;
  vehicle_amount: string;
  guest_amount: string;
  qualified: boolean;
  reason: 'no_rule' | 'min_guests' | 'min_revenue' | null;
  rule_name: string | null;
  manual: boolean;
};

export type VehicleVisit = {
  id: string;
  plate: string;
  vehicle_type: VehicleType;
  bus_operator: { id: string; name: string } | null;
  driver_name: string | null;
  driver_phone: string | null;
  guest_count: number;
  arrived_at: string;
  closes_at: string;
  closed_at: string | null;
  auto_closed: boolean;
  status: VehicleVisitStatus;
  business_date: string;
  revenue_amount: string | null;
  commission_amount: string | null;
  currency: string;
  commission: VehicleCommission | null;
  payout_method: 'cash' | 'transfer' | null;
  payout_status: VehiclePayoutStatus | null;
  transfer_reference: string | null;
  void_reason: string | null;
  revision: number;
  workspaces_count: number | null;
  warnings: string[];
};

const STATUSES: readonly VehicleVisitStatus[] = ['open', 'closed', 'paid', 'voided'];
const PAYOUT_STATUSES: readonly VehiclePayoutStatus[] = ['requested', 'paid', 'canceled'];
const REASONS = ['no_rule', 'min_guests', 'min_revenue'] as const;

function record(value: unknown): Record<string, unknown> | null {
  return value && typeof value === 'object' && !Array.isArray(value)
    ? (value as Record<string, unknown>)
    : null;
}

function text(value: unknown): string | null {
  return typeof value === 'string' && value !== '' ? value : null;
}

function money(value: unknown): string | null {
  return typeof value === 'string' && /^-?\d+(\.\d+)?$/.test(value) ? value : null;
}

function commission(value: unknown): VehicleCommission | null {
  const row = record(value);
  if (!row) return null;
  const reason = REASONS.find((item) => item === row.reason) ?? null;
  return {
    amount: money(row.amount) ?? '0',
    vehicle_amount: money(row.vehicle_amount) ?? '0',
    guest_amount: money(row.guest_amount) ?? '0',
    qualified: row.qualified === true,
    reason,
    rule_name: text(record(row.rule)?.name),
    manual: row.manual === true,
  };
}

export function normalizeVehicleVisit(value: unknown): VehicleVisit | null {
  const row = record(value);
  const id = text(row?.id);
  const plate = text(row?.plate);
  const status = STATUSES.find((item) => item === row?.status);
  if (!row || !id || !plate || !status) return null;
  const operator = record(row.bus_operator);
  const operatorId = text(operator?.id);
  const type = VEHICLE_TYPES.find((item) => item === row.vehicle_type) ?? 'other';
  const method =
    row.payout_method === 'cash' || row.payout_method === 'transfer' ? row.payout_method : null;
  return {
    id,
    plate,
    vehicle_type: type,
    bus_operator:
      operator && operatorId ? { id: operatorId, name: text(operator.name) ?? '' } : null,
    driver_name: text(row.driver_name),
    driver_phone: text(row.driver_phone),
    guest_count: typeof row.guest_count === 'number' ? row.guest_count : 0,
    arrived_at: text(row.arrived_at) ?? '',
    closes_at: text(row.closes_at) ?? '',
    closed_at: text(row.closed_at),
    auto_closed: row.auto_closed === true,
    status,
    business_date: text(row.business_date) ?? '',
    revenue_amount: money(row.revenue_amount),
    commission_amount: money(row.commission_amount),
    currency: text(row.currency) ?? 'VND',
    commission: commission(row.commission),
    payout_method: method,
    payout_status: PAYOUT_STATUSES.find((item) => item === row.payout_status) ?? null,
    transfer_reference: text(row.transfer_reference),
    void_reason: text(row.void_reason),
    revision: typeof row.revision === 'number' ? row.revision : 0,
    workspaces_count: typeof row.workspaces_count === 'number' ? row.workspaces_count : null,
    warnings: Array.isArray(row.warnings)
      ? row.warnings.filter((item) => typeof item === 'string')
      : [],
  };
}

export function normalizeVehicleVisits(value: unknown): VehicleVisit[] {
  return Array.isArray(value)
    ? value.map(normalizeVehicleVisit).filter((row): row is VehicleVisit => row !== null)
    : [];
}

// Whole minutes until an open visit closes by itself; never below zero.
export function minutesLeft(visit: Pick<VehicleVisit, 'closes_at'>, now: number): number {
  const closes = Date.parse(visit.closes_at);
  if (Number.isNaN(closes)) return 0;
  return Math.max(0, Math.ceil((closes - now) / 60_000));
}

// What the screen may do with a visit, by its state and the reader's rights.
export function visitActions(visit: VehicleVisit, canManage: boolean) {
  const commission = Number(visit.commission_amount ?? '0');
  const payable =
    visit.status === 'closed' || (visit.status === 'paid' && visit.payout_status === 'canceled');
  return {
    edit: visit.status === 'open',
    close: visit.status === 'open',
    pay: canManage && payable && commission > 0,
    adjust: canManage && visit.status === 'closed',
    void: canManage && (visit.status === 'open' || visit.status === 'closed'),
  };
}

// Server refusals of coach visit commands, as translation keys.
const REASON_KEYS: Record<string, string> = {
  vehicle_plate_invalid: 'vehicleReason_plate',
  vehicle_type_invalid: 'vehicleReason_type',
  vehicle_guests_invalid: 'vehicleReason_guests',
  vehicle_visit_changed: 'vehicleReason_changed',
  vehicle_visit_closed: 'vehicleReason_closed',
  vehicle_visit_open: 'vehicleReason_open',
  vehicle_visit_paid: 'vehicleReason_paid',
  vehicle_visit_voided: 'vehicleReason_voided',
  vehicle_commission_zero: 'vehicleReason_zero',
  workspace_completed: 'vehicleReason_workspaceCompleted',
  transfer_reference_required: 'vehicleReason_transferReference',
  shift_required: 'vehicleReason_shift',
  insufficient_cash: 'vehicleReason_cash',
  approval_required: 'vehicleReason_approval',
  reason_required: 'vehicleReason_note',
  bus_operator_archived: 'vehicleReason_operatorArchived',
};

export function vehicleReasonKey(reason: string | null | undefined): string | null {
  return reason ? (REASON_KEYS[reason] ?? null) : null;
}
