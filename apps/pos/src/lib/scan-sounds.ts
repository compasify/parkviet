// Short tones that tell the cashier what a scan did without looking up:
// one short beep when a meal is recorded, two beeps for a meal already
// recorded a moment ago, one long low tone for every other refusal. The tones
// are made with Web Audio, so the app ships no sound files, and they are a
// setting of this device (a quiet ward may turn them off).

export type ScanTone = 'ok' | 'duplicate' | 'error';

export const SCAN_SOUNDS_KEY = 'parkviet-pos:scan-sounds';
// Fired on window for every tone asked for, played or muted, so the screen
// (and tests) can tell which outcome the cashier heard.
export const SCAN_TONE_EVENT = 'parkviet-pos:scan-tone';

export type ScanToneDetail = { tone: ScanTone; played: boolean };

type Beep = { frequency: number; start: number; duration: number };

export const TONE_PATTERNS: Record<ScanTone, readonly Beep[]> = {
  ok: [{ frequency: 1320, start: 0, duration: 0.09 }],
  duplicate: [
    { frequency: 880, start: 0, duration: 0.08 },
    { frequency: 880, start: 0.15, duration: 0.08 },
  ],
  error: [{ frequency: 220, start: 0, duration: 0.45 }],
};

const VOLUME = 0.2;

// The tone for a swipe refusal reason; no reason means the meal was recorded.
export function toneForReason(reason: string | null | undefined): ScanTone {
  if (!reason) return 'ok';
  return reason === 'meal_duplicate_swipe' ? 'duplicate' : 'error';
}

function storage(): Storage | null {
  try {
    return globalThis.localStorage ?? null;
  } catch {
    return null;
  }
}

// On unless this device turned them off.
export function scanSoundsEnabled(): boolean {
  try {
    return storage()?.getItem(SCAN_SOUNDS_KEY) !== 'off';
  } catch {
    return true;
  }
}

export function setScanSounds(on: boolean) {
  try {
    if (on) storage()?.removeItem(SCAN_SOUNDS_KEY);
    else storage()?.setItem(SCAN_SOUNDS_KEY, 'off');
  } catch {
    // A preference only: the screen still shows every outcome in text.
  }
}

type AudioContextClass = new () => AudioContext;

function audioContextClass(): AudioContextClass | null {
  const scope = globalThis as typeof globalThis & {
    AudioContext?: AudioContextClass;
    webkitAudioContext?: AudioContextClass;
  };
  return scope.AudioContext ?? scope.webkitAudioContext ?? null;
}

let shared: AudioContext | null = null;

function context(): AudioContext | null {
  if (shared) return shared;
  const Context = audioContextClass();
  if (!Context) return null;
  try {
    shared = new Context();
  } catch {
    return null;
  }
  return shared;
}

// Tests start from a fresh device.
export function resetScanSounds() {
  shared = null;
}

function announce(detail: ScanToneDetail) {
  const target = globalThis as typeof globalThis & {
    dispatchEvent?: (event: Event) => boolean;
    CustomEvent?: typeof CustomEvent;
  };
  if (typeof target.dispatchEvent !== 'function' || typeof target.CustomEvent !== 'function')
    return;
  target.dispatchEvent(new target.CustomEvent(SCAN_TONE_EVENT, { detail }));
}

// Plays the tone; false when it was muted or the device has no audio.
export function playScanTone(tone: ScanTone): boolean {
  let played = false;
  if (scanSoundsEnabled()) {
    const audio = context();
    if (audio) {
      try {
        // A context made before any tap starts suspended; the scan's own key
        // press is the gesture that lets it resume.
        if (audio.state === 'suspended') void audio.resume().catch(() => undefined);
        const now = audio.currentTime;
        for (const beep of TONE_PATTERNS[tone]) {
          const oscillator = audio.createOscillator();
          const gain = audio.createGain();
          oscillator.type = tone === 'error' ? 'square' : 'sine';
          oscillator.frequency.setValueAtTime(beep.frequency, now + beep.start);
          gain.gain.setValueAtTime(VOLUME, now + beep.start);
          gain.gain.setValueAtTime(0, now + beep.start + beep.duration);
          oscillator.connect(gain);
          gain.connect(audio.destination);
          oscillator.start(now + beep.start);
          oscillator.stop(now + beep.start + beep.duration);
        }
        played = true;
      } catch {
        played = false;
      }
    }
  }
  announce({ tone, played });
  return played;
}
