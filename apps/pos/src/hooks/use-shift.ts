import { useMutation, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import type { PosShift } from '../lib/pos-context';
import { posFailureKey } from '../lib/request-failure';
import { SessionSuperseded } from '../lib/session-coordinator';
import { useSession } from './use-session';

export function useOpenShift() {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (body: {
      register_id?: string;
      branch_id?: string;
      opening_float: string;
    }) => {
      try {
        return await session.request<{ data: PosShift }>('POST', '/pos/shifts', { body });
      } catch (error) {
        if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized') {
          session.abandon();
        }
        throw error;
      }
    },
    onSuccess: async () => {
      await queryClient.invalidateQueries({ queryKey: ['pos', 'context', snapshot.generation] });
    },
  });
}
