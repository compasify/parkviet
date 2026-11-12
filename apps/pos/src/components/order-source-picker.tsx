import { useTranslation } from 'react-i18next';
import {
  isPlatformSource,
  KIOSK_ORDER_SOURCE,
  type OrderSource,
  orderSourceKey,
  orderSourceOf,
  PICKABLE_ORDER_SOURCES,
} from '../lib/order-source';

// One tap tags where the sale came from: Tại quầy (default), Facebook, Zalo
// or Khác. It moves no money, so it stays open while a payment is taken. A
// delivery platform's order keeps its platform, and a kiosk's order stays the
// kiosk's: it shows, and cannot change.
export function OrderSourcePicker({
  value,
  disabled,
  onPick,
}: {
  value: unknown;
  disabled: boolean;
  onPick: (source: OrderSource) => void;
}) {
  const { t } = useTranslation();
  const current = orderSourceOf(value);
  if (isPlatformSource(current) || current === KIOSK_ORDER_SOURCE)
    return (
      <p className="order-source-picker" data-source={current}>
        {t(orderSourceKey(current))}
      </p>
    );
  return (
    <fieldset className="order-source-picker" disabled={disabled}>
      <legend className="visually-hidden">{t('orderSourceTitle')}</legend>
      {PICKABLE_ORDER_SOURCES.map((source) => (
        <button
          key={source}
          type="button"
          aria-pressed={current === source}
          data-source={source}
          onClick={() => {
            if (source !== current) onPick(source);
          }}
        >
          {t(orderSourceKey(source))}
        </button>
      ))}
    </fieldset>
  );
}
