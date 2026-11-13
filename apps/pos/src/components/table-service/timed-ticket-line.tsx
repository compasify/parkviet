import { formatMoney } from '@parkviet/pos-shared/money';
import type { BoardTable, BoardTimed } from '@parkviet/pos-shared/tables';
import { useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useResourceBoard } from '../../hooks/use-resource-board';
import { useTimedCommands, useTimedQuote } from '../../hooks/use-timed';
import { type ApprovalAsk, askFromFailure } from '../../lib/approval-requests';
import type { PosLineItem, PosWorkspace } from '../../lib/pos-context';
import { conflictReason, describeFailure } from '../../lib/request-failure';
import { moveTargets } from '../../lib/tables';
import { canRunClock, clockOffset, TIMED_MODULE, timedFailureKey } from '../../lib/timed-clock';
import { workspaceIsSettled } from '../../lib/workspace-content';
import { PosIcon } from '../pos-icon';
import { RemoteApprovalButton } from '../remote-approval-button';
import type { SellingWorkspace } from '../workspace-tabs';
import { useRoomClock } from './room-tile';
import { runningClockOf } from './stop-and-pay-dialog';

// How a band of play time was priced, when not at the plan's rate.
const BAND_LABELS = {
  package: 'timedBandPackage',
  card: 'timedBandCard',
  bonus: 'timedBandBonus',
} as const;

export type OrderRoom = {
  // The order's room on the board and its clock, when it bills this order.
  table: BoardTable | null;
  timed: BoardTimed | null;
  tables: BoardTable[];
  offsetMs: number;
  readAt: string | null;
  // The order's time line: the counting one, else the last one stopped.
  line: PosLineItem | null;
  // The clock still counts (paused included): the order cannot be paid yet.
  running: boolean;
  // The server's quote of the time now, or as billed once stopped.
  amount: string | null;
};

function timedLineOf(workspace: PosWorkspace | null): PosLineItem | null {
  const lines = (workspace?.line_items ?? []).filter(
    (line) => line.kind === 'timed' && line.timed_session,
  );
  return lines.find((line) => line.timed_session?.status !== 'stopped') ?? lines.at(-1) ?? null;
}

// The clock of the order's room, read from the board (the clock and its
// server time) and from the order (its time line, segments and bands). The
// quote of a counting clock is polled only while the order is `shown`.
export function useOrderRoom(
  selling: SellingWorkspace,
  active: PosWorkspace | null,
  shown: boolean,
): OrderRoom {
  const { data, selection, activeTable } = selling;
  const timedOn = data?.modules?.[TIMED_MODULE] === true;
  const board = useResourceBoard(selection.branchId, timedOn && activeTable.table !== null);
  const tables = board.data?.resources ?? [];
  const table = tables.find((row) => row.id === activeTable.table?.id) ?? null;
  const timed =
    table?.timed && active && (table.timed.workspace_id ?? active.id) === active.id
      ? table.timed
      : null;
  const line = timedLineOf(active);
  const session = line?.timed_session ?? null;
  const counting = runningClockOf(active, { timed });
  const running = counting !== null;
  const quote = useTimedQuote(
    counting?.sessionId ?? session?.id ?? timed?.id ?? null,
    running && shown,
  );
  const amount =
    quote.data?.quote?.amount ??
    timed?.quote_amount ??
    session?.quote?.amount ??
    session?.amount ??
    null;
  return {
    table,
    timed,
    tables,
    offsetMs: clockOffset(board.data?.server_now, board.dataUpdatedAt),
    readAt: board.data?.server_now ?? null,
    line,
    running,
    amount,
  };
}

// The time line pinned on top of a room's ticket: the clock (largest), what
// the time costs so far, how it is priced, then one tap to pause or resume,
// moving the clock to a free room (the stretch played keeps its price). It
// lists every stretch played, each one correctable with a manager's approval
// until the order is paid, the stopped ones too; once stopped it lists the
// bands the time was billed at.
export function TimedTicketLine({
  selling,
  active,
  room,
  clockTime,
}: {
  selling: SellingWorkspace;
  active: PosWorkspace;
  room: OrderRoom;
  clockTime: (value: string) => string;
}) {
  const { t } = useTranslation();
  const { data, locked, selectionComplete, setEditingSegment, selection } = selling;
  const commands = useTimedCommands();
  const [busy, setBusy] = useState(false);
  // A command in flight: a second tap before the first re-renders must not
  // send it twice.
  const sending = useRef(false);
  const [error, setError] = useState('');
  const [moving, setMoving] = useState(false);
  const [target, setTarget] = useState('');
  const [approvalId, setApprovalId] = useState('');
  const [ask, setAsk] = useState<ApprovalAsk | null>(null);
  const session = room.line?.timed_session ?? null;
  // The board's room carries the clock this order bills.
  const clockRoom = room.timed ? room.table : null;
  const status = session?.status ?? room.timed?.status ?? 'stopped';
  const sessionId = session?.id ?? room.timed?.id ?? null;
  // Corrections stay open after the stop, until the order is paid, as on the
  // counter; they wait for the selection and an unlocked till like any edit.
  const canCorrect = canRunClock(data) && !workspaceIsSettled(active);
  const canOperate = canCorrect && !locked && selectionComplete;
  const currency = session?.currency ?? room.table?.currency ?? 'VND';
  const bands = session?.quote?.lines ?? [];
  const rate = [...bands].reverse().find((band) => Number(band.price_per_hour ?? 0) > 0);
  const plays = (session?.segments ?? []).filter((segment) => segment.kind === 'play');
  const targets = room.table ? moveTargets(room.tables, room.table.id) : [];

  async function act(action: (approval?: string) => Promise<unknown>, granted?: string) {
    if (sending.current) return;
    sending.current = true;
    setBusy(true);
    setError('');
    try {
      await action(granted ?? (approvalId.trim() || undefined));
      setAsk(null);
      setApprovalId('');
    } catch (failure) {
      const asked = askFromFailure(failure);
      if (asked) setAsk(asked);
      const key = timedFailureKey(conflictReason(failure));
      setError(key ? t(key) : describeFailure(failure, t));
    } finally {
      sending.current = false;
      setBusy(false);
    }
  }

  if (!session && !room.timed) return null;
  const paused = status === 'paused';
  const stopped = status === 'stopped';
  const heading = [
    t('timedClock'),
    session?.package?.name ?? null,
    rate?.price_per_hour
      ? t('roomRate', { price: formatMoney(rate.price_per_hour, currency) })
      : null,
    session?.started_at ? t('roomSince', { time: clockTime(session.started_at) }) : null,
  ]
    .filter(Boolean)
    .join(' · ');

  return (
    <section
      className={`timed-ticket-line${paused ? ' timed-ticket-line-paused' : ''}`}
      aria-label={t('timedClock')}
    >
      <div className="timed-ticket-line-top">
        <p className="timed-ticket-line-heading">
          <PosIcon name="clock" /> {heading}
        </p>
        <p className="timed-ticket-line-amount">
          <small>{stopped ? t('timedBilled') : t('roomEstimate')}</small>
          <strong>{room.amount ? formatMoney(room.amount, currency) : '—'}</strong>
        </p>
      </div>
      {clockRoom ? (
        <RoomClockFace table={clockRoom} room={room} />
      ) : (
        <p className="timed-ticket-line-clock">
          {t('timedPlayed', {
            time: t('timedMinutes', {
              count: session?.quote?.played_minutes ?? session?.played_minutes ?? 0,
            }),
          })}
        </p>
      )}
      {stopped ? (
        <ul className="timed-ticket-line-bands">
          {session?.stopped_at ? (
            <li>{t('timedStopped', { time: clockTime(session.stopped_at) })}</li>
          ) : null}
          {bands.map((band) => {
            // The package band carries the package's price once, by its name.
            const name = band.label ?? (band.kind === 'package' ? session?.package?.name : null);
            return (
              <li
                key={`${band.kind ?? 'rate'}:${band.starts_at}:${band.ends_at}`}
                className={`timed-band timed-band-${band.kind ?? 'rate'}`}
              >
                {band.kind && band.kind !== 'rate' ? `${t(BAND_LABELS[band.kind])} · ` : ''}
                {name ? `${name} · ` : ''}
                {t('timedLine', {
                  minutes: band.minutes,
                  from: clockTime(band.starts_at),
                  to: clockTime(band.ends_at),
                })}
                {band.kind === 'bonus' ? '' : ` · ${formatMoney(band.amount, currency)}`}
              </li>
            );
          })}
        </ul>
      ) : null}
      {plays.length > 0 ? (
        <ul className="timed-ticket-line-segments">
          {plays.map((segment) => (
            <li key={segment.id}>
              {t('timedSegment', {
                room: segment.resource_name ?? '',
                from: clockTime(segment.started_at),
                to: segment.ended_at ? clockTime(segment.ended_at) : t('timedSegmentRunning'),
              })}
              {segment.edited ? ` · ${t('timedSegmentEdited')}` : ''}
              {canCorrect && session ? (
                <button
                  type="button"
                  className="link-button"
                  aria-label={`${t('timedEditSegment')} ${segment.resource_name ?? ''} ${clockTime(segment.started_at)}`}
                  disabled={busy || locked || !selectionComplete}
                  onClick={() => setEditingSegment({ sessionId: session.id, segment })}
                >
                  <PosIcon name="edit" /> {t('roomEditNeedsApproval')}
                </button>
              ) : null}
            </li>
          ))}
        </ul>
      ) : null}
      {!stopped && sessionId ? (
        <div className="timed-ticket-line-actions">
          {paused ? (
            <button
              type="button"
              disabled={busy || !canOperate}
              onClick={() => void act((approval) => commands.resume(sessionId, approval))}
            >
              <PosIcon name="play" /> {t('roomAction_resume')}
            </button>
          ) : (
            <button
              type="button"
              disabled={busy || !canOperate}
              onClick={() => void act(() => commands.pause(sessionId))}
            >
              <PosIcon name="pause" /> {t('roomAction_pause')}
            </button>
          )}
          {room.table ? (
            <button
              type="button"
              aria-expanded={moving}
              disabled={busy || !canOperate}
              onClick={() => setMoving((value) => !value)}
            >
              {t('roomMoveKeepsPrice')}
            </button>
          ) : null}
        </div>
      ) : null}
      {moving && sessionId ? (
        targets.length > 0 ? (
          <div className="row timed-ticket-line-move">
            <label>
              {t('timedMoveTo')}
              <select value={target} onChange={(event) => setTarget(event.target.value)}>
                <option value="" />
                {targets.map((row) => (
                  <option key={row.id} value={row.id}>
                    {row.name}
                  </option>
                ))}
              </select>
            </label>
            <button
              type="button"
              disabled={busy || !canOperate || !target}
              onClick={() =>
                void act(async () => {
                  await commands.move(sessionId, target);
                  setTarget('');
                  setMoving(false);
                })
              }
            >
              {t('timedMove')}
            </button>
          </div>
        ) : (
          <p className="muted">{t('timedMoveNone')}</p>
        )
      ) : null}
      {ask ? (
        <div className="timed-ticket-line-approval">
          <label>
            {t('timedEditApproval')}
            <input
              value={approvalId}
              autoComplete="off"
              onChange={(event) => setApprovalId(event.target.value)}
            />
          </label>
          {selection.branchId && sessionId ? (
            <RemoteApprovalButton
              branchId={selection.branchId}
              subject={{ workspace_id: active.id }}
              ask={ask}
              disabled={busy || !canOperate}
              onGranted={(id) => {
                setApprovalId(id);
                void act((approval) => commands.resume(sessionId, approval), id);
              }}
            />
          ) : null}
        </div>
      ) : null}
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
    </section>
  );
}

// The clock itself, ticking on the board's shared timer.
function RoomClockFace({ table, room }: { table: BoardTable; room: OrderRoom }) {
  const { t } = useTranslation();
  const { tone, text } = useRoomClock(table, room.offsetMs, room.readAt);
  return (
    <p className={`timed-ticket-line-clock room-clock-${tone}`}>
      {text ? (
        <time className="timed-clock" dateTime={table.timed?.started_at}>
          {text}
        </time>
      ) : null}
      <span className="timed-ticket-line-tone">{t(`roomTone_${tone}`)}</span>
    </p>
  );
}
