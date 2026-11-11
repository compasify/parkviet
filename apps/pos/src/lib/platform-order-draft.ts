// A platform order being typed in: menu lines picked from the grid, each with
// the quantity and the platform's own unit price read off the platform's
// tablet. Pure, so the form and its tests share it.
import { estimatePrice } from './menu-selection';
import type { PosMenu, PosModifierSelection } from './pos-context';

export type PlatformDraftLine = {
  key: string;
  variantId: string;
  name: string;
  modifiers: PosModifierSelection[];
  modifierNames: string[];
  note: string;
  quantity: number;
  // The shop's price for one unit with its options, as the menu shows it now.
  shopPrice: string | null;
  // What the platform charges for one unit; blank keeps the shop's price.
  platformPrice: string;
};

export type PlatformEntryLine = {
  variant_id: string;
  quantity: number;
  modifiers?: PosModifierSelection[];
  note?: string;
  platform_price?: string;
};

export const PLATFORM_MAX_LINES = 50;
export const PLATFORM_MAX_QUANTITY = 100;

// The line a pick from the menu grid makes, or null when the menu no longer
// has the variant.
export function draftLine(
  menu: PosMenu,
  variantId: string,
  extra: { modifiers?: PosModifierSelection[]; note?: string },
  key: string,
): PlatformDraftLine | null {
  const item = menu.items.find((row) => row.variants.some((variant) => variant.id === variantId));
  const variant = item?.variants.find((row) => row.id === variantId);
  if (!item || !variant) return null;
  const groups = menu.modifier_groups.filter((group) => item.modifier_group_ids.includes(group.id));
  const modifiers = extra.modifiers ?? [];
  const picks = Object.fromEntries(modifiers.map((row) => [row.option_id, row.quantity ?? 1]));
  const options = groups.flatMap((group) => group.options);
  const modifierNames = modifiers.flatMap((row) => {
    const option = options.find((candidate) => candidate.id === row.option_id);
    if (!option) return [];
    return [(row.quantity ?? 1) > 1 ? `${option.name} x${row.quantity}` : option.name];
  });
  return {
    key,
    variantId,
    name: item.variants.length > 1 ? `${item.name} · ${variant.name}` : item.name,
    modifiers,
    modifierNames,
    note: extra.note?.trim() ?? '',
    quantity: 1,
    shopPrice: estimatePrice(variant.price, groups, picks),
    platformPrice: '',
  };
}

// A whole amount of money with no sign, as the platform prints it ("39000",
// "39.000"); blank is no price. Returns the plain digits, or null when invalid.
export function platformPriceValue(value: string): string | null | undefined {
  const text = value.trim();
  if (text === '') return undefined;
  if (!/^\d{1,3}(\.\d{3})*$|^\d+$/.test(text)) return null;
  return text.replaceAll('.', '');
}

export function lineValid(line: PlatformDraftLine): boolean {
  return (
    Number.isInteger(line.quantity) &&
    line.quantity >= 1 &&
    line.quantity <= PLATFORM_MAX_QUANTITY &&
    platformPriceValue(line.platformPrice) !== null
  );
}

// The lines as POST /pos/platform_orders takes them.
export function entryLines(lines: PlatformDraftLine[]): PlatformEntryLine[] {
  return lines.map((line) => {
    const price = platformPriceValue(line.platformPrice);
    return {
      variant_id: line.variantId,
      quantity: line.quantity,
      ...(line.modifiers.length > 0 ? { modifiers: line.modifiers } : {}),
      ...(line.note ? { note: line.note } : {}),
      ...(price ? { platform_price: price } : {}),
    };
  });
}

// The order's total at the platform's prices where given, else the shop's;
// null while a price is unknown or invalid.
export function draftTotal(lines: PlatformDraftLine[]): string | null {
  let total = 0;
  for (const line of lines) {
    const price = platformPriceValue(line.platformPrice);
    if (price === null) return null;
    const unit = price ?? line.shopPrice;
    if (unit === null) return null;
    total += Number(unit) * line.quantity;
  }
  return String(total);
}
