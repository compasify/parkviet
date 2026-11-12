import type { BoardTimed } from '@parkviet/pos-shared/tables';
import type { PosContext } from './pos-context';

export const TIMED_MODULE = 'timed_billing';

// The clock of a room shown at the counter. Every time comes from the
// server: the elapsed time counts from the session's `started_at` on the
// server clock, which is this device's clock moved by the offset measured
// when the board was read. The device's own time never starts or bills a
// clock; the amount shown is the server's quote.

// Refresh the server's quote of a running clock every minute.
export const TIMED_QUOTE_POLL_MS = 60_000;

// How far the server clock is ahead of this device, from a server time and
// the device time it was received at. Zero when the server sent no time.
export function clockOffset(serverNow: string | null | undefined, receivedAtMs: number): number {
  const server = serverNow ? Date.parse(serverNow) : Number.NaN;
  return Number.isFinite(server) && Number.isFinite(receivedAtMs) ? server - receivedAtMs : 0;
}

// Whole seconds a clock has run on the server clock: until it stopped, else
// until now. Never negative, and zero for a clock without a valid start.
export function elapsedSeconds(
  timed: Pick<BoardTimed, 'started_at' | 'stopped_at'>,
  deviceNowMs: number,
  offsetMs: number,
): number {
  const started = Date.parse(timed.started_at);
  if (!Number.isFinite(started)) return 0;
  const stopped = timed.stopped_at ? Date.parse(timed.stopped_at) : Number.NaN;
  const end = Number.isFinite(stopped) ? stopped : deviceNowMs + offsetMs;
  return Math.max(0, Math.floor((end - started) / 1000));
}

// "1:05:09", or "05:09" under an hour.
export function formatElapsed(seconds: number): string {
  const total = Math.max(0, Math.floor(seconds));
  const hours = Math.floor(total / 3600);
  const minutes = Math.floor((total % 3600) / 60);
  const rest = total % 60;
  const pad = (value: number) => String(value).padStart(2, '0');
  return hours > 0 ? `${hours}:${pad(minutes)}:${pad(rest)}` : `${pad(minutes)}:${pad(rest)}`;
}

export function isRunning(timed: BoardTimed | null | undefined): boolean {
  return timed?.status === 'running' || timed?.status === 'paused';
}

// Who runs clocks here: the branch bills play time and the person may run it.
export function canRunClock(context: PosContext | undefined): boolean {
  return (
    context?.modules?.[TIMED_MODULE] === true && context.capabilities.includes('pos.timed.operate')
  );
}

// Refusals of the clock commands that have their own wording.
export const TIMED_FAILURE_REASONS = [
  'timed_session_running',
  'rate_plan_missing',
  'workspace_required',
  'timed_session_stopped',
  'timed_line',
  'planned_end_invalid',
  'timed_amount_unrepresentable',
  'segment_overlap',
  'time_in_future',
  'time_invalid',
  'segment_open',
  'reason_required',
  'time_required',
  'timed_session_paused',
  'timed_session_not_paused',
  'approval_required',
  'timed_package_unknown',
  'stored_value_card_unknown',
  'stored_value_closed',
  'stored_value_insufficient',
  'stored_value_changed',
  'timed_card_charged',
  'attendant_busy',
  'attendant_not_member',
] as const;

export function timedFailureKey(reason: string | null): string | null {
  return reason && (TIMED_FAILURE_REASONS as readonly string[]).includes(reason)
    ? `timedFailure_${reason}`
    : null;
}

// A server time as a `datetime-local` input shows it on this device
// ("2026-11-12T21:30"); empty for no time.
export function toLocalInput(value: string | null | undefined): string {
  const time = value ? new Date(value) : null;
  if (!time || Number.isNaN(time.getTime())) return '';
  const pad = (part: number) => String(part).padStart(2, '0');
  return `${time.getFullYear()}-${pad(time.getMonth() + 1)}-${pad(time.getDate())}T${pad(time.getHours())}:${pad(time.getMinutes())}`;
}

// A `datetime-local` value back as an ISO time for the server; null when
// empty or not a time.
export function fromLocalInput(value: string): string | null {
  if (!value) return null;
  const time = new Date(value);
  return Number.isNaN(time.getTime()) ? null : time.toISOString();
}
