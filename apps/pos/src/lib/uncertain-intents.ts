const STORAGE_KEY = 'parkviet-pos-uncertain-intents';
const TTL = 12 * 60 * 60 * 1000;
export const INTENTS_CHANGED = 'pos:uncertain-intents-changed';

type Entry = { key: string; savedAt: number };
// In-memory only: after a reload, every durable unresolved record must become
// uncertain again. Never persist a flag that could hide a lost response.
const pending = new Map<string, number>();

export function beginIntent(scope: string): string {
  if (!hasIntent(scope) || pending.has(scope)) pending.set(scope, (pending.get(scope) ?? 0) + 1);
  try {
    return intentKey(scope);
  } catch (error) {
    finishIntent(scope);
    throw error;
  }
}

export function finishIntent(scope: string) {
  const count = pending.get(scope) ?? 0;
  if (count <= 1) pending.delete(scope);
  else pending.set(scope, count - 1);
  globalThis.dispatchEvent?.(new Event(INTENTS_CHANGED));
}

export function hasPendingIntents(): boolean {
  return pending.size > 0;
}

function read(): Record<string, Entry> {
  try {
    const parsed = JSON.parse(sessionStorage.getItem(STORAGE_KEY) ?? '{}') as Record<string, Entry>;
    return Object.fromEntries(
      Object.entries(parsed).filter(
        ([, entry]) =>
          typeof entry?.key === 'string' &&
          typeof entry.savedAt === 'number' &&
          Date.now() - entry.savedAt < TTL,
      ),
    );
  } catch {
    return {};
  }
}

export function intentKey(scope: string): string {
  const entries = read();
  if (entries[scope]) return entries[scope].key;
  const key = crypto.randomUUID();
  entries[scope] = { key, savedAt: Date.now() };
  sessionStorage.setItem(STORAGE_KEY, JSON.stringify(entries));
  globalThis.dispatchEvent?.(new Event(INTENTS_CHANGED));
  return key;
}

export function hasIntent(scope: string): boolean {
  return Boolean(read()[scope]);
}

export function forgetIntent(scope: string) {
  const entries = read();
  delete entries[scope];
  sessionStorage.setItem(STORAGE_KEY, JSON.stringify(entries));
  globalThis.dispatchEvent?.(new Event(INTENTS_CHANGED));
}

export function hasUncertainIntents(staffId?: string, storeId?: string): boolean {
  return Object.keys(read()).some((scope) => {
    if (pending.has(scope)) return false;
    if (!staffId || !storeId) return true;
    try {
      const parts: unknown = JSON.parse(scope);
      return Array.isArray(parts) && parts[0] === staffId && parts[1] === storeId;
    } catch {
      return false;
    }
  });
}

export function scopedIntents(
  staffId: string,
  storeId: string,
): Array<{ scope: string; key: string }> {
  return Object.entries(read()).flatMap(([scope, entry]) => {
    if (pending.has(scope)) return [];
    try {
      const parts: unknown = JSON.parse(scope);
      return Array.isArray(parts) && parts[0] === staffId && parts[1] === storeId
        ? [{ scope, key: entry.key }]
        : [];
    } catch {
      return [];
    }
  });
}

export function clearIntents() {
  pending.clear();
  sessionStorage.removeItem(STORAGE_KEY);
  globalThis.dispatchEvent?.(new Event(INTENTS_CHANGED));
}
