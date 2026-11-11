import { formatMoney, parseVndInput } from '@parkviet/pos-shared/money';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import {
  type TipDay,
  type TipShare,
  type TipSplitMode,
  useTipPayout,
  useTips,
} from '../hooks/use-tips';
import { writesLocked } from '../lib/pos-context';
import { conflictReason, describeFailure } from '../lib/request-failure';

const TIPS_MODULE = 'fnb.postpay';
const MODES: readonly TipSplitMode[] = ['equal', 'by_hours', 'manual'];
const PAYOUT_CAPABILITY = 'pos.payment.resolve';

const FAILURES: Record<string, string> = {
  tips_none: 'tipsNone',
  tip_split_mismatch: 'tipsSplitMismatch',
  tip_hours_invalid: 'tipsHoursInvalid',
  tip_amount_invalid: 'tipsAmountInvalid',
  tip_recipient_invalid: 'tipsRecipientInvalid',
  tip_recipients_required: 'tipsRecipientsRequired',
};

export function TipsPage() {
  const { context, selection } = usePosSelection();
  const scope = `${context.data?.staff.id}:${context.data?.store.id}:${selection.branchId}`;
  return <Tips key={scope} />;
}

function Tips() {
  const { t } = useTranslation();
  const { context, selection } = usePosSelection();
  const data = context.data;
  const branchId = selection.branchId;
  const enabled = data?.modules?.[TIPS_MODULE] === true;
  const canPay = (data?.capabilities ?? []).includes(PAYOUT_CAPABILITY);
  // Empty: the branch's current business day, as the server counts it.
  const [date, setDate] = useState('');
  const tips = useTips(branchId, date, enabled);
  const day = tips.data;
  return (
    <PosPage title={t('tipsTitle')} description={t('tipsHint')}>
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !branchId ? (
        <PageState title={t('chooseBranch')} description={t('pageChooseBranchHint')} />
      ) : !enabled ? (
        <PageState title={t('posModules.fnb_postpay.off')} />
      ) : (
        <>
          <div className="page-toolbar">
            <label>
              {t('tipsBusinessDate')}
              <input
                type="date"
                value={date || day?.businessDate || ''}
                onChange={(event) => setDate(event.target.value)}
              />
            </label>
          </div>
          {tips.isLoading ? <PageState kind="loading" title={t('waiting')} /> : null}
          {tips.isError ? <PageState kind="error" title={describeFailure(tips.error, t)} /> : null}
          {day ? (
            <>
              <div className="checkout-line">
                <span>{t('tipsHeld')}</span>
                <strong>{formatMoney(day.held, 'VND')}</strong>
              </div>
              <div className="checkout-line">
                <span>{t('tipsPaidOut')}</span>
                <strong>{formatMoney(day.paidOut, 'VND')}</strong>
              </div>
              <p className="muted">
                {day.tipsAsRevenue ? t('tipsCountedAsRevenue') : t('tipsOutsideRevenue')}
              </p>
              {day.rows.length === 0 ? (
                <PageState kind="empty" title={t('tipsEmpty')} />
              ) : (
                <ul className="record-list" aria-label={t('tipsList')}>
                  {day.rows.map((row) => (
                    <li key={row.id}>
                      {formatMoney(row.amount, row.currency)} ·{' '}
                      {row.kind === 'cash' ? t('cash') : t('bankTransfer')} ·{' '}
                      {row.status === 'held' ? t('tipsStatusHeld') : t('tipsStatusPaid')}
                      <small className="muted">
                        {' '}
                        · {row.createdAt ? new Date(row.createdAt).toLocaleTimeString() : ''}
                      </small>
                    </li>
                  ))}
                </ul>
              )}
              {canPay && Number(day.held) > 0 ? (
                <PayoutForm
                  key={`${day.businessDate}:${day.held}`}
                  branchId={branchId}
                  day={day}
                  disabled={writesLocked(data, selection)}
                />
              ) : null}
            </>
          ) : null}
        </>
      )}
    </PosPage>
  );
}

function PayoutForm({
  branchId,
  day,
  disabled,
}: {
  branchId: string;
  day: TipDay;
  disabled: boolean;
}) {
  const { t } = useTranslation();
  const payout = useTipPayout(branchId);
  const [mode, setMode] = useState<TipSplitMode>(day.mode);
  const [chosen, setChosen] = useState<Record<string, boolean>>({});
  const [values, setValues] = useState<Record<string, string>>({});
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  const [shares, setShares] = useState<TipShare[] | null>(null);
  const picked = day.staff.filter((person) => chosen[person.staffId]);
  const typed = (id: string) => (values[id] ?? '').trim();
  const ready =
    picked.length > 0 &&
    (mode === 'equal' ||
      picked.every((person) =>
        mode === 'manual'
          ? parseVndInput(typed(person.staffId)) !== null
          : /^\d+(\.\d+)?$/.test(typed(person.staffId)),
      ));

  async function submit() {
    if (!ready || disabled) return;
    setBusy(true);
    setMessage('');
    try {
      setShares(
        await payout({
          businessDate: day.businessDate,
          mode,
          recipients: picked.map((person) => ({
            staffId: person.staffId,
            ...(mode === 'by_hours' ? { hours: typed(person.staffId) } : {}),
            ...(mode === 'manual'
              ? { amount: parseVndInput(typed(person.staffId)) ?? undefined }
              : {}),
          })),
        }),
      );
    } catch (failure) {
      const key = FAILURES[conflictReason(failure) ?? ''];
      setMessage(key ? t(key) : describeFailure(failure, t));
    } finally {
      setBusy(false);
    }
  }

  if (shares) {
    return (
      <section aria-label={t('tipsShares')}>
        <h3>{t('tipsShares')}</h3>
        <ul className="record-list">
          {shares.map((share) => (
            <li key={share.staffId}>
              {share.name} · <strong>{formatMoney(share.amount, 'VND')}</strong>
            </li>
          ))}
        </ul>
        <p className="muted">{t('tipsPayoutPending')}</p>
      </section>
    );
  }
  return (
    <form
      className="reservation-form"
      aria-label={t('tipsPayout')}
      onSubmit={(event) => {
        event.preventDefault();
        void submit();
      }}
    >
      <h3>{t('tipsPayout')}</h3>
      <label>
        {t('tipsSplitMode')}
        <select
          value={mode}
          disabled={disabled || busy}
          onChange={(event) => setMode(event.target.value as TipSplitMode)}
        >
          {MODES.map((value) => (
            <option key={value} value={value}>
              {t(`tipsMode_${value}`)}
            </option>
          ))}
        </select>
      </label>
      {day.staff.length === 0 ? <p className="muted">{t('tipsNoStaff')}</p> : null}
      <ul className="record-list">
        {day.staff.map((person) => (
          <li key={person.staffId}>
            <label className="checkbox-field">
              <input
                type="checkbox"
                checked={chosen[person.staffId] === true}
                disabled={disabled || busy}
                onChange={(event) =>
                  setChosen((current) => ({ ...current, [person.staffId]: event.target.checked }))
                }
              />
              {person.name}
              {person.role ? <small className="muted"> · {person.role}</small> : null}
            </label>
            {mode !== 'equal' && chosen[person.staffId] ? (
              <input
                aria-label={
                  mode === 'by_hours'
                    ? t('tipsHoursOf', { name: person.name })
                    : t('tipsAmountOf', { name: person.name })
                }
                inputMode={mode === 'by_hours' ? 'decimal' : 'numeric'}
                value={values[person.staffId] ?? ''}
                disabled={disabled || busy}
                onChange={(event) =>
                  setValues((current) => ({ ...current, [person.staffId]: event.target.value }))
                }
              />
            ) : null}
          </li>
        ))}
      </ul>
      <button type="submit" className="primary-button" disabled={disabled || busy || !ready}>
        {t('tipsPayoutSubmit', { amount: formatMoney(day.held, 'VND') })}
      </button>
      {message ? (
        <p className="error" role="alert">
          {message}
        </p>
      ) : null}
    </form>
  );
}
