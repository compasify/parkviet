export type PosBranch = {
  id: string;
  name: string;
  code: string;
  timezone: string;
  status: string;
  stock_location_id: string;
  receiving_stock_location_id: string | null;
  receiving_note: string | null;
};

export type PosRegister = {
  id: string;
  branch_id: string;
  name: string;
  code: string;
  status: string;
};

export type PosShift = {
  id: string;
  branch_id: string;
  register_id: string | null;
  status: string;
  opening_float: string;
  currency: string;
  owner_id: string;
  opened_at: string | null;
  reports: false;
};

export type PosSelection = {
  branchId: string | null;
  registerId: string | null;
};

export type PosContext = {
  administration?: { read: boolean; write: boolean };
  staff: { id: string; email: string; full_name: string | null };
  store: {
    id: string;
    name: string | null;
    currency: string | null;
    locale: string | null;
    timezone: string | null;
  };
  capabilities: string[];
  branches: PosBranch[];
  registers: PosRegister[];
  shift: PosShift | null;
  selection: { branch_id: string | null; register_id: string | null };
};

export type PosDiscount = {
  id: string;
  value_type: 'flat' | 'percent';
  value: string;
  reason: string;
  amount: string;
};

export type PosTotals = {
  item_total: string;
  discount_total: string;
  manual_discount_total: string;
  included_tax_total: string;
  additional_tax_total: string;
  total: string;
  currency: string;
};

export type PosLineDiscount = {
  id: string;
  value_type: 'flat' | 'percent' | 'unit_price' | 'item_flat' | 'item_percent';
  value: string;
  reason: string;
  amount: string;
};

export type PosLineItem = {
  id: string;
  variant_id: string;
  product_id: string;
  name: string;
  sku: string;
  quantity: number;
  price: string;
  list_price?: string;
  amount: string;
  discounts: { id: string; kind: string; label: string; amount: string }[];
  net_amount?: string;
  item_net_amount?: string;
  sale_line_id: string | null;
  kind?: 'ordinary' | 'measured' | 'tracked';
  sale_quantity?: string;
  base_quantity?: number;
  sale_unit?: string;
  base_unit?: string;
  conversion_version?: number | null;
  unit_price?: string;
  lot_code?: string | null;
  expiry_on?: string | null;
  serial_codes?: string[];
  tracked_mode?: string;
  label_barcode?: string | null;
  label_format_version?: number | null;
  line_discount?: PosLineDiscount | null;
  item_discount?: {
    amount: string;
    source: 'manual' | 'promotion' | 'none';
    value_type: 'flat' | 'percent';
    value: string;
    labels: string[];
  };
};

export type PosVariantUnit = {
  variant_id: string;
  sale_unit: string;
  base_unit: string;
  price_unit: string;
  ratio_numerator: number;
  ratio_denominator: number;
  tracked_mode: string;
  version: number;
  status: string;
  label_code?: string | null;
};

export type PosCustomer = {
  id: string | null;
  name: string | null;
  phone: string | null;
  email: string | null;
  customer_id: string | null;
  has_account: boolean;
};

export type PosCustomerProfile = {
  id: string;
  name: string;
  phone: string | null;
  email: string | null;
  customer_id: string | null;
  has_account: boolean;
  duplicates?: PosCustomerProfile[];
};

export type PosFinancialAttempt = {
  id: string;
  workspace_id: string;
  payment_method_id: string;
  kind: string;
  status: string;
  amount: string;
  order_total_snapshot: string;
  currency: string;
  workspace_revision: number;
  received_funds_id: string | null;
  confirmed_at: string | null;
  canceled_at: string | null;
};

export type PosFinancial = {
  received: string;
  allocated: string;
  unapplied: string;
  remaining: string;
  change_due: string;
  attempts: PosFinancialAttempt[];
};

export type PosPaymentMethod = {
  id: string;
  code: string;
  name: string;
  kind: 'cash' | 'bank_manual';
  status: string;
  position: number;
};

export type PosReceivedFunds = {
  id: string;
  workspace_id: string | null;
  branch_id: string;
  shift_id: string;
  tender_attempt_id: string | null;
  kind: 'cash' | 'bank_manual';
  status: 'received' | 'attention';
  handed_amount: string;
  applied_amount: string;
  change_amount: string;
  received_net: string;
  currency: string;
  reference: string | null;
  allocated: string;
  payout_reserved: string;
  paid_out: string;
  available: string;
  received_at: string | null;
  payouts?: PosLiabilityPayout[];
  allocations?: PosFundsAllocation[];
};

export type PosFundsAllocation = {
  id: string;
  received_funds_id: string;
  workspace_id: string;
  order_id: string;
  payment_id: string | null;
  status: 'active' | 'reversed';
  amount: string;
  currency: string;
  reversed_at: string | null;
};

export type PosLiabilityPayout = {
  id: string;
  received_funds_id: string;
  branch_id: string;
  status: 'requested' | 'reserved' | 'unknown' | 'confirmed' | 'failed' | 'canceled';
  amount: string;
  currency: string;
  beneficiary_name: string;
  beneficiary_reference: string | null;
  reason: string;
  confirmed_at: string | null;
  resolved_at: string | null;
};

export type PosWorkspace = {
  id: string;
  branch_id: string;
  register_id: string | null;
  shift_id: string;
  order_id: string;
  revision: number;
  lease_generation: number;
  operational_status: string;
  payments: boolean;
  note?: string | null;
  customer?: PosCustomer | null;
  line_items?: PosLineItem[];
  discount?: PosDiscount | null;
  coupon?: {
    code: string;
    name?: string | null;
    amount: string;
  } | null;
  totals?: PosTotals;
  financial?: PosFinancial | null;
};

export type PosMembership = {
  id: string;
  branch_id: string;
  staff_id: string;
  capabilities: string[];
  status: string;
};

export const emptySelection: PosSelection = { branchId: null, registerId: null };

export function writesLocked(context: PosContext | undefined, selection: PosSelection) {
  if (!context) return true;
  const branch = context.branches.find((item) => item.id === selection.branchId);
  const register = context.registers.find((item) => item.id === selection.registerId);
  if (branch?.status === 'disabled' || register?.status === 'disabled') return true;
  return Boolean(context.shift) && !context.capabilities.includes('pos.shift.open');
}
