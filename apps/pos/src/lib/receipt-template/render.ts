import { code128Values } from './code128';
import type { DataRow, LineData, TemplateData } from './data';
import { TEST_PRINT_BANNER } from './defaults';
import type {
  Align,
  BusinessField,
  DocumentType,
  FieldSection,
  LineColumn,
  LinesSection,
  PageSettings,
  PrintBlock,
  PrintDocument,
  PrintLines,
  PrintPayQr,
  PrintRow,
  PrintTableColumn,
  QrBlock,
  SignatureParty,
  SignaturesBlock,
  SocialField,
  TemplateBlock,
  TemplateConfig,
  TextSize,
} from './types';
import { resolveText } from './variables';

// Template × data → a resolved document of text, images and layout. The
// template decides what shows and how it is labelled; it cannot remove the
// banners (copy, pre-bill, test print), the title and number, the total or
// the e-invoice disclaimer, and it adds no figure the data does not carry.
// Configs may come from the server: anything unknown or malformed is
// skipped rather than failing the print.

export type RenderOptions = {
  // The copy banner of a recorded reprint.
  banner?: string | null;
  // A test print from the template editor: labelled as worthless.
  testPrint?: boolean;
};

export const MAX_BLOCKS = 8;
export const MAX_TEXT_LENGTH = 500;
export const MAX_TITLE_LENGTH = 60;
export const MAX_LABEL_LENGTH = 40;
export const MAX_URL_LENGTH = 300;
export const MAX_CAPTION_LENGTH = 60;
export const MAX_COPIES = 3;

export const SIGNATURE_PARTIES: readonly SignatureParty[] = ['buyer', 'seller', 'cashier'];
export const SOCIAL_FIELDS: readonly SocialField[] = ['url', 'facebook', 'instagram'];

const ALIGNS: readonly Align[] = ['left', 'center', 'right'];
const SIZES: readonly TextSize[] = ['s', 'm', 'l'];
const ALL_COLUMNS: readonly LineColumn[] = [
  'index',
  'name',
  'sku',
  'unit',
  'qty',
  'price',
  'discount',
  'amount',
];
const TABLE_COLUMNS: readonly PrintTableColumn['key'][] = ['qty', 'price', 'discount', 'amount'];

const clip = (value: string, max: number) =>
  value.length > max ? `${value.slice(0, max - 1)}…` : value;
const pick = <T extends string>(value: unknown, allowed: readonly T[], fallback: T): T =>
  typeof value === 'string' && (allowed as readonly string[]).includes(value)
    ? (value as T)
    : fallback;
const clamp = (value: unknown, min: number, max: number, fallback: number) =>
  typeof value === 'number' && Number.isFinite(value)
    ? Math.min(max, Math.max(min, value))
    : fallback;
const textOf = (value: unknown) => (typeof value === 'string' ? value.trim() : '');

function page(settings: Partial<PageSettings> | undefined): PageSettings {
  return {
    margin_mm: clamp(settings?.margin_mm, 0, 20, 3),
    font: pick(settings?.font, ['sans', 'mono'] as const, 'sans'),
    font_size: pick(settings?.font_size, SIZES, 'm'),
    line_spacing: clamp(settings?.line_spacing, 1, 1.6, 1.35),
  };
}

// How many prints one press makes: the original and its copies, on sale
// receipts only. Anything out of range prints once.
export function printCopies(config: TemplateConfig | null | undefined, type: DocumentType): number {
  const copies = config?.page?.copies;
  return type === 'sale' && Number.isInteger(copies) && copies !== undefined
    ? Math.min(MAX_COPIES, Math.max(1, copies))
    : 1;
}

// What the server's link check (Ruby's RFC 3986 parser) accepts: http(s),
// `//`, an ASCII host and an optional port, then only URI characters and
// well-formed percent escapes. Stricter is fine; looser would let the
// editor show a link as valid that the server refuses.
const PCHAR = "(?:[A-Za-z0-9\\-._~!$&'()*+,;=:@]|%[0-9A-Fa-f]{2})";
const WEB_URL = new RegExp(
  `^https?://[A-Za-z0-9\\-._~]+(?::\\d+)?(?:/(?:${PCHAR}|/)*)?(?:\\?(?:${PCHAR}|[/?])*)?(?:#(?:${PCHAR}|[/?])*)?$`,
  'i',
);

// An absolute http(s) link, the only links a QR code prints.
export function isWebUrl(value: string): boolean {
  if (value === '' || value.length > MAX_URL_LENGTH || !WEB_URL.test(value)) return false;
  try {
    const url = new URL(value);
    return (url.protocol === 'http:' || url.protocol === 'https:') && url.hostname !== '';
  } catch {
    return false;
  }
}

const SOCIAL_PAGES: Record<Exclude<SocialField, 'url'>, string> = {
  facebook: 'https://www.facebook.com/',
  instagram: 'https://www.instagram.com/',
};

// A store page as a link: stores keep their website and social pages as
// full links, bare domains or (social pages) a handle.
function storePage(field: SocialField, data: TemplateData): string | null {
  const value = data.store[field]?.trim() ?? '';
  if (value === '') return null;
  if (/^https?:\/\//i.test(value)) return value;
  if (field === 'url' || /^[\w-]+(\.[\w-]+)+(\/|$)/.test(value)) return `https://${value}`;
  return `${SOCIAL_PAGES[field]}${value.replace(/^@/, '')}`;
}

function qrLink(block: QrBlock, data: TemplateData): string | null {
  const link =
    block.source === 'url'
      ? textOf(block.value)
      : block.source === 'store_social' && SOCIAL_FIELDS.includes(block.field)
        ? storePage(block.field, data)
        : null;
  return link && isWebUrl(link) ? link : null;
}

function signatureLabels(block: SignaturesBlock, data: TemplateData) {
  const parties = Array.isArray(block.parties) ? block.parties : [];
  const labels = (block.labels ?? {}) as Partial<Record<string, unknown>>;
  return SIGNATURE_PARTIES.filter((party) => parties.includes(party)).map((party) => ({
    party,
    label: clip(textOf(labels[party]), MAX_LABEL_LENGTH) || data.signatureLabels[party],
  }));
}

export function businessLines(fields: unknown, data: TemplateData): string[] {
  if (!Array.isArray(fields)) return [];
  const values: Record<BusinessField, string | null> = {
    name: data.store.name,
    branch: data.branch.name,
    address: data.store.address,
    phone: data.store.phone,
    email: data.store.email,
    url: data.store.url,
    facebook: data.store.facebook,
    instagram: data.store.instagram,
  };
  return fields
    .filter((field): field is BusinessField => typeof field === 'string' && field in values)
    .map((field) => values[field]?.trim() ?? '')
    .filter((value) => value !== '')
    .map((value) => clip(value, MAX_TEXT_LENGTH));
}

const isImageSource = (value: string) => /^(https?:\/\/|\/)/i.test(value);

function titleBlock(label: unknown, data: TemplateData): PrintBlock {
  const custom = clip(textOf(label), MAX_TITLE_LENGTH);
  return { kind: 'title', title: custom || data.title, number: data.number };
}

function resolveBlock(block: TemplateBlock, data: TemplateData): PrintBlock | null {
  const align = pick(block && 'align' in block ? block.align : undefined, ALIGNS, 'center');
  switch (block?.type) {
    case 'logo': {
      const src = data.store.logoUrl;
      if (!src || !isImageSource(src)) return null;
      return {
        kind: 'image',
        src,
        alt: data.store.name ?? '',
        widthPct: clamp(block.width_pct, 20, 100, 60),
        align,
        monochrome: block.monochrome === true,
      };
    }
    case 'qr': {
      const value = qrLink(block, data);
      if (!value) return null;
      return {
        kind: 'qr',
        value,
        caption: clip(textOf(block.caption), MAX_CAPTION_LENGTH) || null,
        align,
      };
    }
    case 'barcode':
      // Documents without a number (pre-bill, payment ticket) have nothing to scan.
      return data.number && code128Values(data.number)
        ? { kind: 'barcode', value: data.number, align }
        : null;
    case 'signatures': {
      const parties = signatureLabels(block, data);
      return parties.length > 0 ? { kind: 'signatures', parties } : null;
    }
    case 'business': {
      const lines = businessLines(block.fields, data);
      return lines.length > 0 ? { kind: 'text', lines, align, bold: false, size: 'm' } : null;
    }
    case 'text': {
      // Each line hides on its own when all of its variables are empty.
      const lines = clip(textOf(block.value), MAX_TEXT_LENGTH)
        .split(/\r?\n/)
        .map((line) => resolveText(line, data))
        .filter((line) => !line.blank)
        .map((line) => line.text);
      if (lines.length === 0) return null;
      return {
        kind: 'text',
        lines,
        align,
        bold: block.bold === true,
        size: pick(block.size, SIZES, 'm'),
      };
    }
    case 'title':
      return titleBlock(block.label, data);
    case 'divider':
      return { kind: 'divider', style: pick(block.style, ['solid', 'dashed'] as const, 'dashed') };
    case 'spacer':
      return { kind: 'spacer', mm: clamp(block.mm, 1, 10, 2) };
    default:
      return null;
  }
}

function blocks(list: unknown, data: TemplateData, place: 'header' | 'footer'): PrintBlock[] {
  const result: PrintBlock[] = [];
  let titled = false;
  for (const block of Array.isArray(list) ? list.slice(0, MAX_BLOCKS) : []) {
    // A malformed entry is skipped, never allowed to break the print.
    if (typeof block !== 'object' || block === null) continue;
    if (block.type === 'title') {
      // One title, in the header only.
      if (place === 'footer' || titled) continue;
      titled = true;
    }
    const resolved = resolveBlock(block as TemplateBlock, data);
    if (resolved) result.push(resolved);
  }
  if (place === 'header' && !titled) result.push(titleBlock(undefined, data));
  return result;
}

// Rows whose field the template switched off are dropped; rows without a
// field and the `locked` fields always print.
function fieldRows<F extends string>(
  rows: DataRow<F>[],
  section: FieldSection<F> | undefined,
  locked: readonly F[] = [],
  fixedLabels: readonly F[] = [],
): PrintRow[] {
  const enabled = Array.isArray(section?.fields) ? new Set<string>(section.fields) : null;
  const labels = (section?.labels ?? {}) as Partial<Record<string, unknown>>;
  return rows
    .filter(
      (row) =>
        row.field === null ||
        enabled === null ||
        enabled.has(row.field) ||
        locked.includes(row.field),
    )
    .map((row) => {
      const custom =
        row.field !== null && !fixedLabels.includes(row.field)
          ? clip(textOf(labels[row.field]), MAX_LABEL_LENGTH)
          : '';
      const label = `${custom || row.label}${row.labelSuffix ?? ''}`;
      return row.strong ? { label, value: row.value, strong: true } : { label, value: row.value };
    });
}

function lineName(line: LineData, columns: Set<LineColumn>) {
  return columns.has('sku') && line.sku ? `${line.name} (${line.sku})` : line.name;
}

function quantityText(line: LineData, columns: Set<LineColumn>) {
  return `${line.quantity ?? ''}${columns.has('unit') && line.unit ? ` ${line.unit}` : ''}`;
}

function lineDetails(line: LineData, columns: Set<LineColumn>, section: LinesSection | undefined) {
  const details: string[] = [];
  if (line.price !== null) {
    const parts = [
      columns.has('qty') ? quantityText(line, columns) : '',
      columns.has('price') ? line.price : '',
    ].filter(Boolean);
    if (parts.length > 0) details.push(parts.join(' × '));
  }
  if (section?.show_conversion !== false && line.conversion) details.push(line.conversion);
  if (columns.has('discount') && line.discountNote) details.push(line.discountNote);
  if (section?.show_trace !== false) details.push(...line.trace);
  details.push(...line.notes);
  return details;
}

function lines(data: TemplateData, section: LinesSection | undefined): PrintLines {
  const columns = new Set<LineColumn>(
    Array.isArray(section?.columns)
      ? section.columns.filter((column) => ALL_COLUMNS.includes(column))
      : ALL_COLUMNS,
  );
  const index = (position: number) => (columns.has('index') ? position + 1 : null);
  if (section?.layout === 'table') {
    const keys = TABLE_COLUMNS.filter((key) => columns.has(key));
    const cell = (line: LineData, key: PrintTableColumn['key']) =>
      key === 'qty'
        ? quantityText(line, columns)
        : key === 'price'
          ? line.priceCell
          : key === 'discount'
            ? line.discountCell
            : line.amountCell;
    return {
      layout: 'table',
      headings: {
        index: columns.has('index') ? data.lineLabels.index : null,
        name: data.lineLabels.name,
      },
      columns: keys.map((key) => ({ key, label: data.lineLabels[key] })),
      rows: data.lines.map((line, position) => ({
        index: index(position),
        name: lineName(line, columns),
        cells: keys.map((key) => cell(line, key)),
        details: [
          ...(section.show_conversion && line.conversion ? [line.conversion] : []),
          ...(section.show_trace ? line.trace : []),
          ...line.notes,
        ],
      })),
    };
  }
  return {
    layout: 'stacked',
    items: data.lines.map((line, position) => ({
      index: index(position),
      name: lineName(line, columns),
      amount: columns.has('amount') ? line.amount : null,
      details: lineDetails(line, columns, section),
    })),
  };
}

// The pay-later QR prints while the template has `pay_qr` on (a template
// without a payments section prints everything); its label is the caption.
function payQr(data: TemplateData, section: TemplateConfig['payments']): PrintPayQr | null {
  const qr = data.payQr;
  if (!qr) return null;
  if (Array.isArray(section?.fields) && !section.fields.includes('pay_qr')) return null;
  const labels = (section?.labels ?? {}) as Partial<Record<string, unknown>>;
  const caption = clip(textOf(labels.pay_qr), MAX_LABEL_LENGTH) || qr.caption;
  return { value: qr.value, caption, lines: qr.lines };
}

export function renderDocument(
  config: TemplateConfig,
  data: TemplateData,
  options: RenderOptions = {},
): PrintDocument {
  const banners = [
    data.banner,
    options.banner ?? null,
    options.testPrint ? TEST_PRINT_BANNER : null,
  ]
    .map((banner) => banner?.trim() ?? '')
    .filter((banner) => banner !== '');
  return {
    documentType: data.documentType,
    page: page(config?.page),
    banners,
    header: blocks(config?.header, data, 'header'),
    meta: fieldRows(data.meta, config?.meta),
    lines: lines(data, config?.lines),
    totals: fieldRows(data.totals, config?.totals, ['total']),
    // Each payment method row is labelled by its method.
    payments: fieldRows(data.payments, config?.payments, [], ['methods']),
    payQr: payQr(data, config?.payments),
    notes: data.notes,
    footer: blocks(config?.footer, data, 'footer'),
    disclaimer: data.disclaimer,
  };
}
