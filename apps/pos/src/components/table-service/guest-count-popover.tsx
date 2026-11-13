import { type ReactNode, useLayoutEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useModalFocus } from '../../lib/dialog-focus';
import { MAX_GUESTS } from '../table-floor';

const QUICK_COUNTS = [1, 2, 3, 4, 5, 6, 7, 8];
const WIDTH = 300;
const GAP = 6;

// A small dialog placed just under the tile it was opened from (above it when
// there is no room below). Focus stays inside, Escape or a tap beside it closes.
export function BoardPopover({
  anchor,
  label,
  onClose,
  children,
}: {
  anchor: HTMLElement;
  label: string;
  onClose: () => void;
  children: ReactNode;
}) {
  const { t } = useTranslation();
  const ref = useRef<HTMLDivElement>(null);
  const [place, setPlace] = useState<{ left: number; top: number } | null>(null);
  useModalFocus(ref, onClose);
  useLayoutEffect(() => {
    const box = anchor.getBoundingClientRect();
    const height = ref.current?.offsetHeight ?? 0;
    const left = Math.max(GAP, Math.min(box.left, window.innerWidth - WIDTH - GAP));
    const below = box.bottom + GAP;
    const top =
      below + height <= window.innerHeight - GAP ? below : Math.max(GAP, box.top - height - GAP);
    setPlace({ left, top });
  }, [anchor]);
  return (
    <div className="pos-popup-backdrop board-popover-layer">
      {/* A tap beside the popover closes it; the keyboard uses Escape. */}
      <button
        type="button"
        className="board-popover-dismiss"
        tabIndex={-1}
        aria-label={t('adminClose')}
        onClick={onClose}
      />
      <div
        ref={ref}
        className="board-popover"
        role="dialog"
        aria-modal="true"
        aria-label={label}
        tabIndex={-1}
        style={place ? { left: place.left, top: place.top } : { visibility: 'hidden' }}
      >
        {children}
      </div>
    </div>
  );
}

// Seats guests at a free table: a tap on a count (or "…" for more), then
// "Mở bàn · n khách". The count may stay unknown only through "…" left blank.
export function GuestCountPicker({
  title,
  hint,
  busy,
  disabled,
  disabledReason,
  error,
  onOpen,
  children,
}: {
  title: string;
  hint: string;
  busy: boolean;
  disabled: boolean;
  disabledReason?: string;
  error: string;
  onOpen: (guestCount: number | null) => void;
  // Other actions on the table, below the open button.
  children?: ReactNode;
}) {
  const { t } = useTranslation();
  const [count, setCount] = useState<number | 'other'>(2);
  const [other, setOther] = useState('');
  const [invalid, setInvalid] = useState(false);

  function submit() {
    if (count !== 'other') {
      onOpen(count);
      return;
    }
    const raw = other.trim();
    if (!raw) {
      onOpen(null);
      return;
    }
    const value = Number(raw);
    if (!Number.isInteger(value) || value < 0 || value > MAX_GUESTS) {
      setInvalid(true);
      return;
    }
    setInvalid(false);
    onOpen(value);
  }

  return (
    <div className="guest-count-picker">
      <h3>{title}</h3>
      <p>{hint}</p>
      <fieldset className="guest-count-options">
        <legend className="visually-hidden">{t('tableGuestCount')}</legend>
        {QUICK_COUNTS.map((value) => (
          <button
            key={value}
            type="button"
            aria-pressed={count === value}
            onClick={() => setCount(value)}
          >
            {value}
          </button>
        ))}
        <button
          type="button"
          aria-pressed={count === 'other'}
          aria-label={t('boardGuestsOther')}
          onClick={() => setCount('other')}
        >
          …
        </button>
      </fieldset>
      {count === 'other' ? (
        <label>
          {t('tableGuestCount')}
          <input
            type="number"
            inputMode="numeric"
            min={0}
            max={MAX_GUESTS}
            value={other}
            onChange={(event) => setOther(event.target.value)}
          />
        </label>
      ) : null}
      <button
        type="button"
        className="primary-button board-popover-primary"
        disabled={busy || disabled}
        title={disabledReason}
        onClick={submit}
      >
        {count === 'other' && !other.trim()
          ? t('tableOpen')
          : t('boardOpenGuests', {
              count: count === 'other' ? Number(other) || 0 : count,
            })}
      </button>
      {children}
      {invalid || error ? (
        <p className="error" role="alert">
          {invalid ? t('tableGuestCountInvalid', { max: MAX_GUESTS }) : error}
        </p>
      ) : null}
    </div>
  );
}
