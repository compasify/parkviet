import { useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import { runFinancialCommand } from '../lib/financial-command';
import {
  normalizeVehicleVisit,
  normalizeVehicleVisits,
  type VehicleType,
  type VehicleVisit,
  type VehicleVisitStatus,
} from '../lib/vehicle-visits';
import { useSession } from './use-session';
import { abandonIfNeeded, financialRequest } from './use-tenders';

const visitsKey = (generation: number) => ['pos', 'vehicle-visits', generation] as const;

async function list(params: Record<string, string | undefined>) {
  try {
    const result = await session.request<{ data: unknown }>('GET', '/pos/vehicle_visits', {
      params,
    });
    return normalizeVehicleVisits(result.data);
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

// The coaches at the stop right now, read again every half minute so a visit
// that closed by itself leaves the bar.
export function useOpenVehicleVisits(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: [...visitsKey(snapshot.generation), 'open', branchId] as const,
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    refetchInterval: 30_000,
    placeholderData: (previous) => previous,
    queryFn: () => list({ branch_id: branchId ?? undefined, status: 'open' }),
  });
}

// The day's visits, by state and part of a plate.
export function useVehicleVisits(
  branchId: string | null,
  filter: { businessDate: string; statuses: VehicleVisitStatus[]; q: string },
  enabled: boolean,
) {
  const snapshot = useSession();
  const q = filter.q.trim();
  const status = filter.statuses.join(',');
  return useQuery({
    queryKey: [
      ...visitsKey(snapshot.generation),
      'list',
      branchId,
      filter.businessDate,
      status,
      q,
    ] as const,
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    placeholderData: (previous) => previous,
    queryFn: () =>
      list({
        branch_id: branchId ?? undefined,
        ...(filter.businessDate ? { business_date: filter.businessDate } : {}),
        ...(status ? { status } : {}),
        ...(q ? { q } : {}),
      }),
  });
}

export type VehicleVisitDraft = {
  plate: string;
  vehicleType: VehicleType;
  guestCount: number;
  busOperatorId?: string;
  driverName?: string;
  driverPhone?: string;
  note?: string;
};

function draftBody(draft: Partial<VehicleVisitDraft>) {
  return {
    ...(draft.plate !== undefined ? { plate: draft.plate.trim() } : {}),
    ...(draft.vehicleType ? { vehicle_type: draft.vehicleType } : {}),
    ...(draft.guestCount !== undefined ? { guest_count: draft.guestCount } : {}),
    ...(draft.busOperatorId ? { bus_operator_id: draft.busOperatorId } : {}),
    ...(draft.driverName?.trim() ? { driver_name: draft.driverName.trim() } : {}),
    ...(draft.driverPhone?.trim() ? { driver_phone: draft.driverPhone.trim() } : {}),
    ...(draft.note?.trim() ? { note: draft.note.trim() } : {}),
  };
}

// Opening, changing, closing, voiding, correcting and paying a coach visit.
// Paying moves money out of the drawer, so it runs as a money command: a lost
// answer is checked against its receipt before anything is resent.
export function useVehicleVisitCommands(
  branchId: string | null,
  staffId: string | null,
  storeId: string | null,
) {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  const refresh = () => queryClient.invalidateQueries({ queryKey: visitsKey(snapshot.generation) });
  async function send(method: 'POST' | 'PATCH', path: string, body: Record<string, unknown>) {
    const key = crypto.randomUUID();
    try {
      const result = await session.request<{ data: unknown }>(method, path, {
        body: { ...body, idempotency_key: key },
        idempotencyKey: key,
      });
      return normalizeVehicleVisit(result.data) as VehicleVisit;
    } catch (error) {
      abandonIfNeeded(error);
      throw error;
    } finally {
      void refresh();
    }
  }
  return {
    open(draft: VehicleVisitDraft) {
      return send('POST', '/pos/vehicle_visits', { branch_id: branchId, ...draftBody(draft) });
    },
    update(visit: VehicleVisit, draft: Partial<VehicleVisitDraft>) {
      return send('PATCH', `/pos/vehicle_visits/${visit.id}`, {
        expected_revision: visit.revision,
        ...draftBody(draft),
      });
    },
    close(visit: VehicleVisit) {
      return send('POST', `/pos/vehicle_visits/${visit.id}/close`, {});
    },
    void(visit: VehicleVisit, reason: string) {
      return send('POST', `/pos/vehicle_visits/${visit.id}/void`, { reason: reason.trim() });
    },
    // Guests (commission worked out again) or the commission itself, with a
    // note and a manager's approval granted on this visit.
    adjust(
      visit: VehicleVisit,
      input: { guestCount?: number; commissionAmount?: string; note: string; approvalId?: string },
    ) {
      return send('POST', `/pos/vehicle_visits/${visit.id}/adjust`, {
        expected_revision: visit.revision,
        note: input.note.trim(),
        ...(input.guestCount !== undefined ? { guest_count: input.guestCount } : {}),
        ...(input.commissionAmount ? { commission_amount: input.commissionAmount } : {}),
        ...(input.approvalId ? { approval_id: input.approvalId } : {}),
      });
    },
    async pay(
      visit: VehicleVisit,
      input: { method: 'cash' } | { method: 'transfer'; reference: string },
    ) {
      try {
        const result = await runFinancialCommand<unknown>(financialRequest, {
          staffId,
          storeId,
          scopeId: visit.id,
          action: 'vehicle_visit.pay',
          path: `/pos/vehicle_visits/${visit.id}/pay`,
          body: {
            payout_method: input.method,
            ...(input.method === 'transfer' ? { transfer_reference: input.reference.trim() } : {}),
          },
          intent: `pay:${visit.id}`,
        });
        return normalizeVehicleVisit(result.data) as VehicleVisit;
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      } finally {
        void refresh();
        void queryClient.invalidateQueries({ queryKey: ['pos', 'cash-requests'] });
        void queryClient.invalidateQueries({ queryKey: ['pos', 'shift-close'] });
      }
    },
  };
}
