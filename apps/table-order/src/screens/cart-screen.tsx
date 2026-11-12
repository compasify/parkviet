import { useTranslation } from 'react-i18next';
import {
  type CartLine,
  cartProblem,
  cartTotal,
  MAX_ITEMS,
  MAX_LINE_QUANTITY,
  MAX_LINES,
} from '../lib/cart';
import { formatMoney } from '../lib/money';

// The cart before it is sent: change quantities, remove lines, send. A
// closed table (menu-only session) cannot send.
export function CartScreen({
  cart,
  currency,
  canSend,
  sending,
  onQuantity,
  onSend,
}: {
  cart: CartLine[];
  currency: string;
  canSend: boolean;
  sending: boolean;
  onQuantity: (key: string, quantity: number) => void;
  onSend: () => void;
}) {
  const { t, i18n } = useTranslation();
  const problem = cartProblem(cart);
  if (cart.length === 0) return <p className="muted">{t('cartEmpty')}</p>;
  return (
    <section aria-label={t('tabCart')}>
      <ul className="cart-lines">
        {cart.map((line) => (
          <li key={line.key} data-testid="cart-line">
            <div>
              <strong>{line.name}</strong>
              {line.size ? ` (${line.size})` : ''}
              {line.options.length > 0 ? <small>{line.options.join(', ')}</small> : null}
              {line.note ? <small>{line.note}</small> : null}
            </div>
            <div className="stepper">
              <button
                type="button"
                aria-label={`${t('less')} ${line.name}`}
                onClick={() => onQuantity(line.key, line.quantity - 1)}
              >
                −
              </button>
              <span>{line.quantity}</span>
              <button
                type="button"
                aria-label={`${t('more')} ${line.name}`}
                disabled={line.quantity >= MAX_LINE_QUANTITY}
                onClick={() => onQuantity(line.key, line.quantity + 1)}
              >
                +
              </button>
            </div>
            <button type="button" className="link" onClick={() => onQuantity(line.key, 0)}>
              {t('remove')}
            </button>
          </li>
        ))}
      </ul>
      <p className="total">
        {t('cartTotal')}:{' '}
        <strong data-testid="cart-total">
          {formatMoney(cartTotal(cart), currency, i18n.language)}
        </strong>
      </p>
      <p className="muted">{t('cartPriceNote')}</p>
      {problem ? (
        <p className="error" role="alert">
          {problem === 'too_many_lines'
            ? t('cartTooManyLines', { max: MAX_LINES })
            : t('cartTooManyItems', { max: MAX_ITEMS })}
        </p>
      ) : null}
      <button
        type="button"
        className="primary block"
        disabled={!canSend || sending || problem !== null}
        data-testid="send-order"
        onClick={onSend}
      >
        {sending ? t('sending') : t('send')}
      </button>
    </section>
  );
}
