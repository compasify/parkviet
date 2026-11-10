import {
  renderSheetContentHtml,
  sheetClassName,
  sheetLineHeight,
} from '@parkviet/pos-shared/receipt-template/sheet-html';
import type { PaperSize, PrintDocument } from '@parkviet/pos-shared/receipt-template/types';
import { useMemo } from 'react';
import { createPortal } from 'react-dom';
import '@parkviet/pos-shared/receipt.css';

// One printable document as the renderer resolved it. The markup inside the
// sheet comes from the shared sheet renderer, the same one the
// administration preview shows, so print and preview cannot drift; it
// escapes every text and attribute value. `printId` marks the recorded
// print this sheet carries the label of. `markOverflow` underlines header
// and footer text past the estimated line width (the editor preview);
// prints never do.
export function PrintSheet({
  document,
  paper,
  printId,
  testId,
  markOverflow = false,
}: {
  document: PrintDocument;
  paper: PaperSize;
  printId?: string | null;
  testId: string;
  markOverflow?: boolean;
}) {
  const html = useMemo(
    () => renderSheetContentHtml(document, { paper, markOverflow }),
    [document, paper, markOverflow],
  );
  const lineHeight = sheetLineHeight(document);
  return (
    <article
      className={sheetClassName(document, paper)}
      style={lineHeight === null ? undefined : { lineHeight }}
      data-testid={testId}
      data-paper={paper}
      data-print-id={printId ?? undefined}
      // biome-ignore lint/security/noDangerouslySetInnerHtml: the shared sheet renderer escapes all document text and attributes
      dangerouslySetInnerHTML={{ __html: html }}
    />
  );
}

export type PrintedSheet = { document: PrintDocument; printId?: string | null };

// The copies that are printed: at the end of <body>, hidden on screen and
// the only visible content while the print adapter's marker is set. Several
// sheets (the original and its copies) print on separate pages.
export function PrintPortal({
  sheets,
  paper,
  testId,
}: {
  sheets: PrintedSheet[];
  paper: PaperSize;
  testId: string;
}) {
  return createPortal(
    <div className="receipt-print-root receipt-print-portal">
      {sheets.map((sheet) => (
        <PrintSheet
          key={sheet.printId ?? 'sheet'}
          document={sheet.document}
          paper={paper}
          printId={sheet.printId}
          testId={testId}
        />
      ))}
    </div>,
    window.document.body,
  );
}
