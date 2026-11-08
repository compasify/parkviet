import { formatMoney } from '../money';
import type {
  PosFinancialAttempt,
  PosLineItem,
  PosStoreProfile,
  PosWorkspace,
} from '../pos-context';
import type { ReceiptSnapshot } from '../print-adapter';
import type { DocumentType, MetaField, PaymentField, TotalField } from './types';

// Every printable document reduced to one shape, from a posted receipt
// snapshot, an open order (pre-bill) or an order being paid (payment
// ticket). Only server figures are used: rows are picked, labelled and
// formatted here, never computed. A zero discount, tax or change is left
// out the way the slips always did.

type Translate = (key: string, options?: Record<string, unknown>) => string;

export type DataRow<F extends string> = {
  // The template field that may switch the row off; null rows always print.
  field: F | null;
  label: string;
  value: string;
  strong?: boolean;
  // Printed after the label, kept when a template relabels the row.
  labelSuffix?: string;
};

export type LineData = {
  name: string;
  sku: string | null;
  quantity: string | null;
  unit: string | null;
  // `price` and `amount` carry the currency; `*Cell` are the bare figures
  // of a narrow table column.
  price: string | null;
  priceCell: string;
  discountNote: string | null;
  discountCell: string;
  amount: string;
  amountCell: string;
  conversion: string | null;
  trace: string[];
  // Details that always print (returned quantity and condition).
  notes: string[];
};

export type StoreData = {
  name: string | null;
  address: string | null;
  phone: string | null;
  email: string | null;
  url: string | null;
  facebook: string | null;
  instagram: string | null;
  logoUrl: string | null;
};

export type TemplateData = {
  documentType: DocumentType;
  title: string;
  number: string | null;
  // A banner the document type always carries (pre-bill).
  banner: string | null;
  store: StoreData;
  branch: { name: string | null; code: string | null; returnWindowDays: number | null };
  register: string | null;
  cashier: string | null;
  time: string;
  customerName: string | null;
  meta: DataRow<MetaField>[];
  lines: LineData[];
  lineLabels: { qty: string; price: string; discount: string; amount: string };
  totals: DataRow<TotalField>[];
  payments: DataRow<PaymentField>[];
  notes: string[];
  disclaimer: string | null;
};

type Doc = Record<string, unknown>;
const str = (value: unknown): string | null =>
  typeof value === 'string' && value !== '' ? value : null;
const rows = (value: unknown): Doc[] =>
  Array.isArray(value)
    ? value.filter((item): item is Doc => typeof item === 'object' && item !== null)
    : [];
const obj = (value: unknown): Doc | null =>
  typeof value === 'object' && value !== null && !Array.isArray(value) ? (value as Doc) : null;
const int = (value: unknown): number | null =>
  typeof value === 'number' && Number.isInteger(value) ? value : null;

// Vietnamese document formats: dd/MM/yyyy HH:mm in the branch timezone,
// dd/MM/yyyy for dates, a comma as the decimal separator for quantities.
export function formatDocumentTime(value: string | null | undefined, timeZone: string): string {
  if (!value) return '—';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return value;
  const parts = new Intl.DateTimeFormat('en-GB', {
    timeZone,
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
    hourCycle: 'h23',
  }).formatToParts(date);
  const part = (type: string) => parts.find((item) => item.type === type)?.value ?? '';
  return `${part('day')}/${part('month')}/${part('year')} ${part('hour')}:${part('minute')}`;
}

export function formatDocumentDate(value: string | null | undefined): string {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(value ?? '');
  return match ? `${match[3]}/${match[2]}/${match[1]}` : (value ?? '');
}

export function formatQuantity(value: string | number | null | undefined): string {
  if (value === null || value === undefined) return '';
  const text = String(value);
  return /^-?\d+(\.\d+)?$/.test(text) ? text.replace(/\.0+$/, '').replace('.', ',') : text;
}

const isZero = (amount: string | null | undefined) =>
  amount == null || /^-?0+(\.0+)?$/.test(amount);
const nonZero = (amount: string | null | undefined) => !isZero(amount);

// Table cells drop the currency sign: columns are narrow on a 58mm roll.
function bare(amount: string | null | undefined, currency: string) {
  return formatMoney(amount ?? null, currency).replace(/\s(₫|[A-Z]{3})$/, '');
}

// The unit price the basket shows: a price override replaces the list price.
export function lineUnitPrice(line: PosLineItem): string {
  return line.line_discount?.value_type === 'unit_price'
    ? line.line_discount.value
    : (line.unit_price ?? line.price);
}

export function lineDiscount(line: PosLineItem): string | null {
  const amount = line.item_discount?.amount;
  return isZero(amount) ? null : (amount ?? null);
}

function lineLabels(t: Translate): TemplateData['lineLabels'] {
  return {
    qty: t('ticketQty'),
    price: t('ticketPrice'),
    discount: t('ticketDiscount'),
    amount: t('ticketTotal'),
  };
}

const methodLabel = (kind: string | null, t: Translate) =>
  kind === 'cash' ? t('receiptCash') : kind === 'vietqr' ? t('receiptVietqr') : t('receiptBank');

function emptyLine(name: string): LineData {
  return {
    name,
    sku: null,
    quantity: null,
    unit: null,
    price: null,
    priceCell: '',
    discountNote: null,
    discountCell: '',
    amount: '',
    amountCell: '',
    conversion: null,
    trace: [],
    notes: [],
  };
}

function traceText(trace: Doc, t: Translate): string {
  const parts: string[] = [];
  const serial = str(trace.serial);
  const lot = str(trace.lot_code);
  const expiry = str(trace.expiry_on);
  if (serial) parts.push(t('receiptSerial', { serial }));
  if (lot) parts.push(t('receiptLot', { lot }));
  if (expiry) parts.push(t('receiptExpiry', { date: formatDocumentDate(expiry) }));
  return parts.join(' · ');
}

// The store as printed: a snapshot copies its details at issue time (older
// snapshots carry only the name); open orders use the live POS context.
function storeFromSnapshot(store: Doc | null): StoreData {
  return {
    name: str(store?.name),
    address: str(store?.address),
    phone: str(store?.contact_phone),
    email: str(store?.customer_support_email),
    url: str(store?.url),
    facebook: str(store?.facebook),
    instagram: str(store?.instagram),
    logoUrl: null,
  };
}

function storeFromProfile(
  name: string | null | undefined,
  profile: PosStoreProfile | null | undefined,
): StoreData {
  return {
    name: name || null,
    address: profile?.address || null,
    phone: profile?.contact_phone || null,
    email: profile?.customer_support_email || null,
    url: profile?.url || null,
    facebook: profile?.facebook || null,
    instagram: profile?.instagram || null,
    logoUrl: profile?.logo_url || null,
  };
}

// What the POS context knows about where an open order is printed.
export type PrintPlace = {
  storeName?: string | null;
  branchName?: string | null;
  registerName?: string | null;
  storeProfile?: PosStoreProfile | null;
  branchCode?: string | null;
  returnWindowDays?: number | null;
};

function saleLine(line: Doc, currency: string, t: Translate): LineData {
  const discount = str(line.discount);
  const amount = str(line.net_amount) ?? str(line.amount);
  const price = str(line.unit_price);
  return {
    ...emptyLine(str(line.name) ?? ''),
    sku: str(line.sku),
    quantity: formatQuantity(str(line.sale_quantity) ?? String(line.quantity ?? '')),
    unit: str(line.sale_unit),
    price: formatMoney(price, currency),
    priceCell: bare(price, currency),
    discountNote: nonZero(discount)
      ? t('receiptLineDiscount', { amount: formatMoney(discount, currency) })
      : null,
    discountCell: nonZero(discount) ? bare(discount, currency) : '',
    amount: formatMoney(amount, currency),
    amountCell: bare(amount, currency),
    conversion: str(line.conversion),
    trace: rows(line.trace)
      .map((trace) => traceText(trace, t))
      .filter(Boolean),
  };
}

function saleTotals(document: Doc, currency: string, t: Translate): DataRow<TotalField>[] {
  const totals = obj(document.totals) ?? {};
  const money = (value: unknown) => formatMoney(str(value), currency);
  const result: DataRow<TotalField>[] = [
    { field: 'item_total', label: t('receiptItemTotal'), value: money(totals.item_total) },
  ];
  if (nonZero(str(totals.discount_total)))
    result.push({
      field: 'discount',
      label: t('receiptDiscount'),
      value: money(totals.discount_total),
    });
  if (nonZero(str(totals.additional_tax_total)))
    result.push({
      field: 'tax',
      label: t('receiptTax'),
      value: money(totals.additional_tax_total),
    });
  if (nonZero(str(totals.included_tax_total)))
    result.push({
      field: 'included_tax',
      label: t('receiptIncludedTax'),
      value: money(totals.included_tax_total),
    });
  result.push({
    field: 'total',
    label: t('receiptTotal'),
    value: money(totals.total),
    strong: true,
  });
  return result;
}

function salePayments(document: Doc, currency: string, t: Translate): DataRow<PaymentField>[] {
  const money = (value: unknown) => formatMoney(str(value), currency);
  const result: DataRow<PaymentField>[] = [];
  for (const receipt of rows(document.receipts)) {
    const kind = str(receipt.method);
    result.push({ field: 'methods', label: methodLabel(kind, t), value: money(receipt.amount) });
    if (kind === 'cash') {
      result.push({ field: 'handed', label: t('receiptHanded'), value: money(receipt.handed) });
      if (nonZero(str(receipt.change)))
        result.push({ field: 'change', label: t('receiptChange'), value: money(receipt.change) });
    } else if (str(receipt.reference)) {
      result.push({
        field: 'reference',
        label: t('receiptReference'),
        value: str(receipt.reference) ?? '',
      });
    }
  }
  result.push({
    field: 'paid_total',
    label: t('receiptPaidTotal'),
    value: money(document.paid_total),
    strong: true,
  });
  const credit = obj(document.credit);
  if (credit) {
    result.push({
      field: 'debt',
      label: t('receiptDebt'),
      value: money(credit.debt),
      strong: true,
    });
    if (str(credit.due_on))
      result.push({
        field: 'due_on',
        label: t('receiptDueOn'),
        value: formatDocumentDate(str(credit.due_on)),
      });
  }
  return result;
}

const SNAPSHOT_TYPES: Record<string, DocumentType> = {
  sale: 'sale',
  return: 'return',
  return_supplement: 'return',
  refund: 'refund',
  shift_closure: 'shift_closure',
};

// The template a posted receipt prints with: a return supplement uses the
// return template.
export function snapshotDocumentType(receipt: Pick<ReceiptSnapshot, 'source_type'>): DocumentType {
  return SNAPSHOT_TYPES[receipt.source_type] ?? 'sale';
}

// A posted document from its server snapshot.
export function snapshotData(receipt: ReceiptSnapshot, t: Translate): TemplateData {
  const document = receipt.document;
  const currency = str(document.currency) ?? 'VND';
  const zone = str(document.timezone) ?? 'Asia/Ho_Chi_Minh';
  const money = (value: unknown) => formatMoney(str(value), currency);
  const time = formatDocumentTime(str(document.at) ?? receipt.issued_at, zone);
  const cashier = str(document.cashier);
  const meta: DataRow<MetaField>[] = [{ field: 'time', label: t('receiptTime'), value: time }];
  if (cashier) meta.push({ field: 'cashier', label: t('receiptCashier'), value: cashier });
  if (str(document.order_number))
    meta.push({
      field: 'order_number',
      label: t('receiptOrderNumber'),
      value: str(document.order_number) ?? '',
    });
  if (str(document.return_number))
    meta.push({
      field: 'return_number',
      label: t('receiptReturnNumber'),
      value: str(document.return_number) ?? '',
    });
  const customer = obj(document.customer);
  const customerValue = customer
    ? [str(customer.name), str(customer.phone)].filter(Boolean).join(' · ')
    : '';
  if (customerValue)
    meta.push({ field: 'customer', label: t('receiptCustomer'), value: customerValue });

  let lines: LineData[] = [];
  let totals: DataRow<TotalField>[] = [];
  let payments: DataRow<PaymentField>[] = [];
  const notes: string[] = [];
  switch (receipt.source_type) {
    case 'sale':
      lines = rows(document.lines).map((line) => saleLine(line, currency, t));
      totals = saleTotals(document, currency, t);
      payments = salePayments(document, currency, t);
      if (str(document.note)) notes.push(str(document.note) ?? '');
      break;
    case 'return':
      lines = rows(document.lines).map((line) => ({
        ...emptyLine(str(line.name) ?? ''),
        sku: str(line.sku),
        amount: money(line.amount),
        amountCell: bare(str(line.amount), currency),
        notes: [
          t('receiptReturnedQuantity', {
            quantity: formatQuantity(line.quantity as string | number),
          }),
          t(
            line.condition === 'damaged' ? 'receiptConditionDamaged' : 'receiptConditionResellable',
          ),
        ],
      }));
      totals = [
        {
          field: 'total',
          label: t('receiptReturnValue'),
          value: money(document.entitlement_total),
          strong: true,
        },
      ];
      if (document.entitlement_posted) {
        if (nonZero(str(document.credit_note_amount)))
          totals.push({
            field: null,
            label: t('receiptCreditNote'),
            value: money(document.credit_note_amount),
          });
        totals.push({
          field: null,
          label: t('receiptRefundEntitlement'),
          value: money(document.refund_entitlement),
        });
      } else {
        notes.push(t('receiptReturnPending'));
      }
      if (str(document.reason)) notes.push(t('receiptReason', { reason: str(document.reason) }));
      break;
    case 'refund':
      payments = [
        {
          // The refunded amount is the slip's total and always prints.
          field: null,
          label: str(document.method) === 'cash' ? t('receiptRefundCash') : t('receiptRefundBank'),
          value: money(document.amount),
          strong: true,
        },
      ];
      if (str(document.reference))
        payments.push({
          field: 'reference',
          label: t('receiptReference'),
          value: str(document.reference) ?? '',
        });
      break;
    case 'shift_closure':
      meta.push({
        field: null,
        label: t('receiptShiftOpened'),
        value: formatDocumentTime(str(document.opened_at), zone),
      });
      if (str(document.closer))
        meta.push({ field: null, label: t('receiptCloser'), value: str(document.closer) ?? '' });
      if (str(document.approver))
        meta.push({
          field: null,
          label: t('receiptApprover'),
          value: str(document.approver) ?? '',
        });
      totals = [
        { field: null, label: t('receiptOpeningFloat'), value: money(document.opening_float) },
        { field: null, label: t('receiptInflow'), value: money(document.inflow_total) },
        { field: null, label: t('receiptOutflow'), value: money(document.outflow_total) },
        {
          field: null,
          label: t('receiptExpected'),
          value: money(document.expected),
          strong: true,
        },
        { field: null, label: t('receiptCounted'), value: money(document.counted), strong: true },
        {
          field: null,
          label: t('receiptVariance'),
          value: money(document.variance),
          strong: true,
        },
      ];
      if (str(document.reason)) notes.push(t('receiptReason', { reason: str(document.reason) }));
      break;
  }
  if (receipt.issued_late) notes.push(t('receiptIssuedLate'));
  const branch = obj(document.branch);
  return {
    documentType: snapshotDocumentType(receipt),
    title: str(document.title) ?? receipt.number,
    number: receipt.number,
    banner: null,
    store: storeFromSnapshot(obj(document.store)),
    branch: {
      name: str(branch?.name),
      code: str(branch?.code),
      returnWindowDays: int(branch?.return_window_days),
    },
    register: str(document.register),
    cashier,
    time,
    customerName: str(customer?.name),
    meta,
    lines,
    lineLabels: lineLabels(t),
    totals,
    payments,
    notes,
    disclaimer: receipt.disclaimer,
  };
}

function placeData(place: PrintPlace) {
  return {
    store: storeFromProfile(place.storeName, place.storeProfile),
    branch: {
      name: place.branchName || null,
      code: place.branchCode || null,
      returnWindowDays: place.returnWindowDays ?? null,
    },
    register: place.registerName || null,
  };
}

// A provisional bill of an open order: server figures as they stand, always
// labelled as not paid and never numbered as a receipt.
export function prebillData(
  workspace: PosWorkspace,
  place: PrintPlace,
  t: Translate,
  now: Date = new Date(),
  timeZone = 'Asia/Ho_Chi_Minh',
): TemplateData {
  const currency = workspace.totals?.currency ?? 'VND';
  const money = (value: string | null | undefined) => formatMoney(value ?? null, currency);
  const totals = workspace.totals;
  const time = formatDocumentTime(now.toISOString(), timeZone);
  const lines = (workspace.line_items ?? []).map((line): LineData => {
    const price = line.unit_price ?? line.price;
    const amount = line.item_net_amount ?? line.net_amount ?? line.amount;
    const trace = (line.serial_codes ?? []).map((serial) => t('receiptSerial', { serial }));
    if (line.lot_code) trace.push(t('receiptLot', { lot: line.lot_code }));
    return {
      ...emptyLine(line.name),
      sku: line.sku || null,
      quantity: formatQuantity(line.sale_quantity ?? line.quantity),
      unit: line.sale_unit || null,
      price: money(price),
      priceCell: bare(price, currency),
      amount: money(amount),
      amountCell: bare(amount, currency),
      trace,
    };
  });
  const totalRows: DataRow<TotalField>[] = [];
  if (totals) {
    totalRows.push({
      field: 'item_total',
      label: t('receiptItemTotal'),
      value: money(totals.item_total),
    });
    if (nonZero(totals.discount_total))
      totalRows.push({
        field: 'discount',
        label: t('receiptDiscount'),
        value: money(totals.discount_total),
      });
    totalRows.push({
      field: 'total',
      label: t('receiptTotal'),
      value: money(totals.total),
      strong: true,
    });
  }
  const payments: DataRow<PaymentField>[] = workspace.financial
    ? [
        {
          field: 'paid_total',
          label: t('receiptPaidTotal'),
          value: money(workspace.financial.allocated),
        },
        {
          field: null,
          label: t('receiptRemaining'),
          value: money(workspace.financial.remaining),
          strong: true,
        },
      ]
    : [];
  return {
    documentType: 'prebill',
    title: t('receiptPrebillTitle'),
    number: null,
    banner: t('receiptPrebillBanner'),
    ...placeData(place),
    cashier: null,
    time,
    customerName: workspace.customer?.name || null,
    meta: [{ field: 'time', label: t('receiptTime'), value: time }],
    lines,
    lineLabels: lineLabels(t),
    totals: totalRows,
    payments,
    notes: [t('receiptPrebillNote')],
    disclaimer: t('receiptDisclaimer'),
  };
}

export type PaymentTicketInput = {
  workspace: PosWorkspace;
  attempts: PosFinancialAttempt[];
  handed: string | null;
  change: string | null;
  names: PrintPlace & { cashier?: string | null };
};

// The payment invoice handed over at the counter: the order as it is being
// paid. The change is the one already shown to the cashier on screen.
export function paymentTicketData(
  input: PaymentTicketInput,
  t: Translate,
  now: Date = new Date(),
  timeZone = 'Asia/Ho_Chi_Minh',
): TemplateData {
  const { workspace, attempts, handed, change, names } = input;
  const currency = workspace.totals?.currency ?? attempts[0]?.currency ?? 'VND';
  const money = (value: string | null | undefined) => formatMoney(value ?? null, currency);
  const time = formatDocumentTime(now.toISOString(), timeZone);
  const meta: DataRow<MetaField>[] = [{ field: 'time', label: t('receiptTime'), value: time }];
  if (workspace.order_id)
    meta.push({ field: 'order_number', label: t('ticketOrder'), value: workspace.order_id });
  if (names.cashier)
    meta.push({ field: 'cashier', label: t('receiptCashier'), value: names.cashier });
  meta.push({
    field: 'customer',
    label: t('receiptCustomer'),
    value: workspace.customer?.name || t('customerWalkIn'),
  });

  const lines = (workspace.line_items ?? []).map((line): LineData => {
    const price = lineUnitPrice(line);
    const discount = lineDiscount(line);
    const amount = line.item_net_amount ?? line.net_amount ?? line.amount;
    return {
      ...emptyLine(line.name),
      sku: line.sku || null,
      quantity: formatQuantity(line.sale_quantity ?? line.quantity),
      unit: line.sale_unit || null,
      price: money(price),
      priceCell: bare(price, currency),
      discountNote: discount ? t('receiptLineDiscount', { amount: money(discount) }) : null,
      discountCell: discount ? bare(discount, currency) : '',
      amount: money(amount),
      amountCell: bare(amount, currency),
    };
  });

  const totals: DataRow<TotalField>[] = [];
  if (workspace.totals) {
    totals.push({
      field: 'item_total',
      label: t('receiptItemTotal'),
      value: money(workspace.totals.item_total),
    });
    if (nonZero(workspace.totals.discount_total))
      totals.push({
        field: 'discount',
        label: t('receiptDiscount'),
        labelSuffix: workspace.coupon ? ` (${workspace.coupon.code})` : undefined,
        value: money(workspace.totals.discount_total),
      });
    if (nonZero(workspace.totals.additional_tax_total))
      totals.push({
        field: 'tax',
        label: t('receiptTax'),
        value: money(workspace.totals.additional_tax_total),
      });
    totals.push({
      field: 'total',
      label: t('receiptTotal'),
      value: money(workspace.totals.total),
      strong: true,
    });
  }

  const payments: DataRow<PaymentField>[] = [];
  for (const attempt of attempts) {
    payments.push({
      field: 'methods',
      label: methodLabel(attempt.kind, t),
      value: formatMoney(attempt.amount, attempt.currency),
    });
    if (attempt.kind === 'cash' && handed !== null) {
      payments.push({
        field: 'handed',
        label: t('receiptHanded'),
        value: formatMoney(handed, attempt.currency),
      });
      if (change !== null && nonZero(change))
        payments.push({
          field: 'change',
          label: t('receiptChange'),
          value: formatMoney(change, attempt.currency),
        });
    }
  }

  return {
    documentType: 'payment_ticket',
    title: t('ticketTitle'),
    number: null,
    banner: null,
    ...placeData(names),
    cashier: names.cashier || null,
    time,
    customerName: workspace.customer?.name || null,
    meta,
    lines,
    lineLabels: lineLabels(t),
    totals,
    payments,
    notes: [],
    disclaimer: null,
  };
}
