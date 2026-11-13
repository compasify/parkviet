import { useStore } from '@spree/dashboard-core'
import { useParams, useSearch } from '@tanstack/react-router'
import { createContext, useContext, useEffect } from 'react'
import { branchHint, rememberBranch } from '../lib/store-selection'
import { useBranchSelection } from './use-branch-selection'
import { NO_SELECTION, usePosContext } from './use-pos-context'

// The context of a branch also lists every visible branch, so the shell asks
// for the expected branch first: a right guess loads in one round trip instead
// of listing the branches and then loading the chosen one. A wrong guess (the
// branch is gone or hidden) falls back to the plain listing.
export function useCreatePosSession() {
  const { storeId } = useStore()
  const search = useSearch({ strict: false }) as { branch?: string; register?: string }
  const params = useParams({ strict: false }) as { branchId?: string }
  const urlBranch = params.branchId ?? search.branch
  const hintBranch = branchHint(storeId, urlBranch)
  const guess = usePosContext(
    {
      branchId: hintBranch,
      registerId: hintBranch && hintBranch === urlBranch ? (search.register ?? null) : null,
    },
    { retry: false },
  )
  const fallback = guess.isError && hintBranch !== null
  const listing = usePosContext(NO_SELECTION, { enabled: fallback })
  const source = fallback ? listing : guess
  const branches = source.data?.branches
  const { selection, setSelection } = useBranchSelection(branches, hintBranch)
  const scoped = usePosContext(selection, { enabled: branches !== undefined })
  const context = branches === undefined ? source : scoped
  const loadedBranch = scoped.data?.selection.branch_id
  useEffect(() => {
    if (loadedBranch) rememberBranch(storeId, loadedBranch)
  }, [storeId, loadedBranch])
  return { context, selection, setSelection }
}
export const PosSessionContext = createContext<ReturnType<typeof useCreatePosSession> | null>(null)
export function usePosSession() {
  const value = useContext(PosSessionContext)
  if (!value) throw new Error('usePosSession requires the store POS shell')
  return value
}
