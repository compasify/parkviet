import { parseVndInput } from '@parkviet/pos-shared/money'
import {
  clampPlacement,
  type FloorArea,
  fitsArea,
  type Placement,
  type ResourceRecord,
} from '@parkviet/pos-shared/tables'

type Floor = Pick<FloorArea, 'floor_width' | 'floor_height'>

// The server's bounds for an area's grid and a table on it.
export const FLOOR_MIN = 4
export const FLOOR_MAX = 200
export const TABLE_SIZE_MAX = 50
export const CAPACITY_MAX = 999
export const SERVICE_CHARGE_MAX = 50

const bounded = (value: number, low: number, high: number) =>
  Math.min(Math.max(low, value), Math.max(low, high))

// A table moved (or resized from its bottom-right corner) by whole cells,
// kept inside the area. Resizing never moves the table; it stops at the edge.
export function shiftPlacement(
  start: Placement,
  cells: { dx: number; dy: number },
  mode: 'move' | 'resize',
  area: Floor,
): Placement {
  const dx = Math.round(cells.dx)
  const dy = Math.round(cells.dy)
  if (mode === 'move') return clampPlacement({ ...start, x: start.x + dx, y: start.y + dy }, area)
  return clampPlacement(
    {
      ...start,
      w: bounded(start.w + dx, 1, Math.min(TABLE_SIZE_MAX, area.floor_width - start.x)),
      h: bounded(start.h + dy, 1, Math.min(TABLE_SIZE_MAX, area.floor_height - start.y)),
    },
    area,
  )
}

const ARROWS: Record<string, { dx: number; dy: number }> = {
  ArrowLeft: { dx: -1, dy: 0 },
  ArrowRight: { dx: 1, dy: 0 },
  ArrowUp: { dx: 0, dy: -1 },
  ArrowDown: { dx: 0, dy: 1 },
}

// Keyboard alternative to dragging: arrows move a table one cell, with Shift
// they resize it. Null for any other key.
export function nudgePlacement(
  start: Placement,
  key: string,
  resize: boolean,
  area: Floor,
): Placement | null {
  const step = ARROWS[key]
  return step ? shiftPlacement(start, step, resize ? 'resize' : 'move', area) : null
}

const overlaps = (left: Placement, right: Placement) =>
  left.x < right.x + right.w &&
  right.x < left.x + left.w &&
  left.y < right.y + right.h &&
  right.y < left.y + left.h

// The floor large enough to hold every table, and at least the area's current
// size, never past the server's maximum.
export function floorSpan(tables: readonly Placement[], area: Floor): Floor {
  let floor_width = area.floor_width
  let floor_height = area.floor_height
  for (const table of tables) {
    floor_width = Math.max(floor_width, table.x + table.w)
    floor_height = Math.max(floor_height, table.y + table.h)
  }
  return {
    floor_width: Math.min(FLOOR_MAX, floor_width),
    floor_height: Math.min(FLOOR_MAX, floor_height),
  }
}

// The rectangle dragged from one cell to another, at least one cell each way.
export function rectanglePlacement(
  origin: { x: number; y: number },
  current: { x: number; y: number },
): Placement {
  return {
    x: Math.min(origin.x, current.x),
    y: Math.min(origin.y, current.y),
    w: Math.abs(current.x - origin.x) + 1,
    h: Math.abs(current.y - origin.y) + 1,
    rotation: 0,
  }
}

// Where a new table of `w` × `h` cells goes: the first spot, row by row, that
// no table of the area covers; the top-left corner when the floor is full.
export function freeSpot(taken: readonly Placement[], area: Floor, w: number, h: number) {
  const size = { w: Math.min(w, area.floor_width), h: Math.min(h, area.floor_height) }
  for (let y = 0; y + size.h <= area.floor_height; y += 1)
    for (let x = 0; x + size.w <= area.floor_width; x += 1) {
      const spot = { x, y, ...size, rotation: 0 }
      if (!taken.some((other) => overlaps(spot, other))) return spot
    }
  return { x: 0, y: 0, ...size, rotation: 0 }
}

// What the table form edits; numbers stay text while typed.
export type TableDraft = {
  id?: string
  name: string
  kind: ResourceRecord['kind']
  capacity: string
  shape: ResourceRecord['shape']
  x: string
  y: string
  w: string
  h: string
  rotation: string
  // Whole VND; blank for no minimum spend.
  minimumSpend: string
}

export const tableDraftOf = (row: ResourceRecord): TableDraft => ({
  id: row.id,
  name: row.name,
  kind: row.kind,
  capacity: String(row.capacity),
  shape: row.shape,
  x: String(row.x),
  y: String(row.y),
  w: String(row.w),
  h: String(row.h),
  rotation: String(row.rotation),
  minimumSpend: row.minimum_spend ?? '',
})

export const placementDraft = (placement: Placement) => ({
  x: String(placement.x),
  y: String(placement.y),
  w: String(placement.w),
  h: String(placement.h),
  rotation: String(placement.rotation),
})

const whole = (value: string) => {
  const text = value.trim()
  return /^\d+$/.test(text) ? Number(text) : null
}

export type TableProblem =
  | 'name'
  | 'capacity'
  | 'size'
  | 'position'
  | 'rotation'
  | 'outside'
  | 'minimumSpend'

export type TableValues = Placement & {
  name: string
  kind: ResourceRecord['kind']
  capacity: number
  shape: ResourceRecord['shape']
  minimum_spend: string | null
}

// The draft as the server takes it, or the first rule it breaks.
export function readTableDraft(
  draft: TableDraft,
  area: Floor,
): { values: TableValues } | { problem: TableProblem } {
  const name = draft.name.trim()
  if (!name || name.length > 40) return { problem: 'name' }
  const capacity = whole(draft.capacity)
  if (capacity === null || capacity > CAPACITY_MAX) return { problem: 'capacity' }
  const [x, y, w, h, rotation] = [draft.x, draft.y, draft.w, draft.h, draft.rotation].map(whole)
  if (w === null || h === null || w < 1 || h < 1 || w > TABLE_SIZE_MAX || h > TABLE_SIZE_MAX)
    return { problem: 'size' }
  if (x === null || y === null) return { problem: 'position' }
  if (rotation === null || rotation > 359) return { problem: 'rotation' }
  const placement = { x, y, w, h, rotation }
  if (!fitsArea(placement, area)) return { problem: 'outside' }
  const minimum = draft.minimumSpend.trim()
  const minimumSpend = minimum ? parseVndInput(minimum) : null
  if (minimum && (minimumSpend === null || minimumSpend === '0')) return { problem: 'minimumSpend' }
  return {
    values: {
      name,
      kind: draft.kind,
      capacity,
      shape: draft.shape,
      ...placement,
      minimum_spend: minimumSpend,
    },
  }
}

// The fields of a saved table that the draft changes, for PATCH.
export function changedFields(row: ResourceRecord, values: TableValues) {
  return Object.fromEntries(
    (Object.keys(values) as (keyof TableValues)[])
      .filter((key) => (row[key] ?? null) !== values[key])
      .map((key) => [key, values[key]]),
  ) as Partial<TableValues>
}

// An area's grid size typed in the form, or null when outside the bounds.
export function readFloorSize(value: string): number | null {
  const size = whole(value)
  return size !== null && size >= FLOOR_MIN && size <= FLOOR_MAX ? size : null
}

// Tables of an area that a smaller grid would leave outside it.
export const tablesOutside = (tables: readonly ResourceRecord[], area: Floor) =>
  tables.filter((row) => !fitsArea(row, area))

// The service charge percent as typed: blank clears it (null); otherwise a
// number above 0 and at most 50 with up to two decimals, as the server stores
// it. Undefined when it is not one.
export function readServiceChargeRate(value: string): string | null | undefined {
  const text = value.trim().replace(',', '.')
  if (!text) return null
  if (!/^\d{1,2}(\.\d{1,2})?$/.test(text)) return undefined
  const rate = Number(text)
  return rate > 0 && rate <= SERVICE_CHARGE_MAX ? text : undefined
}

// How many days a guest's bottle is kept, as typed: 1 to 3650. Null when
// blank (keep the saved value); undefined when it is not a number of days.
export const BOTTLE_KEEP_DAYS_MAX = 3650
export function readKeepDays(value: string): number | null | undefined {
  const text = value.trim()
  if (!text) return null
  if (!/^\d{1,4}$/.test(text)) return undefined
  const days = Number(text)
  return days >= 1 && days <= BOTTLE_KEEP_DAYS_MAX ? days : undefined
}

// How long a table may stay seated before the floor flags it, as typed: 10
// to 600 minutes. Null when blank (the alert is off); undefined when it is not
// a number of minutes in range.
export const SEATED_ALERT_MIN = 10
export const SEATED_ALERT_MAX = 600
export function readSeatedAlertMinutes(value: string): number | null | undefined {
  const text = value.trim()
  if (!text) return null
  if (!/^\d{1,3}$/.test(text)) return undefined
  const minutes = Number(text)
  return minutes >= SEATED_ALERT_MIN && minutes <= SEATED_ALERT_MAX ? minutes : undefined
}

// The amount up to which a guest's QR order goes straight to the kitchen, as
// typed in đồng ("500.000" or "500000"). Null when blank; undefined when it
// is not a whole positive amount.
export function readQrLimit(value: string): string | null | undefined {
  const text = value.trim().replace(/[.,\s]/g, '')
  if (!text) return null
  if (!/^\d{1,12}$/.test(text)) return undefined
  return Number(text) > 0 ? String(Number(text)) : undefined
}

// How many items such an order may hold: 1 to 50.
export const QR_MAX_ITEMS = 50
export function readQrMaxItems(value: string): number | undefined {
  const text = value.trim()
  if (!/^\d{1,2}$/.test(text)) return undefined
  const count = Number(text)
  return count >= 1 && count <= QR_MAX_ITEMS ? count : undefined
}
