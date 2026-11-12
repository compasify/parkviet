import { formatMoney } from '@parkviet/pos-shared/money';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useGuestOrders } from '../hooks/use-guest-orders';
import {
  GUEST_ORDER_REASONS,
  type GuestOrder,
  type GuestRequest,
  REJECT_PRESETS,
  waitingCount,
} from '../lib/guest-orders';
import { conflictReason, describeFailure } from '../lib/request-failure';

type T = (key: string, options?: Record<string, unknown>) => string;

function guestFailure(failure: unknown, t: T): string {
  const reason = conflictReason(failure);
  if (reason && (GUEST_ORDER_REASONS as readonly string[]).includes(reason))
    return t(`guestFailure_${reason}`);
  return describeFailure(failure, t);
}

// "Đơn từ QR": what guests ordered from the table's QR code and wait to have
// confirmed, and their calls for staff or the bill. "Duyệt" adds the items to
// the table's order and sends them to the kitchen as the person accepting;
// "Từ chối" needs a reason the guest reads on their phone.
export function GuestOrderTray({
  branchId,
  canDecide,
}: {
  branchId: string | null;
  canDecide: boolean;
}) {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const [rejecting, setRejecting] = useState<string | null>(null);
  const [reason, setReason] = useState('');
  const [message, setMessage] = useState('');
  const { orders, requests, accept, reject, done } = useGuestOrders(branchId, true);
  const pending = (orders.data ?? []).filter((order) => order.status === 'pending');
  const calls = (requests.data ?? []).filter((request) => request.status === 'open');
  const waiting = waitingCount(pending, calls);
  const busy = accept.isPending || reject.isPending || done.isPending;

  const run = (action: () => Promise<unknown>) => {
    setMessage('');
    return action().then(
      () => true,
      (failure: unknown) => {
        setMessage(guestFailure(failure, t));
        return false;
      },
    );
  };

  return (
    <section className="platform-order-tray guest-order-tray" aria-label={t('guestTrayTitle')}>
      <div className="platform-order-tray-head">
        <button
          type="button"
          aria-expanded={open}
          data-testid="guest-tray-toggle"
          onClick={() => setOpen((value) => !value)}
        >
          {t('guestTrayTitle')}
          {waiting > 0 ? (
            <span className="badge" data-testid="guest-tray-badge">
              {' '}
              {t('guestTrayWaiting', { count: waiting })}
            </span>
          ) : null}
        </button>
      </div>
      {open ? (
        orders.isPending || requests.isPending ? (
          <p className="muted">{t('waiting')}</p>
        ) : orders.isError || requests.isError ? (
          <p role="alert">{t('guestTrayFailed')}</p>
        ) : waiting === 0 ? (
          <p className="muted">{t('guestTrayEmpty')}</p>
        ) : (
          <>
            {calls.length > 0 ? (
              <ul className="platform-orders" data-testid="guest-requests">
                {calls.map((request) => (
                  <GuestRequestRow
                    key={request.id}
                    request={request}
                    busy={busy}
                    onDone={() => void run(() => done.mutateAsync(request.id))}
                  />
                ))}
              </ul>
            ) : null}
            {pending.length > 0 ? (
              <ul className="platform-orders" data-testid="guest-orders">
                {pending.map((order) => (
                  <GuestOrderRow
                    key={order.id}
                    order={order}
                    busy={busy}
                    canDecide={canDecide}
                    onAccept={() => void run(() => accept.mutateAsync(order.id))}
                    onReject={() => {
                      setReason('');
                      setRejecting(order.id);
                    }}
                  />
                ))}
              </ul>
            ) : null}
          </>
        )
      ) : null}
      {rejecting ? (
        <form
          className="platform-cancel"
          data-testid="guest-reject-form"
          onSubmit={(event) => {
            event.preventDefault();
            const id = rejecting;
            void run(() => reject.mutateAsync({ id, reason })).then((ok) => {
              if (ok) setRejecting(null);
            });
          }}
        >
          <fieldset>
            <legend>{t('guestRejectPresets')}</legend>
            {REJECT_PRESETS.map((preset) => (
              <button
                key={preset}
                type="button"
                aria-pressed={reason === t(`guestRejectPreset_${preset}`)}
                onClick={() => setReason(t(`guestRejectPreset_${preset}`))}
              >
                {t(`guestRejectPreset_${preset}`)}
              </button>
            ))}
          </fieldset>
          <label>
            {t('guestRejectReason')}
            <input
              value={reason}
              maxLength={200}
              required
              onChange={(event) => setReason(event.target.value)}
            />
          </label>
          <p className="muted">{t('guestRejectHint')}</p>
          <button type="button" onClick={() => setRejecting(null)}>
            {t('platformCancelBack')}
          </button>
          <button
            type="submit"
            className="danger"
            disabled={reject.isPending || reason.trim() === ''}
            data-testid="guest-reject-confirm"
          >
            {t('guestRejectConfirm')}
          </button>
        </form>
      ) : null}
      {message ? (
        <p className="error" role="alert">
          {message}
        </p>
      ) : null}
    </section>
  );
}

function GuestRequestRow({
  request,
  busy,
  onDone,
}: {
  request: GuestRequest;
  busy: boolean;
  onDone: () => void;
}) {
  const { t } = useTranslation();
  return (
    <li className="platform-order" data-testid={`guest-request-${request.id}`}>
      <p>
        <strong>{request.table_name}</strong> · {t(`guestRequest_${request.kind}`)}
      </p>
      <div className="platform-order-actions">
        <button type="button" disabled={busy} onClick={onDone}>
          {t('guestRequestDone')}
        </button>
      </div>
    </li>
  );
}

function GuestOrderRow({
  order,
  busy,
  canDecide,
  onAccept,
  onReject,
}: {
  order: GuestOrder;
  busy: boolean;
  canDecide: boolean;
  onAccept: () => void;
  onReject: () => void;
}) {
  const { t } = useTranslation();
  return (
    <li
      className="platform-order"
      data-status={order.status}
      data-testid={`guest-order-${order.id}`}
    >
      <p>
        <strong>{order.table_name}</strong> · {formatMoney(order.quoted_total, order.currency)}
      </p>
      <ul className="platform-order-items">
        {order.items.map((item, index) => (
          // biome-ignore lint/suspicious/noArrayIndexKey: the server sends items in a fixed order
          <li key={index}>
            {item.quantity} × {item.name}
            {item.size ? ` (${item.size})` : ''}
            {item.options.length > 0 ? ` · ${item.options.join(', ')}` : ''}
            {item.note ? ` · ${item.note}` : ''}
          </li>
        ))}
      </ul>
      <div className="platform-order-actions">
        <button
          type="button"
          className="primary"
          disabled={busy || !canDecide}
          data-testid={`guest-accept-${order.id}`}
          onClick={onAccept}
        >
          {t('guestAccept')}
        </button>
        <button
          type="button"
          className="danger"
          disabled={busy || !canDecide}
          data-testid={`guest-reject-${order.id}`}
          onClick={onReject}
        >
          {t('guestReject')}
        </button>
      </div>
    </li>
  );
}
