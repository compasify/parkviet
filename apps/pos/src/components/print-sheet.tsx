import type {
  PaperSize,
  PrintBlock,
  PrintDocument,
  PrintLines,
  PrintRow,
  TextSize,
} from '@parkviet/pos-shared/receipt-template/types';
import { charsPerLine, WIDE_PAPERS } from '@parkviet/pos-shared/receipt-template/validate';
import type { CSSProperties } from 'react';
import { createPortal } from 'react-dom';
import { BarcodeBlock } from './receipt-template/barcode-block';
import { QrCodeBlock } from './receipt-template/qr-block';
import { SignatureBlock } from './receipt-template/signature-block';
import '@parkviet/pos-shared/receipt.css';

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

// How the sheet is laid out: the paper decides sheet-only blocks and the
// line table; `wrapAt` (editor preview only) gives the characters a line
// of text fits, so the part that will wrap is underlined.
type Layout = { paper: PaperSize; wrapAt: ((size: TextSize) => number | null) | null };

// A text line with the part past the line width underlined.
function TextLine({ line, limit }: { line: string; limit: number | null }) {
  if (limit === null || line.length <= limit) return <>{line}</>;
  return (
    <>
      {line.slice(0, limit)}
      <span className="receipt-overflow" data-testid="receipt-overflow">
        {line.slice(limit)}
      </span>
    </>
  );
}

function Block({ block, layout }: { block: PrintBlock; layout: Layout }) {
  switch (block.kind) {
    case 'text': {
      const className = classes(
        alignClass(block.align),
        block.bold && 'receipt-bold',
        block.size !== 'm' && `receipt-size-${block.size}`,
      );
      const limit = layout.wrapAt?.(block.size) ?? null;
      return (
        <>
          {block.lines.map((line, index) => (
            // biome-ignore lint/suspicious/noArrayIndexKey: print documents are immutable, positional output
            <p key={index} className={className}>
              <TextLine line={line} limit={limit} />
            </p>
          ))}
        </>
      );
    }
    case 'image':
      return (
        <p
          className={classes(
            'receipt-logo',
            alignClass(block.align),
            block.monochrome && 'receipt-logo-mono',
          )}
        >
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
    case 'qr':
      return <QrCodeBlock value={block.value} caption={block.caption} align={block.align} />;
    case 'barcode':
      return <BarcodeBlock value={block.value} align={block.align} paper={layout.paper} />;
    case 'signatures':
      return WIDE_PAPERS.includes(layout.paper) ? <SignatureBlock parties={block.parties} /> : null;
  }
}

function Blocks({ blocks, layout }: { blocks: PrintBlock[]; layout: Layout }) {
  return blocks.map((block, index) => (
    // biome-ignore lint/suspicious/noArrayIndexKey: print documents are immutable, positional output
    <Block key={index} block={block} layout={layout} />
  ));
}

const numbered = (index: number | null, name: string) =>
  index === null ? name : `${index}. ${name}`;

// The lines of a table template on an A4 or A5 sheet: one ruled row per
// line, the line number and every column in its own cell.
function SheetTable({ lines }: { lines: Extract<PrintLines, { layout: 'table' }> }) {
  const { headings } = lines;
  return (
    <table className="receipt-grid">
      <thead>
        <tr>
          {headings.index !== null ? (
            <th scope="col" className="receipt-grid-index">
              {headings.index}
            </th>
          ) : null}
          <th scope="col" className="receipt-grid-name">
            {headings.name}
          </th>
          {lines.columns.map((column) => (
            <th key={column.key} scope="col">
              {column.label}
            </th>
          ))}
        </tr>
      </thead>
      <tbody>
        {lines.rows.map((row, index) => (
          // biome-ignore lint/suspicious/noArrayIndexKey: print documents are immutable, positional output
          <tr key={index}>
            {headings.index !== null ? <td className="receipt-grid-index">{row.index}</td> : null}
            <td className="receipt-grid-name">
              {row.name}
              {row.details.map((detail, position) => (
                // biome-ignore lint/suspicious/noArrayIndexKey: print documents are immutable, positional output
                <small key={position}>{detail}</small>
              ))}
            </td>
            {row.cells.map((cell, position) => (
              <td key={lines.columns[position]?.key ?? position}>{cell}</td>
            ))}
          </tr>
        ))}
      </tbody>
    </table>
  );
}

function Lines({ lines, paper }: { lines: PrintLines; paper: PaperSize }) {
  if (lines.layout === 'table') {
    if (lines.rows.length === 0) return null;
    if (WIDE_PAPERS.includes(paper)) return <SheetTable lines={lines} />;
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
// carries the label of. `markOverflow` underlines header and footer text
// past the estimated line width (the editor preview); prints never do.
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
  const { page } = document;
  const style: CSSProperties | undefined =
    page.line_spacing === DEFAULT_LINE_SPACING ? undefined : { lineHeight: page.line_spacing };
  const layout: Layout = {
    paper,
    wrapAt: markOverflow ? (size) => charsPerLine(paper, page.font_size, size) : null,
  };
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
        <Blocks blocks={document.header} layout={layout} />
      </header>
      <Rows rows={document.meta} className="receipt-meta" />
      <Lines lines={document.lines} paper={paper} />
      <Rows rows={document.totals} className="receipt-totals" />
      <Rows rows={document.payments} className="receipt-payments" />
      {document.payQr ? (
        <section className="receipt-pay-qr" data-testid="receipt-pay-qr">
          <QrCodeBlock
            value={document.payQr.value}
            caption={document.payQr.caption}
            align="center"
          />
          {document.payQr.lines.map((line, index) => (
            // biome-ignore lint/suspicious/noArrayIndexKey: print documents are immutable, positional output
            <p key={index}>{line}</p>
          ))}
        </section>
      ) : null}
      {document.notes.map((note, index) => (
        // biome-ignore lint/suspicious/noArrayIndexKey: print documents are immutable, positional output
        <p key={index} className="receipt-note">
          {note}
        </p>
      ))}
      {document.footer.length > 0 ? (
        <footer className="receipt-footer">
          <Blocks blocks={document.footer} layout={layout} />
        </footer>
      ) : null}
      {document.disclaimer ? <p className="receipt-disclaimer">{document.disclaimer}</p> : null}
    </article>
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
