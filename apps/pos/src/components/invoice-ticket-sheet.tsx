import type { PaperSize, PrintDocument } from '../lib/receipt-template/types';
import { PrintPortal, PrintSheet } from './print-sheet';

// The payment invoice on the paper of its template: centred text header, one
// items table (name on its own row, then quantity / price / discount / total).
export function InvoiceTicketSheet({
  document,
  paper,
  testId = 'invoice-ticket',
}: {
  document: PrintDocument;
  paper: PaperSize;
  testId?: string;
}) {
  return <PrintSheet document={document} paper={paper} testId={testId} />;
}

export function InvoiceTicketPrintPortal(props: { document: PrintDocument; paper: PaperSize }) {
  return <PrintPortal {...props} testId="invoice-ticket-print" />;
}
