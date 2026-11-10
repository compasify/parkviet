import { DEFAULT_TEMPLATES } from './defaults';
import { renderDocument } from './render';
import { sampleData } from './sample-data';
import { DOCUMENT_TYPES, type PaperSize, type PrintDocument, type TemplateConfig } from './types';

// Documents the sheet renderer is checked against: the sample of every
// document type plus hand-made documents that use every block kind, both
// line layouts and text that must be escaped. Inputs only; the expected
// markup lives in sheet-html.golden.json.

export type SheetCase = {
  name: string;
  document: PrintDocument;
  paper: PaperSize;
  markOverflow: boolean;
  testId: string;
  printId: string | null;
};

// Keys instead of translations, so locale edits leave the cases alone.
const t = (key: string, options?: Record<string, unknown>) =>
  options ? `${key} ${JSON.stringify(options)}` : key;

const NOW = new Date('2026-11-07T03:00:00Z');

const PLACE = {
  storeName: 'Park <Việt> & "Co"',
  branchName: 'Quận 1',
  branchCode: 'q1',
  registerName: 'Quầy 1',
  returnWindowDays: 7,
  cashier: 'Lan',
  timeZone: 'Asia/Ho_Chi_Minh',
  storeProfile: {
    address: '12 Lê Lợi, Quận 1',
    contact_phone: '0901 234 567',
    customer_support_email: 'shop@example.com',
    url: 'https://example.com',
    facebook: null,
    instagram: null,
    logo_url: 'https://cdn.example.com/logo.png?a=1&b=2',
  },
};

// Every table template laid out as a table, so the line table is covered.
const asTable = (config: TemplateConfig): TemplateConfig =>
  config.lines ? { ...config, lines: { ...config.lines, layout: 'table' } } : config;

const HOSTILE = `<script>alert('x')</script> & "quoted"`;

const BLOCKS_DOCUMENT: PrintDocument = {
  documentType: 'sale',
  page: { margin_mm: 3, font: 'mono', font_size: 's', line_spacing: 1.6 },
  banners: ['BẢN SAO', HOSTILE],
  header: [
    {
      kind: 'image',
      src: 'https://cdn.example.com/logo.png?a=1&b="2"',
      alt: HOSTILE,
      widthPct: 45,
      align: 'left',
      monochrome: true,
    },
    {
      kind: 'image',
      src: '/logo.png',
      alt: '',
      widthPct: 60,
      align: 'center',
      monochrome: false,
    },
    { kind: 'title', title: 'PHIẾU <BÁN> HÀNG', number: 'R&100' },
    { kind: 'title', title: 'No number', number: null },
    {
      kind: 'text',
      lines: [
        'Short',
        'A line long enough to run past the width of a narrow thermal roll <b>&</b>',
        '',
      ],
      align: 'right',
      bold: true,
      size: 'l',
    },
    { kind: 'text', lines: [HOSTILE], align: 'center', bold: false, size: 'm' },
    { kind: 'divider', style: 'dashed' },
    { kind: 'divider', style: 'solid' },
    { kind: 'spacer', mm: 4 },
    { kind: 'qr', value: 'https://example.com/r?id=1&x="2"', caption: HOSTILE, align: 'right' },
    { kind: 'qr', value: 'https://example.com', caption: null, align: 'center' },
    { kind: 'qr', value: 'x'.repeat(5000), caption: 'too long', align: 'center' },
    { kind: 'barcode', value: 'R100', align: 'left' },
    { kind: 'barcode', value: 'Không mã', align: 'center' },
    {
      kind: 'signatures',
      parties: [
        { party: 'buyer', label: 'Người <mua>' },
        { party: 'seller', label: 'Người bán & "ký"' },
      ],
    },
  ],
  meta: [
    { label: 'Thu ngân', value: 'Lan & <Mai>' },
    { label: 'Tổng', value: '1', strong: true },
  ],
  lines: {
    layout: 'stacked',
    items: [
      { index: 1, name: 'Bia <lon>', amount: '240.000', details: ['24 × 10.000', 'Lô "L01"'] },
      { index: null, name: 'Không số', amount: null, details: [] },
    ],
  },
  totals: [{ label: 'Tổng cộng', value: '230.000', strong: true }],
  payments: [],
  payQr: {
    value: '00020101021238570010A000000727',
    caption: 'Quét để <trả>',
    lines: ['Nội dung CK: TNR250', HOSTILE],
  },
  notes: ['Ghi chú & <note>', "It's"],
  footer: [
    { kind: 'text', lines: ['Cảm ơn quý khách'], align: 'center', bold: false, size: 's' },
    { kind: 'signatures', parties: [{ party: 'cashier', label: 'Thu ngân' }] },
  ],
  disclaimer: 'Không phải <hóa đơn> điện tử',
};

const TABLE_DOCUMENT: PrintDocument = {
  ...BLOCKS_DOCUMENT,
  documentType: 'payment_ticket',
  page: { margin_mm: 3, font: 'sans', font_size: 'l', line_spacing: 1.35 },
  header: [{ kind: 'title', title: 'HÓA ĐƠN', number: null }],
  payQr: null,
  footer: [],
  disclaimer: null,
  lines: {
    layout: 'table',
    headings: { index: 'STT', name: 'Tên <hàng>' },
    columns: [
      { key: 'qty', label: 'SL' },
      { key: 'price', label: 'Đơn giá' },
      { key: 'amount', label: 'Thành tiền' },
    ],
    rows: [
      { index: 1, name: 'Bia & nước', cells: ['2', '10.000', '20.000'], details: ['Lô <A>'] },
      { index: 2, name: 'Đá', cells: ['1', '0', '0'], details: [] },
    ],
  },
};

const TABLE_WITHOUT_COLUMNS: PrintDocument = {
  ...TABLE_DOCUMENT,
  lines: {
    layout: 'table',
    headings: { index: null, name: 'Tên' },
    columns: [],
    rows: [{ index: null, name: 'Bia', cells: [], details: ['24 lon'] }],
  },
};

const EMPTY_DOCUMENT: PrintDocument = {
  ...TABLE_DOCUMENT,
  banners: [],
  header: [],
  meta: [],
  totals: [],
  notes: [],
  lines: { layout: 'table', headings: { index: null, name: 'Tên' }, columns: [], rows: [] },
};

const EMPTY_STACKED: PrintDocument = {
  ...EMPTY_DOCUMENT,
  lines: { layout: 'stacked', items: [] },
};

function sampleCases(): SheetCase[] {
  return DOCUMENT_TYPES.flatMap((type) => {
    const data = sampleData(type, PLACE, t, NOW);
    const stacked = renderDocument(DEFAULT_TEMPLATES[type], data);
    const table = renderDocument(asTable(DEFAULT_TEMPLATES[type]), data);
    return [
      { name: `${type} 80mm`, document: stacked, paper: '80mm', markOverflow: false },
      { name: `${type} 58mm overflow`, document: stacked, paper: '58mm', markOverflow: true },
      { name: `${type} table 80mm`, document: table, paper: '80mm', markOverflow: false },
      { name: `${type} table a4`, document: table, paper: 'a4', markOverflow: false },
    ].map((item) => ({
      ...(item as Omit<SheetCase, 'testId' | 'printId'>),
      testId: 'receipt-print-sheet',
      printId: null,
    }));
  });
}

export function sheetCases(): SheetCase[] {
  const made = (
    name: string,
    document: PrintDocument,
    paper: PaperSize,
    markOverflow: boolean,
    printId: string | null = null,
  ): SheetCase => ({ name, document, paper, markOverflow, testId: 'sheet', printId });
  return [
    ...sampleCases(),
    made('blocks 58mm overflow', BLOCKS_DOCUMENT, '58mm', true, 'print_<1>&"2"'),
    made('blocks 80mm', BLOCKS_DOCUMENT, '80mm', false),
    made('blocks a4', BLOCKS_DOCUMENT, 'a4', true),
    made('blocks a5', BLOCKS_DOCUMENT, 'a5', false),
    made('blocks a6', BLOCKS_DOCUMENT, 'a6', false),
    made('table 80mm', TABLE_DOCUMENT, '80mm', false),
    made('table a5', TABLE_DOCUMENT, 'a5', false, 'print_1'),
    made('table without columns 58mm', TABLE_WITHOUT_COLUMNS, '58mm', false),
    made('table without columns a4', TABLE_WITHOUT_COLUMNS, 'a4', false),
    made('empty table a4', EMPTY_DOCUMENT, 'a4', false),
    made('empty stacked 80mm', EMPTY_STACKED, '80mm', false),
  ];
}
