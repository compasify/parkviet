import type { PosContext } from '@parkviet/pos-shared/types/pos-context'
import { describe, expect, it } from 'vitest'
import { canAdminister, canManageBranch, routeAllowed, visibleNav } from './pos-access'

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
  it('opens orders to branch staff and deliveries to sellers or collectors', () => {
    const staff = (capabilities: string[], delivery?: boolean) => ({
      permissionKeys: [],
      context: {
        selection: { branch_id: 'b', register_id: null },
        capabilities,
        features: delivery === undefined ? null : { delivery },
      } as unknown as PosContext,
    })
    expect(visibleNav('orders', staff(['pos.report.read']))).toBe(true)
    expect(visibleNav('orders', staff([]))).toBe(false)
    expect(visibleNav('orders', { permissionKeys: ['write_pos_topology'] })).toBe(false)
    expect(visibleNav('deliveries', staff(['pos.shift.open'], true))).toBe(true)
    expect(visibleNav('deliveries', staff(['pos.payment.collect'], true))).toBe(true)
    expect(visibleNav('deliveries', staff(['pos.report.read'], true))).toBe(false)
  })
  it('opens funds to collectors and the attention view only to resolvers', () => {
    const staff = (capabilities: string[]) => ({
      permissionKeys: ['write_pos_topology'],
      context: { selection: { branch_id: 'b', register_id: null }, capabilities } as PosContext,
    })
    expect(visibleNav('funds', staff(['pos.payment.collect']))).toBe(true)
    expect(visibleNav('funds-attention', staff(['pos.payment.collect']))).toBe(false)
    expect(routeAllowed('funds-attention', staff(['pos.payment.resolve']))).toBe(true)
    expect(visibleNav('funds', staff(['pos.shift.open']))).toBe(false)
    expect(visibleNav('funds', { permissionKeys: ['write_pos_topology'] })).toBe(false)
  })
  it('opens shift management to recoverers, cash confirmers and approvers', () => {
    const staff = (capabilities: string[]) => ({
      permissionKeys: [],
      context: { selection: { branch_id: 'b', register_id: null }, capabilities } as PosContext,
    })
    expect(visibleNav('shifts', staff(['pos.topology.recover']))).toBe(true)
    expect(visibleNav('shifts', staff(['pos.cash.move']))).toBe(true)
    expect(visibleNav('shifts', staff(['pos.approval.grant']))).toBe(true)
    expect(visibleNav('shifts', staff(['pos.shift.open', 'pos.payment.collect']))).toBe(false)
    expect(visibleNav('late-cash', staff(['pos.approval.grant']))).toBe(false)
    expect(routeAllowed('late-cash', staff(['pos.approval.grant', 'pos.payment.resolve']))).toBe(
      true,
    )
  })
  it('keeps deliveries reachable by URL when the delivery feature is off', () => {
    const context = {
      selection: { branch_id: 'b', register_id: null },
      capabilities: ['pos.shift.open'],
      features: { delivery: false },
    } as unknown as PosContext
    expect(visibleNav('deliveries', { permissionKeys: [], context })).toBe(false)
    expect(routeAllowed('deliveries', { permissionKeys: [], context })).toBe(true)
    expect(routeAllowed('deliveries', { permissionKeys: ['write_pos_topology'] })).toBe(false)
  })
  it('lets readers reach setup and label formats by URL only', () => {
    const access = {
      permissionKeys: ['read_pos_topology'],
      context: { modules: { 'retail.measured': false } } as unknown as PosContext,
    }
    expect(routeAllowed('setup', access)).toBe(true)
    expect(routeAllowed('labels', access)).toBe(true)
    expect(visibleNav('labels', access)).toBe(false)
    expect(routeAllowed('setup', { permissionKeys: [] })).toBe(false)
  })
})
