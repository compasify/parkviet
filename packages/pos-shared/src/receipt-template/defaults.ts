import type { DocumentType, PageSettings, TemplateBlock, TemplateConfig } from './types';

// The built-in template of every document type. They lay the documents out
// exactly as the POS printed them before templates existed, plus the store
// address and phone when the store has them. The server keeps the same
// configs as its defaults; this copy prints when templates cannot be
// loaded. Plain JSON-compatible data only.

export const TEST_PRINT_BANNER = 'IN THỬ — KHÔNG CÓ GIÁ TRỊ';

const PAGE: PageSettings = { margin_mm: 3, font: 'sans', font_size: 'm', line_spacing: 1.35 };

const HEADER: TemplateBlock[] = [
  { type: 'business', fields: ['name', 'address', 'phone', 'branch'], align: 'center' },
  { type: 'text', value: '{register.name}', align: 'center' },
  { type: 'title' },
];

const POSTED_META = {
  fields: ['time', 'cashier', 'order_number', 'return_number', 'customer'],
  labels: {},
} satisfies TemplateConfig['meta'];

export const DEFAULT_TEMPLATES: Readonly<Record<DocumentType, TemplateConfig>> = {
  sale: {
    schema: 1,
    page: PAGE,
    header: HEADER,
    meta: POSTED_META,
    lines: {
      layout: 'stacked',
      columns: ['name', 'sku', 'unit', 'qty', 'price', 'discount', 'amount'],
      show_trace: true,
      show_conversion: true,
    },
    totals: { fields: ['item_total', 'discount', 'tax', 'included_tax', 'total'], labels: {} },
    payments: {
      fields: [
        'methods',
        'handed',
        'change',
        'reference',
        'paid_total',
        'debt',
        'due_on',
        'pay_qr',
      ],
      labels: {},
    },
    footer: [],
  },
  prebill: {
    schema: 1,
    page: PAGE,
    header: HEADER,
    meta: { fields: ['time', 'customer'], labels: {} },
    lines: {
      layout: 'stacked',
      columns: ['name', 'unit', 'qty', 'price', 'amount'],
      show_trace: true,
      show_conversion: false,
    },
    totals: { fields: ['item_total', 'discount', 'total'], labels: {} },
    payments: { fields: ['paid_total'], labels: {} },
    footer: [],
  },
  payment_ticket: {
    schema: 1,
    page: PAGE,
    header: HEADER,
    meta: { fields: ['time', 'order_number', 'cashier', 'customer'], labels: {} },
    lines: {
      layout: 'table',
      columns: ['index', 'name', 'unit', 'qty', 'price', 'discount', 'amount'],
      show_trace: false,
      show_conversion: false,
    },
    totals: { fields: ['item_total', 'discount', 'tax', 'total'], labels: {} },
    payments: { fields: ['methods', 'handed', 'change'], labels: {} },
    footer: [
      { type: 'divider', style: 'dashed' },
      { type: 'text', value: 'Cảm ơn quý khách!', align: 'center', size: 's' },
    ],
  },
  return: {
    schema: 1,
    page: PAGE,
    header: HEADER,
    meta: POSTED_META,
    lines: {
      layout: 'stacked',
      columns: ['name', 'amount'],
      show_trace: false,
      show_conversion: false,
    },
    totals: { fields: ['total'], labels: {} },
    footer: [],
  },
  refund: {
    schema: 1,
    page: PAGE,
    header: HEADER,
    meta: POSTED_META,
    payments: { fields: ['methods', 'reference'], labels: {} },
    footer: [],
  },
  shift_closure: {
    schema: 1,
    page: PAGE,
    header: HEADER,
    meta: { fields: ['time', 'cashier'], labels: {} },
    footer: [],
  },
};

export function defaultTemplate(type: DocumentType): TemplateConfig {
  return DEFAULT_TEMPLATES[type];
}
