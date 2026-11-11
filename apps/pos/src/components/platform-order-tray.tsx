import { formatMoney } from '@parkviet/pos-shared/money';
import {
  activePlatforms,
  type PlatformOrder,
  platformKey,
} from '@parkviet/pos-shared/platform-orders';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { usePlatformOrders, usePlatformSettings } from '../hooks/use-platform-orders';
import { PlatformOrderForm, platformFailure } from './platform-order-form';

// "Đơn Grab / Shopee": the delivery platform orders still at the shop, each
// with its platform, codes, call number and dishes. "Sẵn sàng" tells the
// counter it is packed (the kitchen marks it by itself when it finishes),
// "Tài xế đã lấy" completes the sale with what the platform owes, "Hủy"
// records the platform's cancel. Platform orders stay out of the tabs.
export function PlatformOrderTray({
  branchId,
  registerId,
  canEnter,
  canCollect,
}: {
  branchId: string | null;
  registerId: string | null;
  canEnter: boolean;
  canCollect: boolean;
}) {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const [entering, setEntering] = useState(false);
  const [canceling, setCanceling] = useState<string | null>(null);
  const [reason, setReason] = useState('');
  const [message, setMessage] = useState('');
  const settings = usePlatformSettings(branchId, true);
  const platforms = activePlatforms(settings.data);
  const { query, enter, ready, complete, cancel } = usePlatformOrders(branchId, registerId, open);
  const orders = query.data ?? [];
  const busy = ready.isPending || complete.isPending || cancel.isPending;

  // True when the command went through; the refusal is shown otherwise.
  const run = (action: () => Promise<unknown>) => {
    setMessage('');
    return action().then(
      () => true,
      (failure: unknown) => {
        setMessage(platformFailure(failure, t));
        return false;
      },
    );
  };

  if (platforms.length === 0) return null;

  return (
    <section className="platform-order-tray" aria-label={t('platformTrayTitle')}>
      <div className="platform-order-tray-head">
        <button
          type="button"
          aria-expanded={open}
          data-testid="platform-tray-toggle"
          onClick={() => setOpen((value) => !value)}
        >
          {t('platformTrayTitle')}
          {open && orders.length > 0 ? ` (${orders.length})` : ''}
        </button>
        <button
          type="button"
          className="primary"
          disabled={!canEnter}
          data-testid="platform-enter"
          onClick={() => setEntering(true)}
        >
          {t('platformEnter')}
        </button>
      </div>
      {open ? (
        query.isPending ? (
          <p className="muted">{t('waiting')}</p>
        ) : query.isError ? (
          <p role="alert">{t('platformTrayFailed')}</p>
        ) : orders.length === 0 ? (
          <p className="muted">{t('platformTrayEmpty')}</p>
        ) : (
          <ul className="platform-orders" data-testid="platform-orders">
            {orders.map((order) => (
              <PlatformOrderRow
                key={order.id}
                order={order}
                busy={busy}
                canCollect={canCollect}
                onReady={() => void run(() => ready.mutateAsync(order.id))}
                onComplete={() => void run(() => complete.mutateAsync(order.id))}
                onCancel={() => {
                  setReason('');
                  setCanceling(order.id);
                }}
              />
            ))}
          </ul>
        )
      ) : null}
      {canceling ? (
        <form
          className="platform-cancel"
          data-testid="platform-cancel-form"
          onSubmit={(event) => {
            event.preventDefault();
            const id = canceling;
            void run(() => cancel.mutateAsync({ id, reason })).then((done) => {
              if (done) setCanceling(null);
            });
          }}
        >
          <label>
            {t('platformCancelReason')}
            <input
              value={reason}
              maxLength={200}
              onChange={(event) => setReason(event.target.value)}
            />
          </label>
          <p className="muted">{t('platformCancelHint')}</p>
          <button type="button" onClick={() => setCanceling(null)}>
            {t('platformCancelBack')}
          </button>
          <button type="submit" className="danger" disabled={cancel.isPending}>
            {t('platformCancelConfirm')}
          </button>
        </form>
      ) : null}
      {message ? (
        <p className="error" role="alert">
          {message}
        </p>
      ) : null}
      {entering ? (
        <PlatformOrderForm
          branchId={branchId}
          platforms={platforms}
          onSubmit={async (entry) => {
            await enter.mutateAsync(entry);
            setOpen(true);
          }}
          onClose={() => setEntering(false)}
        />
      ) : null}
    </section>
  );
}

function PlatformOrderRow({
  order,
  busy,
  canCollect,
  onReady,
  onComplete,
  onCancel,
}: {
  order: PlatformOrder;
  busy: boolean;
  canCollect: boolean;
  onReady: () => void;
  onComplete: () => void;
  onCancel: () => void;
}) {
  const { t } = useTranslation();
  return (
    <li
      className="platform-order"
      data-status={order.status}
      data-testid={`platform-order-${order.id}`}
    >
      <p>
        <strong>{t(platformKey(order.platform))}</strong> · {order.platform_order_ref}
        {order.pickup_code ? ` · ${t('platformPickupShort', { code: order.pickup_code })}` : ''}
        {order.order_number ? ` · ${t('callNumber', { number: order.order_number })}` : ''}
      </p>
      <p className="muted">
        {t(`platformStatus_${order.status}`)} · {formatMoney(order.gross_amount, order.currency)}
      </p>
      <ul className="platform-order-items">
        {order.items.map((item, index) => (
          // Lines have no id of their own here; their order is fixed.
          // biome-ignore lint/suspicious/noArrayIndexKey: the server sends lines in a fixed order
          <li key={index}>
            {Number(item.quantity)} × {item.name}
            {item.modifiers.length > 0 ? ` · ${item.modifiers.join(', ')}` : ''}
            {item.note ? ` · ${item.note}` : ''}
          </li>
        ))}
      </ul>
      <div className="platform-order-actions">
        {order.status === 'accepted' ? (
          <button type="button" disabled={busy} onClick={onReady}>
            {t('platformReady')}
          </button>
        ) : null}
        <button
          type="button"
          className="primary"
          disabled={busy || !canCollect}
          data-testid={`platform-complete-${order.id}`}
          onClick={onComplete}
        >
          {t('platformPickedUp')}
        </button>
        <button type="button" className="danger" disabled={busy} onClick={onCancel}>
          {t('platformCancel')}
        </button>
      </div>
    </li>
  );
}
