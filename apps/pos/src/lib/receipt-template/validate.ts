import { MAX_BLOCKS, MAX_LABEL_LENGTH, MAX_TEXT_LENGTH, MAX_TITLE_LENGTH } from './render';
import type {
  BusinessField,
  DocumentType,
  LineColumn,
  MetaField,
  PaperSize,
  PaymentField,
  TemplateBlock,
  TemplateConfig,
  TextSize,
  TotalField,
} from './types';
import { isTemplateVariable } from './variables';

// The editor's copy of the server's template rules
// (`Spree::Pos::ReceiptTemplateSchema`), so a mistake shows while typing.
// The server stays the authority: its 422 errors carry the same JSON
// pointers and replace these when a save is refused.

export const MAX_NAME_LENGTH = 60;
export const MAX_CONFIG_BYTES = 16 * 1024;
export const MAX_ACTIVE_TEMPLATES = 5;

export type TemplateIssue = { pointer: string; code: string; message?: string };

export type SectionRules = {
  meta?: readonly MetaField[];
  lines?: readonly LineColumn[];
  totals?: readonly TotalField[];
  payments?: readonly PaymentField[];
};

const META_ALL: readonly MetaField[] = [
  'time',
  'cashier',
  'register',
  'branch',
  'order_number',
  'return_number',
  'customer',
];
const COLUMNS_ALL: readonly LineColumn[] = [
  'index',
  'name',
  'sku',
  'unit',
  'qty',
  'price',
  'discount',
  'amount',
];
const TOTALS_ALL: readonly TotalField[] = [
  'item_total',
  'discount',
  'tax',
  'included_tax',
  'total',
];
const PAYMENTS_ALL: readonly PaymentField[] = [
  'methods',
  'handed',
  'change',
  'reference',
  'paid_total',
  'debt',
  'due_on',
];

// Sections and fields each document type has data for; a section missing
// here does not exist on that document.
export const SECTION_RULES: Readonly<Record<DocumentType, SectionRules>> = {
  sale: { meta: META_ALL, lines: COLUMNS_ALL, totals: TOTALS_ALL, payments: PAYMENTS_ALL },
  prebill: {
    meta: ['time', 'register', 'branch'],
    lines: ['index', 'name', 'sku', 'unit', 'qty', 'price', 'amount'],
    totals: ['item_total', 'discount', 'total'],
    payments: ['paid_total'],
  },
  payment_ticket: {
    meta: ['time', 'cashier', 'register', 'branch', 'order_number', 'customer'],
    lines: COLUMNS_ALL,
    totals: ['item_total', 'discount', 'tax', 'total'],
    payments: ['methods', 'handed', 'change'],
  },
  return: { meta: META_ALL, lines: ['index', 'name', 'sku', 'amount'], totals: ['total'] },
  refund: { meta: META_ALL, payments: ['methods', 'reference'] },
  shift_closure: { meta: ['time', 'cashier', 'register', 'branch'] },
};

// Fields the server accepts but no printed row carries yet: the header
// already names the branch and register, so the editor does not offer them.
export const UNPRINTED_META: readonly MetaField[] = ['register', 'branch'];

// Always printed whatever the template says.
export const LOCKED_TOTALS: readonly TotalField[] = ['total'];
export const LOCKED_COLUMNS: readonly LineColumn[] = ['name'];
// Payment method rows are labelled by their method.
export const FIXED_LABELS: readonly string[] = ['methods'];

export const BLOCK_TYPES = ['logo', 'business', 'text', 'title', 'divider', 'spacer'] as const;
export type BlockType = (typeof BLOCK_TYPES)[number];
export const BUSINESS_FIELDS: readonly BusinessField[] = [
  'name',
  'branch',
  'address',
  'phone',
  'email',
  'url',
  'facebook',
  'instagram',
];

const ALIGNS: readonly string[] = ['left', 'center', 'right'];
const SIZES: readonly string[] = ['s', 'm', 'l'];
const PAPERS: readonly PaperSize[] = ['58mm', '80mm', 'a4', 'a5', 'a6'];
const VARIABLE_PATTERN = /\{([a-z_]+(?:\.[a-z_]+)?)\}/g;

const between = (value: unknown, min: number, max: number) =>
  typeof value === 'number' && Number.isFinite(value) && value >= min && value <= max;

type Add = (pointer: string, code: string) => void;

function checkBlock(block: TemplateBlock, at: string, add: Add) {
  if ('align' in block && block.align !== undefined && !ALIGNS.includes(block.align))
    add(`${at}/align`, 'invalid_value');
  switch (block.type) {
    case 'logo':
      if (block.width_pct !== undefined && !between(block.width_pct, 20, 100))
        add(`${at}/width_pct`, 'invalid_value');
      break;
    case 'business':
      if (block.fields.length === 0) add(`${at}/fields`, 'blank');
      break;
    case 'text':
      if (block.size !== undefined && !SIZES.includes(block.size))
        add(`${at}/size`, 'invalid_value');
      if (block.value.length > MAX_TEXT_LENGTH) add(`${at}/value`, 'too_long');
      else if (block.value.trim() === '') add(`${at}/value`, 'blank');
      else if (unknownVariables(block.value).length > 0) add(`${at}/value`, 'unknown_variable');
      break;
    case 'title':
      if ((block.label ?? '').length > MAX_TITLE_LENGTH) add(`${at}/label`, 'too_long');
      break;
    case 'spacer':
      if (block.mm !== undefined && !between(block.mm, 1, 10)) add(`${at}/mm`, 'invalid_value');
      break;
    case 'divider':
      break;
    default:
      add(`${at}/type`, 'unknown_block');
  }
}

function checkBlocks(blocks: TemplateBlock[], place: 'header' | 'footer', add: Add) {
  if (blocks.length > MAX_BLOCKS) add(`/config/${place}`, 'too_many');
  let titles = 0;
  blocks.forEach((block, index) => {
    const at = `/config/${place}/${index}`;
    if (block.type === 'title') titles += 1;
    if (block.type === 'title' && place === 'footer') add(at, 'misplaced');
    else if (block.type === 'title' && titles > 1) add(at, 'duplicate');
    else checkBlock(block, at, add);
  });
}

function checkFields(
  section: { fields: string[]; labels?: Partial<Record<string, string>> } | undefined,
  name: string,
  allowed: readonly string[],
  add: Add,
) {
  if (!section) return;
  section.fields.forEach((field, index) => {
    if (!allowed.includes(field)) add(`/config/${name}/fields/${index}`, 'field_unavailable');
    else if (section.fields.indexOf(field) !== index)
      add(`/config/${name}/fields/${index}`, 'duplicate');
  });
  for (const [field, label] of Object.entries(section.labels ?? {})) {
    if (label === undefined) continue;
    if (!allowed.includes(field) || FIXED_LABELS.includes(field))
      add(`/config/${name}/labels/${field}`, 'field_unavailable');
    else if (label.length > MAX_LABEL_LENGTH) add(`/config/${name}/labels/${field}`, 'too_long');
  }
}

// Variables named in a text that the POS does not know.
export function unknownVariables(text: string): string[] {
  const names = [...text.matchAll(VARIABLE_PATTERN)].map(([, name]) => name ?? '');
  return [...new Set(names.filter((name) => !isTemplateVariable(name)))];
}

// Problems of a template as the editor holds it, as server-style pointers.
export function validateTemplate(
  draft: { name: string; paper: PaperSize; config: TemplateConfig },
  documentType: DocumentType,
): TemplateIssue[] {
  const issues: TemplateIssue[] = [];
  const add: Add = (pointer, code) => {
    issues.push({ pointer, code });
  };
  const name = draft.name.trim();
  if (name === '') add('/name', 'blank');
  else if (name.length > MAX_NAME_LENGTH) add('/name', 'too_long');
  if (!PAPERS.includes(draft.paper)) add('/paper', 'invalid_value');

  const { config } = draft;
  if (!between(config.page.margin_mm, 0, 20)) add('/config/page/margin_mm', 'invalid_value');
  if (!between(config.page.line_spacing, 1, 1.6)) add('/config/page/line_spacing', 'invalid_value');
  checkBlocks(config.header, 'header', add);
  checkBlocks(config.footer, 'footer', add);

  const rules = SECTION_RULES[documentType];
  for (const section of ['meta', 'lines', 'totals', 'payments'] as const) {
    if (config[section] && !rules[section]) add(`/config/${section}`, 'section_unavailable');
  }
  if (rules.meta) checkFields(config.meta, 'meta', rules.meta, add);
  if (rules.totals) checkFields(config.totals, 'totals', rules.totals, add);
  if (rules.payments) checkFields(config.payments, 'payments', rules.payments, add);
  if (rules.lines && config.lines) {
    const allowed = rules.lines;
    config.lines.columns.forEach((column, index) => {
      if (!allowed.includes(column)) add(`/config/lines/columns/${index}`, 'field_unavailable');
    });
  }
  if (new TextEncoder().encode(JSON.stringify(config)).length > MAX_CONFIG_BYTES)
    add('/config', 'too_large');
  return issues;
}

// The problems of a refused (422) template save, in the same shape.
export function serverIssues(error: unknown): TemplateIssue[] {
  if (typeof error !== 'object' || error === null || !('details' in error)) return [];
  const details = (error as { details?: unknown }).details;
  if (typeof details !== 'object' || details === null || !('errors' in details)) return [];
  const list = (details as { errors?: unknown }).errors;
  if (!Array.isArray(list)) return [];
  return list.flatMap((entry: unknown) => {
    if (typeof entry !== 'object' || entry === null) return [];
    const { pointer, code, message } = entry as Record<string, unknown>;
    if (typeof pointer !== 'string') return [];
    return [
      {
        pointer,
        code: typeof code === 'string' ? code : 'invalid_value',
        ...(typeof message === 'string' ? { message } : {}),
      },
    ];
  });
}

export type IssueArea =
  | 'name'
  | 'paper'
  | 'page'
  | 'header'
  | 'meta'
  | 'lines'
  | 'totals'
  | 'payments'
  | 'footer'
  | 'config';

// Where in the editor a pointer lands: a field, a section or one block.
export function issueTarget(pointer: string): { area: IssueArea; index: number | null } {
  const [root, area, index] = pointer.split('/').slice(1);
  if (root === 'name' || root === 'paper') return { area: root, index: null };
  if (root !== 'config' || !area) return { area: 'config', index: null };
  if (area === 'header' || area === 'footer') {
    const position = index !== undefined && /^\d+$/.test(index) ? Number(index) : null;
    return { area, index: position };
  }
  if (
    area === 'page' ||
    area === 'meta' ||
    area === 'lines' ||
    area === 'totals' ||
    area === 'payments'
  )
    return { area, index: null };
  return { area: 'config', index: null };
}

// Roughly how many characters fit on one line of a thermal roll, so the
// editor can warn before a line wraps. Sheets are wide enough not to care.
export function charsPerLine(
  paper: PaperSize,
  pageSize: TextSize,
  textSize: TextSize = 'm',
): number | null {
  const base = paper === '58mm' ? 32 : paper === '80mm' ? 48 : null;
  if (base === null) return null;
  // Smaller type fits more characters.
  const scale = { s: 1.2, m: 1, l: 0.8 } as const;
  return Math.floor(base * scale[pageSize] * scale[textSize]);
}

// The resolved lines longer than the roll fits.
export function overlongLines(lines: string[], limit: number | null): string[] {
  return limit === null ? [] : lines.filter((line) => line.length > limit);
}

const clone = <T>(value: T): T => JSON.parse(JSON.stringify(value)) as T;

// A config in the full shape the editor works on: every section the
// document has is present (a missing one printed everything, so it starts
// with every field on), sections the document lacks are dropped, and the
// always-printed fields are listed.
export function editableConfig(config: TemplateConfig, documentType: DocumentType): TemplateConfig {
  const source = clone(config);
  const rules = SECTION_RULES[documentType];
  const blocks = (list: unknown): TemplateBlock[] =>
    Array.isArray(list)
      ? list.filter(
          (block): block is TemplateBlock =>
            typeof block === 'object' &&
            block !== null &&
            (BLOCK_TYPES as readonly string[]).includes((block as { type?: string }).type ?? ''),
        )
      : [];
  const fields = <F extends string>(
    section: { fields?: F[]; labels?: Partial<Record<F, string>> } | undefined,
    allowed: readonly F[],
    locked: readonly F[] = [],
  ) => {
    const listed = Array.isArray(section?.fields) ? section.fields : [...allowed];
    const missing = locked.filter((field) => allowed.includes(field) && !listed.includes(field));
    return { fields: [...listed, ...missing], labels: { ...(section?.labels ?? {}) } };
  };
  const result: TemplateConfig = {
    schema: 1,
    page: {
      margin_mm: source.page?.margin_mm ?? 3,
      font: source.page?.font ?? 'sans',
      font_size: source.page?.font_size ?? 'm',
      line_spacing: source.page?.line_spacing ?? 1.35,
    },
    header: blocks(source.header),
    footer: blocks(source.footer),
  };
  if (rules.meta) result.meta = fields(source.meta, rules.meta);
  if (rules.lines) {
    const lines = source.lines;
    const columns = Array.isArray(lines?.columns) ? lines.columns : [...rules.lines];
    result.lines = {
      layout: lines?.layout === 'table' ? 'table' : 'stacked',
      columns: columns.includes('name') ? columns : [...columns, 'name'],
      show_trace: lines?.show_trace ?? true,
      show_conversion: lines?.show_conversion ?? true,
    };
  }
  if (rules.totals) result.totals = fields(source.totals, rules.totals, LOCKED_TOTALS);
  if (rules.payments) result.payments = fields(source.payments, rules.payments);
  return result;
}
