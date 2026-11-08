import { Link } from '@tanstack/react-router';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { FeatureOffNote } from '../components/feature-off-note';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { ReceiptPrintButton } from '../components/receipt-print-dialog';
import { SoldTrace } from '../components/sold-trace';
import { type OrderFilters, useOrder, useOrders, useReconcileHandover } from '../hooks/use-returns';
import { formatMoney } from '../lib/money';
import { contextFeature } from '../lib/pos-features';
import { formatInstant } from '../lib/receivables';
import { posFailureKey } from '../lib/request-failure';
import {
  canProcessReturns,
  canResolve,
  compareMoney,
  dateRangeInvalid,
  describeReturnFailure,
  type PosOrderDetail,
  saleQuantityLabel,
  sumMoney,
} from '../lib/returns';

const EMPTY: OrderFilters = {
  number: '',
  from: '',
  to: '',
  registerId: '',
  cashierId: '',
  status: 'all',
  page: 1,
};

export function OrdersPage() {
  const { context, selection } = usePosSelection();
  const scope = `${context.data?.staff.id}:${context.data?.store.id}:${selection.branchId}`;
  return <Orders key={scope} />;
}

function Orders() {
  const { t, i18n } = useTranslation();
  const { context, selection } = usePosSelection();
  const branchId = selection.branchId;
  const [draft, setDraft] = useState<OrderFilters>(EMPTY);
  const [filters, setFilters] = useState<OrderFilters>(EMPTY);
  const [openId, setOpenId] = useState<string | null>(null);
  const orders = useOrders(branchId, filters, Boolean(context.data));
  const detail = useOrder(openId ? { orderId: openId } : null, branchId, Boolean(openId));
  const registers = context.data?.registers ?? [];
  const meta = orders.data?.meta;
  // Cashiers seen in results so far; the server filters by the chosen one.
  const [cashiers, setCashiers] = useState<Record<string, string>>({});
  const seen = orders.data?.data.filter((row) => cashiers[row.cashier_id] !== row.cashier) ?? [];
  if (seen.length) {
    setCashiers({
      ...cashiers,
      ...Object.fromEntries(seen.map((row) => [row.cashier_id, row.cashier])),
    });
  }
  const rangeInvalid = dateRangeInvalid(draft.from, draft.to);
  const show = (next: OrderFilters) => {
    setOpenId(null);
    setFilters(next);
  };

  return (
    <PosPage title={t('ordersTitle')} description={t('ordersHint')}>
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !branchId ? (
        <PageState title={t('chooseBranch')} description={t('pageChooseBranchHint')} />
      ) : (
        <div className="orders-layout">
          <section className="page-card" aria-label={t('ordersTitle')}>
            <form
              className="orders-filters"
              aria-label={t('ordersFilters')}
              onSubmit={(event) => {
                event.preventDefault();
                if (rangeInvalid) return;
                show({ ...draft, page: 1 });
              }}
            >
              <label>
                {t('ordersNumber')}
                <input
                  type="search"
                  value={draft.number}
                  maxLength={64}
                  onChange={(event) => setDraft({ ...draft, number: event.target.value })}
                />
              </label>
              <label>
                {t('ordersFrom')}
                <input
                  type="date"
                  value={draft.from}
                  onChange={(event) => setDraft({ ...draft, from: event.target.value })}
                />
              </label>
              <label>
                {t('ordersTo')}
                <input
                  type="date"
                  value={draft.to}
                  aria-invalid={rangeInvalid}
                  aria-describedby={rangeInvalid ? 'orders-range-error' : undefined}
                  onChange={(event) => setDraft({ ...draft, to: event.target.value })}
                />
              </label>
              {registers.length ? (
                <label>
                  {t('ordersRegister')}
                  <select
                    value={draft.registerId}
                    onChange={(event) => setDraft({ ...draft, registerId: event.target.value })}
                  >
                    <option value="">{t('ordersAll')}</option>
                    {registers.map((register) => (
                      <option key={register.id} value={register.id}>
                        {register.name}
                      </option>
                    ))}
                  </select>
                </label>
              ) : null}
              {Object.keys(cashiers).length ? (
                <label>
                  {t('ordersCashier')}
                  <select
                    value={draft.cashierId}
                    onChange={(event) => setDraft({ ...draft, cashierId: event.target.value })}
                  >
                    <option value="">{t('ordersAll')}</option>
                    {Object.entries(cashiers).map(([id, name]) => (
                      <option key={id} value={id}>
                        {name}
                      </option>
                    ))}
                  </select>
                </label>
              ) : null}
              <label>
                {t('ordersStatus')}
                <select
                  value={draft.status}
                  onChange={(event) =>
                    setDraft({ ...draft, status: event.target.value as OrderFilters['status'] })
                  }
                >
                  {(['all', 'debt', 'returned', 'refund_pending'] as const).map((status) => (
                    <option key={status} value={status}>
                      {t(`ordersStatus_${status}`)}
                    </option>
                  ))}
                </select>
              </label>
              <button type="submit" disabled={rangeInvalid}>
                {t('ordersSearch')}
              </button>
              {rangeInvalid ? (
                <p id="orders-range-error" className="error" role="alert">
                  {t('ordersRangeInvalid')}
                </p>
              ) : null}
            </form>
            {orders.isLoading ? <PageState kind="loading" title={t('waiting')} /> : null}
            {orders.isError ? (
              <PageState kind="error" title={t(posFailureKey(orders.error))} />
            ) : null}
            {orders.isSuccess && orders.data.data.length === 0 ? (
              <PageState kind="empty" title={t('ordersEmpty')} />
            ) : null}
            <ul className="record-list" aria-label={t('ordersList')}>
              {(orders.data?.data ?? []).map((order) => (
                <li key={order.id} className="order-row">
                  <button
                    type="button"
                    className="order-row-button"
                    aria-expanded={openId === order.id}
                    aria-controls="order-detail"
                    onClick={() => setOpenId(openId === order.id ? null : order.id)}
                  >
                    <span className="record-copy">
                      <strong>{order.number}</strong>
                      <small>
                        {formatInstant(order.placed_at, i18n.language)} · {order.register ?? '—'} ·{' '}
                        {order.cashier}
                        {order.customer?.name ? ` · ${order.customer.name}` : ''}
                      </small>
                    </span>
                    <span className="order-row-tags">
                      {order.debt && compareMoney(order.debt, '0') > 0 ? (
                        <span className="status-tag" data-warning>
                          {t('ordersDebt', { amount: formatMoney(order.debt, order.currency) })}
                        </span>
                      ) : null}
                      {order.returned ? (
                        <span className="status-tag">{t('ordersReturned')}</span>
                      ) : null}
                      {order.refund_pending ? (
                        <span className="status-tag" data-warning>
                          {t('ordersRefundPending')}
                        </span>
                      ) : null}
                    </span>
                    <strong>{formatMoney(order.total, order.currency)}</strong>
                  </button>
                </li>
              ))}
            </ul>
            {meta && meta.pages > 1 ? (
              <nav className="row" aria-label={t('ordersPages')}>
                <button
                  type="button"
                  disabled={filters.page <= 1}
                  onClick={() => show({ ...filters, page: filters.page - 1 })}
                >
                  {t('previousPage')}
                </button>
                <span>{t('ordersPageOf', { page: filters.page, pages: meta.pages })}</span>
                <button
                  type="button"
                  disabled={filters.page >= meta.pages}
                  onClick={() => show({ ...filters, page: filters.page + 1 })}
                >
                  {t('nextPage')}
                </button>
              </nav>
            ) : null}
          </section>
          {openId ? (
            <section id="order-detail" className="page-card" aria-label={t('orderDetail')}>
              {detail.isLoading ? <PageState kind="loading" title={t('waiting')} /> : null}
              {detail.isError ? (
                <PageState kind="error" title={t(posFailureKey(detail.error))} />
              ) : null}
              {detail.data ? (
                <OrderDetail
                  order={detail.data}
                  canReturn={canProcessReturns(context.data?.capabilities)}
                />
              ) : null}
            </section>
          ) : null}
        </div>
      )}
    </PosPage>
  );
}

export function OrderDetail({ order, canReturn }: { order: PosOrderDetail; canReturn: boolean }) {
  const { t, i18n } = useTranslation();
  const { context } = usePosSelection();
  const reconcile = useReconcileHandover();
  const [notice, setNotice] = useState('');
  const money = (value: string | null | undefined) => formatMoney(value, order.currency);
  const returnable = order.lines.some((line) => line.returnable_quantity > 0);
  const returnsOn = contextFeature(context.data, 'returns');
  const openGaps = order.stock.discrepancies.filter((gap) => gap.status === 'open');
  return (
    <div className="order-detail">
      <div className="pos-popup-header">
        <h2>{t('orderDetailTitle', { number: order.number })}</h2>
        <ReceiptPrintButton sourceId={order.workspace_id} label={t('receiptOpen')} />
        {canReturn && returnable && returnsOn ? (
          <Link className="button-link" to="/returns" search={{ orderId: order.id }}>
            {t('ordersStartReturn')}
          </Link>
        ) : null}
        {canReturn && returnable && !returnsOn ? <FeatureOffNote feature="returns" /> : null}
      </div>
      <dl className="order-summary">
        <div>
          <dt>{t('orderOriginalTotal')}</dt>
          <dd>{money(order.totals.original_total)}</dd>
        </div>
        <div>
          <dt>{t('orderPaid')}</dt>
          <dd>{money(order.paid)}</dd>
        </div>
        <div>
          <dt>{t('orderEntitlementUsed')}</dt>
          <dd>{money(order.entitlement.used)}</dd>
        </div>
        <div>
          <dt>{t('orderEntitlementReserved')}</dt>
          <dd>{money(order.entitlement.reserved)}</dd>
        </div>
        <div>
          <dt>{t('orderCreditNotes')}</dt>
          <dd>{money(order.entitlement.credit_notes)}</dd>
        </div>
        <div>
          <dt>{t('orderRefunded')}</dt>
          <dd>{money(sumMoney(order.receipts.map((receipt) => receipt.refunded)))}</dd>
        </div>
        {order.credit ? (
          <div>
            <dt>{t('orderDebtBalance')}</dt>
            <dd>{money(order.credit.balance)}</dd>
          </div>
        ) : null}
      </dl>
      <h3>{t('orderLines')}</h3>
      <table className="order-lines-table">
        <thead>
          <tr>
            <th scope="col">{t('orderLineItem')}</th>
            <th scope="col">{t('orderLineSold')}</th>
            <th scope="col">{t('orderLineReturned')}</th>
            <th scope="col">{t('orderLineReturnable')}</th>
            <th scope="col">{t('orderLineValue')}</th>
          </tr>
        </thead>
        <tbody>
          {order.lines.map((line) => (
            <tr key={line.sale_line_id}>
              <th scope="row">
                {line.name}
                {line.trace ? (
                  <SoldTrace trace={line.trace} />
                ) : line.lot_code ? (
                  <small> · {line.lot_code}</small>
                ) : null}
              </th>
              <td>{saleQuantityLabel(line)}</td>
              <td>
                {t('orderLineReturnedValue', {
                  posted: line.posted_quantity,
                  held: line.returned_quantity - line.posted_quantity,
                  unit: line.base_unit,
                })}
              </td>
              <td>
                {line.handed_over
                  ? `${line.returnable_quantity} ${line.base_unit}`
                  : t('orderNotHandedOver')}
              </td>
              <td>{money(line.original.total)}</td>
            </tr>
          ))}
        </tbody>
      </table>
      {order.returns.length ? (
        <>
          <h3>{t('orderReturns')}</h3>
          <ul className="record-list" aria-label={t('orderReturns')}>
            {order.returns.map((row) => (
              <li key={row.id}>
                <Link to="/returns" search={{ returnId: row.id }}>
                  {row.return_number}
                </Link>
                <span className="status-tag" data-warning={row.status === 'pending_approval'}>
                  {t(`returnStatus_${row.status}`)}
                </span>
                <span>{money(row.entitlement_total)}</span>
                <small>
                  {t('orderReturnRefunds', {
                    refunded: money(row.refunded),
                    requested: money(row.refund_requested),
                  })}
                </small>
              </li>
            ))}
          </ul>
        </>
      ) : null}
      <h3>{t('orderReceipts')}</h3>
      <ul className="record-list">
        {order.receipts.map((receipt) => (
          <li key={receipt.allocation_id}>
            <span>
              {t(receipt.kind === 'cash' ? 'orderReceiptCash' : 'orderReceiptBank')}
              {receipt.collection ? ` · ${t('orderCollection')}` : ''}
              {receipt.reference ? ` · ${receipt.reference}` : ''}
            </span>
            <span>{money(receipt.amount)}</span>
            <small>
              {t('orderReceiptRefunded', {
                refunded: money(receipt.refunded),
                reserved: money(receipt.refund_reserved),
              })}
            </small>
          </li>
        ))}
      </ul>
      {order.stock.discrepancies.length ? (
        <div className="attention-box" role="note">
          <strong>{t('orderStockAttention')}</strong>
          <ul>
            {order.stock.discrepancies.map((gap) => (
              <li key={gap.id}>
                {t('orderStockGap', { name: gap.name, needed: gap.needed, onHand: gap.on_hand })} ·{' '}
                {t(`stockGapStatus_${gap.status}`)}
              </li>
            ))}
          </ul>
          {openGaps.length && canResolve(context.data?.capabilities) ? (
            <p className="row">
              <button
                type="button"
                disabled={reconcile.isPending}
                onClick={() => {
                  setNotice('');
                  reconcile.mutate(order.id, {
                    onSuccess: (result) =>
                      setNotice(
                        t(
                          result.stock_discrepancies.length
                            ? 'orderReconcileStillShort'
                            : 'orderReconcileDone',
                        ),
                      ),
                    onError: (failure) => setNotice(describeReturnFailure(failure, t)),
                  });
                }}
              >
                {t('orderReconcile')}
              </button>
              <small className="muted">{t('orderReconcileHint')}</small>
            </p>
          ) : null}
          {notice ? <p role="status">{notice}</p> : null}
        </div>
      ) : null}
      <p className="muted">
        {t('orderStockEffects', {
          restocked: order.stock.restocked_quantity,
          damaged: order.stock.damaged_quantity,
        })}
      </p>
      <h3>{t('orderTimeline')}</h3>
      <ol className="order-timeline">
        {order.timeline.map((event) => (
          <li key={event.id}>
            <time dateTime={event.at}>{formatInstant(event.at, i18n.language)}</time>{' '}
            {t(`timeline_${event.kind}`, { defaultValue: event.kind })}
            {event.reference ? ` ${event.reference}` : ''}
            {event.amount ? ` · ${money(event.amount)}` : ''}
          </li>
        ))}
      </ol>
    </div>
  );
}
