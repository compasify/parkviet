import { formatMoney } from '@parkviet/pos-shared/money';
import { type BoardTable, type BoardTone, tableStateKey } from '@parkviet/pos-shared/tables';
import type { CSSProperties } from 'react';
import { useTranslation } from 'react-i18next';
import { PosIcon } from '../pos-icon';

// One table on the board: its name, how long it has been seated (the
// largest text), its state in words, the guests and the running total. The
// background is one of five tones; a late kitchen or a long stay adds a red
// strip and red minutes; a booking, a bill asked for, several orders or a
// pre-bill edited since are corner badges. Colour is never the only signal.
export function BoardTile({
  table,
  tone,
  alert,
  expanded,
  style,
  onSelect,
}: {
  table: BoardTable;
  tone: BoardTone;
  alert: boolean;
  expanded: boolean;
  style?: CSSProperties;
  onSelect: (table: BoardTable, tile: HTMLButtonElement) => void;
}) {
  const { t, i18n } = useTranslation();
  const seated = table.orders.length > 0;
  const status = seated ? t(`boardTone_${tone}`) : t(tableStateKey(table.state));
  const waitingLong = seated && table.state === 'waiting_long';
  const booking = table.next_reservation;
  const bookingTime = booking
    ? new Date(booking.starts_at).toLocaleTimeString(i18n.language, {
        hour: '2-digit',
        minute: '2-digit',
      })
    : null;
  const total = Number(table.subtotal ?? 0) > 0 ? table.subtotal : null;
  const label = [
    `${table.name} · ${status}`,
    waitingLong ? t('tableState_waiting_long') : null,
    alert && !waitingLong ? t('boardSeatedLong') : null,
  ]
    .filter(Boolean)
    .join(' · ');
  return (
    <button
      type="button"
      className={`board-tile board-tile-${tone}`}
      data-tone={tone}
      data-state={table.state}
      data-alert={alert || undefined}
      data-table-id={table.id}
      aria-label={label}
      aria-haspopup="dialog"
      aria-expanded={expanded}
      style={style}
      onClick={(event) => onSelect(table, event.currentTarget)}
    >
      <span className="board-tile-icons">
        {booking && bookingTime ? (
          <span
            className="board-tile-icon"
            title={t('tableNextReservation', {
              time: bookingTime,
              name: booking.guest_name,
              count: booking.party_size,
            })}
          >
            <span className="visually-hidden">{t('boardReserved')} </span>
            {bookingTime}
          </span>
        ) : null}
        {table.orders.length > 1 ? (
          <span
            className="board-tile-icon"
            title={t('tableOrderCount', { count: table.orders.length })}
          >
            {t('tableOrderCount', { count: table.orders.length })}
          </span>
        ) : null}
        {table.edited_after_prebill ? (
          <span className="board-tile-icon" title={t('tableEditedAfterPrebill')}>
            <PosIcon name="edit" />
            <span className="visually-hidden">{t('tableEditedAfterPrebill')}</span>
          </span>
        ) : null}
        {tone === 'payment' ? (
          <span className="board-tile-icon" title={t('boardTone_payment')}>
            ₫
          </span>
        ) : null}
      </span>
      <strong className="board-tile-name">{table.name}</strong>
      {seated ? (
        <>
          {alert ? <span className="board-tile-strip" aria-hidden="true" /> : null}
          <span className="board-tile-time">
            {table.seated_minutes != null ? `${table.seated_minutes}′` : '—'}
          </span>
          {/* A late kitchen is said in red in place of the tone's words; the
          background still shows the tone and the label names both. */}
          {waitingLong ? (
            <span className="board-tile-status board-tile-late">
              {t('tableState_waiting_long')}
            </span>
          ) : (
            <span className="board-tile-status">{status}</span>
          )}
          <span className="board-tile-foot">
            <span
              className="board-tile-guests"
              title={
                table.guest_count != null
                  ? t('tableGuests', { count: table.guest_count })
                  : undefined
              }
            >
              <PosIcon name="user" />
              <span>{table.guest_count ?? '—'}</span>
              {table.guest_count != null ? (
                <span className="visually-hidden">
                  {' '}
                  {t('tableGuests', { count: table.guest_count })}
                </span>
              ) : null}
            </span>
            <span className="board-tile-total">
              {total ? formatMoney(total, table.currency ?? 'VND') : '—'}
            </span>
          </span>
        </>
      ) : (
        <>
          <span className="board-tile-status">{status}</span>
          <span className="board-tile-foot">
            <span>
              {table.state === 'available' || table.state === 'reserved'
                ? booking
                  ? t('boardReserved')
                  : t('boardTapToOpen')
                : null}
            </span>
          </span>
        </>
      )}
    </button>
  );
}
