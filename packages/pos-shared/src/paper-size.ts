import type { PaperSize } from './receipt-template/types';

// Every size a posted receipt can print on: thermal rolls first, then sheets.
export const PAPER_SIZES: readonly PaperSize[] = ['58mm', '80mm', 'a4', 'a5', 'a6'];

export const isPaperSize = (value: unknown): value is PaperSize =>
  typeof value === 'string' && (PAPER_SIZES as readonly string[]).includes(value);
