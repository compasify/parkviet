// Notes a guest is likely to hand over for an amount due in whole VND: the
// amount rounded up to the next 10k, 50k, 100k, 200k and 500k, without
// repeats, smallest first. The exact amount is offered separately.
const STEPS = [10_000n, 50_000n, 100_000n, 200_000n, 500_000n];

export function cashSuggestions(due: bigint, limit = 4): bigint[] {
  if (due <= 0n) return [];
  const values = new Set<bigint>();
  for (const step of STEPS) {
    const rounded = ((due + step - 1n) / step) * step;
    if (rounded > due) values.add(rounded);
  }
  return [...values].sort((a, b) => (a < b ? -1 : a > b ? 1 : 0)).slice(0, limit);
}

// Whole VND digits grouped by dots, as the cashier types them ("150.000").
export function groupVndDigits(digits: string): string {
  return digits.replace(/\B(?=(\d{3})+(?!\d))/g, '.');
}

// Splitting what is due evenly: each part, rounded up so the parts cover it.
export function evenShare(due: bigint, parts: number): bigint {
  if (parts < 1 || due <= 0n) return due > 0n ? due : 0n;
  const count = BigInt(parts);
  return (due + count - 1n) / count;
}
