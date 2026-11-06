export const LAYOUT_TTL_MS = 12 * 60 * 60 * 1000;
const STORAGE_KEY = 'parkviet-pos-layout';
const forbidden = ['token', 'password', 'email', 'authorization', 'cookie', 'refresh'];

export type PosLayout = {
  staffId: string;
  storeId: string;
  savedAt: number;
  branchId: string | null;
  registerId: string | null;
  openWorkspaceIds: string[];
  closedWorkspaceIds?: string[];
  activeWorkspaceId?: string | null;
  workspacePage?: number;
  tabNumbers?: Record<string, number>;
};

type KeyValueStore = {
  getItem: (key: string) => string | null;
  setItem: (key: string, value: string) => void;
  removeItem: (key: string) => void;
};

function browserStore(): KeyValueStore | null {
  const storage = globalThis.localStorage;
  if (!storage) return null;
  return storage;
}

function clean(value: unknown, staffId: string, storeId: string, now: number): PosLayout | null {
  if (typeof value !== 'object' || value === null) return null;
  const record = value as Record<string, unknown>;
  if (forbidden.some((key) => key in record)) return null;
  if (record.staffId !== staffId || record.storeId !== storeId) return null;
  if (typeof record.savedAt !== 'number' || now - record.savedAt > LAYOUT_TTL_MS) return null;
  const openWorkspaceIds = Array.isArray(record.openWorkspaceIds)
    ? record.openWorkspaceIds.filter((item) => typeof item === 'string').slice(0, 50)
    : [];
  return {
    staffId,
    storeId,
    savedAt: record.savedAt,
    branchId: typeof record.branchId === 'string' ? record.branchId : null,
    registerId: typeof record.registerId === 'string' ? record.registerId : null,
    openWorkspaceIds,
    tabNumbers:
      typeof record.tabNumbers === 'object' &&
      record.tabNumbers !== null &&
      !Array.isArray(record.tabNumbers)
        ? Object.fromEntries(
            Object.entries(record.tabNumbers)
              .filter(
                ([id, value]) =>
                  id.length <= 200 &&
                  Number.isSafeInteger(value) &&
                  Number(value) > 0 &&
                  Number(value) <= 10000,
              )
              .slice(0, 200),
          )
        : {},
    closedWorkspaceIds: Array.isArray(record.closedWorkspaceIds)
      ? record.closedWorkspaceIds.filter((item) => typeof item === 'string').slice(0, 200)
      : [],
    activeWorkspaceId:
      typeof record.activeWorkspaceId === 'string' ? record.activeWorkspaceId : null,
    workspacePage:
      typeof record.workspacePage === 'number' &&
      Number.isSafeInteger(record.workspacePage) &&
      record.workspacePage > 0 &&
      record.workspacePage <= 10000
        ? record.workspacePage
        : 1,
  };
}

export function readLayout(
  staffId: string,
  storeId: string,
  storage: KeyValueStore | null = browserStore(),
  now = Date.now(),
) {
  if (!storage) return null;
  try {
    const parsed = JSON.parse(storage.getItem(STORAGE_KEY) ?? 'null') as unknown;
    const layout = clean(parsed, staffId, storeId, now);
    if (!layout) storage.removeItem(STORAGE_KEY);
    return layout;
  } catch {
    storage.removeItem(STORAGE_KEY);
    return null;
  }
}

export function writeLayout(layout: PosLayout, storage: KeyValueStore | null = browserStore()) {
  if (!storage) return;
  const stored = clean(
    { ...layout, savedAt: layout.savedAt },
    layout.staffId,
    layout.storeId,
    layout.savedAt,
  );
  if (!stored) return;
  storage.setItem(STORAGE_KEY, JSON.stringify(stored));
}

export function clearLayout(storage: KeyValueStore | null = browserStore()) {
  storage?.removeItem(STORAGE_KEY);
}
