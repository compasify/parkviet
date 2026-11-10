// Parsing only: calculations and rounding remain the server's responsibility.
// Canonical strings preserve arbitrary precision and never pass through Number.
function canonicalDecimal(input: string): string | null {
  const match = /^(\d+)(?:\.(\d+))?$/.exec(input.trim());
  if (!match) return null;
  const whole = match[1].replace(/^0+(?=\d)/, '');
  const fraction = (match[2] ?? '').replace(/0+$/, '');
  return fraction ? `${whole}.${fraction}` : whole;
}

export function parseMoneyInput(input: string): string | null {
  return canonicalDecimal(input);
}

// Display only. Group the canonical server string without rounding or converting
// it to a floating-point number; prices/totals always remain server-owned.
export function formatMoney(amount: string | null | undefined, currency = 'VND'): string {
  if (amount == null || !/^-?\d+(?:\.\d+)?$/.test(amount)) return '—';
  const [whole, rawFraction = ''] = amount.split('.');
  const fraction = rawFraction.replace(/0+$/, '');
  const grouped = whole.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
  return `${grouped}${fraction ? `,${fraction}` : ''} ${currency === 'VND' ? '₫' : currency}`;
}

// For canonical server strings such as "150000.0"; never for cashier input,
// where a dot groups thousands.
export function parseVndAmount(input: string): string | null {
  const value = canonicalDecimal(input);
  return value !== null && !value.includes('.') ? value : null;
}

// Cashier-typed VND: plain digits, or thousands grouped by dots or spaces
// ("150.000", "1 500 000"). Commas, fractions and signs are rejected so a
// grouped amount can never be misread as a smaller decimal one.
const PLAIN_DIGITS = /^\d+$/;
const DOT_GROUPED = /^\d{1,3}(?:\.\d{3})+$/;
const SPACE_GROUPED = /^\d{1,3}(?:[  ]\d{3})+$/;

export function parseVndInput(input: string): string | null {
  const value = input.trim();
  if (!PLAIN_DIGITS.test(value) && !DOT_GROUPED.test(value) && !SPACE_GROUPED.test(value))
    return null;
  return value.replace(/\D/g, '').replace(/^0+(?=\d)/, '');
}

export function parsePercentageInput(input: string): string | null {
  const value = canonicalDecimal(input);
  if (value === null) return null;
  const [whole, fraction] = value.split('.');
  if (whole.length > 3 || (whole.length === 3 && whole > '100')) return null;
  if (whole === '100' && fraction) return null;
  return value;
}
