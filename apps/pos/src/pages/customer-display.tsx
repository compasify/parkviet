import { formatMoney } from '@parkviet/pos-shared/money';
import { type FormEvent, useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  DISPLAY_HANDOFF_READY,
  DISPLAY_HANDOFF_TOKEN,
  DisplayUnauthorized,
  exchangePairingCode,
  fetchDisplayState,
  PairingRefused,
  postDisplayAck,
} from '../hooks/use-display';
import {
  type CallBoardNumber,
  type CallBoardReady,
  createDisplayFreshness,
  type DisplayState,
} from '../lib/display-generation';
import { formatQuantity } from '../lib/print-adapter';

// The customer-facing screen. It holds no staff session: only the read-only
// display token, from the cashier window (postMessage) or exchanged for a
// short pairing code typed on a separate device, kept in this tab's session
// storage. Everything is hidden unless the last state is provably fresh
// (see display-generation) and the browser reports itself online.
const TOKEN_KEY = 'parkviet-pos:display-token';
const TICK_MS = 250;
const DEFAULT_TTL_SECONDS = 15;
const MAX_REQUEST_MS = 5000;
// The call board follows the kitchen closely: a number called out should
// appear within a couple of seconds.
const CALL_BOARD_POLL_MS = 2000;
// How long a newly ready number flashes.
const FLASH_MS = 8000;

function storedToken(): string | null {
  try {
    return window.sessionStorage.getItem(TOKEN_KEY);
  } catch {
    return null;
  }
}

function storeToken(token: string | null) {
  try {
    if (token) window.sessionStorage.setItem(TOKEN_KEY, token);
    else window.sessionStorage.removeItem(TOKEN_KEY);
  } catch {
    // Storage unavailable: the token lives only in memory for this page.
  }
}

type View = { fresh: boolean; state: DisplayState | null; showPayment: boolean };

export function CustomerDisplayPage() {
  const { t } = useTranslation();
  const [token, setToken] = useState<string | null>(() => storedToken());
  const [disconnected, setDisconnected] = useState(false);
  const [view, setView] = useState<View>({ fresh: false, state: null, showPayment: false });
  const [freshness] = useState(() => createDisplayFreshness());
  const inFlight = useRef(false);

  useEffect(() => {
    const onMessage = (event: MessageEvent) => {
      if (event.origin !== window.location.origin || event.source !== window.opener) return;
      const data = event.data as { type?: unknown; token?: unknown } | null;
      if (data?.type !== DISPLAY_HANDOFF_TOKEN || typeof data.token !== 'string' || !data.token)
        return;
      storeToken(data.token);
      setDisconnected(false);
      setToken(data.token);
    };
    window.addEventListener('message', onMessage);
    if (window.opener)
      window.opener.postMessage({ type: DISPLAY_HANDOFF_READY }, window.location.origin);
    return () => window.removeEventListener('message', onMessage);
  }, []);

  useEffect(() => {
    freshness.reset();
    setView({ fresh: false, state: null, showPayment: false });
    if (!token) return;
    let stopped = false;
    // The last window the server gave; recovery polling keeps using it after
    // the screen was hidden.
    let ttl = DEFAULT_TTL_SECONDS;
    let boardMode = false;
    const online = () => globalThis.navigator?.onLine !== false;
    const render = () => {
      if (stopped) return;
      // Strict offline: whatever the last poll said, an offline browser shows nothing.
      if (!online()) freshness.invalidate('offline');
      const snapshot = freshness.snapshot();
      setView({ fresh: snapshot.fresh, state: snapshot.state, showPayment: snapshot.showPayment });
    };
    // `force` revalidates at once after a hide, even while an older request
    // is still out; that older answer can no longer show anything.
    const refresh = async (force = false) => {
      if ((inFlight.current && !force) || stopped) return;
      inFlight.current = true;
      const ticket = freshness.beginRequest();
      // A request that hangs is abandoned well inside the window.
      const controller = new AbortController();
      const timeout = window.setTimeout(
        () => controller.abort(),
        Math.min((ttl * 1000) / 2, MAX_REQUEST_MS),
      );
      let ack: { generation: number; lease_id: string } | null = null;
      try {
        const body = await fetchDisplayState(token, controller.signal);
        if (stopped) return;
        if (freshness.accept(ticket, body) === 'applied') {
          const applied = freshness.snapshot().state;
          ttl = applied?.freshness_ttl_seconds ?? ttl;
          boardMode = applied?.state === 'call_board';
          render();
          ack = online() ? freshness.ackFor() : null;
        }
      } catch (error) {
        if (error instanceof DisplayUnauthorized && !stopped) {
          freshness.reset();
          storeToken(null);
          setDisconnected(true);
          setToken(null);
        }
        // Any other failure renews nothing; the deadline hides the screen.
      } finally {
        window.clearTimeout(timeout);
        inFlight.current = false;
        render();
      }
      // The acknowledgement does not hold up the next poll.
      if (ack && !stopped) {
        postDisplayAck(token, ack).catch(() => {
          // An unacknowledged state only keeps the cashier from the next customer.
        });
      }
    };
    const hideAndRevalidate = (reason: 'offline' | 'hidden' | 'resumed') => {
      freshness.invalidate(reason);
      render();
      if (reason === 'resumed') void refresh(true);
    };
    const onOffline = () => hideAndRevalidate('offline');
    const onOnline = () => void refresh(true);
    const onVisibility = () => {
      if (document.visibilityState === 'hidden') hideAndRevalidate('hidden');
      else hideAndRevalidate('resumed');
    };
    const onPageShow = (event: PageTransitionEvent) => {
      if (event.persisted) hideAndRevalidate('resumed');
    };
    const onResume = () => hideAndRevalidate('resumed');
    window.addEventListener('offline', onOffline);
    window.addEventListener('online', onOnline);
    document.addEventListener('visibilitychange', onVisibility);
    window.addEventListener('pageshow', onPageShow);
    document.addEventListener('resume', onResume);
    document.addEventListener('freeze', onResume);
    let lastPoll = 0;
    const timer = window.setInterval(() => {
      const hidden = freshness.tick();
      if (hidden || !online()) render();
      if (hidden === 'resumed') void refresh(true);
      // Poll a few times per window so a healthy display never goes stale.
      const interval = Math.max(
        500,
        Math.min(boardMode ? CALL_BOARD_POLL_MS : 5000, (ttl * 1000) / 3),
      );
      const now = performance.now();
      if (now - lastPoll >= interval && document.visibilityState !== 'hidden') {
        lastPoll = now;
        void refresh();
      }
    }, TICK_MS);
    void refresh();
    return () => {
      stopped = true;
      window.clearInterval(timer);
      window.removeEventListener('offline', onOffline);
      window.removeEventListener('online', onOnline);
      document.removeEventListener('visibilitychange', onVisibility);
      window.removeEventListener('pageshow', onPageShow);
      document.removeEventListener('resume', onResume);
      document.removeEventListener('freeze', onResume);
    };
  }, [token, freshness]);

  if (!token) return <PairingForm disconnected={disconnected} onToken={setToken} />;

  const state = view.fresh ? view.state : null;
  return (
    <main
      className="customer-display"
      aria-live="polite"
      data-fresh={view.fresh ? 'true' : 'false'}
    >
      {!state ? (
        <p className="customer-display-stale" data-testid="display-stale">
          {t('customerDisplayUpdating')}
        </p>
      ) : state.state === 'call_board' ? (
        <CallBoard preparing={state.preparing ?? []} ready={state.ready ?? []} />
      ) : state.state === 'idle' ? (
        <h1 className="customer-display-welcome">
          {t('customerDisplayWelcome', { branch: state.branch_name })}
        </h1>
      ) : state.state === 'completed' && state.order ? (
        <section className="customer-display-thanks">
          <h1>{t('customerDisplayThanks')}</h1>
          <p>{t('customerDisplayOrder', { number: state.order.number })}</p>
        </section>
      ) : state.order ? (
        <section className="customer-display-order" data-testid="display-order">
          <h1>{t('customerDisplayOrder', { number: state.order.number })}</h1>
          <ul className="customer-display-lines">
            {(state.order.lines ?? []).map((line, index) => (
              // Lines have no stable id on this channel; their order is fixed by the server.
              // biome-ignore lint/suspicious/noArrayIndexKey: server-ordered rows without ids
              <li key={index}>
                <span>
                  {line.name} × {formatQuantity(line.quantity)}
                  {line.unit ? ` ${line.unit}` : ''}
                  {line.options && line.options.length > 0 ? (
                    <small className="customer-display-options">{line.options.join(', ')}</small>
                  ) : null}
                </span>
                <span className="money">{formatMoney(line.amount, state.order?.currency)}</span>
              </li>
            ))}
          </ul>
          <dl className="customer-display-totals">
            <div>
              <dt>{t('customerDisplayTotal')}</dt>
              <dd className="money">{formatMoney(state.order.total, state.order.currency)}</dd>
            </div>
            <div>
              <dt>{t('customerDisplayDue')}</dt>
              <dd className="money">{formatMoney(state.order.amount_due, state.order.currency)}</dd>
            </div>
          </dl>
          {view.showPayment && state.payment?.kind === 'vietqr' ? (
            <section
              className="customer-display-payment customer-display-vietqr"
              data-testid="display-payment"
            >
              <h2>{t('customerDisplayVietqrTitle')}</h2>
              <img
                className="customer-display-qr"
                src={state.payment.qr_url}
                alt={t('vietqrImageAlt')}
                width={280}
                height={280}
              />
              <p className="money customer-display-amount">
                {formatMoney(state.payment.amount, state.payment.currency)}
              </p>
              <p>
                {state.payment.bank_name} · {state.payment.account_number}
              </p>
              <p>{state.payment.account_name}</p>
              <p>{t('customerDisplayTransferNote', { note: state.payment.transfer_note })}</p>
              <p className="muted">{t('customerDisplayVietqrHint')}</p>
            </section>
          ) : view.showPayment && state.payment?.kind === 'bank_manual' ? (
            <section className="customer-display-payment" data-testid="display-payment">
              <h2>{t('customerDisplayBankTitle')}</h2>
              <p className="money customer-display-amount">
                {formatMoney(state.payment.amount, state.payment.currency)}
              </p>
              <p>{state.payment.account_text ?? t('customerDisplayAskAccount')}</p>
              <p>{t('customerDisplayTransferNote', { note: state.payment.transfer_note })}</p>
              <p className="muted">{t('customerDisplayBankHint')}</p>
            </section>
          ) : null}
        </section>
      ) : null}
    </main>
  );
}

// A short chime for a newly ready number. Browsers may refuse sound before
// anyone touched the screen; the flash still shows.
function chime() {
  try {
    const AudioContextClass =
      window.AudioContext ??
      (window as unknown as { webkitAudioContext?: typeof AudioContext }).webkitAudioContext;
    if (!AudioContextClass) return;
    const context = new AudioContextClass();
    const tone = context.createOscillator();
    const gain = context.createGain();
    tone.frequency.value = 880;
    gain.gain.setValueAtTime(0.2, context.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, context.currentTime + 0.6);
    tone.connect(gain).connect(context.destination);
    tone.start();
    tone.stop(context.currentTime + 0.6);
    tone.onended = () => void context.close();
  } catch {
    // No sound on this device.
  }
}

// Two large columns: the numbers being made, and those ready to collect,
// with the guest's name. A number that just became ready flashes and chimes.
function CallBoard({
  preparing,
  ready,
}: {
  preparing: CallBoardNumber[];
  ready: CallBoardReady[];
}) {
  const { t } = useTranslation();
  const seen = useRef<Set<number> | null>(null);
  const [flashing, setFlashing] = useState<Record<number, number>>({});
  const readyKey = ready.map((row) => row.number).join(',');

  useEffect(() => {
    const numbers = readyKey ? readyKey.split(',').map(Number) : [];
    // The first board after loading is not news.
    if (seen.current === null) {
      seen.current = new Set(numbers);
      return;
    }
    const fresh = numbers.filter((number) => !seen.current?.has(number));
    seen.current = new Set(numbers);
    if (fresh.length === 0) return;
    chime();
    const until = Date.now() + FLASH_MS;
    setFlashing((current) => ({
      ...current,
      ...Object.fromEntries(fresh.map((number) => [number, until])),
    }));
    const timer = window.setTimeout(
      () =>
        setFlashing((current) =>
          Object.fromEntries(Object.entries(current).filter(([, end]) => end > Date.now())),
        ),
      FLASH_MS + 50,
    );
    return () => window.clearTimeout(timer);
  }, [readyKey]);

  return (
    <section className="call-board" data-testid="call-board">
      <div className="call-board-column">
        <h1>{t('callBoardPreparing')}</h1>
        <ul data-testid="call-board-preparing">
          {preparing.map((row) => (
            <li key={row.number}>{row.number}</li>
          ))}
        </ul>
      </div>
      <div className="call-board-column call-board-ready">
        <h1>{t('callBoardReady')}</h1>
        <ul data-testid="call-board-ready">
          {ready.map((row) => (
            <li key={row.number} className={flashing[row.number] ? 'call-board-new' : undefined}>
              <strong>{row.number}</strong>
              {row.guest_name ? <span>{row.guest_name}</span> : null}
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}

function PairingForm({
  disconnected,
  onToken,
}: {
  disconnected: boolean;
  onToken: (token: string) => void;
}) {
  const { t } = useTranslation();
  const [value, setValue] = useState('');
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  const submit = async (event: FormEvent) => {
    event.preventDefault();
    const code = value.trim();
    if (!code || busy) return;
    setBusy(true);
    setError('');
    try {
      const token = await exchangePairingCode(code);
      storeToken(token);
      setValue('');
      onToken(token);
    } catch (failure) {
      setError(
        t(
          failure instanceof PairingRefused && failure.limited
            ? 'customerDisplayPairLimited'
            : 'customerDisplayPairInvalid',
        ),
      );
    } finally {
      setBusy(false);
    }
  };
  return (
    <main className="customer-display customer-display-pairing">
      <h1>{t('customerDisplayPairTitle')}</h1>
      {disconnected ? (
        <p className="error" role="alert">
          {t('customerDisplayDisconnected')}
        </p>
      ) : null}
      <p>{t('customerDisplayPairHint')}</p>
      <form onSubmit={(event) => void submit(event)}>
        <label>
          {t('customerDisplayPairCode')}
          <input
            value={value}
            autoComplete="off"
            autoCapitalize="characters"
            maxLength={12}
            onChange={(event) => setValue(event.target.value)}
          />
        </label>
        <button type="submit" disabled={busy}>
          {t('customerDisplayPairSubmit')}
        </button>
        {error ? (
          <p className="error" role="alert">
            {error}
          </p>
        ) : null}
      </form>
    </main>
  );
}
