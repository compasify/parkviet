import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import {
  type FinancialCommand,
  type FinancialRequest,
  runFinancialCommand,
} from './financial-command';
import {
  createMemoryFinancialStore,
  scopedFinancialRecords,
  setFinancialStore,
} from './financial-recovery';

type Call = { method: string; path: string; key?: string; body?: Record<string, unknown> };
type Reply = (call: Call) => unknown;

function fakeServer(replies: Reply[]) {
  const calls: Call[] = [];
  const request: FinancialRequest = async <T>(
    method: 'GET' | 'POST',
    path: string,
    options?: Parameters<FinancialRequest>[2],
  ) => {
    const call = {
      method,
      path,
      key: options?.idempotencyKey ?? options?.params?.idempotency_key,
      body: options?.body,
    };
    calls.push(call);
    const reply = replies.shift();
    if (!reply) throw new Error(`unexpected ${method} ${path}`);
    return reply(call) as T;
  };
  return { request, calls };
}

const fail = (error: unknown) => () => {
  throw error;
};
const ok = (data: unknown) => () => ({ data });

function confirmCommand(editorId: string, revision: number): FinancialCommand {
  return {
    staffId: 'stf_1',
    storeId: 'store_1',
    scopeId: 'ws_1',
    action: 'tender.confirm',
    path: '/pos/workspaces/ws_1/tender_attempts/ten_1/confirm',
    body: {
      expected_revision: revision,
      lease_generation: 1,
      editor_id: editorId,
      evidence_kind: 'cash_count',
      handed_amount: '200000',
    },
  };
}

let keys = 0;
const newKey = () => `key-${++keys}`;

beforeEach(() => {
  keys = 0;
  setFinancialStore(createMemoryFinancialStore());
});

afterEach(() => {
  setFinancialStore(null);
});

describe('a named intent keeps one key when the body is corrected', () => {
  const collection = (handed: string): FinancialCommand => ({
    staffId: 'stf_1',
    storeId: 'store_1',
    scopeId: 'poscredit_1',
    action: 'collection.receive',
    path: '/pos/collections',
    intent: 'receipt',
    body: { amount: '700000', handed_amount: handed },
  });

  it('reuses the unknown receipt key after the handed amount is edited', async () => {
    const first = fakeServer([fail(new TypeError('Failed to fetch'))]);
    await expect(
      runFinancialCommand(first.request, collection('1000000'), newKey),
    ).rejects.toThrow();

    const retry = fakeServer([fail({ status: 404 }), ok({ id: 'poscollect_1' })]);
    await runFinancialCommand(retry.request, collection('800000'), newKey);
    expect(retry.calls.map((call) => [call.method, call.key])).toEqual([
      ['GET', 'key-1'],
      ['POST', 'key-1'],
    ]);
    expect(retry.calls[1].body).toMatchObject({ handed_amount: '800000' });
  });

  it('returns the committed receipt instead of sending the edited body', async () => {
    const first = fakeServer([fail(new TypeError('Failed to fetch'))]);
    await expect(
      runFinancialCommand(first.request, collection('1000000'), newKey),
    ).rejects.toThrow();

    const retry = fakeServer([ok({ id: 'poscollect_1' })]);
    const result = await runFinancialCommand(retry.request, collection('800000'), newKey);
    expect(result).toEqual({ data: { id: 'poscollect_1' }, recovered: true });
    expect(retry.calls.map((call) => call.method)).toEqual(['GET']);
  });
});

describe('financial command recovery', () => {
  it('drops the local record when the server definitively rejects the command', async () => {
    const conflict = { status: 409, message: 'Handed cash is less than the tender amount.' };
    const server = fakeServer([fail(conflict), fail({ status: 404 })]);
    await expect(
      runFinancialCommand(server.request, confirmCommand('editor-a', 3), newKey),
    ).rejects.toBe(conflict);
    expect(server.calls.map((call) => call.method)).toEqual(['POST', 'GET']);
    expect(await scopedFinancialRecords('stf_1', 'store_1')).toEqual([]);
  });

  it('drops the record on validation and permission failures without a receipt lookup', async () => {
    for (const status of [422, 403, 404]) {
      const server = fakeServer([fail({ status })]);
      await expect(
        runFinancialCommand(server.request, confirmCommand('editor-a', 3), newKey),
      ).rejects.toEqual({ status });
      expect(server.calls).toHaveLength(1);
      expect(await scopedFinancialRecords('stf_1', 'store_1')).toEqual([]);
    }
  });

  it('keeps the record after a transport failure and retries under the same key after a reload', async () => {
    const lost = new TypeError('Failed to fetch');
    const first = fakeServer([fail(lost)]);
    await expect(
      runFinancialCommand(first.request, confirmCommand('editor-a', 3), newKey),
    ).rejects.toBe(lost);
    const kept = await scopedFinancialRecords('stf_1', 'store_1');
    expect(kept.map((record) => record.idempotencyKey)).toEqual(['key-1']);

    // A reload mints a new editor id and the workspace moved on meanwhile.
    const retry = fakeServer([fail({ status: 404 }), ok({ id: 'ws_1', revision: 5 })]);
    const result = await runFinancialCommand(retry.request, confirmCommand('editor-b', 4), newKey);
    expect(result).toEqual({ data: { id: 'ws_1', revision: 5 }, recovered: false });
    expect(retry.calls.map((call) => [call.method, call.key])).toEqual([
      ['GET', 'key-1'],
      ['POST', 'key-1'],
    ]);
    expect(retry.calls[1].body).toMatchObject({ expected_revision: 4, editor_id: 'editor-b' });
    expect(await scopedFinancialRecords('stf_1', 'store_1')).toEqual([]);
  });

  it('keeps the record on server errors', async () => {
    const server = fakeServer([fail({ status: 503 })]);
    await expect(
      runFinancialCommand(server.request, confirmCommand('editor-a', 3), newKey),
    ).rejects.toEqual({ status: 503 });
    expect(await scopedFinancialRecords('stf_1', 'store_1')).toHaveLength(1);
  });

  it('returns the committed receipt instead of resending a retried intent', async () => {
    await runFinancialCommand(
      fakeServer([fail(new TypeError('Failed to fetch'))]).request,
      confirmCommand('editor-a', 3),
      newKey,
    ).catch(() => undefined);
    const server = fakeServer([ok({ id: 'ws_1', revision: 4 })]);
    const result = await runFinancialCommand(server.request, confirmCommand('editor-b', 3), newKey);
    expect(result.recovered).toBe(true);
    expect(server.calls.map((call) => call.method)).toEqual(['GET']);
    expect(await scopedFinancialRecords('stf_1', 'store_1')).toEqual([]);
  });

  it('does not resend while the receipt lookup itself fails', async () => {
    await runFinancialCommand(
      fakeServer([fail(new TypeError('Failed to fetch'))]).request,
      confirmCommand('editor-a', 3),
      newKey,
    ).catch(() => undefined);
    const lookup = { status: 502 };
    const server = fakeServer([fail(lookup)]);
    await expect(
      runFinancialCommand(server.request, confirmCommand('editor-a', 3), newKey),
    ).rejects.toBe(lookup);
    expect(server.calls.map((call) => call.method)).toEqual(['GET']);
    expect(await scopedFinancialRecords('stf_1', 'store_1')).toHaveLength(1);
  });

  it('refuses to send when the intent cannot be stored first', async () => {
    setFinancialStore({
      async put() {
        throw new Error('quota');
      },
      async getAll() {
        return [];
      },
      async delete() {},
      async clear() {},
    });
    const server = fakeServer([]);
    await expect(
      runFinancialCommand(server.request, confirmCommand('editor-a', 3), newKey),
    ).rejects.toThrow('financial-storage-unavailable');
    expect(server.calls).toEqual([]);
  });
});
