import { describe, expect, it } from 'vitest'
import {
  adjustmentCommandBody,
  countBody,
  quantity,
  tableMeta,
  todayIn,
  transferBody,
  variantLabel,
} from './inventory-helpers'

const lot = { tracked_mode: 'lot' as const }
const serial = { tracked_mode: 'serial' as const }

describe('labels', () => {
  it('shows a quantity with its unit and a dash when unknown', () => {
    expect(quantity(3, 'hộp')).toBe('3 hộp')
    expect(quantity(0, undefined)).toBe('0')
    expect(quantity(null, 'cái')).toBe('—')
  })

  it('names a variant with its SKU when it has one', () => {
    expect(variantLabel({ name: 'Sữa chua', sku: 'SUA-1' })).toBe('Sữa chua · SUA-1')
    expect(variantLabel({ name: 'Sữa chua', sku: '' })).toBe('Sữa chua')
  })

  it('reads the calendar day where the branch trades', () => {
    const late = new Date('2026-11-10T18:30:00Z')
    expect(todayIn('Asia/Ho_Chi_Minh', late)).toBe('2026-11-11')
    expect(todayIn('UTC', late)).toBe('2026-11-10')
    expect(todayIn('Not/AZone', late)).toBe('2026-11-10')
  })
})

describe('tableMeta', () => {
  it('fills the row range and neighbours from the server page', () => {
    expect(tableMeta({ page: 2, pages: 3, count: 60 }, 25, 25)).toEqual({
      page: 2,
      limit: 25,
      count: 60,
      pages: 3,
      from: 26,
      to: 50,
      previous: 1,
      next: 3,
    })
  })

  it('treats a missing or empty meta as one empty page', () => {
    expect(tableMeta(undefined, 0, 50)).toMatchObject({
      page: 1,
      pages: 1,
      count: 0,
      from: 0,
      to: 0,
      previous: null,
      next: null,
    })
  })
})

describe('transferBody', () => {
  it('needs a variant', () => {
    expect(transferBody(null, '', {}, [])).toEqual({ error: 'inventoryVariantRequired' })
  })

  it('sends the scanned serials and refuses repeats', () => {
    expect(transferBody(serial, 'A1\nA2\n', {}, [])).toEqual({ body: { serials: ['A1', 'A2'] } })
    expect(transferBody(serial, 'A1\nA1', {}, [])).toMatchObject({
      error: 'inventorySerialDuplicate',
      options: { codes: 'A1' },
    })
    expect(transferBody(serial, '  ', {}, [])).toEqual({ error: 'inventoryNothingEntered' })
  })

  it('sends whole amounts of lots, never more than a lot has available', () => {
    const lots = [
      { id: 'lot_1', available: 4 },
      { id: 'lot_2', available: 2 },
    ]
    expect(transferBody(lot, '', { lot_1: '3', lot_2: '' }, lots)).toEqual({
      body: { lots: [{ lot_id: 'lot_1', quantity: 3 }] },
    })
    expect(transferBody(lot, '', { lot_1: '5' }, lots)).toEqual({
      error: 'inventoryQuantityTooMany',
    })
    expect(transferBody(lot, '', { lot_1: '1.5' }, lots)).toEqual({
      error: 'inventoryQuantityInvalid',
    })
    expect(transferBody(lot, '', {}, lots)).toEqual({ error: 'inventoryNothingEntered' })
  })

  it('keeps amounts typed for lots the filter hides', () => {
    expect(transferBody(lot, '', { lot_hidden: '2' }, [])).toEqual({
      body: { lots: [{ lot_id: 'lot_hidden', quantity: 2 }] },
    })
  })
})

describe('countBody', () => {
  it('needs a variant and a reason', () => {
    expect(countBody(null, 'x', {}, '', '')).toEqual({ error: 'inventoryVariantRequired' })
    expect(countBody(lot, ' ', {}, '', '')).toEqual({ error: 'inventoryReasonRequired' })
  })

  it('states each counted lot whole, with its held units when given', () => {
    expect(
      countBody(
        lot,
        'Đếm lại',
        {
          lot_1: { counted: '3', quarantined: '' },
          lot_2: { counted: '0', quarantined: '1' },
          lot_3: { counted: '', quarantined: '' },
        },
        '',
        '',
      ),
    ).toEqual({
      body: {
        lots: [
          { lot_id: 'lot_1', counted: 3 },
          { lot_id: 'lot_2', counted: 0, counted_quarantined: 1 },
        ],
      },
    })
    expect(countBody(lot, 'r', { lot_1: { counted: '', quarantined: '1' } }, '', '')).toEqual({
      error: 'inventoryCountRequired',
    })
    expect(countBody(lot, 'r', { lot_1: { counted: '-1', quarantined: '' } }, '', '')).toEqual({
      error: 'inventoryQuantityInvalid',
    })
  })

  it('names missing and found serials, never the same one in both', () => {
    expect(countBody(serial, 'r', {}, 'A1', 'B1')).toEqual({
      body: { missing_serials: ['A1'], found_serials: ['B1'] },
    })
    expect(countBody(serial, 'r', {}, 'A1', '')).toEqual({ body: { missing_serials: ['A1'] } })
    expect(countBody(serial, 'r', {}, 'A1', 'A1')).toEqual({
      error: 'traceReason_duplicate_serial',
    })
    expect(countBody(serial, 'r', {}, '', '')).toEqual({ error: 'inventoryNothingEntered' })
  })
})

describe('adjustmentCommandBody', () => {
  const approval = { id: 'appr_1', status: 'active', expires_at: '2026-11-10T05:00:00Z' }
  it('applies with the active approval and approves with nothing', () => {
    expect(adjustmentCommandBody({ approval }, 'apply')).toEqual({ approval_id: 'appr_1' })
    expect(adjustmentCommandBody({ approval }, 'approve')).toEqual({})
    expect(adjustmentCommandBody({ approval: null }, 'apply')).toEqual({})
    expect(
      adjustmentCommandBody({ approval: { ...approval, status: 'expired' } }, 'apply'),
    ).toEqual({})
  })
})
