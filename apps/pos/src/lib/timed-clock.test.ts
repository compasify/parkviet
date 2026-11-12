import { describe, expect, it } from 'vitest';
import en from '../locales/en.json';
import vi from '../locales/vi.json';
import type { PosContext } from './pos-context';
import {
  canRunClock,
  clockOffset,
  elapsedSeconds,
  formatElapsed,
  fromLocalInput,
  isRunning,
  TIMED_FAILURE_REASONS,
  timedFailureKey,
  toLocalInput,
} from './timed-clock';

describe('room clock', () => {
  it('measures the server clock against this device', () => {
    expect(clockOffset('2026-11-12T10:00:30Z', Date.parse('2026-11-12T10:00:00Z'))).toBe(30_000);
    expect(clockOffset(null, Date.now())).toBe(0);
    expect(clockOffset('not a time', Date.now())).toBe(0);
  });

  it('counts from the server start, on the server clock, until it stops', () => {
    const started = { started_at: '2026-11-12T10:00:00Z', stopped_at: null };
    const device = Date.parse('2026-11-12T10:05:00Z');
    // The device runs 9 s behind the server.
    expect(elapsedSeconds(started, device, 9_000)).toBe(309);
    expect(elapsedSeconds({ ...started, stopped_at: '2026-11-12T11:00:00Z' }, device, 9_000)).toBe(
      3600,
    );
    // A device far ahead of a fresh start shows zero, never a negative time.
    expect(elapsedSeconds(started, Date.parse('2026-11-12T09:00:00Z'), 0)).toBe(0);
    expect(elapsedSeconds({ started_at: '', stopped_at: null }, device, 0)).toBe(0);
  });

  it('writes the elapsed time', () => {
    expect(formatElapsed(309)).toBe('05:09');
    expect(formatElapsed(3909)).toBe('1:05:09');
    expect(formatElapsed(-4)).toBe('00:00');
  });

  it('tells running clocks from stopped ones', () => {
    const base = {
      id: 't',
      workspace_id: null,
      started_at: '',
      stopped_at: null,
      planned_end_at: null,
      played_minutes: 0,
      quote_amount: '0',
      ending_soon: false,
    };
    expect(isRunning({ ...base, status: 'running' })).toBe(true);
    expect(isRunning({ ...base, status: 'stopped' })).toBe(false);
    expect(isRunning(null)).toBe(false);
  });

  it('lets people who run play time start a clock where the branch bills it', () => {
    const context = (capabilities: string[], modules: Record<string, boolean>) =>
      ({ capabilities, modules }) as unknown as PosContext;
    expect(canRunClock(context(['pos.timed.operate'], { timed_billing: true }))).toBe(true);
    expect(canRunClock(context(['pos.table.serve'], { timed_billing: true }))).toBe(false);
    expect(canRunClock(context(['pos.timed.operate'], {}))).toBe(false);
    expect(canRunClock(undefined)).toBe(false);
  });

  it('words every clock refusal in both languages', () => {
    expect(timedFailureKey('something_else')).toBeNull();
    for (const reason of TIMED_FAILURE_REASONS)
      for (const bundle of [vi, en])
        expect((bundle as Record<string, unknown>)[`timedFailure_${reason}`]).toEqual(
          expect.any(String),
        );
  });
});

describe('datetime-local values', () => {
  it('shows a server time on this device and sends it back unchanged', () => {
    const value = toLocalInput('2026-11-12T14:30:00Z');
    expect(value).toMatch(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$/);
    expect(fromLocalInput(value)).toBe('2026-11-12T14:30:00.000Z');
  });

  it('keeps empty and broken values empty', () => {
    expect(toLocalInput(null)).toBe('');
    expect(toLocalInput('not a time')).toBe('');
    expect(fromLocalInput('')).toBeNull();
    expect(fromLocalInput('nope')).toBeNull();
  });
});
