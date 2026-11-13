import { useSearch } from '@tanstack/react-router';
import { useEffect, useMemo, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useSoldOutToggle } from '../../hooks/use-menu';
import { type SellingView, useSellingWorkspace } from '../../hooks/use-selling-workspace';
import { addsInOneTap, describeMenuFailure } from '../../lib/menu-selection';
import type { PosMenu, PosMenuItem, PosWorkspace } from '../../lib/pos-context';
import { autoPrintEnabled } from '../../lib/receipt-preferences';
import { CourseSeatPicker } from '../course-seat-picker';
import type { MenuAdd } from '../menu-grid';
import { ReceiptPrintDialog } from '../receipt-print-dialog';
import { SellingCatalog, SellingNotices, type SellingWorkspace } from '../workspace-tabs';
import { CategoryRail } from './category-rail';
import { MenuItemGrid } from './menu-item-grid';
import { ModifierPanel } from './modifier-panel';
import { PaymentScreen } from './payment-screen';
import { runningClockOf, type StopAndPay, StopAndPayDialog } from './stop-and-pay-dialog';
import { TableBoard } from './table-board';
import { Ticket } from './ticket';
import { useOrderRoom } from './timed-ticket-line';

// How long the screen shows a short confirmation ("Đã gửi 3 món").
const NOTICE_MS = 4_000;

// Selling at a branch that serves tables, in frames kept in the URL
// (`?view=`): the table board first, then the order of a table with the menu
// (categories, text tiles, or one dish's options) beside its ticket, then
// its payment over the whole screen. A page opened without a frame shows
// the order it names, else the board. A room's clock still counting is
// stopped (once the cashier says yes) before its payment ever opens.
export function TableServiceScreen() {
  const { t } = useTranslation();
  const search = useSearch({ from: '/authed/' });
  const [view, setView] = useState<SellingView>(
    () => search.view ?? (search.order ? 'order' : 'board'),
  );
  // A frame the URL changes to by itself (a link, history) is followed;
  // this screen's own writes already match `view`.
  const lastSearchView = useRef(search.view);
  useEffect(() => {
    if (search.view === lastSearchView.current) return;
    lastSearchView.current = search.view;
    if (search.view) setView(search.view);
  }, [search.view]);
  const selling = useSellingWorkspace({ view });
  const { menuSurface, menu, selectOrder, active, activeLoading, leaveOrder } = selling;
  // An order or payment frame without its order (closed, gone, not found)
  // goes back to the board; it never shows another order instead.
  // biome-ignore lint/correctness/useExhaustiveDependencies: leaveOrder is recreated every render
  useEffect(() => {
    if (view === 'board' || active || activeLoading) return;
    leaveOrder();
    setView('board');
  }, [view, active, activeLoading]);
  const [notice, setNotice] = useState<{ text: string; seq: number } | null>(null);
  useEffect(() => {
    if (!notice) return;
    const timer = window.setTimeout(() => setNotice(null), NOTICE_MS);
    return () => window.clearTimeout(timer);
  }, [notice]);
  // The order paid last, whose invoice prints over the board.
  const [printing, setPrinting] = useState<string | null>(null);
  const notify = (text: string) => setNotice((current) => ({ text, seq: (current?.seq ?? 0) + 1 }));
  // The room clock the cashier is asked to stop before paying.
  const [stopping, setStopping] = useState<StopAndPay | null>(null);
  const room = useOrderRoom(selling, active, view === 'order');
  const activeClock = runningClockOf(active, {
    name: selling.activeTable.table?.name,
    timed: room.timed,
    currency: room.table?.currency,
  });
  // No payment while a clock counts: a payment frame reached any other way
  // (a link, history, a clock started elsewhere) goes back to the order and
  // asks first. Decided while rendering, so the payment never mounts with
  // the clock counting, not even for one frame.
  if (view === 'pay' && activeClock) {
    setView('order');
    setStopping(activeClock);
  }

  function openOrder(workspaceId: string) {
    selectOrder(workspaceId);
    setView('order');
  }

  function openPay(workspaceId: string) {
    selectOrder(workspaceId);
    setView('pay');
  }

  // The ticket's "Thanh toán".
  function payActive() {
    if (activeClock) setStopping(activeClock);
    else setView('pay');
  }

  const toast = notice ? (
    <p key={notice.seq} className="table-service-notice" role="status">
      {notice.text}
    </p>
  ) : null;
  const printDialog = printing ? (
    <ReceiptPrintDialog sourceId={printing} autoPrint onClose={() => setPrinting(null)} />
  ) : null;
  const stopDialog = stopping ? (
    <StopAndPayDialog
      key={stopping.sessionId}
      request={stopping}
      selling={selling}
      onStopped={(workspaceId) => {
        setStopping(null);
        openPay(workspaceId);
      }}
      onClose={() => setStopping(null)}
    />
  ) : null;
  const catalog =
    menuSurface && menu.data ? (
      <OrderMenu
        key={`${selling.storeId}:${selling.selection.branchId}`}
        menu={menu.data}
        selling={selling}
      />
    ) : undefined;

  if (view === 'board')
    return (
      <section className="draft-workspace table-service" aria-label={t('draftList')}>
        {toast}
        {printDialog}
        {stopDialog}
        <TableBoard
          selling={selling}
          onOpenOrder={openOrder}
          onPay={openPay}
          onStopAndPay={setStopping}
        />
      </section>
    );
  if (view === 'pay' && !activeClock)
    return (
      <PaymentScreen
        selling={selling}
        onOrder={() => setView('order')}
        onBoard={() => setView('board')}
        onCompleted={(workspaceId, { print, failure }) => {
          if (print || autoPrintEnabled()) setPrinting(workspaceId);
          if (failure) notify(failure);
          setView('board');
        }}
      />
    );
  return (
    <section
      className="draft-workspace table-service table-service-order"
      aria-label={t('draftList')}
    >
      {toast}
      {stopDialog}
      <SellingNotices selling={selling} />
      <div className="order-frame">
        <section className="order-frame-menu" aria-label={t('catalogTitle')}>
          {catalog ?? (
            <SellingCatalog
              key={`${selling.storeId}:${selling.selection.branchId}`}
              selling={selling}
            />
          )}
        </section>
        <Ticket
          selling={selling}
          onBoard={() => setView('board')}
          room={room}
          onPay={payActive}
          onNotice={notify}
        />
      </div>
    </section>
  );
}

// Units of each dish on the order, counted from its lines by variant.
function dishQuantities(menu: PosMenu, workspace: PosWorkspace | null): Map<string, number> {
  const itemOf = new Map<string, string>();
  for (const item of menu.items)
    for (const variant of item.variants) itemOf.set(variant.id, item.id);
  const quantities = new Map<string, number>();
  for (const line of workspace?.line_items ?? []) {
    const itemId = itemOf.get(line.variant_id);
    const quantity = Number(line.quantity);
    if (!itemId || !Number.isFinite(quantity)) continue;
    quantities.set(itemId, (quantities.get(itemId) ?? 0) + quantity);
  }
  return quantities;
}

// The menu of an order: the categories, the dish tiles, or one dish's
// options with what it takes on the order. Table service and the quick
// counter pick from it alike.
export function OrderMenu({
  menu,
  selling,
  imagesByDefault = false,
}: {
  menu: PosMenu;
  selling: SellingWorkspace;
  // The dishes' pictures until this device says otherwise.
  imagesByDefault?: boolean;
}) {
  const { t } = useTranslation();
  const {
    data,
    selection,
    active,
    activeTable,
    workspaces,
    command,
    tableAddExtra,
    quickAddDisabled,
    lockReason,
    kitchenOn,
    placement,
    setPlacement,
    canAppend,
    busy,
  } = selling;
  const setSoldOut = useSoldOutToggle(selection.branchId);
  const [categoryId, setCategoryId] = useState<string | null>(null);
  // The dish whose options are open, for the order it was picked on.
  const [panel, setPanel] = useState<{ item: PosMenuItem; orderId: string } | null>(null);
  const panelItem = panel && panel.orderId === active?.id ? panel.item : null;
  const [notice, setNotice] = useState('');
  const quantities = useMemo(() => dishQuantities(menu, active), [menu, active]);
  const onAdd: MenuAdd | undefined = active
    ? (variantId, extra) =>
        command(active, (current) =>
          workspaces.addItem(current, variantId, 1, tableAddExtra(extra)),
        )
    : undefined;
  const addDisabled = quickAddDisabled || !onAdd;

  async function pick(item: PosMenuItem) {
    if (!onAdd || addDisabled) return;
    setNotice('');
    if (item.sold_out) {
      setNotice(t('menuFailure_menu_item_sold_out'));
      return;
    }
    const variant = item.variants[0];
    if (!addsInOneTap(menu, item) || !variant) {
      if (active) setPanel({ item, orderId: active.id });
      return;
    }
    try {
      await onAdd(variant.id, { merge: true });
    } catch (failure) {
      setNotice(describeMenuFailure(failure, t));
    }
  }

  async function toggleSoldOut(item: PosMenuItem) {
    setNotice('');
    try {
      await setSoldOut(item.id, !item.sold_out);
    } catch (failure) {
      setNotice(describeMenuFailure(failure, t));
    }
  }

  return (
    <div className="order-menu">
      {notice ? (
        <p className="workspace-hint order-menu-notice" role="alert">
          {notice}
        </p>
      ) : null}
      <div className="order-menu-body">
        {panelItem && onAdd ? (
          <ModifierPanel
            menu={menu}
            item={panelItem}
            placement={
              active && activeTable.table && kitchenOn && !active.payments ? (
                <CourseSeatPicker
                  workspace={active}
                  value={placement}
                  onChange={setPlacement}
                  disabled={!canAppend || busy}
                  onFire={(course) =>
                    command(active, (current) => workspaces.fireCourse(current, course))
                  }
                />
              ) : undefined
            }
            onSubmit={(result) =>
              onAdd(result.variantId, {
                modifiers: result.modifiers,
                note: result.note || undefined,
                merge: true,
              })
            }
            onClose={() => setPanel(null)}
          />
        ) : (
          <>
            <CategoryRail menu={menu} value={categoryId} onChange={setCategoryId} />
            <MenuItemGrid
              menu={menu}
              categoryId={categoryId}
              quantities={quantities}
              disabled={addDisabled}
              disabledReason={lockReason}
              imagesByDefault={imagesByDefault}
              canSetSoldOut={Boolean(
                data?.capabilities.includes('pos.menu.sold_out') ||
                  data?.capabilities.includes('pos.menu.manage'),
              )}
              onPick={(item) => void pick(item)}
              onToggleSoldOut={(item) => void toggleSoldOut(item)}
            />
          </>
        )}
      </div>
    </div>
  );
}
