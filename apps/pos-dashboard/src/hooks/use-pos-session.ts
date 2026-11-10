import { createContext, useContext } from 'react'
import { useBranchSelection } from './use-branch-selection'
import { usePosContext } from './use-pos-context'

export function useCreatePosSession() {
  const initial = usePosContext()
  const { selection, setSelection } = useBranchSelection(initial.data?.branches)
  const context = usePosContext(selection)
  return { context, selection, setSelection }
}
export const PosSessionContext = createContext<ReturnType<typeof useCreatePosSession> | null>(null)
export function usePosSession() {
  const value = useContext(PosSessionContext)
  if (!value) throw new Error('usePosSession requires the store POS shell')
  return value
}
