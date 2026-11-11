import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import type { DisplaySession } from '../lib/display-generation';
import { useSession } from './use-session';
import { abandonIfNeeded } from './use-tenders';

// Cashier side of the customer display. The display token is returned by
// bind only so this page can hand it to a display window it opens; it is
// kept in memory, never shown, stored, logged or put in a URL. A separate
// device pairs with a short single-use code instead.
const tokens = new Map<string, string>();

export const DISPLAY_HANDOFF_READY = 'pos-display-ready';
export const DISPLAY_HANDOFF_TOKEN = 'pos-display-token';

let handoffWindow: Window | null = null;
let handoffSessionId: string | null = null;
let handoffToken: string | null = null;
let listening = false;

function sendHandoff() {
  if (!handoffWindow || handoffWindow.closed || !handoffToken) return;
  handoffWindow.postMessage(
    { type: DISPLAY_HANDOFF_TOKEN, token: handoffToken },
    window.location.origin,
  );
}

function listenForDisplay() {
  if (listening || typeof window === 'undefined') return;
  listening = true;
  window.addEventListener('message', (event) => {
    // Only the display window this page opened, from this origin, gets the token.
    if (event.origin !== window.location.origin || event.source !== handoffWindow) return;
    const data = event.data as { type?: unknown } | null;
    if (data?.type === DISPLAY_HANDOFF_READY) sendHandoff();
  });
}

// A rebind rotates the token: an open display window gets the new one at
// once. A revoke forgets it, so nothing can be handed over any more.
function rememberToken(sessionId: string, token: string | null) {
  if (token) tokens.set(sessionId, token);
  else tokens.delete(sessionId);
  if (handoffSessionId !== sessionId) return;
  handoffToken = token;
  if (token) sendHandoff();
}

// Opens (or focuses) the customer display window and hands it the token
// through postMessage once it reports ready. False when the browser blocked it.
export function openDisplayWindow(sessionId: string): boolean {
  const token = tokens.get(sessionId);
  if (!token) return false;
  listenForDisplay();
  const opened = window.open(`${import.meta.env.BASE_URL}display`, 'parkviet-pos-customer-display');
  if (!opened) return false;
  handoffWindow = opened;
  handoffSessionId = sessionId;
  handoffToken = token;
  // An already open display window reloads nothing; send the token directly.
  sendHandoff();
  return true;
}

export function canOpenDisplayWindow(sessionId: string | null | undefined): boolean {
  return Boolean(sessionId && tokens.has(sessionId));
}

async function call<T>(
  method: 'GET' | 'POST',
  path: string,
  options?: Parameters<typeof session.request>[2],
) {
  try {
    return await session.request<T>(method, path, options);
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

export function displayKey(generation: number, shiftId: string | null) {
  return ['pos', 'display-session', generation, shiftId] as const;
}

export type PairingCode = { code: string; expires_at: string };

export function useDisplaySession(shiftId: string | null, enabled: boolean) {
  const snapshot = useSession();
  const client = useQueryClient();
  const key = displayKey(snapshot.generation, shiftId);
  const query = useQuery({
    queryKey: key,
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(shiftId),
    // Freshness of the display is the server's acknowledgement record; poll it.
    // Twice per freshness window at least, so a healthy display never reads
    // as stale on the cashier screen.
    refetchInterval: (current) => {
      const ttl = current.state.data?.freshness_ttl_seconds;
      if (ttl) return Math.min(3000, ttl * 500);
      return current.state.error ? 3000 : false;
    },
    queryFn: async () =>
      (
        await call<{ data: DisplaySession | null }>('GET', '/pos/display_sessions/current', {
          params: { shift_id: shiftId ?? undefined },
        })
      ).data,
  });
  const store = (value: DisplaySession | null) => client.setQueryData(key, value);
  const keyed = () => crypto.randomUUID();

  const bind = useMutation({
    mutationFn: async () => {
      const body = await call<{ data: DisplaySession; token: string }>(
        'POST',
        '/pos/display_sessions',
        { body: { shift_id: shiftId } },
      );
      rememberToken(body.data.id, body.token);
      return body.data;
    },
    onSuccess: store,
  });
  // Pin and clear are compare-and-set on the generation the cashier saw.
  const command = (path: string, body: Record<string, unknown>) => {
    const idempotencyKey = keyed();
    return call<{ data: DisplaySession }>('POST', path, {
      body: { ...body, idempotency_key: idempotencyKey },
      idempotencyKey,
    });
  };
  const pin = useMutation({
    mutationFn: async (input: {
      session: DisplaySession;
      workspaceId: string;
      attemptId?: string;
    }) =>
      (
        await command(`/pos/display_sessions/${input.session.id}/pin`, {
          workspace_id: input.workspaceId,
          tender_attempt_id: input.attemptId,
          expected_generation: input.session.generation,
        })
      ).data,
    onSuccess: store,
    onError: () => void query.refetch(),
  });
  const clear = useMutation({
    mutationFn: async (current: DisplaySession) =>
      (
        await command(`/pos/display_sessions/${current.id}/clear`, {
          expected_generation: current.generation,
        })
      ).data,
    onSuccess: store,
    onError: () => void query.refetch(),
  });
  // Switches what the display shows: the pinned order, or the branch's call
  // numbers. Switching empties the display.
  const mode = useMutation({
    mutationFn: async (input: { session: DisplaySession; mode: 'order' | 'call_board' }) =>
      (
        await command(`/pos/display_sessions/${input.session.id}/mode`, {
          mode: input.mode,
          expected_generation: input.session.generation,
        })
      ).data,
    onSuccess: store,
    onError: () => void query.refetch(),
  });
  const pairing = useMutation({
    mutationFn: async (sessionId: string) =>
      (await call<{ data: PairingCode }>('POST', `/pos/display_sessions/${sessionId}/pairing_code`))
        .data,
  });
  const revoke = useMutation({
    mutationFn: async (input: { sessionId: string; reason: 'ended' | 'unresponsive' }) => {
      await call<{ data: DisplaySession }>(
        'POST',
        `/pos/display_sessions/${input.sessionId}/revoke`,
        { body: { reason: input.reason } },
      );
      rememberToken(input.sessionId, null);
      return null;
    },
    onSuccess: store,
  });
  return { query, bind, pin, clear, mode, pairing, revoke };
}

// Display side: the public channel. Reads and acknowledgements carry the
// display token in the Authorization header only.
export class DisplayUnauthorized extends Error {}
export class PairingRefused extends Error {
  constructor(readonly limited: boolean) {
    super(limited ? 'pairing rate limited' : 'pairing refused');
  }
}

const noStore = { cache: 'no-store', credentials: 'omit', referrerPolicy: 'no-referrer' } as const;

export async function fetchDisplayState(token: string, signal?: AbortSignal): Promise<unknown> {
  const response = await fetch('/api/v3/pos_display/state', {
    ...noStore,
    headers: { Authorization: `Display ${token}`, Accept: 'application/json' },
    signal,
  });
  if (response.status === 401) throw new DisplayUnauthorized();
  if (!response.ok) throw new Error(`display state ${response.status}`);
  const body = (await response.json()) as { data?: unknown };
  return body.data;
}

export async function postDisplayAck(token: string, ack: { generation: number; lease_id: string }) {
  const response = await fetch('/api/v3/pos_display/ack', {
    ...noStore,
    method: 'POST',
    headers: {
      Authorization: `Display ${token}`,
      'Content-Type': 'application/json',
      Accept: 'application/json',
    },
    body: JSON.stringify(ack),
  });
  if (response.status === 401) throw new DisplayUnauthorized();
  return response.ok;
}

// Exchanges a pairing code typed on the display device for its token.
export async function exchangePairingCode(code: string): Promise<string> {
  const response = await fetch('/api/v3/pos_display/pair', {
    ...noStore,
    method: 'POST',
    headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
    body: JSON.stringify({ code }),
  });
  if (response.status === 429) throw new PairingRefused(true);
  if (!response.ok) throw new PairingRefused(false);
  const body = (await response.json()) as { data?: { token?: unknown } };
  if (typeof body.data?.token !== 'string' || !body.data.token) throw new PairingRefused(false);
  return body.data.token;
}
