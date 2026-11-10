import { describe, expect, it } from 'vitest'
import { posContextKey, posKey } from './query-keys'
import { createSubmissionKey } from './submission-key'

describe('store and branch scoped keys', () => {
  it('isolates stores and registers without dropping the resource prefix', () => {
    expect(posKey('store-a', 'topology', 'branches')).toEqual([
      'pos',
      'store-a',
      'topology',
      'branches',
    ])
    const selection = { branchId: 'b', registerId: null }
    expect(posContextKey('a', selection)).not.toEqual(posContextKey('b', selection))
    expect(posContextKey('a', selection)).not.toEqual(
      posContextKey('a', { ...selection, registerId: 'r' }),
    )
  })
  it('reuses a submission key until its content changes or the server confirms', () => {
    let index = 0
    const submission = createSubmissionKey(() => String(++index))
    expect(submission.keyFor('payload')).toBe('1')
    expect(submission.keyFor('payload')).toBe('1')
    submission.settle('other')
    expect(submission.keyFor('payload')).toBe('1')
    submission.settle('payload')
    expect(submission.keyFor('payload')).toBe('2')
  })
})
