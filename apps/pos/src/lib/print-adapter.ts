import type { PosWorkspace } from './pos-context';
import {
  type PrintPlace,
  prebillData,
  snapshotData,
  snapshotDocumentType,
} from './receipt-template/data';
import { defaultTemplate } from './receipt-template/defaults';
import { renderDocument } from './receipt-template/render';
import type { PaperSize, PrintBlock, PrintDocument } from './receipt-template/types';

// Printing is two steps behind one interface: a template renderer turns a
// server receipt snapshot (or a provisional pre-bill of an open order) into
// a printable document without computing any amount, and `deliver` sends it
// to a printer. Only a browser implementation exists; a native driver or
// silent printing would be another adapter after merchant device approval.
// A failed or blocked print is reported and never undoes or repeats a sale.

export {
  formatDocumentDate,
  formatDocumentTime,
  formatQuantity,
} from './receipt-template/data';
export type { PaperSize } from './receipt-template/types';

// Every size a posted receipt can print on: thermal rolls first, then sheets.
export const PAPER_SIZES: readonly PaperSize[] = ['58mm', '80mm', 'a4', 'a5', 'a6'];

export const isPaperSize = (value: unknown): value is PaperSize =>
  typeof value === 'string' && (PAPER_SIZES as readonly string[]).includes(value);

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

// The flat view of a stacked document, kept for callers that read the
// printed content rather than lay it out.
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

const str = (value: unknown): string | null =>
  typeof value === 'string' && value !== '' ? value : null;

export function copyBanner(print: Pick<ReceiptPrint, 'copy' | 'copy_number'> | null, t: Translate) {
  return print?.copy ? t('receiptCopyBanner', { number: print.copy_number }) : null;
}

// A posted document from its server snapshot, laid out by the built-in
// template of its type. `print` decides the banner: a copy is always
// labelled as one.
export function receiptPrintDocument(
  receipt: ReceiptSnapshot,
  print: Pick<ReceiptPrint, 'copy' | 'copy_number'> | null,
  t: Translate,
): PrintDocument {
  return renderDocument(defaultTemplate(snapshotDocumentType(receipt)), snapshotData(receipt, t), {
    banner: copyBanner(print, t),
  });
}

// A provisional bill of an open order: server figures as they stand, always
// labelled as not paid and never numbered as a receipt.
export function prebillPrintDocument(
  workspace: PosWorkspace,
  place: PrintPlace,
  t: Translate,
  now: Date = new Date(),
  timeZone = 'Asia/Ho_Chi_Minh',
): PrintDocument {
  return renderDocument(
    defaultTemplate('prebill'),
    prebillData(workspace, place, t, now, timeZone),
  );
}

export const textLines = (blocks: PrintBlock[]) =>
  blocks.flatMap((block) => (block.kind === 'text' ? block.lines : []));

export function documentTitle(document: PrintDocument) {
  const title = document.header.find((block) => block.kind === 'title');
  return title?.kind === 'title' ? title : { title: '', number: null };
}

export function toReceiptDocument(document: PrintDocument): ReceiptDocument {
  const { title, number } = documentTitle(document);
  return {
    banner: document.banners[0] ?? null,
    title,
    number,
    header: textLines(document.header),
    meta: document.meta,
    lines:
      document.lines.layout === 'stacked'
        ? document.lines.items.map((line) => ({
            name: line.index === null ? line.name : `${line.index}. ${line.name}`,
            details: line.details,
            amount: line.amount ?? '',
          }))
        : [],
    totals: document.totals,
    payments: document.payments,
    notes: document.notes,
    disclaimer: document.disclaimer ?? '',
  };
}

export function formatReceipt(
  receipt: ReceiptSnapshot,
  print: Pick<ReceiptPrint, 'copy' | 'copy_number'> | null,
  t: Translate,
): ReceiptDocument {
  return toReceiptDocument(receiptPrintDocument(receipt, print, t));
}

export function formatPrebill(
  workspace: PosWorkspace,
  context: PrintPlace,
  t: Translate,
  now: Date = new Date(),
  timeZone = 'Asia/Ho_Chi_Minh',
): ReceiptDocument {
  return toReceiptDocument(prebillPrintDocument(workspace, context, t, now, timeZone));
}

export type PrintOutcome =
  | { ok: true }
  | { ok: false; reason: 'blocked' | 'failed'; message?: string };

// `title` replaces the page title while printing: browsers print it in the
// page header and use it as the file name when saving as PDF.
export type PrintOptions = { title?: string | null };

export interface PrintAdapter {
  deliver(paper: PaperSize, options?: PrintOptions): Promise<PrintOutcome>;
}

// "Hóa đơn HD-0001 - Đơn R250": the document name and the order it belongs
// to, without characters a file name cannot carry.
export function printTitle(
  name: string,
  number: string | null | undefined,
  orderNumber: string | null | undefined,
  t: Translate,
): string {
  const parts = [number ? `${name} ${number}` : name];
  if (orderNumber && orderNumber !== number)
    parts.push(t('receiptPrintTitleOrder', { number: orderNumber }));
  return parts
    .join(' - ')
    .replace(/[\\/:*?"<>|]+/g, '-')
    .trim();
}

// The print title of a posted receipt.
export function receiptPrintTitle(receipt: ReceiptSnapshot, t: Translate): string {
  return printTitle(
    t(`receiptPrintTitle_${receipt.source_type}`),
    receipt.number,
    str(receipt.document.order_number),
    t,
  );
}

const PAGE_STYLE_ID = 'pos-receipt-page-size';
// Set on <html> only while a receipt prints: the receipt print stylesheet is
// scoped to it, so any other print of the app (tender evidence) is untouched.
export const PRINTING_ATTRIBUTE = 'data-receipt-printing';

// Roll paper has no fixed length; browsers need a definite size, so 80mm
// rolls use a long page that thermal drivers cut after the content.
// Sheet margins match the printable widths in receipt.css (A4 186mm, A5
// 128mm, A6 93mm).
export function pageRule(paper: PaperSize): string {
  switch (paper) {
    case '58mm':
      return '@page { size: 58mm 297mm; margin: 2mm; }';
    case '80mm':
      return '@page { size: 80mm 297mm; margin: 3mm; }';
    case 'a5':
      return '@page { size: A5; margin: 10mm; }';
    case 'a6':
      return '@page { size: A6; margin: 6mm; }';
    default:
      return '@page { size: A4; margin: 12mm; }';
  }
}

// Browser print of the receipt print root: sets the page size and the
// printing marker, opens the print dialog and removes both afterwards
// (on `afterprint`, or right away where the dialog blocks).
export function createBrowserPrintAdapter(win: Window = window): PrintAdapter {
  return {
    async deliver(paper, options) {
      const doc = win.document;
      const style = doc.createElement('style');
      style.id = PAGE_STYLE_ID;
      style.textContent = pageRule(paper);
      doc.getElementById(PAGE_STYLE_ID)?.remove();
      doc.head.append(style);
      doc.documentElement.setAttribute(PRINTING_ATTRIBUTE, paper);
      const pageTitle = doc.title;
      if (options?.title) doc.title = options.title;
      let cleaned = false;
      const cleanup = () => {
        if (cleaned) return;
        cleaned = true;
        style.remove();
        if (options?.title) doc.title = pageTitle;
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
