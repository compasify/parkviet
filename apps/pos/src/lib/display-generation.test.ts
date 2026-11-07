import { describe, expect, it } from 'vitest';
import {
  createDisplayFreshness,
  type DisplaySession,
  type DisplayState,
  pinDecision,
  readDisplayState,
} from './display-generation';

function clock() {
  let mono = 1000;
  let wall = 1_700_000_000_000;
  return {
    now: () => mono,
    wall: () => wall,
    advance(ms: number) {
      mono += ms;
      wall += ms;
    },
    // Device slept: the wall clock moved, the monotonic clock did not.
    sleep(ms: number) {
      wall += ms;
    },
  };
}

function state(overrides: Partial<DisplayState> = {}): DisplayState {
  return {
    session_id: 'posdisplay_1',
    generation: 2,
    sequence: 1,
    issued_at: '2026-11-07T10:00:00.000Z',
    lease_id: 'lease-1',
    freshness_ttl_seconds: 15,
    token_expires_at: '2026-11-07T22:00:00Z',
    branch_name: 'Chi nhánh',
    state: 'order',
    order: { number: 'R100', currency: 'VND', total: '50000.0', amount_due: '50000.0', lines: [] },
    payment: {
      kind: 'bank_manual',
      amount: '50000.0',
      currency: 'VND',
      transfer_note: 'R100',
      account_text: 'VCB 0123',
    },
    ...overrides,
  };
}

describe('display freshness', () => {
  it('shows payment only after a fresh response and hides it when the monotonic deadline passes', () => {
    const time = clock();
    const freshness = createDisplayFreshness(time);
    expect(freshness.snapshot()).toMatchObject({
      fresh: false,
      showPayment: false,
      reason: 'initial',
    });
    const ticket = freshness.beginRequest();
    time.advance(500);
    expect(freshness.accept(ticket, state())).toBe('applied');
    expect(freshness.snapshot()).toMatchObject({ fresh: true, showPayment: true, generation: 2 });
    expect(freshness.ackFor()).toEqual({ generation: 2, lease_id: 'lease-1' });
    // The deadline counts from when the request was sent, not when it arrived.
    time.advance(14_499);
    expect(freshness.tick()).toBeNull();
    time.advance(1);
    expect(freshness.tick()).toBe('expired');
    expect(freshness.snapshot()).toMatchObject({ fresh: false, showPayment: false, state: null });
    expect(freshness.ackFor()).toBeNull();
  });

  it('never renews from cached, replayed, reordered or older-generation responses', () => {
    const time = clock();
    const freshness = createDisplayFreshness(time);
    const first = freshness.beginRequest();
    const second = freshness.beginRequest();
    expect(freshness.accept(second, state({ sequence: 5 }))).toBe('applied');
    // The earlier request answers late: out of order.
    expect(freshness.accept(first, state({ sequence: 4 }))).toBe('stale_order');
    // A cached body repeats the sequence it already had.
    expect(freshness.accept(freshness.beginRequest(), state({ sequence: 5 }))).toBe(
      'stale_sequence',
    );
    expect(freshness.accept(freshness.beginRequest(), state({ sequence: 3 }))).toBe(
      'stale_sequence',
    );
    expect(freshness.accept(freshness.beginRequest(), state({ sequence: 6, generation: 1 }))).toBe(
      'stale_generation',
    );
    time.advance(15_000);
    expect(freshness.tick()).toBe('expired');
    expect(freshness.snapshot().showPayment).toBe(false);
  });

  it('a slow response cannot extend the deadline past send time plus the window', () => {
    const time = clock();
    const freshness = createDisplayFreshness(time);
    const ticket = freshness.beginRequest();
    time.advance(16_000);
    expect(freshness.accept(ticket, state())).toBe('applied');
    expect(freshness.snapshot()).toMatchObject({ fresh: false, showPayment: false });
  });

  it.each(['offline', 'hidden'] as const)(
    'hides at once on %s and ignores responses to requests sent before',
    (reason) => {
      const time = clock();
      const freshness = createDisplayFreshness(time);
      expect(freshness.accept(freshness.beginRequest(), state({ sequence: 1 }))).toBe('applied');
      const inFlight = freshness.beginRequest();
      freshness.invalidate(reason);
      expect(freshness.snapshot()).toMatchObject({ fresh: false, showPayment: false, reason });
      expect(freshness.accept(inFlight, state({ sequence: 2 }))).toBe('stale_epoch');
      expect(freshness.snapshot().fresh).toBe(false);
      // Revalidation after the event shows it again.
      expect(freshness.accept(freshness.beginRequest(), state({ sequence: 3 }))).toBe('applied');
      expect(freshness.snapshot().showPayment).toBe(true);
    },
  );

  it('detects a resume from sleep even when the monotonic clock paused', () => {
    const time = clock();
    const freshness = createDisplayFreshness(time);
    freshness.accept(freshness.beginRequest(), state());
    time.sleep(60 * 60 * 1000);
    expect(freshness.tick()).toBe('resumed');
    expect(freshness.snapshot()).toMatchObject({
      fresh: false,
      showPayment: false,
      reason: 'resumed',
    });
  });

  it('starts over for a new session token and refuses malformed bodies', () => {
    const time = clock();
    const freshness = createDisplayFreshness(time);
    freshness.accept(freshness.beginRequest(), state({ sequence: 9, generation: 4 }));
    freshness.reset();
    expect(freshness.snapshot().reason).toBe('disconnected');
    expect(freshness.accept(freshness.beginRequest(), state({ sequence: 1, generation: 1 }))).toBe(
      'applied',
    );
    expect(freshness.accept(freshness.beginRequest(), { ...state(), sequence: 'x' })).toBe(
      'invalid',
    );
    expect(readDisplayState({ ...state(), freshness_ttl_seconds: 0 })).toBeNull();
    expect(readDisplayState({ ...state(), payment: { kind: 'card' } })).toBeNull();
  });
});

describe('pinning the next customer', () => {
  const base: DisplaySession = {
    id: 'posdisplay_1',
    status: 'active',
    generation: 3,
    freshness_ttl_seconds: 15,
    pinned_workspace_id: null,
    pinned_order_number: null,
    pinned_tender_attempt_id: null,
    acked_generation: 3,
    acked_at: '2026-11-07T10:00:00Z',
    ack_current: true,
    last_seen_at: null,
    token_expires_at: '2026-11-07T22:00:00Z',
  };

  it('needs a current acknowledgement of the cleared generation', () => {
    expect(pinDecision(base, 'ws_b')).toEqual({ allowed: true, sameCustomer: false });
    expect(pinDecision({ ...base, acked_generation: 2 }, 'ws_b')).toEqual({
      allowed: false,
      reason: 'ack_required',
    });
    // An expired acknowledgement is not proof the display shows the clear.
    expect(pinDecision({ ...base, ack_current: false }, 'ws_b')).toEqual({
      allowed: false,
      reason: 'ack_required',
    });
  });

  it('keeps the pinned order until it is cleared and allows re-pinning the same one', () => {
    const pinned = { ...base, pinned_workspace_id: 'ws_a', ack_current: false };
    expect(pinDecision(pinned, 'ws_b')).toEqual({ allowed: false, reason: 'busy' });
    expect(pinDecision(pinned, 'ws_a')).toEqual({ allowed: true, sameCustomer: true });
    expect(pinDecision({ ...base, status: 'revoked' }, 'ws_a')).toEqual({
      allowed: false,
      reason: 'inactive',
    });
    expect(pinDecision(null, 'ws_a')).toEqual({ allowed: false, reason: 'inactive' });
  });
});
