import { documentTitle, textLines } from './print-adapter';
import { type PaymentTicketInput, paymentTicketData } from './receipt-template/data';
import { defaultTemplate } from './receipt-template/defaults';
import { renderDocument } from './receipt-template/render';
import type { PrintDocument } from './receipt-template/types';

// The payment invoice as it goes to a small thermal printer: plain text and
// one table of items. Server figures only — nothing here computes an amount
// except the change already shown to the cashier on screen.

export { lineDiscount, lineUnitPrice } from './receipt-template/data';

export type TicketPaper = '58mm' | '80mm';
export type TicketRow = { label: string; value: string; strong?: boolean };
export type TicketLine = {
  name: string;
  quantity: string;
  price: string;
  discount: string;
  total: string;
};

// The flat view of a payment invoice, kept for callers that read the
// printed content rather than lay it out.
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

export function invoiceTicketPrintDocument(
  input: PaymentTicketInput,
  t: Translate,
  now: Date = new Date(),
  timeZone = 'Asia/Ho_Chi_Minh',
): PrintDocument {
  return renderDocument(
    defaultTemplate('payment_ticket'),
    paymentTicketData(input, t, now, timeZone),
  );
}

export function formatInvoiceTicket(
  input: PaymentTicketInput,
  t: Translate,
  now: Date = new Date(),
  timeZone = 'Asia/Ho_Chi_Minh',
): InvoiceTicket {
  const document = invoiceTicketPrintDocument(input, t, now, timeZone);
  const table = document.lines.layout === 'table' ? document.lines : null;
  const cell = (cells: string[], key: string) =>
    cells[table?.columns.findIndex((column) => column.key === key) ?? -1] ?? '';
  return {
    header: textLines(document.header),
    title: documentTitle(document).title,
    meta: document.meta,
    lines: (table?.rows ?? []).map((row) => ({
      name: row.name,
      quantity: cell(row.cells, 'qty'),
      price: cell(row.cells, 'price'),
      discount: cell(row.cells, 'discount'),
      total: cell(row.cells, 'amount'),
    })),
    totals: document.totals,
    payments: document.payments,
    footer: textLines(document.footer).join('\n'),
  };
}
