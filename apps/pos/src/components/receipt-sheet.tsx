import type { PaperSize } from '../lib/print-adapter';
import type { PrintDocument } from '../lib/receipt-template/types';
import { PrintPortal, PrintSheet } from './print-sheet';

// A posted receipt or a pre-bill, on an 80mm roll or a sheet.
export function ReceiptSheet({
  document,
  paper,
  printId,
  testId = 'receipt-sheet',
}: {
  document: PrintDocument;
  paper: PaperSize;
  printId?: string | null;
  testId?: string;
}) {
  return <PrintSheet document={document} paper={paper} printId={printId} testId={testId} />;
}

export function ReceiptPrintPortal(props: {
  document: PrintDocument;
  paper: PaperSize;
  printId?: string | null;
}) {
  return <PrintPortal {...props} testId="receipt-print-sheet" />;
}
