const key = 'parkviet-pos-dashboard-store'
export function rememberStore(storeId: string) {
  try {
    localStorage.setItem(key, storeId)
  } catch {
    /* Storage may be restricted. */
  }
}
export function preferredStore(
  stores: readonly { id: string }[] | undefined | null,
): string | null {
  let remembered: string | null = null
  try {
    remembered = localStorage.getItem(key)
  } catch {
    /* Fall back to first authorized store. */
  }
  return stores?.find((store) => store.id === remembered)?.id ?? stores?.[0]?.id ?? null
}
