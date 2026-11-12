import { fromHundredths, type Picks, toHundredths, toSelections } from './modifiers';

// The guest's cart, kept on the phone until it is sent. Prices here are the
// menu's and only shown; the server prices the order again.
export type CartLine = {
  key: string;
  itemId: string;
  variantId: string;
  name: string;
  size: string | null;
  quantity: number;
  picks: Picks;
  options: string[];
  note: string;
  unitPrice: string;
};

// What the server takes in one order.
export const MAX_LINES = 20;
export const MAX_LINE_QUANTITY = 20;
export const MAX_ITEMS = 50;
export const NOTE_MAX = 200;

export type CartProblem = 'too_many_lines' | 'too_many_items' | null;

// Same dish, size, picks and note: one line.
function lineKey(line: Omit<CartLine, 'key' | 'quantity'>): string {
  return JSON.stringify([line.variantId, toSelections(line.picks), line.note.trim()]);
}

export function itemCount(cart: CartLine[]): number {
  return cart.reduce((sum, line) => sum + line.quantity, 0);
}

export function addLine(cart: CartLine[], input: Omit<CartLine, 'key'>): CartLine[] {
  const key = lineKey(input);
  const found = cart.find((line) => line.key === key);
  if (found)
    return cart.map((line) =>
      line.key === key
        ? { ...line, quantity: Math.min(MAX_LINE_QUANTITY, line.quantity + input.quantity) }
        : line,
    );
  return [...cart, { ...input, note: input.note.trim(), key }];
}

export function setQuantity(cart: CartLine[], key: string, quantity: number): CartLine[] {
  if (quantity <= 0) return cart.filter((line) => line.key !== key);
  return cart.map((line) =>
    line.key === key ? { ...line, quantity: Math.min(MAX_LINE_QUANTITY, quantity) } : line,
  );
}

export function cartProblem(cart: CartLine[]): CartProblem {
  if (cart.length > MAX_LINES) return 'too_many_lines';
  if (itemCount(cart) > MAX_ITEMS) return 'too_many_items';
  return null;
}

export function cartTotal(cart: CartLine[]): string {
  const total = cart.reduce((sum, line) => {
    const unit = toHundredths(line.unitPrice);
    return unit === null ? sum : sum + unit * BigInt(line.quantity);
  }, 0n);
  return fromHundredths(total);
}

// The body of POST /api/v3/pos_guest/guest_orders. No price is sent.
export function orderBody(cart: CartLine[]) {
  return {
    items: cart.map((line) => ({
      variant_id: line.variantId,
      quantity: line.quantity,
      modifiers: toSelections(line.picks),
      ...(line.note.trim() ? { note: line.note.trim().slice(0, NOTE_MAX) } : {}),
    })),
  };
}
