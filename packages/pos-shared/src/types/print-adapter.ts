import type { PrintLayout } from '../receipt-template/selection';

// The persisted receipt and print records; no browser printing implementation.
export type ReceiptSnapshot = {
  id: string;
  source_type: 'sale' | 'return' | 'refund' | 'shift_closure';
  number: string;
  branch_id: string;
  issued_at: string;
  issued_late: boolean;
  disclaimer: string;
  printed: boolean;
  copy_count: number;
  // Null before the first print and for prints made before templates existed.
  original_print?: PrintLayout | null;
  document: Record<string, unknown>;
};

export type ReceiptPrint = {
  id: string;
  copy: boolean;
  copy_number: number;
  label: string | null;
  printed_at: string;
} & Partial<PrintLayout>;
