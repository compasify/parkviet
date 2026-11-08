import type { PaperSize } from '../lib/print-adapter';
import type { PrintDocument } from '../lib/receipt-template/types';
import { type PrintedSheet, PrintPortal, PrintSheet } from './print-sheet';

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

// The print copy; `sheets` replaces the single document when one press
// prints the original and its copies.
export function ReceiptPrintPortal({
  document,
  paper,
  printId,
  sheets,
}: {
  document: PrintDocument;
  paper: PaperSize;
  printId?: string | null;
  sheets?: PrintedSheet[];
}) {
  return (
    <PrintPortal
      sheets={sheets ?? [{ document, printId }]}
      paper={paper}
      testId="receipt-print-sheet"
    />
  );
}
