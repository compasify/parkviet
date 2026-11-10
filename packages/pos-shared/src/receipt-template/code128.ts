// Code 128 (code set B) for document numbers, so a receipt can be scanned
// back at the returns and orders screens. Set B covers printable ASCII,
// which every POS document number is made of; anything else is refused
// rather than printed as a barcode that scans to something else.

// Module patterns of symbol values 0–105 (1 = bar, 0 = space), 11 modules
// each, then the 13-module stop.
export const CODE128_PATTERNS: readonly string[] = [
  '11011001100',
  '11001101100',
  '11001100110',
  '10010011000',
  '10010001100',
  '10001001100',
  '10011001000',
  '10011000100',
  '10001100100',
  '11001001000',
  '11001000100',
  '11000100100',
  '10110011100',
  '10011011100',
  '10011001110',
  '10111001100',
  '10011101100',
  '10011100110',
  '11001110010',
  '11001011100',
  '11001001110',
  '11011100100',
  '11001110100',
  '11101101110',
  '11101001100',
  '11100101100',
  '11100100110',
  '11101100100',
  '11100110100',
  '11100110010',
  '11011011000',
  '11011000110',
  '11000110110',
  '10100011000',
  '10001011000',
  '10001000110',
  '10110001000',
  '10001101000',
  '10001100010',
  '11010001000',
  '11000101000',
  '11000100010',
  '10110111000',
  '10110001110',
  '10001101110',
  '10111011000',
  '10111000110',
  '10001110110',
  '11101110110',
  '11010001110',
  '11000101110',
  '11011101000',
  '11011100010',
  '11011101110',
  '11101011000',
  '11101000110',
  '11100010110',
  '11101101000',
  '11101100010',
  '11100011010',
  '11101111010',
  '11001000010',
  '11110001010',
  '10100110000',
  '10100001100',
  '10010110000',
  '10010000110',
  '10000101100',
  '10000100110',
  '10110010000',
  '10110000100',
  '10011010000',
  '10011000010',
  '10000110100',
  '10000110010',
  '11000010010',
  '11001010000',
  '11110111010',
  '11000010100',
  '10001111010',
  '10100111100',
  '10010111100',
  '10010011110',
  '10111100100',
  '10011110100',
  '10011110010',
  '11110100100',
  '11110010100',
  '11110010010',
  '11011011110',
  '11011110110',
  '11110110110',
  '10101111000',
  '10100011110',
  '10001011110',
  '10111101000',
  '10111100010',
  '11110101000',
  '11110100010',
  '10111011110',
  '10111101110',
  '11101011110',
  '11110101110',
  '11010000100',
  '11010010000',
  '11010011100',
];
export const CODE128_STOP = '1100011101011';
const START_B = 104;

// The longest text encoded at all; whether a barcode fits a paper is
// decided by `barcodeWidthMm`.
export const MAX_BARCODE_LENGTH = 24;
// Blank modules on each side, so scanners find where the code starts.
export const QUIET_ZONE = 10;
// Module widths on paper: the preferred one, and the narrowest the counter's
// scanners still read. A barcode that only fits narrower is not printed.
export const MODULE_MM = 0.33;
export const MIN_MODULE_MM = 0.25;

// The symbol values of `text` in code set B with its start code and check
// value, or null when a character is not in set B or the text is too long.
export function code128Values(text: string): number[] | null {
  if (text === '' || text.length > MAX_BARCODE_LENGTH) return null;
  const values = [START_B];
  for (const char of text) {
    const code = char.charCodeAt(0);
    if (code < 32 || code > 126) return null;
    values.push(code - 32);
  }
  const sum = values.reduce((total, value, index) => total + value * Math.max(index, 1), 0);
  values.push(sum % 103);
  return values;
}

// The bars of `text`, left to right, as module offsets and widths.
export function code128Bars(
  text: string,
): { modules: number; bars: { x: number; width: number }[] } | null {
  const values = code128Values(text);
  if (!values) return null;
  const pattern = values.map((value) => CODE128_PATTERNS[value]).join('') + CODE128_STOP;
  const bars: { x: number; width: number }[] = [];
  for (let x = 0; x < pattern.length; x += 1) {
    if (pattern[x] !== '1') continue;
    const last = bars[bars.length - 1];
    if (last && last.x + last.width === x) last.width += 1;
    else bars.push({ x, width: 1 });
  }
  return { modules: pattern.length, bars };
}

// The printed width of `text`'s barcode, quiet zones included, within
// `printableMm`: at the preferred module width when it fits, narrower down
// to the minimum, else null (the barcode is left off).
export function barcodeWidthMm(text: string, printableMm: number): number | null {
  const bars = code128Bars(text);
  if (!bars) return null;
  const modules = bars.modules + QUIET_ZONE * 2;
  if (modules * MIN_MODULE_MM > printableMm) return null;
  return Math.min(modules * MODULE_MM, printableMm);
}
