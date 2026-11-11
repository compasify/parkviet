import type { PrintDocument } from '@parkviet/pos-shared/receipt-template/types';
import { useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import { useSession } from './use-session';
import { abandonIfNeeded } from './use-tenders';

export const BOTTLE_KEEP_MODULE = 'fnb.bottle_keep';

export type BottleKeepStatus = 'kept' | 'finished' | 'expired' | 'returned';

export type BottleKeepEvent = {
  id: string;
  kind: 'open' | 'pour' | 'adjust' | 'expire' | 'return';
  levelBefore: number | null;
  levelAfter: number | null;
  ml: number | null;
  approvalId: string | null;
  actor: string | null;
  note: string | null;
  createdAt: string;
};

// A guest's kept bottle as the book shows it.
export type BottleKeep = {
  id: string;
  code: string;
  status: BottleKeepStatus;
  levelPercent: number;
  productName: string;
  optionsText: string | null;
  guestName: string | null;
  phone: string | null;
  keptOn: string;
  expiresOn: string;
  note: string | null;
  revision: number;
  photoUrl: string | null;
  events: BottleKeepEvent[];
};

const STATUSES: readonly BottleKeepStatus[] = ['kept', 'finished', 'expired', 'returned'];
const EVENT_KINDS: readonly BottleKeepEvent['kind'][] = [
  'open',
  'pour',
  'adjust',
  'expire',
  'return',
];

function text(value: unknown): string | null {
  return typeof value === 'string' && value ? value : null;
}

function int(value: unknown): number | null {
  return typeof value === 'number' && Number.isInteger(value) ? value : null;
}

function normalizeEvent(value: unknown): BottleKeepEvent[] {
  const row = (value ?? {}) as Record<string, unknown>;
  const id = text(row.id);
  const kind = row.kind as BottleKeepEvent['kind'];
  if (!id || !EVENT_KINDS.includes(kind)) return [];
  const actor = (row.actor ?? null) as Record<string, unknown> | null;
  return [
    {
      id,
      kind,
      levelBefore: int(row.level_before),
      levelAfter: int(row.level_after),
      ml: int(row.ml),
      approvalId: text(row.approval_id),
      actor: text(actor?.name),
      note: text(row.note),
      createdAt: text(row.created_at) ?? '',
    },
  ];
}

export function normalizeBottleKeep(value: unknown): BottleKeep | null {
  const row = (value ?? {}) as Record<string, unknown>;
  const id = text(row.id);
  const code = text(row.code);
  const status = row.status as BottleKeepStatus;
  if (!id || !code || !STATUSES.includes(status)) return null;
  return {
    id,
    code,
    status,
    levelPercent: int(row.level_percent) ?? 0,
    productName: text(row.product_name) ?? '',
    optionsText: text(row.options_text),
    guestName: text(row.guest_name),
    phone: text(row.phone),
    keptOn: text(row.kept_on) ?? '',
    expiresOn: text(row.expires_on) ?? '',
    note: text(row.note),
    revision: int(row.revision) ?? 0,
    photoUrl: text(row.photo_url),
    events: Array.isArray(row.events) ? row.events.flatMap(normalizeEvent) : [],
  };
}

export function normalizeBottleKeeps(rows: unknown): BottleKeep[] {
  if (!Array.isArray(rows)) return [];
  return rows.flatMap((row) => {
    const keep = normalizeBottleKeep(row);
    return keep ? [keep] : [];
  });
}

// The bottles of a branch, found by code, phone or guest name.
export function useBottleKeeps(
  branchId: string | null,
  query: string,
  status: 'kept' | 'all',
  enabled: boolean,
) {
  const snapshot = useSession();
  const q = query.trim();
  return useQuery({
    queryKey: ['pos', 'bottle-keeps', snapshot.generation, branchId, status, q] as const,
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    placeholderData: (previous) => previous,
    queryFn: async () => {
      try {
        const result = await session.request<{ data: unknown }>('GET', '/pos/bottle_keeps', {
          params: { branch_id: branchId ?? undefined, status, ...(q ? { q } : {}) },
        });
        return normalizeBottleKeeps(result.data);
      } catch (error) {
        abandonIfNeeded(error);
        throw error;
      }
    },
  });
}

// One bottle with its whole history.
export function useBottleKeep(id: string | null) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'bottle-keeps', snapshot.generation, 'one', id] as const,
    enabled: snapshot.status === 'authenticated' && Boolean(id),
    queryFn: async () => {
      const result = await session.request<{ data: unknown }>('GET', `/pos/bottle_keeps/${id}`);
      return normalizeBottleKeep(result.data);
    },
  });
}

export type BottleKeepDraft = {
  variantId: string;
  levelPercent: number;
  guestName: string;
  phone: string;
  note: string;
  photo: File | null;
};

function form(values: Record<string, string | number | File | null | undefined>, key: string) {
  const body = new FormData();
  body.set('idempotency_key', key);
  for (const [name, value] of Object.entries(values)) {
    if (value === null || value === undefined || value === '') continue;
    body.set(name, value instanceof File ? value : String(value));
  }
  return body;
}

async function send<T>(path: string, body: FormData | Record<string, unknown>, key: string) {
  try {
    const result = await session.request<{ data: T }>('POST', path, {
      body: body instanceof FormData ? body : { ...body, idempotency_key: key },
      idempotencyKey: key,
    });
    return result.data;
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

// Keeping, pouring, correcting (with a manager's approval), returning and
// labelling a bottle. Every write reads the book again.
export function useBottleKeepCommands(branchId: string | null) {
  const snapshot = useSession();
  const queryClient = useQueryClient();
  const refresh = () =>
    queryClient.invalidateQueries({ queryKey: ['pos', 'bottle-keeps', snapshot.generation] });
  const keep = async (path: string, body: (key: string) => FormData | Record<string, unknown>) => {
    const key = crypto.randomUUID();
    try {
      return normalizeBottleKeep(await send<unknown>(path, body(key), key)) as BottleKeep;
    } finally {
      void refresh();
    }
  };
  return {
    create(draft: BottleKeepDraft) {
      return keep('/pos/bottle_keeps', (key) =>
        form(
          {
            branch_id: branchId,
            variant_id: draft.variantId,
            level_percent: draft.levelPercent,
            guest_name: draft.guestName.trim(),
            phone: draft.phone.trim(),
            note: draft.note.trim(),
            photo: draft.photo,
          },
          key,
        ),
      );
    },
    pour(
      id: string,
      input: { levelPercent: number; ml?: number; note?: string; photo?: File | null },
    ) {
      return keep(`/pos/bottle_keeps/${id}/pour`, (key) =>
        form(
          {
            level_percent: input.levelPercent,
            ml: input.ml,
            note: input.note?.trim(),
            photo: input.photo ?? null,
          },
          key,
        ),
      );
    },
    adjust(bottle: BottleKeep, input: { levelPercent: number; note: string; approvalId?: string }) {
      return keep(`/pos/bottle_keeps/${bottle.id}/adjust`, () => ({
        level_percent: input.levelPercent,
        note: input.note.trim(),
        expected_revision: bottle.revision,
        approval_id: input.approvalId,
      }));
    },
    giveBack(id: string, note: string) {
      return keep(`/pos/bottle_keeps/${id}/return`, () => ({
        note: note.trim() || undefined,
      }));
    },
    // The label as a receipt document; with a printer it is queued there too.
    async label(id: string, printerId?: string) {
      const key = crypto.randomUUID();
      return send<{ document: PrintDocument; print_job?: unknown }>(
        `/pos/bottle_keeps/${id}/label`,
        printerId ? { printer_id: printerId } : {},
        key,
      );
    },
  };
}
