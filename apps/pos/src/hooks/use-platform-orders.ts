import type {
  Platform,
  PlatformOrder,
  PlatformSettings,
} from '@parkviet/pos-shared/platform-orders';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import type { PlatformEntryLine } from '../lib/platform-order-draft';
import { useSession } from './use-session';
import { workspaceEditorId } from './use-workspaces';

export function platformOrdersKey(generation: number, branchId: string | null) {
  return ['pos', 'platform-orders', generation, branchId] as const;
}

export function platformSettingsKey(generation: number, branchId: string | null) {
  return ['pos', 'platform-settings', generation, branchId] as const;
}

export type PlatformEntry = {
  platform: Platform;
  platformOrderRef: string;
  pickupCode: string;
  note: string;
  lines: PlatformEntryLine[];
};

function command<T>(path: string, body: Record<string, unknown> = {}) {
  const idempotencyKey = crypto.randomUUID();
  return session
    .request<{ data: T }>('POST', path, {
      body: { ...body, idempotency_key: idempotencyKey },
      idempotencyKey,
    })
    .then((result) => result.data);
}

// Which platforms the branch takes orders from, and at what rate.
export function usePlatformSettings(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: platformSettingsKey(snapshot.generation, branchId),
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    staleTime: 60_000,
    queryFn: async () =>
      (
        await session.request<{ data: PlatformSettings }>('GET', '/pos/platform_settings', {
          params: { branch_id: branchId ?? undefined },
        })
      ).data,
  });
}

// The counter's platform tray: orders entered and not handed to the driver
// yet, oldest first. The kitchen marks them ready, so it is read again every
// few seconds while open; every command reads it again too.
export function usePlatformOrders(
  branchId: string | null,
  registerId: string | null,
  enabled: boolean,
) {
  const snapshot = useSession();
  const client = useQueryClient();
  const key = platformOrdersKey(snapshot.generation, branchId);
  const query = useQuery({
    queryKey: key,
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    refetchInterval: 10_000,
    queryFn: async () =>
      (
        await session.request<{ data: PlatformOrder[] }>('GET', '/pos/platform_orders', {
          params: { branch_id: branchId ?? undefined, status: 'open', limit: '50' },
        })
      ).data,
  });
  const refresh = () => void client.invalidateQueries({ queryKey: key });
  const enter = useMutation({
    mutationFn: (entry: PlatformEntry) =>
      command<PlatformOrder>('/pos/platform_orders', {
        editor_id: workspaceEditorId,
        register_id: registerId ?? undefined,
        branch_id: registerId ? undefined : (branchId ?? undefined),
        platform: entry.platform,
        platform_order_ref: entry.platformOrderRef.trim(),
        pickup_code: entry.pickupCode.trim() || undefined,
        note: entry.note.trim() || undefined,
        lines: entry.lines,
      }),
    onSettled: refresh,
  });
  const ready = useMutation({
    mutationFn: (id: string) => command<PlatformOrder>(`/pos/platform_orders/${id}/ready`),
    onSettled: refresh,
  });
  const complete = useMutation({
    mutationFn: (id: string) =>
      command<PlatformOrder>(`/pos/platform_orders/${id}/complete`, {
        editor_id: workspaceEditorId,
      }),
    onSettled: refresh,
  });
  const cancel = useMutation({
    mutationFn: (input: { id: string; reason: string }) =>
      command<PlatformOrder>(`/pos/platform_orders/${input.id}/cancel`, {
        editor_id: workspaceEditorId,
        reason: input.reason.trim() || undefined,
      }),
    onSettled: refresh,
  });
  return { query, enter, ready, complete, cancel };
}
