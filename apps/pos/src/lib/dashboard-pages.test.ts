import { describe, expect, it } from 'vitest';
import { dashboardPages } from './dashboard-pages';
import type { PosContext } from './pos-context';

const context = (overrides: Partial<PosContext> = {}): PosContext =>
  ({
    capabilities: [],
    administration: { read: false, write: false },
    features: {},
    modules: null,
    ...overrides,
  }) as unknown as PosContext;

const keys = (data: PosContext | undefined, branchId: string | null = 'branch_1') =>
  dashboardPages(data, branchId).map((page) => page.key);

describe('POS dashboard pages in the account menu', () => {
  it('lists nothing without a context and only orders for staff without capabilities', () => {
    expect(keys(undefined)).toEqual([]);
    expect(keys(context())).toEqual(['orders']);
  });

  it('lists the back office a cashier could open before, with reports for any member', () => {
    expect(keys(context({ capabilities: ['pos.shift.open', 'pos.payment.collect'] }))).toEqual([
      'orders',
      'funds',
      'attention',
      'receivables',
      'reports',
    ]);
  });

  it('lists deliveries only with the delivery switch on', () => {
    const capabilities = ['pos.shift.open'];
    expect(keys(context({ capabilities }))).not.toContain('deliveries');
    expect(
      keys(context({ capabilities, features: { delivery: true } } as Partial<PosContext>)),
    ).toContain('deliveries');
  });

  it('lists shift management for staff who confirm cash, recover or reconcile', () => {
    expect(keys(context({ capabilities: ['pos.shift.open'] }))).not.toContain('shifts');
    for (const capability of ['pos.cash.move', 'pos.approval.grant', 'pos.topology.recover']) {
      expect(keys(context({ capabilities: [capability] }))).toContain('shifts');
    }
  });

  it('gates credit accounts and approvals like the counter did', () => {
    const manager = keys(
      context({ capabilities: ['pos.shift.open', 'pos.credit.manage', 'pos.approval.grant'] }),
    );
    expect(manager).toEqual(expect.arrayContaining(['credit-accounts', 'credit-approvals']));
    // Credit management from a store role alone does not prove branch membership.
    expect(keys(context({ capabilities: ['pos.topology.manage'] }))).not.toContain(
      'credit-accounts',
    );
  });

  it('links store settings for administrators, else branch features for topology managers', () => {
    const admin = dashboardPages(
      context({ administration: { read: true, write: false } }),
      'branch_1',
    );
    expect(admin.find((page) => page.key === 'settings')).toMatchObject({ path: '' });
    expect(keys(context({ capabilities: ['pos.topology.manage'] }))).toContain('branch-features');
    expect(keys(context({ capabilities: ['pos.topology.manage'] }), null)).not.toContain(
      'branch-features',
    );
  });

  it('links inventory with the traceability module on and an inventory capability', () => {
    expect(keys(context({ capabilities: ['pos.inventory.trace'] }))).toContain('inventory');
    expect(
      keys(context({ capabilities: ['pos.inventory.trace'], modules: {} } as Partial<PosContext>)),
    ).not.toContain('inventory');
  });
});
