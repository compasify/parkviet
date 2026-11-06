import { useSyncExternalStore } from 'react';
import { session } from '../lib/app-session';

export function useSession() {
  return useSyncExternalStore(session.subscribe, session.getSnapshot, session.getSnapshot);
}
