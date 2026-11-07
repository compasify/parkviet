export type FinancialRecoveryRecord = {
  scope: string;
  idempotencyKey: string;
  workspaceId: string;
  path: string;
  body: Record<string, unknown>;
  savedAt: number;
};

export type FinancialRecoveryDb = {
  put(record: FinancialRecoveryRecord): Promise<void>;
  getAll(): Promise<FinancialRecoveryRecord[]>;
  delete(scope: string): Promise<void>;
  clear(): Promise<void>;
  // Records vanish with the page: the browser offered no durable storage.
  volatile?: boolean;
};

export const FINANCIAL_RECOVERY_CHANGED = 'pos:financial-recovery-changed';

function scopeKey(scope: string): string {
  return scope;
}

export function financialScope(
  staffId: string | null,
  storeId: string | null,
  workspaceId: string,
  action: string,
  digest: string,
): string {
  return JSON.stringify([staffId, storeId, workspaceId, action, digest]);
}

export function createMemoryFinancialStore(): FinancialRecoveryDb {
  const records = new Map<string, FinancialRecoveryRecord>();
  return {
    async put(record) {
      records.set(scopeKey(record.scope), { ...record });
    },
    async getAll() {
      return [...records.values()].sort((a, b) => a.savedAt - b.savedAt);
    },
    async delete(scope) {
      records.delete(scopeKey(scope));
    },
    async clear() {
      records.clear();
    },
  };
}

function openIndexedDb(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open('parkviet-pos-financial-recovery', 1);
    request.onupgradeneeded = () => {
      if (!request.result.objectStoreNames.contains('records')) {
        request.result.createObjectStore('records', { keyPath: 'scope' });
      }
    };
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error ?? new Error('indexeddb-unavailable'));
    request.onblocked = () => reject(new Error('indexeddb-blocked'));
  });
}

async function withStore<T>(
  mode: IDBTransactionMode,
  run: (store: IDBObjectStore) => IDBRequest<T> | Promise<T>,
): Promise<T> {
  const database = await openIndexedDb();
  try {
    return await new Promise<T>((resolve, reject) => {
      const transaction = database.transaction('records', mode);
      const store = transaction.objectStore('records');
      let result: T;
      const finish = () => resolve(result);
      transaction.oncomplete = finish;
      transaction.onerror = () => reject(transaction.error ?? new Error('indexeddb-transaction'));
      // Quota exhaustion and similar failures abort without an error event.
      transaction.onabort = () => reject(transaction.error ?? new Error('indexeddb-aborted'));
      const request = run(store);
      if (request instanceof Promise) {
        void request.then((value) => {
          result = value;
        }, reject);
      } else {
        request.onsuccess = () => {
          result = request.result;
        };
      }
    });
  } finally {
    database.close();
  }
}

export function createIndexedDbFinancialStore(): FinancialRecoveryDb {
  return {
    async put(record) {
      await withStore('readwrite', (store) => store.put(record));
    },
    async getAll() {
      return withStore(
        'readonly',
        (store) => store.getAll() as IDBRequest<FinancialRecoveryRecord[]>,
      );
    },
    async delete(scope) {
      await withStore('readwrite', (store) => store.delete(scope));
    },
    async clear() {
      await withStore('readwrite', (store) => store.clear());
    },
  };
}

export function defaultFinancialStore(): FinancialRecoveryDb {
  try {
    if (typeof indexedDB !== 'undefined') return createIndexedDbFinancialStore();
  } catch {
    // Fall through to memory; callers must surface attention, not claim sync.
  }
  return { ...createMemoryFinancialStore(), volatile: true };
}

let activeStore: FinancialRecoveryDb | null = null;

export function setFinancialStore(store: FinancialRecoveryDb | null) {
  activeStore = store;
}

export function financialStore(): FinancialRecoveryDb {
  activeStore ??= defaultFinancialStore();
  return activeStore;
}

function emitChanged() {
  globalThis.dispatchEvent?.(new Event(FINANCIAL_RECOVERY_CHANGED));
}

export async function saveFinancialRecord(record: FinancialRecoveryRecord): Promise<void> {
  await financialStore().put(record);
  emitChanged();
}

// Storage errors propagate: an unreadable store is not an empty one.
export async function listFinancialRecords(): Promise<FinancialRecoveryRecord[]> {
  return financialStore().getAll();
}

export async function scopedFinancialRecords(
  staffId: string,
  storeId: string,
): Promise<FinancialRecoveryRecord[]> {
  const records = await listFinancialRecords();
  return records.filter((record) => {
    try {
      const parts: unknown = JSON.parse(record.scope);
      return Array.isArray(parts) && parts[0] === staffId && parts[1] === storeId;
    } catch {
      return false;
    }
  });
}

export async function forgetFinancialRecord(scope: string): Promise<void> {
  await financialStore().delete(scope);
  emitChanged();
}

export async function clearFinancialRecords(): Promise<void> {
  await financialStore().clear();
  emitChanged();
}

export type FinancialRecoveryState = { pending: number; storageUnavailable: boolean };

// What the shell must tell the cashier: unresolved records, or that this
// browser cannot keep them so every payment needs manual reconciliation.
export async function financialRecoveryState(
  staffId: string,
  storeId: string,
): Promise<FinancialRecoveryState> {
  try {
    const records = await scopedFinancialRecords(staffId, storeId);
    return { pending: records.length, storageUnavailable: Boolean(financialStore().volatile) };
  } catch {
    return { pending: 0, storageUnavailable: true };
  }
}
