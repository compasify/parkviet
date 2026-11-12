import { formatMoney, parseVndInput } from '@parkviet/pos-shared/money';
import { useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { RemoteApprovalButton } from '../components/remote-approval-button';
import {
  type OfflineSaleRecord,
  type ResolveInput,
  useOfflineReviewCommands,
  useOfflineReviews,
} from '../hooks/use-offline';
import { type ApprovalAsk, askFromFailure } from '../lib/approval-requests';
import { conflictReason, definitiveRejection, describeFailure } from '../lib/request-failure';

const MENU_MODULE = 'fnb.menu';
const APPROVE = 'pos.approval.grant';

// Offline sales the server could not complete as recorded. The cashier who
// took the cash finishes theirs (keeping the prices charged, with an
// approval, or charging today's prices); a manager may reject one.
export function OfflineReviewPage() {
  const { context, selection } = usePosSelection();
  const scope = `${context.data?.staff.id}:${context.data?.store.id}:${selection.branchId}`;
  return <OfflineReview key={scope} />;
}

function OfflineReview() {
  const { t } = useTranslation();
  const { context, selection } = usePosSelection();
  const data = context.data;
  const enabled = data?.modules?.[MENU_MODULE] === true;
  const reviews = useOfflineReviews(selection.branchId, enabled);
  const canReject = (data?.capabilities ?? []).includes(APPROVE);
  const rows = (reviews.data ?? []).filter((sale) => sale.status === 'needs_review');
  return (
    <PosPage title={t('offlineReviewTitle')} description={t('offlineReviewHint')}>
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !selection.branchId ? (
        <PageState title={t('chooseBranch')} description={t('pageChooseBranchHint')} />
      ) : !enabled ? (
        <PageState title={t('offlineState_menu_disabled')} />
      ) : reviews.isPending ? (
        <PageState kind="loading" title={t('waiting')} />
      ) : reviews.isError ? (
        <PageState kind="error" title={describeFailure(reviews.error, t)} />
      ) : rows.length === 0 ? (
        <PageState kind="success" title={t('offlineReviewEmpty')} />
      ) : (
        <ul className="offline-review-list">
          {rows.map((sale) => (
            <ReviewCard
              key={sale.id}
              sale={sale}
              mine={sale.staff.id === data?.staff.id}
              canReject={canReject}
            />
          ))}
        </ul>
      )}
    </PosPage>
  );
}

function ReviewCard({
  sale,
  mine,
  canReject,
}: {
  sale: OfflineSaleRecord;
  mine: boolean;
  canReject: boolean;
}) {
  const { t } = useTranslation();
  const { resolve, reject } = useOfflineReviewCommands();
  const [handed, setHanded] = useState('');
  const [approvalId, setApprovalId] = useState('');
  const [ask, setAsk] = useState<ApprovalAsk | null>(null);
  const [reason, setReason] = useState('');
  const [error, setError] = useState('');
  // One key per decision until the server answers it for good, so a resend
  // after a lost reply finds the same outcome.
  const keys = useRef(new Map<string, string>());
  const money = (value: string | null) => formatMoney(value ?? '0', sale.currency);
  const busy = resolve.isPending || reject.isPending;
  const priceChanged = sale.review_reason === 'price_changed' && Boolean(sale.workspace_id);

  function keyFor(action: string) {
    let key = keys.current.get(action);
    if (!key) {
      key = crypto.randomUUID();
      keys.current.set(action, key);
    }
    return key;
  }

  async function finish(input: Omit<ResolveInput, 'saleId' | 'key'>, action: string) {
    setError('');
    try {
      await resolve.mutateAsync({ ...input, saleId: sale.id, key: keyFor(action) });
      keys.current.delete(action);
    } catch (failure) {
      if (definitiveRejection(failure)) keys.current.delete(action);
      if (conflictReason(failure) === 'approval_required') {
        setAsk(askFromFailure(failure));
        setError(t('offlineApprovalNeeded'));
        return;
      }
      setError(describeFailure(failure, t));
    }
  }

  async function refuse() {
    setError('');
    try {
      await reject.mutateAsync({ saleId: sale.id, reason: reason.trim(), key: keyFor('reject') });
      keys.current.delete('reject');
    } catch (failure) {
      if (definitiveRejection(failure)) keys.current.delete('reject');
      setError(describeFailure(failure, t));
    }
  }

  const keep = (granted?: string) =>
    finish(
      {
        mode: 'accept_collected',
        approvalId: granted ?? (approvalId.trim() || undefined),
      },
      `accept:${granted ?? approvalId.trim()}`,
    );
  const handedValue = handed.trim() ? parseVndInput(handed) : null;

  return (
    <li className="offline-review-card">
      <h3>
        {sale.provisional_number}{' '}
        <small>{new Date(sale.client_sold_at).toLocaleString('vi-VN')}</small>
      </h3>
      <p>
        {t('offlineReviewCashier', { name: sale.staff.name })} ·{' '}
        <strong>{t(`offlineReason_${sale.review_reason ?? 'sale_refused'}`)}</strong>
      </p>
      {sale.clock_check ? (
        <p className="error">
          {t('offlineClockCheck', { minutes: Math.round(sale.clock_skew_seconds / 60) })}
        </p>
      ) : null}
      <p>
        {t('offlineCollected')}: <strong>{money(sale.collected_total)}</strong> (
        {t('offlineHanded')}: {money(sale.handed_amount)})
        {sale.current_total ? (
          <>
            {' '}
            · {t('offlineCurrentTotal')}: <strong>{money(sale.current_total)}</strong>
          </>
        ) : null}
      </p>
      <ul className="offline-review-lines">
        {sale.lines.map((line, index) => (
          // biome-ignore lint/suspicious/noArrayIndexKey: the recorded lines never reorder; the same item may repeat
          <li key={`${line.variant_id}-${index}`}>
            {line.quantity} × {line.name} — {money(line.unit_price)}
          </li>
        ))}
      </ul>
      {mine ? (
        <div className="offline-review-actions">
          {priceChanged ? (
            <div>
              <button type="button" disabled={busy} onClick={() => void keep()}>
                {t('offlineKeepCollected')}
              </button>
              {ask ? (
                <>
                  <label>
                    {t('discountApproval')}
                    <input
                      value={approvalId}
                      onChange={(event) => setApprovalId(event.target.value)}
                    />
                  </label>
                  {sale.workspace_id ? (
                    <RemoteApprovalButton
                      branchId={sale.branch_id}
                      subject={{ workspace_id: sale.workspace_id }}
                      ask={ask}
                      reason={sale.provisional_number}
                      disabled={busy}
                      onGranted={(id) => {
                        setApprovalId(id);
                        void keep(id);
                      }}
                    />
                  ) : null}
                </>
              ) : null}
            </div>
          ) : null}
          <div>
            <label>
              {t('offlineHandedNow')}
              <input
                inputMode="numeric"
                value={handed}
                placeholder={money(sale.handed_amount)}
                onChange={(event) => setHanded(event.target.value)}
              />
            </label>
            <button
              type="button"
              disabled={busy || (handed.trim() !== '' && handedValue === null)}
              onClick={() =>
                void finish(
                  {
                    mode: 'current_price',
                    handedAmount: handedValue === null ? undefined : String(handedValue),
                  },
                  `current:${handedValue ?? ''}`,
                )
              }
            >
              {t('offlineChargeCurrent')}
            </button>
          </div>
        </div>
      ) : (
        <p className="muted">{t('offlineReviewOthers')}</p>
      )}
      {canReject ? (
        <div className="offline-review-reject">
          <label>
            {t('offlineRejectReason')}
            <input
              value={reason}
              maxLength={200}
              onChange={(event) => setReason(event.target.value)}
            />
          </label>
          <button
            type="button"
            className="danger"
            disabled={busy || !reason.trim()}
            onClick={() => void refuse()}
          >
            {t('offlineReject')}
          </button>
        </div>
      ) : null}
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
    </li>
  );
}
