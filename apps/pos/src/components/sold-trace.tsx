import { expiryState, formatExpiry, type OrderLineTrace } from '@parkviet/pos-shared/traceability';
import { useTranslation } from 'react-i18next';

export function lotLabel(
  t: (key: string, options?: Record<string, unknown>) => string,
  code: string | null,
  expiry: string | null,
) {
  return expiry ? t('saleLineLotExpiry', { code, expiry: formatExpiry(expiry) }) : (code ?? '');
}

// What the line sold: its serials, or its lots with expiry (flagged against
// the branch's today when given), and what already came back.
export function SoldTrace({
  trace,
  today,
}: {
  trace: OrderLineTrace | null | undefined;
  today?: string;
}) {
  const { t } = useTranslation();
  if (!trace?.allocations.length) return null;
  return (
    <small className="return-trace">
      {trace.allocations.map((allocation, index) => {
        const label =
          trace.mode === 'serial'
            ? (allocation.serial ?? '')
            : `${lotLabel(t, allocation.lot_code, allocation.expiry_on)} × ${allocation.quantity}`;
        const state =
          today && trace.mode === 'lot' ? expiryState(allocation.expiry_on, today) : 'none';
        return (
          // The same lot can appear twice on one line; the list never reorders.
          // biome-ignore lint/suspicious/noArrayIndexKey: allocations are a fixed server list
          <span key={`${allocation.serial ?? ''}:${allocation.lot_code ?? ''}:${index}`}>
            {index > 0 ? ' · ' : ''}
            {label}
            {allocation.returned_quantity > 0
              ? ` (${t('returnTraceReturned', { count: allocation.returned_quantity })})`
              : ''}
            {state === 'expired' ? (
              <>
                {' '}
                <span className="status-tag" data-danger="true">
                  {t('inventoryExpired')}
                </span>
              </>
            ) : state === 'near' ? (
              <>
                {' '}
                <span className="status-tag" data-warning="true">
                  {t('inventoryNearExpiry')}
                </span>
              </>
            ) : null}
          </span>
        );
      })}
    </small>
  );
}
