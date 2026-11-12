import { formatMoney } from '@parkviet/pos-shared/money';
import {
  type BoardTable,
  type BoardTimed,
  clockPlayedSeconds,
  clockSecondsLeft,
} from '@parkviet/pos-shared/tables';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  useAttendants,
  useRatePackages,
  useTimedCommands,
  useTimedQuote,
} from '../hooks/use-timed';
import { conflictReason } from '../lib/request-failure';
import { moveTargets } from '../lib/tables';
import { formatElapsed, isRunning, timedFailureKey } from '../lib/timed-clock';

// What a clock may start with: a prepaid package of the room's plan, and a
// minutes card read at the counter that pays the time when it stops.
export type ClockStartOptions = { packageCode?: string; cardToken?: string };

// Ticks every second on this device; the time shown is still the server's.
function useTick(active: boolean) {
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    if (!active) return;
    const timer = window.setInterval(() => setNow(Date.now()), 1000);
    return () => window.clearInterval(timer);
  }, [active]);
  return now;
}

// The time a room's clock has played on the server's clock, pauses not
// counted: the board's count at `readAt`, then counting on while it runs.
export function TimedClock({
  timed,
  offsetMs,
  readAt = null,
}: {
  timed: BoardTimed;
  offsetMs: number;
  readAt?: string | null;
}) {
  const now = useTick(timed.status === 'running');
  return (
    <time className="timed-clock" dateTime={timed.started_at}>
      {formatElapsed(clockPlayedSeconds(timed, readAt, now + offsetMs))}
    </time>
  );
}

// The minutes left until a running clock's planned end (its package's
// end), counted down on the server's clock.
function TimedCountdown({ timed, offsetMs }: { timed: BoardTimed; offsetMs: number }) {
  const { t } = useTranslation();
  const now = useTick(timed.status === 'running');
  const left = clockSecondsLeft(timed, now + offsetMs);
  if (left === null) return null;
  return left > 0 ? (
    <p className={left <= 600 ? 'warning' : 'muted'}>
      {t(timed.prepaid_minutes ? 'timedPackageLeft' : 'timedPlannedLeft', {
        time: formatElapsed(left),
      })}
    </p>
  ) : (
    <p className="error">{t(timed.prepaid_minutes ? 'timedPackageEnded' : 'timedPlannedEnded')}</p>
  );
}

// Who serves the room: the open turns of the attendants book, ending one,
// and writing in another member of the branch.
function TimedAttendants({
  branchId,
  table,
  locked,
  act,
}: {
  branchId: string | null;
  table: BoardTable;
  locked: boolean;
  act: (action: () => Promise<unknown>) => Promise<void>;
}) {
  const { t } = useTranslation();
  const attendants = useAttendants(branchId, table.id, true);
  const [staffId, setStaffId] = useState('');
  const turns = attendants.turns.data ?? [];
  const serving = new Set(turns.map((turn) => turn.staffId));
  const choices = (attendants.candidates.data ?? []).filter((row) => !serving.has(row.id));
  return (
    <div className="timed-panel-attendants-block">
      <p className="muted">{t('timedAttendants')}</p>
      {turns.length > 0 ? (
        <ul className="timed-panel-attendants">
          {turns.map((turn) => (
            <li key={turn.id}>
              <span>{turn.staffName}</span>
              <button
                type="button"
                disabled={locked}
                onClick={() => void act(() => attendants.end(turn.id))}
              >
                {t('timedAttendantEnd')}
              </button>
            </li>
          ))}
        </ul>
      ) : null}
      {choices.length > 0 ? (
        <div className="row">
          <label>
            {t('timedAttendantPick')}
            <select value={staffId} onChange={(event) => setStaffId(event.target.value)}>
              <option value="" />
              {choices.map((row) => (
                <option key={row.id} value={row.id}>
                  {row.name}
                </option>
              ))}
            </select>
          </label>
          <button
            type="button"
            disabled={locked || !staffId}
            onClick={() =>
              void act(async () => {
                await attendants.assign(staffId);
                setStaffId('');
              })
            }
          >
            {t('timedAttendantAssign')}
          </button>
        </div>
      ) : null}
    </div>
  );
}

// The clock part of the room panel: start (with a package or a minutes
// card), the time played and the server's quote, pause and resume, stop,
// moving the clock to a free room and who serves the room.
export function TimedPanel({
  branchId = null,
  table,
  tables,
  offsetMs,
  readAt = null,
  outsideHours = false,
  currency,
  locked,
  onStart,
  onCheckout,
  onFailure,
}: {
  branchId?: string | null;
  table: BoardTable;
  tables: BoardTable[];
  offsetMs: number;
  // The server time the board was read at.
  readAt?: string | null;
  // A clock started now starts outside the branch's operating hours.
  outsideHours?: boolean;
  currency: string;
  locked: boolean;
  onStart: (table: BoardTable, options: ClockStartOptions) => Promise<unknown>;
  // Stops the clock on the server, then opens the order's payment.
  onCheckout?: (sessionId: string, approvalId?: string) => Promise<unknown>;
  onFailure: (failure: unknown, key: string | null) => void;
}) {
  const { t, i18n } = useTranslation();
  const timed = table.timed;
  const running = isRunning(timed);
  const quote = useTimedQuote(timed?.id ?? null, running);
  const commands = useTimedCommands();
  const packages = useRatePackages(branchId, !running);
  const [busy, setBusy] = useState(false);
  const [target, setTarget] = useState('');
  const [packageCode, setPackageCode] = useState('');
  const [cardToken, setCardToken] = useState('');
  const [approvalId, setApprovalId] = useState('');
  const [confirmHours, setConfirmHours] = useState(false);
  const targets = moveTargets(tables, table.id);
  const amount = quote.data?.quote?.amount ?? timed?.quote_amount ?? null;
  const approval = approvalId.trim() || undefined;

  async function act(action: () => Promise<unknown>) {
    if (busy) return;
    setBusy(true);
    try {
      await action();
    } catch (failure) {
      onFailure(failure, timedFailureKey(conflictReason(failure)));
    } finally {
      setBusy(false);
    }
  }

  function start() {
    // Outside the branch's hours the server only warns; the cashier says yes first.
    if (outsideHours && !confirmHours) {
      setConfirmHours(true);
      return;
    }
    setConfirmHours(false);
    void act(async () => {
      await onStart(table, {
        packageCode: packageCode || undefined,
        cardToken: cardToken.trim() || undefined,
      });
      setPackageCode('');
      setCardToken('');
    });
  }

  if (!timed || !running) {
    const stoppedAt = timed?.stopped_at
      ? new Date(timed.stopped_at).toLocaleTimeString(i18n.language, {
          hour: '2-digit',
          minute: '2-digit',
        })
      : null;
    const offered = packages.data ?? [];
    return (
      <div className="timed-panel">
        {timed && stoppedAt ? (
          <p className="muted">
            {t('timedStopped', { time: stoppedAt })} · {t('timedBilled')}{' '}
            <strong>{formatMoney(timed.quote_amount, currency)}</strong>
            <br />
            {t('timedStoppedHint')}
          </p>
        ) : null}
        {table.state !== 'out_of_service' && table.state !== 'cleaning' ? (
          <>
            <div className="timed-panel-options">
              {offered.length > 0 ? (
                <label>
                  {t('timedPackage')}
                  <select
                    value={packageCode}
                    onChange={(event) => setPackageCode(event.target.value)}
                  >
                    <option value="">{t('timedPackageNone')}</option>
                    {offered.map((row) => (
                      <option key={`${row.typeCode}:${row.code}`} value={row.code}>
                        {t('timedPackageOption', {
                          name: row.name,
                          plan: row.planName,
                          minutes: row.minutes,
                          price: formatMoney(row.price, currency),
                        })}
                      </option>
                    ))}
                  </select>
                </label>
              ) : null}
              <label>
                {t('timedMinutesCard')}
                <input
                  value={cardToken}
                  autoComplete="off"
                  placeholder={t('timedMinutesCardHint')}
                  onChange={(event) => setCardToken(event.target.value)}
                />
              </label>
            </div>
            {confirmHours ? (
              <p className="warning" role="alert">
                {t('timedOutsideHours')}
              </p>
            ) : null}
            <div className="row">
              <button
                type="button"
                className="primary-button"
                disabled={busy || locked}
                onClick={start}
              >
                {confirmHours ? t('timedStartAnyway') : t('timedStart')}
              </button>
              {confirmHours ? (
                <button type="button" onClick={() => setConfirmHours(false)}>
                  {t('timedEditCancel')}
                </button>
              ) : null}
            </div>
          </>
        ) : null}
      </div>
    );
  }

  const paused = timed.status === 'paused';
  return (
    <section className="timed-panel" aria-label={t('timedClock')}>
      <p className="timed-panel-clock">
        <span>{paused ? t('timedPaused') : t('timedClock')}</span>{' '}
        <TimedClock timed={timed} offsetMs={offsetMs} readAt={readAt} />
      </p>
      <p>
        {t('timedQuote')}: <strong>{amount ? formatMoney(amount, currency) : '—'}</strong>
      </p>
      <TimedCountdown timed={timed} offsetMs={offsetMs} />
      {timed.ending_soon ? <p className="warning">{t('timedEndingSoon')}</p> : null}
      {timed.pause_too_long ? <p className="error">{t('timedPauseTooLong')}</p> : null}
      <p className="muted">{t('timedServerTime')}</p>
      {timed.pause_too_long ? (
        <div className="timed-panel-approval">
          <label>
            {t('timedEditApproval')}
            <input
              value={approvalId}
              autoComplete="off"
              onChange={(event) => setApprovalId(event.target.value)}
            />
          </label>
        </div>
      ) : null}
      <div className="row">
        {paused ? (
          <button
            type="button"
            className="primary-button"
            disabled={busy || locked}
            onClick={() =>
              void act(async () => {
                await commands.resume(timed.id, approval);
                setApprovalId('');
              })
            }
          >
            {t('timedResume')}
          </button>
        ) : (
          <button
            type="button"
            disabled={busy || locked}
            onClick={() => void act(() => commands.pause(timed.id))}
          >
            {t('timedPause')}
          </button>
        )}
        <button
          type="button"
          className={paused ? undefined : 'primary-button'}
          disabled={busy || locked}
          onClick={() => void act(() => commands.stop(timed.id, approval))}
        >
          {t('timedStop')}
        </button>
        {onCheckout ? (
          <button
            type="button"
            title={t('timedCheckoutHint')}
            disabled={busy || locked}
            onClick={() => void act(() => onCheckout(timed.id, approval))}
          >
            {t('timedCheckout')}
          </button>
        ) : null}
      </div>
      {targets.length > 0 ? (
        <div className="row timed-panel-move">
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
            disabled={busy || locked || !target}
            onClick={() =>
              void act(async () => {
                await commands.move(timed.id, target);
                setTarget('');
              })
            }
          >
            {t('timedMove')}
          </button>
        </div>
      ) : (
        <p className="muted">{t('timedMoveNone')}</p>
      )}
      <div className="row">
        <label>
          {t('timedMinutesCard')}
          <input
            value={cardToken}
            autoComplete="off"
            placeholder={t('timedMinutesCardHint')}
            onChange={(event) => setCardToken(event.target.value)}
          />
        </label>
        <button
          type="button"
          disabled={busy || locked || !cardToken.trim()}
          onClick={() =>
            void act(async () => {
              await commands.minutesCard(timed.id, cardToken.trim());
              setCardToken('');
            })
          }
        >
          {t('timedMinutesCardApply')}
        </button>
      </div>
      <TimedAttendants branchId={branchId} table={table} locked={locked || busy} act={act} />
    </section>
  );
}
