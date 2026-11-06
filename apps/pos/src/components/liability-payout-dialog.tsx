import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { formatMoney, parseVndAmount } from '../lib/money';
import type { PosLiabilityPayout, PosReceivedFunds } from '../lib/pos-context';
import { posFailureKey } from '../lib/request-failure';

export function LiabilityPayoutDialog({
  funds,
  disabled,
  busy,
  onRequest,
  onConfirm,
  onResolve,
}: {
  funds: PosReceivedFunds;
  disabled: boolean;
  busy: boolean;
  onRequest: (input: {
    amount: string;
    beneficiaryName: string;
    beneficiaryReference?: string;
    reason: string;
    approvalId?: string;
  }) => Promise<PosLiabilityPayout>;
  onConfirm: (
    payout: PosLiabilityPayout,
    input: { evidenceKind: string; reference?: string },
  ) => Promise<PosLiabilityPayout>;
  onResolve: (
    payout: PosLiabilityPayout,
    input: { outcome: 'unknown' | 'failed_no_effect' | 'cancel'; reference?: string },
  ) => Promise<PosLiabilityPayout>;
}) {
  const { t } = useTranslation();
  const [error, setError] = useState('');
  const payouts = funds.payouts ?? [];

  async function run(action: () => Promise<unknown>) {
    setError('');
    try {
      await action();
    } catch (failure) {
      setError(t(posFailureKey(failure)));
    }
  }

  return (
    <section className="liability-payouts" aria-label={t('fundsPayouts')}>
      <h4>{t('fundsPayouts')}</h4>
      <form
        onSubmit={(event) => {
          event.preventDefault();
          const form = new FormData(event.currentTarget);
          const amount = parseVndAmount(String(form.get('amount') ?? ''));
          if (!amount) {
            setError(t('invalid'));
            return;
          }
          void run(() =>
            onRequest({
              amount,
              beneficiaryName: String(form.get('beneficiary_name') ?? ''),
              beneficiaryReference: String(form.get('beneficiary_reference') ?? '') || undefined,
              reason: String(form.get('reason') ?? ''),
              approvalId: String(form.get('approval_id') ?? '') || undefined,
            }),
          );
        }}
      >
        <label>
          {t('fundsPayoutAmount')}
          <input name="amount" inputMode="numeric" required disabled={disabled || busy} />
        </label>
        <label>
          {t('fundsBeneficiary')}
          <input name="beneficiary_name" required disabled={disabled || busy} />
        </label>
        <label>
          {t('fundsBeneficiaryReference')}
          <input name="beneficiary_reference" disabled={disabled || busy} />
        </label>
        <label>
          {t('discountReason')}
          <input name="reason" required disabled={disabled || busy} />
        </label>
        <label>
          {t('discountApproval')}
          <input name="approval_id" disabled={disabled || busy} />
        </label>
        <button type="submit" disabled={disabled || busy}>
          {t('fundsPayoutRequest')}
        </button>
      </form>
      {payouts.map((payout) => (
        <article key={payout.id} className="liability-payout">
          <p>
            {payout.beneficiary_name} · {formatMoney(payout.amount, payout.currency)} ·{' '}
            {t(`payoutStatus_${payout.status}`)} · {payout.reason}
          </p>
          {['requested', 'reserved', 'unknown'].includes(payout.status) ? (
            <div className="row">
              <button
                type="button"
                disabled={disabled || busy}
                onClick={() =>
                  void run(() =>
                    onConfirm(payout, {
                      evidenceKind: funds.kind === 'cash' ? 'cash_count' : 'bank_manual',
                    }),
                  )
                }
              >
                {t('fundsPayoutConfirm')}
              </button>
              <button
                type="button"
                disabled={disabled || busy}
                onClick={() => void run(() => onResolve(payout, { outcome: 'unknown' }))}
              >
                {t('fundsPayoutUnknown')}
              </button>
              <button
                type="button"
                disabled={disabled || busy}
                onClick={() => void run(() => onResolve(payout, { outcome: 'failed_no_effect' }))}
              >
                {t('fundsPayoutFailed')}
              </button>
              <button
                type="button"
                disabled={disabled || busy}
                onClick={() => void run(() => onResolve(payout, { outcome: 'cancel' }))}
              >
                {t('fundsPayoutCancel')}
              </button>
            </div>
          ) : null}
        </article>
      ))}
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
    </section>
  );
}
