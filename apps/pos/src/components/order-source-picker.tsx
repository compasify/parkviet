import { useTranslation } from 'react-i18next';
import {
  ORDER_SOURCES,
  type OrderSource,
  orderSourceKey,
  orderSourceOf,
} from '../lib/order-source';

// One tap tags where the sale came from: Tại quầy (default), Facebook, Zalo
// or Khác. It moves no money, so it stays open while a payment is taken.
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
  return (
    <fieldset className="order-source-picker" disabled={disabled}>
      <legend className="visually-hidden">{t('orderSourceTitle')}</legend>
      {ORDER_SOURCES.map((source) => (
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
