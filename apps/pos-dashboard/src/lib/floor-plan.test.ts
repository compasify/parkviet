import type { ResourceRecord } from '@parkviet/pos-shared/tables'
import { describe, expect, it } from 'vitest'
import {
  changedFields,
  freeSpot,
  nudgePlacement,
  readFloorSize,
  readKeepDays,
  readQrLimit,
  readQrMaxItems,
  readServiceChargeRate,
  readTableDraft,
  shiftPlacement,
  type TableDraft,
  tableDraftOf,
  tablesOutside,
} from './floor-plan'

const area = { floor_width: 10, floor_height: 6 }
const start = { x: 2, y: 1, w: 2, h: 2, rotation: 0 }
const table: ResourceRecord = {
  id: 'posres_1',
  branch_id: 'b',
  area_id: 'a',
  kind: 'table',
  name: 'T1',
  capacity: 4,
  shape: 'rect',
  ...start,
  manual_status: 'available',
  resource_type_code: null,
  status: 'active',
  position: 0,
}

describe('floor plan placement', () => {
  it('moves a table by whole cells and keeps it on the floor', () => {
    expect(shiftPlacement(start, { dx: 1.4, dy: 2.6 }, 'move', area)).toMatchObject({ x: 3, y: 4 })
    expect(shiftPlacement(start, { dx: 20, dy: -5 }, 'move', area)).toMatchObject({
      x: 8,
      y: 0,
      w: 2,
      h: 2,
    })
  })
  it('resizes from the corner without moving the table, stopping at the edge', () => {
    expect(shiftPlacement(start, { dx: 3, dy: 1 }, 'resize', area)).toMatchObject({
      x: 2,
      y: 1,
      w: 5,
      h: 3,
    })
    expect(shiftPlacement(start, { dx: 40, dy: 40 }, 'resize', area)).toMatchObject({
      x: 2,
      y: 1,
      w: 8,
      h: 5,
    })
    expect(shiftPlacement(start, { dx: -9, dy: -9 }, 'resize', area)).toMatchObject({ w: 1, h: 1 })
  })
  it('moves with arrows, resizes with Shift and ignores other keys', () => {
    expect(nudgePlacement(start, 'ArrowRight', false, area)).toMatchObject({ x: 3, y: 1, w: 2 })
    expect(nudgePlacement(start, 'ArrowDown', true, area)).toMatchObject({ x: 2, y: 1, h: 3 })
    expect(nudgePlacement({ ...start, x: 0 }, 'ArrowLeft', false, area)).toMatchObject({ x: 0 })
    expect(nudgePlacement(start, 'Enter', false, area)).toBeNull()
  })
  it('places a new table on the first free cells', () => {
    expect(freeSpot([], area, 2, 2)).toMatchObject({ x: 0, y: 0 })
    expect(freeSpot([{ x: 0, y: 0, w: 3, h: 2, rotation: 0 }], area, 2, 2)).toMatchObject({
      x: 3,
      y: 0,
    })
    const full = [{ x: 0, y: 0, w: 10, h: 6, rotation: 0 }]
    expect(freeSpot(full, area, 2, 2)).toMatchObject({ x: 0, y: 0, w: 2, h: 2 })
  })
  it('finds the tables a smaller grid would leave out', () => {
    expect(tablesOutside([table], { floor_width: 4, floor_height: 6 })).toEqual([])
    expect(tablesOutside([table], { floor_width: 3, floor_height: 6 })).toEqual([table])
  })
})

describe('floor plan forms', () => {
  const draft = (patch: Partial<TableDraft>): TableDraft => ({ ...tableDraftOf(table), ...patch })
  it('reads a valid table and names the first broken rule', () => {
    expect(readTableDraft(draft({ name: ' T2 ' }), area)).toEqual({
      values: {
        name: 'T2',
        kind: 'table',
        capacity: 4,
        shape: 'rect',
        ...start,
        minimum_spend: null,
      },
    })
    expect(readTableDraft(draft({ minimumSpend: '1.500.000' }), area)).toMatchObject({
      values: { minimum_spend: '1500000' },
    })
    expect(readTableDraft(draft({ minimumSpend: '0' }), area)).toEqual({ problem: 'minimumSpend' })
    expect(readTableDraft(draft({ minimumSpend: 'abc' }), area)).toEqual({
      problem: 'minimumSpend',
    })
    expect(readTableDraft(draft({ name: '  ' }), area)).toEqual({ problem: 'name' })
    expect(readTableDraft(draft({ name: 'x'.repeat(41) }), area)).toEqual({ problem: 'name' })
    expect(readTableDraft(draft({ capacity: '1000' }), area)).toEqual({ problem: 'capacity' })
    expect(readTableDraft(draft({ capacity: '-1' }), area)).toEqual({ problem: 'capacity' })
    expect(readTableDraft(draft({ w: '0' }), area)).toEqual({ problem: 'size' })
    expect(readTableDraft(draft({ h: '51' }), area)).toEqual({ problem: 'size' })
    expect(readTableDraft(draft({ x: '1.5' }), area)).toEqual({ problem: 'position' })
    expect(readTableDraft(draft({ rotation: '360' }), area)).toEqual({ problem: 'rotation' })
    expect(readTableDraft(draft({ x: '9' }), area)).toEqual({ problem: 'outside' })
  })
  it('sends only the changed fields of a saved table', () => {
    const read = readTableDraft(draft({ x: '4', capacity: '6' }), area)
    if (!('values' in read)) throw new Error('expected values')
    expect(changedFields(table, read.values)).toEqual({ x: 4, capacity: 6 })
    expect(changedFields(table, { ...read.values, x: 2, capacity: 4 })).toEqual({})
    expect(
      changedFields(table, { ...read.values, x: 2, capacity: 4, minimum_spend: '500000' }),
    ).toEqual({
      minimum_spend: '500000',
    })
  })
  it('reads the days a kept bottle is held', () => {
    expect(readKeepDays('')).toBeNull()
    expect(readKeepDays('30')).toBe(30)
    expect(readKeepDays('0')).toBeUndefined()
    expect(readKeepDays('3651')).toBeUndefined()
    expect(readKeepDays('1.5')).toBeUndefined()
  })
  it('accepts grid sizes between 4 and 200 cells', () => {
    expect(readFloorSize('24')).toBe(24)
    expect(readFloorSize('3')).toBeNull()
    expect(readFloorSize('201')).toBeNull()
    expect(readFloorSize('abc')).toBeNull()
  })
  it('reads the service charge percent', () => {
    expect(readServiceChargeRate('')).toBeNull()
    expect(readServiceChargeRate('5')).toBe('5')
    expect(readServiceChargeRate('7,5')).toBe('7.5')
    expect(readServiceChargeRate('50')).toBe('50')
    expect(readServiceChargeRate('0')).toBeUndefined()
    expect(readServiceChargeRate('50.01')).toBeUndefined()
    expect(readServiceChargeRate('5.123')).toBeUndefined()
    expect(readServiceChargeRate('ten')).toBeUndefined()
  })
})

describe('QR order limits', () => {
  it('reads an amount in đồng with or without thousand separators', () => {
    expect(readQrLimit('')).toBeNull()
    expect(readQrLimit('500.000')).toBe('500000')
    expect(readQrLimit(' 1,200,000 ')).toBe('1200000')
    expect(readQrLimit('0')).toBeUndefined()
    expect(readQrLimit('-5')).toBeUndefined()
    expect(readQrLimit('abc')).toBeUndefined()
  })

  it('takes 1 to 50 items', () => {
    expect(readQrMaxItems('10')).toBe(10)
    expect(readQrMaxItems('50')).toBe(50)
    expect(readQrMaxItems('0')).toBeUndefined()
    expect(readQrMaxItems('51')).toBeUndefined()
    expect(readQrMaxItems('')).toBeUndefined()
  })
})
