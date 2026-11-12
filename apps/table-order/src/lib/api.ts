import { readToken } from './session';
import type { GuestMenu, GuestOrder, GuestRequest, GuestSession, GuestTable } from './types';

const BASE = '/api/v3/pos_guest';

// A refusal of the guest API: `{ error: { code, message } }` with its status.
export class GuestApiError extends Error {
  constructor(
    readonly status: number,
    readonly code: string,
    message: string,
  ) {
    super(message);
  }
}

// The session ended (table closed, four hours, a new code) or never existed.
export const SESSION_ENDED = ['session_invalid', 'session_expired', 'qr_order_unavailable'];

async function call<T>(
  method: 'GET' | 'POST',
  path: string,
  options: { body?: unknown; key?: string; token?: string | null } = {},
): Promise<T> {
  const token = options.token === undefined ? readToken() : options.token;
  let response: Response;
  try {
    response = await fetch(`${BASE}${path}`, {
      method,
      credentials: 'omit',
      cache: 'no-store',
      headers: {
        Accept: 'application/json',
        ...(options.body === undefined ? {} : { 'Content-Type': 'application/json' }),
        ...(token ? { Authorization: `Guest ${token}` } : {}),
        ...(options.key ? { 'Idempotency-Key': options.key } : {}),
      },
      body: options.body === undefined ? undefined : JSON.stringify(options.body),
    });
  } catch {
    throw new GuestApiError(0, 'network', 'offline');
  }
  const json = (await response.json().catch(() => null)) as {
    data?: T;
    error?: { code?: string; message?: string };
  } | null;
  if (!response.ok || !json || json.data === undefined)
    throw new GuestApiError(
      response.status,
      json?.error?.code ?? 'unknown',
      json?.error?.message ?? response.statusText,
    );
  return json.data;
}

export const guestApi = {
  openSession: (code: string) =>
    call<GuestSession & { token: string }>('POST', '/session', {
      body: { table_code: code },
      token: null,
    }),
  session: () => call<GuestSession>('GET', '/session'),
  menu: () => call<GuestMenu>('GET', '/menu'),
  table: () => call<GuestTable>('GET', '/order'),
  submitOrder: (body: unknown, key: string) =>
    call<GuestOrder>('POST', '/guest_orders', { body, key }),
  request: (kind: GuestRequest['kind']) =>
    call<GuestRequest>('POST', '/requests', { body: { kind } }),
};
