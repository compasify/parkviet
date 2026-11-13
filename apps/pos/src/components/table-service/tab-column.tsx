import { formatMoney } from '@parkviet/pos-shared/money';
import { pendingKitchenUnits } from '@parkviet/pos-shared/ticket-groups';
import { type FormEvent, useEffect, useId, useMemo, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useResourceBoard } from '../../hooks/use-resource-board';
import { type OpenTab, useOpenTabs } from '../../hooks/use-tabs';
import { posFailureKey } from '../../lib/request-failure';
import { searchTabs, tabColumnRows } from '../../lib/tab-search';
import { canServeTables } from '../../lib/tables';
import { PosIcon } from '../pos-icon';
import { tabOpenFailureKey, takenTabId } from '../tab-list';
import type { SellingWorkspace } from '../workspace-tabs';

const TAB_NAME_MAX = 60;
// The pause in typing after which the server is asked for matching tabs.
const SEARCH_DEBOUNCE_MS = 250;
// The column while it is the narrow screen's open drawer: a modal dialog
// that can hold the focus itself.
const DRAWER_DIALOG = { role: 'dialog', 'aria-modal': true, tabIndex: -1 } as const;
const FOCUSABLE =
  'button:not(:disabled), input:not(:disabled), [href], [tabindex]:not([tabindex="-1"])';

// A finger on a touch screen: focusing a field there pops the keyboard over
// the menu, so the search takes the focus only from a mouse or a keyboard.
function coarsePointer(): boolean {
  return typeof window.matchMedia === 'function' && window.matchMedia('(pointer: coarse)').matches;
}

function useDebounced(value: string, delay: number): string {
  const [settled, setSettled] = useState(value);
  useEffect(() => {
    const timer = window.setTimeout(() => setSettled(value), delay);
    return () => window.clearTimeout(timer);
  }, [value, delay]);
  return settled;
}

// A bar's open orders beside the menu: the named tabs and the orders open at
// the tables, newest first. The search keeps the focus (mouse and keyboard),
// so a bartender types a name (accents optional) and picks the row, which
// shows on the ticket at once; "Mở tab" opens a tab with only the guest's
// name, and the floor plan is one tap away. Each row says where, since when,
// what is owed, how much the kitchen has not heard about and, in green and in
// words, that the table asked for the bill. Narrow screens fold the column
// into a modal drawer behind a button.
export function TabColumn({
  selling,
  onSelect,
  onBoard,
}: {
  selling: SellingWorkspace;
  // Shows the tab or the table order on the ticket.
  onSelect: (workspaceId: string) => void;
  // The floor plan of the tables.
  onBoard: () => void;
}) {
  const { t, i18n } = useTranslation();
  const { data, selection, selectionComplete, storeId, locked, postpay, active, kitchenOn } =
    selling;
  const [query, setQuery] = useState('');
  // The name form, open when "Mở tab" is tapped with nothing typed.
  const [naming, setNaming] = useState(false);
  const [name, setName] = useState('');
  const [busy, setBusy] = useState(false);
  // A tab being opened: a second tap before the first re-renders opens nothing.
  const opening = useRef(false);
  const [message, setMessage] = useState<string | null>(null);
  const [drawer, setDrawer] = useState(false);
  const search = useRef<HTMLInputElement>(null);
  const nameInput = useRef<HTMLInputElement>(null);
  const toggle = useRef<HTMLButtonElement>(null);
  const column = useRef<HTMLElement>(null);
  const columnId = useId();
  const branchId = selection.branchId;
  const enabled = Boolean(branchId);
  const board = useResourceBoard(branchId, enabled);
  const recent = useOpenTabs(branchId, storeId, '', enabled);
  // Past the newest page the server finds the rest; its match ignores case
  // but not accents, so the newest page is matched here as well.
  const wanted = useDebounced(query.trim(), SEARCH_DEBOUNCE_MS);
  const found = useOpenTabs(branchId, storeId, wanted, enabled && wanted !== '');
  const recentTabs = recent.data?.tabs;
  const foundTabs = wanted ? found.data?.tabs : undefined;
  const all = useMemo(() => {
    const tabs: OpenTab[] = [...(recentTabs ?? []), ...(foundTabs ?? [])];
    return tabColumnRows(tabs, board.data);
  }, [recentTabs, foundTabs, board.data]);
  const rows = searchTabs(all, query);
  const tableOrders = all.filter((row) => row.kind === 'table').length;
  const openTabs = recent.data?.total ?? 0;
  const unseenTabs = openTabs - (recentTabs?.length ?? 0);
  const currency = data?.store.currency ?? 'VND';
  const branch = data?.branches.find((row) => row.id === branchId);
  const timeZone = branch?.timezone ?? data?.store.timezone ?? 'Asia/Ho_Chi_Minh';
  const canOpen = postpay && canServeTables(data) && !locked && selectionComplete;
  const failure = recent.error ?? board.error ?? (wanted ? found.error : null);

  // Beside the menu the search takes the focus when the column shows.
  useEffect(() => {
    if (!coarsePointer()) search.current?.focus({ preventScroll: true });
  }, []);
  useEffect(() => {
    if (naming) nameInput.current?.focus();
  }, [naming]);

  // The drawer is modal while open: focus starts inside (on the search only
  // from a mouse or a keyboard), Tab stays inside and Escape closes it,
  // giving the focus back to its button.
  useEffect(() => {
    const element = column.current;
    if (!drawer || !element) return;
    if (coarsePointer()) element.focus({ preventScroll: true });
    else search.current?.focus({ preventScroll: true });
    const onKeyDown = (event: KeyboardEvent) => {
      if (event.key === 'Escape') {
        // The name form closes itself first.
        if (event.target === nameInput.current) return;
        event.preventDefault();
        event.stopPropagation();
        setDrawer(false);
        toggle.current?.focus();
        return;
      }
      if (event.key !== 'Tab') return;
      const items = [...element.querySelectorAll<HTMLElement>(FOCUSABLE)];
      if (items.length === 0) return;
      const first = items[0];
      const last = items[items.length - 1];
      const current = document.activeElement;
      if (!element.contains(current)) {
        event.preventDefault();
        first.focus();
      } else if (event.shiftKey && (current === first || current === element)) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && current === last) {
        event.preventDefault();
        first.focus();
      }
    };
    document.addEventListener('keydown', onKeyDown, true);
    return () => document.removeEventListener('keydown', onKeyDown, true);
  }, [drawer]);

  function openedTime(iso: string | null) {
    if (!iso) return null;
    const at = new Date(iso);
    if (Number.isNaN(at.getTime())) return null;
    return at.toLocaleTimeString(i18n.language, { hour: '2-digit', minute: '2-digit', timeZone });
  }

  function closeDrawer() {
    setDrawer(false);
    toggle.current?.focus();
  }

  function select(workspaceId: string) {
    const fromDrawer = drawer;
    setDrawer(false);
    onSelect(workspaceId);
    // Beside the menu the search keeps the focus for the next name (not under
    // a finger); a closed drawer leaves it to the ticket.
    if (!fromDrawer && !coarsePointer()) search.current?.focus({ preventScroll: true });
  }

  async function openTab(value: string) {
    const tabName = value.trim();
    if (!tabName || opening.current || !canOpen) return;
    opening.current = true;
    setBusy(true);
    setMessage(null);
    try {
      const created = await selling.workspaces.openTab(tabName);
      setName('');
      setQuery('');
      setNaming(false);
      select(created.id);
    } catch (error) {
      const taken = takenTabId(error);
      if (taken) {
        // The guest already has a tab: it goes on the ticket instead.
        setName('');
        setQuery('');
        setNaming(false);
        setMessage(t('tabNameTakenOpened', { name: tabName }));
        select(taken);
      } else {
        setMessage(t(tabOpenFailureKey(error)));
      }
    } finally {
      opening.current = false;
      setBusy(false);
    }
  }

  function tapOpen() {
    // A name already typed in the search opens at once.
    if (query.trim()) void openTab(query);
    else setNaming((current) => !current);
  }

  return (
    <>
      <button
        ref={toggle}
        type="button"
        className="tab-drawer-toggle"
        aria-expanded={drawer}
        aria-controls={columnId}
        onClick={() => setDrawer((current) => !current)}
      >
        <PosIcon name="list" /> {t('tabListTitle')} <b>{openTabs + tableOrders}</b>
      </button>
      {drawer ? (
        <button
          type="button"
          className="tab-drawer-backdrop"
          aria-label={t('tabDrawerClose')}
          tabIndex={-1}
          onClick={closeDrawer}
        />
      ) : null}
      <section
        ref={column}
        id={columnId}
        className="tab-column"
        data-open={drawer}
        aria-label={t('tabListTitle')}
        {...(drawer ? DRAWER_DIALOG : {})}
      >
        <div className="tab-column-top">
          <label className="tab-column-search">
            <PosIcon name="search" />
            <span className="visually-hidden">{t('tabSearch')}</span>
            <input
              ref={search}
              type="search"
              value={query}
              placeholder={t('tabColumnSearchPlaceholder')}
              maxLength={TAB_NAME_MAX}
              onChange={(event) => setQuery(event.target.value)}
              onKeyDown={(event) => {
                if (event.key === 'Enter' && rows.length === 1) select(rows[0].id);
              }}
            />
          </label>
          <div className="tab-column-actions">
            {canOpen ? (
              <button
                type="button"
                className="primary-button"
                aria-expanded={query.trim() ? undefined : naming}
                disabled={busy}
                onClick={tapOpen}
              >
                <PosIcon name="plus" /> {t('tabOpen')}
              </button>
            ) : null}
            <button type="button" onClick={onBoard}>
              <PosIcon name="location" /> {t('tableFloorOpen')}
            </button>
          </div>
          {naming && canOpen ? (
            <form
              className="tab-column-open"
              onSubmit={(event: FormEvent) => {
                event.preventDefault();
                void openTab(name);
              }}
            >
              <label>
                <span className="visually-hidden">{t('tabName')}</span>
                <input
                  ref={nameInput}
                  value={name}
                  placeholder={t('tabNamePlaceholder')}
                  maxLength={TAB_NAME_MAX}
                  onChange={(event) => setName(event.target.value)}
                  onKeyDown={(event) => {
                    if (event.key === 'Escape') {
                      event.stopPropagation();
                      setNaming(false);
                      search.current?.focus();
                    }
                  }}
                />
              </label>
              <button type="submit" disabled={busy || !name.trim()}>
                {t('tabOpenConfirm')}
              </button>
            </form>
          ) : null}
        </div>
        {message ? (
          <p className="error tab-column-note" role="alert">
            {message}
          </p>
        ) : null}
        {failure ? (
          <p className="error tab-column-note" role="alert">
            {t(posFailureKey(failure))}
          </p>
        ) : null}
        {recent.isSuccess && rows.length === 0 ? (
          <p className="workspace-hint tab-column-note" role="status">
            {query.trim() ? t('tabNoMatch') : t('tabNone')}
          </p>
        ) : null}
        <ul className="tab-rows" aria-label={t('tabListTitle')}>
          {rows.map((row) => {
            const where = [row.place, openedTime(row.openedAt)].filter(Boolean).join(' · ');
            // The order on the ticket reads its own latest state, not the list's.
            const live = row.id === active?.id ? active : null;
            const total = live?.totals?.total ?? row.total;
            const unsent = kitchenOn ? (live ? pendingKitchenUnits(live) : (row.unsent ?? 0)) : 0;
            return (
              <li key={row.id}>
                <button
                  type="button"
                  className={row.paymentRequested ? 'tab-row tab-row-payment' : 'tab-row'}
                  aria-current={row.id === active?.id ? 'true' : undefined}
                  data-tab-id={row.id}
                  data-kind={row.kind}
                  onClick={() => select(row.id)}
                >
                  <span className="tab-row-main">
                    <strong className="tab-row-name">{row.name}</strong>
                    {where ? <small>{where}</small> : null}
                  </span>
                  <span className="tab-row-side">
                    <b>{formatMoney(total, currency)}</b>
                    {row.paymentRequested ? (
                      <small className="tab-row-bill">{t('tableState_payment_requested')}</small>
                    ) : null}
                    {unsent > 0 ? (
                      <small className="tab-row-unsent">{t('tabUnsent', { count: unsent })}</small>
                    ) : null}
                  </span>
                </button>
              </li>
            );
          })}
        </ul>
        {!query.trim() && unseenTabs > 0 ? (
          <p className="workspace-hint tab-column-note" role="status">
            {t('tabColumnMore', { count: unseenTabs })}
          </p>
        ) : null}
      </section>
    </>
  );
}
