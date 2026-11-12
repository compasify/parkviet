import { useCallback, useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { toggleLanguage } from './i18n';
import { GuestApiError, guestApi, SESSION_ENDED } from './lib/api';
import { addLine, type CartLine, itemCount, orderBody, setQuantity } from './lib/cart';
import { errorKey, keepsKey } from './lib/errors';
import { forgetCode, readCode, readToken, saveToken, takeCodeFromAddress } from './lib/session';
import type { GuestMenu, GuestRequest, GuestSession, GuestTable, MenuItem } from './lib/types';
import { CartScreen } from './screens/cart-screen';
import { ItemScreen } from './screens/item-screen';
import { MenuScreen } from './screens/menu-screen';
import { TableScreen } from './screens/table-screen';

// The guest polls instead of joining the branch stream.
export const POLL_MS = 5_000;

type Tab = 'menu' | 'cart' | 'table';
type Phase =
  | { kind: 'loading' }
  | { kind: 'no_code' }
  | { kind: 'invalid' }
  | { kind: 'ended' }
  | { kind: 'failed'; message: string }
  | { kind: 'ready'; session: GuestSession };

// Opens a session from the code on the table, or resumes this tab's one.
async function startSession(code: string | null): Promise<GuestSession> {
  if (code) {
    const opened = await guestApi.openSession(code);
    saveToken(opened.token);
    const { token: _token, ...session } = opened;
    return session;
  }
  if (!readToken()) throw new GuestApiError(401, 'session_invalid', 'no session');
  return guestApi.session();
}

export function App() {
  const { t } = useTranslation();
  const [phase, setPhase] = useState<Phase>({ kind: 'loading' });
  const [menu, setMenu] = useState<GuestMenu | null>(null);
  const [table, setTable] = useState<GuestTable | null>(null);
  const [tab, setTab] = useState<Tab>('menu');
  const [item, setItem] = useState<MenuItem | null>(null);
  const [cart, setCart] = useState<CartLine[]>([]);
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null);
  // One key per cart: a retry after a lost answer replays the same order.
  const orderKey = useRef<string | null>(null);
  // Starts once per page load, also under StrictMode's second effect run.
  const started = useRef(false);
  // This tab held a session, so an ended one reads "scan again".
  const hadSession = useRef(false);

  const begin = useCallback(
    async (code: string | null) => {
      try {
        const session = await startSession(code);
        // An ordering session ends with the table's order; the code is kept
        // only to try again at a table that is not open yet.
        if (session.status === 'open') forgetCode();
        hadSession.current = true;
        setPhase({ kind: 'ready', session });
        setMenu(await guestApi.menu());
      } catch (error) {
        if (error instanceof GuestApiError && error.code === 'table_code_invalid') {
          forgetCode();
          setPhase({ kind: 'invalid' });
        } else if (error instanceof GuestApiError && SESSION_ENDED.includes(error.code)) {
          // A menu-only session tries the table's code again; one that
          // ordered asks for a new scan.
          saveToken(null);
          const saved = readCode();
          if (saved && !code) return begin(saved);
          setPhase(code || hadSession.current ? { kind: 'ended' } : { kind: 'no_code' });
        } else {
          setPhase({ kind: 'failed', message: t(errorKey(error)) });
        }
      }
    },
    [t],
  );

  useEffect(() => {
    if (started.current) return;
    started.current = true;
    hadSession.current = Boolean(readToken());
    void begin(takeCodeFromAddress(window.location, window.history));
  }, [begin]);

  const session = phase.kind === 'ready' ? phase.session : null;

  // The table and this phone's orders, every few seconds while visible.
  useEffect(() => {
    if (!session) return;
    let stopped = false;
    const read = async () => {
      if (document.visibilityState === 'hidden') return;
      try {
        const next = await guestApi.table();
        if (!stopped) setTable(next);
      } catch (error) {
        if (!stopped && error instanceof GuestApiError && SESSION_ENDED.includes(error.code))
          void begin(null);
      }
    };
    void read();
    const timer = setInterval(read, POLL_MS);
    return () => {
      stopped = true;
      clearInterval(timer);
    };
  }, [session, begin]);

  const changeCart = (next: CartLine[]) => {
    orderKey.current = null;
    setCart(next);
  };

  const send = async () => {
    if (busy || cart.length === 0) return;
    setBusy(true);
    setNotice(null);
    orderKey.current ??= crypto.randomUUID();
    try {
      await guestApi.submitOrder(orderBody(cart), orderKey.current);
      orderKey.current = null;
      setCart([]);
      setNotice({ text: t('sent'), failed: false });
      setTab('table');
      setTable(await guestApi.table());
    } catch (error) {
      if (!keepsKey(error)) orderKey.current = null;
      if (error instanceof GuestApiError && SESSION_ENDED.includes(error.code)) void begin(null);
      else setNotice({ text: t(errorKey(error)), failed: true });
      if (error instanceof GuestApiError && error.code === 'item_sold_out')
        setMenu(await guestApi.menu().catch(() => menu));
    } finally {
      setBusy(false);
    }
  };

  const request = async (kind: GuestRequest['kind']) => {
    setBusy(true);
    setNotice(null);
    try {
      await guestApi.request(kind);
      setTable(await guestApi.table());
    } catch (error) {
      setNotice({ text: t(errorKey(error)), failed: true });
    } finally {
      setBusy(false);
    }
  };

  const header = (
    <header className="bar">
      <h1>
        {session
          ? t('tableTitle', { name: session.table.name, branch: session.branch.name })
          : t('title')}
      </h1>
      <button type="button" className="link" onClick={toggleLanguage}>
        {t('language')}
      </button>
    </header>
  );

  if (phase.kind !== 'ready' || !session) {
    const text =
      phase.kind === 'loading'
        ? t('loading')
        : phase.kind === 'no_code'
          ? t('noCode')
          : phase.kind === 'invalid'
            ? t('codeInvalid')
            : phase.kind === 'ended'
              ? t('sessionEnded')
              : phase.kind === 'failed'
                ? phase.message
                : '';
    return (
      <div className="page">
        {header}
        <main>
          <p role={phase.kind === 'loading' ? 'status' : 'alert'} data-testid="phase">
            {text}
          </p>
          {phase.kind === 'failed' ? (
            <button type="button" onClick={() => void begin(readCode())}>
              {t('retry')}
            </button>
          ) : null}
        </main>
      </div>
    );
  }

  const ordering = session.status === 'open';
  const count = itemCount(cart);

  return (
    <div className="page">
      {header}
      {ordering ? (
        <p className="muted banner">
          {t(session.approval === 'direct_to_kitchen' ? 'approvalDirect' : 'approvalStaff')}
        </p>
      ) : (
        <div className="banner warning" role="status" data-testid="table-closed">
          <p>{t('tableClosed')}</p>
          <button type="button" disabled={busy} onClick={() => void begin(readCode())}>
            {t('tableClosedRetry')}
          </button>
        </div>
      )}
      {notice ? (
        <p className={notice.failed ? 'error' : 'notice'} role={notice.failed ? 'alert' : 'status'}>
          {notice.text}
        </p>
      ) : null}
      <main>
        {!menu ? (
          <p role="status">{t('loading')}</p>
        ) : item ? (
          <ItemScreen
            menu={menu}
            item={item}
            onBack={() => setItem(null)}
            onAdd={(picked) => {
              changeCart(addLine(cart, picked));
              setItem(null);
            }}
          />
        ) : tab === 'menu' ? (
          <MenuScreen menu={menu} onPick={setItem} />
        ) : tab === 'cart' ? (
          <CartScreen
            cart={cart}
            currency={menu.currency}
            canSend={ordering}
            sending={busy}
            onQuantity={(key, quantity) => changeCart(setQuantity(cart, key, quantity))}
            onSend={() => void send()}
          />
        ) : (
          <TableScreen session={session} table={table} busy={busy} onRequest={request} />
        )}
      </main>
      <nav className="tabs" aria-label={t('title')}>
        {(['menu', 'cart', 'table'] as const).map((name) => (
          <button
            key={name}
            type="button"
            aria-current={tab === name && !item ? 'page' : undefined}
            data-testid={`tab-${name}`}
            onClick={() => {
              setItem(null);
              setTab(name);
            }}
          >
            {t(name === 'menu' ? 'tabMenu' : name === 'cart' ? 'tabCart' : 'tabTable')}
            {name === 'cart' && count > 0 ? <span className="count"> ({count})</span> : null}
          </button>
        ))}
      </nav>
    </div>
  );
}
