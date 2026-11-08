import type { CSSProperties } from 'react';
import { createPortal } from 'react-dom';
import type {
  PaperSize,
  PrintBlock,
  PrintDocument,
  PrintLines,
  PrintRow,
} from '../lib/receipt-template/types';
import '../styles/receipt.css';

const DEFAULT_LINE_SPACING = 1.35;

function Rows({ rows, className }: { rows: PrintRow[]; className: string }) {
  if (rows.length === 0) return null;
  return (
    <dl className={className}>
      {rows.map((row, index) => (
        // biome-ignore lint/suspicious/noArrayIndexKey: print documents are immutable, positional output
        <div key={index} className={row.strong ? 'receipt-strong' : undefined}>
          <dt>{row.label}</dt>
          <dd>{row.value}</dd>
        </div>
      ))}
    </dl>
  );
}

const classes = (...names: (string | false | null | undefined)[]) =>
  names.filter(Boolean).join(' ') || undefined;

const alignClass = (align: string) => (align === 'center' ? null : `receipt-align-${align}`);

function Block({ block }: { block: PrintBlock }) {
  switch (block.kind) {
    case 'text': {
      const className = classes(
        alignClass(block.align),
        block.bold && 'receipt-bold',
        block.size !== 'm' && `receipt-size-${block.size}`,
      );
      return (
        <>
          {block.lines.map((line, index) => (
            // biome-ignore lint/suspicious/noArrayIndexKey: print documents are immutable, positional output
            <p key={index} className={className}>
              {line}
            </p>
          ))}
        </>
      );
    }
    case 'image':
      return (
        <p className={classes('receipt-logo', alignClass(block.align))}>
          <img src={block.src} alt={block.alt} style={{ width: `${block.widthPct}%` }} />
        </p>
      );
    case 'title':
      return (
        <>
          <h2>{block.title}</h2>
          {block.number ? <p className="receipt-number">{block.number}</p> : null}
        </>
      );
    case 'divider':
      return <div className={`receipt-divider receipt-divider-${block.style}`} />;
    case 'spacer':
      return <div className="receipt-spacer" style={{ height: `${block.mm}mm` }} />;
  }
}

function Blocks({ blocks }: { blocks: PrintBlock[] }) {
  return blocks.map((block, index) => (
    // biome-ignore lint/suspicious/noArrayIndexKey: print documents are immutable, positional output
    <Block key={index} block={block} />
  ));
}

const numbered = (index: number | null, name: string) =>
  index === null ? name : `${index}. ${name}`;

function Lines({ lines }: { lines: PrintLines }) {
  if (lines.layout === 'table') {
    if (lines.rows.length === 0) return null;
    const span = Math.max(lines.columns.length, 1);
    return (
      <table className="ticket-table">
        {lines.columns.length > 0 ? (
          <thead>
            <tr>
              {lines.columns.map((column) => (
                <th key={column.key} scope="col">
                  {column.label}
                </th>
              ))}
            </tr>
          </thead>
        ) : null}
        {lines.rows.map((row, index) => (
          // biome-ignore lint/suspicious/noArrayIndexKey: print documents are immutable, positional output
          <tbody key={index}>
            <tr className="ticket-name">
              <td colSpan={span}>{numbered(row.index, row.name)}</td>
            </tr>
            {row.details.map((detail, position) => (
              // biome-ignore lint/suspicious/noArrayIndexKey: print documents are immutable, positional output
              <tr key={position} className="ticket-detail">
                <td colSpan={span}>{detail}</td>
              </tr>
            ))}
            {lines.columns.length > 0 ? (
              <tr className="ticket-figures">
                {row.cells.map((cell, position) => (
                  <td key={lines.columns[position]?.key ?? position}>{cell}</td>
                ))}
              </tr>
            ) : null}
          </tbody>
        ))}
      </table>
    );
  }
  if (lines.items.length === 0) return null;
  return (
    <ol className="receipt-lines">
      {lines.items.map((line, index) => (
        // biome-ignore lint/suspicious/noArrayIndexKey: print documents are immutable, positional output
        <li key={index}>
          <div className="receipt-line-head">
            <span>{numbered(line.index, line.name)}</span>
            {line.amount !== null ? <span className="receipt-money">{line.amount}</span> : null}
          </div>
          {line.details.map((detail, position) => (
            // biome-ignore lint/suspicious/noArrayIndexKey: print documents are immutable, positional output
            <p key={position} className="receipt-line-detail">
              {detail}
            </p>
          ))}
        </li>
      ))}
    </ol>
  );
}

// One printable document as the renderer resolved it. This component only
// lays it out for a roll or a sheet; content and labels come from the
// template and the data. `printId` marks the recorded print this sheet
// carries the label of.
export function PrintSheet({
  document,
  paper,
  printId,
  testId,
}: {
  document: PrintDocument;
  paper: PaperSize;
  printId?: string | null;
  testId: string;
}) {
  const { page } = document;
  const style: CSSProperties | undefined =
    page.line_spacing === DEFAULT_LINE_SPACING ? undefined : { lineHeight: page.line_spacing };
  return (
    <article
      className={classes(
        'receipt-sheet',
        document.documentType === 'payment_ticket' && 'invoice-ticket',
        `receipt-${paper}`,
        page.font === 'mono' && 'receipt-font-mono',
        page.font_size !== 'm' && `receipt-scale-${page.font_size}`,
      )}
      style={style}
      data-testid={testId}
      data-paper={paper}
      data-print-id={printId ?? undefined}
    >
      {document.banners.map((banner) => (
        <p key={banner} className="receipt-banner">
          {banner}
        </p>
      ))}
      <header className="receipt-header">
        <Blocks blocks={document.header} />
      </header>
      <Rows rows={document.meta} className="receipt-meta" />
      <Lines lines={document.lines} />
      <Rows rows={document.totals} className="receipt-totals" />
      <Rows rows={document.payments} className="receipt-payments" />
      {document.notes.map((note, index) => (
        // biome-ignore lint/suspicious/noArrayIndexKey: print documents are immutable, positional output
        <p key={index} className="receipt-note">
          {note}
        </p>
      ))}
      {document.footer.length > 0 ? (
        <footer className="receipt-footer">
          <Blocks blocks={document.footer} />
        </footer>
      ) : null}
      {document.disclaimer ? <p className="receipt-disclaimer">{document.disclaimer}</p> : null}
    </article>
  );
}

// The copy that is printed: at the end of <body>, hidden on screen and the
// only visible content while the print adapter's marker is set.
export function PrintPortal(props: {
  document: PrintDocument;
  paper: PaperSize;
  printId?: string | null;
  testId: string;
}) {
  return createPortal(
    <div className="receipt-print-root receipt-print-portal">
      <PrintSheet {...props} />
    </div>,
    window.document.body,
  );
}
