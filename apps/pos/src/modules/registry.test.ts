import { describe, expect, it } from 'vitest';
import {
  branchSettingModule,
  branchSettingVisible,
  moduleUis,
  navVisible,
  skuEditorAreas,
  visibleBranchSettings,
  visibleNav,
} from './registry';

const ALL_ON = { 'retail.units': true, 'retail.measured': true, 'retail.traceability': true };
const keeper = ['pos.inventory.manage'];
const admin = { read: true, write: true };

describe('module UI registry', () => {
  it('declares the three retail modules once, by server key', () => {
    expect(moduleUis.map((module) => module.key)).toEqual([
      'retail.units',
      'retail.measured',
      'retail.traceability',
    ]);
    expect(moduleUis.map((module) => module.skuEditor)).toEqual([
      'units',
      'measured',
      'traceability',
    ]);
  });

  it('shows every entry to a server without modules, as before', () => {
    expect(navVisible({ capabilities: keeper }, 'inventory')).toBe(true);
    expect(navVisible({ capabilities: keeper, modules: null }, 'inventory')).toBe(true);
    expect(branchSettingVisible({ administration: admin }, 'label-formats')).toBe(true);
    expect(branchSettingVisible({ administration: admin }, 'lot-selection')).toBe(true);
    expect([...skuEditorAreas(null)].sort()).toEqual(['measured', 'traceability', 'units']);
  });

  it('still asks for the permissions of each entry', () => {
    expect(navVisible({ modules: ALL_ON, capabilities: ['pos.shift.open'] }, 'inventory')).toBe(
      false,
    );
    expect(navVisible({ modules: ALL_ON, capabilities: ['pos.approval.grant'] }, 'inventory')).toBe(
      true,
    );
    expect(navVisible(undefined, 'inventory')).toBe(false);
    expect(visibleBranchSettings({ modules: ALL_ON })).toEqual([]);
    expect(
      visibleBranchSettings({ modules: ALL_ON, administration: { read: false, write: false } }),
    ).toEqual([]);
    expect(
      visibleBranchSettings({ modules: ALL_ON, administration: admin }).map((entry) => entry.id),
    ).toEqual(['label-formats', 'lot-selection']);
  });

  it('hides the stock page with traceability off unless the store still tracks SKUs', () => {
    const off = { modules: { 'retail.units': true }, capabilities: keeper };
    expect(navVisible(off, 'inventory')).toBe(false);
    expect(visibleNav(off)).toEqual([]);
    expect(
      navVisible({ ...off, module_usage: { 'retail.traceability': false } }, 'inventory'),
    ).toBe(false);
    expect(navVisible({ ...off, module_usage: { 'retail.traceability': true } }, 'inventory')).toBe(
      true,
    );
    // Usage keeps an entry reachable; it never grants the permission.
    expect(
      navVisible(
        { ...off, capabilities: ['pos.shift.open'], module_usage: { 'retail.traceability': true } },
        'inventory',
      ),
    ).toBe(false);
  });

  it('gates branch settings and SKU editor areas by their own module', () => {
    const measuredOff = {
      modules: { 'retail.units': true, 'retail.traceability': true },
      administration: admin,
    };
    expect(branchSettingVisible(measuredOff, 'label-formats')).toBe(false);
    expect(branchSettingVisible(measuredOff, 'lot-selection')).toBe(true);
    const traceOff = {
      modules: { 'retail.units': true, 'retail.measured': true },
      administration: admin,
    };
    // Usage does not bring setup back: lot picking stays hidden.
    expect(
      branchSettingVisible(
        { ...traceOff, module_usage: { 'retail.traceability': true } },
        'lot-selection',
      ),
    ).toBe(false);
    expect([...skuEditorAreas({ 'retail.units': true })]).toEqual(['units']);
    expect([...skuEditorAreas({})]).toEqual([]);
    expect(branchSettingModule('label-formats')).toBe('retail.measured');
    expect(branchSettingModule('lot-selection')).toBe('retail.traceability');
  });

  it('ignores modules no entry declares', () => {
    expect(
      visibleNav({ modules: { ...ALL_ON, wholesale: true }, capabilities: keeper }).map(
        (e) => e.id,
      ),
    ).toEqual(['inventory']);
    expect([...skuEditorAreas({ wholesale: true })]).toEqual([]);
  });
});
