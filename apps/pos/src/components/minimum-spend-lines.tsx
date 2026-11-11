import { formatMoney } from '@parkviet/pos-shared/money';
import { useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { PosWorkspace } from '../lib/pos-context';
import { describeFailure } from '../lib/request-failure';

// The VIP table's minimum spend fee and the door tickets' drink credit left,
// as checkout lines. Waiving the fee takes a manager's approval code unless
// the cashier may approve; putting it back needs nothing.
export function MinimumSpendLines({
  workspace,
  currency,
  canApprove,
  disabled,
  onWaive,
}: {
  workspace: PosWorkspace;
  currency: string;
  canApprove: boolean;
  disabled: boolean;
  onWaive: (waived: boolean, approvalId?: string) => Promise<unknown>;
}) {
  const { t } = useTranslation();
  const [approvalId, setApprovalId] = useState('');
  const [error, setError] = useState('');
  const [busy, setBusy] = useState(false);
  const details = useRef<HTMLDetailsElement>(null);
  const minimum = workspace.minimum_spend ?? null;
  const credit = workspace.drink_credit ?? null;

  async function run(waived: boolean) {
    setError('');
    setBusy(true);
    try {
      await onWaive(waived, approvalId.trim() || undefined);
      setApprovalId('');
      if (details.current) details.current.open = false;
    } catch (failure) {
      setError(describeFailure(failure, t));
    } finally {
      setBusy(false);
    }
  }

  const fee = minimum && Number(minimum.amount) > 0 ? minimum.amount : null;
  return (
    <>
      {minimum && (fee || minimum.waived) ? (
        <div className="checkout-line minimum-spend-line">
          <span>
            {t('minimumSpendFee')}{' '}
            <small className="item-discount-source">
              {minimum.waived
                ? t('minimumSpendWaived')
                : t('minimumSpendOf', { amount: formatMoney(minimum.minimum, currency) })}
            </small>
            {minimum.waived ? (
              <button
                type="button"
                className="link-button"
                disabled={disabled || busy}
                onClick={() => void run(false)}
              >
                {t('minimumSpendRestore')}
              </button>
            ) : (
              <details className="minimum-spend-waive" ref={details}>
                <summary className="link-button">{t('minimumSpendWaive')}</summary>
                <form
                  className="row"
                  onSubmit={(event) => {
                    event.preventDefault();
                    if (disabled || busy || (!canApprove && !approvalId.trim())) return;
                    void run(true);
                  }}
                >
                  {!canApprove ? (
                    <label>
                      {t('discountApproval')}
                      <input
                        value={approvalId}
                        maxLength={64}
                        disabled={disabled || busy}
                        onChange={(event) => setApprovalId(event.target.value)}
                      />
                    </label>
                  ) : null}
                  <button
                    type="submit"
                    disabled={disabled || busy || (!canApprove && !approvalId.trim())}
                  >
                    {t('minimumSpendWaiveConfirm')}
                  </button>
                </form>
              </details>
            )}
          </span>
          <strong>{formatMoney(fee ?? '0', currency)}</strong>
        </div>
      ) : null}
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
      {credit ? (
        <div className="checkout-line drink-credit-line">
          <span>
            {t('drinkCreditLeft')}{' '}
            <small className="item-discount-source">
              {t('drinkCreditOf', { amount: formatMoney(credit.total, currency) })}
            </small>
          </span>
          <strong>{formatMoney(credit.remaining, currency)}</strong>
        </div>
      ) : null}
    </>
  );
}
