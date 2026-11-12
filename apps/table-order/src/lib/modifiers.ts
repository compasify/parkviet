import type { GuestMenu, MenuItem, ModifierGroup } from './types';

// The guest's picks in one item sheet: option id -> quantity. The same rules
// as the counter's menu (min / max per group, summed quantities where a group
// allows them); the server checks and prices them again.
export type Picks = Record<string, number>;

// The server's ceiling for one option in an allow-quantity group.
export const MAX_OPTION_QUANTITY = 10;

export type GroupProblem = 'min' | 'max' | null;

export function itemGroups(menu: GuestMenu, item: MenuItem): ModifierGroup[] {
  const byId = new Map(menu.modifier_groups.map((group) => [group.id, group]));
  return item.modifier_group_ids.flatMap((id) => {
    const group = byId.get(id);
    return group ? [group] : [];
  });
}

export function defaultPicks(groups: ModifierGroup[]): Picks {
  const picks: Picks = {};
  for (const group of groups)
    for (const option of group.options) if (option.default_selected) picks[option.id] = 1;
  return picks;
}

export function groupCount(group: ModifierGroup, picks: Picks): number {
  return group.options.reduce((count, option) => {
    const quantity = picks[option.id] ?? 0;
    if (quantity <= 0) return count;
    return count + (group.allow_quantity ? quantity : 1);
  }, 0);
}

export function groupProblem(group: ModifierGroup, picks: Picks): GroupProblem {
  const count = groupCount(group, picks);
  if (count < group.min_select) return 'min';
  if (count > group.max_select) return 'max';
  return null;
}

export function picksReady(groups: ModifierGroup[], picks: Picks): boolean {
  return groups.every((group) => groupProblem(group, picks) === null);
}

// Tapping an option: a single-choice group swaps its pick; other groups add
// or remove it and refuse a pick past the group's max.
export function togglePick(group: ModifierGroup, picks: Picks, optionId: string): Picks {
  if ((picks[optionId] ?? 0) > 0) {
    const next = { ...picks };
    delete next[optionId];
    return next;
  }
  if (group.max_select === 1 && !group.allow_quantity) {
    const next = { ...picks };
    for (const option of group.options) delete next[option.id];
    return { ...next, [optionId]: 1 };
  }
  if (groupCount(group, picks) + 1 > group.max_select) return picks;
  return { ...picks, [optionId]: 1 };
}

// +/- on an option of an allow-quantity group, within the group's max.
export function stepPick(
  group: ModifierGroup,
  picks: Picks,
  optionId: string,
  delta: 1 | -1,
): Picks {
  const quantity = (picks[optionId] ?? 0) + delta;
  if (quantity < 0 || quantity > MAX_OPTION_QUANTITY) return picks;
  if (delta > 0 && groupCount(group, picks) + 1 > group.max_select) return picks;
  const next = { ...picks };
  if (quantity === 0) delete next[optionId];
  else next[optionId] = quantity;
  return next;
}

// The body's modifiers, in a stable order so the same picks send the same body.
export function toSelections(picks: Picks): { option_id: string; quantity: number }[] {
  return Object.entries(picks)
    .filter(([, quantity]) => quantity > 0)
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([option_id, quantity]) => ({ option_id, quantity }));
}

// The names of the picks, for the cart and the order ("Thạch x2").
export function pickNames(groups: ModifierGroup[], picks: Picks): string[] {
  return groups.flatMap((group) =>
    group.options.flatMap((option) => {
      const quantity = picks[option.id] ?? 0;
      if (quantity <= 0) return [];
      return [quantity > 1 ? `${option.name} x${quantity}` : option.name];
    }),
  );
}

// Decimal strings ("30000.0") in hundredths, so sums never drift.
export function toHundredths(amount: string): bigint | null {
  const match = /^(-?)(\d+)(?:\.(\d+))?$/.exec(amount);
  if (!match) return null;
  const [, sign, whole, fraction = ''] = match;
  const value = BigInt(whole) * 100n + BigInt(fraction.padEnd(2, '0').slice(0, 2));
  return sign ? -value : value;
}

export function fromHundredths(value: bigint): string {
  const negative = value < 0n;
  const absolute = negative ? -value : value;
  return `${negative ? '-' : ''}${absolute / 100n}.${String(absolute % 100n).padStart(2, '0')}`;
}

// One item's price with its picks. Display only: the server prices the order.
export function unitPrice(basePrice: string, groups: ModifierGroup[], picks: Picks): string | null {
  let total = toHundredths(basePrice);
  if (total === null) return null;
  for (const group of groups)
    for (const option of group.options) {
      const quantity = picks[option.id] ?? 0;
      const delta = toHundredths(option.price_delta);
      if (quantity > 0 && delta !== null) total += delta * BigInt(quantity);
    }
  return fromHundredths(total);
}
