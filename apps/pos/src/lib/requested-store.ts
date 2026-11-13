const IDENTITY = /^[A-Za-z0-9_-]+$/;

function readParam(search: string, key: string): string | null {
  const value = new URLSearchParams(search).get(key);
  return value && IDENTITY.test(value) ? value : null;
}

// The store named on the address the dashboard opened, or nothing.
export function requestedStoreId(search: string): string | null {
  return readParam(search, 'store');
}

// The branch the dashboard had open, kept only for the store it belongs to.
// A later switch to another store must not reuse that branch id.
type Handoff = { storeId: string; branchId: string };
let handoff: Handoff | null = null;

export function captureHandoff(search: string, rememberStore: (storeId: string) => void) {
  const storeId = requestedStoreId(search);
  const branchId = readParam(search, 'branch');
  if (storeId) rememberStore(storeId);
  if (storeId && branchId) handoff = { storeId, branchId };
}

export function handoffBranch(storeId: string): string | null {
  return handoff?.storeId === storeId ? handoff.branchId : null;
}

export function clearRequestedHandoff() {
  handoff = null;
}
