import type { PosMenu } from './pos-context';

// What a counter keeps in this browser to sell cash sales while the server
// is out of reach: the last offline snapshot of its register and the sales
// it made since, until the server has them. Never a token, an email or a
// customer: the snapshot names the cashier by id and display name only.

export type OfflineSnapshot = {
  store: {
    id: string;
    name: string;
    currency: string;
    profile?: Record<string, string | null> | null;
  };
  branch: { id: string; name: string; code: string | null; timezone: string | null };
  register: { id: string; name: string; code: string | null };
  staff: { id: string; name: string };
  shift: { id: string; opened_at: string | null } | null;
  offline: { allowed: boolean; reason: string | null };
  menu: PosMenu | null;
  etag: string;
  generated_at: string;
  max_age_seconds: number;
};

// The snapshot as stored: `savedAt` is this browser's clock when it arrived.
export type StoredSnapshot = { data: OfflineSnapshot; savedAt: number };

export type OfflineSaleLine = {
  variant_id: string;
  quantity: number;
  modifiers: Array<{ option_id: string; quantity: number }>;
  note: string | null;
  // What the counter showed, kept to compare: the server prices the line again.
  name: string;
  unit_price: string;
  // Display only (the slip and the queue): the options as the cashier saw them.
  modifier_names?: string[];
};

export type QueuedSale = {
  offlineId: string;
  staffId: string;
  storeId: string;
  branchId: string;
  registerId: string;
  shiftId: string;
  provisionalNumber: string;
  soldAt: string;
  total: string;
  handedAmount: string;
  currency: string;
  lines: OfflineSaleLine[];
  // `failed`: the server refused it for good (shown, kept, sent again on request).
  status: 'pending' | 'failed';
  attempts: number;
  lastError: string | null;
  savedAt: number;
};

export type OfflineDb = {
  getSnapshot(): Promise<StoredSnapshot | null>;
  putSnapshot(snapshot: StoredSnapshot | null): Promise<void>;
  // The next provisional sequence of a register for a day, kept across reloads.
  nextSequence(counter: string): Promise<number>;
  putSale(sale: QueuedSale): Promise<void>;
  sales(): Promise<QueuedSale[]>;
  deleteSale(offlineId: string): Promise<void>;
  // Data vanishes with the page: the browser offered no durable storage.
  volatile?: boolean;
};

export const OFFLINE_CHANGED = 'pos:offline-changed';

export function createMemoryOfflineDb(): OfflineDb {
  let snapshot: StoredSnapshot | null = null;
  const counters = new Map<string, number>();
  const sales = new Map<string, QueuedSale>();
  return {
    async getSnapshot() {
      return snapshot;
    },
    async putSnapshot(next) {
      snapshot = next;
    },
    async nextSequence(counter) {
      const next = (counters.get(counter) ?? 0) + 1;
      counters.set(counter, next);
      return next;
    },
    async putSale(sale) {
      sales.set(sale.offlineId, structuredClone(sale));
    },
    async sales() {
      return [...sales.values()].map((sale) => structuredClone(sale));
    },
    async deleteSale(offlineId) {
      sales.delete(offlineId);
    },
  };
}

const DB_NAME = 'parkviet-pos-offline';
const SNAPSHOT_KEY = 'snapshot';

function openDb(): Promise<IDBDatabase> {
  return new Promise((resolve, reject) => {
    const request = indexedDB.open(DB_NAME, 1);
    request.onupgradeneeded = () => {
      const db = request.result;
      if (!db.objectStoreNames.contains('meta')) db.createObjectStore('meta', { keyPath: 'key' });
      if (!db.objectStoreNames.contains('sales'))
        db.createObjectStore('sales', { keyPath: 'offlineId' });
    };
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error ?? new Error('indexeddb-unavailable'));
    request.onblocked = () => reject(new Error('indexeddb-blocked'));
  });
}

function transact<T>(
  connection: () => Promise<IDBDatabase>,
  name: 'meta' | 'sales',
  mode: IDBTransactionMode,
  run: (store: IDBObjectStore, done: (value: T) => void) => void,
): Promise<T> {
  return connection().then(
    (db) =>
      new Promise<T>((resolve, reject) => {
        const transaction = db.transaction(name, mode);
        let result: T;
        transaction.oncomplete = () => resolve(result);
        transaction.onerror = () => reject(transaction.error ?? new Error('indexeddb-transaction'));
        // Quota exhaustion aborts without an error event.
        transaction.onabort = () => reject(transaction.error ?? new Error('indexeddb-aborted'));
        run(transaction.objectStore(name), (value) => {
          result = value;
        });
      }),
  );
}

export function createIndexedDbOfflineDb(): OfflineDb {
  let cached: Promise<IDBDatabase> | null = null;
  const connection = () => {
    cached ??= openDb().then(
      (db) => {
        db.onversionchange = () => {
          db.close();
          cached = null;
        };
        db.onclose = () => {
          cached = null;
        };
        return db;
      },
      (error: unknown) => {
        cached = null;
        throw error;
      },
    );
    return cached;
  };
  return {
    getSnapshot() {
      return transact<StoredSnapshot | null>(connection, 'meta', 'readonly', (store, done) => {
        const request = store.get(SNAPSHOT_KEY);
        request.onsuccess = () => {
          const row = request.result as { value?: StoredSnapshot } | undefined;
          done(row?.value ?? null);
        };
      });
    },
    putSnapshot(snapshot) {
      return transact<void>(connection, 'meta', 'readwrite', (store) => {
        if (snapshot) store.put({ key: SNAPSHOT_KEY, value: snapshot });
        else store.delete(SNAPSHOT_KEY);
      });
    },
    nextSequence(counter) {
      // Read and write in one transaction, so two tabs never take the same number.
      return transact<number>(connection, 'meta', 'readwrite', (store, done) => {
        const key = `sequence:${counter}`;
        const request = store.get(key);
        request.onsuccess = () => {
          const row = request.result as { value?: number } | undefined;
          const next = (row?.value ?? 0) + 1;
          store.put({ key, value: next });
          done(next);
        };
      });
    },
    putSale(sale) {
      return transact<void>(connection, 'sales', 'readwrite', (store) => {
        store.put(sale);
      });
    },
    sales() {
      return transact<QueuedSale[]>(connection, 'sales', 'readonly', (store, done) => {
        const request = store.getAll();
        request.onsuccess = () => done(request.result as QueuedSale[]);
      });
    },
    deleteSale(offlineId) {
      return transact<void>(connection, 'sales', 'readwrite', (store) => {
        store.delete(offlineId);
      });
    },
  };
}

let active: OfflineDb | null = null;

export function setOfflineDb(db: OfflineDb | null) {
  active = db;
}

export function offlineDb(): OfflineDb {
  if (!active) {
    try {
      active =
        typeof indexedDB === 'undefined'
          ? { ...createMemoryOfflineDb(), volatile: true }
          : createIndexedDbOfflineDb();
    } catch {
      active = { ...createMemoryOfflineDb(), volatile: true };
    }
  }
  return active;
}

export function emitOfflineChanged() {
  globalThis.dispatchEvent?.(new Event(OFFLINE_CHANGED));
}

// The sales of one cashier at one store, oldest sale first: the order they
// are sent in.
export async function queuedSales(staffId: string, storeId: string): Promise<QueuedSale[]> {
  const rows = await offlineDb().sales();
  return rows
    .filter((sale) => sale.staffId === staffId && sale.storeId === storeId)
    .sort((left, right) =>
      left.soldAt === right.soldAt
        ? left.savedAt - right.savedAt
        : left.soldAt < right.soldAt
          ? -1
          : 1,
    );
}
