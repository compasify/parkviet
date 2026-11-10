import type { PosContext } from '@parkviet/pos-shared/types/pos-context'

export function administrationAccess(context?: PosContext) {
  return context?.administration ?? { read: false, write: false }
}
