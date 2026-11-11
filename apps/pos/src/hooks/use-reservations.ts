import {
  type AvailableTable,
  normalizeAvailableTables,
  normalizeReservation,
  normalizeReservations,
  type Reservation,
} from '@parkviet/pos-shared/reservations';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import { reservationsKey, resourceBoardKey } from '../lib/query-keys';
import { pollInterval } from '../lib/realtime';
import { useRealtimeStatus } from './use-branch-events';
import { useSession } from './use-session';
import { abandonIfNeeded } from './use-tenders';

// Without the branch stream the day is read again every thirty seconds.
const FALLBACK_POLL_MS = 30_000;

export type ReservationDraft = {
  guestName: string;
  phone: string;
  partySize: number;
  startsAt: string;
  endsAt?: string;
  note: string;
  resourceIds: string[];
};

// The bookings of a branch's day (YYYY-MM-DD, the branch's own day).
export function useReservations(branchId: string | null, date: string, enabled: boolean) {
  const snapshot = useSession();
  const realtime = useRealtimeStatus();
  return useQuery({
    queryKey: reservationsKey(snapshot.generation, branchId, date),
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    refetchInterval: pollInterval(realtime, FALLBACK_POLL_MS),
    queryFn: async () => {
      try {
        const result = await session.request<{ data: unknown; meta?: { from?: string } }>(
          'GET',
          '/pos/reservations',
          { params: { branch_id: branchId ?? undefined, date } },
        );
        return { rows: normalizeReservations(result.data), from: result.meta?.from ?? null };
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
  });
}

// Free tables for a party at a time; nothing until a time is chosen.
export function useAvailability(
  branchId: string | null,
  input: { startsAt: string; partySize: number; exceptId?: string } | null,
) {
  const snapshot = useSession();
  return useQuery({
    queryKey: [
      'pos',
      'reservation-availability',
      snapshot.generation,
      branchId,
      input?.startsAt ?? null,
      input?.partySize ?? null,
      input?.exceptId ?? null,
    ],
    enabled: snapshot.status === 'authenticated' && Boolean(branchId && input?.startsAt),
    queryFn: async (): Promise<AvailableTable[]> => {
      const result = await session.request<{ data: unknown }>(
        'GET',
        '/pos/reservations/availability',
        {
          params: {
            branch_id: branchId ?? undefined,
            starts_at: input?.startsAt,
            party_size: input ? String(input.partySize) : undefined,
            ...(input?.exceptId ? { except_id: input.exceptId } : {}),
          },
        },
      );
      return normalizeAvailableTables(result.data);
    },
  });
}

async function command<T>(path: string, body: Record<string, unknown>): Promise<T> {
  const key = crypto.randomUUID();
  try {
    const result = await session.request<{ data: T }>('POST', path, {
      body: { ...body, idempotency_key: key },
      idempotencyKey: key,
    });
    return result.data;
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

export function useReservationCommands(branchId: string | null, editorId: string) {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  const refresh = async () => {
    await queryClient.invalidateQueries({ queryKey: ['pos', 'reservations', snapshot.generation] });
    await queryClient.invalidateQueries({ queryKey: resourceBoardKey(snapshot.generation) });
  };
  const run = async <T>(path: string, body: Record<string, unknown>) => {
    try {
      return await command<T>(path, body);
    } finally {
      void refresh();
    }
  };
  const reservation = (value: unknown) => normalizeReservation(value) as Reservation;
  return {
    refresh,
    async create(draft: ReservationDraft) {
      return reservation(
        await run('/pos/reservations', {
          branch_id: branchId,
          resource_ids: draft.resourceIds,
          guest_name: draft.guestName,
          phone: draft.phone || undefined,
          party_size: draft.partySize,
          starts_at: draft.startsAt,
          ...(draft.endsAt ? { ends_at: draft.endsAt } : {}),
          note: draft.note || undefined,
          source: 'phone',
        }),
      );
    },
    // Cash into this cashier's drawer, or a transfer with its reference.
    async takeDeposit(
      id: string,
      input: {
        kind: 'cash' | 'bank_manual';
        amount: string;
        reference?: string;
        receivingAccount?: string;
      },
    ) {
      return reservation(
        await run(`/pos/reservations/${id}/deposits`, {
          kind: input.kind,
          amount: input.amount,
          ...(input.reference ? { reference: input.reference } : {}),
          ...(input.receivingAccount ? { receiving_account: input.receivingAccount } : {}),
        }),
      );
    },
    // Opens the order at the booked table; answers its workspace id.
    async seat(id: string) {
      const result = await run<{ reservation: unknown; workspace: { id: string } }>(
        `/pos/reservations/${id}/seat`,
        { editor_id: editorId },
      );
      return { reservation: reservation(result.reservation), workspaceId: result.workspace.id };
    },
    async cancel(id: string, status: 'canceled' | 'no_show') {
      return reservation(await run(`/pos/reservations/${id}/cancel`, { status }));
    },
    async refundDeposit(depositId: string, approvalId?: string) {
      return reservation(
        await run(`/pos/reservations/deposits/${depositId}/refund`, {
          ...(approvalId ? { approval_id: approvalId } : {}),
        }),
      );
    },
    async forfeitDeposit(depositId: string, approvalId?: string) {
      return reservation(
        await run(`/pos/reservations/deposits/${depositId}/forfeit`, {
          ...(approvalId ? { approval_id: approvalId } : {}),
        }),
      );
    },
  };
}
