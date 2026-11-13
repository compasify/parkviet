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

// Last branch opened in each store, so reopening a store asks for that branch
// straight away instead of listing the branches first.
const branchKey = 'parkviet-pos-dashboard-branches'
function rememberedBranches(): Record<string, string> {
  try {
    const value = JSON.parse(localStorage.getItem(branchKey) ?? '{}')
    return value && typeof value === 'object' ? (value as Record<string, string>) : {}
  } catch {
    return {}
  }
}
export function rememberBranch(storeId: string, branchId: string) {
  const branches = rememberedBranches()
  if (branches[storeId] === branchId) return
  try {
    localStorage.setItem(branchKey, JSON.stringify({ ...branches, [storeId]: branchId }))
  } catch {
    /* Storage may be restricted. */
  }
}
// The branch worth asking for first: the URL's, unless it is the branch last
// used in another store (the store switcher carries `?branch=` along), else
// the branch last used in this store.
export function branchHint(storeId: string, urlBranch: string | undefined): string | null {
  const branches = rememberedBranches()
  const foreign = Object.entries(branches).some(
    ([store, branch]) => store !== storeId && branch === urlBranch,
  )
  if (urlBranch && !foreign) return urlBranch
  return branches[storeId] ?? null
}
