import { useTranslation } from 'react-i18next';
import { formatMoney } from '../lib/money';
import type { GuestOrder, GuestRequest, GuestSession, GuestTable } from '../lib/types';

// "Bàn của tôi": this phone's orders and where they are, what is on the
// table with its kitchen state, and the calls for staff and for the bill.
export function TableScreen({
  session,
  table,
  busy,
  onRequest,
}: {
  session: GuestSession;
  table: GuestTable | null;
  busy: boolean;
  onRequest: (kind: GuestRequest['kind']) => void;
}) {
  const { t, i18n } = useTranslation();
  const open = (kind: GuestRequest['kind']) =>
    (table?.requests ?? []).some((request) => request.kind === kind && request.status === 'open');
  const ordering = session.status === 'open';
  const timed = session.timed || table?.has_timed === true;

  return (
    <section aria-label={t('tabTable')}>
      {(table?.orders ?? []).length > 0 ? (
        <>
          <h2>{t('myOrders')}</h2>
          <ul className="orders" data-testid="my-orders">
            {[...(table?.orders ?? [])].reverse().map((order) => (
              <OrderRow key={order.id} order={order} />
            ))}
          </ul>
        </>
      ) : null}
      {ordering ? (
        <>
          <h2>{t('onTable')}</h2>
          {(table?.lines ?? []).length === 0 ? (
            <p className="muted">{t('tableEmpty')}</p>
          ) : (
            <ul className="table-lines" data-testid="table-lines">
              {(table?.lines ?? []).map((line, index) => (
                // biome-ignore lint/suspicious/noArrayIndexKey: the server sends lines in a fixed order
                <li key={index}>
                  <span>
                    {Number(line.quantity)} × {line.name}
                    {line.size ? ` (${line.size})` : ''}
                    {line.options.length > 0 ? <small>{line.options.join(', ')}</small> : null}
                  </span>
                  <span className="muted">{t(`kitchen_${line.kitchen}`)}</span>
                </li>
              ))}
            </ul>
          )}
          {table?.subtotal ? (
            <p className="total">
              {t('subtotal')}:{' '}
              <strong>{formatMoney(table.subtotal, session.currency, i18n.language)}</strong>
            </p>
          ) : null}
        </>
      ) : null}
      <div className="requests">
        <button
          type="button"
          disabled={busy || open('call_staff')}
          data-testid="call-staff"
          onClick={() => onRequest('call_staff')}
        >
          {t('callStaff')}
        </button>
        {ordering ? (
          <button
            type="button"
            disabled={busy || open('request_bill')}
            data-testid="request-bill"
            onClick={() => onRequest('request_bill')}
          >
            {t('requestBill')}
          </button>
        ) : null}
      </div>
      {ordering && timed ? <p className="muted">{t('timedNote')}</p> : null}
      {(['call_staff', 'request_bill'] as const).map((kind) =>
        open(kind) ? (
          <p key={kind} role="status" className="notice">
            {t(`requestOpen_${kind}`)}
          </p>
        ) : null,
      )}
    </section>
  );
}

function OrderRow({ order }: { order: GuestOrder }) {
  const { t, i18n } = useTranslation();
  return (
    <li data-status={order.status} data-testid={`order-${order.id}`}>
      <p>
        <strong>
          {order.status === 'rejected'
            ? t('status_rejected', { reason: order.reject_reason ?? '' })
            : t(`status_${order.status}`)}
        </strong>{' '}
        · {formatMoney(order.quoted_total, order.currency, i18n.language)}
      </p>
      <ul>
        {order.items.map((item, index) => (
          // biome-ignore lint/suspicious/noArrayIndexKey: the server sends items in a fixed order
          <li key={index} className={item.outcome === 'left_out' ? 'left-out' : undefined}>
            {item.quantity} × {item.name}
            {item.size ? ` (${item.size})` : ''}
            {item.options.length > 0 ? ` · ${item.options.join(', ')}` : ''}
            {item.outcome === 'left_out' ? ` · ${t('leftOut')}` : ''}
          </li>
        ))}
      </ul>
    </li>
  );
}
