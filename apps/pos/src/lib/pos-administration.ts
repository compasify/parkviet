import type { PosContext } from './pos-context';

export function administrationAccess(context?: PosContext) {
  // Branch capabilities alone never authorize store-level administration.
  return context?.administration ?? { read: false, write: false };
}
