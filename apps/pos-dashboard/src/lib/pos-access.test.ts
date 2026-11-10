import type { PosContext } from '@parkviet/pos-shared/types/pos-context'
import { describe, expect, it } from 'vitest'
import { canAdminister, canManageBranch, visibleNav } from './pos-access'

describe('POS permission gates', () => {
  it('allows a store owner to administer and manage any branch', () => {
    const access = { permissionKeys: ['write_pos_topology'] }
    expect(canAdminister(access, true)).toBe(true)
    expect(canManageBranch(access, 'other')).toBe(true)
    expect(visibleNav('receipt-templates', access)).toBe(true)
  })
  it('preserves read-only access without write authority', () => {
    const access = { permissionKeys: ['read_pos_topology'] }
    expect(visibleNav('branches', access)).toBe(true)
    expect(visibleNav('features', access)).toBe(true)
    expect(canAdminister(access, true)).toBe(false)
    expect(canManageBranch(access, 'b')).toBe(false)
    expect(visibleNav('setup', access)).toBe(false)
  })
  it('allows a branch manager only their current branch features and model', () => {
    const access = {
      permissionKeys: [],
      context: {
        selection: { branch_id: 'b', register_id: null },
        capabilities: ['pos.topology.manage'],
      } as PosContext,
    }
    expect(visibleNav('features', access)).toBe(true)
    expect(visibleNav('business-model', access)).toBe(true)
    expect(visibleNav('branches', access)).toBe(false)
    expect(visibleNav('receipt-templates', access)).toBe(false)
    expect(canManageBranch(access, 'other')).toBe(false)
    expect(canManageBranch(access, null)).toBe(false)
  })
  it('fails closed before permissions/context arrive', () => {
    expect(visibleNav('features', { permissionKeys: [] })).toBe(false)
    expect(visibleNav('branches', { permissionKeys: [] })).toBe(false)
  })
  it('hides label-format nav and direct routes when measured retail is off', () => {
    const context = { modules: { 'retail.measured': false } } as unknown as PosContext
    const access = { permissionKeys: ['read_pos_topology'], context }
    expect(visibleNav('labels', access)).toBe(false)
    expect(
      visibleNav('labels', {
        ...access,
        context: { ...context, modules: { 'retail.measured': true } },
      }),
    ).toBe(true)
    expect(visibleNav('labels', { ...access, context: { ...context, modules: null } })).toBe(true)
    expect(visibleNav('labels', { ...access, permissionKeys: [] })).toBe(false)
  })
})
