import { formatMoney } from '@parkviet/pos-shared/money';
import { describeTraceFailure } from '@parkviet/pos-shared/traceability';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useTenders } from '../hooks/use-tenders';
import { type MealStatus, mealDue, mealReasonKey } from '../lib/meal-accounts';
import type { PosWorkspace } from '../lib/pos-context';
import { conflictReason } from '../lib/request-failure';

type WorkspaceCommand = (
  action: (current: PosWorkspace) => Promise<PosWorkspace>,
) => Promise<PosWorkspace>;

// The eater recorded on a canteen order: who they are, their wallet, the
// meals left today and who pays what. "Pay" settles it in one touch: the
// wallet pays the eater's part when it covers it, and completing the order
// charges the sponsor's part to its credit. A wallet that does not cover it
// leaves the eater's part to the ordinary payment below.
export function MealBanner({
  workspace,
  meal,
  staffId,
  storeId,
  canCollect,
  drawerOpen,
  disabled,
  command,
}: {
  workspace: PosWorkspace;
  meal: MealStatus;
  staffId: string | null;
  storeId: string | null;
  canCollect: boolean;
  drawerOpen: boolean;
  disabled: boolean;
  command: WorkspaceCommand;
}) {
  const { t } = useTranslation();
  const tenders = useTenders(staffId, storeId);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const plan = meal.plan;
  const currency = workspace.totals?.currency ?? meal.currency;
  const completed = workspace.operational_status === 'completed';
  const due = mealDue(workspace.financial?.remaining, plan);
  const unresolved = (workspace.financial?.attempts ?? []).some(
    (attempt) => attempt.status === 'prepared' || attempt.status === 'unknown',
  );
  const sponsorBlocked = due.sponsor > 0n && plan?.sponsor_unavailable === true;
  const walletPays = due.eater > 0n && meal.wallet_covers;
  const ready =
    canCollect &&
    drawerOpen &&
    !completed &&
    (workspace.line_items?.length ?? 0) > 0 &&
    !unresolved &&
    !sponsorBlocked &&
    meal.status === 'active' &&
    (due.eater === 0n || walletPays);

  async function payOneTouch() {
    setBusy(true);
    setError('');
    try {
      if (walletPays) await command((current) => tenders.payMealWallet(current));
      await command((current) =>
        tenders.complete(current, undefined, undefined, { mealSponsor: due.sponsor > 0n }),
      );
    } catch (failure) {
      const key = mealReasonKey(conflictReason(failure));
      setError(key ? t(key) : describeTraceFailure(failure, t));
      void tenders.refresh();
    } finally {
      setBusy(false);
    }
  }

  return (
    <section className="meal-banner" aria-label={t('mealBannerTitle')} data-testid="meal-banner">
      <div className="meal-banner-head">
        <strong>{meal.name}</strong>
        <span className="muted">
          {meal.employee_code}
          {meal.group_label ? ` · ${meal.group_label}` : ''}
        </span>
        {meal.status === 'locked' ? (
          <span className="workspace-phase">{t('mealAccountStatus_locked')}</span>
        ) : null}
      </div>
      <dl className="meal-banner-facts">
        <div>
          <dt>{t('mealBalance')}</dt>
          <dd>{formatMoney(meal.balance, meal.currency)}</dd>
        </div>
        <div>
          <dt>{t('mealMealsLeft')}</dt>
          <dd>{meal.meals_left === null ? t('mealNoLimit') : meal.meals_left}</dd>
        </div>
        {plan?.sponsor_name ? (
          <div>
            <dt>{t('mealSponsorPart', { sponsor: plan.sponsor_name })}</dt>
            <dd>{formatMoney(plan?.sponsor_amount, currency)}</dd>
          </div>
        ) : null}
        {plan ? (
          <div>
            <dt>{t('mealEaterPart')}</dt>
            <dd>{formatMoney(plan.employee_amount, currency)}</dd>
          </div>
        ) : null}
      </dl>
      {meal.low_balance ? (
        <p className="attention-box" role="note">
          {t('mealLowBalance')}
        </p>
      ) : null}
      {plan?.sponsor_unavailable ? (
        <p className="attention-box" role="note">
          {t('mealSponsorUnavailable')}
        </p>
      ) : null}
      {!completed && due.eater > 0n && !meal.wallet_covers ? (
        <p className="muted" role="note">
          {t('mealWalletShort', { amount: formatMoney(String(due.eater), currency) })}
        </p>
      ) : null}
      {!completed ? (
        <button
          type="button"
          className="checkout-submit meal-pay"
          disabled={disabled || busy || !ready}
          onClick={() => void payOneTouch()}
        >
          {busy
            ? t('waiting')
            : walletPays
              ? t('mealPayWallet', { amount: formatMoney(String(due.eater), currency) })
              : t('mealPayComplete')}
        </button>
      ) : null}
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
    </section>
  );
}
