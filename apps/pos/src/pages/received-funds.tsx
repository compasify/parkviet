import { useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { LiabilityPayoutDialog } from '../components/liability-payout-dialog';
import { LocalFinancialRecords } from '../components/local-financial-records';
import { PosIcon } from '../components/pos-icon';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { useLiabilityPayouts, useReceivedFundDetail, useReceivedFunds } from '../hooks/use-tenders';
import { formatMoney, parseMoneyInput } from '../lib/money';
import type { PosReceivedFunds } from '../lib/pos-context';
import { writesLocked } from '../lib/pos-context';
import { posFailureKey } from '../lib/request-failure';

function FundRow({
  funds,
  selected,
  onSelect,
}: {
  funds: PosReceivedFunds;
  selected: boolean;
  onSelect: (id: string) => void;
}) {
  const { t } = useTranslation();
  return (
    <li>
      <button
        className="fund-row"
        type="button"
        aria-pressed={selected}
        onClick={() => onSelect(funds.id)}
      >
        <span className="fund-method-icon">
          <PosIcon name={funds.kind === 'cash' ? 'cash' : 'bank'} />
        </span>
        <span className="record-copy">
          <strong>{t(funds.kind === 'cash' ? 'cash' : 'bankTransfer')}</strong>
          <small>{funds.reference || funds.id}</small>
          <span className="status-tag" data-warning={funds.status === 'attention'}>
            {t(`fundStatus_${funds.status}`)}
          </span>
        </span>
        <span className="fund-row-money">
          <strong>{formatMoney(funds.received_net, funds.currency)}</strong>
          <small>{t('fundsAvailableShort')}</small>
          <span>{formatMoney(funds.available, funds.currency)}</span>
        </span>
      </button>
    </li>
  );
}

export function ReceivedFundsPage() {
  return <ScopedLedger attentionOnly={false} />;
}
export function PaymentAttentionPage() {
  return <ScopedLedger attentionOnly />;
}

function ScopedLedger({ attentionOnly }: { attentionOnly: boolean }) {
  const { context, selection } = usePosSelection();
  // Changing store, branch or permissions must remove the old detail and its action forms immediately.
  const scope = `${context.data?.staff.id}:${context.data?.store.id}:${selection.branchId}:${context.data?.capabilities.join(',')}`;
  return <FundsLedger key={scope} attentionOnly={attentionOnly} />;
}

function FundsLedger({ attentionOnly }: { attentionOnly: boolean }) {
  const { t } = useTranslation();
  const { selection, context } = usePosSelection();
  const data = context.data;
  const branchId = selection.branchId;
  const canResolve = Boolean(data?.capabilities.includes('pos.payment.resolve'));
  const canRead =
    canResolve || (!attentionOnly && Boolean(data?.capabilities.includes('pos.payment.collect')));
  const [page, setPage] = useState(1);
  const [selectedId, setSelectedId] = useState<string | null>(null);
  const detailHeading = useRef<HTMLHeadingElement>(null);
  const fundsQuery = useReceivedFunds(data?.store.id ?? null, branchId, null, canRead, page);
  const detailQuery = useReceivedFundDetail(selectedId, canRead && Boolean(branchId && selectedId));
  const detail =
    canRead && detailQuery.isSuccess && detailQuery.data.branch_id === branchId
      ? detailQuery.data
      : null;
  const payouts = useLiabilityPayouts(data?.staff.id ?? null, data?.store.id ?? null);
  const rows = (fundsQuery.data?.data ?? []).filter(
    (fund) =>
      !attentionOnly || fund.status === 'attention' || parseMoneyInput(fund.available) !== '0',
  );
  const branch = data?.branches.find((item) => item.id === branchId);
  const title = t(attentionOnly ? 'fundsAttentionTitle' : 'fundsTitle');

  return (
    <PosPage title={title} description={t(attentionOnly ? 'fundsAttentionHint' : 'fundsHint')}>
      {attentionOnly && data ? (
        <LocalFinancialRecords staffId={data.staff.id} storeId={data.store.id} />
      ) : null}
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !canRead ? (
        <PageState title={t('forbidden')} />
      ) : !branchId ? (
        <PageState title={t('chooseBranch')} description={t('pageChooseBranchHint')} />
      ) : (
        <>
          <div className="page-toolbar">
            <span>
              <PosIcon name="bank" /> <strong>{branch?.name ?? branchId}</strong>
            </span>
            <button
              type="button"
              disabled={fundsQuery.isFetching}
              onClick={() => void fundsQuery.refetch()}
            >
              {t('refresh')}
            </button>
          </div>
          <div className="funds-layout">
            <section className="page-card funds-list-panel" aria-label={title}>
              <h2>{t(attentionOnly ? 'attentionNav' : 'fundsNav')}</h2>
              <p className="muted">{t(attentionOnly ? 'fundsPageHint' : 'fundsSelectHint')}</p>
              {fundsQuery.isLoading ? <PageState kind="loading" title={t('waiting')} /> : null}
              {fundsQuery.isError ? (
                <PageState kind="error" title={t(posFailureKey(fundsQuery.error))}>
                  <button type="button" onClick={() => void fundsQuery.refetch()}>
                    {t('retry')}
                  </button>
                </PageState>
              ) : null}
              {fundsQuery.isSuccess && !rows.length ? (
                <PageState
                  kind={attentionOnly ? 'success' : 'empty'}
                  title={t(attentionOnly ? 'fundsAttentionEmpty' : 'fundsEmpty')}
                />
              ) : null}
              <ul className="fund-list" aria-label={t('fundsRecords')}>
                {rows.map((funds) => (
                  <FundRow
                    key={funds.id}
                    funds={funds}
                    selected={selectedId === funds.id}
                    onSelect={(id) => {
                      setSelectedId(id);
                      if (window.matchMedia('(max-width: 900px)').matches) {
                        detailHeading.current?.scrollIntoView({ block: 'start' });
                        detailHeading.current?.focus({ preventScroll: true });
                      }
                    }}
                  />
                ))}
              </ul>
              {fundsQuery.data && fundsQuery.data.meta.pages > 1 ? (
                <div className="page-pagination">
                  <button
                    type="button"
                    disabled={page <= 1 || fundsQuery.isFetching}
                    onClick={() => setPage((value) => value - 1)}
                  >
                    {t('previousPage')}
                  </button>
                  <span>
                    {page} / {fundsQuery.data.meta.pages}
                  </span>
                  <button
                    type="button"
                    disabled={page >= fundsQuery.data.meta.pages || fundsQuery.isFetching}
                    onClick={() => setPage((value) => value + 1)}
                  >
                    {t('nextPage')}
                  </button>
                </div>
              ) : null}
            </section>
            <section className="page-card fund-detail" aria-label={t('fundsDetail')}>
              <h2 ref={detailHeading} tabIndex={-1}>
                {t('fundsDetail')}
              </h2>
              {!selectedId ? (
                <PageState title={t('fundsSelect')} description={t('fundsSelectHint')} />
              ) : null}
              {selectedId && detailQuery.isLoading ? (
                <PageState kind="loading" title={t('waiting')} />
              ) : null}
              {selectedId && detailQuery.isError ? (
                <PageState kind="error" title={t(posFailureKey(detailQuery.error))}>
                  <button type="button" onClick={() => void detailQuery.refetch()}>
                    {t('retry')}
                  </button>
                </PageState>
              ) : null}
              {selectedId && detailQuery.isSuccess && !detail ? (
                <PageState kind="error" title={t('missing')} />
              ) : null}
              {detail ? (
                <article>
                  <div className="fund-detail-heading">
                    <span className="status-tag" data-warning={detail.status === 'attention'}>
                      {t(`fundStatus_${detail.status}`)}
                    </span>
                    <h3>{t(detail.kind === 'cash' ? 'cash' : 'bankTransfer')}</h3>
                    <strong>{formatMoney(detail.received_net, detail.currency)}</strong>
                    <small>{detail.id}</small>
                  </div>
                  <dl className="fund-breakdown">
                    {(
                      [
                        ['paymentAllocated', detail.allocated],
                        ['fundsReserved', detail.payout_reserved],
                        ['fundsPaidOut', detail.paid_out],
                        ['paymentUnapplied', detail.available],
                      ] as const
                    ).map(([label, amount]) => (
                      <div key={label}>
                        <dt>{t(label)}</dt>
                        <dd>{formatMoney(amount, detail.currency)}</dd>
                      </div>
                    ))}
                    <div>
                      <dt>{t('paymentReference')}</dt>
                      <dd>{detail.reference || '—'}</dd>
                    </div>
                  </dl>
                  {detail.allocations?.length ? (
                    <details className="page-disclosure">
                      <summary>
                        {t('fundsAllocations')} ({detail.allocations.length})
                      </summary>
                      <ul className="record-list">
                        {detail.allocations.map((allocation) => (
                          <li key={allocation.id}>
                            <span className="record-copy">
                              <strong>{allocation.order_id || allocation.workspace_id}</strong>
                              <small>{t(`allocationStatus_${allocation.status}`)}</small>
                            </span>
                            <strong>{formatMoney(allocation.amount, allocation.currency)}</strong>
                          </li>
                        ))}
                      </ul>
                    </details>
                  ) : null}
                  {canResolve ? (
                    <>
                      <p className="muted">{t('fundsAllocateHint')}</p>
                      <details className="page-disclosure">
                        <summary>{t('fundsPayouts')}</summary>
                        <p className="muted">{t('paymentSandbox')}</p>
                        <LiabilityPayoutDialog
                          key={detail.id}
                          funds={detail}
                          disabled={payouts.isPending || !data || writesLocked(data, selection)}
                          busy={payouts.isPending}
                          onRequest={(input) =>
                            payouts.mutateAsync({
                              funds: detail,
                              action: 'request',
                              amount: input.amount,
                              beneficiaryName: input.beneficiaryName,
                              beneficiaryReference: input.beneficiaryReference,
                              reason: input.reason,
                              approvalId: input.approvalId,
                            })
                          }
                          onConfirm={(payout, input) =>
                            payouts.mutateAsync({
                              funds: detail,
                              action: 'confirm',
                              payoutId: payout.id,
                              evidenceKind: input.evidenceKind,
                              reference: input.reference,
                            })
                          }
                          onResolve={(payout, input) =>
                            payouts.mutateAsync({
                              funds: detail,
                              action: 'resolve',
                              payoutId: payout.id,
                              outcome: input.outcome,
                              reference: input.reference,
                            })
                          }
                        />
                      </details>
                    </>
                  ) : (
                    <p className="muted">{t('fundsReadOnly')}</p>
                  )}
                </article>
              ) : null}
            </section>
          </div>
          <p className="page-footnote">{t('fundsManualReconcile')}</p>
        </>
      )}
    </PosPage>
  );
}
