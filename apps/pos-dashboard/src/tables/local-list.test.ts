import { describe, expect, it } from 'vitest'
import { localList } from './local-list'

const rows = [
  { id: 'b1', name: 'Quận 3', code: 'q3', status: 'active', branch_id: 'x' },
  { id: 'b2', name: 'Bình Thạnh', code: 'bt', status: 'disabled', branch_id: 'y' },
  { id: 'b3', name: 'An Phú', code: 'ap', status: 'active', branch_id: 'y' },
]
const options = {
  searchParam: 'search',
  text: (row: (typeof rows)[number]) => `${row.name} ${row.code}`,
}

describe('localList', () => {
  it('searches, filters with Ransack predicates and sorts', () => {
    expect(localList(rows, { search: 'BT' }, options).data.map((r) => r.id)).toEqual(['b2'])
    expect(
      localList(rows, { status_in: ['active'], sort: 'name' }, options).data.map((r) => r.id),
    ).toEqual(['b3', 'b1'])
    expect(localList(rows, { branch_id_not_eq: 'y' }, options).data.map((r) => r.id)).toEqual([
      'b1',
    ])
    expect(localList(rows, { sort: '-name' }, options).data.map((r) => r.id)).toEqual([
      'b1',
      'b2',
      'b3',
    ])
  })

  it('sorts by the display value while filtering by the raw one', () => {
    const names: Record<string, string> = { x: 'Zeta', y: 'Alpha' }
    const result = localList(
      rows,
      { sort: 'branch_id', branch_id_in: ['x', 'y'] },
      {
        ...options,
        sortValue: (row, field) => (field === 'branch_id' ? names[row.branch_id] : undefined),
      },
    )
    expect(result.data.map((r) => r.id)).toEqual(['b2', 'b3', 'b1'])
  })

  it('pages and clamps an out-of-range page', () => {
    const result = localList(rows, { limit: 2, page: 9 }, options)
    expect(result.data.map((r) => r.id)).toEqual(['b3'])
    expect(result.meta).toEqual({
      page: 2,
      limit: 2,
      count: 3,
      pages: 2,
      from: 3,
      to: 3,
      previous: 1,
      next: null,
    })
    expect(localList([], {}, options).meta).toMatchObject({ page: 1, pages: 1, from: 0, to: 0 })
  })
})
