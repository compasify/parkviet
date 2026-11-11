import type { PosContext } from '@parkviet/pos-shared/types/pos-context'
import { describe, expect, it } from 'vitest'
import {
  branchTabs,
  canAdminister,
  canManageBranch,
  canSendReminders,
  routeAllowed,
  visibleNav,
} from './pos-access'

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
  it('lists store master data for administrators whatever the selected branch runs', () => {
    const context = { modules: { 'retail.measured': false } } as unknown as PosContext
    const reader = { permissionKeys: ['read_pos_topology'], context }
    for (const page of ['labels', 'payment-methods', 'units', 'staff-roles'] as const) {
      expect(visibleNav(page, reader)).toBe(true)
      expect(visibleNav(page, { ...reader, permissionKeys: [] })).toBe(false)
    }
    expect(visibleNav('store-model', reader)).toBe(false)
    expect(visibleNav('store-model', { permissionKeys: ['write_pos_topology'] })).toBe(true)
  })
  it('opens every branch tab to administrators and only overview and features to a manager', () => {
    const tabs = (access: Parameters<typeof branchTabs>[0]) =>
      branchTabs(access).map((tab) => tab.key)
    expect(tabs({ permissionKeys: ['read_pos_topology'] })).toEqual([
      'overview',
      'registers',
      'staff',
      'products',
      'features',
      'payments',
      'printing',
    ])
    const manager = {
      permissionKeys: [],
      context: {
        selection: { branch_id: 'b', register_id: null },
        capabilities: ['pos.topology.manage'],
      } as PosContext,
    }
    expect(tabs(manager)).toEqual(['overview', 'features'])
    expect(routeAllowed('branch', manager)).toBe(true)
    expect(visibleNav('branch', manager)).toBe(true)
    expect(visibleNav('branch', { permissionKeys: ['read_pos_topology'] })).toBe(false)
    expect(routeAllowed('branch-payments', manager)).toBe(false)
    const cashier = {
      ...manager,
      context: { ...manager.context, capabilities: ['pos.shift.open'] },
    }
    expect(tabs(cashier)).toEqual([])
    expect(routeAllowed('branch', cashier)).toBe(false)
    const printerManager = {
      ...manager,
      context: { ...manager.context, capabilities: ['pos.printer.manage'] },
    }
    expect(tabs(printerManager)).toEqual(['overview', 'printing'])
    expect(routeAllowed('branch-printing', printerManager)).toBe(true)
    expect(routeAllowed('branch-payments', printerManager)).toBe(false)
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
  it('lets readers reach setup by URL only', () => {
    const access = { permissionKeys: ['read_pos_topology'] }
    expect(routeAllowed('setup', access)).toBe(true)
    expect(visibleNav('setup', access)).toBe(false)
    expect(routeAllowed('setup', { permissionKeys: [] })).toBe(false)
  })
  it('opens receivables to branch members and credit screens to credit staff', () => {
    const staff = (capabilities: string[]) => ({
      permissionKeys: ['write_pos_topology'],
      context: { selection: { branch_id: 'b', register_id: null }, capabilities } as PosContext,
    })
    expect(visibleNav('receivables', staff(['pos.shift.open']))).toBe(true)
    expect(visibleNav('receivables', staff(['pos.topology.manage']))).toBe(false)
    expect(visibleNav('receivables', { permissionKeys: ['write_pos_topology'] })).toBe(false)
    expect(visibleNav('credit-accounts', staff(['pos.credit.manage']))).toBe(true)
    expect(visibleNav('credit-accounts', staff(['pos.shift.open']))).toBe(false)
    expect(visibleNav('credit-approvals', staff(['pos.approval.grant']))).toBe(true)
    expect(visibleNav('credit-approvals', staff(['pos.approval.grant', 'pos.credit.manage']))).toBe(
      true,
    )
    expect(routeAllowed('credit-approvals', staff(['pos.shift.open']))).toBe(false)
  })
  it('sends reminders only while credit sales are on', () => {
    const access = (credit: boolean) => ({
      permissionKeys: [],
      context: {
        selection: { branch_id: 'b', register_id: null },
        capabilities: ['pos.payment.collect'],
        features: { credit },
      } as unknown as PosContext,
    })
    expect(canSendReminders(access(true))).toBe(true)
    expect(canSendReminders(access(false))).toBe(false)
  })
  it('lists traceable stock with the module or its data, and opens it by URL to its staff', () => {
    const staff = (capabilities: string[], on: boolean, inUse = false) => ({
      permissionKeys: [],
      context: {
        selection: { branch_id: 'b', register_id: null },
        capabilities,
        modules: { 'retail.traceability': on },
        module_usage: { 'retail.traceability': inUse },
      } as unknown as PosContext,
    })
    expect(visibleNav('inventory', staff(['pos.inventory.trace'], true))).toBe(true)
    expect(visibleNav('inventory', staff(['pos.approval.grant'], true))).toBe(true)
    expect(visibleNav('inventory', staff(['pos.inventory.manage'], false))).toBe(false)
    expect(visibleNav('inventory', staff(['pos.inventory.manage'], false, true))).toBe(true)
    expect(routeAllowed('inventory', staff(['pos.inventory.manage'], false))).toBe(true)
    expect(routeAllowed('inventory', staff(['pos.shift.open'], true))).toBe(false)
  })
  it('opens reports to any branch member', () => {
    const staff = (capabilities: string[]) => ({
      permissionKeys: [],
      context: { selection: { branch_id: 'b', register_id: null }, capabilities } as PosContext,
    })
    expect(visibleNav('reports', staff(['pos.shift.open']))).toBe(true)
    expect(visibleNav('reports', staff([]))).toBe(false)
  })
  it('shows server information to store administrators only', () => {
    expect(routeAllowed('system', { permissionKeys: ['read_pos_topology'] })).toBe(true)
    expect(visibleNav('system', { permissionKeys: ['write_pos_topology'] })).toBe(true)
    const manager = {
      permissionKeys: [],
      context: {
        selection: { branch_id: 'b', register_id: null },
        capabilities: ['pos.topology.manage', 'pos.device.manage'],
      } as PosContext,
    }
    expect(routeAllowed('system', manager)).toBe(false)
  })
})
