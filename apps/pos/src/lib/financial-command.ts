import { commandDigest } from './command-queue';
import {
  type FinancialRecoveryRecord,
  financialScope,
  forgetFinancialRecord,
  saveFinancialRecord,
  scopedFinancialRecords,
} from './financial-recovery';
import {
  definitiveRejection,
  FINANCIAL_STORAGE_UNAVAILABLE,
  failureStatus,
} from './request-failure';

export type FinancialRequest = <T>(
  method: 'GET' | 'POST',
  path: string,
  options?: {
    body?: Record<string, unknown>;
    params?: Record<string, string>;
    idempotencyKey?: string;
  },
) => Promise<T>;

export type FinancialCommand = {
  staffId: string | null;
  storeId: string | null;
  // Workspace id, or the received funds id for commands outside a workspace.
  scopeId: string;
  action: string;
  path: string;
  body: Record<string, unknown>;
  // Names the money intent when the body may legitimately change between
  // retries (for example a corrected handed amount): one key per intent, so an
  // edited retry can never become a second receipt.
  intent?: string;
};

// Fields that change on every reload or write. The money intent stays the same
// across them, so they must not change the idempotency key of a retry.
const VOLATILE_FIELDS = new Set(['editor_id', 'expected_revision', 'lease_generation']);

export function financialIntentScope(command: FinancialCommand): string {
  if (command.intent !== undefined) {
    return financialScope(
      command.staffId,
      command.storeId,
      command.scopeId,
      command.action,
      commandDigest({ path: command.path, intent: command.intent }),
    );
  }
  const intent = Object.fromEntries(
    Object.entries(command.body).filter(
      ([field, value]) => !VOLATILE_FIELDS.has(field) && value !== undefined,
    ),
  );
  return financialScope(
    command.staffId,
    command.storeId,
    command.scopeId,
    command.action,
    commandDigest({ path: command.path, intent: commandDigest(intent) }),
  );
}

function storageUnavailable(): Error {
  return new Error(FINANCIAL_STORAGE_UNAVAILABLE);
}

async function existingRecord(
  command: FinancialCommand,
  scope: string,
): Promise<FinancialRecoveryRecord | undefined> {
  if (!command.staffId || !command.storeId) return undefined;
  try {
    return (await scopedFinancialRecords(command.staffId, command.storeId)).find(
      (record) => record.scope === scope,
    );
  } catch {
    throw storageUnavailable();
  }
}

type ReceiptOutcome<T> = { committed: true; data: T } | { committed: false } | { unknown: unknown };

async function lookupReceipt<T>(
  request: FinancialRequest,
  key: string,
): Promise<ReceiptOutcome<T>> {
  try {
    const receipt = await request<{ data: T }>('GET', '/pos/command_receipts', {
      params: { idempotency_key: key },
    });
    return { committed: true, data: receipt.data };
  } catch (error) {
    return failureStatus(error) === 404 ? { committed: false } : { unknown: error };
  }
}

async function forget(scope: string) {
  await forgetFinancialRecord(scope).catch(() => undefined);
}

// Sends one money command so that a lost response can never become a second
// payment: the key is stored before sending, kept while the outcome is unknown,
// and reused (after checking its receipt) when the same intent is retried.
export async function runFinancialCommand<T>(
  request: FinancialRequest,
  command: FinancialCommand,
  newKey: () => string = () => crypto.randomUUID(),
): Promise<{ data: T; recovered: boolean }> {
  const scope = financialIntentScope(command);
  const existing = await existingRecord(command, scope);
  if (existing) {
    const receipt = await lookupReceipt<T>(request, existing.idempotencyKey);
    if ('unknown' in receipt) throw receipt.unknown;
    if (receipt.committed) {
      await forget(scope);
      return { data: receipt.data, recovered: true };
    }
    // Not committed: resend under the same key with the current body.
  }
  const key = existing?.idempotencyKey ?? newKey();
  try {
    await saveFinancialRecord({
      scope,
      idempotencyKey: key,
      workspaceId: command.scopeId,
      path: command.path,
      body: command.body,
      savedAt: existing?.savedAt ?? Date.now(),
    });
  } catch {
    throw storageUnavailable();
  }
  try {
    const result = await request<{ data: T }>('POST', command.path, {
      body: { ...command.body, idempotency_key: key },
      idempotencyKey: key,
    });
    await forget(scope);
    return { data: result.data, recovered: false };
  } catch (error) {
    // A conflict may mean this key already committed with an older body.
    if (failureStatus(error) === 409) {
      const receipt = await lookupReceipt<T>(request, key);
      if ('committed' in receipt && receipt.committed) {
        await forget(scope);
        return { data: receipt.data, recovered: true };
      }
      if ('committed' in receipt) await forget(scope);
      throw error;
    }
    if (definitiveRejection(error)) await forget(scope);
    throw error;
  }
}
