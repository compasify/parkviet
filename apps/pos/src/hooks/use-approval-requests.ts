import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import {
  type ApprovalAsk,
  type ApprovalRequest,
  type ApprovalSubject,
  approvalRequestBody,
  normalizeApprovalRequest,
} from '../lib/approval-requests';
import { pollInterval } from '../lib/realtime';
import { useRealtimeStatus } from './use-branch-events';
import { useSession } from './use-session';

export const approvalRequestsKey = (generation: number) =>
  ['pos', 'approval-requests', generation] as const;

function parsed(result: { data: unknown }): ApprovalRequest {
  const request = normalizeApprovalRequest(result.data);
  if (!request) throw new Error('approval request');
  return request;
}

// One request while the counter waits on it: read again on its events, and
// every few seconds while the branch stream is down.
export function useApprovalRequest(id: string | null) {
  const snapshot = useSession();
  const realtime = useRealtimeStatus();
  return useQuery({
    queryKey: [...approvalRequestsKey(snapshot.generation), id] as const,
    enabled: snapshot.status === 'authenticated' && Boolean(id),
    refetchInterval: (query) =>
      query.state.data?.status === 'pending' ? pollInterval(realtime, 5_000) : false,
    queryFn: async () =>
      parsed(await session.request<{ data: unknown }>('GET', `/pos/approval_requests/${id}`)),
  });
}

export function useApprovalRequestCommands() {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  const remember = (request: ApprovalRequest) => {
    queryClient.setQueryData([...approvalRequestsKey(snapshot.generation), request.id], request);
    return request;
  };
  const ask = useMutation({
    mutationFn: async (input: {
      branchId: string;
      subject: ApprovalSubject;
      ask: ApprovalAsk;
      reason?: string;
    }) => {
      const key = crypto.randomUUID();
      return remember(
        parsed(
          await session.request<{ data: unknown }>('POST', '/pos/approval_requests', {
            body: approvalRequestBody(input.branchId, input.subject, input.ask, input.reason),
            idempotencyKey: key,
          }),
        ),
      );
    },
  });
  const cancel = useMutation({
    mutationFn: async (id: string) =>
      remember(
        parsed(
          await session.request<{ data: unknown }>('POST', `/pos/approval_requests/${id}/cancel`, {
            idempotencyKey: crypto.randomUUID(),
          }),
        ),
      ),
  });
  return { ask, cancel };
}
