const key = 'parkviet-pos-dashboard-store'
export function rememberStore(storeId: string) {
  try {
    localStorage.setItem(key, storeId)
  } catch {
    /* Storage may be restricted. */
  }
}
// The default store is listed only when the user holds a role in it.
export function preferredStore(
  stores: readonly { id: string; default?: boolean }[] | undefined | null,
): string | null {
  let remembered: string | null = null
  try {
    remembered = localStorage.getItem(key)
  } catch {
    /* Fall back to the default or first authorized store. */
  }
  return (
    stores?.find((store) => store.id === remembered)?.id ??
    stores?.find((store) => store.default)?.id ??
    stores?.[0]?.id ??
    null
  )
}
