// Unsaved editor work kept in sessionStorage so it survives a forced
// sign-out: session expiry unmounts the editor without a navigation the
// blocker can intercept. A draft is only valid for the server version it was
// based on; once the server moves on, the draft is discarded.
type StoredDraft = { version: number; value: unknown }

const PREFIX = 'pos-dashboard:draft'

// Scoped to the signed-in admin so another account in the same tab never sees it.
export function editorDraftKey(
  kind: string,
  userId: string,
  storeId: string,
  recordId: string,
): string {
  return [PREFIX, kind, userId, storeId, recordId].map(encodeURIComponent).join(':')
}

export function sessionDraftStorage(): Storage | null {
  try {
    return typeof window === 'undefined' ? null : window.sessionStorage
  } catch {
    // Browser privacy settings can block storage access entirely.
    return null
  }
}

function storedDraft(raw: string): StoredDraft | null {
  try {
    const parsed: unknown = JSON.parse(raw)
    return parsed !== null &&
      typeof parsed === 'object' &&
      typeof (parsed as StoredDraft).version === 'number'
      ? (parsed as StoredDraft)
      : null
  } catch {
    return null
  }
}

// Returns the draft when it was based on `version` and passes `parse`;
// otherwise removes whatever is stored under the key and returns null.
export function readEditorDraft<T>(
  storage: Storage | null,
  key: string,
  version: number,
  parse: (value: unknown) => T | null,
): T | null {
  if (!storage) return null
  let raw: string | null
  try {
    raw = storage.getItem(key)
  } catch {
    return null
  }
  if (raw === null) return null
  const stored = storedDraft(raw)
  const value = stored && stored.version === version ? parse(stored.value) : null
  if (value === null) clearEditorDraft(storage, key)
  return value
}

export function writeEditorDraft(
  storage: Storage | null,
  key: string,
  version: number,
  value: unknown,
): boolean {
  if (!storage) return false
  try {
    storage.setItem(key, JSON.stringify({ version, value } satisfies StoredDraft))
    return true
  } catch {
    // Quota exceeded or storage disabled: the in-memory draft still works.
    return false
  }
}

export function clearEditorDraft(storage: Storage | null, key: string): void {
  try {
    storage?.removeItem(key)
  } catch {
    // Nothing to clean up when storage is unavailable.
  }
}
