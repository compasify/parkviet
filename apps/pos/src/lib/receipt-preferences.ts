import type { DocumentType } from '@parkviet/pos-shared/receipt-template/types';

export const rememberedTemplateKey = (documentType: DocumentType) =>
  `parkviet-pos:receipt-template:${documentType}`;
// Paper was chosen per device before templates carried it.
export const LEGACY_PAPER_KEYS = ['parkviet-pos:receipt-paper', 'parkviet-pos:ticket-paper'];

export function rememberedTemplate(documentType: DocumentType): string | null {
  try {
    return window.localStorage.getItem(rememberedTemplateKey(documentType));
  } catch {
    return null;
  }
}

export function rememberTemplate(documentType: DocumentType, templateId: string) {
  try {
    window.localStorage.setItem(rememberedTemplateKey(documentType), templateId);
    for (const key of LEGACY_PAPER_KEYS) window.localStorage.removeItem(key);
  } catch {
    // A preference only: the print itself is recorded on the server.
  }
}

// Printing sale receipts as soon as they are issued is a setting of this
// device (its printer and driver), off until turned on here.
export const AUTO_PRINT_KEY = 'parkviet-pos:auto-print:sale';

export function autoPrintEnabled(): boolean {
  try {
    return window.localStorage.getItem(AUTO_PRINT_KEY) === 'on';
  } catch {
    return false;
  }
}

export function setAutoPrint(on: boolean) {
  try {
    if (on) window.localStorage.setItem(AUTO_PRINT_KEY, 'on');
    else window.localStorage.removeItem(AUTO_PRINT_KEY);
  } catch {
    // Storage unavailable: the cashier prints by hand.
  }
}
