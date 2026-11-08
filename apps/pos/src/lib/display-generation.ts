// Customer display freshness. The display may show payment instructions (a
// bank account or QR) only while it holds proof that what it shows is the
// server's current state for the current generation:
//
// - The proof is a local deadline on a monotonic clock, set to the moment the
//   request was *sent* plus the freshness window, so a slow or delayed
//   response never extends it past what the server knew at that time.
// - Only a response newer than every applied one renews it: a later request
//   (in-order check), a higher server sequence (no cached or replayed body)
//   and a generation not older than the current one.
// - Going offline, the page being hidden, a resume from sleep or the deadline
//   passing hides everything at once. Requests sent before that moment can
//   never show it again; only a fresh request sent afterwards can.
//
// The server token expiring is separate: a valid token never proves freshness.

export type DisplayLine = { name: string; quantity: string; unit: string | null; amount: string };

export type DisplayOrder = {
  number: string;
  currency: string;
  total: string;
  lines?: DisplayLine[];
  item_total?: string;
  discount_total?: string;
  paid?: string;
  amount_due?: string;
};

export type DisplayPayment =
  | {
      kind: 'bank_manual';
      amount: string;
      currency: string;
      transfer_note: string;
      account_text: string | null;
    }
  | {
      // A VietQR tender: the customer scans the QR; the details are the
      // receiving account it was issued for, for a manual transfer.
      kind: 'vietqr';
      amount: string;
      currency: string;
      transfer_note: string;
      qr_url: string;
      bank_name: string | null;
      account_number: string;
      account_name: string;
    };

const DISPLAY_PAYMENT_KINDS = ['bank_manual', 'vietqr'];

export type DisplayState = {
  session_id: string;
  generation: number;
  sequence: number;
  issued_at: string;
  lease_id: string;
  freshness_ttl_seconds: number;
  token_expires_at: string;
  branch_name: string;
  state: 'idle' | 'order' | 'completed';
  order: DisplayOrder | null;
  payment: DisplayPayment | null;
};

export type HideReason = 'initial' | 'offline' | 'hidden' | 'resumed' | 'expired' | 'disconnected';

export type DisplayTicket = Readonly<{ id: number; epoch: number; sentAt: number }>;

export type AcceptResult =
  | 'applied'
  | 'stale_epoch'
  | 'stale_order'
  | 'stale_sequence'
  | 'stale_generation'
  | 'invalid';

export type DisplayClock = { now: () => number; wall: () => number };

// Freshness windows outside these bounds are refused as malformed.
const MIN_TTL_SECONDS = 1;
const MAX_TTL_SECONDS = 120;
// A wall clock that ran this much further than the monotonic clock means the
// device slept (some monotonic clocks pause during suspend).
const RESUME_JUMP_MS = 2000;

const isText = (value: unknown): value is string => typeof value === 'string';

// Validates a display state body at the boundary; null when malformed.
export function readDisplayState(data: unknown): DisplayState | null {
  if (typeof data !== 'object' || data === null) return null;
  const body = data as Record<string, unknown>;
  const ttl = body.freshness_ttl_seconds;
  if (
    !isText(body.session_id) ||
    !Number.isInteger(body.generation) ||
    !Number.isInteger(body.sequence) ||
    !isText(body.lease_id) ||
    !isText(body.issued_at) ||
    typeof ttl !== 'number' ||
    ttl < MIN_TTL_SECONDS ||
    ttl > MAX_TTL_SECONDS ||
    (body.state !== 'idle' && body.state !== 'order' && body.state !== 'completed')
  )
    return null;
  const payment = body.payment as Record<string, unknown> | null | undefined;
  if (
    payment != null &&
    (!DISPLAY_PAYMENT_KINDS.includes(payment.kind as string) ||
      !isText(payment.amount) ||
      (payment.kind === 'vietqr' && !isText(payment.qr_url)))
  )
    return null;
  const order = body.order as Record<string, unknown> | null | undefined;
  if (order != null && (!isText(order.number) || !isText(order.total))) return null;
  return data as DisplayState;
}

export function createDisplayFreshness(
  clock: DisplayClock = { now: () => performance.now(), wall: () => Date.now() },
) {
  let epoch = 0;
  let nextTicket = 1;
  let lastAppliedTicket = 0;
  let lastSequence = -1;
  let generation = 0;
  let deadline = Number.NEGATIVE_INFINITY;
  let current: DisplayState | null = null;
  let hidden: HideReason | null = 'initial';
  let lastMono = clock.now();
  let lastWall = clock.wall();

  function invalidate(reason: HideReason) {
    epoch += 1;
    deadline = Number.NEGATIVE_INFINITY;
    hidden = reason;
  }

  function fresh(): boolean {
    return hidden === null && current !== null && clock.now() < deadline;
  }

  return {
    // Call right before sending a state request.
    beginRequest(): DisplayTicket {
      return Object.freeze({ id: nextTicket++, epoch, sentAt: clock.now() });
    },
    accept(ticket: DisplayTicket, response: unknown): AcceptResult {
      const state = readDisplayState(response);
      if (!state) return 'invalid';
      if (ticket.epoch !== epoch) return 'stale_epoch';
      if (ticket.id <= lastAppliedTicket) return 'stale_order';
      if (state.sequence <= lastSequence) return 'stale_sequence';
      if (state.generation < generation) return 'stale_generation';
      lastAppliedTicket = ticket.id;
      lastSequence = state.sequence;
      generation = state.generation;
      current = state;
      const until = ticket.sentAt + state.freshness_ttl_seconds * 1000;
      if (until <= clock.now()) {
        // Already too old when it arrived: it proves nothing.
        invalidate('expired');
        return 'applied';
      }
      deadline = until;
      hidden = null;
      return 'applied';
    },
    invalidate,
    // Periodic check: deadline passed, or the device slept in between.
    tick(): HideReason | null {
      const mono = clock.now();
      const wall = clock.wall();
      const slept = wall - lastWall - (mono - lastMono) > RESUME_JUMP_MS;
      lastMono = mono;
      lastWall = wall;
      if (slept) {
        invalidate('resumed');
        return 'resumed';
      }
      if (hidden === null && mono >= deadline) {
        invalidate('expired');
        return 'expired';
      }
      return null;
    },
    // Forget the previous session entirely (unbound or a new token).
    reset() {
      invalidate('disconnected');
      lastAppliedTicket = 0;
      lastSequence = -1;
      generation = 0;
      current = null;
    },
    snapshot() {
      const isFresh = fresh();
      return {
        fresh: isFresh,
        reason: isFresh ? null : (hidden ?? 'expired'),
        generation,
        state: isFresh ? current : null,
        showPayment: isFresh && current?.payment != null,
      };
    },
    // What to acknowledge for the state on screen; null unless fresh.
    ackFor(): { generation: number; lease_id: string } | null {
      if (!fresh() || !current) return null;
      return { generation: current.generation, lease_id: current.lease_id };
    },
  };
}

export type DisplayFreshness = ReturnType<typeof createDisplayFreshness>;

// Cashier side: the session as the server reports it.
export type DisplaySession = {
  id: string;
  status: 'active' | 'revoked' | 'expired' | 'ended';
  generation: number;
  freshness_ttl_seconds: number;
  pinned_workspace_id: string | null;
  pinned_order_number: string | null;
  pinned_tender_attempt_id: string | null;
  acked_generation: number | null;
  acked_at: string | null;
  ack_current: boolean;
  last_seen_at: string | null;
  token_expires_at: string;
};

export type PinDecision =
  | { allowed: true; sameCustomer: boolean }
  | { allowed: false; reason: 'inactive' | 'busy' | 'ack_required' };

// Mirrors the server rule: another customer only after the display confirmed
// the current generation after a clear; the same order may be re-pinned. An
// acknowledgement the server reports as no longer current proves nothing.
export function pinDecision(session: DisplaySession | null, workspaceId: string): PinDecision {
  if (session?.status !== 'active') return { allowed: false, reason: 'inactive' };
  if (session.pinned_workspace_id === workspaceId) return { allowed: true, sameCustomer: true };
  if (session.pinned_workspace_id) return { allowed: false, reason: 'busy' };
  if (!session.ack_current || session.acked_generation !== session.generation)
    return { allowed: false, reason: 'ack_required' };
  return { allowed: true, sameCustomer: false };
}
