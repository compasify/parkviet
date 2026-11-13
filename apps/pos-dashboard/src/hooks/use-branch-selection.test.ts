import type { PosBranch } from '@parkviet/pos-shared/types/pos-context'
import { describe, expect, it } from 'vitest'
import { resolveBranchSelection } from './use-branch-selection'

const branches = [{ id: 'a' }, { id: 'b' }] as PosBranch[]
describe('URL branch selection', () => {
  it('uses the requested visible branch and register', () => {
    expect(resolveBranchSelection({ branch: 'b', register: 'r' }, branches)).toEqual({
      branchId: 'b',
      registerId: 'r',
    })
  })
  it('defaults to the first visible branch and clears a stale register', () => {
    expect(resolveBranchSelection({ branch: 'hidden', register: 'r' }, branches)).toEqual({
      branchId: 'a',
      registerId: null,
    })
    expect(resolveBranchSelection({}, [])).toEqual({ branchId: null, registerId: null })
  })
  it('falls back to the last used branch before the first one', () => {
    expect(resolveBranchSelection({}, branches, 'b')).toEqual({ branchId: 'b', registerId: null })
    expect(resolveBranchSelection({ branch: 'a' }, branches, 'b').branchId).toBe('a')
    expect(resolveBranchSelection({}, branches, 'gone').branchId).toBe('a')
  })
})
