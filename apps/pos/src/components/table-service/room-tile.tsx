import { formatMoney } from '@parkviet/pos-shared/money';
import {
  type AttentionReason,
  type BoardTable,
  type BoardTimed,
  clockPlayedSeconds,
  clockSecondsLeft,
  type RoomTone,
  roomTone,
  tableStateKey,
} from '@parkviet/pos-shared/tables';
import { useTranslation } from 'react-i18next';
import { useTicker } from '../../lib/board-ticker';
import { formatElapsed } from '../../lib/timed-clock';
import { PosIcon } from '../pos-icon';

export type RoomClockAction = 'start' | 'pause' | 'resume';

// What a room's clock reads at `serverNow`: the time left to its planned end
// (its package's end) while it runs toward one, "+" the time past it once
// over, else the time played, pauses not counted.
export function roomClockText(timed: BoardTimed, readAt: string | null, serverNow: number): string {
  const left = clockSecondsLeft(timed, serverNow);
  if (left !== null) return left > 0 ? formatElapsed(left) : `+${formatElapsed(-left)}`;
  return formatElapsed(clockPlayedSeconds(timed, readAt, serverNow));
}

// A counting clock reads on the server's time from the shared ticker; any
// other clock stands still.
export function useRoomClock(
  table: BoardTable,
  offsetMs: number,
  readAt: string | null,
): { tone: RoomTone; text: string | null; serverNow: number } {
  const timed = table.timed;
  const serverNow = useTicker(timed?.status === 'running') + offsetMs;
  return {
    tone: roomTone(table, serverNow),
    text: timed ? roomClockText(timed, readAt, serverNow) : null,
    serverNow,
  };
}

// The amounts of a room: its play time (the server's quote at the board's
// read, or as billed once stopped), what it ordered, and both together. A
// stopped clock is already in the order's total.
export function roomAmounts(table: BoardTable): {
  time: number | null;
  items: number | null;
  total: number | null;
} {
  const subtotal = table.orders.length > 0 ? Number(table.subtotal ?? 0) : null;
  const timed = table.timed;
  const time = timed ? Number(timed.quote_amount) : null;
  if (subtotal === null) return { time, items: null, total: time };
  if (timed?.status === 'stopped' && time !== null)
    return { time, items: Math.max(0, subtotal - time), total: subtotal };
  return { time, items: subtotal, total: subtotal + (time ?? 0) };
}

// The clock of a timed table on the restaurant's board (billiards beside
// the dining tables): its time and its tone in words.
export function RoomClockBadge({
  table,
  offsetMs,
  readAt,
}: {
  table: BoardTable;
  offsetMs: number;
  readAt: string | null;
}) {
  const { t } = useTranslation();
  const { tone, text } = useRoomClock(table, offsetMs, readAt);
  return (
    <span className={`board-tile-clock room-clock-${tone}`} data-room-tone={tone}>
      <PosIcon name={tone === 'paused' ? 'pause' : 'clock'} />
      <time className="timed-clock" dateTime={table.timed?.started_at}>
        {text}
      </time>
      <span>{t(`roomTone_${tone}`)}</span>
    </span>
  );
}

function clockTime(value: string | null, language: string, timeZone: string): string | null {
  if (!value) return null;
  const time = new Date(value);
  return Number.isNaN(time.getTime())
    ? null
    : time.toLocaleTimeString(language, { hour: '2-digit', minute: '2-digit', timeZone });
}

// One timed room (or billiard table) on the room board: its name and kind,
// its clock as the largest text, how the clock counts, the time, items and
// total, then the actions that follow the clock: start, pause or resume
// (none once stopped: the session waits for its payment); order; pay. The
// background is one of the room tones and every tone is also said in words,
// as is every reason the room needs someone; past its end the tile blinks
// unless the device asks for less motion.
export function RoomTile({
  table,
  offsetMs,
  readAt,
  timeZone,
  expanded,
  attention,
  canTime,
  canServe,
  locked,
  onDetails,
  onClock,
  onOrder,
  onPay,
}: {
  table: BoardTable;
  // Server clock minus this device's.
  offsetMs: number;
  // The server time the board was read at.
  readAt: string | null;
  timeZone: string;
  expanded: boolean;
  // Why the room needs someone now (`attentionReasons`).
  attention: AttentionReason[];
  // The person runs clocks here.
  canTime: boolean;
  // The person may open an order on a free room.
  canServe: boolean;
  locked: boolean;
  onDetails: (table: BoardTable, anchor: HTMLElement) => void;
  onClock: (table: BoardTable, action: RoomClockAction, anchor: HTMLElement) => void;
  onOrder: (table: BoardTable, anchor: HTMLElement) => void;
  onPay: (table: BoardTable, anchor: HTMLElement) => void;
}) {
  const { t, i18n } = useTranslation();
  const { tone, text } = useRoomClock(table, offsetMs, readAt);
  const timed = table.timed;
  const currency = table.currency ?? 'VND';
  const seated = table.orders.length > 0;
  const out = table.state === 'cleaning' || table.state === 'out_of_service';
  const toneText = t(`roomTone_${tone}`);
  const counting = timed?.status === 'running' || timed?.status === 'paused';
  const detail = (() => {
    // A free room says only what is not plain "free" (a booking).
    if (!timed || !seated)
      return seated || tone !== 'free' || table.state === 'available'
        ? null
        : t(tableStateKey(table.state));
    if (timed.status === 'paused') {
      const since = clockTime(timed.paused_at, i18n.language, timeZone);
      return since ? t('roomPausedSince', { time: since }) : t('timedPaused');
    }
    if (timed.status === 'stopped') {
      const at = clockTime(timed.stopped_at, i18n.language, timeZone);
      return at ? t('timedStopped', { time: at }) : null;
    }
    if (!timed.planned_end_at) return t('roomCountUp');
    if (tone === 'over') return t(timed.prepaid_minutes ? 'roomPackageOver' : 'roomPlannedOver');
    return t(timed.prepaid_minutes ? 'roomPackageLeft' : 'roomPlannedLeft');
  })();
  const amounts = roomAmounts(table);
  const money = (value: number | null) =>
    value === null || (value === 0 && !seated) ? '—' : formatMoney(String(value), currency);
  // A stopped clock waits for its payment: no new start on top of it.
  const clockAction: RoomClockAction | null =
    timed?.status === 'running'
      ? 'pause'
      : timed?.status === 'paused'
        ? 'resume'
        : timed?.status === 'stopped' && seated
          ? null
          : 'start';
  const rate =
    timed?.status === 'running' && timed.rate_per_hour
      ? t('roomRate', { price: formatMoney(timed.rate_per_hour, currency) })
      : null;
  // The clock's own tone already says it ends soon or has ended; a pause too
  // long is said here.
  const flags = attention.filter((reason) => reason !== 'clock' || tone === 'paused');
  const flagTexts = flags.map((reason) => t(`roomAttention_${reason}`));
  // Paying stops a counting clock first, which only someone who runs clocks
  // may do.
  const payBlockedReason = counting && !canTime ? t('roomCannotTime') : undefined;
  const label = [
    table.name,
    toneText,
    counting && text ? text : null,
    detail,
    rate,
    ...flagTexts,
    seated && amounts.total !== null ? formatMoney(String(amounts.total), currency) : null,
  ]
    .filter(Boolean)
    .join(' · ');

  return (
    <article
      className={`room-tile room-tile-${tone}`}
      data-tone={tone}
      data-state={table.state}
      data-table-id={table.id}
      aria-label={table.name}
    >
      <button
        type="button"
        className="room-tile-head"
        aria-label={label}
        aria-haspopup="dialog"
        aria-expanded={expanded}
        onClick={(event) => onDetails(table, event.currentTarget)}
      >
        <span className="room-tile-title">
          <strong>{table.name}</strong>
          <small>{t(`roomKind_${table.kind}`)}</small>
          {tone === 'paused' ? (
            <span className="room-tile-badge" title={toneText}>
              <PosIcon name="pause" />
            </span>
          ) : tone === 'over' ? (
            <span className="room-tile-badge" title={toneText}>
              <PosIcon name="alert" />
            </span>
          ) : null}
        </span>
        {timed && seated ? (
          <time className="room-tile-clock timed-clock" dateTime={timed.started_at}>
            {text}
          </time>
        ) : (
          <span className="room-tile-clock room-tile-clock-empty">{toneText}</span>
        )}
        <span className="room-tile-status">
          {timed && seated ? <b>{toneText}</b> : null}
          {timed && seated && detail ? ' · ' : null}
          {detail}
          {rate ? <span className="room-tile-rate"> · {rate}</span> : null}
        </span>
        {flags.length > 0 ? (
          <span className="room-tile-flags">
            {flags.map((reason, index) => (
              <span key={reason} className={`room-tile-flag room-tile-flag-${reason}`}>
                {flagTexts[index]}
              </span>
            ))}
          </span>
        ) : null}
      </button>
      <dl className="room-tile-money">
        <div>
          <dt>{t('roomTime')}</dt>
          <dd>{money(amounts.time)}</dd>
        </div>
        <div>
          <dt>{t('roomItems')}</dt>
          <dd>{money(amounts.items)}</dd>
        </div>
        <div>
          <dt>{t('roomTotal')}</dt>
          <dd>{money(amounts.total)}</dd>
        </div>
      </dl>
      <div className="room-tile-actions">
        {clockAction ? (
          <button
            type="button"
            className={`room-tile-clock-action room-tile-${clockAction}`}
            disabled={!canTime || locked || (clockAction === 'start' && out)}
            title={canTime ? undefined : t('roomCannotTime')}
            onClick={(event) => onClock(table, clockAction, event.currentTarget)}
          >
            <PosIcon name={clockAction === 'pause' ? 'pause' : 'play'} />
            {t(`roomAction_${clockAction}`)}
          </button>
        ) : null}
        <button
          type="button"
          disabled={!seated && (!canServe || locked)}
          onClick={(event) => onOrder(table, event.currentTarget)}
        >
          {t('roomOrder')}
        </button>
        <button
          type="button"
          className="room-tile-pay"
          disabled={!seated || locked || payBlockedReason !== undefined}
          title={payBlockedReason}
          onClick={(event) => onPay(table, event.currentTarget)}
        >
          {t('ticketPay')}
        </button>
      </div>
    </article>
  );
}
