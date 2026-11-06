import { describe, expect, it } from 'vitest';
import en from '../locales/en.json';
import vi from '../locales/vi.json';
import { emptySelection, writesLocked } from './pos-context';
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
});
