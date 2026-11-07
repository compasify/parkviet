import { useQuery } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import type { PosContext, PosSelection } from '../lib/pos-context';
import { normalizeFeatures } from '../lib/pos-features';
import { posContextKey } from '../lib/query-keys';
import { posFailureKey } from '../lib/request-failure';
import { SessionSuperseded } from '../lib/session-coordinator';
import { useSession } from './use-session';

export function usePosContext(selection: PosSelection) {
  const snapshot = useSession();
  return useQuery({
    queryKey: posContextKey(snapshot.generation, selection),
    enabled: snapshot.status === 'authenticated',
    queryFn: async (): Promise<PosContext> => {
      try {
        const context = await session.fetchContext<PosContext>({
          branch_id: selection.branchId,
          register_id: selection.registerId,
        });
        return { ...context, features: normalizeFeatures(context.features) };
      } catch (error) {
        if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized')
          session.abandon();
        throw error;
      }
    },
  });
}
