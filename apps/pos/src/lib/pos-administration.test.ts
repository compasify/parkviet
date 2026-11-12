import { posCapabilities, sensitiveCapabilities } from '@parkviet/pos-shared/pos-capabilities';
import { describe, expect, it } from 'vitest';
import { administrationAccess } from './pos-administration';
import type { PosContext } from './pos-context';

describe('POS administration authorization', () => {
  it('prefers store authority to membership capabilities and fails closed without context', () => {
    expect(administrationAccess()).toEqual({ read: false, write: false });
    expect(administrationAccess({ capabilities: ['pos.topology.manage'] } as PosContext)).toEqual({
      read: false,
      write: false,
    });
    expect(
      administrationAccess({
        administration: { read: false, write: false },
        capabilities: ['pos.topology.manage'],
      } as PosContext),
    ).toEqual({ read: false, write: false });
    expect(
      administrationAccess({
        administration: { read: true, write: true },
        capabilities: [],
      } as unknown as PosContext),
    ).toEqual({ read: true, write: true });
  });
  it('offers all thirty-one branch capabilities without hiding discount, price, customer, credit, return, cash or report permissions', () => {
    const keys = posCapabilities.map(([key]) => key);
    expect(new Set(keys).size).toBe(31);
    expect(keys.slice(-13)).toEqual([
      'pos.device.manage',
      'pos.printer.manage',
      'pos.menu.manage',
      'pos.menu.sold_out',
      'pos.einvoice.manage',
      'pos.kitchen.operate',
      'pos.kitchen.manage',
      'pos.kitchen.void',
      'pos.table.serve',
      'pos.resource.manage',
      'pos.reservation.manage',
      'pos.expo.operate',
      'pos.meal_account.manage',
    ]);
    expect(keys).toEqual(
      expect.arrayContaining(['pos.cash.move', 'pos.report.read', 'pos.report.export']),
    );
    expect(keys).toEqual(
      expect.arrayContaining([
        'pos.discount.apply',
        'pos.price.override',
        'pos.customer.write',
        'pos.credit.sell',
        'pos.credit.manage',
        'pos.return.process',
      ]),
    );
    expect(sensitiveCapabilities).toEqual(
      expect.arrayContaining([
        'pos.discount.apply',
        'pos.price.override',
        'pos.topology.recover',
        'pos.credit.manage',
      ]),
    );
  });
});
