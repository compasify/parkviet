import type { TemplateData } from './data';

// Template text may name only these values, written `{store.name}`. They
// are inserted as plain text, never markup, and clipped so a long value
// cannot push a narrow roll out of shape. Anything else in braces is left
// as written.

export const TEMPLATE_VARIABLES = [
  'store.name',
  'store.address',
  'store.phone',
  'store.email',
  'store.url',
  'store.facebook',
  'store.instagram',
  'branch.name',
  'branch.code',
  'branch.return_window_days',
  'register.name',
  'cashier',
  'document.number',
  'document.time',
  'document.business_date',
  'document.taxes',
  'order.call_number',
  'order.guest_name',
  'customer.name',
  'customer.phone',
  'customer.address',
  'einvoice.lookup_code',
  'einvoice.lookup_url',
  'einvoice.buyer_qr',
] as const;

export type TemplateVariable = (typeof TEMPLATE_VARIABLES)[number];

export const MAX_VARIABLE_LENGTH = 120;

const KNOWN = new Set<string>(TEMPLATE_VARIABLES);
const PATTERN = /\{([a-z_]+(?:\.[a-z_]+)?)\}/g;

export const isTemplateVariable = (name: string): name is TemplateVariable => KNOWN.has(name);

export function variableValues(data: TemplateData): Record<TemplateVariable, string> {
  return {
    'store.name': data.store.name ?? '',
    'store.address': data.store.address ?? '',
    'store.phone': data.store.phone ?? '',
    'store.email': data.store.email ?? '',
    'store.url': data.store.url ?? '',
    'store.facebook': data.store.facebook ?? '',
    'store.instagram': data.store.instagram ?? '',
    'branch.name': data.branch.name ?? '',
    'branch.code': data.branch.code ?? '',
    'branch.return_window_days':
      data.branch.returnWindowDays === null ? '' : String(data.branch.returnWindowDays),
    'register.name': data.register ?? '',
    cashier: data.cashier ?? '',
    'document.number': data.number ?? '',
    'document.time': data.time,
    'document.business_date': data.businessDate,
    'document.taxes': data.taxesText,
    'order.call_number': data.callNumber ?? '',
    'order.guest_name': data.guestName ?? '',
    'customer.name': data.customerName ?? '',
    'customer.phone': data.customerPhone ?? '',
    'customer.address': data.customerAddress ?? '',
    'einvoice.lookup_code': data.einvoice?.lookupCode ?? '',
    'einvoice.lookup_url': data.einvoice?.lookupUrl ?? '',
    'einvoice.buyer_qr': data.einvoice?.buyerUrl ?? '',
  };
}

const clip = (value: string) =>
  value.length > MAX_VARIABLE_LENGTH ? `${value.slice(0, MAX_VARIABLE_LENGTH - 1)}…` : value;

// The text with every known variable replaced. `blank` is true when the
// text names known variables and every one of them is empty, so a line such
// as "ĐT: {store.phone}" disappears for a store without a phone.
export function resolveText(text: string, data: TemplateData): { text: string; blank: boolean } {
  const values = variableValues(data);
  let named = 0;
  let filled = 0;
  const resolved = text.replace(PATTERN, (whole, name: string) => {
    if (!isTemplateVariable(name)) return whole;
    named += 1;
    const value = clip(values[name].trim());
    if (value) filled += 1;
    return value;
  });
  return { text: resolved, blank: resolved.trim() === '' || (named > 0 && filled === 0) };
}

export function interpolate(text: string, data: TemplateData): string {
  return resolveText(text, data).text;
}
