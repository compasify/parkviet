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

// What one press of the payment screen's finish button pays. A QR whose
// money arrived (`qr`) is confirmed first, so the cash pays only what is due
// after it, never more than an even part (`share`). Like the server, the
// change is what was handed (`cash`, the tip already taken off) over the
// amount the cash pays.
export function payPreview(input: {
  due: bigint;
  share: bigint | null;
  cash: bigint | null;
  qr: bigint;
}): { cashTarget: bigint; cashPays: bigint; change: bigint; paysNow: bigint } {
  const afterQr = input.due > input.qr ? input.due - input.qr : 0n;
  const cashTarget = input.share !== null && input.share < afterQr ? input.share : afterQr;
  const cash = input.cash !== null && input.cash > 0n ? input.cash : 0n;
  // biome-ignore lint/complexity/useMathMinMax: Math.min does not take bigint
  const cashPays = cash < cashTarget ? cash : cashTarget;
  // Nothing left for the cash: none is taken, so none is given back.
  const change = cashTarget > 0n && cash > cashTarget ? cash - cashTarget : 0n;
  return { cashTarget, cashPays, change, paysNow: cashPays + input.qr };
}
