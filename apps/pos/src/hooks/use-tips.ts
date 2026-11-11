import { useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import { useSession } from './use-session';
import { abandonIfNeeded } from './use-tenders';

export type TipSplitMode = 'equal' | 'by_hours' | 'manual';

export type TipRow = {
  id: string;
  kind: string;
  amount: string;
  currency: string;
  status: 'held' | 'paid_out';
  createdAt: string;
};

export type TipStaff = { staffId: string; name: string; role: string | null };

export type TipDay = {
  businessDate: string;
  held: string;
  paidOut: string;
  tipsAsRevenue: boolean;
  mode: TipSplitMode;
  rows: TipRow[];
  staff: TipStaff[];
};

export type TipShare = { staffId: string; name: string; amount: string };

const MODES: readonly TipSplitMode[] = ['equal', 'by_hours', 'manual'];

function text(value: unknown): string {
  return typeof value === 'string' ? value : '';
}

export function normalizeTipDay(body: { data?: unknown; meta?: unknown }): TipDay {
  const meta = (body.meta ?? {}) as Record<string, unknown>;
  const rule = (meta.rule ?? {}) as Record<string, unknown>;
  const rows = Array.isArray(body.data) ? body.data : [];
  const staff = Array.isArray(meta.staff) ? meta.staff : [];
  return {
    businessDate: text(meta.business_date),
    held: text(meta.held) || '0',
    paidOut: text(meta.paid_out) || '0',
    tipsAsRevenue: meta.tips_as_revenue === true,
    mode: MODES.includes(rule.mode as TipSplitMode) ? (rule.mode as TipSplitMode) : 'equal',
    rows: rows.flatMap((value) => {
      const row = (value ?? {}) as Record<string, unknown>;
      const status = row.status === 'paid_out' ? 'paid_out' : row.status === 'held' ? 'held' : null;
      if (!text(row.id) || !status) return [];
      return [
        {
          id: text(row.id),
          kind: text(row.kind),
          amount: text(row.amount) || '0',
          currency: text(row.currency) || 'VND',
          status,
          createdAt: text(row.created_at),
        },
      ];
    }),
    staff: staff.flatMap((value) => {
      const row = (value ?? {}) as Record<string, unknown>;
      if (!text(row.staff_id)) return [];
      return [{ staffId: text(row.staff_id), name: text(row.name), role: text(row.role) || null }];
    }),
  };
}

// A branch's tips of one business day (the branch's current day by default).
export function useTips(branchId: string | null, businessDate: string, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'tips', snapshot.generation, branchId, businessDate] as const,
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    queryFn: async () => {
      try {
        const result = await session.request<{ data: unknown; meta: unknown }>('GET', '/pos/tips', {
          params: {
            branch_id: branchId ?? undefined,
            ...(businessDate ? { business_date: businessDate } : {}),
          },
        });
        return normalizeTipDay(result);
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
  });
}

// Pays the held tips of the day to the chosen staff; the payouts then wait
// for another person's confirmation like every payout.
export function useTipPayout(branchId: string | null) {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  return async (input: {
    businessDate: string;
    mode: TipSplitMode;
    recipients: { staffId: string; hours?: string; amount?: string }[];
  }) => {
    const key = crypto.randomUUID();
    try {
      const result = await session.request<{ data: { shares?: unknown; total?: unknown } }>(
        'POST',
        '/pos/tips/payout',
        {
          body: {
            idempotency_key: key,
            branch_id: branchId,
            business_date: input.businessDate,
            mode: input.mode,
            recipients: input.recipients.map((row) => ({
              staff_id: row.staffId,
              ...(row.hours ? { hours: row.hours } : {}),
              ...(row.amount ? { amount: row.amount } : {}),
            })),
          },
          idempotencyKey: key,
        },
      );
      const shares = Array.isArray(result.data.shares) ? result.data.shares : [];
      return shares.map((value) => {
        const row = (value ?? {}) as Record<string, unknown>;
        return { staffId: text(row.staff_id), name: text(row.name), amount: text(row.amount) };
      }) as TipShare[];
    } catch (error) {
      abandonIfNeeded(error);
      throw error;
    } finally {
      void queryClient.invalidateQueries({ queryKey: ['pos', 'tips', snapshot.generation] });
    }
  };
}
