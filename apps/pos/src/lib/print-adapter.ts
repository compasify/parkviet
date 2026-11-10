import {
  type PrintPlace,
  prebillData,
  snapshotData,
  snapshotDocumentType,
} from '@parkviet/pos-shared/receipt-template/data';
import { defaultTemplate } from '@parkviet/pos-shared/receipt-template/defaults';
import { renderDocument } from '@parkviet/pos-shared/receipt-template/render';
import type {
  PaperSize,
  PrintDocument,
  TemplateConfig,
} from '@parkviet/pos-shared/receipt-template/types';
import type { ReceiptPrint, ReceiptSnapshot } from '@parkviet/pos-shared/types/print-adapter';
import type { PosWorkspace } from './pos-context';

// Printing is two steps behind one interface: a template renderer turns a
// server receipt snapshot (or a provisional pre-bill of an open order) into
// a printable document without computing any amount, and `deliver` sends it
// to a printer. Only a browser implementation exists; a native driver or
// silent printing would be another adapter after merchant device approval.
// A failed or blocked print is reported and never undoes or repeats a sale.

export { isPaperSize, PAPER_SIZES } from '@parkviet/pos-shared/paper-size';
export {
  formatDocumentDate,
  formatDocumentTime,
  formatQuantity,
} from '@parkviet/pos-shared/receipt-template/data';
export type { PaperSize } from '@parkviet/pos-shared/receipt-template/types';
export type { ReceiptPrint, ReceiptSnapshot } from '@parkviet/pos-shared/types/print-adapter';

type Translate = (key: string, options?: Record<string, unknown>) => string;

const str = (value: unknown): string | null =>
  typeof value === 'string' && value !== '' ? value : null;

export function copyBanner(print: Pick<ReceiptPrint, 'copy' | 'copy_number'> | null, t: Translate) {
  return print?.copy ? t('receiptCopyBanner', { number: print.copy_number }) : null;
}

// A posted document from its server snapshot, laid out by `config` (the
// built-in template of its type by default). `print` decides the banner: a
// copy is always labelled as one, whatever the template.
export function receiptPrintDocument(
  receipt: ReceiptSnapshot,
  print: Pick<ReceiptPrint, 'copy' | 'copy_number'> | null,
  t: Translate,
  config: TemplateConfig = defaultTemplate(snapshotDocumentType(receipt)),
): PrintDocument {
  return renderDocument(config, snapshotData(receipt, t), { banner: copyBanner(print, t) });
}

// A provisional bill of an open order: server figures as they stand, always
// labelled as not paid and never numbered as a receipt.
export function prebillPrintDocument(
  workspace: PosWorkspace,
  place: PrintPlace,
  t: Translate,
  now: Date = new Date(),
  timeZone = 'Asia/Ho_Chi_Minh',
  config: TemplateConfig = defaultTemplate('prebill'),
): PrintDocument {
  return renderDocument(config, prebillData(workspace, place, t, now, timeZone));
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

// How long a print waits for its images (the store logo) to decode.
export const IMAGE_WAIT_MS = 1500;
// Set on an image that did not decode in time: hidden from that print.
export const SKIPPED_IMAGE_ATTRIBUTE = 'data-print-skipped';

// Waits until every image of the print root decoded, or the wait is over;
// returns the images that are not ready, so the print goes out without them.
export async function settleImages(
  doc: Document,
  win: Pick<Window, 'setTimeout' | 'clearTimeout'>,
  waitMs = IMAGE_WAIT_MS,
): Promise<HTMLImageElement[]> {
  if (typeof doc.querySelectorAll !== 'function') return [];
  const images = Array.from(doc.querySelectorAll<HTMLImageElement>('.receipt-print-root img'));
  if (images.length === 0) return [];
  let timer: number | undefined;
  const expired = new Promise<false>((resolve) => {
    timer = win.setTimeout(() => resolve(false), waitMs);
  });
  const ready = await Promise.all(
    images.map((image) =>
      Promise.race([
        (typeof image.decode === 'function' ? image.decode() : Promise.resolve()).then(
          () => true,
          () => false,
        ),
        expired,
      ]),
    ),
  );
  win.clearTimeout(timer);
  return images.filter((_, index) => !ready[index]);
}

// Browser print of the receipt print root: waits for its images, sets the
// page size and the printing marker, opens the print dialog and removes
// both afterwards (on `afterprint`, or right away where the dialog blocks).
export function createBrowserPrintAdapter(win: Window = window): PrintAdapter {
  return {
    async deliver(paper, options) {
      const doc = win.document;
      const skipped = await settleImages(doc, win);
      for (const image of skipped) image.setAttribute(SKIPPED_IMAGE_ATTRIBUTE, '');
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
        for (const image of skipped) image.removeAttribute(SKIPPED_IMAGE_ATTRIBUTE);
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
