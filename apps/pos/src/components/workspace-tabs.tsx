import { formatMoney } from '@parkviet/pos-shared/money';
import type { Platform } from '@parkviet/pos-shared/platform-orders';
import { contextFeature } from '@parkviet/pos-shared/pos-features';
import { rateLabel } from '@parkviet/pos-shared/receipt-template/data';
import { useRef } from 'react';
import { useTranslation } from 'react-i18next';
import { useSellingWorkspace } from '../hooks/use-selling-workspace';
import { commandQueue } from '../lib/command-queue';
import type { PosLineItem, PosWorkspace } from '../lib/pos-context';
import { posFailureKey } from '../lib/request-failure';
import { voidReasons } from '../lib/table-kitchen';
import { canServeTables, isTab, tableOrderName, tableOrderOf } from '../lib/tables';
import { canRunClock } from '../lib/timed-clock';
import { workspaceIsSettled, workspacePhase } from '../lib/workspace-content';
import { BuffetTierPicker } from './buffet-tier-picker';
import { CatalogSearch } from './catalog-search';
import { CloseTabDialog } from './close-tab-dialog';
import { CourseSeatPicker } from './course-seat-picker';
import { CustomerPanel } from './customer-panel';
import { DeliveryForm } from './delivery-form';
import { DiscountForm } from './discount-form';
import { DisplayPinControl } from './display-pin-control';
import { GuestNameField } from './guest-name-field';
import { GuestOrderTray } from './guest-order-tray';
import { KioskOrderTray } from './kiosk-order-tray';
import { KitchenHistory } from './kitchen-history';
import { MealBanner } from './meal-banner';
import { MenuGrid } from './menu-grid';
import { MinimumSpendLines } from './minimum-spend-lines';
import { NoteForm } from './note-form';
import { OrderLines } from './order-lines';
import { OrderSourcePicker } from './order-source-picker';
import { PaymentPanel } from './payment-panel';
import { PickupQueue } from './pickup-queue';
import { PlatformOrderTray } from './platform-order-tray';
import { PosIcon } from './pos-icon';
import { PrebillDialog } from './prebill-dialog';
import { ReservationDepositNote } from './reservation-deposit-note';
import { ScanInput } from './scan-input';
import { SegmentEditDialog } from './segment-edit-dialog';
import { ServiceModeControl } from './service-mode-control';
import { TabList } from './tab-list';
import { TableOrderBar } from './table-actions';
import { TableFloor } from './table-floor';
import { VehicleVisitBar } from './vehicle-visit-bar';
import { VoidItemDialog } from './void-item-dialog';

export type SellingWorkspace = ReturnType<typeof useSellingWorkspace>;

export function WorkspaceTabs() {
  return <WorkspaceTabsView selling={useSellingWorkspace()} />;
}

// The waiting orders of the branch, each tray a button with its count that
// opens the tray: delivery platforms, guests' QR orders, kiosks.
// `onTaken` opens an order taken from a tray (selected here by default);
// `enterPlatform` opens the entry of a platform order for that platform.
export function OrderTrays({
  selling,
  onTaken,
  enterPlatform,
  onPlatformClosed,
}: {
  selling: SellingWorkspace;
  onTaken?: (workspaceId: string) => void;
  enterPlatform?: Platform | null;
  onPlatformClosed?: () => void;
}) {
  const {
    data,
    selection,
    selectionComplete,
    storeId,
    workspaces,
    locked,
    channelUnavailable,
    platformOrders,
    guestOrders,
    kioskOrders,
    selectOrder,
  } = selling;
  return (
    <>
      {platformOrders && selectionComplete ? (
        <PlatformOrderTray
          key={`${storeId}:${selection.branchId}`}
          branchId={selection.branchId}
          registerId={selection.registerId}
          canEnter={Boolean(
            data?.shift && data.shift.owner_id === data.staff.id && !locked && !channelUnavailable,
          )}
          canCollect={Boolean(data?.capabilities.includes('pos.payment.collect'))}
          enterWith={enterPlatform}
          onEnterClosed={onPlatformClosed}
        />
      ) : null}
      {guestOrders && selectionComplete ? (
        <GuestOrderTray
          key={`guest:${storeId}:${selection.branchId}`}
          branchId={selection.branchId}
          canDecide={Boolean(data?.capabilities.includes('pos.guest_order.decide')) && !locked}
        />
      ) : null}
      {kioskOrders && selectionComplete ? (
        <KioskOrderTray
          key={`kiosk:${storeId}:${selection.branchId}`}
          branchId={selection.branchId}
          canTake={Boolean(data?.shift && data.shift.owner_id === data.staff.id) && !locked}
          onTake={async (id) => {
            const taken = await workspaces.takeKioskOrder(id);
            (onTaken ?? selectOrder)(taken.id);
          }}
        />
      ) : null}
    </>
  );
}

// The counter layout over selling state owned by the caller.
export function WorkspaceTabsView({ selling }: { selling: SellingWorkspace }) {
  const { t } = useTranslation();
  const {
    data,
    selection,
    selectionComplete,
    staffId,
    storeId,
    workspaces,
    locked,
    channelUnavailable,
    query,
    setQuery,
    pendingCounts,
    scanNotice,
    blockedScans,
    setBlockedScans,
    hidden,
    setHidden,
    closeRequest,
    setCloseRequest,
    closing,
    setClosing,
    rows,
    tabNumbers,
    visible,
    overflow,
    active,
    setActiveId,
    isEditor,
    activePhase,
    busy,
    editable,
    editDisabled,
    sourceDisabled,
    canAppend,
    lockReason,
    menuSurface,
    menu,
    callNumbers,
    cupLabels,
    setSavedSurface,
    tableSurface,
    mealAccounts,
    meal,
    vehicleCommission,
    activeTable,
    tablist,
    setFloorChoice,
    tabSurface,
    showTabs,
    setTabsChoice,
    command,
    run,
    hideWorkspace,
    selectOrder,
    canCreate,
    createDraft,
    cancellable,
    cancelAndHide,
    requestClose,
    scanner,
    prebillOpen,
    setPrebillOpen,
    voiding,
    setVoiding,
    editingSegment,
    setEditingSegment,
    kitchenOn,
    placement,
    setPlacement,
    enqueueScan,
  } = selling;
  const discountDetailsRef = useRef<HTMLDetailsElement>(null);
  const noteDetailsRef = useRef<HTMLDetailsElement>(null);
  const deliveryDetailsRef = useRef<HTMLDetailsElement>(null);
  const showFloor = selling.showFloor;

  return (
    <section className="draft-workspace" aria-label={t('draftList')}>
      <div className="draft-toolbar">
        {tabSurface ? (
          <button
            type="button"
            className="floor-toggle"
            aria-pressed={showTabs}
            onClick={() => {
              setTabsChoice(!showTabs);
              if (!showTabs && selling.showFloor) setFloorChoice(false);
            }}
          >
            <PosIcon name={showTabs ? 'back' : 'grid'} />{' '}
            {showTabs ? t('tableBackToSale') : t('tabListTitle')}
          </button>
        ) : null}
        {tableSurface ? (
          <button type="button" className="floor-toggle" onClick={() => setFloorChoice(!showFloor)}>
            <PosIcon name={showFloor ? 'back' : 'grid'} />{' '}
            {showFloor ? t('tableBackToSale') : t('tableFloorOpen')}
          </button>
        ) : null}
        <button
          type="button"
          disabled={busy || !canCreate}
          onClick={() => {
            createDraft();
            if (showFloor) setFloorChoice(false);
          }}
        >
          <PosIcon name="plus" /> {t('newDraft')}
        </button>
        <details className="draft-filter">
          <summary title={t('search')}>
            <PosIcon name="search" />
            <span className="visually-hidden">{t('search')}</span>
          </summary>
          <label>
            {t('search')}
            <input value={query} onChange={(event) => setQuery(event.target.value)} />
          </label>
        </details>
        {hidden.length > 0 ? (
          <button
            type="button"
            onClick={() => {
              setHidden([]);
              workspaces.rememberClosed([]);
            }}
          >
            {t('showClosedViews')}
          </button>
        ) : null}
        <div className="tablist" ref={tablist} role="tablist" aria-label={t('draftList')}>
          {visible.map((workspace) => {
            const phase = workspacePhase(workspace.id === active?.id ? active : workspace);
            const seat = tableOrderOf(workspace);
            return (
              <span key={workspace.id} className="workspace-tab" role="presentation">
                <button
                  type="button"
                  role="tab"
                  aria-label={t('invoiceTab', { number: tabNumbers[workspace.id] })}
                  aria-description={t(`workspacePhase_${phase}`)}
                  data-workspace-id={workspace.id}
                  title={t(`workspacePhase_${phase}`)}
                  aria-selected={workspace.id === active?.id}
                  onClick={() => {
                    setActiveId(workspace.id);
                    workspaces.rememberView(workspace.id, workspaces.page);
                    if (showFloor) setFloorChoice(false);
                  }}
                >
                  <strong>{t('invoiceTab', { number: tabNumbers[workspace.id] })}</strong>
                  {/* The table a table order is served at. */}
                  {seat.table ? (
                    <span className="workspace-table-name">
                      {tableOrderName(seat.table.name, seat.label)}
                    </span>
                  ) : isTab(workspace) ? (
                    <span className="workspace-table-name">{workspace.tab_name}</span>
                  ) : null}
                  {/* The call number the counter calls out, once the order has one. */}
                  {workspace.order_number != null ? (
                    <span className="workspace-call-number" data-testid="tab-call-number">
                      {t('callNumberShort', { number: workspace.order_number })}
                    </span>
                  ) : null}
                  {/* Selling is the default; only a state that changes what to do is badged. */}
                  {phase === 'editing' ? null : (
                    <span className={`workspace-phase workspace-phase-${phase}`} aria-hidden="true">
                      {t(`workspacePhase_${phase}`)}
                    </span>
                  )}
                </button>
                <button
                  type="button"
                  className="workspace-tab-close"
                  aria-label={t('closeTabAction', { number: tabNumbers[workspace.id] })}
                  title={t('closeTabAction', { number: tabNumbers[workspace.id] })}
                  disabled={closing === workspace.id || Boolean(pendingCounts[workspace.id])}
                  onClick={() => void requestClose(workspace)}
                >
                  <PosIcon name="close" />
                </button>
              </span>
            );
          })}
        </div>
      </div>
      {closeRequest ? (
        <CloseTabDialog
          workspace={closeRequest.workspace}
          number={tabNumbers[closeRequest.workspace.id]}
          canCancel={cancellable(closeRequest.workspace)}
          busy={closing === closeRequest.workspace.id}
          onDismiss={() => setCloseRequest(null)}
          onKeep={() => hideWorkspace(closeRequest.workspace.id)}
          onCancelInvoice={() => {
            const target = closeRequest.workspace;
            setClosing(target.id);
            void run(() => cancelAndHide(target).then(() => undefined)).finally(() => {
              setClosing(null);
              setCloseRequest((current) => (current?.workspace.id === target.id ? null : current));
            });
          }}
        />
      ) : null}
      {overflow > 0 ? (
        <label>
          {t('moreDrafts')}
          <select
            value={active?.id ?? ''}
            onChange={(event) => {
              setActiveId(event.target.value || null);
              workspaces.rememberView(event.target.value || null, workspaces.page);
            }}
          >
            <option value="">{t('chooseDraft')}</option>
            {rows.map((workspace) => (
              <option key={workspace.id} value={workspace.id}>
                {t('invoiceTab', { number: tabNumbers[workspace.id] })}
              </option>
            ))}
          </select>
        </label>
      ) : null}
      {(workspaces.query.data?.meta.pages ?? 1) > 1 ? (
        <div className="row">
          <button
            type="button"
            disabled={workspaces.page <= 1}
            onClick={() => {
              setActiveId(null);
              workspaces.rememberView(null, workspaces.page - 1);
              workspaces.setPage(workspaces.page - 1);
            }}
          >
            {t('previousPage')}
          </button>
          <span>
            {workspaces.page} / {workspaces.query.data?.meta.pages || 1}
          </span>
          <button
            type="button"
            disabled={workspaces.page >= (workspaces.query.data?.meta.pages ?? 1)}
            onClick={() => {
              setActiveId(null);
              workspaces.rememberView(null, workspaces.page + 1);
              workspaces.setPage(workspaces.page + 1);
            }}
          >
            {t('nextPage')}
          </button>
        </div>
      ) : null}
      <SellingNotices selling={selling} />
      <OrderTrays selling={selling} />
      {showTabs ? (
        <TabList
          key={`tabs:${storeId}:${selection.branchId}`}
          branchId={selection.branchId}
          storeId={storeId}
          currency={data?.store.currency ?? 'VND'}
          canOpen={canServeTables(data) && !locked && selectionComplete}
          onOpenTab={async (name) => {
            const created = await workspaces.openTab(name);
            selectOrder(created.id);
            setTabsChoice(false);
          }}
          onSelectOrder={(id) => {
            selectOrder(id);
            setTabsChoice(false);
          }}
        />
      ) : showFloor && tableSurface ? (
        <TableFloor
          key={`${storeId}:${selection.branchId}`}
          branchId={selection.branchId}
          surface={tableSurface}
          onSurface={setSavedSurface}
          canServe={canServeTables(data)}
          locked={locked || !selectionComplete}
          onOpenTable={async (table, input) => {
            const created = await workspaces.openTable(table.id, input);
            selectOrder(created.id);
          }}
          onSelectOrder={selectOrder}
          canTime={canRunClock(data)}
          onStartClock={async (table, options) => {
            const started = await workspaces.startClock(
              table.id,
              table.orders.length === 0,
              options,
            );
            selectOrder(started.id);
          }}
          onCheckoutClock={async (sessionId, approvalId) => {
            // The clock stops first, so the payment takes the billed time.
            const stopped = await workspaces.clockCommand(
              'POST',
              `/pos/timed_sessions/${sessionId}/stop`,
              approvalId ? { approval_id: approvalId } : {},
            );
            selectOrder(stopped.id);
          }}
        />
      ) : (
        <>
          <nav className="sale-panel-nav" aria-label={t('sellingArea')}>
            {[
              ['pos-catalog', 'catalogTitle'],
              ['pos-basket', 'basketTitle'],
              ['pos-checkout', 'checkoutTitle'],
            ].map(([id, label]) => (
              <a
                key={id}
                href={`#${id}`}
                onClick={(event) => {
                  event.preventDefault();
                  document
                    .getElementById(id)
                    ?.scrollIntoView({ block: 'nearest', inline: 'start' });
                }}
              >
                {t(label)}
              </a>
            ))}
          </nav>
          <div className="sale-layout">
            <section
              className="selling-panel catalog-panel"
              id="pos-catalog"
              aria-label={t('catalogTitle')}
            >
              {active && blockedScans[active.id] ? (
                <div className="workspace-hint" role="alert">
                  <span>
                    {t('scanUnknown', {
                      code: blockedScans[active.id],
                      count: scanner.snapshot(active.id).pending.length,
                    })}
                  </span>
                  <button
                    type="button"
                    onClick={() => {
                      setBlockedScans((current) => {
                        const next = { ...current };
                        delete next[active.id];
                        return next;
                      });
                      scanner.retry(active.id);
                    }}
                  >
                    {t('scanRetry')}
                  </button>
                </div>
              ) : null}
              {mealAccounts ? (
                <ScanInput
                  key={`meal-scan:${storeId}:${selection.branchId}`}
                  branchId={selection.branchId}
                  workspace={active}
                  disabled={!editable || channelUnavailable}
                  onSwipe={(input) => {
                    if (!active) return Promise.reject(new Error('workspace-required'));
                    return command(active, async (current) => {
                      const swiped = await workspaces.mealSwipe(current, input);
                      return swiped.workspace;
                    });
                  }}
                  onBarcode={
                    editable && !channelUnavailable
                      ? (code) => enqueueScan.current(code)
                      : undefined
                  }
                  barcodeNotice={menuSurface ? scanNotice : null}
                />
              ) : null}
              {vehicleCommission ? (
                <VehicleVisitBar
                  key={`vehicle-bar:${storeId}:${selection.branchId}`}
                  branchId={selection.branchId}
                  staffId={staffId}
                  storeId={storeId}
                  workspace={active}
                  disabled={!editable || channelUnavailable}
                  onAttach={(visitId) => {
                    if (!active) return Promise.reject(new Error('workspace-required'));
                    return command(active, (current) => workspaces.vehicleVisit(current, visitId));
                  }}
                />
              ) : null}
              <SellingCatalog key={`${storeId}:${selection.branchId}`} selling={selling} />
            </section>
            <section
              className="selling-panel basket-panel"
              id="pos-basket"
              aria-label={t('basketTitle')}
            >
              <div className="basket-heading">
                <h2>{t('basketTitle')}</h2>
                {active ? (
                  <span
                    className={`workspace-phase workspace-phase-${activePhase}`}
                    role="status"
                    title={t(`workspacePhaseHint_${activePhase}`)}
                  >
                    {t(`workspacePhase_${activePhase}`)}
                  </span>
                ) : null}
                {active ? (
                  <span>
                    {active.line_items?.length ?? 0} {t('basketLines')}
                  </span>
                ) : null}
                {active ? (
                  <div className="row basket-actions">
                    <button
                      type="button"
                      disabled={
                        busy || locked || !isEditor || active.operational_status === 'canceled'
                      }
                      onClick={() =>
                        void run(() =>
                          command(active, (current) =>
                            workspaces.change(
                              current,
                              current.operational_status === 'parked' ? 'reopen' : 'park',
                            ),
                          ),
                        )
                      }
                    >
                      {t(active.operational_status === 'parked' ? 'reopenDraft' : 'park')}
                    </button>
                    <details className="order-more">
                      <summary>
                        {t('orderMore')} <PosIcon name="chevron" />
                      </summary>
                      <div className="order-more-menu">
                        <button
                          type="button"
                          disabled={
                            busy ||
                            locked ||
                            !isEditor ||
                            active.operational_status === 'canceled' ||
                            active.payments
                          }
                          title={active.payments ? t('cancelDraftPayments') : undefined}
                          onClick={() => {
                            if (window.confirm(t('cancelDraftConfirm', { order: active.order_id })))
                              void run(() =>
                                command(active, (current) => workspaces.change(current, 'cancel')),
                              );
                          }}
                        >
                          {t('cancelDraft')}
                        </button>
                        <button type="button" onClick={() => hideWorkspace(active.id)}>
                          {t('closeView')}
                        </button>
                        <button
                          type="button"
                          disabled={active.operational_status !== 'editing'}
                          onClick={() => setPrebillOpen(true)}
                        >
                          {t('receiptPrebillOpen')}
                        </button>
                      </div>
                    </details>
                    {prebillOpen && active.operational_status === 'editing' ? (
                      <ActivePrebillDialog selling={selling} active={active} />
                    ) : null}
                  </div>
                ) : null}
              </div>
              {active && activeTable.table ? (
                <ActiveTableOrderBar key={active.id} selling={selling} active={active} />
              ) : null}
              {active && activeTable.table && kitchenOn && !active.payments ? (
                <div className="table-service-panel">
                  <CourseSeatPicker
                    workspace={active}
                    value={placement}
                    onChange={setPlacement}
                    disabled={!canAppend || busy}
                    onFire={(course) =>
                      command(active, (current) => workspaces.fireCourse(current, course))
                    }
                  />
                  <ActiveBuffetPicker selling={selling} active={active} />
                </div>
              ) : null}
              {active ? (
                <article className="draft-detail">
                  {active.order_number != null ? (
                    <p
                      className={`call-number-banner${
                        active.operational_status === 'completed' ? ' call-number-banner-done' : ''
                      }`}
                      data-testid="call-number"
                    >
                      {t('callNumber', { number: active.order_number })}
                      {active.guest_name ? <small> · {active.guest_name}</small> : null}
                    </p>
                  ) : null}
                  {callNumbers || cupLabels ? (
                    <GuestNameField
                      key={`:guest:${active.guest_name ?? ''}`}
                      workspace={active}
                      disabled={sourceDisabled}
                      disabledReason={lockReason}
                      onSave={(guestName) =>
                        command(active, (current) => workspaces.setGuestName(current, guestName))
                      }
                    />
                  ) : null}
                  <OrderLines
                    key={active.id}
                    workspace={active}
                    disabled={editDisabled}
                    disabledReason={lockReason}
                    appendOnly={canAppend && !busy}
                    onVoid={kitchenOn && !active.payments ? setVoiding : undefined}
                    onEditSegment={
                      canRunClock(data) && !workspaceIsSettled(active)
                        ? (line, segment) =>
                            line.timed_session &&
                            setEditingSegment({ sessionId: line.timed_session.id, segment })
                        : undefined
                    }
                    onStale={() => void workspaces.refresh()}
                    canApplyDiscount={Boolean(data?.capabilities.includes('pos.discount.apply'))}
                    canOverridePrice={Boolean(data?.capabilities.includes('pos.price.override'))}
                    onUpdate={(lineId, input) =>
                      command(active, (current) => workspaces.updateItem(current, lineId, input))
                    }
                    onRemove={(lineId) =>
                      command(active, (current) => workspaces.removeItem(current, lineId))
                    }
                    onLineDiscount={(saleLineId, input) =>
                      command(active, (current) =>
                        workspaces.lineDiscount(current, saleLineId, input),
                      )
                    }
                    onClearLineDiscount={(saleLineId, approvalId) =>
                      command(active, (current) =>
                        workspaces.clearLineDiscount(current, saleLineId, approvalId),
                      )
                    }
                    onPriceOverride={(saleLineId, input) =>
                      command(active, (current) =>
                        workspaces.priceOverride(current, saleLineId, input),
                      )
                    }
                    menu={menuSurface ? (menu.data ?? null) : null}
                    onUpdateModifiers={(saleLineId, input) =>
                      command(active, (current) =>
                        workspaces.updateModifiers(current, saleLineId, input),
                      )
                    }
                    onAddSame={(variantId, input) =>
                      command(active, (current) =>
                        workspaces.addItem(current, variantId, 1, { ...input, merge: true }),
                      )
                    }
                    cupLabels={cupLabels}
                  />
                  {voiding?.sale_line_id ? (
                    <ActiveVoidDialog
                      key={voiding.id}
                      selling={selling}
                      active={active}
                      line={voiding}
                    />
                  ) : null}
                  {editingSegment ? (
                    <SegmentEditDialog
                      key={editingSegment.segment.id}
                      workspace={active}
                      segment={editingSegment.segment}
                      canEdit={Boolean(data?.capabilities.includes('pos.timed.edit'))}
                      onSave={(input) =>
                        workspaces.clockCommand(
                          'PATCH',
                          `/pos/timed_sessions/${editingSegment.sessionId}/segments/${editingSegment.segment.id}`,
                          input,
                        )
                      }
                      onClose={() => setEditingSegment(null)}
                    />
                  ) : null}
                  {lockReason && isEditor ? (
                    <p className="workspace-hint" role="status">
                      {lockReason}
                    </p>
                  ) : null}
                  {busy || commandQueue.hasPending(active.id) ? (
                    <p className="muted" role="status">
                      {t('waiting')}
                    </p>
                  ) : null}
                </article>
              ) : (
                <div className="empty">
                  <strong>{t('basketEmpty')}</strong>
                  <p>{t('basketStart')}</p>
                </div>
              )}
            </section>
            <aside
              className="checkout-panel"
              id="pos-checkout"
              tabIndex={-1}
              aria-label={t('checkoutTitle')}
            >
              {active ? (
                <div className="checkout-section" key={active.id}>
                  <ActiveCustomerPanel key={active.id} selling={selling} active={active} />
                  <ServiceModeControl
                    value={active.service_mode}
                    enabled={data?.modules?.['fnb.menu'] === true}
                    disabled={sourceDisabled}
                    onPick={(mode) =>
                      void run(() =>
                        command(active, (current) => workspaces.setServiceMode(current, mode)),
                      )
                    }
                  />
                  <OrderSourcePicker
                    value={active.order_source}
                    disabled={sourceDisabled}
                    onPick={(source) =>
                      void run(() =>
                        command(active, (current) => workspaces.setOrderSource(current, source)),
                      )
                    }
                  />
                  <section className="checkout-totals" aria-label={t('orderDetails')}>
                    <div className="checkout-totals-header">
                      <h2>{t('orderDetails')}</h2>
                      <div className="checkout-tools">
                        <details className="checkout-optional" ref={discountDetailsRef}>
                          <summary title={lockReason}>
                            <PosIcon name="edit" /> {t('discountTitle')}
                          </summary>
                          <div className="pos-popup-backdrop">
                            <ActiveDiscountForm
                              key={`${active.id}:${active.revision}:${active.discount?.id ?? 'new'}:${active.coupon?.code ?? 'no-coupon'}`}
                              selling={selling}
                              active={active}
                              onClose={() => {
                                if (discountDetailsRef.current)
                                  discountDetailsRef.current.open = false;
                              }}
                            />
                          </div>
                        </details>
                        <details className="checkout-optional" ref={noteDetailsRef}>
                          <summary title={lockReason}>
                            <PosIcon name="edit" /> {t('noteTitle')}
                          </summary>
                          <div className="pos-popup-backdrop">
                            <ActiveNoteForm
                              key={`${active.id}:note:${active.note ?? ''}`}
                              selling={selling}
                              active={active}
                              onClose={() => {
                                if (noteDetailsRef.current) noteDetailsRef.current.open = false;
                              }}
                            />
                          </div>
                        </details>
                        {/* Delivery orders (`delivery` switch); an order already
                        marked keeps the entry so it can be undone. */}
                        {data?.features?.delivery === true || active.delivery ? (
                          <details className="checkout-optional" ref={deliveryDetailsRef}>
                            <summary title={lockReason}>
                              <PosIcon name="box" /> {t('deliveryTitle')}
                            </summary>
                            <div className="pos-popup-backdrop">
                              <DeliveryForm
                                key={`${active.id}:delivery:${active.revision}`}
                                workspace={active}
                                disabled={editDisabled}
                                disabledReason={lockReason}
                                onSave={(input) =>
                                  command(active, (current) =>
                                    workspaces.setDelivery(current, input),
                                  )
                                }
                                onClear={() =>
                                  command(active, (current) => workspaces.clearDelivery(current))
                                }
                                onClose={() => {
                                  if (deliveryDetailsRef.current)
                                    deliveryDetailsRef.current.open = false;
                                }}
                              />
                            </div>
                          </details>
                        ) : null}
                      </div>
                    </div>
                    {active.totals ? (
                      <>
                        <div className="checkout-line">
                          <span>{t('subtotal')}</span>
                          <strong>
                            {formatMoney(active.totals.item_total, active.totals.currency)}
                          </strong>
                        </div>
                        <div className="checkout-line">
                          <span>
                            {t('discount')}{' '}
                            {active.coupon ? (
                              <small className="item-discount-source">{active.coupon.code}</small>
                            ) : null}
                          </span>
                          <strong>
                            {formatMoney(active.totals.discount_total, active.totals.currency)}
                          </strong>
                        </div>
                        {active.delivery ? (
                          <div className="checkout-line">
                            <span>
                              {t('deliveryFee')}{' '}
                              <small className="item-discount-source">
                                {active.delivery.deliverer
                                  ? t('deliveryBadgeNamed', { name: active.delivery.deliverer })
                                  : t('deliveryBadge')}
                              </small>
                            </span>
                            <strong>
                              {formatMoney(
                                active.totals.fee_total ?? active.delivery.fee,
                                active.totals.currency,
                              )}
                            </strong>
                          </div>
                        ) : null}
                        {activeTable.serviceCharge?.applies && !activeTable.serviceCharge.waived ? (
                          <div className="checkout-line">
                            <span>
                              {t('tableServiceCharge')}
                              {activeTable.serviceCharge.rate
                                ? ` (${activeTable.serviceCharge.rate.replace(/\.0+$/, '')}%)`
                                : ''}
                            </span>
                            <strong>
                              {formatMoney(
                                activeTable.serviceCharge.amount,
                                active.totals.currency,
                              )}
                            </strong>
                          </div>
                        ) : null}
                        <MinimumSpendLines
                          workspace={active}
                          currency={active.totals.currency}
                          canApprove={Boolean(data?.capabilities.includes('pos.approval.grant'))}
                          disabled={editDisabled}
                          onWaive={(waived, approvalId) =>
                            command(active, (current) =>
                              workspaces.setMinimumSpend(current, waived, approvalId),
                            )
                          }
                        />
                        {(active.totals.taxes ?? []).map((tax) => (
                          <div className="checkout-line" key={`${tax.rate}:${tax.label}`}>
                            <span>
                              {tax.label} ({rateLabel(tax.rate)})
                            </span>
                            <strong>
                              {formatMoney(tax.amount, active.totals?.currency ?? 'VND')}
                            </strong>
                          </div>
                        ))}
                        <div className="checkout-line checkout-total">
                          <span>{t('orderTotal')}</span>
                          <strong>
                            {formatMoney(active.totals.total, active.totals.currency)}
                          </strong>
                        </div>
                      </>
                    ) : (
                      <p>{t('totalsUnavailable')}</p>
                    )}
                  </section>
                  {active.note ? <p className="checkout-note-preview">{active.note}</p> : null}
                  {kitchenOn && data ? (
                    <KitchenHistory
                      workspace={active}
                      manual={
                        data.branches.find((row) => row.id === active.branch_id)
                          ?.kitchen_send_trigger === 'manual'
                      }
                      // Anyone serving a table sends its additions; a counter
                      // order is sent by the person holding it.
                      disabled={
                        activeTable.table
                          ? locked ||
                            busy ||
                            !['editing', 'parked'].includes(active.operational_status)
                          : editDisabled || !isEditor
                      }
                      disabledReason={lockReason}
                      onSend={() =>
                        run(() => command(active, (current) => workspaces.sendToKitchen(current)))
                      }
                    />
                  ) : null}
                  {callNumbers ? <PickupQueue branchId={active.branch_id} /> : null}
                  {active.reservation ? (
                    <ReservationDepositNote
                      workspace={active}
                      disabled={
                        locked || busy || !isEditor || active.operational_status !== 'editing'
                      }
                      onApply={() =>
                        command(active, (current) => workspaces.applyDeposits(current))
                      }
                    />
                  ) : null}
                  {meal ? (
                    <MealBanner
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
                      command={(action) => command(active, action)}
                    />
                  ) : null}
                  <PaymentPanel {...activePaymentProps(selling, active)} />
                  <DisplayPinControl
                    shiftId={data?.shift?.id ?? null}
                    ownsShift={Boolean(data?.shift && data.shift.owner_id === data.staff.id)}
                    enabled={contextFeature(data, 'customer_display')}
                    callBoard={callNumbers}
                    workspace={active}
                  />
                </div>
              ) : (
                <div className="checkout-section">
                  <h2>{t('customerTitle')}</h2>
                  <p className="muted">{t('checkoutChooseDraft')}</p>
                  <div className="checkout-totals">
                    <h2>{t('orderDetails')}</h2>
                    <p className="muted">{t('checkoutNoTotals')}</p>
                  </div>
                  <div className="checkout-totals">
                    <h2>{t('paymentTitle')}</h2>
                    <p className="muted">{t('checkoutNoPayment')}</p>
                  </div>
                </div>
              )}
            </aside>
          </div>
        </>
      )}
    </section>
  );
}

// The state of the selling session above the order: no shift, a changed
// currency, the last failure, the read-only lease and a parked or settled order.
export function SellingNotices({ selling }: { selling: SellingWorkspace }) {
  const { t } = useTranslation();
  const {
    data,
    selectionComplete,
    workspaces,
    locked,
    message,
    leaseWait,
    leaseSeconds,
    active,
    isEditor,
    activePhase,
    busy,
    strictLease,
    autoClaimFailed,
    command,
    run,
    hideWorkspace,
  } = selling;
  return (
    <>
      {!selectionComplete ? (
        <p className="workspace-hint" role="status">
          {t('workspaceChooseContext')}
        </p>
      ) : !data?.shift ? (
        <p className="workspace-hint" role="status">
          {t('workspaceNeedShift')}
        </p>
      ) : data.shift.owner_id !== data.staff.id ? (
        <p className="workspace-hint" role="status">
          {t('workspaceShiftOwned')}
        </p>
      ) : null}
      {data?.store.currency &&
      data.shift?.currency &&
      data.shift.currency !== data.store.currency ? (
        <p className="workspace-hint" role="status">
          {t('workspaceCurrencyChanged', {
            currency: data.shift.currency,
            current: data.store.currency,
          })}
        </p>
      ) : null}
      {message ? (
        <p className="error" role="alert">
          {message}
        </p>
      ) : null}
      {workspaces.query.isLoading ? <p role="status">{t('workspaceLoading')}</p> : null}
      {workspaces.query.isError ? (
        <p className="error" role="alert">
          {t(posFailureKey(workspaces.query.error))}
        </p>
      ) : null}
      {workspaces.selectedQuery.isError ? (
        <p className="error" role="alert">
          {t(posFailureKey(workspaces.selectedQuery.error))}
        </p>
      ) : null}
      {active &&
      !isEditor &&
      active.operational_status !== 'canceled' &&
      (strictLease || autoClaimFailed === active.id) ? (
        <div className="lease-notice" role="status">
          <span>{t('leaseReadOnly')}</span>
          {leaseWait?.workspaceId === active.id ? (
            <span className="lease-wait" role="status">
              {t(leaseSeconds > 0 ? 'leaseRetryIn' : 'leaseRetryReady', { seconds: leaseSeconds })}
            </span>
          ) : null}
          <details className="lease-help">
            <summary>{t('leaseWhy')}</summary>
            <p>{t('leaseExplanation')}</p>
            <p>{t('leaseInstruction')}</p>
          </details>
          <button
            type="button"
            disabled={locked || busy || (leaseWait?.workspaceId === active.id && leaseSeconds > 0)}
            onClick={() => void run(() => command(active, (current) => workspaces.claim(current)))}
          >
            {t('claimLease')}
          </button>
          {data?.capabilities.includes('pos.workspace.takeover') ? (
            <button
              type="button"
              disabled={locked || busy}
              onClick={() =>
                void run(() => command(active, (current) => workspaces.claim(current, true)))
              }
            >
              {t('takeoverLease')}
            </button>
          ) : null}
        </div>
      ) : null}
      {active && (activePhase === 'parked' || workspaceIsSettled(active)) ? (
        <div className={`lease-notice phase-notice phase-notice-${activePhase}`} role="status">
          <span>{t(`workspacePhaseHint_${activePhase}`)}</span>
          {activePhase === 'parked' ? null : (
            <button type="button" onClick={() => hideWorkspace(active.id)}>
              {t('closeView')}
            </button>
          )}
        </div>
      ) : null}
    </>
  );
}

type ActiveProps = { selling: SellingWorkspace; active: PosWorkspace };

// The time zone the branch of an order prints in.
export function orderTimeZone(selling: SellingWorkspace, active: PosWorkspace): string {
  return (
    selling.data?.branches.find((row) => row.id === active.branch_id)?.timezone ??
    selling.data?.store.timezone ??
    'Asia/Ho_Chi_Minh'
  );
}

// What the payment of the selected order needs, the same on the counter's
// checkout column and on the table payment screen.
export function activePaymentProps(selling: SellingWorkspace, active: PosWorkspace) {
  const { data, staffId, storeId, workspaces, locked, busy, isEditor, activeTable, meal, command } =
    selling;
  return {
    workspace: active,
    mealSponsorAmount: meal?.plan?.sponsor_amount ?? null,
    storedValueCards: data?.modules?.timed_billing === true,
    staffId,
    storeId,
    canCollect: Boolean(data?.capabilities.includes('pos.payment.collect')),
    canResolve: Boolean(data?.capabilities.includes('pos.payment.resolve')),
    canSellCredit: Boolean(data?.capabilities.includes('pos.credit.sell')),
    creditEnabled: contextFeature(data, 'credit'),
    einvoiceType: data?.einvoice_type ?? 'none',
    // Only an explicit switch skips the second person.
    quickCredit: data?.features?.quick_credit === true,
    // A table order without money yet moves to the shift of whoever
    // collects it, so the collector's own open drawer is enough.
    drawerOpen: Boolean(
      data?.shift &&
        (data.shift.id === active.shift_id || (activeTable.table !== null && !active.payments)) &&
        data.shift.owner_id === data.staff.id,
    ),
    disabled:
      locked ||
      busy ||
      !isEditor ||
      (active.operational_status !== 'editing' && active.operational_status !== 'completed'),
    command: (action: (current: PosWorkspace) => Promise<PosWorkspace>) => command(active, action),
    reserveTrace: (current: PosWorkspace) => workspaces.reserveTrace(current),
    ticketNames: {
      storeName: data?.store.name,
      branchName: data?.branches.find((row) => row.id === active.branch_id)?.name,
      registerName: data?.registers.find((row) => row.id === active.register_id)?.name,
      cashier: data?.staff.full_name || data?.staff.email,
    },
    timeZone: orderTimeZone(selling, active),
  };
}

// The pre-bill of the order, closed through the selling state's `prebillOpen`.
export function ActivePrebillDialog({ selling, active }: ActiveProps) {
  const { data, postpay, activeTable, staffId, setPrebillOpen } = selling;
  return (
    <PrebillDialog
      workspace={active}
      names={{
        storeName: data?.store.name,
        branchName: data?.branches.find((row) => row.id === active.branch_id)?.name,
        registerName: data?.registers.find((row) => row.id === active.register_id)?.name,
      }}
      timeZone={orderTimeZone(selling, active)}
      record={postpay && activeTable.table !== null}
      staffId={staffId}
      canApprove={Boolean(data?.capabilities.includes('pos.approval.grant'))}
      onClose={() => setPrebillOpen(false)}
    />
  );
}

// Moving, merging and splitting a table order, its service charge and the
// guests' request for the bill.
export function ActiveTableOrderBar({ selling, active }: ActiveProps) {
  const {
    data,
    selection,
    staffId,
    editDisabled,
    locked,
    busy,
    postpay,
    kitchenOn,
    workspaces,
    command,
    selectOrder,
  } = selling;
  return (
    <TableOrderBar
      workspace={active}
      branchId={selection.branchId}
      staffId={staffId}
      editDisabled={editDisabled}
      actionDisabled={locked || busy}
      canWaive={Boolean(data?.capabilities.includes('pos.discount.apply'))}
      canApprove={Boolean(data?.capabilities.includes('pos.approval.grant'))}
      postpay={postpay}
      onMove={(resourceId) =>
        command(active, (current) => workspaces.moveTable(current, resourceId))
      }
      onMerge={async (targetId) => {
        const target = await command(active, (current) => workspaces.mergeTable(current, targetId));
        selectOrder(target.id);
      }}
      onSplit={(input) =>
        command(active, async (current) => (await workspaces.splitTable(current, input)).workspace)
      }
      onSplitBySeat={
        kitchenOn
          ? (shared) =>
              command(
                active,
                async (current) => (await workspaces.splitBySeat(current, shared)).workspace,
              )
          : undefined
      }
      onServiceCharge={(waived) =>
        command(active, (current) => workspaces.setServiceCharge(current, waived))
      }
      onRequestPayment={() => command(active, (current) => workspaces.requestPayment(current))}
      onResolvePayment={(status) =>
        command(active, (current) => workspaces.resolvePaymentRequest(current, status))
      }
      onPrebillChanged={() => void workspaces.refresh()}
    />
  );
}

// The buffet tickets of a table order and the tier its next dishes go on.
export function ActiveBuffetPicker({ selling, active }: ActiveProps) {
  const { selection, placement, setPlacement, canAppend, busy, workspaces, command } = selling;
  return (
    <BuffetTierPicker
      workspace={active}
      branchId={selection.branchId}
      placement={placement}
      onPlacement={setPlacement}
      disabled={!canAppend || busy}
      onAddCover={(tierId, guests) =>
        command(active, (current) => workspaces.addBuffetCover(current, tierId, guests))
      }
    />
  );
}

// Taking back what the kitchen has of a line, with a reason.
export function ActiveVoidDialog({ selling, active, line }: ActiveProps & { line: PosLineItem }) {
  const { data, workspaces, command, setVoiding } = selling;
  return (
    <VoidItemDialog
      workspace={active}
      line={line}
      reasons={voidReasons(data?.branches.find((row) => row.id === active.branch_id))}
      canVoid={Boolean(data?.capabilities.includes('pos.kitchen.void'))}
      onVoid={(input) =>
        command(active, (current) =>
          workspaces.voidSent(current, line.sale_line_id as string, input),
        )
      }
      onClose={() => setVoiding(null)}
    />
  );
}

export function ActiveCustomerPanel({ selling, active }: ActiveProps) {
  const { data, selection, storeId, editDisabled, lockReason, workspaces, command } = selling;
  return (
    <CustomerPanel
      workspace={active}
      branchId={selection.branchId}
      storeId={storeId}
      canCreate={Boolean(data?.capabilities.includes('pos.customer.write'))}
      disabled={editDisabled}
      disabledReason={lockReason}
      onAssign={(profileId) =>
        command(active, (current) => workspaces.assignCustomer(current, profileId))
      }
      onClear={() => command(active, (current) => workspaces.clearCustomer(current))}
    />
  );
}

export function ActiveDiscountForm({
  selling,
  active,
  onClose,
}: ActiveProps & { onClose: () => void }) {
  const { data, editDisabled, lockReason, workspaces, command } = selling;
  return (
    <DiscountForm
      workspace={active}
      canApply={Boolean(data?.capabilities.includes('pos.discount.apply'))}
      disabled={editDisabled}
      disabledReason={lockReason}
      onApply={(input) => command(active, (current) => workspaces.discount(current, input))}
      onClear={(approvalId) =>
        command(active, (current) => workspaces.clearDiscount(current, approvalId))
      }
      onApplyCoupon={(code) => command(active, (current) => workspaces.applyCoupon(current, code))}
      onClearCoupon={() => command(active, (current) => workspaces.clearCoupon(current))}
      onClose={onClose}
    />
  );
}

export function ActiveNoteForm({
  selling,
  active,
  onClose,
}: ActiveProps & { onClose: () => void }) {
  const { editDisabled, lockReason, workspaces, command } = selling;
  return (
    <NoteForm
      workspace={active}
      disabled={editDisabled}
      disabledReason={lockReason}
      onSave={(note) => command(active, (current) => workspaces.updateNote(current, note))}
      onClose={onClose}
    />
  );
}

// The counter's own catalogue: the menu tiles of a branch selling from its
// menu, else the product search with the scanner.
export function SellingCatalog({ selling }: { selling: SellingWorkspace }) {
  const {
    data,
    selection,
    storeId,
    workspaces,
    channelUnavailable,
    scanNotice,
    active,
    editable,
    quickAddDisabled,
    lockReason,
    menuSurface,
    soldOut,
    command,
    quickAdd,
    calibration,
    tableAddExtra,
    enqueueScan,
  } = selling;
  return menuSurface ? (
    <MenuGrid
      branchId={selection.branchId}
      addDisabled={quickAddDisabled}
      addDisabledReason={lockReason}
      drinksFirst={isTab(active)}
      canSetSoldOut={Boolean(
        data?.capabilities.includes('pos.menu.sold_out') ||
          data?.capabilities.includes('pos.menu.manage'),
      )}
      onAdd={
        active
          ? (variantId, extra) =>
              command(active, (current) =>
                workspaces.addItem(current, variantId, 1, tableAddExtra(extra)),
              )
          : undefined
      }
    />
  ) : (
    <CatalogSearch
      storeId={storeId}
      branchId={selection.branchId}
      workspaceId={active?.id ?? null}
      addDisabled={quickAddDisabled}
      addDisabledReason={lockReason}
      scanNotice={scanNotice}
      soldOutVariantIds={soldOut}
      onScan={editable && !channelUnavailable ? (code) => enqueueScan.current(code) : undefined}
      scanTerminator={calibration.terminator}
      onAdd={active ? (variantId) => quickAdd(active, variantId) : undefined}
      onAddForm={
        active
          ? (variantId, quantity, extra) =>
              command(active, (current) => workspaces.addItem(current, variantId, quantity, extra))
          : undefined
      }
    />
  );
}
