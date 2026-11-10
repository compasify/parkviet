// biome-ignore-all lint/suspicious/noArrayIndexKey: PrintDocument is immutable positional output; these rows have no identity or local state.

import {
  barcodeWidthMm,
  code128Bars,
  QUIET_ZONE,
} from '@parkviet/pos-shared/receipt-template/code128'
import type {
  Align,
  PaperSize,
  PrintBlock,
  PrintDocument,
  PrintLines,
  PrintRow,
  TextSize,
} from '@parkviet/pos-shared/receipt-template/types'
import {
  charsPerLine,
  PRINTABLE_WIDTH_MM,
  WIDE_PAPERS,
} from '@parkviet/pos-shared/receipt-template/validate'
import { type CSSProperties, useMemo } from 'react'
import { encode } from 'uqr'

// Presentation-only twin of the POS PrintSheet. Both consume the same shared
// PrintDocument and receipt.css; no dashboard styles are loaded into its frame.
const classes = (...names: (string | false | null | undefined)[]) =>
  names.filter(Boolean).join(' ') || undefined
const alignClass = (align: string) => (align === 'center' ? null : `receipt-align-${align}`)
type Layout = { paper: PaperSize; wrapAt: ((size: TextSize) => number | null) | null }

function QrCodeBlock({
  value,
  caption,
  align,
}: {
  value: string
  caption: string | null
  align: Align
}) {
  const code = useMemo(() => {
    try {
      const { size, data } = encode(value, { ecc: 'M', border: 4 })
      const parts: string[] = []
      data.forEach((row, y) => {
        let x = 0
        while (x < size) {
          if (!row[x]) {
            x += 1
            continue
          }
          const start = x
          while (x < size && row[x]) x += 1
          parts.push(`M${start} ${y}h${x - start}v1h${start - x}z`)
        }
      })
      return { size, path: parts.join('') }
    } catch {
      return null
    }
  }, [value])
  if (!code) return null
  return (
    <figure className={`receipt-qr receipt-code-${align}`} data-qr-value={value}>
      <svg
        viewBox={`0 0 ${code.size} ${code.size}`}
        shapeRendering="crispEdges"
        role="img"
        aria-label={caption ?? value}
      >
        <path d={code.path} fill="#000" />
      </svg>
      {caption ? <figcaption>{caption}</figcaption> : null}
    </figure>
  )
}
function BarcodeBlock({ value, align, paper }: { value: string; align: Align; paper: PaperSize }) {
  const code = useMemo(() => code128Bars(value), [value])
  const widthMm = barcodeWidthMm(value, PRINTABLE_WIDTH_MM[paper])
  if (!code || widthMm === null) return null
  return (
    <figure className={`receipt-barcode receipt-code-${align}`} data-barcode-value={value}>
      <svg
        viewBox={`0 0 ${code.modules + QUIET_ZONE * 2} 30`}
        preserveAspectRatio="none"
        shapeRendering="crispEdges"
        style={{ width: `${widthMm.toFixed(1)}mm` }}
        role="img"
        aria-label={value}
      >
        {code.bars.map((bar) => (
          <rect
            key={bar.x}
            x={bar.x + QUIET_ZONE}
            y={0}
            width={bar.width}
            height={30}
            fill="#000"
          />
        ))}
      </svg>
      <figcaption>{value}</figcaption>
    </figure>
  )
}
function Rows({ rows, className }: { rows: PrintRow[]; className: string }) {
  if (!rows.length) return null
  return (
    <dl className={className}>
      {rows.map((row, index) => (
        <div key={index} className={row.strong ? 'receipt-strong' : undefined}>
          <dt>{row.label}</dt>
          <dd>{row.value}</dd>
        </div>
      ))}
    </dl>
  )
}
function TextLine({ line, limit }: { line: string; limit: number | null }) {
  if (limit === null || line.length <= limit) return <>{line}</>
  return (
    <>
      {line.slice(0, limit)}
      <span className="receipt-overflow" data-testid="receipt-overflow">
        {line.slice(limit)}
      </span>
    </>
  )
}
function Block({ block, layout }: { block: PrintBlock; layout: Layout }) {
  switch (block.kind) {
    case 'text':
      return (
        <>
          {block.lines.map((line, index) => (
            <p
              key={index}
              className={classes(
                alignClass(block.align),
                block.bold && 'receipt-bold',
                block.size !== 'm' && `receipt-size-${block.size}`,
              )}
            >
              <TextLine line={line} limit={layout.wrapAt?.(block.size) ?? null} />
            </p>
          ))}
        </>
      )
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
      )
    case 'title':
      return (
        <>
          <h2>{block.title}</h2>
          {block.number ? <p className="receipt-number">{block.number}</p> : null}
        </>
      )
    case 'divider':
      return <div className={`receipt-divider receipt-divider-${block.style}`} />
    case 'spacer':
      return <div className="receipt-spacer" style={{ height: `${block.mm}mm` }} />
    case 'qr':
      return <QrCodeBlock value={block.value} caption={block.caption} align={block.align} />
    case 'barcode':
      return <BarcodeBlock value={block.value} align={block.align} paper={layout.paper} />
    case 'signatures':
      return WIDE_PAPERS.includes(layout.paper) ? (
        <div
          className="receipt-signatures"
          style={{ gridTemplateColumns: `repeat(${block.parties.length}, minmax(0, 1fr))` }}
        >
          {block.parties.map(({ party, label }) => (
            <div key={party} className="receipt-signature">
              <strong>{label}</strong>
            </div>
          ))}
        </div>
      ) : null
  }
}
function Blocks({ blocks, layout }: { blocks: PrintBlock[]; layout: Layout }) {
  return blocks.map((block, index) => <Block key={index} block={block} layout={layout} />)
}
const numbered = (index: number | null, name: string) =>
  index === null ? name : `${index}. ${name}`
function SheetTable({ lines }: { lines: Extract<PrintLines, { layout: 'table' }> }) {
  const { headings } = lines
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
          <tr key={index}>
            {headings.index !== null ? <td className="receipt-grid-index">{row.index}</td> : null}
            <td className="receipt-grid-name">
              {row.name}
              {row.details.map((detail, position) => (
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
  )
}
function Lines({ lines, paper }: { lines: PrintLines; paper: PaperSize }) {
  if (lines.layout === 'table') {
    if (!lines.rows.length) return null
    if (WIDE_PAPERS.includes(paper)) return <SheetTable lines={lines} />
    const span = Math.max(lines.columns.length, 1)
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
          <tbody key={index}>
            <tr className="ticket-name">
              <td colSpan={span}>{numbered(row.index, row.name)}</td>
            </tr>
            {row.details.map((detail, position) => (
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
    )
  }
  if (!lines.items.length) return null
  return (
    <ol className="receipt-lines">
      {lines.items.map((line, index) => (
        <li key={index}>
          <div className="receipt-line-head">
            <span>{numbered(line.index, line.name)}</span>
            {line.amount !== null ? <span className="receipt-money">{line.amount}</span> : null}
          </div>
          {line.details.map((detail, position) => (
            <p key={position} className="receipt-line-detail">
              {detail}
            </p>
          ))}
        </li>
      ))}
    </ol>
  )
}

export function PrintSheet({
  document,
  paper,
  testId,
  markOverflow = false,
}: {
  document: PrintDocument
  paper: PaperSize
  testId: string
  markOverflow?: boolean
}) {
  const { page } = document
  const style: CSSProperties | undefined =
    page.line_spacing === 1.35 ? undefined : { lineHeight: page.line_spacing }
  const layout: Layout = {
    paper,
    wrapAt: markOverflow ? (size) => charsPerLine(paper, page.font_size, size) : null,
  }
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
            <p key={index}>{line}</p>
          ))}
        </section>
      ) : null}
      {document.notes.map((note, index) => (
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
  )
}
