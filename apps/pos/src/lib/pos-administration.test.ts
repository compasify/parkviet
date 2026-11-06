import { describe, expect, it } from 'vitest';
import { administrationAccess } from './pos-administration';
import { posCapabilities, sensitiveCapabilities } from './pos-capabilities';
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
  it('offers all ten branch capabilities without hiding discount, price or customer permissions', () => {
    const keys = posCapabilities.map(([key]) => key);
    expect(new Set(keys).size).toBe(10);
    expect(keys).toEqual(
      expect.arrayContaining(['pos.discount.apply', 'pos.price.override', 'pos.customer.write']),
    );
    expect(sensitiveCapabilities).toEqual(
      expect.arrayContaining(['pos.discount.apply', 'pos.price.override', 'pos.topology.recover']),
    );
  });
});
