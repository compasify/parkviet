import { Link } from '@tanstack/react-router';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { CashMovementDialog } from '../components/cash-movement-dialog';
import { CashRequestList } from '../components/cash-request-list';
import { LateCashWizard } from '../components/late-cash-wizard';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { ShiftCloseDialog, VarianceText } from '../components/shift-close-dialog';
import {
  useCashMovementRequests,
  useCashMovements,
  useOpenShifts,
  useShiftCloseState,
} from '../hooks/use-shift-close';
import { formatMoney } from '../lib/money';
import { writesLocked } from '../lib/pos-context';
import { posFailureKey } from '../lib/request-failure';
import { canMoveCash, canReconcileCash, formatInZone } from '../lib/shifts';

export function ShiftsPage() {
  const { context, selection } = usePosSelection();
  const scope = `${context.data?.staff.id}:${context.data?.store.id}:${selection.branchId}`;
  return <Shifts key={scope} />;
}

function Shifts() {
  const { t, i18n } = useTranslation();
  const { context, selection } = usePosSelection();
  const data = context.data;
  const shift = data?.shift ?? null;
  const actor = { staffId: data?.staff.id ?? null, storeId: data?.store.id ?? null };
  const locked = !data || writesLocked(data, selection);
  const own = Boolean(shift && data && shift.owner_id === data.staff.id);
  const capabilities = data?.capabilities ?? [];
  const branch = data?.branches.find((row) => row.id === selection.branchId);
  const timeZone = branch?.timezone ?? data?.store.timezone ?? 'Asia/Ho_Chi_Minh';
  const recover = capabilities.includes('pos.topology.recover');
  // Kept while the dialog is open: closing removes the shift from the context.
  const [closingId, setClosingId] = useState<string | null>(null);
  const [moving, setMoving] = useState(false);
  const [notice, setNotice] = useState('');
  const [closedId, setClosedId] = useState<string | null>(null);
  const state = useShiftCloseState(shift?.id ?? null);
  const closed = useShiftCloseState(closedId);
  const movements = useCashMovements(own ? (shift?.id ?? null) : null);
  const requests = useCashMovementRequests(
    selection.branchId,
    { shiftId: own ? (shift?.id ?? null) : null },
    own,
  );
  const openShifts = useOpenShifts(selection.branchId, recover);
  const confirmer = canMoveCash(capabilities) || capabilities.includes('pos.approval.grant');
  const toConfirm = useCashMovementRequests(selection.branchId, { pendingOnly: true }, confirmer);
  const colleagues = (toConfirm.data?.data ?? []).filter(
    (row) => row.requester_id !== actor.staffId,
  );
  // Once shown, the section stays so the confirmation notice is not lost.
  const [confirming, setConfirming] = useState(false);
  if (colleagues.length > 0 && !confirming) setConfirming(true);
  const time = (value: string | null | undefined) => formatInZone(value, i18n.language, timeZone);
  const others = (openShifts.data?.data ?? []).filter((row) => row.id !== shift?.id);

  return (
    <PosPage title={t('shiftsTitle')} description={t('shiftsHint')}>
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !selection.branchId ? (
        <PageState title={t('chooseBranch')} description={t('pageChooseBranchHint')} />
      ) : (
        <>
          {notice ? (
            <p className="muted" role="status">
              {notice}
            </p>
          ) : null}
          <section className="page-card" aria-labelledby="current-shift-title">
            <h2 id="current-shift-title">{t('shiftCurrent')}</h2>
            {!shift ? (
              <PageState title={t('shiftNone')} description={t('shiftNoneHint')} />
            ) : (
              <>
                <dl className="summary-grid">
                  <dt>{t('shiftOpenedAt')}</dt>
                  <dd>{time(shift.opened_at)}</dd>
                  <dt>{t('shiftOpeningFloat')}</dt>
                  <dd>{formatMoney(shift.opening_float, shift.currency)}</dd>
                  <dt>{t('shiftStatusLabel')}</dt>
                  <dd>
                    {state.data?.count.counted ? t('shiftStatusCounted') : t('shiftStatusOpen')}
                  </dd>
                </dl>
                <p className="muted">{t('shiftBlindNotice')}</p>
                <div className="row">
                  {own && canMoveCash(capabilities) ? (
                    <button type="button" disabled={locked} onClick={() => setMoving(true)}>
                      {t('cashMovementOpen')}
                    </button>
                  ) : null}
                  {state.data?.can_close ? (
                    <button
                      type="button"
                      className="checkout-submit"
                      disabled={locked}
                      onClick={() => setClosingId(shift.id)}
                    >
                      {t('shiftCloseOpen')}
                    </button>
                  ) : null}
                </div>
                {own ? (
                  <>
                    {(requests.data?.data.length ?? 0) > 0 ? (
                      <>
                        <h3>{t('cashRequestsMine')}</h3>
                        <CashRequestList
                          requests={requests.data?.data ?? []}
                          actor={actor}
                          locked={locked}
                          timeZone={timeZone}
                          mode="own"
                        />
                      </>
                    ) : null}
                    <h3>{t('cashMovementList')}</h3>
                    {movements.isError ? (
                      <PageState kind="error" title={t(posFailureKey(movements.error))} />
                    ) : null}
                    {movements.isSuccess && movements.data.data.length === 0 ? (
                      <p className="muted">{t('cashMovementEmpty')}</p>
                    ) : null}
                    <ul className="record-list" aria-label={t('cashMovementList')}>
                      {(movements.data?.data ?? []).map((row) => (
                        <li key={row.id}>
                          <div className="record-copy">
                            <strong>{t(`cashMovement_${row.kind}`)}</strong>
                            <small>
                              {row.reason}
                              {row.evidence_reference ? ` · ${row.evidence_reference}` : ''} ·{' '}
                              {time(row.created_at)}
                            </small>
                          </div>
                          <strong>{formatMoney(row.amount, row.currency)}</strong>
                        </li>
                      ))}
                    </ul>
                  </>
                ) : null}
              </>
            )}
          </section>
          {confirming ? (
            <section className="page-card" aria-labelledby="cash-confirm-title">
              <h2 id="cash-confirm-title">{t('cashRequestsTitle')}</h2>
              <p className="muted">{t('cashRequestsHint')}</p>
              <CashRequestList
                requests={colleagues}
                actor={actor}
                locked={locked}
                timeZone={timeZone}
                mode="confirm"
              />
            </section>
          ) : null}
          {recover && others.length > 0 ? (
            <section className="page-card" aria-labelledby="open-shifts-title">
              <h2 id="open-shifts-title">{t('shiftOthersTitle')}</h2>
              <p className="muted">{t('shiftOthersHint')}</p>
              <ul className="record-list" aria-label={t('shiftOthersTitle')}>
                {others.map((row) => (
                  <li key={row.id}>
                    <div className="record-copy">
                      <strong>
                        {row.owner_name} · {row.register ?? t('shiftNoRegister')}
                      </strong>
                      <small>
                        {t('shiftOpenedAt')}: {time(row.opened_at)} ·{' '}
                        {formatMoney(row.opening_float, row.currency)}
                      </small>
                    </div>
                    <button type="button" disabled={locked} onClick={() => setClosingId(row.id)}>
                      {t('shiftCloseFor', { name: row.owner_name })}
                    </button>
                  </li>
                ))}
              </ul>
            </section>
          ) : null}
          {closed.data?.closure ? (
            <section className="page-card" aria-labelledby="closed-shift-title">
              <h2 id="closed-shift-title">{t('shiftJustClosed')}</h2>
              <dl className="summary-grid">
                <dt>{t('shiftExpected')}</dt>
                <dd>{formatMoney(closed.data.closure.expected, closed.data.closure.currency)}</dd>
                <dt>{t('shiftCounted')}</dt>
                <dd>{formatMoney(closed.data.closure.counted, closed.data.closure.currency)}</dd>
                <dt>{t('shiftVarianceLabel')}</dt>
                <dd>
                  <VarianceText
                    variance={closed.data.closure.variance}
                    currency={closed.data.closure.currency}
                  />
                </dd>
              </dl>
              <Link
                className="button-link"
                to="/receipts"
                search={{ source: closed.data.closure.id }}
              >
                {t('receiptOpenClosure')}
              </Link>
            </section>
          ) : null}
          {canReconcileCash(capabilities) && selection.branchId ? (
            <LateCashWizard
              branchId={selection.branchId}
              actor={actor}
              locked={locked}
              timeZone={timeZone}
            />
          ) : null}
        </>
      )}
      {moving && shift ? (
        <CashMovementDialog
          shiftId={shift.id}
          currency={shift.currency}
          actor={actor}
          onClose={() => setMoving(false)}
          onDone={(message) => {
            setMoving(false);
            setNotice(message);
          }}
        />
      ) : null}
      {closingId ? (
        <ShiftCloseDialog
          shiftId={closingId}
          actor={actor}
          timeZone={timeZone}
          onClose={() => {
            setClosedId(closingId);
            setClosingId(null);
          }}
        />
      ) : null}
    </PosPage>
  );
}
