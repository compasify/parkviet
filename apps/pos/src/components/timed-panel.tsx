import { formatMoney } from '@parkviet/pos-shared/money';
import type { BoardTable, BoardTimed } from '@parkviet/pos-shared/tables';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useTimedCommands, useTimedQuote } from '../hooks/use-timed';
import { conflictReason } from '../lib/request-failure';
import { moveTargets } from '../lib/tables';
import { elapsedSeconds, formatElapsed, isRunning, timedFailureKey } from '../lib/timed-clock';

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

// The elapsed time of a room's clock, counted from the server's start.
export function TimedClock({ timed, offsetMs }: { timed: BoardTimed; offsetMs: number }) {
  const now = useTick(isRunning(timed));
  return (
    <time className="timed-clock" dateTime={timed.started_at}>
      {formatElapsed(elapsedSeconds(timed, now, offsetMs))}
    </time>
  );
}

// The clock part of the room panel: start, the running time and the
// server's quote, stop, and moving the clock to a free room.
export function TimedPanel({
  table,
  tables,
  offsetMs,
  currency,
  locked,
  onStart,
  onCheckout,
  onFailure,
}: {
  table: BoardTable;
  tables: BoardTable[];
  offsetMs: number;
  currency: string;
  locked: boolean;
  onStart: (table: BoardTable) => Promise<unknown>;
  // Stops the clock on the server, then opens the order's payment.
  onCheckout?: (sessionId: string) => Promise<unknown>;
  onFailure: (failure: unknown, key: string | null) => void;
}) {
  const { t, i18n } = useTranslation();
  const timed = table.timed;
  const running = isRunning(timed);
  const quote = useTimedQuote(timed?.id ?? null, running);
  const commands = useTimedCommands();
  const [busy, setBusy] = useState(false);
  const [target, setTarget] = useState('');
  const targets = moveTargets(tables, table.id);
  const amount = quote.data?.quote?.amount ?? timed?.quote_amount ?? null;

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

  if (!timed || !running) {
    const stoppedAt = timed?.stopped_at
      ? new Date(timed.stopped_at).toLocaleTimeString(i18n.language, {
          hour: '2-digit',
          minute: '2-digit',
        })
      : null;
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
          <button
            type="button"
            className="primary-button"
            disabled={busy || locked}
            onClick={() => void act(() => onStart(table))}
          >
            {t('timedStart')}
          </button>
        ) : null}
      </div>
    );
  }

  return (
    <section className="timed-panel" aria-label={t('timedClock')}>
      <p className="timed-panel-clock">
        <span>{t('timedClock')}</span> <TimedClock timed={timed} offsetMs={offsetMs} />
      </p>
      <p>
        {t('timedQuote')}: <strong>{amount ? formatMoney(amount, currency) : '—'}</strong>
      </p>
      {timed.ending_soon ? <p className="warning">{t('timedEndingSoon')}</p> : null}
      <p className="muted">{t('timedServerTime')}</p>
      <div className="row">
        <button
          type="button"
          className="primary-button"
          disabled={busy || locked}
          onClick={() => void act(() => commands.stop(timed.id))}
        >
          {t('timedStop')}
        </button>
        {onCheckout ? (
          <button
            type="button"
            title={t('timedCheckoutHint')}
            disabled={busy || locked}
            onClick={() => void act(() => onCheckout(timed.id))}
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
    </section>
  );
}
