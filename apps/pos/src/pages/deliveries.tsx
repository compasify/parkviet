import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { FeatureOffNote } from '../components/feature-off-note';
import { OrderSourceTag } from '../components/order-source-picker';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { ReceiptPrintButton } from '../components/receipt-print-dialog';
import { useChangeDelivery, useDeliveries } from '../hooks/use-deliveries';
import {
  canHandleDeliveries,
  type DeliveryStatus,
  deliveryFailureKey,
  hasOwed,
  type PosDeliveryRow,
  telHref,
} from '../lib/deliveries';
import { formatMoney } from '../lib/money';
import { contextFeature } from '../lib/pos-features';
import { formatInstant } from '../lib/receivables';
import { conflictReason, describeFailure, posFailureKey } from '../lib/request-failure';

// "Đơn cần giao": the branch's sales marked for delivery. Pending ones wait
// oldest first with a one-tap "Đã giao"; the ones delivered today can be
// reviewed and put back if tapped by mistake.
export function DeliveriesPage() {
  const { context, selection } = usePosSelection();
  const scope = `${context.data?.staff.id}:${context.data?.store.id}:${selection.branchId}`;
  return <Deliveries key={scope} />;
}

function Deliveries() {
  const { t } = useTranslation();
  const { context, selection } = usePosSelection();
  const branchId = selection.branchId;
  const allowed = canHandleDeliveries(context.data?.capabilities);
  const [status, setStatus] = useState<DeliveryStatus>('pending');
  const rows = useDeliveries(branchId, status, Boolean(context.data) && allowed);
  const change = useChangeDelivery();
  const [notice, setNotice] = useState('');
  const [error, setError] = useState('');

  function act(row: PosDeliveryRow, action: 'deliver' | 'reopen') {
    setNotice('');
    setError('');
    change.mutate(
      { id: row.id, action },
      {
        onSuccess: () =>
          setNotice(
            t(action === 'deliver' ? 'deliveriesDone' : 'deliveriesReopened', {
              number: row.order_number,
            }),
          ),
        onError: (failure) => {
          const key = deliveryFailureKey(conflictReason(failure));
          setError(key ? t(key) : describeFailure(failure, t, 'deliveriesFailed'));
        },
      },
    );
  }

  return (
    <PosPage title={t('deliveriesTitle')} description={t('deliveriesHint')}>
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !branchId ? (
        <PageState title={t('chooseBranch')} description={t('pageChooseBranchHint')} />
      ) : !allowed ? (
        <PageState title={t('forbidden')} />
      ) : (
        <section className="page-card" aria-label={t('deliveriesTitle')}>
          {contextFeature(context.data, 'delivery') ? null : <FeatureOffNote feature="delivery" />}
          <div className="page-toolbar">
            <fieldset className="delivery-filter">
              <legend className="visually-hidden">{t('deliveriesFilter')}</legend>
              {(['pending', 'delivered'] as const).map((value) => (
                <button
                  key={value}
                  type="button"
                  aria-pressed={status === value}
                  onClick={() => {
                    setStatus(value);
                    setNotice('');
                    setError('');
                  }}
                >
                  {t(`deliveriesStatus_${value}`)}
                </button>
              ))}
            </fieldset>
            <button type="button" disabled={rows.isFetching} onClick={() => void rows.refetch()}>
              {t('refresh')}
            </button>
          </div>
          {notice ? (
            <p className="muted" role="status">
              {notice}
            </p>
          ) : null}
          {error ? (
            <p className="error" role="alert">
              {error}
            </p>
          ) : null}
          {rows.isLoading ? <PageState kind="loading" title={t('waiting')} /> : null}
          {rows.isError ? <PageState kind="error" title={t(posFailureKey(rows.error))} /> : null}
          {rows.isSuccess && rows.data.data.length === 0 ? (
            <PageState
              kind="empty"
              title={t(status === 'pending' ? 'deliveriesEmpty' : 'deliveriesEmptyToday')}
            />
          ) : null}
          <ul className="record-list delivery-list" aria-label={t(`deliveriesStatus_${status}`)}>
            {(rows.data?.data ?? []).map((row) => (
              <DeliveryRow
                key={row.id}
                row={row}
                busy={change.isPending}
                onDeliver={() => act(row, 'deliver')}
                onReopen={() => act(row, 'reopen')}
              />
            ))}
          </ul>
        </section>
      )}
    </PosPage>
  );
}

function DeliveryRow({
  row,
  busy,
  onDeliver,
  onReopen,
}: {
  row: PosDeliveryRow;
  busy: boolean;
  onDeliver: () => void;
  onReopen: () => void;
}) {
  const { t, i18n } = useTranslation();
  const money = (value: string) => formatMoney(value, row.currency);
  const phone = row.customer?.phone ?? null;
  const tel = telHref(phone);
  return (
    <li className="delivery-row" data-status={row.status}>
      <span className="record-copy">
        <strong>
          {row.order_number} · {formatInstant(row.placed_at, i18n.language)}{' '}
          <OrderSourceTag value={row.order_source} />
        </strong>
        <span>
          {row.customer?.name || t('customerWalkIn')}
          {phone ? (
            <>
              {' · '}
              {tel ? <a href={tel}>{phone}</a> : phone}
            </>
          ) : null}
        </span>
        {row.customer?.address ? (
          <span className="delivery-address">{row.customer.address}</span>
        ) : null}
        <small>
          {row.deliverer
            ? t('deliveriesDeliverer', { name: row.deliverer })
            : t('deliveriesNoDeliverer')}
          {row.status === 'delivered' && row.delivered_at
            ? ` · ${t('deliveriesDeliveredAt', { time: formatInstant(row.delivered_at, i18n.language) })}`
            : ''}
        </small>
      </span>
      <span className="delivery-money">
        <strong>{money(row.total)}</strong>
        {hasOwed(row) ? (
          <span className="status-tag" data-warning="true">
            {t('deliveriesOwed', { amount: money(row.owed) })}
          </span>
        ) : (
          <span className="status-tag">{t('deliveriesPaid')}</span>
        )}
      </span>
      <span className="delivery-actions">
        <ReceiptPrintButton sourceId={row.workspace_id} label={t('receiptOpen')} />
        {row.status === 'pending' ? (
          <button type="button" className="primary-button" disabled={busy} onClick={onDeliver}>
            {t('deliveriesMarkDelivered')}
          </button>
        ) : (
          <button type="button" disabled={busy} onClick={onReopen}>
            {t('deliveriesUndo')}
          </button>
        )}
      </span>
    </li>
  );
}
