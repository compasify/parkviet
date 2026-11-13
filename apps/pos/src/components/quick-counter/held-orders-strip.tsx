import { formatMoney } from '@parkviet/pos-shared/money';
import type { Platform } from '@parkviet/pos-shared/platform-orders';
import { useTranslation } from 'react-i18next';
import { heldOrdersOf } from '../../lib/quick-counter';
import { workspacePhase } from '../../lib/workspace-content';
import { OrderTrays, type SellingWorkspace } from '../workspace-tabs';

// Above the menu: the orders put aside at the counter (a guest still
// choosing, or paying later), each a tap away from the ticket, then the
// trays of orders waiting from elsewhere (delivery platforms, QR, kiosks).
export function HeldOrdersStrip({
  selling,
  ownDrafts,
  enterPlatform,
  onPlatformClosed,
}: {
  selling: SellingWorkspace;
  // This device's blank drafts for its next guests: not put aside.
  ownDrafts: ReadonlySet<string>;
  enterPlatform: Platform | null;
  onPlatformClosed: () => void;
}) {
  const { t } = useTranslation();
  const { rows, active, selectOrder, data } = selling;
  const held = heldOrdersOf(rows, active?.id ?? null, ownDrafts);
  const currency = data?.store.currency ?? 'VND';
  return (
    <div className="quick-strip">
      {held.length > 0 ? (
        <ul className="quick-held" aria-label={t('quickHeldTitle')}>
          {held.map((order) => {
            const phase = workspacePhase(order);
            const total = order.totals?.total ?? order.total;
            return (
              <li key={order.id}>
                <button
                  type="button"
                  className="quick-held-order"
                  data-workspace-id={order.id}
                  aria-description={t(`workspacePhase_${phase}`)}
                  onClick={() => selectOrder(order.id)}
                >
                  <strong>
                    {order.order_number != null
                      ? t('callNumberShort', { number: order.order_number })
                      : order.order_id}
                  </strong>
                  {order.guest_name ? <span>{order.guest_name}</span> : null}
                  {total ? <span>{formatMoney(total, currency)}</span> : null}
                  {phase === 'editing' ? null : (
                    <small className={`workspace-phase workspace-phase-${phase}`}>
                      {t(`workspacePhase_${phase}`)}
                    </small>
                  )}
                </button>
              </li>
            );
          })}
        </ul>
      ) : null}
      <OrderTrays
        selling={selling}
        enterPlatform={enterPlatform}
        onPlatformClosed={onPlatformClosed}
      />
    </div>
  );
}
