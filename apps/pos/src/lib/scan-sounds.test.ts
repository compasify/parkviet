import { afterEach, beforeEach, describe, expect, it, vi } from 'vitest';
import {
  playScanTone,
  resetScanSounds,
  SCAN_SOUNDS_KEY,
  SCAN_TONE_EVENT,
  type ScanToneDetail,
  scanSoundsEnabled,
  setScanSounds,
  TONE_PATTERNS,
  toneForReason,
} from './scan-sounds';

type Started = { frequency: number; start: number; stop: number };

function fakeAudio(started: Started[], state: 'running' | 'suspended' = 'running') {
  const resume = vi.fn(() => Promise.resolve());
  class FakeAudioContext {
    state = state;
    currentTime = 10;
    destination = {};
    resume = resume;
    createGain() {
      return { gain: { setValueAtTime: vi.fn() }, connect: vi.fn() };
    }
    createOscillator() {
      let frequency = 0;
      let start = 0;
      return {
        type: 'sine',
        frequency: {
          setValueAtTime: (value: number) => {
            frequency = value;
          },
        },
        connect: vi.fn(),
        start: (at: number) => {
          start = at;
        },
        stop: (at: number) => started.push({ frequency, start, stop: at }),
      };
    }
  }
  return { FakeAudioContext, resume };
}

describe('scan sounds', () => {
  let store: Map<string, string>;
  let heard: ScanToneDetail[];

  beforeEach(() => {
    resetScanSounds();
    store = new Map();
    heard = [];
    vi.stubGlobal('localStorage', {
      getItem: (key: string) => store.get(key) ?? null,
      setItem: (key: string, value: string) => store.set(key, value),
      removeItem: (key: string) => store.delete(key),
    });
    const target = new EventTarget();
    target.addEventListener(SCAN_TONE_EVENT, (event) =>
      heard.push((event as CustomEvent<ScanToneDetail>).detail),
    );
    vi.stubGlobal('dispatchEvent', (event: Event) => target.dispatchEvent(event));
  });
  afterEach(() => {
    vi.unstubAllGlobals();
    resetScanSounds();
  });

  it('maps a recorded meal, a repeated swipe and every other refusal to three tones', () => {
    expect(toneForReason(null)).toBe('ok');
    expect(toneForReason(undefined)).toBe('ok');
    expect(toneForReason('meal_duplicate_swipe')).toBe('duplicate');
    expect(toneForReason('meal_daily_limit')).toBe('error');
    expect(toneForReason('meal_account_unknown')).toBe('error');
    expect(toneForReason('module_disabled')).toBe('error');
  });

  it('plays one short beep, two beeps and one long tone', () => {
    const started: Started[] = [];
    vi.stubGlobal('AudioContext', fakeAudio(started).FakeAudioContext);

    expect(playScanTone('ok')).toBe(true);
    expect(started).toHaveLength(1);
    expect(playScanTone('duplicate')).toBe(true);
    expect(started).toHaveLength(3);
    expect(started[1].start).toBeLessThan(started[2].start);
    expect(playScanTone('error')).toBe(true);
    expect(started).toHaveLength(4);

    const [ok, , , error] = started;
    expect(error.stop - error.start).toBeGreaterThan(ok.stop - ok.start);
    expect(error.frequency).toBeLessThan(ok.frequency);
    expect(TONE_PATTERNS.duplicate).toHaveLength(2);
    expect(heard.map((detail) => detail.tone)).toEqual(['ok', 'duplicate', 'error']);
    expect(heard.every((detail) => detail.played)).toBe(true);
  });

  it('resumes a context the browser started suspended', () => {
    const audio = fakeAudio([], 'suspended');
    vi.stubGlobal('AudioContext', audio.FakeAudioContext);
    playScanTone('ok');
    expect(audio.resume).toHaveBeenCalled();
  });

  it('keeps the on/off choice per device and stays silent when off', () => {
    const started: Started[] = [];
    vi.stubGlobal('AudioContext', fakeAudio(started).FakeAudioContext);
    expect(scanSoundsEnabled()).toBe(true);

    setScanSounds(false);
    expect(store.get(SCAN_SOUNDS_KEY)).toBe('off');
    expect(scanSoundsEnabled()).toBe(false);
    expect(playScanTone('error')).toBe(false);
    expect(started).toHaveLength(0);
    expect(heard).toEqual([{ tone: 'error', played: false }]);

    setScanSounds(true);
    expect(store.has(SCAN_SOUNDS_KEY)).toBe(false);
    expect(playScanTone('ok')).toBe(true);
  });

  it('does nothing harmful without Web Audio or storage', () => {
    vi.stubGlobal('AudioContext', undefined);
    expect(playScanTone('ok')).toBe(false);
    expect(heard).toEqual([{ tone: 'ok', played: false }]);

    resetScanSounds();
    class BrokenAudioContext {
      constructor() {
        throw new Error('no audio device');
      }
    }
    vi.stubGlobal('AudioContext', BrokenAudioContext);
    expect(playScanTone('duplicate')).toBe(false);

    const denied = () => {
      throw new Error('Storage denied');
    };
    vi.stubGlobal('localStorage', { getItem: denied, setItem: denied, removeItem: denied });
    expect(scanSoundsEnabled()).toBe(true);
    expect(() => setScanSounds(false)).not.toThrow();
  });
});
