import { formatMoney } from './money';
import type { PosFinancialAttempt, PosLineItem, PosWorkspace } from './pos-context';
import { formatDocumentTime, formatQuantity } from './print-adapter';

// The payment invoice as it goes to a small thermal printer: plain text and
// one table of items. Server figures only — nothing here computes an amount
// except the change already shown to the cashier on screen.

export type TicketPaper = '58mm' | '80mm';
export type TicketRow = { label: string; value: string; strong?: boolean };
export type TicketLine = {
  name: string;
  quantity: string;
  price: string;
  discount: string;
  total: string;
};

export type InvoiceTicket = {
  header: string[];
  title: string;
  meta: TicketRow[];
  lines: TicketLine[];
  totals: TicketRow[];
  payments: TicketRow[];
  footer: string;
};

type Translate = (key: string, options?: Record<string, unknown>) => string;

const isZero = (amount: string | null | undefined) =>
  amount == null || /^-?0+(\.0+)?$/.test(amount);

// Table cells drop the currency sign: columns are narrow on a 58mm roll.
function bare(amount: string | null | undefined, currency: string) {
  const text = formatMoney(amount, currency);
  return text.replace(/\s(₫|[A-Z]{3})$/, '');
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

export function formatInvoiceTicket(
  input: {
    workspace: PosWorkspace;
    attempts: PosFinancialAttempt[];
    handed: string | null;
    change: string | null;
    names: {
      storeName?: string | null;
      branchName?: string | null;
      registerName?: string | null;
      cashier?: string | null;
    };
  },
  t: Translate,
  now: Date = new Date(),
  timeZone = 'Asia/Ho_Chi_Minh',
): InvoiceTicket {
  const { workspace, attempts, handed, change, names } = input;
  const currency = workspace.totals?.currency ?? attempts[0]?.currency ?? 'VND';
  const money = (value: string | null | undefined) => formatMoney(value ?? null, currency);
  const meta: TicketRow[] = [
    { label: t('receiptTime'), value: formatDocumentTime(now.toISOString(), timeZone) },
  ];
  if (workspace.order_id) meta.push({ label: t('ticketOrder'), value: workspace.order_id });
  if (names.cashier) meta.push({ label: t('receiptCashier'), value: names.cashier });
  meta.push({
    label: t('receiptCustomer'),
    value: workspace.customer?.name || t('customerWalkIn'),
  });

  const lines = (workspace.line_items ?? []).map((line) => {
    const discount = lineDiscount(line);
    return {
      name: line.name,
      quantity: `${formatQuantity(line.sale_quantity ?? line.quantity)}${line.sale_unit ? ` ${line.sale_unit}` : ''}`,
      price: bare(lineUnitPrice(line), currency),
      discount: discount ? bare(discount, currency) : '',
      total: bare(line.item_net_amount ?? line.net_amount ?? line.amount, currency),
    };
  });

  const totals: TicketRow[] = [];
  if (workspace.totals) {
    totals.push({ label: t('receiptItemTotal'), value: money(workspace.totals.item_total) });
    if (!isZero(workspace.totals.discount_total))
      totals.push({
        label: workspace.coupon
          ? `${t('receiptDiscount')} (${workspace.coupon.code})`
          : t('receiptDiscount'),
        value: money(workspace.totals.discount_total),
      });
    if (!isZero(workspace.totals.additional_tax_total))
      totals.push({ label: t('receiptTax'), value: money(workspace.totals.additional_tax_total) });
    totals.push({ label: t('receiptTotal'), value: money(workspace.totals.total), strong: true });
  }

  const payments: TicketRow[] = [];
  for (const attempt of attempts) {
    const label =
      attempt.kind === 'cash'
        ? t('receiptCash')
        : attempt.kind === 'vietqr'
          ? t('receiptVietqr')
          : t('receiptBank');
    payments.push({ label, value: formatMoney(attempt.amount, attempt.currency) });
    if (attempt.kind === 'cash' && handed !== null) {
      payments.push({ label: t('receiptHanded'), value: formatMoney(handed, attempt.currency) });
      if (change !== null && !isZero(change))
        payments.push({ label: t('receiptChange'), value: formatMoney(change, attempt.currency) });
    }
  }

  return {
    header: [names.storeName, names.branchName, names.registerName].filter(
      (value): value is string => Boolean(value),
    ),
    title: t('ticketTitle'),
    meta,
    lines,
    totals,
    payments,
    footer: t('ticketThanks'),
  };
}
