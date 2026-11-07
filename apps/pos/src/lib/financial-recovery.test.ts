import { afterEach, describe, expect, it, vi } from 'vitest';
import {
  clearFinancialRecords,
  createIndexedDbFinancialStore,
  createMemoryFinancialStore,
  financialRecoveryState,
  financialScope,
  forgetFinancialRecord,
  saveFinancialRecord,
  scopedFinancialRecords,
  setFinancialStore,
} from './financial-recovery';

afterEach(() => {
  setFinancialStore(null);
  vi.unstubAllGlobals();
});

describe('financial recovery store', () => {
  it('keeps an independent key per scope and never turns it into a session intent', async () => {
    setFinancialStore(createMemoryFinancialStore());
    const firstScope = financialScope('stf_1', 'store_1', 'ws_1', 'tender.confirm', 'digest-a');
    const secondScope = financialScope('stf_1', 'store_1', 'ws_1', 'tender.confirm', 'digest-b');
    await saveFinancialRecord({
      scope: firstScope,
      idempotencyKey: 'key-a',
      workspaceId: 'ws_1',
      path: '/pos/workspaces/ws_1/tender_attempts/ten_1/confirm',
      body: { expected_revision: 1 },
      savedAt: 1,
    });
    await saveFinancialRecord({
      scope: secondScope,
      idempotencyKey: 'key-b',
      workspaceId: 'ws_1',
      path: '/pos/workspaces/ws_1/tender_attempts/ten_2/confirm',
      body: { expected_revision: 2 },
      savedAt: 2,
    });
    expect(await scopedFinancialRecords('stf_1', 'store_1')).toHaveLength(2);
    expect(
      (await scopedFinancialRecords('stf_1', 'store_1')).map((record) => record.idempotencyKey),
    ).toEqual(['key-a', 'key-b']);
    await forgetFinancialRecord(firstScope);
    expect(await scopedFinancialRecords('stf_1', 'store_1')).toHaveLength(1);
    expect(await scopedFinancialRecords('stf_2', 'store_1')).toHaveLength(0);
    await clearFinancialRecords();
    expect(await scopedFinancialRecords('stf_1', 'store_1')).toHaveLength(0);
  });

  it('reports unreadable storage instead of claiming nothing is pending', async () => {
    setFinancialStore({
      async put() {
        throw new Error('blocked');
      },
      async getAll() {
        throw new Error('blocked');
      },
      async delete() {},
      async clear() {},
    });
    await expect(
      saveFinancialRecord({
        scope: financialScope('stf_1', 'store_1', 'ws_1', 'complete', 'digest'),
        idempotencyKey: 'key-c',
        workspaceId: 'ws_1',
        path: '/pos/workspaces/ws_1/complete',
        body: {},
        savedAt: 3,
      }),
    ).rejects.toThrow('blocked');
    await expect(scopedFinancialRecords('stf_1', 'store_1')).rejects.toThrow('blocked');
    expect(await financialRecoveryState('stf_1', 'store_1')).toEqual({
      pending: 0,
      storageUnavailable: true,
    });
  });

  it('reports the in-memory fallback as unavailable storage', async () => {
    vi.stubGlobal('indexedDB', undefined);
    setFinancialStore(null);
    expect(await financialRecoveryState('stf_1', 'store_1')).toEqual({
      pending: 0,
      storageUnavailable: true,
    });
  });

  it('rejects a write whose IndexedDB transaction aborts instead of hanging', async () => {
    vi.stubGlobal('indexedDB', abortingIndexedDb());
    setFinancialStore(createIndexedDbFinancialStore());
    await expect(
      saveFinancialRecord({
        scope: financialScope('stf_1', 'store_1', 'ws_1', 'complete', 'digest'),
        idempotencyKey: 'key-d',
        workspaceId: 'ws_1',
        path: '/pos/workspaces/ws_1/complete',
        body: {},
        savedAt: 4,
      }),
    ).rejects.toThrow('QuotaExceededError');
  });
});

// Opens fine, then aborts every transaction the way a full disk does.
function abortingIndexedDb() {
  const database = {
    objectStoreNames: { contains: () => true },
    close() {},
    transaction() {
      const transaction: {
        error: Error;
        onabort: (() => void) | null;
        oncomplete: (() => void) | null;
        onerror: (() => void) | null;
        objectStore: () => unknown;
      } = {
        error: new Error('QuotaExceededError'),
        onabort: null,
        oncomplete: null,
        onerror: null,
        objectStore: () => ({ put: () => ({ onsuccess: null }) }),
      };
      setTimeout(() => transaction.onabort?.(), 0);
      return transaction;
    },
  };
  return {
    open() {
      const request: { result: unknown; onsuccess: (() => void) | null } = {
        result: database,
        onsuccess: null,
      };
      setTimeout(() => request.onsuccess?.(), 0);
      return request;
    },
  };
}
