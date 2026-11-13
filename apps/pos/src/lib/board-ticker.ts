import { useSyncExternalStore } from 'react';

// One clock for every room clock on the screen: a single one-second timer
// runs while something watches it and stops with the last watcher, so a
// board of dozens of rooms never holds a timer per tile. The time it gives is
// this device's; callers move it onto the server clock themselves.

const TICK_MS = 1000;

let now = Date.now();
let timer: ReturnType<typeof setInterval> | null = null;
const listeners = new Set<() => void>();

function tick() {
  now = Date.now();
  for (const listener of listeners) listener();
}

export function subscribeTicker(listener: () => void): () => void {
  listeners.add(listener);
  if (timer === null) {
    // A watcher arriving after a quiet spell starts from the time now.
    now = Date.now();
    timer = setInterval(tick, TICK_MS);
  }
  return () => {
    listeners.delete(listener);
    if (listeners.size === 0 && timer !== null) {
      clearInterval(timer);
      timer = null;
    }
  };
}

// Whether the shared timer runs: something watches it.
export function tickerRunning(): boolean {
  return timer !== null;
}

// The time the ticker gives, in steps of `stepMs`: the last tick while the
// timer runs, else the time now (the last tick may be long gone).
export function tickerNow(stepMs: number): number {
  return Math.floor((timer === null ? Date.now() : now) / stepMs) * stepMs;
}

function idle() {
  return () => {};
}

// This device's time in steps of `stepMs`, moving on by itself while
// `active`; a component re-renders only when its step changes. Inactive, it
// is the time of the render and watches nothing.
export function useTicker(active: boolean, stepMs = TICK_MS): number {
  const step = Math.max(TICK_MS, stepMs);
  const ticked = useSyncExternalStore(active ? subscribeTicker : idle, () =>
    active ? tickerNow(step) : null,
  );
  return ticked ?? Date.now();
}
