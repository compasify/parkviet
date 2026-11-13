import { afterEach, describe, expect, it, vi } from 'vitest';
import { subscribeTicker, tickerNow, tickerRunning } from './board-ticker';

describe('board ticker', () => {
  afterEach(() => {
    vi.useRealTimers();
  });

  it('runs one timer for every watcher and stops with the last one', () => {
    vi.useFakeTimers();
    const first = vi.fn();
    const second = vi.fn();
    expect(tickerRunning()).toBe(false);
    const stopFirst = subscribeTicker(first);
    const stopSecond = subscribeTicker(second);
    expect(tickerRunning()).toBe(true);
    expect(vi.getTimerCount()).toBe(1);

    vi.advanceTimersByTime(3000);
    expect(first).toHaveBeenCalledTimes(3);
    expect(second).toHaveBeenCalledTimes(3);

    stopFirst();
    expect(tickerRunning()).toBe(true);
    vi.advanceTimersByTime(1000);
    expect(first).toHaveBeenCalledTimes(3);
    expect(second).toHaveBeenCalledTimes(4);

    stopSecond();
    expect(tickerRunning()).toBe(false);
    expect(vi.getTimerCount()).toBe(0);
  });

  it('gives the time now, not a stale tick, while no timer runs', () => {
    vi.useFakeTimers();
    vi.setSystemTime(new Date('2026-11-12T10:00:00Z'));
    const stop = subscribeTicker(() => {});
    stop();
    vi.setSystemTime(new Date('2026-11-12T12:00:30Z'));
    expect(tickerNow(1000)).toBe(Date.parse('2026-11-12T12:00:30Z'));
    expect(tickerNow(60_000)).toBe(Date.parse('2026-11-12T12:00:00Z'));
  });
});
