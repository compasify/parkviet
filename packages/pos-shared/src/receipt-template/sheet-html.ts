import { encode } from 'uqr';
import { barcodeWidthMm, code128Bars, QUIET_ZONE } from './code128';
import type {
  Align,
  PaperSize,
  PrintBlock,
  PrintDocument,
  PrintLines,
  PrintRow,
  SignatureParty,
  TextSize,
} from './types';
import { charsPerLine, PRINTABLE_WIDTH_MM, WIDE_PAPERS } from './validate';

// The one renderer of a printed sheet: the POS prints this markup and the
// administration preview shows it in a frame, so both are the same by
// construction. Pure string output (no DOM); every text and attribute value
// is escaped, since templates carry text the store typed in.

export const DEFAULT_LINE_SPACING = 1.35;

// How the sheet is laid out: the paper decides sheet-only blocks and the
// line table; `markOverflow` (editor preview only) underlines the part of a
// header or footer text line past the estimated roll width. Prints never do.
export type SheetLayout = { paper: PaperSize; markOverflow?: boolean };

// The attributes of the sheet element itself.
export type SheetElement = SheetLayout & { testId: string; printId?: string | null };

const ESCAPES: Record<string, string> = {
  '&': '&amp;',
  '<': '&lt;',
  '>': '&gt;',
  '"': '&quot;',
  "'": '&#x27;',
};

// Safe in text content and in double-quoted attribute values alike.
export function escapeHtml(value: string | number): string {
  return String(value).replace(/[&<>"']/g, (char) => ESCAPES[char] ?? char);
}

type Attribute = string | number | null | undefined | false;

// ` name="value"` for every set attribute, in the order given.
function attrs(list: [string, Attribute][]): string {
  return list
    .filter((entry): entry is [string, string | number] => {
      const value = entry[1];
      return value !== null && value !== undefined && value !== false;
    })
    .map(([name, value]) => ` ${name}="${escapeHtml(value)}"`)
    .join('');
}

const el = (tag: string, list: [string, Attribute][], inner: string) =>
  `<${tag}${attrs(list)}>${inner}</${tag}>`;

const classes = (...names: (string | false | null | undefined)[]) =>
  names.filter(Boolean).join(' ') || null;

const alignClass = (align: string) => (align === 'center' ? null : `receipt-align-${align}`);

// The dark modules of a QR code as one SVG path, a row run at a time.
export function qrPath(value: string): { size: number; path: string } | null {
  try {
    const { size, data } = encode(value, { ecc: 'M', border: 4 });
    const parts: string[] = [];
    data.forEach((row, y) => {
      let x = 0;
      while (x < size) {
        if (!row[x]) {
          x += 1;
          continue;
        }
        const start = x;
        while (x < size && row[x]) x += 1;
        parts.push(`M${start} ${y}h${x - start}v1h${start - x}z`);
      }
    });
    return { size, path: parts.join('') };
  } catch {
    // Too long to encode: the block is left off rather than break the print.
    return null;
  }
}

// A printed QR code, generated here: nothing is sent to a QR service.
function qrHtml(value: string, caption: string | null, align: Align): string {
  const code = qrPath(value);
  if (!code) return '';
  const svg = el(
    'svg',
    [
      ['viewBox', `0 0 ${code.size} ${code.size}`],
      ['shape-rendering', 'crispEdges'],
      ['role', 'img'],
      ['aria-label', caption ?? value],
    ],
    `<path${attrs([
      ['d', code.path],
      ['fill', '#000'],
    ])}></path>`,
  );
  return el(
    'figure',
    [
      ['class', `receipt-qr receipt-code-${align}`],
      ['data-qr-value', value],
    ],
    svg + (caption ? el('figcaption', [], escapeHtml(caption)) : ''),
  );
}

// The document number as a Code 128 barcode with the number printed under
// it. Left off when the paper is too narrow for bars a scanner can read.
function barcodeHtml(value: string, align: Align, paper: PaperSize): string {
  const code = code128Bars(value);
  const widthMm = barcodeWidthMm(value, PRINTABLE_WIDTH_MM[paper]);
  if (!code || widthMm === null) return '';
  const width = code.modules + QUIET_ZONE * 2;
  const bars = code.bars
    .map(
      (bar) =>
        `<rect${attrs([
          ['x', bar.x + QUIET_ZONE],
          ['y', 0],
          ['width', bar.width],
          ['height', 30],
          ['fill', '#000'],
        ])}></rect>`,
    )
    .join('');
  const svg = el(
    'svg',
    [
      ['viewBox', `0 0 ${width} 30`],
      ['preserveAspectRatio', 'none'],
      ['shape-rendering', 'crispEdges'],
      ['style', `width:${widthMm.toFixed(1)}mm`],
      ['role', 'img'],
      ['aria-label', value],
    ],
    bars,
  );
  return el(
    'figure',
    [
      ['class', `receipt-barcode receipt-code-${align}`],
      ['data-barcode-value', value],
    ],
    svg + el('figcaption', [], escapeHtml(value)),
  );
}

// Signature boxes side by side, each with room to sign under its label.
function signaturesHtml(parties: { party: SignatureParty; label: string }[]): string {
  return el(
    'div',
    [
      ['class', 'receipt-signatures'],
      ['style', `grid-template-columns:repeat(${parties.length}, minmax(0, 1fr))`],
    ],
    parties
      .map(({ label }) =>
        el('div', [['class', 'receipt-signature']], el('strong', [], escapeHtml(label))),
      )
      .join(''),
  );
}

// A text line with the part past the line width underlined.
function textLineHtml(line: string, limit: number | null): string {
  if (limit === null || line.length <= limit) return escapeHtml(line);
  return (
    escapeHtml(line.slice(0, limit)) +
    el(
      'span',
      [
        ['class', 'receipt-overflow'],
        ['data-testid', 'receipt-overflow'],
      ],
      escapeHtml(line.slice(limit)),
    )
  );
}

function blockHtml(block: PrintBlock, layout: SheetLayout, fontSize: TextSize): string {
  switch (block.kind) {
    case 'text': {
      const className = classes(
        alignClass(block.align),
        block.bold && 'receipt-bold',
        block.size !== 'm' && `receipt-size-${block.size}`,
      );
      const limit = layout.markOverflow ? charsPerLine(layout.paper, fontSize, block.size) : null;
      return block.lines
        .map((line) => el('p', [['class', className]], textLineHtml(line, limit)))
        .join('');
    }
    case 'image':
      return el(
        'p',
        [
          [
            'class',
            classes(
              'receipt-logo',
              alignClass(block.align),
              block.monochrome && 'receipt-logo-mono',
            ),
          ],
        ],
        `<img${attrs([
          ['src', block.src],
          ['alt', block.alt],
          ['style', `width:${block.widthPct}%`],
        ])}/>`,
      );
    case 'title':
      return (
        el('h2', [], escapeHtml(block.title)) +
        (block.number ? el('p', [['class', 'receipt-number']], escapeHtml(block.number)) : '')
      );
    case 'divider':
      return el('div', [['class', `receipt-divider receipt-divider-${block.style}`]], '');
    case 'spacer':
      return el(
        'div',
        [
          ['class', 'receipt-spacer'],
          ['style', `height:${block.mm}mm`],
        ],
        '',
      );
    case 'qr':
      return qrHtml(block.value, block.caption, block.align);
    case 'barcode':
      return barcodeHtml(block.value, block.align, layout.paper);
    case 'signatures':
      return WIDE_PAPERS.includes(layout.paper) ? signaturesHtml(block.parties) : '';
  }
}

function rowsHtml(rows: PrintRow[], className: string): string {
  if (rows.length === 0) return '';
  return el(
    'dl',
    [['class', className]],
    rows
      .map((row) =>
        el(
          'div',
          [['class', row.strong ? 'receipt-strong' : null]],
          el('dt', [], escapeHtml(row.label)) + el('dd', [], escapeHtml(row.value)),
        ),
      )
      .join(''),
  );
}

const numbered = (index: number | null, name: string) =>
  index === null ? name : `${index}. ${name}`;

const th = (label: string, className: string | null = null) =>
  el(
    'th',
    [
      ['scope', 'col'],
      ['class', className],
    ],
    escapeHtml(label),
  );

const cellsHtml = (cells: string[]) => cells.map((cell) => el('td', [], escapeHtml(cell))).join('');

// The lines of a table template on an A4 or A5 sheet: one ruled row per
// line, the line number and every column in its own cell.
function sheetTableHtml(lines: Extract<PrintLines, { layout: 'table' }>): string {
  const { headings } = lines;
  const hasIndex = headings.index !== null;
  const head = el(
    'tr',
    [],
    (headings.index !== null ? th(headings.index, 'receipt-grid-index') : '') +
      th(headings.name, 'receipt-grid-name') +
      lines.columns.map((column) => th(column.label)).join(''),
  );
  const body = lines.rows
    .map((row) =>
      el(
        'tr',
        [],
        (hasIndex ? el('td', [['class', 'receipt-grid-index']], escapeHtml(row.index ?? '')) : '') +
          el(
            'td',
            [['class', 'receipt-grid-name']],
            escapeHtml(row.name) +
              row.details.map((detail) => el('small', [], escapeHtml(detail))).join(''),
          ) +
          cellsHtml(row.cells),
      ),
    )
    .join('');
  return el('table', [['class', 'receipt-grid']], el('thead', [], head) + el('tbody', [], body));
}

function linesHtml(lines: PrintLines, paper: PaperSize): string {
  if (lines.layout === 'table') {
    if (lines.rows.length === 0) return '';
    if (WIDE_PAPERS.includes(paper)) return sheetTableHtml(lines);
    const span = Math.max(lines.columns.length, 1);
    const hasColumns = lines.columns.length > 0;
    const head = hasColumns
      ? el('thead', [], el('tr', [], lines.columns.map((column) => th(column.label)).join('')))
      : '';
    const fullRow = (className: string, text: string) =>
      el('tr', [['class', className]], el('td', [['colspan', span]], escapeHtml(text)));
    const bodies = lines.rows
      .map((row) =>
        el(
          'tbody',
          [],
          fullRow('ticket-name', numbered(row.index, row.name)) +
            row.details.map((detail) => fullRow('ticket-detail', detail)).join('') +
            (hasColumns ? el('tr', [['class', 'ticket-figures']], cellsHtml(row.cells)) : ''),
        ),
      )
      .join('');
    return el('table', [['class', 'ticket-table']], head + bodies);
  }
  if (lines.items.length === 0) return '';
  return el(
    'ol',
    [['class', 'receipt-lines']],
    lines.items
      .map((line) =>
        el(
          'li',
          [],
          el(
            'div',
            [['class', 'receipt-line-head']],
            el('span', [], escapeHtml(numbered(line.index, line.name))) +
              (line.amount !== null
                ? el('span', [['class', 'receipt-money']], escapeHtml(line.amount))
                : ''),
          ) +
            line.details
              .map((detail) => el('p', [['class', 'receipt-line-detail']], escapeHtml(detail)))
              .join(''),
        ),
      )
      .join(''),
  );
}

// The class list of the sheet element: paper, document kind, font and scale.
export function sheetClassName(document: PrintDocument, paper: PaperSize): string {
  const { page } = document;
  return [
    'receipt-sheet',
    document.documentType === 'payment_ticket' && 'invoice-ticket',
    `receipt-${paper}`,
    page.font === 'mono' && 'receipt-font-mono',
    page.font_size !== 'm' && `receipt-scale-${page.font_size}`,
  ]
    .filter(Boolean)
    .join(' ');
}

// The line height the sheet sets inline; null keeps the stylesheet's own.
export function sheetLineHeight(document: PrintDocument): number | null {
  const spacing = document.page.line_spacing;
  return spacing === DEFAULT_LINE_SPACING ? null : spacing;
}

// The inside of the sheet element: banners, header, rows, lines, pay QR,
// notes, footer and disclaimer.
export function renderSheetContentHtml(document: PrintDocument, layout: SheetLayout): string {
  const fontSize = document.page.font_size;
  const blocks = (list: PrintBlock[]) =>
    list.map((block) => blockHtml(block, layout, fontSize)).join('');
  const { payQr } = document;
  return [
    document.banners.map((banner) => el('p', [['class', 'receipt-banner']], escapeHtml(banner))),
    el('header', [['class', 'receipt-header']], blocks(document.header)),
    rowsHtml(document.meta, 'receipt-meta'),
    linesHtml(document.lines, layout.paper),
    rowsHtml(document.totals, 'receipt-totals'),
    rowsHtml(document.payments, 'receipt-payments'),
    payQr
      ? el(
          'section',
          [
            ['class', 'receipt-pay-qr'],
            ['data-testid', 'receipt-pay-qr'],
          ],
          qrHtml(payQr.value, payQr.caption, 'center') +
            payQr.lines.map((line) => el('p', [], escapeHtml(line))).join(''),
        )
      : '',
    document.notes.map((note) => el('p', [['class', 'receipt-note']], escapeHtml(note))),
    document.footer.length > 0
      ? el('footer', [['class', 'receipt-footer']], blocks(document.footer))
      : '',
    document.disclaimer
      ? el('p', [['class', 'receipt-disclaimer']], escapeHtml(document.disclaimer))
      : '',
  ]
    .flat()
    .join('');
}

// The whole sheet element, ready to place in a print root or a frame.
export function renderSheetHtml(document: PrintDocument, sheet: SheetElement): string {
  const lineHeight = sheetLineHeight(document);
  return el(
    'article',
    [
      ['class', sheetClassName(document, sheet.paper)],
      ['style', lineHeight === null ? null : `line-height:${lineHeight}`],
      ['data-testid', sheet.testId],
      ['data-paper', sheet.paper],
      ['data-print-id', sheet.printId],
    ],
    renderSheetContentHtml(document, sheet),
  );
}
