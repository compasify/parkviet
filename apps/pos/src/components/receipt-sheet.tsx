import { createPortal } from 'react-dom';
import type { PaperSize, ReceiptDocument, ReceiptRow } from '../lib/print-adapter';
import '../styles/receipt.css';

function Rows({ rows, className }: { rows: ReceiptRow[]; className: string }) {
  if (rows.length === 0) return null;
  return (
    <dl className={className}>
      {rows.map((row, index) => (
        // biome-ignore lint/suspicious/noArrayIndexKey: labels may repeat (two cash receipts)
        <div key={index} className={row.strong ? 'receipt-strong' : undefined}>
          <dt>{row.label}</dt>
          <dd>{row.value}</dd>
        </div>
      ))}
    </dl>
  );
}

// One printable document. Content comes from the formatter only; this
// component lays it out for an 80mm roll or an A4 sheet.
// `printId` marks the recorded print this sheet carries the label of.
export function ReceiptSheet({
  document,
  paper,
  printId,
  testId = 'receipt-sheet',
}: {
  document: ReceiptDocument;
  paper: PaperSize;
  printId?: string | null;
  testId?: string;
}) {
  return (
    <article
      className={`receipt-sheet receipt-${paper}`}
      data-testid={testId}
      data-paper={paper}
      data-print-id={printId ?? undefined}
    >
      {document.banner ? <p className="receipt-banner">{document.banner}</p> : null}
      <header className="receipt-header">
        {document.header.map((line) => (
          <p key={line}>{line}</p>
        ))}
        <h2>{document.title}</h2>
        {document.number ? <p className="receipt-number">{document.number}</p> : null}
      </header>
      <Rows rows={document.meta} className="receipt-meta" />
      {document.lines.length > 0 ? (
        <ol className="receipt-lines">
          {document.lines.map((line, index) => (
            // biome-ignore lint/suspicious/noArrayIndexKey: document lines keep their printed order
            <li key={index}>
              <div className="receipt-line-head">
                <span>{line.name}</span>
                <span className="receipt-money">{line.amount}</span>
              </div>
              {line.details.map((detail) => (
                <p key={detail} className="receipt-line-detail">
                  {detail}
                </p>
              ))}
            </li>
          ))}
        </ol>
      ) : null}
      <Rows rows={document.totals} className="receipt-totals" />
      <Rows rows={document.payments} className="receipt-payments" />
      {document.notes.map((note) => (
        <p key={note} className="receipt-note">
          {note}
        </p>
      ))}
      <p className="receipt-disclaimer">{document.disclaimer}</p>
    </article>
  );
}

// The copy that is printed: at the end of <body>, hidden on screen and the
// only visible content while the receipt print marker is set.
export function ReceiptPrintPortal(props: {
  document: ReceiptDocument;
  paper: PaperSize;
  printId?: string | null;
}) {
  return createPortal(
    <div className="receipt-print-root receipt-print-portal">
      <ReceiptSheet {...props} testId="receipt-print-sheet" />
    </div>,
    window.document.body,
  );
}
