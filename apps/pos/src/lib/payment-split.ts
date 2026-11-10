import { parseVndInput } from '@parkviet/pos-shared/money';

// Amounts typed into the rows of a split payment, keyed by method kind.
export type RowAmounts = Partial<Record<string, string>>;

const whole = (value: string | undefined) => BigInt(parseVndInput(value ?? '') ?? 0);
const floor = (value: bigint) => String(value > 0n ? value : 0n);

// The amount of each split row: a typed value wins; otherwise the first row
// takes the whole target and every later row what the rows before it left.
export function splitRowValues(
  kinds: string[],
  target: string,
  typed: RowAmounts | null,
): Record<string, string> {
  const values: Record<string, string> = {};
  let taken = 0n;
  kinds.forEach((kind, index) => {
    const value = typed?.[kind] ?? (index === 0 ? target : floor(BigInt(target || 0) - taken));
    values[kind] = value;
    taken += whole(value);
  });
  return values;
}

// Typing into one row of a split rebalances another so the rows still add up
// to the target: the first row, or the last when the first one was typed.
export function rebalanceRows(
  kinds: string[],
  target: string,
  typed: RowAmounts | null,
  kind: string,
  raw: string,
): RowAmounts {
  const next: RowAmounts = { ...typed, [kind]: raw };
  if (kinds.length < 2) return next;
  const balancing = kind === kinds[0] ? kinds[kinds.length - 1] : kinds[0];
  const values = splitRowValues(kinds, target, next);
  const others = kinds
    .filter((item) => item !== balancing)
    .reduce((sum, item) => sum + whole(values[item]), 0n);
  next[balancing] = floor(BigInt(target || 0) - others);
  return next;
}
