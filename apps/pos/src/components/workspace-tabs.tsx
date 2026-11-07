import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useInvoiceNumbers } from '../hooks/use-invoice-numbers';
import { useWorkspaces } from '../hooks/use-workspaces';
import { commandQueue } from '../lib/command-queue';
import { formatMoney } from '../lib/money';
import { type PosWorkspace, writesLocked } from '../lib/pos-context';
import { leaseConflict, posFailureKey } from '../lib/request-failure';
import { readLayout } from '../lib/workspace-storage';
import { CatalogSearch } from './catalog-search';
import { CustomerPanel } from './customer-panel';
import { DiscountForm } from './discount-form';
import { NoteForm } from './note-form';
import { OrderLines } from './order-lines';
import { PaymentPanel } from './payment-panel';
import { PosIcon } from './pos-icon';
import { usePosSelection } from './pos-selection';

export function WorkspaceTabs() {
  const { t } = useTranslation();
  const { selection, context, selectionComplete } = usePosSelection();
  const data = context.data;
  const staffId = data?.staff.id ?? null;
  const storeId = data?.store.id ?? null;
  const [activeId, setActiveId] = useState<string | null>(null);
  const activeIdRef = useRef(activeId);
  activeIdRef.current = activeId;
  const workspaces = useWorkspaces(
    storeId,
    staffId,
    Boolean(data?.shift),
    selection.branchId,
    selection.registerId,
    activeId,
  );
  const locked = writesLocked(data, selection);
  const [query, setQuery] = useState('');
  const [message, setMessage] = useState('');
  const [busy, setBusy] = useState(false);
  const [leaseWait, setLeaseWait] = useState<{ workspaceId: string; until: number } | null>(null);
  const [leaseSeconds, setLeaseSeconds] = useState(0);
  const [hidden, setHidden] = useState<string[]>([]);
  const scope = `${staffId}:${storeId}:${selection.branchId}:${selection.registerId}`;
  const scopeRef = useRef(scope);
  scopeRef.current = scope;
  useEffect(() => {
    setActiveId(null);
    setHidden([]);
    setQuery('');
    if (!staffId || !storeId || !selection.branchId) return;
    const saved = readLayout(staffId, storeId);
    if (saved?.branchId === selection.branchId && saved.registerId === selection.registerId) {
      setActiveId(saved.activeWorkspaceId ?? null);
      setHidden(saved.closedWorkspaceIds ?? []);
    }
  }, [staffId, storeId, selection.branchId, selection.registerId]);
  const rows = (workspaces.query.data?.data ?? []).filter(
    (workspace) =>
      !hidden.includes(workspace.id) &&
      workspace.branch_id === selection.branchId &&
      workspace.register_id === selection.registerId,
  );
  const pinned = workspaces.selectedQuery.isError ? undefined : workspaces.selectedQuery.data?.data;
  if (
    pinned &&
    pinned.id === activeId &&
    pinned.branch_id === selection.branchId &&
    pinned.register_id === selection.registerId &&
    !hidden.includes(pinned.id) &&
    !rows.some((row) => row.id === pinned.id)
  )
    rows.unshift(pinned);
  const matching = rows.filter((workspace) => workspace.order_id.includes(query.trim()));
  const tabNumbers = useInvoiceNumbers(
    staffId,
    storeId,
    selection.branchId,
    selection.registerId,
    rows.map((workspace) => workspace.id).reverse(),
    hidden,
  );
  matching.sort((left, right) => tabNumbers[left.id] - tabNumbers[right.id]);
  const visible = matching.slice(0, 8);
  const selectedMatch = matching.find((workspace) => workspace.id === activeId);
  if (selectedMatch && !visible.some((workspace) => workspace.id === selectedMatch.id)) {
    visible[7] = selectedMatch;
  }
  const overflow = rows.length - visible.length;
  const activeSummary = rows.find((workspace) => workspace.id === activeId) ?? visible[0] ?? null;
  const active = pinned && activeSummary && pinned.id === activeSummary.id ? pinned : activeSummary;
  const isEditor = active ? workspaces.owns(active) : false;
  const tablist = useRef<HTMLDivElement>(null);
  const discountDetailsRef = useRef<HTMLDetailsElement>(null);
  const noteDetailsRef = useRef<HTMLDetailsElement>(null);
  const activeTabId = active?.id;
  useEffect(() => {
    if (!leaseWait || leaseWait.workspaceId !== activeTabId) {
      setLeaseSeconds(0);
      return;
    }
    const update = () =>
      setLeaseSeconds(Math.max(0, Math.ceil((leaseWait.until - Date.now()) / 1000)));
    update();
    const timer = window.setInterval(update, 1000);
    return () => window.clearInterval(timer);
  }, [leaseWait, activeTabId]);
  useEffect(() => {
    if (!activeTabId) return;
    const list = tablist.current;
    const selected = list?.querySelector<HTMLElement>('[aria-selected="true"]');
    if (!list || !selected) return;
    // Scroll only the tab strip, never jump the cashier's document position.
    const left = selected.offsetLeft - list.offsetLeft;
    if (left < list.scrollLeft) list.scrollLeft = left;
    else if (left + selected.offsetWidth > list.scrollLeft + list.clientWidth)
      list.scrollLeft = left + selected.offsetWidth - list.clientWidth;
  }, [activeTabId]);
  const heartbeat = useRef(workspaces.heartbeat);
  heartbeat.current = workspaces.heartbeat;
  const claim = useRef(workspaces.claim);
  claim.current = workspaces.claim;
  const heartbeatWorkspace = useRef(active);
  heartbeatWorkspace.current = active;
  const leaseWorkspaceId = active?.id;
  const leaseGeneration = active?.lease_generation;
  const leaseStatus = active?.operational_status;

  useEffect(() => {
    if (!leaseWorkspaceId || !isEditor || locked || leaseStatus === 'canceled') return;
    const renew = () => {
      const workspace = heartbeatWorkspace.current;
      if (workspace?.id !== leaseWorkspaceId || workspace.lease_generation !== leaseGeneration)
        return;
      void heartbeat.current(workspace).catch(async (error: unknown) => {
        if (
          heartbeatWorkspace.current?.id !== leaseWorkspaceId ||
          heartbeatWorkspace.current.lease_generation !== leaseGeneration
        )
          return;
        // A background tab lets its lease lapse. When nobody else claimed it in the
        // meantime, take it back instead of dropping the cashier to read-only.
        if (leaseConflict(error)?.reason === 'lease_stale') {
          try {
            await claim.current(workspace);
            return;
          } catch {
            // Someone else holds the lease now; show the read-only notice below.
          }
        }
        if (heartbeatWorkspace.current?.id === leaseWorkspaceId) setMessage(t('leaseLost'));
      });
    };
    renew();
    const timer = window.setInterval(renew, 40_000);
    return () => window.clearInterval(timer);
  }, [leaseWorkspaceId, leaseGeneration, leaseStatus, isEditor, locked, t]);

  async function run(action: () => Promise<PosWorkspace | undefined>) {
    setBusy(true);
    setMessage('');
    const started = scopeRef.current;
    const hadActiveWorkspace = Boolean(active);
    try {
      const workspace = await action();
      if (started === scopeRef.current) setLeaseWait(null);
      if (workspace && !hadActiveWorkspace && started === scopeRef.current)
        setActiveId((current) => current ?? workspace.id);
      return workspace;
    } catch (error) {
      if (started === scopeRef.current) {
        const conflict = leaseConflict(error);
        setMessage(
          t(
            conflict?.reason === 'lease_busy'
              ? 'leaseBusy'
              : conflict?.reason === 'lease_stale'
                ? 'leaseStale'
                : posFailureKey(error),
          ),
        );
        if (conflict?.reason === 'lease_busy' && active)
          setLeaseWait({ workspaceId: active.id, until: Date.now() + conflict.seconds * 1000 });
      }
    } finally {
      setBusy(false);
    }
  }

  return (
    <section className="draft-workspace" aria-label={t('draftList')}>
      <div className="draft-toolbar">
        <button
          type="button"
          disabled={
            busy ||
            locked ||
            !selectionComplete ||
            !data?.shift ||
            data.shift.owner_id !== data.staff.id
          }
          onClick={() => {
            if (!selectionComplete) return;
            const started = scopeRef.current;
            const selectedAtStart = activeIdRef.current;
            void run(() => workspaces.create(selection.registerId)).then((created) => {
              if (
                created &&
                started === scopeRef.current &&
                selectedAtStart === activeIdRef.current
              ) {
                setActiveId(created.id);
                workspaces.rememberView(created.id, workspaces.page);
              }
            });
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
          {visible.map((workspace) => (
            <button
              key={workspace.id}
              type="button"
              role="tab"
              aria-label={t('invoiceTab', { number: tabNumbers[workspace.id] })}
              data-workspace-id={workspace.id}
              title={t(
                `orderStatus_${workspace.id === active?.id ? active.operational_status : workspace.operational_status}`,
                { defaultValue: workspace.operational_status },
              )}
              aria-selected={workspace.id === active?.id}
              onClick={() => {
                setActiveId(workspace.id);
                workspaces.rememberView(workspace.id, workspaces.page);
              }}
            >
              <strong>{t('invoiceTab', { number: tabNumbers[workspace.id] })}</strong>
            </button>
          ))}
        </div>
      </div>
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
      {active && !isEditor && active.operational_status !== 'canceled' ? (
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
            onClick={() => void run(() => workspaces.claim(active))}
          >
            {t('claimLease')}
          </button>
          {data?.capabilities.includes('pos.workspace.takeover') ? (
            <button
              type="button"
              disabled={locked || busy}
              onClick={() => void run(() => workspaces.claim(active, true))}
            >
              {t('takeoverLease')}
            </button>
          ) : null}
        </div>
      ) : null}
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
              document.getElementById(id)?.scrollIntoView({ block: 'nearest', inline: 'start' });
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
          <CatalogSearch
            key={`${storeId}:${selection.branchId}`}
            storeId={storeId}
            branchId={selection.branchId}
            workspaceId={active?.id ?? null}
            addDisabled={
              busy || locked || !active || !isEditor || active.operational_status !== 'editing'
            }
            onAdd={
              active
                ? (variantId) =>
                    void run(() => workspaces.addItem(active, variantId, 1, { merge: true }))
                : undefined
            }
            onAddForm={
              active
                ? (variantId, quantity, extra) =>
                    workspaces.addItem(active, variantId, quantity, extra)
                : undefined
            }
          />
        </section>
        <section
          className="selling-panel basket-panel"
          id="pos-basket"
          aria-label={t('basketTitle')}
        >
          <div className="basket-heading">
            <h2>{t('basketTitle')}</h2>
            {active ? (
              <span>
                {active.line_items?.length ?? 0} {t('basketLines')}
              </span>
            ) : null}
            {active ? (
              <div className="row basket-actions">
                <button
                  type="button"
                  disabled={busy || locked || !isEditor || active.operational_status === 'canceled'}
                  onClick={() =>
                    void run(() =>
                      workspaces.change(
                        active,
                        active.operational_status === 'parked' ? 'reopen' : 'park',
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
                          void run(() => workspaces.change(active, 'cancel'));
                      }}
                    >
                      {t('cancelDraft')}
                    </button>
                    <button
                      type="button"
                      onClick={() => {
                        setHidden((current) => [...current, active.id]);
                        workspaces.rememberClosed([...hidden, active.id]);
                        setActiveId(null);
                        workspaces.rememberView(null, workspaces.page);
                        if (staffId && storeId) {
                          workspaces.remember(
                            workspaces.rememberedIds().filter((id) => id !== active.id),
                          );
                        }
                      }}
                    >
                      {t('closeView')}
                    </button>
                  </div>
                </details>
              </div>
            ) : null}
          </div>
          {active ? (
            <article className="draft-detail">
              <OrderLines
                key={active.id}
                workspace={active}
                disabled={busy || locked || !isEditor || active.operational_status !== 'editing'}
                canApplyDiscount={Boolean(data?.capabilities.includes('pos.discount.apply'))}
                canOverridePrice={Boolean(data?.capabilities.includes('pos.price.override'))}
                onUpdate={(lineId, input) => workspaces.updateItem(active, lineId, input)}
                onRemove={(lineId) => workspaces.removeItem(active, lineId)}
                onLineDiscount={(saleLineId, input) =>
                  workspaces.lineDiscount(active, saleLineId, input)
                }
                onClearLineDiscount={(saleLineId, approvalId) =>
                  workspaces.clearLineDiscount(active, saleLineId, approvalId)
                }
                onPriceOverride={(saleLineId, input) =>
                  workspaces.priceOverride(active, saleLineId, input)
                }
              />
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
              <CustomerPanel
                key={`${active.id}:${active.customer?.id ?? active.customer?.customer_id ?? 'walk-in'}`}
                workspace={active}
                branchId={selection.branchId}
                storeId={storeId}
                canCreate={Boolean(data?.capabilities.includes('pos.customer.write'))}
                disabled={locked || !isEditor || active.operational_status !== 'editing'}
                onAssign={(profileId) => workspaces.assignCustomer(active, profileId)}
                onClear={() => workspaces.clearCustomer(active)}
              />
              <section className="checkout-totals" aria-label={t('orderDetails')}>
                <div className="checkout-totals-header">
                  <h2>{t('orderDetails')}</h2>
                  <div className="checkout-tools">
                    <details className="checkout-optional" ref={discountDetailsRef}>
                      <summary>
                        <PosIcon name="edit" /> {t('discountTitle')}
                      </summary>
                      <div className="pos-popup-backdrop">
                        <DiscountForm
                          key={`${active.id}:${active.revision}:${active.discount?.id ?? 'new'}:${active.coupon?.code ?? 'no-coupon'}`}
                          workspace={active}
                          canApply={Boolean(data?.capabilities.includes('pos.discount.apply'))}
                          disabled={locked || !isEditor || active.operational_status !== 'editing'}
                          onApply={(input) => workspaces.discount(active, input)}
                          onClear={(approvalId) => workspaces.clearDiscount(active, approvalId)}
                          onApplyCoupon={(code) => workspaces.applyCoupon(active, code)}
                          onClearCoupon={() => workspaces.clearCoupon(active)}
                          onClose={() => {
                            if (discountDetailsRef.current) discountDetailsRef.current.open = false;
                          }}
                        />
                      </div>
                    </details>
                    <details className="checkout-optional" ref={noteDetailsRef}>
                      <summary>
                        <PosIcon name="edit" /> {t('noteTitle')}
                      </summary>
                      <div className="pos-popup-backdrop">
                        <NoteForm
                          key={`${active.id}:note:${active.note ?? ''}`}
                          workspace={active}
                          disabled={locked || !isEditor || active.operational_status !== 'editing'}
                          onSave={(note) => workspaces.updateNote(active, note)}
                          onClose={() => {
                            if (noteDetailsRef.current) noteDetailsRef.current.open = false;
                          }}
                        />
                      </div>
                    </details>
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
                    <div className="checkout-line checkout-total">
                      <span>{t('orderTotal')}</span>
                      <strong>{formatMoney(active.totals.total, active.totals.currency)}</strong>
                    </div>
                  </>
                ) : (
                  <p>{t('totalsUnavailable')}</p>
                )}
              </section>
              {active.note ? <p className="checkout-note-preview">{active.note}</p> : null}
              <PaymentPanel
                workspace={active}
                staffId={staffId}
                storeId={storeId}
                canCollect={Boolean(data?.capabilities.includes('pos.payment.collect'))}
                canResolve={Boolean(data?.capabilities.includes('pos.payment.resolve'))}
                disabled={
                  locked ||
                  !isEditor ||
                  (active.operational_status !== 'editing' &&
                    active.operational_status !== 'completed')
                }
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
    </section>
  );
}
