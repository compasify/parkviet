import { formatMoney } from '@parkviet/pos-shared/money';
import {
  type BoardTable,
  buffetMinutesLeft,
  buffetTiming,
  tableStateKey,
} from '@parkviet/pos-shared/tables';
import type { CSSProperties } from 'react';
import { useTranslation } from 'react-i18next';
import { isRunning } from '../lib/timed-clock';
import { TimedClock } from './timed-panel';

// One table on the floor, as a tile in the grid or a shape on the plan. The
// state is always written out beside its colour.
export function TableTile({
  table,
  selected,
  onSelect,
  style,
  offsetMs = 0,
  readAt = null,
}: {
  table: BoardTable;
  selected: boolean;
  onSelect: (table: BoardTable) => void;
  style?: CSSProperties;
  // Server clock minus this device's, for a room clock.
  offsetMs?: number;
  // The server time the board was read at.
  readAt?: string | null;
}) {
  const { t, i18n } = useTranslation();
  const state = t(tableStateKey(table.state));
  // The board is read again every few seconds, so the clock of the read is near enough.
  const now = new Date().toISOString();
  const buffet = buffetTiming(table.buffet_ends_at, now);
  const buffetLeft = buffetMinutesLeft(table.buffet_ends_at, now);
  const booking = table.next_reservation;
  // A room past its package or paused too long needs someone now (red);
  // a room ending soon shows its own state colour (amber).
  const timedAlert =
    table.timed && (table.timed.package_ended || table.timed.pause_too_long)
      ? ' table-tile-timed-alert'
      : '';
  return (
    <button
      type="button"
      className={`table-tile table-tile-${table.state} table-shape-${table.shape}${
        buffet === 'ending' || buffet === 'over' ? ` table-tile-buffet-${buffet}` : ''
      }${timedAlert}`}
      data-state={table.state}
      data-table-id={table.id}
      aria-pressed={selected}
      aria-label={`${table.name} · ${state}`}
      style={style}
      onClick={() => onSelect(table)}
    >
      <strong className="table-tile-name">{table.name}</strong>
      <span className="table-tile-state">{state}</span>
      {table.orders.length > 0 ? (
        <span className="table-tile-meta">
          {table.guest_count != null ? (
            <span>{t('tableGuests', { count: table.guest_count })}</span>
          ) : null}
          {table.seated_minutes != null ? (
            <span>{t('tableSeatedMinutes', { count: table.seated_minutes })}</span>
          ) : null}
          {table.orders.length > 1 ? (
            <span>{t('tableOrderCount', { count: table.orders.length })}</span>
          ) : null}
        </span>
      ) : (
        <span className="table-tile-meta">{t('tableCapacity', { count: table.capacity })}</span>
      )}
      {table.subtotal != null && table.orders.length > 0 ? (
        <span className="table-tile-total">
          {formatMoney(table.subtotal, table.currency ?? 'VND')}
        </span>
      ) : null}
      {table.timed && isRunning(table.timed) ? (
        <span className="table-tile-flag table-tile-timed">
          {table.timed.status === 'paused' ? `${t('timedPaused')} · ` : null}
          <TimedClock timed={table.timed} offsetMs={offsetMs} readAt={readAt} />{' '}
          {formatMoney(table.timed.quote_amount, table.currency ?? 'VND')}
        </span>
      ) : null}
      {booking ? (
        <span className="table-tile-flag table-tile-booking">
          {t('tableNextReservation', {
            time: new Date(booking.starts_at).toLocaleTimeString(i18n.language, {
              hour: '2-digit',
              minute: '2-digit',
            }),
            name: booking.guest_name,
            count: booking.party_size,
          })}
        </span>
      ) : null}
      {buffet !== 'none' && buffetLeft != null ? (
        <span className={`table-tile-flag table-tile-buffet table-tile-buffet-${buffet}`}>
          {buffet === 'over'
            ? t('tableBuffetOver')
            : t('tableBuffetLeft', { count: Math.max(0, buffetLeft) })}
        </span>
      ) : null}
      {table.edited_after_prebill ? (
        <span className="table-tile-flag">{t('tableEditedAfterPrebill')}</span>
      ) : null}
    </button>
  );
}
