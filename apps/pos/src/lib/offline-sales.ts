import { estimatePrice, itemGroups } from './menu-selection';
import type { OfflineSaleLine, QueuedSale, StoredSnapshot } from './offline-store';
import type { PosMenu, PosModifierSelection } from './pos-context';

// The rules of selling offline: cash sales of menu items only, from a fresh
// snapshot of the cashier's open shift, with a bounded queue. Anything the
// server must decide (prices, stock, numbers, e-invoices) is decided when the
// sale is replayed.

// The queue stops taking sales past this many or this old an unsent sale:
// the counter must reach the server before it sells more offline.
export const MAX_QUEUED_SALES = 200;
export const MAX_PENDING_AGE_MS = 24 * 60 * 60 * 1000;
// The server takes at most this many lines, items per line and items per sale.
export const MAX_LINES = 20;
export const MAX_LINE_QUANTITY = 20;
export const MAX_ITEMS = 50;
// Never trust a snapshot longer than this, whatever the server said.
const SNAPSHOT_AGE_CAP_MS = 12 * 60 * 60 * 1000;

// What is not sold offline, shown on the offline screen with its reason.
export const BLOCKED_OFFLINE = [
  'transfer',
  'debt',
  'discount',
  'returns',
  'shift',
  'tables',
  'goods',
  'einvoice',
] as const;

export type SnapshotState =
  | 'ready'
  | 'missing'
  | 'stale'
  | 'shift_closed'
  | 'menu_disabled'
  | 'register_not_counter'
  | 'cash_unavailable'
  | 'not_allowed';

export function snapshotState(stored: StoredSnapshot | null, now = Date.now()): SnapshotState {
  if (!stored) return 'missing';
  const maxAge = Math.min(stored.data.max_age_seconds * 1000, SNAPSHOT_AGE_CAP_MS);
  if (!(now - stored.savedAt >= 0 && now - stored.savedAt <= maxAge)) return 'stale';
  const reason = stored.data.offline.reason;
  if (!stored.data.offline.allowed) {
    return reason === 'shift_closed' ||
      reason === 'menu_disabled' ||
      reason === 'register_not_counter' ||
      reason === 'cash_unavailable'
      ? reason
      : 'not_allowed';
  }
  if (!stored.data.shift) return 'shift_closed';
  if (!stored.data.menu) return 'menu_disabled';
  return 'ready';
}

export type QueueBlock = 'queue_full' | 'queue_too_old' | null;

export function queueBlock(sales: QueuedSale[], now = Date.now()): QueueBlock {
  if (sales.length >= MAX_QUEUED_SALES) return 'queue_full';
  const oldest = sales.reduce<number | null>((min, sale) => {
    const at = Date.parse(sale.soldAt);
    return Number.isFinite(at) && (min === null || at < min) ? at : min;
  }, null);
  if (oldest !== null && now - oldest > MAX_PENDING_AGE_MS) return 'queue_too_old';
  return null;
}

// Decimal strings in hundredths, so sums never drift.
function hundredths(amount: string): bigint | null {
  const match = /^(\d+)(?:\.(\d+))?$/.exec(amount.trim());
  if (!match) return null;
  const [, whole, fraction = ''] = match;
  return BigInt(whole) * 100n + BigInt(fraction.padEnd(2, '0').slice(0, 2));
}

function decimal(value: bigint): string {
  return `${value / 100n}.${String(value % 100n).padStart(2, '0')}`;
}

export function lineAmount(line: OfflineSaleLine): string {
  return decimal((hundredths(line.unit_price) ?? 0n) * BigInt(line.quantity));
}

export function saleTotal(lines: OfflineSaleLine[]): string {
  return decimal(
    lines.reduce(
      (sum, line) => sum + (hundredths(line.unit_price) ?? 0n) * BigInt(line.quantity),
      0n,
    ),
  );
}

export function changeDue(total: string, handed: string): string | null {
  const due = hundredths(total);
  const given = hundredths(handed);
  if (due === null || given === null || given < due) return null;
  return decimal(given - due);
}

export function itemCount(lines: OfflineSaleLine[]): number {
  return lines.reduce((sum, line) => sum + line.quantity, 0);
}

// One menu pick as an offline line, priced the way the menu shows it. Null
// when the item cannot be sold offline (sold out, no price, not on the menu).
export function menuLine(
  menu: PosMenu,
  variantId: string,
  modifiers: PosModifierSelection[] | undefined,
  note: string | undefined,
): OfflineSaleLine | null {
  const item = menu.items.find((row) => row.variants.some((variant) => variant.id === variantId));
  const variant = item?.variants.find((row) => row.id === variantId);
  if (!item || !variant || item.sold_out || variant.price === null) return null;
  const groups = itemGroups(menu, item);
  const picks: Record<string, number> = {};
  if (modifiers === undefined) {
    for (const group of groups)
      for (const option of group.options) if (option.default_selected) picks[option.id] = 1;
  } else {
    for (const row of modifiers)
      picks[row.option_id] = (picks[row.option_id] ?? 0) + (row.quantity ?? 1);
  }
  const price = estimatePrice(variant.price, groups, picks);
  if (price === null) return null;
  const names = groups.flatMap((group) =>
    group.options
      .filter((option) => (picks[option.id] ?? 0) > 0)
      .map((option) =>
        picks[option.id] > 1 ? `${option.name} ×${picks[option.id]}` : option.name,
      ),
  );
  return {
    variant_id: variantId,
    quantity: 1,
    modifiers: Object.entries(picks)
      .filter(([, quantity]) => quantity > 0)
      .sort(([left], [right]) => left.localeCompare(right))
      .map(([option_id, quantity]) => ({ option_id, quantity })),
    note: note?.trim() || null,
    name: item.variants.length > 1 && variant.name ? `${item.name} ${variant.name}` : item.name,
    unit_price: decimal(hundredths(price) ?? 0n),
    modifier_names: names,
  };
}

// Lines with the same item, options and note are one line.
export function lineSignature(line: OfflineSaleLine) {
  return `${line.variant_id}|${JSON.stringify(line.modifiers)}|${line.note ?? ''}`;
}

function sameLine(left: OfflineSaleLine, right: OfflineSaleLine) {
  return lineSignature(left) === lineSignature(right);
}

export type LineChange = { lines: OfflineSaleLine[]; refused: 'too_many' | null };

// Adds one of `line`, joining a line with the same options, within the
// server's limits.
export function addLine(lines: OfflineSaleLine[], line: OfflineSaleLine): LineChange {
  if (itemCount(lines) + 1 > MAX_ITEMS) return { lines, refused: 'too_many' };
  const index = lines.findIndex((row) => sameLine(row, line));
  if (index >= 0) {
    const current = lines[index];
    if (current.quantity + 1 > MAX_LINE_QUANTITY) return { lines, refused: 'too_many' };
    return {
      lines: lines.map((row, at) => (at === index ? { ...row, quantity: row.quantity + 1 } : row)),
      refused: null,
    };
  }
  if (lines.length >= MAX_LINES) return { lines, refused: 'too_many' };
  return { lines: [...lines, line], refused: null };
}

export function changeQuantity(
  lines: OfflineSaleLine[],
  index: number,
  delta: number,
): OfflineSaleLine[] {
  return lines.flatMap((row, at) => {
    if (at !== index) return [row];
    const quantity = row.quantity + delta;
    if (quantity <= 0) return [];
    if (quantity > MAX_LINE_QUANTITY || itemCount(lines) + delta > MAX_ITEMS) return [row];
    return [{ ...row, quantity }];
  });
}

// The day in the branch's time zone as yyMMdd.
function dayStamp(date: Date, timeZone: string | null): string {
  try {
    const parts = new Intl.DateTimeFormat('en-GB', {
      timeZone: timeZone || 'Asia/Ho_Chi_Minh',
      year: '2-digit',
      month: '2-digit',
      day: '2-digit',
    }).formatToParts(date);
    const part = (type: string) => parts.find((row) => row.type === type)?.value ?? '00';
    return `${part('year')}${part('month')}${part('day')}`;
  } catch {
    return date.toISOString().slice(2, 10).replace(/-/g, '');
  }
}

// "OFF-Q1-261112-007": the register, the day and the register's own count.
// Provisional: the server gives the order its own numbers when it lands.
export function provisionalNumber(
  registerCode: string | null,
  date: Date,
  timeZone: string | null,
  sequence: number,
): string {
  const code = (registerCode ?? '').replace(/[^A-Za-z0-9]/g, '').slice(0, 8) || 'Q';
  return `OFF-${code}-${dayStamp(date, timeZone)}-${String(sequence).padStart(3, '0')}`;
}

export function sequenceCounter(registerId: string, date: Date, timeZone: string | null) {
  return `${registerId}:${dayStamp(date, timeZone)}`;
}

// What the server replays: the sale as recorded, the counter's clock now.
export function ingestBody(sale: QueuedSale, now: Date = new Date()) {
  return {
    offline_id: sale.offlineId,
    provisional_number: sale.provisionalNumber,
    register_id: sale.registerId,
    shift_id: sale.shiftId,
    client_sold_at: sale.soldAt,
    client_now: now.toISOString(),
    total: sale.total,
    handed_amount: sale.handedAmount,
    lines: sale.lines.map((line) => ({
      variant_id: line.variant_id,
      quantity: line.quantity,
      modifiers: line.modifiers,
      note: line.note,
      name: line.name,
      unit_price: line.unit_price,
    })),
  };
}

export function offlineKey(offlineId: string) {
  return `offline:${offlineId}`;
}
