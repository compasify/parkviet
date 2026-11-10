import { describe, expect, it } from 'vitest'
import { dayRange, pageParams } from './table-params'

describe('table parameters for day-ranged POS lists', () => {
  it('reads the quick date filter bounds as whole branch days', () => {
    expect(
      dayRange(
        { placed_at_gteq: '2026-11-01', placed_at_lteq: '2026-11-10 23:59:59.999999' },
        'placed_at',
      ),
    ).toEqual({ from: '2026-11-01', to: '2026-11-10' })
  })
  it('turns a strict upper bound into the previous day and eq into one day', () => {
    expect(dayRange({ placed_at_lt: '2026-03-01' }, 'placed_at')).toEqual({ to: '2026-02-28' })
    expect(dayRange({ placed_at_eq: '2026-11-05' }, 'placed_at')).toEqual({
      from: '2026-11-05',
      to: '2026-11-05',
    })
  })
  it('keeps the narrowest range and ignores malformed or other fields', () => {
    expect(
      dayRange(
        { placed_at_gteq: '2026-11-01', placed_at_gt: '2026-11-03', placed_at_lteq: 'soon' },
        'placed_at',
      ),
    ).toEqual({ from: '2026-11-03' })
    expect(dayRange({ created_at_gteq: '2026-11-01' }, 'placed_at')).toEqual({})
  })
  it('bounds page and limit to what the server accepts', () => {
    expect(pageParams({})).toEqual({ page: '1', limit: '25' })
    expect(pageParams({ page: 3, limit: 500 })).toEqual({ page: '3', limit: '100' })
  })
})
