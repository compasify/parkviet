import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useEffect, useState } from 'react';
import { session } from '../lib/app-session';
import { runFinancialCommand } from '../lib/financial-command';
import { FINANCIAL_RECOVERY_CHANGED, scopedFinancialRecords } from '../lib/financial-recovery';
import type {
  PosCollection,
  PosCreditRequest,
  PosCreditReservation,
  PosReceivable,
  PosReceivableAccount,
  PosWorkspace,
  PosWorkspaceCredit,
} from '../lib/pos-context';
import { pollInterval } from '../lib/realtime';
import type { AllocationDraft } from '../lib/receivables';
import { useRealtimeStatus } from './use-branch-events';
import { useSession } from './use-session';
import { abandonIfNeeded, financialRequest } from './use-tenders';
import { workspaceEditorId } from './use-workspaces';

export type ReceivableStatus = 'open' | 'overdue' | 'all';

export const COLLECTIONS_PATH = '/pos/collections';

type Page<T> = { data: T[]; meta: { page: number; pages: number; count: number } };

async function read<T>(path: string, params?: Record<string, string | undefined>): Promise<T> {
  try {
    return await session.request<T>('GET', path, { params });
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

// Non-money writes still carry an idempotency key; one per user action.
async function write<T>(method: 'POST' | 'PATCH', path: string, body: Record<string, unknown>) {
  const key = crypto.randomUUID();
  try {
    return await session.request<{ data: T }>(method, path, {
      body: { ...body, idempotency_key: key },
      idempotencyKey: key,
    });
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

export function useReceivables(
  branchId: string | null,
  filters: { status: ReceivableStatus; customerId: string | null; page: number },
  enabled: boolean,
) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'receivables', snapshot.generation, branchId, filters],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    queryFn: () =>
      read<Page<PosReceivable>>('/pos/receivables', {
        branch_id: branchId ?? undefined,
        status: filters.status,
        customer_id: filters.customerId ?? undefined,
        page: String(filters.page),
        limit: '50',
      }),
  });
}

export function useReceivableAccounts(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'receivables', snapshot.generation, branchId, 'accounts'],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    queryFn: () =>
      read<{
        data: PosReceivableAccount[];
        meta: { count: number; totals: Record<string, string> };
      }>('/pos/receivables/customers', { branch_id: branchId ?? undefined }),
  });
}

// Credit terms, the cashier's request and the approval currently holding
// exposure for one draft. Polls while the cashier waits for a manager.
export function useWorkspaceCredit(
  workspace: PosWorkspace | null,
  enabled: boolean,
  poll?: (data: PosWorkspaceCredit | undefined) => boolean,
) {
  const snapshot = useSession();
  const realtime = useRealtimeStatus();
  return useQuery({
    queryKey: [
      'pos',
      'workspace-credit',
      snapshot.generation,
      workspace?.id ?? null,
      workspace?.revision,
    ],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(workspace),
    // A manager's answer runs as a command on this workspace, which publishes
    // `workspace.updated`, so an open socket delivers it without the poll.
    refetchInterval: (query) => (poll?.(query.state.data) ? pollInterval(realtime, 5000) : false),
    queryFn: async () =>
      (await read<{ data: PosWorkspaceCredit }>(`/pos/workspaces/${workspace?.id}/credit`)).data,
  });
}

// The cashier asks a manager to approve the unpaid remainder; the server keeps
// one request per workspace revision, so asking twice is harmless.
export function useRequestCredit() {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (workspace: PosWorkspace) => {
      const result = await write<PosCreditRequest>(
        'POST',
        `/pos/workspaces/${workspace.id}/credit_requests`,
        {
          expected_revision: workspace.revision,
          lease_generation: workspace.lease_generation,
          editor_id: workspaceEditorId,
        },
      );
      await queryClient.invalidateQueries({
        queryKey: ['pos', 'workspace-credit', snapshot.generation, workspace.id],
      });
      return result.data;
    },
  });
}

// Quick credit (one-person shops): the cashier approves the unpaid remainder
// themselves; the server opens a credit account with default terms when the
// customer has none. Only reserves exposure, so a retry with a new key just
// supersedes the earlier reservation. The caller then completes on it.
export async function quickApproveCredit(workspace: PosWorkspace) {
  const result = await write<PosCreditReservation>(
    'POST',
    `/pos/workspaces/${workspace.id}/quick_credit`,
    {
      expected_revision: workspace.revision,
      lease_generation: workspace.lease_generation,
      editor_id: workspaceEditorId,
    },
  );
  return result.data;
}

export type CollectInput = {
  branchId: string;
  creditAccountId: string;
  kind: 'cash' | 'bank_manual';
  amount: string;
  handedAmount?: string;
  reference?: string;
  receivingAccount?: string;
  note?: string;
  allocations: AllocationDraft[];
};

// Collection commands of one credit account share one named intent: a retry
// after a lost response keeps the first key even if the cashier corrected
// the form, and a committed receipt is returned instead of being recorded
// a second time.
export function useCollections(staffId: string | null, storeId: string | null) {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (
      input: CollectInput,
    ): Promise<{ collection: PosCollection; recovered: boolean }> => {
      try {
        const result = await runFinancialCommand<PosCollection>(financialRequest, {
          staffId,
          storeId,
          scopeId: input.creditAccountId,
          action: 'collection.receive',
          path: COLLECTIONS_PATH,
          intent: 'receipt',
          body: {
            branch_id: input.branchId,
            credit_account_id: input.creditAccountId,
            kind: input.kind,
            amount: input.amount,
            handed_amount: input.kind === 'cash' ? input.handedAmount : undefined,
            reference: input.kind === 'bank_manual' ? input.reference : undefined,
            receiving_account: input.kind === 'bank_manual' ? input.receivingAccount : undefined,
            note: input.note || undefined,
            allocations: input.allocations.map((row) => ({
              order_id: row.orderId,
              amount: row.amount,
            })),
          },
        });
        return { collection: result.data, recovered: result.recovered };
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      } finally {
        await Promise.all([
          queryClient.invalidateQueries({ queryKey: ['pos', 'receivables', snapshot.generation] }),
          queryClient.invalidateQueries({
            queryKey: ['pos', 'received-funds', snapshot.generation],
          }),
        ]);
      }
    },
  });
}

// Settles a collection whose outcome this browser never learned: its receipt
// is looked up under the original key, and only if the server never committed
// it is the very same stored command sent again under that key.
export function useRecheckCollection(staffId: string | null, storeId: string | null) {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: async (accountId: string) => {
      if (!staffId || !storeId) return null;
      const record = (await scopedFinancialRecords(staffId, storeId)).find(
        (item) => item.path === COLLECTIONS_PATH && item.workspaceId === accountId,
      );
      if (!record) return null;
      try {
        const result = await runFinancialCommand<PosCollection>(financialRequest, {
          staffId,
          storeId,
          scopeId: accountId,
          action: 'collection.receive',
          path: COLLECTIONS_PATH,
          intent: 'receipt',
          body: record.body,
        });
        return { collection: result.data, recovered: result.recovered };
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      } finally {
        await queryClient.invalidateQueries({
          queryKey: ['pos', 'receivables', snapshot.generation],
        });
      }
    },
  });
}

// Credit accounts with a collection this browser sent without learning the
// outcome. New collections for them wait until that outcome is known.
export function usePendingCollections(staffId: string | null, storeId: string | null) {
  const [state, setState] = useState<{ accounts: string[]; unavailable: boolean }>({
    accounts: [],
    unavailable: false,
  });
  const [version, setVersion] = useState(0);
  useEffect(() => {
    const changed = () => setVersion((value) => value + 1);
    window.addEventListener(FINANCIAL_RECOVERY_CHANGED, changed);
    return () => window.removeEventListener(FINANCIAL_RECOVERY_CHANGED, changed);
  }, []);
  useEffect(() => {
    void version;
    if (!staffId || !storeId) return;
    let active = true;
    scopedFinancialRecords(staffId, storeId).then(
      (records) => {
        if (!active) return;
        const accounts = records
          .filter((record) => record.path === COLLECTIONS_PATH)
          .map((record) => record.workspaceId);
        setState({ accounts, unavailable: false });
      },
      () => {
        if (active) setState({ accounts: [], unavailable: true });
      },
    );
    return () => {
      active = false;
    };
  }, [staffId, storeId, version]);
  return {
    ...state,
    refresh: () => setVersion((value) => value + 1),
  };
}
