import type { PrintDocument } from '@parkviet/pos-shared/receipt-template/types';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import { runFinancialCommand } from '../lib/financial-command';
import {
  type MealAccount,
  type MealPlan,
  type MealStatus,
  normalizeMealAccount,
  normalizeMealAccounts,
  normalizeMealEntries,
  normalizeMealPlan,
  normalizeMealStatus,
} from '../lib/meal-accounts';
import type { PosWorkspace } from '../lib/pos-context';
import { useSession } from './use-session';
import { abandonIfNeeded, financialRequest } from './use-tenders';

export type MealLookup = { match: MealAccount | null; suggestions: MealAccount[] };

async function read<T>(path: string, params: Record<string, string | undefined>) {
  try {
    return await session.request<T>('GET', path, { params });
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

// Finds the eater typed at the counter: an exact employee code, or names
// holding the text. Rate limited per staff member on the server.
export async function resolveMealAccount(branchId: string, q: string): Promise<MealLookup> {
  const result = await read<{ data: { match?: unknown; suggestions?: unknown } }>(
    '/pos/meal_accounts/resolve',
    { branch_id: branchId, q },
  );
  return {
    match: normalizeMealAccount(result.data?.match),
    suggestions: normalizeMealAccounts(result.data?.suggestions),
  };
}

const mealKey = (generation: number) => ['pos', 'meal-accounts', generation] as const;

// The accounts of a store with their balances, found by code, name or group.
export function useMealAccounts(
  branchId: string | null,
  query: string,
  status: 'active' | 'locked' | 'all',
  enabled: boolean,
) {
  const snapshot = useSession();
  const q = query.trim();
  return useQuery({
    queryKey: [...mealKey(snapshot.generation), 'list', branchId, status, q] as const,
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    placeholderData: (previous) => previous,
    queryFn: async () => {
      const result = await read<{ data: unknown }>('/pos/meal_accounts', {
        branch_id: branchId ?? undefined,
        ...(status === 'all' ? {} : { status }),
        ...(q ? { q } : {}),
      });
      return normalizeMealAccounts(result.data);
    },
  });
}

export function useMealAccount(branchId: string | null, id: string | null) {
  const snapshot = useSession();
  return useQuery({
    queryKey: [...mealKey(snapshot.generation), 'one', branchId, id] as const,
    enabled: snapshot.status === 'authenticated' && Boolean(branchId && id),
    queryFn: async () => {
      const result = await read<{ data: unknown }>(`/pos/meal_accounts/${id}`, {
        branch_id: branchId ?? undefined,
      });
      return normalizeMealAccount(result.data);
    },
  });
}

// The wallet's history, newest first.
export function useMealEntries(branchId: string | null, id: string | null) {
  const snapshot = useSession();
  return useQuery({
    queryKey: [...mealKey(snapshot.generation), 'entries', branchId, id] as const,
    enabled: snapshot.status === 'authenticated' && Boolean(branchId && id),
    queryFn: async () => {
      const result = await read<{ data: unknown }>(`/pos/meal_accounts/${id}/entries`, {
        branch_id: branchId ?? undefined,
      });
      return normalizeMealEntries(result.data);
    },
  });
}

// The eater on an order and who pays what, read again with every revision
// (a new line changes the split).
export function useWorkspaceMeal(workspace: PosWorkspace | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'workspace-meal', snapshot.generation, workspace?.id, workspace?.revision],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(workspace),
    // The previous revision of the same order stays on screen while the new
    // one loads; another order's eater never does.
    placeholderData: (previous, previousQuery) =>
      previousQuery?.queryKey[3] === workspace?.id ? previous : undefined,
    queryFn: async (): Promise<{ meal: MealStatus | null; plan: MealPlan | null }> => {
      const result = await read<{ data: { meal?: unknown; plan?: unknown } }>(
        `/pos/workspaces/${workspace?.id}/meal`,
        {},
      );
      return {
        meal: normalizeMealStatus(result.data?.meal),
        plan: normalizeMealPlan(result.data?.plan),
      };
    },
  });
}

export type MealTopUpInput = {
  kind: 'cash' | 'bank_manual';
  amount: string;
  handedAmount?: string;
  reference?: string;
  receivingAccount?: string;
};

export type MealTopUpResult = { account: MealAccount | null; document: PrintDocument | null };

// Topping up, paying back and correcting a wallet. Each is a money command:
// a lost answer is checked against its receipt before anything is resent.
export function useMealAccountCommands(
  branchId: string | null,
  staffId: string | null,
  storeId: string | null,
) {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  const refresh = () => queryClient.invalidateQueries({ queryKey: mealKey(snapshot.generation) });
  async function run<T>(account: MealAccount, action: string, verb: string, body: object) {
    try {
      const result = await runFinancialCommand<T>(financialRequest, {
        staffId,
        storeId,
        scopeId: account.id,
        action,
        path: `/pos/meal_accounts/${account.id}/${verb}`,
        body: { branch_id: branchId, ...body },
      });
      return result.data;
    } catch (error) {
      abandonIfNeeded(error);
      throw error;
    } finally {
      void refresh();
    }
  }
  return {
    async topUp(account: MealAccount, input: MealTopUpInput): Promise<MealTopUpResult> {
      const data = await run<{ account?: unknown; document?: PrintDocument }>(
        account,
        'meal_wallet.top_up',
        'top_ups',
        {
          kind: input.kind,
          amount: input.amount,
          ...(input.kind === 'cash' && input.handedAmount
            ? { handed_amount: input.handedAmount }
            : {}),
          ...(input.kind === 'bank_manual'
            ? { reference: input.reference, receiving_account: input.receivingAccount }
            : {}),
        },
      );
      return { account: normalizeMealAccount(data?.account), document: data?.document ?? null };
    },
    // The whole balance unless an amount is given.
    async refund(
      account: MealAccount,
      input: { amount?: string; beneficiaryName?: string; reason?: string; approvalId?: string },
    ) {
      const data = await run<{ account?: unknown }>(account, 'meal_wallet.refund', 'refund', {
        ...(input.amount ? { amount: input.amount } : {}),
        ...(input.beneficiaryName ? { beneficiary_name: input.beneficiaryName } : {}),
        ...(input.reason ? { reason: input.reason } : {}),
        ...(input.approvalId ? { approval_id: input.approvalId } : {}),
      });
      return normalizeMealAccount(data?.account);
    },
    // `amount` is signed: "-10000" takes money off the wallet.
    async adjust(
      account: MealAccount,
      input: { amount: string; note: string; approvalId?: string },
    ) {
      const data = await run<{ account?: unknown }>(account, 'meal_wallet.adjust', 'adjust', {
        amount: input.amount,
        note: input.note,
        ...(input.approvalId ? { approval_id: input.approvalId } : {}),
      });
      return normalizeMealAccount(data?.account);
    },
  };
}
