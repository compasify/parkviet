import { afterEach, describe, expect, it, vi } from 'vitest';
import {
  clearFinancialRecords,
  createMemoryFinancialStore,
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

  it('returns an empty attention list when storage is unavailable instead of inventing a receipt', async () => {
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
    expect(await scopedFinancialRecords('stf_1', 'store_1')).toEqual([]);
  });
});
