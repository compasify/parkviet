import { formatMoney } from '@parkviet/pos-shared/money';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useKioskOrders } from '../hooks/use-kiosk-orders';
import { KIOSK_ORDER_REASONS, type KioskOrder, waitingMinutes } from '../lib/kiosk-orders';
import { conflictReason, describeFailure } from '../lib/request-failure';

type T = (key: string, options?: Record<string, unknown>) => string;

function kioskFailure(failure: unknown, t: T): string {
  const reason = conflictReason(failure);
  if (reason && (KIOSK_ORDER_REASONS as readonly string[]).includes(reason))
    return t(`kioskFailure_${reason}`);
  return describeFailure(failure, t);
}

// "Đơn từ kiosk": orders guests placed at a self-ordering kiosk and chose to
// pay at the counter (or whose bank QR ran out), by call number. "Thu tiền"
// takes the order onto this cashier's shift and opens it to tender and
// complete as usual; the kitchen hears of it once it is paid. "Hủy" is
// offered for an order the guest abandoned.
export function KioskOrderTray({
  branchId,
  canTake,
  onTake,
}: {
  branchId: string | null;
  canTake: boolean;
  onTake: (workspaceId: string) => Promise<unknown>;
}) {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const [message, setMessage] = useState('');
  const [taking, setTaking] = useState<string | null>(null);
  const { orders, cancel, refresh } = useKioskOrders(branchId, true);
  const rows = orders.data ?? [];
  const busy = taking !== null || cancel.isPending;

  const run = (id: string | null, action: () => Promise<unknown>) => {
    setMessage('');
    setTaking(id);
    return action().then(
      () => {
        setTaking(null);
        refresh();
      },
      (failure: unknown) => {
        setTaking(null);
        setMessage(kioskFailure(failure, t));
        refresh();
      },
    );
  };

  return (
    <section className="platform-order-tray kiosk-order-tray" aria-label={t('kioskTrayTitle')}>
      <div className="platform-order-tray-head">
        <button
          type="button"
          aria-expanded={open}
          data-testid="kiosk-tray-toggle"
          onClick={() => setOpen((value) => !value)}
        >
          {t('kioskTrayTitle')}
          {rows.length > 0 ? (
            <span className="badge" data-testid="kiosk-tray-badge">
              {' '}
              {t('kioskTrayWaiting', { count: rows.length })}
            </span>
          ) : null}
        </button>
      </div>
      {open ? (
        orders.isPending ? (
          <p className="muted">{t('waiting')}</p>
        ) : orders.isError ? (
          <p role="alert">{t('kioskTrayFailed')}</p>
        ) : rows.length === 0 ? (
          <p className="muted">{t('kioskTrayEmpty')}</p>
        ) : (
          <ul className="platform-orders" data-testid="kiosk-orders">
            {rows.map((order) => (
              <KioskOrderRow
                key={order.id}
                order={order}
                busy={busy}
                canTake={canTake}
                onTake={() => void run(order.id, () => onTake(order.id))}
                onCancel={() => void run(null, () => cancel.mutateAsync(order.id))}
              />
            ))}
          </ul>
        )
      ) : null}
      {message ? (
        <p className="error" role="alert">
          {message}
        </p>
      ) : null}
    </section>
  );
}

function KioskOrderRow({
  order,
  busy,
  canTake,
  onTake,
  onCancel,
}: {
  order: KioskOrder;
  busy: boolean;
  canTake: boolean;
  onTake: () => void;
  onCancel: () => void;
}) {
  const { t } = useTranslation();
  return (
    <li
      className="platform-order"
      data-abandoned={order.abandoned ? 'true' : undefined}
      data-testid={`kiosk-order-${order.id}`}
    >
      <p>
        <strong>
          {order.call_number === null
            ? order.order_number
            : t('kioskCallNumber', { number: order.call_number })}
        </strong>
        {' · '}
        {formatMoney(order.total, order.currency)}
        {' · '}
        {t('kioskItems', { count: order.item_count })}
      </p>
      <p className="muted">
        {order.register_name ? `${order.register_name} · ` : ''}
        {t('kioskWaitingFor', { count: waitingMinutes(order, Date.now()) })}
        {order.abandoned ? ` · ${t('kioskAbandoned')}` : ''}
      </p>
      <div className="platform-order-actions">
        <button
          type="button"
          className="primary"
          disabled={busy || !canTake}
          data-testid={`kiosk-take-${order.id}`}
          onClick={onTake}
        >
          {t('kioskTake')}
        </button>
        {order.abandoned ? (
          <button
            type="button"
            className="danger"
            disabled={busy || !canTake}
            data-testid={`kiosk-cancel-${order.id}`}
            onClick={onCancel}
          >
            {t('kioskCancel')}
          </button>
        ) : null}
      </div>
    </li>
  );
}
