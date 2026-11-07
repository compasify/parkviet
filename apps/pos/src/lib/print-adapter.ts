import { formatMoney } from './money';
import type { PosWorkspace } from './pos-context';

// Printing is two steps behind one interface: `format` turns a server receipt
// snapshot (or a provisional pre-bill of an open order) into a printable
// document without computing any amount, and `deliver` sends it to a
// printer. Only a browser implementation exists; a native driver or silent
// printing would be another adapter after merchant device approval. A
// failed or blocked print is reported and never undoes or repeats a sale.

export type PaperSize = '80mm' | 'a4';

export type ReceiptSnapshot = {
  id: string;
  source_type: 'sale' | 'return' | 'refund' | 'shift_closure';
  number: string;
  branch_id: string;
  issued_at: string;
  issued_late: boolean;
  disclaimer: string;
  printed: boolean;
  copy_count: number;
  document: Record<string, unknown>;
};

export type ReceiptPrint = {
  id: string;
  copy: boolean;
  copy_number: number;
  label: string | null;
  printed_at: string;
};

export type ReceiptRow = { label: string; value: string; strong?: boolean };
export type ReceiptLineView = { name: string; details: string[]; amount: string };

export type ReceiptDocument = {
  banner: string | null;
  title: string;
  number: string | null;
  header: string[];
  meta: ReceiptRow[];
  lines: ReceiptLineView[];
  totals: ReceiptRow[];
  payments: ReceiptRow[];
  notes: string[];
  disclaimer: string;
};

type Translate = (key: string, options?: Record<string, unknown>) => string;

type Doc = Record<string, unknown>;
const str = (value: unknown): string | null =>
  typeof value === 'string' && value !== '' ? value : null;
const rows = (value: unknown): Doc[] =>
  Array.isArray(value)
    ? value.filter((item): item is Doc => typeof item === 'object' && item !== null)
    : [];
const obj = (value: unknown): Doc | null =>
  typeof value === 'object' && value !== null && !Array.isArray(value) ? (value as Doc) : null;

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

const nonZero = (amount: string | null) => amount !== null && !/^-?0+(\.0+)?$/.test(amount);

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

function saleLines(document: Doc, currency: string, t: Translate): ReceiptLineView[] {
  return rows(document.lines).map((line) => {
    const quantity = formatQuantity(str(line.sale_quantity) ?? String(line.quantity ?? ''));
    const unit = str(line.sale_unit);
    const details = [
      `${quantity}${unit ? ` ${unit}` : ''} × ${formatMoney(str(line.unit_price), currency)}`,
    ];
    const conversion = str(line.conversion);
    if (conversion) details.push(conversion);
    const discount = str(line.discount);
    if (nonZero(discount))
      details.push(t('receiptLineDiscount', { amount: formatMoney(discount, currency) }));
    for (const trace of rows(line.trace)) {
      const text = traceText(trace, t);
      if (text) details.push(text);
    }
    return {
      name: [str(line.name), str(line.sku) ? `(${str(line.sku)})` : null].filter(Boolean).join(' '),
      details,
      amount: formatMoney(str(line.net_amount) ?? str(line.amount), currency),
    };
  });
}

function saleTotals(document: Doc, currency: string, t: Translate) {
  const totals = obj(document.totals) ?? {};
  const money = (value: unknown) => formatMoney(str(value), currency);
  const result: ReceiptRow[] = [{ label: t('receiptItemTotal'), value: money(totals.item_total) }];
  if (nonZero(str(totals.discount_total)))
    result.push({ label: t('receiptDiscount'), value: money(totals.discount_total) });
  if (nonZero(str(totals.additional_tax_total)))
    result.push({ label: t('receiptTax'), value: money(totals.additional_tax_total) });
  if (nonZero(str(totals.included_tax_total)))
    result.push({ label: t('receiptIncludedTax'), value: money(totals.included_tax_total) });
  result.push({ label: t('receiptTotal'), value: money(totals.total), strong: true });
  return result;
}

function salePayments(document: Doc, currency: string, t: Translate) {
  const money = (value: unknown) => formatMoney(str(value), currency);
  const result: ReceiptRow[] = [];
  for (const receipt of rows(document.receipts)) {
    const method = str(receipt.method) === 'cash' ? t('receiptCash') : t('receiptBank');
    result.push({ label: method, value: money(receipt.amount) });
    if (str(receipt.method) === 'cash') {
      result.push({ label: t('receiptHanded'), value: money(receipt.handed) });
      if (nonZero(str(receipt.change)))
        result.push({ label: t('receiptChange'), value: money(receipt.change) });
    } else if (str(receipt.reference)) {
      result.push({ label: t('receiptReference'), value: str(receipt.reference) ?? '' });
    }
  }
  result.push({ label: t('receiptPaidTotal'), value: money(document.paid_total), strong: true });
  const credit = obj(document.credit);
  if (credit) {
    result.push({ label: t('receiptDebt'), value: money(credit.debt), strong: true });
    if (str(credit.due_on))
      result.push({ label: t('receiptDueOn'), value: formatDocumentDate(str(credit.due_on)) });
  }
  return result;
}

function header(document: Doc): string[] {
  const store = obj(document.store);
  const branch = obj(document.branch);
  return [str(store?.name), str(branch?.name), str(document.register)].filter(
    (value): value is string => value !== null,
  );
}

function customerRow(document: Doc, t: Translate): ReceiptRow[] {
  const customer = obj(document.customer);
  if (!customer) return [];
  const value = [str(customer.name), str(customer.phone)].filter(Boolean).join(' · ');
  return value ? [{ label: t('receiptCustomer'), value }] : [];
}

export function copyBanner(print: Pick<ReceiptPrint, 'copy' | 'copy_number'> | null, t: Translate) {
  return print?.copy ? t('receiptCopyBanner', { number: print.copy_number }) : null;
}

// A posted document from its server snapshot. `print` decides the banner:
// a copy is always labelled as one.
export function formatReceipt(
  receipt: ReceiptSnapshot,
  print: Pick<ReceiptPrint, 'copy' | 'copy_number'> | null,
  t: Translate,
): ReceiptDocument {
  const document = receipt.document;
  const currency = str(document.currency) ?? 'VND';
  const zone = str(document.timezone) ?? 'Asia/Ho_Chi_Minh';
  const money = (value: unknown) => formatMoney(str(value), currency);
  const meta: ReceiptRow[] = [
    {
      label: t('receiptTime'),
      value: formatDocumentTime(str(document.at) ?? receipt.issued_at, zone),
    },
  ];
  if (str(document.cashier))
    meta.push({ label: t('receiptCashier'), value: str(document.cashier) ?? '' });
  if (str(document.order_number))
    meta.push({ label: t('receiptOrderNumber'), value: str(document.order_number) ?? '' });
  if (str(document.return_number))
    meta.push({ label: t('receiptReturnNumber'), value: str(document.return_number) ?? '' });
  meta.push(...customerRow(document, t));

  let lines: ReceiptLineView[] = [];
  let totals: ReceiptRow[] = [];
  let payments: ReceiptRow[] = [];
  const notes: string[] = [];
  switch (receipt.source_type) {
    case 'sale':
      lines = saleLines(document, currency, t);
      totals = saleTotals(document, currency, t);
      payments = salePayments(document, currency, t);
      if (str(document.note)) notes.push(str(document.note) ?? '');
      break;
    case 'return':
      lines = rows(document.lines).map((line) => ({
        name: str(line.name) ?? '',
        details: [
          t('receiptReturnedQuantity', {
            quantity: formatQuantity(line.quantity as string | number),
          }),
          t(
            line.condition === 'damaged' ? 'receiptConditionDamaged' : 'receiptConditionResellable',
          ),
        ],
        amount: money(line.amount),
      }));
      totals = [
        { label: t('receiptReturnValue'), value: money(document.entitlement_total), strong: true },
      ];
      if (document.entitlement_posted) {
        if (nonZero(str(document.credit_note_amount)))
          totals.push({ label: t('receiptCreditNote'), value: money(document.credit_note_amount) });
        totals.push({
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
          label: str(document.method) === 'cash' ? t('receiptRefundCash') : t('receiptRefundBank'),
          value: money(document.amount),
          strong: true,
        },
      ];
      if (str(document.reference))
        payments.push({ label: t('receiptReference'), value: str(document.reference) ?? '' });
      break;
    case 'shift_closure':
      meta.push({
        label: t('receiptShiftOpened'),
        value: formatDocumentTime(str(document.opened_at), zone),
      });
      if (str(document.closer))
        meta.push({ label: t('receiptCloser'), value: str(document.closer) ?? '' });
      if (str(document.approver))
        meta.push({ label: t('receiptApprover'), value: str(document.approver) ?? '' });
      totals = [
        { label: t('receiptOpeningFloat'), value: money(document.opening_float) },
        { label: t('receiptInflow'), value: money(document.inflow_total) },
        { label: t('receiptOutflow'), value: money(document.outflow_total) },
        { label: t('receiptExpected'), value: money(document.expected), strong: true },
        { label: t('receiptCounted'), value: money(document.counted), strong: true },
        { label: t('receiptVariance'), value: money(document.variance), strong: true },
      ];
      if (str(document.reason)) notes.push(t('receiptReason', { reason: str(document.reason) }));
      break;
  }
  if (receipt.issued_late) notes.push(t('receiptIssuedLate'));
  return {
    banner: copyBanner(print, t),
    title: str(document.title) ?? receipt.number,
    number: receipt.number,
    header: header(document),
    meta,
    lines,
    totals,
    payments,
    notes,
    disclaimer: receipt.disclaimer,
  };
}

// A provisional bill of an open order: server figures as they stand, always
// labelled as not paid and never numbered as a receipt.
export function formatPrebill(
  workspace: PosWorkspace,
  context: { storeName?: string | null; branchName?: string | null; registerName?: string | null },
  t: Translate,
  now: Date = new Date(),
  timeZone = 'Asia/Ho_Chi_Minh',
): ReceiptDocument {
  const currency = workspace.totals?.currency ?? 'VND';
  const money = (value: string | null | undefined) => formatMoney(value ?? null, currency);
  const totals = workspace.totals;
  const lines = (workspace.line_items ?? []).map((line) => {
    const details = [
      `${formatQuantity(line.sale_quantity ?? line.quantity)}${line.sale_unit ? ` ${line.sale_unit}` : ''} × ${money(line.unit_price ?? line.price)}`,
    ];
    for (const serial of line.serial_codes ?? []) details.push(t('receiptSerial', { serial }));
    if (line.lot_code) details.push(t('receiptLot', { lot: line.lot_code }));
    return {
      name: line.name,
      details,
      amount: money(line.item_net_amount ?? line.net_amount ?? line.amount),
    };
  });
  const rowsOut: ReceiptRow[] = totals
    ? [
        { label: t('receiptItemTotal'), value: money(totals.item_total) },
        ...(nonZero(totals.discount_total)
          ? [{ label: t('receiptDiscount'), value: money(totals.discount_total) }]
          : []),
        { label: t('receiptTotal'), value: money(totals.total), strong: true },
      ]
    : [];
  const payments: ReceiptRow[] = workspace.financial
    ? [
        { label: t('receiptPaidTotal'), value: money(workspace.financial.allocated) },
        { label: t('receiptRemaining'), value: money(workspace.financial.remaining), strong: true },
      ]
    : [];
  return {
    banner: t('receiptPrebillBanner'),
    title: t('receiptPrebillTitle'),
    number: null,
    header: [context.storeName, context.branchName, context.registerName].filter(
      (value): value is string => Boolean(value),
    ),
    meta: [{ label: t('receiptTime'), value: formatDocumentTime(now.toISOString(), timeZone) }],
    lines,
    totals: rowsOut,
    payments,
    notes: [t('receiptPrebillNote')],
    disclaimer: t('receiptDisclaimer'),
  };
}

export type PrintOutcome =
  | { ok: true }
  | { ok: false; reason: 'blocked' | 'failed'; message?: string };

export interface PrintAdapter {
  deliver(paper: PaperSize): Promise<PrintOutcome>;
}

const PAGE_STYLE_ID = 'pos-receipt-page-size';
// Set on <html> only while a receipt prints: the receipt print stylesheet is
// scoped to it, so any other print of the app (tender evidence) is untouched.
export const PRINTING_ATTRIBUTE = 'data-receipt-printing';

// Roll paper has no fixed length; browsers need a definite size, so 80mm
// rolls use a long page that thermal drivers cut after the content.
export function pageRule(paper: PaperSize): string {
  return paper === '80mm'
    ? '@page { size: 80mm 297mm; margin: 3mm; }'
    : '@page { size: A4; margin: 12mm; }';
}

// Browser print of the receipt print root: sets the page size and the
// printing marker, opens the print dialog and removes both afterwards
// (on `afterprint`, or right away where the dialog blocks).
export function createBrowserPrintAdapter(win: Window = window): PrintAdapter {
  return {
    async deliver(paper) {
      const doc = win.document;
      const style = doc.createElement('style');
      style.id = PAGE_STYLE_ID;
      style.textContent = pageRule(paper);
      doc.getElementById(PAGE_STYLE_ID)?.remove();
      doc.head.append(style);
      doc.documentElement.setAttribute(PRINTING_ATTRIBUTE, paper);
      let cleaned = false;
      const cleanup = () => {
        if (cleaned) return;
        cleaned = true;
        style.remove();
        doc.documentElement.removeAttribute(PRINTING_ATTRIBUTE);
        win.removeEventListener('afterprint', cleanup);
      };
      win.addEventListener('afterprint', cleanup);
      if (typeof win.print !== 'function') {
        cleanup();
        return { ok: false, reason: 'blocked' };
      }
      try {
        win.print();
        return { ok: true };
      } catch (error) {
        return {
          ok: false,
          reason: 'failed',
          message: error instanceof Error ? error.message : undefined,
        };
      } finally {
        // Where print() blocks until the dialog closes, it is over now.
        if (!win.matchMedia?.('print').matches) cleanup();
      }
    },
  };
}
