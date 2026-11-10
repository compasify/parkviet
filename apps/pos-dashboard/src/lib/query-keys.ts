import type { PosSelection } from '@parkviet/pos-shared/types/pos-context'

export const posKey = (storeId: string, resource: string, ...parts: unknown[]) =>
  ['pos', storeId, resource, ...parts] as const
export const posContextKey = (storeId: string, selection: PosSelection) =>
  posKey(storeId, 'context', selection.branchId, selection.registerId)
