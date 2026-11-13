import { afterEach, describe, expect, it } from 'vitest';
import {
  captureHandoff,
  clearRequestedHandoff,
  handoffBranch,
  requestedStoreId,
} from './requested-store';

afterEach(() => {
  clearRequestedHandoff();
});

describe('requested store handoff', () => {
  it('reads a store id and ignores anything that is not one', () => {
    expect(requestedStoreId('?store=store_1&branch=branch_1')).toBe('store_1');
    expect(requestedStoreId('store=store_1')).toBe('store_1');
    for (const search of ['', '?store=', '?store=../x', '?store=store/1', '?branch=branch_1']) {
      expect(requestedStoreId(search)).toBeNull();
    }
  });

  it('remembers the store and keeps the branch only for that store', () => {
    const writes: string[] = [];
    captureHandoff('?store=store_1&branch=branch_main', (storeId) => writes.push(storeId));
    expect(writes).toEqual(['store_1']);
    expect(handoffBranch('store_1')).toBe('branch_main');
    expect(handoffBranch('store_2')).toBeNull();
  });

  it('does not remember a branch without a store, or an unsafe branch', () => {
    const writes: string[] = [];
    captureHandoff('?branch=branch_1', (storeId) => writes.push(storeId));
    captureHandoff('?store=store_1&branch=../x', (storeId) => writes.push(storeId));
    expect(writes).toEqual(['store_1']);
    expect(handoffBranch('store_1')).toBeNull();
  });
});
