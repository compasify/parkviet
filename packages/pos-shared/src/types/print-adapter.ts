import type { PrintLayout } from '../receipt-template/selection';

// The persisted receipt and print records; no browser printing implementation.
export type ReceiptSnapshot = {
  id: string;
  source_type: 'sale' | 'return' | 'refund' | 'shift_closure';
  number: string;
  branch_id: string;
  register_id?: string | null;
  issued_at: string;
  issued_late: boolean;
  disclaimer: string;
  printed: boolean;
  copy_count: number;
  // Null before the first print and for prints made before templates existed.
  original_print?: PrintLayout | null;
  document: Record<string, unknown>;
  // A sale's e-invoice, read live by the server; null without one.
  einvoice?: ReceiptEinvoice | null;
};

export type ReceiptEinvoice = {
  status: string;
  invoice_type: 'cash_register' | 'coded';
  number: string | null;
  symbol: string | null;
  template_code: string | null;
  lookup_code: string | null;
  lookup_url: string | null;
  buyer_url: string | null;
};

export type ReceiptPrint = {
  id: string;
  copy: boolean;
  copy_number: number;
  label: string | null;
  printed_at: string;
} & Partial<PrintLayout>;

export type PrintFailureReason =
  | 'blocked'
  | 'failed'
  | 'mixed_content'
  | 'no_address'
  | 'cors'
  | 'unreachable'
  | 'printer_error'
  | 'timeout';

export type PrintOutcome =
  | { ok: true }
  | { ok: false; reason: PrintFailureReason; message?: string };

export type PrinterConnection =
  | 'escpos_lan'
  | 'escpos_bluetooth'
  | 'sunmi_builtin'
  | 'epson_epos'
  | 'star_webprnt'
  | 'browser';

export type PrinterRole =
  | 'receipt'
  | 'prebill'
  | 'kitchen_ticket'
  | 'void_ticket'
  | 'cup_label'
  | 'checklist'
  | 'table_qr';

export type PrinterSettings = {
  codepage?: string;
  char_width?: number;
  cut?: boolean;
  drawer?: boolean;
  https?: boolean;
};

// What a printer language needs to know about its target.
export type PrinterTarget = {
  connection: PrinterConnection;
  address: string | null;
  paper: '58mm' | '80mm';
  settings: PrinterSettings;
};

export type Printer = PrinterTarget & {
  id: string;
  branch_id: string;
  name: string;
  bluetooth_id: string | null;
  command_language: 'escpos' | 'tspl';
  roles: PrinterRole[];
  print_station_device_id: string | null;
  register_id: string | null;
  status: 'active' | 'disabled';
};

export type PrintJob = {
  id: string;
  branch_id: string;
  printer_id: string;
  printer_name: string;
  kind: string;
  status: 'queued' | 'claimed' | 'printed' | 'failed' | 'canceled';
  attempts: number;
  label: string | null;
  last_error: string | null;
  copy_of_id: string | null;
  created_at: string;
  printed_at: string | null;
  workspace_id: string | null;
  source_revision: number | null;
  // False when the printer is disabled or its station revoked: nothing will come for its jobs.
  printer_available: boolean;
  reprinted: boolean;
  reprint?: PrintJobReprint;
};

// What the reader may do about reprinting a pre-bill of an open order.
export type PrintJobReprint = {
  workspace_revision: number;
  approval_id: string | null;
  requester_id: string | null;
  can_approve: boolean;
};
