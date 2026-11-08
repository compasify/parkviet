// A print template describes how a document is laid out, never what it
// says: amounts, lines and names come from the receipt snapshot or the
// open order as the server reported them. The header and footer are
// ordered blocks; information, lines, totals and payments are fixed
// sections whose fields can only be switched off or relabelled.

export type PaperSize = '58mm' | '80mm' | 'a4' | 'a5' | 'a6';

export type DocumentType =
  | 'sale'
  | 'prebill'
  | 'payment_ticket'
  | 'return'
  | 'refund'
  | 'shift_closure';

export const DOCUMENT_TYPES: readonly DocumentType[] = [
  'sale',
  'prebill',
  'payment_ticket',
  'return',
  'refund',
  'shift_closure',
];

export type Align = 'left' | 'center' | 'right';
export type TextSize = 's' | 'm' | 'l';

export type BusinessField =
  | 'name'
  | 'branch'
  | 'address'
  | 'phone'
  | 'email'
  | 'url'
  | 'facebook'
  | 'instagram';

export type LogoBlock = { type: 'logo'; width_pct?: number; align?: Align };
export type BusinessBlock = { type: 'business'; fields: BusinessField[]; align?: Align };
export type TextBlock = {
  type: 'text';
  value: string;
  align?: Align;
  bold?: boolean;
  size?: TextSize;
};
// The document title and number. Always printed: a template without one
// gets it appended to its header.
export type TitleBlock = { type: 'title'; label?: string };
export type DividerBlock = { type: 'divider'; style?: 'solid' | 'dashed' };
export type SpacerBlock = { type: 'spacer'; mm?: number };

export type TemplateBlock =
  | LogoBlock
  | BusinessBlock
  | TextBlock
  | TitleBlock
  | DividerBlock
  | SpacerBlock;

export type MetaField =
  | 'time'
  | 'cashier'
  | 'register'
  | 'branch'
  | 'order_number'
  | 'return_number'
  | 'customer';

export type LineColumn =
  | 'index'
  | 'name'
  | 'sku'
  | 'unit'
  | 'qty'
  | 'price'
  | 'discount'
  | 'amount';

export type TotalField = 'item_total' | 'discount' | 'tax' | 'included_tax' | 'total';

export type PaymentField =
  | 'methods'
  | 'handed'
  | 'change'
  | 'reference'
  | 'paid_total'
  | 'debt'
  | 'due_on';

export type FieldSection<F extends string> = {
  fields: F[];
  labels?: Partial<Record<F, string>>;
};

export type LinesSection = {
  layout: 'stacked' | 'table';
  columns: LineColumn[];
  show_trace: boolean;
  show_conversion: boolean;
};

export type PageSettings = {
  // Carried with the template; the print page margin does not use it yet.
  margin_mm: number;
  font: 'sans' | 'mono';
  font_size: TextSize;
  line_spacing: number;
};

// Schema 1. A section a document type has no data for (lines of a shift
// closure) is left out; a missing section prints everything it has.
export type TemplateConfig = {
  schema: 1;
  page: PageSettings;
  header: TemplateBlock[];
  meta?: FieldSection<MetaField>;
  lines?: LinesSection;
  totals?: FieldSection<TotalField>;
  payments?: FieldSection<PaymentField>;
  footer: TemplateBlock[];
};

// ---- The resolved document: text, images and layout only. ----

export type PrintRow = { label: string; value: string; strong?: boolean };

export type PrintBlock =
  | { kind: 'text'; lines: string[]; align: Align; bold: boolean; size: TextSize }
  | { kind: 'image'; src: string; alt: string; widthPct: number; align: Align }
  | { kind: 'title'; title: string; number: string | null }
  | { kind: 'divider'; style: 'solid' | 'dashed' }
  | { kind: 'spacer'; mm: number };

export type PrintStackedLine = {
  index: number | null;
  name: string;
  amount: string | null;
  details: string[];
};

export type PrintTableColumn = { key: 'qty' | 'price' | 'discount' | 'amount'; label: string };
export type PrintTableRow = {
  index: number | null;
  name: string;
  cells: string[];
  details: string[];
};

export type PrintLines =
  | { layout: 'stacked'; items: PrintStackedLine[] }
  | { layout: 'table'; columns: PrintTableColumn[]; rows: PrintTableRow[] };

export type PrintDocument = {
  documentType: DocumentType;
  page: PageSettings;
  // "BẢN SAO", "TẠM TÍNH – CHƯA THANH TOÁN", test print: never removable.
  banners: string[];
  header: PrintBlock[];
  meta: PrintRow[];
  lines: PrintLines;
  totals: PrintRow[];
  payments: PrintRow[];
  notes: string[];
  footer: PrintBlock[];
  disclaimer: string | null;
};
