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

// `monochrome` prints the logo in black and white, for thermal paper.
export type LogoBlock = { type: 'logo'; width_pct?: number; align?: Align; monochrome?: boolean };
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

// The store pages a QR code can link to, read from the store when printing.
export type SocialField = 'url' | 'facebook' | 'instagram';
export type QrBlock =
  | { type: 'qr'; source: 'url'; value: string; caption?: string; align?: Align }
  | { type: 'qr'; source: 'store_social'; field: SocialField; caption?: string; align?: Align };
// The document number as a Code 128 barcode, for the scanners at the counter.
export type BarcodeBlock = { type: 'barcode'; align?: Align };
export type SignatureParty = 'buyer' | 'seller' | 'cashier';
// Signature boxes; printed on A4 and A5 sheets only.
export type SignaturesBlock = {
  type: 'signatures';
  parties: SignatureParty[];
  labels?: Partial<Record<SignatureParty, string>>;
};

export type TemplateBlock =
  | LogoBlock
  | BusinessBlock
  | TextBlock
  | TitleBlock
  | DividerBlock
  | SpacerBlock
  | QrBlock
  | BarcodeBlock
  | SignaturesBlock;

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
  | 'due_on'
  // The pay-later VietQR of a debt; its label is the caption under the code.
  | 'pay_qr';

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
  // Sale receipts only: the original and up to two copies with one press.
  copies?: number;
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
  | {
      kind: 'image';
      src: string;
      alt: string;
      widthPct: number;
      align: Align;
      monochrome: boolean;
    }
  | { kind: 'qr'; value: string; caption: string | null; align: Align }
  | { kind: 'barcode'; value: string; align: Align }
  | { kind: 'signatures'; parties: { party: SignatureParty; label: string }[] }
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
// Headings of the ruled table a sheet prints the lines in.
export type PrintTableHeadings = { index: string | null; name: string };
export type PrintTableRow = {
  index: number | null;
  name: string;
  cells: string[];
  details: string[];
};

export type PrintLines =
  | { layout: 'stacked'; items: PrintStackedLine[] }
  | {
      layout: 'table';
      headings: PrintTableHeadings;
      columns: PrintTableColumn[];
      rows: PrintTableRow[];
    };

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
  // The bank QR for what is still owed, printed under the payments.
  payQr: PrintPayQr | null;
  notes: string[];
  footer: PrintBlock[];
  disclaimer: string | null;
};

export type PrintPayQr = { value: string; caption: string; lines: string[] };

export type PrintJobKind =
  | 'receipt'
  | 'prebill'
  | 'kitchen_ticket'
  | 'void_ticket'
  | 'cup_label'
  | 'checklist'
  | 'table_qr'
  | 'test';

// A document as the server queues it. A test page has no document type.
export type PrintJobDocument = Omit<PrintDocument, 'documentType'> & {
  version: 1;
  kind: PrintJobKind;
  documentType: DocumentType | null;
};
