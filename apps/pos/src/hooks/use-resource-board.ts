import {
  type ManualStatus,
  normalizeResourceBoard,
  type ResourceBoard,
} from '@parkviet/pos-shared/tables';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import type { PosWorkspace } from '../lib/pos-context';
import { resourceBoardKey } from '../lib/query-keys';
import { pollInterval } from '../lib/realtime';
import { useRealtimeStatus } from './use-branch-events';
import { useSession } from './use-session';
import { abandonIfNeeded } from './use-tenders';

// Without the branch stream the floor is read again every ten seconds.
export const BOARD_FALLBACK_POLL_MS = 10_000;
const APPROVAL_TTL_MS = 30 * 60_000;

// The live floor of the branch. `resource.updated`, `workspace.updated` and
// `payment.requested` invalidate it through the branch stream (lib/realtime).
export function useResourceBoard(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  const realtime = useRealtimeStatus();
  return useQuery({
    queryKey: resourceBoardKey(snapshot.generation, branchId),
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    refetchInterval: pollInterval(realtime, BOARD_FALLBACK_POLL_MS),
    queryFn: async (): Promise<ResourceBoard> => {
      try {
        const result = await session.request<{ data: unknown }>('GET', '/pos/resource_board', {
          params: { branch_id: branchId ?? undefined },
        });
        return normalizeResourceBoard(result.data);
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
  });
}

async function post<T>(path: string, body: Record<string, unknown>): Promise<T> {
  const key = crypto.randomUUID();
  try {
    return await session.request<T>('POST', path, {
      body: { ...body, idempotency_key: key },
      idempotencyKey: key,
    });
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

export function useTableCommands(branchId: string | null) {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  const refreshBoard = () =>
    queryClient.invalidateQueries({ queryKey: resourceBoardKey(snapshot.generation) });
  return {
    refreshBoard,
    // Being cleaned, or ready for guests again.
    async setManualStatus(resourceId: string, manualStatus: ManualStatus) {
      try {
        await post(`/pos/resources/${resourceId}/manual_status`, { manual_status: manualStatus });
      } finally {
        await refreshBoard();
      }
    },
    // Records a pre-bill of a table order; with a printer it is queued there.
    // The answer carries the pre-bill and the print job when one was queued.
    async prebill(
      workspace: PosWorkspace,
      input: { approvalId?: string; printerId?: string; templateId?: string },
      key: string,
    ) {
      try {
        return await session.request<{ data: { print_job?: unknown } }>(
          'POST',
          `/pos/workspaces/${workspace.id}/prebill`,
          {
            body: {
              idempotency_key: key,
              ...(input.approvalId ? { approval_id: input.approvalId } : {}),
              ...(input.printerId ? { printer_id: input.printerId } : {}),
              ...(input.templateId ? { receipt_template_id: input.templateId } : {}),
            },
            idempotencyKey: key,
          },
        );
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      } finally {
        void refreshBoard();
      }
    },
    async cancelPrebill(workspace: PosWorkspace, approvalId: string) {
      try {
        await post(`/pos/workspaces/${workspace.id}/prebill/cancel`, { approval_id: approvalId });
      } finally {
        void refreshBoard();
      }
    },
    // A manager working the order approves one action on it as it stands
    // now; the approval is spent by the very next command.
    async approve(workspace: PosWorkspace, requesterId: string, action: string) {
      try {
        const result = await session.request<{ data: { id: string } }>('POST', '/pos/approvals', {
          body: {
            branch_id: branchId ?? workspace.branch_id,
            workspace_id: workspace.id,
            requester_id: requesterId,
            revision: workspace.revision,
            action_name: action,
            expires_at: new Date(Date.now() + APPROVAL_TTL_MS).toISOString(),
          },
        });
        return result.data.id;
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
  };
}
