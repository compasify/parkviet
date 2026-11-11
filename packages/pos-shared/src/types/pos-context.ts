import type { PosFeatureFlags } from '../pos-features';
import type { PosBranchProfile, PosModules, PosModuleUsage, PosOnboarding } from '../pos-modules';
import type { LotSelection, SaleLineTrace, WorkspaceTrace } from '../traceability';

// Where a sale came from. A fixed list, kept in step with the server's ORDER_SOURCES:
// the sources a cashier picks, then the delivery platforms, which only an entered
// platform order carries.
export const PICKABLE_ORDER_SOURCES = ['counter', 'facebook', 'zalo', 'other'] as const;
export const PLATFORM_ORDER_SOURCES = ['grabfood', 'shopeefood'] as const;
export const ORDER_SOURCES = [...PICKABLE_ORDER_SOURCES, ...PLATFORM_ORDER_SOURCES] as const;
export type OrderSource = (typeof ORDER_SOURCES)[number];
export type PickableOrderSource = (typeof PICKABLE_ORDER_SOURCES)[number];
export type PlatformOrderSource = (typeof PLATFORM_ORDER_SOURCES)[number];

export const SERVICE_MODES = [
  'counter',
  'dine_in',
  'takeaway',
  'delivery',
  'tab',
  'timed',
] as const;
export type ServiceMode = (typeof SERVICE_MODES)[number];

export type PosBranch = {
  id: string;
  name: string;
  code: string;
  timezone: string;
  status: string;
  stock_location_id: string;
  receiving_stock_location_id: string | null;
  receiving_note: string | null;
  return_window_days?: number | null;
  // How lot-tracked lines pick their lot; FEFO unless the cashier may choose.
  lot_selection?: LotSelection;
  // Base units a positive count adjustment may add without approval; null
  // means every positive adjustment needs one.
  adjustment_approval_threshold?: number | null;
  // Closing variance above this needs an approval; null means any variance does.
  variance_threshold?: string | null;
  // Industry profile of the branch; absent on servers without profiles.
  profile_key?: string;
  profile_version?: number;
  // Wall-clock time the business day rolls, HH:MM. Missing means 04:00.
  business_day_cutoff?: string;
  staff_session_idle_minutes?: number;
  // When menu lines reach the kitchen: as the sale completes, or on "send".
  kitchen_send_trigger?: 'on_complete' | 'manual';
  // Reasons a sent item may be voided for; `khac` (other) always needs a note.
  void_reasons?: string[];
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
  business_date?: string;
  reports: false;
};

export type PosSelection = {
  branchId: string | null;
  registerId: string | null;
};

// The store's business details as `Spree::Store` holds them, printed in
// the header of documents of an open order. Blank fields are null.
export type PosStoreProfile = {
  address: string | null;
  contact_phone: string | null;
  customer_support_email: string | null;
  url: string | null;
  facebook: string | null;
  instagram: string | null;
  logo_url: string | null;
};

export type PosContext = {
  sales_channel?: {
    id: string | null;
    code: string;
    name: string | null;
    status: 'active' | 'missing' | 'inactive';
  };
  administration?: { read: boolean; write: boolean };
  // Feature flags of the selected branch; absent on servers without them.
  features?: PosFeatureFlags | null;
  // Modules on at the selected branch (`{}` without one); null on servers
  // without modules, which hides nothing.
  modules?: PosModules | null;
  // Store-wide data a module still has ({ 'retail.traceability': bool });
  // `{}` when the server does not send it.
  module_usage?: PosModuleUsage | null;
  // Industry profile of the selected branch; null without a branch.
  profile?: PosBranchProfile | null;
  // First-run setup; null on servers without it.
  onboarding?: PosOnboarding | null;
  // E-invoice the store issues for completed sales; absent on older servers
  // (read as none).
  einvoice_type?: 'none' | 'cash_register' | 'coded';
  staff: { id: string; email: string; full_name: string | null };
  store: {
    id: string;
    name: string | null;
    currency: string | null;
    locale: string | null;
    timezone: string | null;
    // Printable business details; absent on servers that do not send them.
    profile?: PosStoreProfile | null;
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
  // Fees on the order (the delivery fee); missing from older servers.
  fee_total?: string;
  total: string;
  currency: string;
  taxes?: PosTaxRow[];
};

export type PosTaxRow = {
  rate: string;
  label: string;
  amount: string;
};

// A sale to deliver: who takes it, the delivery fee (already in the order
// total) and whether it was delivered.
export type PosDelivery = {
  id: string;
  status: 'pending' | 'delivered';
  deliverer: string | null;
  fee: string;
  delivered_at: string | null;
  delivered_by: string | null;
};

export type PosLineDiscount = {
  id: string;
  value_type: 'flat' | 'percent' | 'unit_price' | 'item_flat' | 'item_percent';
  value: string;
  reason: string;
  amount: string;
};

export type PosLineModifier = {
  id: string;
  option_id: string | null;
  name: string;
  group_name: string;
  price_delta: string;
  quantity: number;
};

export type PosLineComponent = {
  id: string;
  variant_id: string;
  name: string;
  quantity: number;
};

// One picked option as the item endpoints take it.
export type PosModifierSelection = { option_id: string; quantity?: number };

// `GET /pos/menu`: what the counter sells from at one branch.
export type PosMenuOption = {
  id: string;
  name: string;
  price_delta: string;
  variant_id: string | null;
  default_selected: boolean;
  position: number;
  active: boolean;
};

export type PosMenuModifierGroup = {
  id: string;
  name: string;
  min_select: number;
  max_select: number;
  allow_quantity: boolean;
  required: boolean;
  position: number;
  options: PosMenuOption[];
};

export type PosMenuVariant = {
  id: string;
  name: string;
  sku: string | null;
  barcode: string | null;
  // The price now, after a running time-of-day menu; list_price is without it.
  price: string | null;
  list_price: string | null;
  schedule_id: string | null;
};

export type PosMenuItem = {
  id: string;
  product_id: string;
  name: string;
  kind: 'single' | 'combo';
  menu_category_id: string | null;
  kitchen_category: string | null;
  // Prints one cup label per unit when the branch runs cup labels.
  cup_label: boolean;
  show_components_on_kds: boolean;
  position: number;
  active: boolean;
  tax_category_id: string | null;
  modifier_group_ids: string[];
  components: { id: string; variant_id: string; name: string; quantity: number }[];
  image_url: string | null;
  sold_out: boolean;
  variants: PosMenuVariant[];
};

export type PosMenuCategory = {
  id: string;
  name: string;
  position: number;
  color: string | null;
  active: boolean;
};

export type PosMenu = {
  branch_id: string;
  currency: string;
  business_date: string;
  module_enabled: boolean;
  categories: PosMenuCategory[];
  items: PosMenuItem[];
  modifier_groups: PosMenuModifierGroup[];
  // Time-of-day menus running now.
  schedules: { id: string; name: string }[];
  favorites: string[];
  etag: string;
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
  kind?: 'ordinary' | 'measured' | 'tracked' | 'menu';
  // A menu line's options, combo contents and note, copied at the time of sale.
  note?: string | null;
  modifiers?: PosLineModifier[];
  components?: PosLineComponent[];
  sale_quantity?: string;
  // The part of a menu line already sent to the kitchen; the line cannot
  // go below it or change its options.
  kitchen_sent_quantity?: string;
  // Units of a menu line the kitchen has not been told about yet.
  pending_kitchen_quantity?: string;
  // A table line's units in the kitchen by state, as the waiter's phone shows them.
  kitchen_status?: Partial<Record<KitchenLineState, string>>;
  // Bumped on every change; an unsent table line is edited by its version.
  row_version?: number;
  added_by?: { id: string; name: string } | null;
  base_quantity?: number;
  sale_unit?: string;
  base_unit?: string;
  conversion_version?: number | null;
  unit_price?: string;
  lot_code?: string | null;
  expiry_on?: string | null;
  serial_codes?: string[];
  tracked_mode?: string;
  // Reserved serials/lots of a traced line, or the FEFO plan before reserving.
  trace?: SaleLineTrace | null;
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
  // Where to deliver, free text as the seller writes it.
  address?: string | null;
};

export type PosCustomerProfile = {
  id: string;
  name: string;
  phone: string | null;
  email: string | null;
  customer_id: string | null;
  has_account: boolean;
  address?: string | null;
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
  // Approved credit for the current snapshot; after a credit sale, the debt
  // and its balance from the receivable ledger.
  credit?: {
    approved: string | null;
    approval_id: string | null;
    debt: string | null;
    due_on: string | null;
    balance: string | null;
  } | null;
};

export type PosCreditRequest = {
  id: string;
  branch_id: string;
  workspace_id: string;
  order_number: string;
  customer: { id: string; name: string };
  requester: { id: string; name: string };
  amount: string;
  currency: string;
  workspace_revision: number;
  status: 'pending' | 'approved' | 'rejected' | 'stale';
  reason: string | null;
  created_at: string | null;
  decided_at: string | null;
  approval_id: string | null;
  approval_active: boolean;
};

export type PosCreditAccount = {
  id: string;
  customer_id: string;
  customer_name: string;
  customer_phone?: string | null;
  branch_id?: string;
  status: 'active' | 'suspended';
  currency: string;
  credit_limit: string;
  due_days: number;
  open_debt: string;
  reserved: string;
  available: string;
  due_on?: string;
};

export type PosCreditReservation = {
  id: string;
  credit_account_id: string;
  workspace_id: string;
  approval_id: string;
  customer_id: string;
  amount: string;
  currency: string;
  workspace_revision: number;
  status: 'active' | 'committed' | 'released';
  usable: boolean;
  approver: { id: string; name: string };
  expires_at: string;
};

export type PosWorkspaceCredit = {
  workspace_id: string;
  revision: number;
  customer: { id: string; name: string } | null;
  can_sell: boolean;
  account: PosCreditAccount | null;
  reservation: PosCreditReservation | null;
  request?: PosCreditRequest | null;
};

export type PosReceivableCustomer = {
  id: string;
  name: string;
  phone: string | null;
  // Only on the customers list, and null for readers who see masked contacts.
  address?: string | null;
};

// One open order a debt reminder lists (oldest due first).
export type PosReminderOrder = {
  order_id: string;
  order_number: string;
  placed_at: string | null;
  due_on: string | null;
  balance: string;
};

export type PosReceivable = {
  order_id: string;
  order_number: string;
  workspace_id: string;
  credit_account_id: string;
  customer: PosReceivableCustomer;
  currency: string;
  original_total: string;
  paid_at_sale: string;
  debt: string;
  credit_notes: string;
  collected: string;
  refunds: string;
  balance: string;
  due_on: string | null;
  overdue: boolean;
  days_overdue: number;
  aging: 'current' | 'days_1_30' | 'days_31_60' | 'days_61_90' | 'days_over_90';
  placed_at: string | null;
  // The pay-later VietQR for the open balance (lib/pay-later); null without
  // VietQR at the branch or once nothing is owed.
  pay_later?: unknown;
};

export type PosReceivableAccount = {
  credit_account_id: string;
  currency: string;
  customer: PosReceivableCustomer;
  orders: number;
  credit_limit: string;
  account_status: string;
  balance: string;
  overdue: string;
  current: string;
  days_1_30: string;
  days_31_60: string;
  days_61_90: string;
  days_over_90: string;
  oldest_due_on?: string | null;
  oldest_placed_at?: string | null;
  // Days since the oldest open order was sold, and since its due date passed.
  days_owed?: number;
  days_overdue?: number;
  last_reminded_at?: string | null;
  // At most 20; `orders` counts them all.
  open_orders?: PosReminderOrder[];
  // One pay-later VietQR for the whole balance (lib/pay-later).
  pay_later?: unknown;
};

export type PosCollection = {
  id: string;
  credit_account_id: string;
  branch_id: string;
  customer_id: string;
  note: string | null;
  funds: PosReceivedFunds;
  allocations: PosFundsAllocation[];
  created_at: string | null;
};

export type PosPaymentMethod = {
  id: string;
  code: string;
  name: string;
  kind: 'cash' | 'bank_manual' | 'vietqr';
  status: string;
  position: number;
};

export type PosReceivedFunds = {
  id: string;
  workspace_id: string | null;
  branch_id: string;
  shift_id: string;
  tender_attempt_id: string | null;
  kind: 'cash' | 'bank_manual' | 'platform_receivable';
  status: 'received' | 'attention';
  handed_amount: string;
  applied_amount: string;
  change_amount: string;
  received_net: string;
  currency: string;
  reference: string | null;
  // Held cash is outside any drawer; paying it out is a custody-only outflow.
  custody?: 'drawer' | 'held';
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
  order_number?: string;
  payment_id: string | null;
  collection_id?: string | null;
  consumed?: string;
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
  // Where the sale came from; missing on older payloads (read as counter).
  order_source?: OrderSource;
  // How the sale is served. Missing on older payloads (read as counter).
  service_mode?: ServiceMode;
  // Stamped once when the draft is created. Missing on older payloads.
  business_date?: string;
  // Counter service (`fnb.order_number`): the number the order is called by,
  // given at its first kitchen send or at completion, and the guest's name.
  order_number?: number | null;
  guest_name?: string | null;
  customer?: PosCustomer | null;
  line_items?: PosLineItem[];
  discount?: PosDiscount | null;
  coupon?: {
    code: string;
    name?: string | null;
    amount: string;
  } | null;
  totals?: PosTotals;
  // Set when the sale is an order to deliver.
  delivery?: PosDelivery | null;
  financial?: PosFinancial | null;
  // Missing on payloads from servers without stock traceability.
  trace?: WorkspaceTrace | null;
  // Table orders: every kitchen send, in order. Null on other orders.
  kitchen_sends?: PosKitchenSend[] | null;
};

export type PosKitchenSend = {
  id: string;
  sequence: number;
  sent_at: string;
  staff_id: string | null;
  staff_name: string | null;
  device_id: string | null;
};

export type PosMembership = {
  id: string;
  branch_id: string;
  staff_id: string;
  // What the membership grants: its role's capabilities when it has a role.
  capabilities: string[];
  // The membership's own list, used when it has no role.
  custom_capabilities?: string[];
  staff_role?: { id: string; name: string } | null;
  status: string;
};

export type KitchenLineState = 'new' | 'preparing' | 'ready' | 'served';
