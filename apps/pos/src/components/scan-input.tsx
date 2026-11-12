import { type KeyboardEvent, useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { resolveMealAccount } from '../hooks/use-meal-accounts';
import { type MealAccount, mealReasonKey } from '../lib/meal-accounts';
import type { PosWorkspace } from '../lib/pos-context';
import { conflictReason, describeFailure, failureStatus } from '../lib/request-failure';
import {
  playScanTone,
  type ScanTone,
  scanSoundsEnabled,
  setScanSounds,
  toneForReason,
} from '../lib/scan-sounds';
import type { ScanNotice } from './catalog-search';
import { PosIcon } from './pos-icon';

export type MealSwipeInput =
  | { code: string; inputMethod: 'code' }
  | { mealAccountId: string; inputMethod: 'search' };

type Feedback = { tone: ScanTone | 'info'; text: string };

// Taps here do not keep the focus away from the scan field: the menu tiles,
// the basket and its buttons hand it back. Text fields, popups and dialogs
// keep theirs.
const KEEP_FOCUS_AREA = '#pos-catalog, #pos-basket';
const OWN_FOCUS =
  'input, textarea, select, label, details, [role="dialog"], [contenteditable]:not([contenteditable="false"])';
const TEXT_ENTRY = 'input, textarea, select, [contenteditable]:not([contenteditable="false"])';

// A product code from a scanner or typed: one word holding a digit. Names
// never do, so a name without a match is never sent to the catalogue.
export function looksLikeBarcode(code: string) {
  return /^\S{3,}$/.test(code) && /\d/.test(code);
}

// The canteen's scan field on the sale screen. An employee code and Enter
// records the meal on the open order; a name lists the matching eaters to
// pick from; a product barcode goes on to the ordinary barcode lookup. Each
// outcome plays its tone (recorded, already recorded, refused) and the
// refusal is spelled out. The field keeps the focus like a keyboard wedge.
export function ScanInput({
  branchId,
  workspace,
  disabled,
  onSwipe,
  onBarcode,
  barcodeNotice,
}: {
  branchId: string | null;
  workspace: PosWorkspace | null;
  // The order cannot take a meal now (not editing it, locked, no order).
  disabled: boolean;
  onSwipe: (input: MealSwipeInput) => Promise<unknown>;
  onBarcode?: (code: string) => void;
  // The outcome of a barcode handed on, when no catalogue search shows it.
  barcodeNotice?: ScanNotice | null;
}) {
  const { t } = useTranslation();
  const input = useRef<HTMLInputElement>(null);
  const [value, setValue] = useState('');
  const [suggestions, setSuggestions] = useState<MealAccount[]>([]);
  const [feedback, setFeedback] = useState<Feedback | null>(null);
  const [busy, setBusy] = useState(false);
  const [sounds, setSounds] = useState(() => scanSoundsEnabled());
  // Codes typed while the previous one is still answering wait their turn.
  const queue = useRef<Promise<void>>(Promise.resolve());
  const latest = useRef({ branchId, workspace, disabled, onSwipe, onBarcode });
  latest.current = { branchId, workspace, disabled, onSwipe, onBarcode };

  const focus = () => input.current?.focus({ preventScroll: true });
  const workspaceId = workspace?.id ?? null;
  // biome-ignore lint/correctness/useExhaustiveDependencies: a newly selected order takes the focus back
  useEffect(() => {
    setSuggestions([]);
    focus();
  }, [workspaceId]);

  useEffect(() => {
    const regain = (event: PointerEvent) => {
      const target = event.target;
      if (!(target instanceof Element) || !target.closest(KEEP_FOCUS_AREA)) return;
      if (target.closest(OWN_FOCUS)) return;
      window.setTimeout(() => {
        const active = document.activeElement;
        if (active instanceof HTMLElement && active.matches(TEXT_ENTRY)) return;
        if (document.querySelector('[role="dialog"], [aria-modal="true"]')) return;
        input.current?.focus({ preventScroll: true });
      }, 0);
    };
    document.addEventListener('pointerup', regain);
    return () => document.removeEventListener('pointerup', regain);
  }, []);

  function tell(tone: ScanTone | 'info', text: string) {
    setFeedback({ tone, text });
    if (tone !== 'info') playScanTone(tone);
  }

  function refusal(error: unknown) {
    if (failureStatus(error) === 429) return t('mealReason_meal_resolve_rate_limited');
    const key = mealReasonKey(conflictReason(error));
    return key ? t(key) : describeFailure(error, t);
  }

  async function swipe(swipeInput: MealSwipeInput, name: string) {
    try {
      await latest.current.onSwipe(swipeInput);
      tell('ok', t('mealSwipeOk', { name }));
    } catch (error) {
      tell(toneForReason(conflictReason(error) ?? 'request_failed'), refusal(error));
    }
  }

  async function handle(code: string) {
    const current = latest.current;
    if (!current.branchId || !current.workspace || current.disabled) {
      tell('error', t('mealScanNoOrder'));
      return;
    }
    let found: Awaited<ReturnType<typeof resolveMealAccount>>;
    try {
      found = await resolveMealAccount(current.branchId, code);
    } catch (error) {
      tell('error', refusal(error));
      return;
    }
    if (found.match) {
      await swipe({ code, inputMethod: 'code' }, found.match.name);
      return;
    }
    if (found.suggestions.length > 0) {
      setSuggestions(found.suggestions);
      tell('info', t('mealScanPick', { count: found.suggestions.length }));
      return;
    }
    if (current.onBarcode && looksLikeBarcode(code)) {
      setFeedback(null);
      current.onBarcode(code);
      return;
    }
    tell('error', t('mealScanNotFound', { code }));
  }

  function enqueue(task: () => Promise<void>) {
    setBusy(true);
    const next = queue.current.then(task).finally(() => {
      if (queue.current === next) setBusy(false);
      focus();
    });
    queue.current = next;
  }

  function onKeyDown(event: KeyboardEvent<HTMLInputElement>) {
    if (event.key === 'Escape') {
      setSuggestions([]);
      setValue('');
      return;
    }
    if (event.key !== 'Enter') return;
    // The scanner's Enter must not also submit or press anything else.
    event.preventDefault();
    const code = value.trim();
    if (!code) return;
    setValue('');
    setSuggestions([]);
    enqueue(() => handle(code));
  }

  function pick(account: MealAccount) {
    setSuggestions([]);
    enqueue(() => swipe({ mealAccountId: account.id, inputMethod: 'search' }, account.name));
  }

  const notice = barcodeNotice && !barcodeNotice.added ? barcodeNotice.message : '';

  return (
    <section className="meal-scan" aria-label={t('mealScanTitle')}>
      <div className="meal-scan-row">
        <label className="meal-scan-field">
          <span>{t('mealScanLabel')}</span>
          <input
            ref={input}
            value={value}
            maxLength={120}
            autoComplete="off"
            spellCheck={false}
            placeholder={t('mealScanPlaceholder')}
            aria-busy={busy}
            onChange={(event) => setValue(event.target.value)}
            onKeyDown={onKeyDown}
          />
        </label>
        <button
          type="button"
          className="meal-scan-sound"
          aria-pressed={sounds}
          title={t(sounds ? 'mealScanSoundOff' : 'mealScanSoundOn')}
          onClick={() => {
            setScanSounds(!sounds);
            setSounds(!sounds);
            focus();
          }}
        >
          <PosIcon name="check" />
          {t('mealScanSound')}
        </button>
      </div>
      {suggestions.length > 0 ? (
        <ul className="meal-scan-suggestions" aria-label={t('mealScanSuggestions')}>
          {suggestions.map((account) => (
            <li key={account.id}>
              <button type="button" disabled={disabled} onClick={() => pick(account)}>
                <strong>{account.name}</strong>
                <small>
                  {account.employee_code}
                  {account.group_label ? ` · ${account.group_label}` : ''}
                </small>
              </button>
            </li>
          ))}
        </ul>
      ) : null}
      {feedback ? (
        <p
          className={`meal-scan-feedback meal-scan-${feedback.tone}`}
          role={feedback.tone === 'ok' || feedback.tone === 'info' ? 'status' : 'alert'}
          data-tone={feedback.tone}
        >
          {feedback.text}
        </p>
      ) : null}
      {notice ? (
        <p className="meal-scan-feedback meal-scan-error" role="alert">
          {notice}
        </p>
      ) : null}
    </section>
  );
}
