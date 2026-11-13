import { parseVndAmount } from '@parkviet/pos-shared/money';
import type { Platform } from '@parkviet/pos-shared/platform-orders';
import { groupTicketLines } from '@parkviet/pos-shared/ticket-groups';
import { useSearch } from '@tanstack/react-router';
import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useSellingWorkspace } from '../../hooks/use-selling-workspace';
import { commandQueue } from '../../lib/command-queue';
import { describeMenuFailure } from '../../lib/menu-selection';
import type { PosWorkspace } from '../../lib/pos-context';
import {
  blankOrder,
  ownBlankCandidates,
  ownDraftsOf,
  saveOwnDrafts,
} from '../../lib/quick-counter';
import { autoPrintEnabled } from '../../lib/receipt-preferences';
import { workspaceIsSettled } from '../../lib/workspace-content';
import { MealBanner } from '../meal-banner';
import { ReceiptPrintDialog } from '../receipt-print-dialog';
import { PaymentScreen, useHandOver } from '../table-service/payment-screen';
import { OrderMenu } from '../table-service/table-service-screen';
import { TicketLines } from '../table-service/ticket-lines';
import { TicketMoreMenu, type TicketMorePanel } from '../table-service/ticket-more-menu';
import {
  ActivePrebillDialog,
  ActiveVoidDialog,
  orderTimeZone,
  SellingNotices,
} from '../workspace-tabs';
import { HeldOrdersStrip } from './held-orders-strip';
import { QuickPayBar } from './quick-pay-bar';
import { type QuickDone, QuickTicketHeader } from './quick-ticket-header';
import { VehicleVisitStrip } from './vehicle-visit-strip';

// How long the order just paid stays at the head of the next ticket, and a
// short confirmation stays on screen.
const DONE_MS = 8_000;
const NOTICE_MS = 4_000;

type QuickView = 'order' | 'pay';

// The next guest's ticket: not asked, on its way, or refused (the order
// being left, if any, to try again from).
type Fresh =
  | { state: 'idle' }
  | { state: 'starting' }
  | { state: 'failed'; leaving: string | null };

// Selling at a counter that takes payment first (a cafe, a tea shop, an
// eatery without tables): the menu beside one ticket, no table board and no
// invoice tabs. The ticket is paid on the spot; once paid it is handed over,
// its receipt prints as the device is set to, and an empty ticket is ready
// for the next guest with the paid call number shown for a moment. VietQR
// and the rarer methods take the full payment screen (`?view=pay`). An order
// put aside waits in the strip above the menu. A canteen types or scans
// meal codes at the head of the ticket, its eater shown under it with the
// one-touch payment from the wallet; a rest stop puts orders on the coaches
// in the strip above the menu.
export function QuickCounterScreen() {
  const { t, i18n } = useTranslation();
  const search = useSearch({ from: '/authed/' });
  const [view, setView] = useState<QuickView>(() => (search.view === 'pay' ? 'pay' : 'order'));
  const [tender, setTender] = useState<'vietqr' | 'cash'>('vietqr');
  // A frame the URL changes to by itself (history) is followed.
  const lastSearchView = useRef(search.view);
  useEffect(() => {
    if (search.view === lastSearchView.current) return;
    lastSearchView.current = search.view;
    if (search.view === 'pay' || search.view === 'order') setView(search.view);
  }, [search.view]);
  const selling = useSellingWorkspace({ view });
  const {
    active,
    activeLoading,
    menuSurface,
    menu,
    canCreate,
    selectionComplete,
    workspaces,
    selectOrder,
    createDraft,
    leaveOrder,
  } = selling;
  const handOver = useHandOver(selling);
  const [notice, setNotice] = useState<{ text: string; seq: number } | null>(null);
  const [done, setDone] = useState<(QuickDone & { seq: number }) | null>(null);
  // Orders paid on this screen so far: each one sends the focus back to the
  // meal code field (the paid number fading later does not).
  const [paidCount, setPaidCount] = useState(0);
  // A meal code is being looked up or recorded on the order.
  const [mealPending, setMealPending] = useState(false);
  const [printing, setPrinting] = useState<string | null>(null);
  const [more, setMore] = useState<TicketMorePanel | null>(null);
  const [platform, setPlatform] = useState<Platform | null>(null);
  // The order being handed over after its payment: it stays on the ticket
  // until that is done.
  const finishing = useRef<string | null>(null);
  // A next order is on its way (picked or being created); asked once until
  // an order is on the ticket again, so a refused creation does not repeat
  // by itself: the cashier tries again.
  const [fresh, setFresh] = useState<Fresh>({ state: 'idle' });
  // The order on the ticket now, for work that ends after a wait.
  const activeIdRef = useRef<string | null>(null);
  // The blank drafts this device opened for its next guests.
  const registerId = selling.selection.registerId;
  const [ownDrafts, setOwnDrafts] = useState<Set<string>>(() =>
    registerId ? ownDraftsOf(registerId) : new Set(),
  );
  useEffect(() => {
    setOwnDrafts(registerId ? ownDraftsOf(registerId) : new Set());
  }, [registerId]);
  function changeOwnDrafts(change: (ids: Set<string>) => void) {
    if (!registerId) return;
    // Read back from storage so two quick changes do not lose one another.
    const next = ownDraftsOf(registerId);
    change(next);
    saveOwnDrafts(registerId, next);
    setOwnDrafts(next);
  }
  const notify = (text: string) => setNotice((current) => ({ text, seq: (current?.seq ?? 0) + 1 }));

  useEffect(() => {
    if (!notice) return;
    const timer = window.setTimeout(() => setNotice(null), NOTICE_MS);
    return () => window.clearTimeout(timer);
  }, [notice]);
  useEffect(() => {
    if (!done) return;
    const timer = window.setTimeout(() => setDone(null), DONE_MS);
    return () => window.clearTimeout(timer);
  }, [done]);

  // The next guest's ticket: a blank draft this device opened earlier, once
  // its full detail confirms it is still blank, else a new one.
  async function startFresh(leaving: string | null) {
    setFresh({ state: 'starting' });
    try {
      for (const row of ownBlankCandidates(selling.rows, leaving, ownDrafts)) {
        const detail = await workspaces.detail(row.id).catch(() => null);
        if (detail && blankOrder(detail)) {
          selectOrder(detail.id);
          setFresh({ state: 'idle' });
          return;
        }
        // Started since (or gone): it is an order like any other now.
        if (detail) changeOwnDrafts((ids) => ids.delete(row.id));
      }
      const created = await createDraft();
      if (!created) {
        setFresh({ state: 'failed', leaving });
        return;
      }
      changeOwnDrafts((ids) => ids.add(created.id));
      setFresh({ state: 'idle' });
    } catch {
      setFresh({ state: 'failed', leaving });
    }
  }

  const activeId = active?.id ?? null;
  activeIdRef.current = activeId;
  useEffect(() => {
    if (activeId) setFresh((current) => (current.state === 'idle' ? current : { state: 'idle' }));
  }, [activeId]);
  // A draft of this device that got dishes, a number or a name is an order
  // like any other: it shows in the strip once put aside.
  const startedOwn = active?.line_items && ownDrafts.has(active.id) && !blankOrder(active);
  // biome-ignore lint/correctness/useExhaustiveDependencies: changeOwnDrafts reads the latest register
  useEffect(() => {
    if (startedOwn && activeId) changeOwnDrafts((ids) => ids.delete(activeId));
  }, [startedOwn, activeId]);
  // Drafts paid or canceled since are forgotten.
  const settledOwn = selling.rows
    .filter((row) => ownDrafts.has(row.id) && workspaceIsSettled(row))
    .map((row) => row.id)
    .join(',');
  // biome-ignore lint/correctness/useExhaustiveDependencies: changeOwnDrafts reads the latest register
  useEffect(() => {
    if (!settledOwn) return;
    changeOwnDrafts((ids) => {
      for (const id of settledOwn.split(',')) ids.delete(id);
    });
  }, [settledOwn]);
  // A paid or canceled order leaves the ticket (one paid elsewhere, or
  // reopened after a reload, too).
  const settledId = active && workspaceIsSettled(active) ? active.id : null;
  // biome-ignore lint/correctness/useExhaustiveDependencies: leaveOrder is recreated every render
  useEffect(() => {
    if (view !== 'order' || !settledId || finishing.current === settledId) return;
    leaveOrder();
  }, [view, settledId]);
  // The pay frame without its order goes back to the ticket.
  useEffect(() => {
    if (view === 'pay' && !active && !activeLoading) setView('order');
  }, [view, active, activeLoading]);
  // No order on the ticket: the next one starts by itself once the
  // register's open orders are known and this cashier may create one.
  const listReady = selectionComplete && workspaces.query.isSuccess;
  // biome-ignore lint/correctness/useExhaustiveDependencies: startFresh reads the latest rows
  useEffect(() => {
    if (view !== 'order' || activeId || activeLoading || !listReady || !canCreate) return;
    if (fresh.state !== 'idle') return;
    void startFresh(null);
  }, [view, activeId, activeLoading, listReady, canCreate, fresh.state]);

  function finished(workspace: PosWorkspace, change: string) {
    setDone((current) => ({
      workspaceId: workspace.id,
      number: workspace.order_number ?? null,
      change,
      currency: workspace.totals?.currency ?? 'VND',
      seq: (current?.seq ?? 0) + 1,
    }));
    setPaidCount((count) => count + 1);
    if (autoPrintEnabled()) setPrinting(workspace.id);
  }

  // Paid in cash on the ticket: handed over, then the next ticket.
  async function paidHere(workspace: PosWorkspace) {
    finishing.current = workspace.id;
    try {
      const { latest, failure } = await handOver(workspace);
      finished(latest, parseVndAmount(latest.financial?.change_due ?? '') ?? '0');
      if (failure) notify(failure);
    } finally {
      finishing.current = null;
      // The cashier may have opened another order meanwhile: it stays.
      if (activeIdRef.current === workspace.id) leaveOrder();
    }
  }

  const toast = notice ? (
    <p key={notice.seq} className="table-service-notice" role="status">
      {notice.text}
    </p>
  ) : null;
  const printDialog = printing ? (
    <ReceiptPrintDialog sourceId={printing} autoPrint onClose={() => setPrinting(null)} />
  ) : null;

  if (view === 'pay')
    return (
      <>
        {printDialog}
        <PaymentScreen
          selling={selling}
          tender={tender}
          doneLabel={t('quickNextOrder')}
          onOrder={() => setView('order')}
          onBoard={() => setView('order')}
          onCompleted={(workspaceId, { print, failure }) => {
            // The change was shown on the payment screen already.
            const paid = active?.id === workspaceId ? active : null;
            if (paid) finished(paid, '0');
            if (print && !autoPrintEnabled()) setPrinting(workspaceId);
            if (failure) notify(failure);
            setView('order');
          }}
        />
      </>
    );

  // The quick counter sells from the menu only; until it is here the cashier
  // is told so (no product search with keys of its own in its place).
  const catalog =
    menuSurface && menu.data ? (
      <OrderMenu
        key={`${selling.storeId}:${selling.selection.branchId}`}
        menu={menu.data}
        selling={selling}
        imagesByDefault
      />
    ) : menu.isError ? (
      <p className="error quick-menu-state" role="alert">
        {describeMenuFailure(menu.error, t)}{' '}
        <button type="button" onClick={() => void menu.refetch()}>
          {t('menuRetry')}
        </button>
      </p>
    ) : (
      <p className="muted quick-menu-state" role="status">
        {t('menuLoading')}
      </p>
    );
  const startFailed =
    fresh.state === 'failed' ? (
      <p className="error ticket-hint" role="alert">
        {t('quickStartFailed')}{' '}
        <button type="button" disabled={!canCreate} onClick={() => void startFresh(fresh.leaving)}>
          {t('retry')}
        </button>
      </p>
    ) : null;
  const now = Date.now();
  const timeZone = active ? orderTimeZone(selling, active) : undefined;
  const { data, meal, staffId, storeId, locked, busy, isEditor, command } = selling;

  return (
    <section
      className="draft-workspace table-service table-service-order quick-counter"
      aria-label={t('draftList')}
    >
      {toast}
      {printDialog}
      <SellingNotices selling={selling} />
      <div className="order-frame">
        <section className="order-frame-menu" aria-label={t('catalogTitle')}>
          {selling.vehicleCommission ? (
            <VehicleVisitStrip
              key={`vehicle-strip:${selling.storeId}:${selling.selection.branchId}`}
              selling={selling}
            />
          ) : null}
          <HeldOrdersStrip
            selling={selling}
            ownDrafts={ownDrafts}
            enterPlatform={platform}
            onPlatformClosed={() => setPlatform(null)}
          />
          {catalog}
        </section>
        <aside className="ticket quick-ticket" aria-label={t('quickTicketTitle')}>
          <QuickTicketHeader
            selling={selling}
            active={active}
            done={done}
            // Back to the meal code field once an order is paid and no
            // receipt is in front of it.
            refocus={printing ? null : paidCount}
            onMealPending={setMealPending}
            onPrint={setPrinting}
            onPlatform={setPlatform}
            onMore={() => setMore('menu')}
          />
          {active && meal ? (
            <MealBanner
              key={`meal:${active.id}`}
              workspace={active}
              meal={meal}
              staffId={staffId}
              storeId={storeId}
              canCollect={Boolean(data?.capabilities.includes('pos.payment.collect'))}
              drawerOpen={Boolean(
                data?.shift &&
                  data.shift.id === active.shift_id &&
                  data.shift.owner_id === data.staff.id,
              )}
              disabled={locked || busy || !isEditor}
              command={async (action) => {
                const latest = await command(active, action);
                // Paid in one touch: handed over like a cash payment here.
                if (latest.operational_status === 'completed') void paidHere(latest);
                return latest;
              }}
            />
          ) : null}
          {active ? (
            <TicketLines
              key={`lines:${active.id}`}
              selling={selling}
              active={active}
              groups={groupTicketLines(active, 'round')}
              mode="round"
              plain
              cupTools
              clock={{
                now,
                time: (value) =>
                  new Date(value).toLocaleTimeString(i18n.language, {
                    hour: '2-digit',
                    minute: '2-digit',
                    timeZone,
                  }),
              }}
            />
          ) : (
            <div className="ticket-lines">
              <p className="ticket-empty" role="status">
                {activeLoading || fresh.state === 'starting'
                  ? t('contextWaiting')
                  : t('quickNoOrder')}
              </p>
              {!activeLoading && fresh.state === 'idle' && canCreate ? (
                <p className="ticket-empty">
                  <button type="button" onClick={() => void startFresh(null)}>
                    {t('quickNextOrder')}
                  </button>
                </p>
              ) : null}
            </div>
          )}
          {startFailed}
          {active && selling.lockReason && selling.isEditor ? (
            <p className="workspace-hint ticket-hint" role="status">
              {selling.lockReason}
            </p>
          ) : null}
          {active && (selling.busy || commandQueue.hasPending(active.id)) ? (
            <p className="muted ticket-hint" role="status">
              {t('waiting')}
            </p>
          ) : null}
          {active ? (
            <QuickPayBar
              key={`pay:${active.id}`}
              selling={selling}
              active={active}
              mealPending={mealPending}
              onOpen={(next) => {
                setTender(next);
                setView('pay');
              }}
              onPaid={(workspace) => void paidHere(workspace)}
              onHold={() => void startFresh(active.id)}
            />
          ) : null}
          {active && more ? (
            <TicketMoreMenu
              selling={selling}
              active={active}
              panel={more}
              onPanel={setMore}
              onClose={() => setMore(null)}
              onCanceled={() => setMore(null)}
            />
          ) : null}
          {active && selling.prebillOpen && active.operational_status === 'editing' ? (
            <ActivePrebillDialog selling={selling} active={active} />
          ) : null}
          {active && selling.voiding?.sale_line_id ? (
            <ActiveVoidDialog
              key={selling.voiding.id}
              selling={selling}
              active={active}
              line={selling.voiding}
            />
          ) : null}
        </aside>
      </div>
    </section>
  );
}
