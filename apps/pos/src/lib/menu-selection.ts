import type {
  PosLineItem,
  PosMenu,
  PosMenuItem,
  PosMenuModifierGroup,
  PosModifierSelection,
} from './pos-context';
import { conflictReason, describeFailure } from './request-failure';

// The cashier's picks in one modifier sheet: option id -> quantity. The
// server checks and prices them again; nothing here decides money.
export type MenuPicks = Record<string, number>;

// The server's ceiling for one option in an allow-quantity group.
export const MAX_OPTION_QUANTITY = 10;

export type GroupProblem = 'min' | 'max' | null;

// The groups offered on an item, in the order the item lists them, with
// inactive options left out.
export function itemGroups(menu: PosMenu, item: PosMenuItem): PosMenuModifierGroup[] {
  const byId = new Map(menu.modifier_groups.map((group) => [group.id, group]));
  return item.modifier_group_ids.flatMap((id) => {
    const group = byId.get(id);
    return group ? [{ ...group, options: group.options.filter((option) => option.active) }] : [];
  });
}

export function defaultPicks(groups: PosMenuModifierGroup[]): MenuPicks {
  const picks: MenuPicks = {};
  for (const group of groups)
    for (const option of group.options) if (option.default_selected) picks[option.id] = 1;
  return picks;
}

// The picks of a line already in the basket, for editing them again.
export function linePicks(line: PosLineItem): MenuPicks {
  const picks: MenuPicks = {};
  for (const row of line.modifiers ?? [])
    if (row.option_id) picks[row.option_id] = (picks[row.option_id] ?? 0) + row.quantity;
  return picks;
}

// What counts against min and max: summed quantity where quantities are
// allowed, distinct options otherwise. Same rule as the server.
export function groupCount(group: PosMenuModifierGroup, picks: MenuPicks): number {
  return group.options.reduce((count, option) => {
    const quantity = picks[option.id] ?? 0;
    if (quantity <= 0) return count;
    return count + (group.allow_quantity ? quantity : 1);
  }, 0);
}

export function groupProblem(group: PosMenuModifierGroup, picks: MenuPicks): GroupProblem {
  const count = groupCount(group, picks);
  if (count < group.min_select) return 'min';
  if (count > group.max_select) return 'max';
  return null;
}

export function picksReady(groups: PosMenuModifierGroup[], picks: MenuPicks): boolean {
  return groups.every((group) => groupProblem(group, picks) === null);
}

function withoutGroup(group: PosMenuModifierGroup, picks: MenuPicks): MenuPicks {
  const next = { ...picks };
  for (const option of group.options) delete next[option.id];
  return next;
}

// Tapping an option. A single-choice group swaps its pick; other groups add
// or remove the option and refuse a pick past the group's max.
export function togglePick(
  group: PosMenuModifierGroup,
  picks: MenuPicks,
  optionId: string,
): MenuPicks {
  const picked = (picks[optionId] ?? 0) > 0;
  if (picked) {
    const next = { ...picks };
    delete next[optionId];
    return next;
  }
  if (group.max_select === 1 && !group.allow_quantity)
    return { ...withoutGroup(group, picks), [optionId]: 1 };
  if (groupCount(group, picks) + 1 > group.max_select) return picks;
  return { ...picks, [optionId]: 1 };
}

// +/- on an option of an allow-quantity group, within the group's max.
export function stepPick(
  group: PosMenuModifierGroup,
  picks: MenuPicks,
  optionId: string,
  delta: 1 | -1,
): MenuPicks {
  const current = picks[optionId] ?? 0;
  const quantity = current + delta;
  if (quantity < 0 || quantity > MAX_OPTION_QUANTITY) return picks;
  if (delta > 0 && groupCount(group, picks) + 1 > group.max_select) return picks;
  const next = { ...picks };
  if (quantity === 0) delete next[optionId];
  else next[optionId] = quantity;
  return next;
}

// The request body for the item endpoints, in a stable order so the same
// picks always send the same body.
export function toSelections(picks: MenuPicks): PosModifierSelection[] {
  return Object.entries(picks)
    .filter(([, quantity]) => quantity > 0)
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([option_id, quantity]) => ({ option_id, quantity }));
}

// Decimal strings ("30000.0", "-2500.5") in hundredths, so sums never drift.
function toHundredths(amount: string): bigint | null {
  const match = /^(-?)(\d+)(?:\.(\d+))?$/.exec(amount);
  if (!match) return null;
  const [, sign, whole, fraction = ''] = match;
  const value = BigInt(whole) * 100n + BigInt(fraction.padEnd(2, '0').slice(0, 2));
  return sign ? -value : value;
}

function fromHundredths(value: bigint): string {
  const negative = value < 0n;
  const absolute = negative ? -value : value;
  const fraction = String(absolute % 100n).padStart(2, '0');
  return `${negative ? '-' : ''}${absolute / 100n}.${fraction}`;
}

// The price shown in the sheet before adding. Display only: the line takes
// the price the server works out.
export function estimatePrice(
  basePrice: string | null,
  groups: PosMenuModifierGroup[],
  picks: MenuPicks,
): string | null {
  if (basePrice === null) return null;
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

// Tiles of one tab: a category, or every item. Quick search narrows by
// name or code without accents mattering.
export function fold(text: string): string {
  return text
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/đ/g, 'd')
    .replace(/Đ/g, 'D')
    .toLowerCase()
    .trim();
}

export function visibleItems(
  menu: PosMenu,
  categoryId: string | null,
  query: string,
): PosMenuItem[] {
  const needle = fold(query);
  return menu.items.filter((item) => {
    if (categoryId && item.menu_category_id !== categoryId) return false;
    if (!needle) return true;
    return (
      fold(item.name).includes(needle) ||
      item.variants.some(
        (variant) =>
          (variant.sku && fold(variant.sku).includes(needle)) ||
          (variant.barcode && variant.barcode === query.trim()),
      )
    );
  });
}

export function favoriteItems(menu: PosMenu): PosMenuItem[] {
  const byId = new Map(menu.items.map((item) => [item.id, item]));
  return menu.favorites.flatMap((id) => {
    const item = byId.get(id);
    return item ? [item] : [];
  });
}

// Refusals of the menu with a counter wording; anything else reads as any
// other workspace command failure.
const MENU_REASONS = [
  'menu_item_sold_out',
  'menu_item_hidden',
  'modifier_unknown',
  'modifier_min',
  'modifier_max',
  'note_too_long',
] as const;

export function describeMenuFailure(error: unknown, translate: (key: string) => string): string {
  const reason = conflictReason(error);
  if (reason && (MENU_REASONS as readonly string[]).includes(reason))
    return translate(`menuFailure_${reason}`);
  return describeFailure(error, translate);
}

// An item adds in one tap when there is nothing to choose: one size, no
// groups. Defaults still apply on the server.
export function addsInOneTap(menu: PosMenu, item: PosMenuItem): boolean {
  return item.variants.length === 1 && itemGroups(menu, item).length === 0;
}
