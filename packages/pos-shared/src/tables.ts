// Tables and the floor (GET /pos/resource_board, /pos/areas, /pos/resources).
// The server computes every table's state from its open orders; this module
// only reads that answer tolerantly, filters it, and checks a table fits its
// area on the floor plan grid before the editor saves it.

import { parseVndAmount } from './money';

export const TABLE_STATES = [
  'available',
  'reserved',
  'occupied',
  'ordered',
  'playing',
  'waiting_long',
  'ending_soon',
  'payment_requested',
  'prebilled',
  'cleaning',
  'out_of_service',
] as const;

export type TableState = (typeof TABLE_STATES)[number];

export const RESOURCE_KINDS = ['table', 'room', 'billiard', 'vip'] as const;
export type ResourceKind = (typeof RESOURCE_KINDS)[number];

export const RESOURCE_SHAPES = ['rect', 'round'] as const;
export type ResourceShape = (typeof RESOURCE_SHAPES)[number];

export const MANUAL_STATUSES = ['available', 'cleaning', 'out_of_service'] as const;
export type ManualStatus = (typeof MANUAL_STATUSES)[number];

export type FloorArea = {
  id: string;
  name: string;
  position: number;
  floor_width: number;
  floor_height: number;
};

export type BoardOrder = {
  id: string;
  table_label: string | null;
  guest_count: number | null;
  total: string;
  revision: number;
  operational_status: string;
  payment_requested: boolean;
  prebilled: boolean;
  edited_after_prebill: boolean;
  // Items sent to the kitchen and not ready yet.
  pending_kitchen_items: number;
  // Menu units the kitchen has not been told about yet (held courses not
  // counted); null from a server that does not report it.
  unsent_kitchen_items: number | null;
  // When the order's earliest buffet ticket runs out; null without a buffet.
  buffet_ends_at: string | null;
  // When the order was opened at the table; null from an older server.
  opened_at: string | null;
};

// The table's next booking in the coming hours (`fnb.reservations`).
export type NextReservation = {
  id: string;
  starts_at: string;
  guest_name: string;
  party_size: number;
};

// The clock of a room or billiard table (`timed_billing`): the running one,
// else the last one stopped and not paid yet. Times are the server's.
export type BoardTimed = {
  id: string;
  workspace_id: string | null;
  status: 'running' | 'paused' | 'stopped';
  started_at: string;
  stopped_at: string | null;
  planned_end_at: string | null;
  played_minutes: number;
  // The price up to the board's read (running) or as billed (stopped).
  quote_amount: string;
  ending_soon: boolean;
  // Since when the clock is paused; null unless paused.
  paused_at: string | null;
  // The minutes of the prepaid package the clock was sold with.
  prepaid_minutes: number | null;
  // Seconds played up to `server_now`, pauses not counted; null once stopped
  // (and from an older server).
  played_seconds: number | null;
  // A package clock still runs past its prepaid minutes.
  package_ended: boolean;
  // Paused longer than the branch allows: resuming needs an approval.
  pause_too_long: boolean;
  // The hourly price the clock runs at now, its day surcharge included; null
  // once stopped, while a package covers the time, or from an older server.
  rate_per_hour: string | null;
};

export type Placement = { x: number; y: number; w: number; h: number; rotation: number };

export type BoardTable = Placement & {
  id: string;
  area_id: string | null;
  name: string;
  kind: ResourceKind;
  capacity: number;
  shape: ResourceShape;
  manual_status: ManualStatus;
  state: TableState;
  guest_count: number | null;
  seated_minutes: number | null;
  subtotal: string | null;
  currency: string | null;
  payment_requested: boolean;
  edited_after_prebill: boolean;
  orders: BoardOrder[];
  next_reservation: NextReservation | null;
  buffet_ends_at: string | null;
  timed: BoardTimed | null;
};

export type ResourceBoard = {
  branch_id: string;
  server_now: string | null;
  // A clock started now starts outside the branch's operating hours.
  outside_operating_hours: boolean;
  areas: FloorArea[];
  resources: BoardTable[];
};

// An area or a table as the floor plan editor reads and writes it.
export type AreaRecord = FloorArea & { branch_id: string; status: string };
export type ResourceRecord = Placement & {
  id: string;
  branch_id: string;
  area_id: string;
  kind: ResourceKind;
  name: string;
  capacity: number;
  shape: ResourceShape;
  manual_status: ManualStatus;
  resource_type_code: string | null;
  status: string;
  position: number;
  // A VIP table's minimum spend in whole VND; null without one.
  minimum_spend?: string | null;
};

function record(value: unknown): Record<string, unknown> | null {
  return typeof value === 'object' && value !== null && !Array.isArray(value)
    ? (value as Record<string, unknown>)
    : null;
}

function int(value: unknown, fallback = 0): number {
  return typeof value === 'number' && Number.isInteger(value) ? value : fallback;
}

function nullableInt(value: unknown): number | null {
  return typeof value === 'number' && Number.isInteger(value) ? value : null;
}

function text(value: unknown): string | null {
  return typeof value === 'string' ? value : null;
}

function oneOf<T extends string>(values: readonly T[], value: unknown, fallback: T): T {
  return values.includes(value as T) ? (value as T) : fallback;
}

function placement(source: Record<string, unknown>): Placement {
  return {
    x: int(source.x),
    y: int(source.y),
    w: Math.max(1, int(source.w, 1)),
    h: Math.max(1, int(source.h, 1)),
    rotation: int(source.rotation),
  };
}

function area(value: unknown): FloorArea | null {
  const source = record(value);
  if (!source || typeof source.id !== 'string') return null;
  return {
    id: source.id,
    name: text(source.name) ?? '',
    position: int(source.position),
    floor_width: Math.max(1, int(source.floor_width, 24)),
    floor_height: Math.max(1, int(source.floor_height, 16)),
  };
}

function order(value: unknown): BoardOrder | null {
  const source = record(value);
  if (!source || typeof source.id !== 'string') return null;
  return {
    id: source.id,
    table_label: text(source.table_label),
    guest_count: nullableInt(source.guest_count),
    total: text(source.total) ?? '0',
    revision: int(source.revision),
    operational_status: text(source.operational_status) ?? 'editing',
    payment_requested: source.payment_requested === true,
    prebilled: source.prebilled === true,
    edited_after_prebill: source.edited_after_prebill === true,
    pending_kitchen_items: int(source.pending_kitchen_items),
    unsent_kitchen_items: nullableInt(source.unsent_kitchen_items),
    buffet_ends_at: text(source.buffet_ends_at),
    opened_at: text(source.opened_at),
  };
}

function table(value: unknown): BoardTable | null {
  const source = record(value);
  if (!source || typeof source.id !== 'string') return null;
  return {
    id: source.id,
    area_id: text(source.area_id),
    name: text(source.name) ?? '',
    kind: oneOf(RESOURCE_KINDS, source.kind, 'table'),
    capacity: int(source.capacity),
    shape: oneOf(RESOURCE_SHAPES, source.shape, 'rect'),
    ...placement(source),
    manual_status: oneOf(MANUAL_STATUSES, source.manual_status, 'available'),
    state: oneOf(TABLE_STATES, source.state, 'available'),
    guest_count: nullableInt(source.guest_count),
    seated_minutes: nullableInt(source.seated_minutes),
    subtotal: text(source.subtotal),
    currency: text(source.currency),
    payment_requested: source.payment_requested === true,
    edited_after_prebill: source.edited_after_prebill === true,
    orders: (Array.isArray(source.orders) ? source.orders : []).flatMap((row) => {
      const item = order(row);
      return item ? [item] : [];
    }),
    next_reservation: nextReservation(source.next_reservation),
    buffet_ends_at: text(source.buffet_ends_at),
    timed: boardTimed(source.timed),
  };
}

const TIMED_STATUSES = ['running', 'paused', 'stopped'] as const;

function boardTimed(value: unknown): BoardTimed | null {
  const source = record(value);
  if (!source || typeof source.id !== 'string' || typeof source.started_at !== 'string')
    return null;
  return {
    id: source.id,
    workspace_id: text(source.workspace_id),
    status: oneOf(TIMED_STATUSES, source.status, 'stopped'),
    started_at: source.started_at,
    stopped_at: text(source.stopped_at),
    planned_end_at: text(source.planned_end_at),
    played_minutes: int(source.played_minutes),
    quote_amount: text(source.quote_amount) ?? '0',
    ending_soon: source.ending_soon === true,
    paused_at: text(source.paused_at),
    prepaid_minutes: nullableInt(source.prepaid_minutes),
    played_seconds: nullableInt(source.played_seconds),
    package_ended: source.package_ended === true,
    pause_too_long: source.pause_too_long === true,
    rate_per_hour: text(source.rate_per_hour),
  };
}

// Seconds a clock has played at `now` (milliseconds on the server's clock,
// as the screen estimates it), pauses not counted: the board's count at
// `readAt` plus the time since while it runs. A stopped clock is what the
// server counted as played. Without the board's count (an older server),
// from its start to now.
export function clockPlayedSeconds(timed: BoardTimed, readAt: string | null, now: number): number {
  if (timed.status === 'stopped') return Math.max(0, timed.played_minutes) * 60;
  const read = readAt ? Date.parse(readAt) : Number.NaN;
  if (timed.played_seconds !== null && !Number.isNaN(read)) {
    const since = timed.status === 'running' ? Math.max(0, now - read) / 1000 : 0;
    return Math.max(0, Math.floor(timed.played_seconds + since));
  }
  const start = Date.parse(timed.started_at);
  return Number.isNaN(start) ? 0 : Math.max(0, Math.floor((now - start) / 1000));
}

// Seconds until a running clock's planned end (its package's end when it
// has one), negative once past; null without an end or when not running.
export function clockSecondsLeft(timed: BoardTimed, now: number): number | null {
  if (timed.status !== 'running' || !timed.planned_end_at) return null;
  const end = Date.parse(timed.planned_end_at);
  return Number.isNaN(end) ? null : Math.floor((end - now) / 1000);
}

function nextReservation(value: unknown): NextReservation | null {
  const source = record(value);
  if (!source || typeof source.id !== 'string' || typeof source.starts_at !== 'string') return null;
  return {
    id: source.id,
    starts_at: source.starts_at,
    guest_name: text(source.guest_name) ?? '',
    party_size: int(source.party_size),
  };
}

export function normalizeResourceBoard(value: unknown): ResourceBoard {
  const source = record(value) ?? {};
  return {
    branch_id: text(source.branch_id) ?? '',
    server_now: text(source.server_now),
    outside_operating_hours: source.outside_operating_hours === true,
    areas: (Array.isArray(source.areas) ? source.areas : [])
      .flatMap((row) => {
        const item = area(row);
        return item ? [item] : [];
      })
      .sort((left, right) => left.position - right.position),
    resources: (Array.isArray(source.resources) ? source.resources : []).flatMap((row) => {
      const item = table(row);
      return item ? [item] : [];
    }),
  };
}

export function normalizeArea(value: unknown): AreaRecord | null {
  const base = area(value);
  const source = record(value);
  if (!base || !source) return null;
  return {
    ...base,
    branch_id: text(source.branch_id) ?? '',
    status: text(source.status) ?? 'active',
  };
}

export function normalizeResource(value: unknown): ResourceRecord | null {
  const source = record(value);
  if (!source || typeof source.id !== 'string') return null;
  return {
    id: source.id,
    branch_id: text(source.branch_id) ?? '',
    area_id: text(source.area_id) ?? '',
    kind: oneOf(RESOURCE_KINDS, source.kind, 'table'),
    name: text(source.name) ?? '',
    capacity: int(source.capacity),
    shape: oneOf(RESOURCE_SHAPES, source.shape, 'rect'),
    ...placement(source),
    manual_status: oneOf(MANUAL_STATUSES, source.manual_status, 'available'),
    resource_type_code: text(source.resource_type_code),
    status: text(source.status) ?? 'active',
    position: int(source.position),
    minimum_spend:
      typeof source.minimum_spend === 'string' ? parseVndAmount(source.minimum_spend) : null,
  };
}

export type BoardFilter = { areaId?: string | null; state?: TableState | 'open' | null };

// Tables of one area (all areas without one) and in one state; `open` keeps
// every table with an open order.
export function filterTables(tables: BoardTable[], filter: BoardFilter): BoardTable[] {
  return tables.filter(
    (row) =>
      (!filter.areaId || row.area_id === filter.areaId) &&
      (!filter.state ||
        (filter.state === 'open' ? row.orders.length > 0 : row.state === filter.state)),
  );
}

// How many tables are in each state, for the filter chips.
export function countStates(tables: BoardTable[]): Record<TableState, number> {
  const counts = Object.fromEntries(TABLE_STATES.map((state) => [state, 0])) as Record<
    TableState,
    number
  >;
  for (const row of tables) counts[row.state] += 1;
  return counts;
}

// i18n key of a table state; the colour is never the only signal.
export function tableStateKey(state: TableState): string {
  return `tableState_${state}`;
}

// Whether a table placed at `placement` stays inside the area's grid, as the
// server checks it (`resource_outside_area`): its box before rotation.
export function fitsArea(
  placement: Placement,
  area: Pick<FloorArea, 'floor_width' | 'floor_height'>,
): boolean {
  return (
    placement.x >= 0 &&
    placement.y >= 0 &&
    placement.x + placement.w <= area.floor_width &&
    placement.y + placement.h <= area.floor_height
  );
}

// Keeps a dragged table on the grid: whole cells, inside the area.
export function clampPlacement(
  placement: Placement,
  area: Pick<FloorArea, 'floor_width' | 'floor_height'>,
): Placement {
  const w = Math.min(Math.max(1, Math.round(placement.w)), area.floor_width);
  const h = Math.min(Math.max(1, Math.round(placement.h)), area.floor_height);
  return {
    ...placement,
    w,
    h,
    x: Math.min(Math.max(0, Math.round(placement.x)), area.floor_width - w),
    y: Math.min(Math.max(0, Math.round(placement.y)), area.floor_height - h),
  };
}

// How close a buffet table is to its time: `ending` in the last 10 minutes
// (yellow), `over` once past it (red). Read on the server's clock.
export type BuffetTiming = 'none' | 'running' | 'ending' | 'over';

export const BUFFET_ENDING_MINUTES = 10;

export function buffetTiming(
  endsAt: string | null | undefined,
  now: string | null | undefined,
): BuffetTiming {
  if (!endsAt || !now) return 'none';
  const end = Date.parse(endsAt);
  const at = Date.parse(now);
  if (Number.isNaN(end) || Number.isNaN(at)) return 'none';
  if (at >= end) return 'over';
  return end - at <= BUFFET_ENDING_MINUTES * 60_000 ? 'ending' : 'running';
}

// Whole minutes left (negative once over), for the tile's countdown.
export function buffetMinutesLeft(
  endsAt: string | null | undefined,
  now: string | null | undefined,
): number | null {
  if (!endsAt || !now) return null;
  const left = Date.parse(endsAt) - Date.parse(now);
  return Number.isNaN(left) ? null : Math.floor(left / 60_000);
}

// --- The table board of the table-service selling screen --------------------

// The five backgrounds a table tile can have. Everything else a table needs
// to say (a late kitchen, a long stay, a booking) is a strip or a corner
// icon, so the colours stay few enough to read across the room.
export const BOARD_TONES = ['free', 'serving', 'unsent', 'prebilled', 'payment'] as const;
export type BoardTone = (typeof BOARD_TONES)[number];

export const BOARD_CHIPS = ['all', 'in_use', 'free', 'attention'] as const;
export type BoardChip = (typeof BOARD_CHIPS)[number];

export type BoardOptions = {
  // Minutes a table may stay seated before it is flagged; null turns it off.
  alertMinutes?: number | null;
  // The branch sends dishes to a kitchen (`fnb.kitchen`); without one no
  // dish is ever "unsent".
  kitchen?: boolean;
  // Now on the server's clock (milliseconds), to count a room's clock down;
  // without it only the server's own flags say a room ends soon.
  now?: number;
};

// Dishes on the table's orders wait to be sent to the kitchen, after a first
// send too. A server that does not count them per order leaves only a guess:
// dishes are on the table and nothing reached the kitchen yet.
function unsent(table: BoardTable, kitchen: boolean): boolean {
  if (!kitchen) return false;
  if (table.orders.every((order) => order.unsent_kitchen_items !== null))
    return table.orders.some((order) => (order.unsent_kitchen_items ?? 0) > 0);
  return table.state === 'occupied' && Number(table.subtotal ?? 0) > 0;
}

// The background of a table's tile, the strongest need first: the bill was
// asked for, the pre-bill is out, dishes wait to be sent, or it is served.
export function tileTone(table: BoardTable, options: BoardOptions = {}): BoardTone {
  if (table.orders.length === 0) return 'free';
  if (
    table.payment_requested ||
    table.state === 'payment_requested' ||
    table.orders.some((order) => order.payment_requested)
  )
    return 'payment';
  if (table.state === 'prebilled' || table.orders.some((order) => order.prebilled))
    return 'prebilled';
  return unsent(table, options.kitchen ?? true) ? 'unsent' : 'serving';
}

// The red strip: seated past the branch's threshold, or a sent dish waited
// past its station's limit.
export function tileAlert(table: BoardTable, options: BoardOptions = {}): boolean {
  if (table.orders.length === 0) return false;
  if (table.state === 'waiting_long') return true;
  const limit = options.alertMinutes;
  return (
    typeof limit === 'number' &&
    limit > 0 &&
    table.seated_minutes !== null &&
    table.seated_minutes >= limit
  );
}

// Why someone should go to the table now: the bill was asked for, dishes
// wait to be sent, the guests stayed long or the kitchen is late, or its
// clock (a room, or a billiard table in a restaurant) is about to end, has
// ended or was paused too long. Each reason is said in words on a room tile.
export const ATTENTION_REASONS = ['payment', 'unsent', 'long', 'clock'] as const;
export type AttentionReason = (typeof ATTENTION_REASONS)[number];

export function attentionReasons(table: BoardTable, options: BoardOptions = {}): AttentionReason[] {
  const tone = tileTone(table, options);
  const reasons: AttentionReason[] = [];
  if (tone === 'payment') reasons.push('payment');
  if (tone === 'unsent') reasons.push('unsent');
  if (tileAlert(table, options)) reasons.push('long');
  if (clockAttention(table, options.now)) reasons.push('clock');
  return reasons;
}

export function needsAttention(table: BoardTable, options: BoardOptions = {}): boolean {
  return attentionReasons(table, options).length > 0;
}

// Whether a table shows under a filter chip. Free is ready for guests: no
// order, and neither being cleaned nor out of service.
export function inBoardChip(
  table: BoardTable,
  chip: BoardChip,
  options: BoardOptions = {},
): boolean {
  switch (chip) {
    case 'in_use':
      return table.orders.length > 0;
    case 'free':
      return (
        table.orders.length === 0 && (table.state === 'available' || table.state === 'reserved')
      );
    case 'attention':
      return needsAttention(table, options);
    default:
      return true;
  }
}

// How many tables each filter chip holds.
export function boardCounts(
  tables: BoardTable[],
  options: BoardOptions = {},
): Record<BoardChip, number> {
  const counts = { all: 0, in_use: 0, free: 0, attention: 0 };
  for (const row of tables)
    for (const chip of BOARD_CHIPS) if (inBoardChip(row, chip, options)) counts[chip] += 1;
  return counts;
}

// --- Timed rooms (`timed_billing`) on the board ------------------------------

// The backgrounds of a timed room: free, its clock counting, its end in the
// last ten minutes (amber), past its end (red, blinking), paused (grey),
// guests on its order with no clock counting (stopped and not paid yet, or
// never started), or empty and not ready for guests: being cleaned or out of
// service. Each is also said in words on the tile.
export const ROOM_TONES = [
  'free',
  'running',
  'ending',
  'over',
  'paused',
  'idle',
  'cleaning',
  'out_of_service',
] as const;
export type RoomTone = (typeof ROOM_TONES)[number];

// A room's clock turns amber this many seconds before its end, as the
// server flags it (`ending_soon`).
export const ROOM_ENDING_SECONDS = 10 * 60;

// The tone of a room's clock at `now` (server clock, milliseconds). The
// server's flags count as well as the countdown, so a board read without a
// clock of its own still shows a room ending soon or past its package.
export function roomTone(table: BoardTable, now?: number): RoomTone {
  const timed = table.timed;
  if (timed?.status === 'paused') return 'paused';
  if (timed?.status === 'running') {
    const left = now === undefined ? null : clockSecondsLeft(timed, now);
    if (timed.package_ended || (left !== null && left <= 0)) return 'over';
    if (timed.ending_soon || (left !== null && left <= ROOM_ENDING_SECONDS)) return 'ending';
    return 'running';
  }
  if (table.orders.length > 0) return 'idle';
  if (table.state === 'cleaning' || table.state === 'out_of_service') return table.state;
  return 'free';
}

// A room's clock needs someone now: it ends within ten minutes, has ended,
// or was paused longer than the branch allows.
export function clockAttention(table: BoardTable, now?: number): boolean {
  if (table.timed?.status === 'paused' && table.timed.pause_too_long) return true;
  const tone = roomTone(table, now);
  return tone === 'ending' || tone === 'over';
}
