import { describe, expect, it } from 'vitest';
import en from '../locales/en.json';
import vi from '../locales/vi.json';
import { navVisible } from '../modules/registry';
import { emptySelection, normalizeContext, type PosContext, writesLocked } from './pos-context';
import { catalogViewOf, contextModule } from './pos-modules';
import { posContextKey } from './query-keys';
import { posFailureKey } from './request-failure';

describe('hợp đồng shell POS', () => {
  it('keeps Vietnamese and English labels aligned', () => {
    expect(Object.keys(en).sort()).toEqual(Object.keys(vi).sort());
  });

  it('scopes context cache by session generation', () => {
    expect(posContextKey(1)).not.toEqual(posContextKey(2));
    expect(posContextKey(4)).toEqual(['pos', 'context', 4, null, null]);
    expect(posContextKey(4, { branchId: 'branch' })).not.toEqual(posContextKey(4));
  });

  it('maps auth, permission, validation and network failures', () => {
    expect(posFailureKey({ status: 401 })).toBe('unauthorized');
    expect(posFailureKey({ response: { status: 403 } })).toBe('forbidden');
    expect(posFailureKey({ status: 404 })).toBe('missing');
    expect(posFailureKey({ status: 409 })).toBe('conflict');
    expect(posFailureKey({ status: 422 })).toBe('invalid');
    expect(posFailureKey(new TypeError('Failed to fetch'))).toBe('offline');
  });

  it('locks writes while the current context is unavailable', () => {
    expect(writesLocked(undefined, emptySelection)).toBe(true);
  });

  const base: PosContext = {
    staff: { id: 'stf_1', email: 'staff@example.test', full_name: 'Lan' },
    store: { id: 'store_1', name: 'ParkViet', currency: 'VND', locale: 'vi', timezone: null },
    capabilities: ['pos.inventory.manage'],
    branches: [],
    registers: [],
    shift: null,
    selection: { branch_id: 'br_1', register_id: null },
  };

  it('reads modules, module usage, profile and onboarding from the context', () => {
    const context = normalizeContext({
      ...base,
      modules: { 'retail.units': true, 'retail.measured': false, 'retail.traceability': false },
      module_usage: { 'retail.traceability': true },
      profile: { key: 'nha_thuoc', version: 1, display: { catalog_view: 'list' } },
      onboarding: { required: false, can_setup: true },
    } as PosContext);
    expect(context.modules).toEqual({ 'retail.units': true });
    expect(context.module_usage).toEqual({ 'retail.traceability': true });
    expect(context.profile).toEqual({
      key: 'nha_thuoc',
      version: 1,
      display: { catalog_view: 'list' },
    });
    expect(context.onboarding).toEqual({ required: false, can_setup: true });
    expect(contextModule(context, 'retail.traceability')).toBe(false);
    expect(navVisible(context, 'inventory')).toBe(true);
    expect(catalogViewOf(context)).toBe('list');
  });

  it('keeps the UI as before for a context without modules or profile', () => {
    const context = normalizeContext(base);
    expect(context.modules).toBeNull();
    expect(context.module_usage).toEqual({});
    expect(context.profile).toBeNull();
    expect(context.onboarding).toBeNull();
    expect(context.features).toBeNull();
    for (const key of ['retail.units', 'retail.measured', 'retail.traceability'])
      expect(contextModule(context, key)).toBe(true);
    expect(navVisible(context, 'inventory')).toBe(true);
    expect(catalogViewOf(context)).toBe('cards');
  });
});
