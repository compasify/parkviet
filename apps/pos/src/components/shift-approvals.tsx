import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  useApproveClose,
  useCashMovementRequests,
  usePendingCloses,
} from '../hooks/use-shift-close';
import { formatMoney } from '../lib/money';
import { posFailureKey } from '../lib/request-failure';
import { describeShiftFailure, formatInZone } from '../lib/shifts';
import { CashRequestList } from './cash-request-list';
import { PageState } from './pos-page';
import { VarianceText } from './shift-close-dialog';

// Closing counts whose variance exceeds the branch threshold, and cash out /
// safe drop requests waiting for a second person. Approving a variance binds
// the approval to that count and variance; a recount needs a new approval.
export function ShiftApprovals({
  branchId,
  actor,
  locked,
  timeZone,
  canConfirmCash,
}: {
  branchId: string;
  actor: { staffId: string | null; storeId: string | null };
  locked: boolean;
  timeZone: string;
  canConfirmCash: boolean;
}) {
  const { t, i18n } = useTranslation();
  const pending = usePendingCloses(branchId, true);
  const cashRequests = useCashMovementRequests(branchId, { pendingOnly: true }, canConfirmCash);
  const approve = useApproveClose(actor);
  const [error, setError] = useState('');
  const [notice, setNotice] = useState('');
  const rows = pending.data?.data ?? [];

  return (
    <section className="page-card" aria-label={t('shiftApprovalsTitle')}>
      <h2>{t('shiftApprovalsTitle')}</h2>
      {notice ? (
        <p className="muted" role="status">
          {notice}
        </p>
      ) : null}
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
      {pending.isError ? <PageState kind="error" title={t(posFailureKey(pending.error))} /> : null}
      {pending.isSuccess && rows.length === 0 ? (
        <PageState kind="empty" title={t('shiftApprovalsEmpty')} />
      ) : null}
      <ul className="record-list" aria-label={t('shiftApprovalsList')}>
        {rows.map((row) => {
          const currency = row.currency ?? 'VND';
          return (
            <li key={row.shift_id} className="credit-request-row">
              <div className="record-copy">
                <strong>
                  {row.owner_name} · {row.register ?? t('shiftNoRegister')}
                </strong>
                <small>
                  {t('shiftApprovalLine', {
                    counted: formatMoney(row.counted, currency),
                    expected: formatMoney(row.expected, currency),
                    time: formatInZone(row.counted_at, i18n.language, timeZone),
                  })}
                </small>
                <small>
                  {t('shiftReason')}: {row.reason ?? '—'}
                </small>
              </div>
              <VarianceText variance={row.variance} currency={currency} />
              {row.approval ? (
                <span className="status-tag">{t('shiftApprovalGranted')}</span>
              ) : !row.reason ? (
                <button type="button" disabled>
                  {t('shiftApprovalWaitingReason')}
                </button>
              ) : (
                <button
                  type="button"
                  className="checkout-submit"
                  disabled={locked || approve.isPending || row.self_count}
                  title={row.self_count ? t('shiftReason_self_approval') : undefined}
                  onClick={() => {
                    setError('');
                    approve.mutate(
                      { shiftId: row.shift_id, revision: row.revision },
                      {
                        onSuccess: () =>
                          setNotice(t('shiftApprovalDone', { name: row.owner_name })),
                        onError: (failure) => setError(describeShiftFailure(failure, t)),
                      },
                    );
                  }}
                >
                  {t('shiftApproveVariance')}
                </button>
              )}
            </li>
          );
        })}
      </ul>
      {canConfirmCash ? (
        <>
          <h3>{t('cashRequestsTitle')}</h3>
          {cashRequests.isSuccess && cashRequests.data.data.length === 0 ? (
            <p className="muted">{t('cashRequestsEmpty')}</p>
          ) : null}
          <CashRequestList
            requests={cashRequests.data?.data ?? []}
            actor={actor}
            locked={locked}
            timeZone={timeZone}
            mode="confirm"
          />
        </>
      ) : null}
    </section>
  );
}
