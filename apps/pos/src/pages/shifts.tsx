import { formatMoney } from '@parkviet/pos-shared/money';
import { contextFeature } from '@parkviet/pos-shared/pos-features';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { CashMovementDialog } from '../components/cash-movement-dialog';
import { CashRequestList } from '../components/cash-request-list';
import { FeatureOffNote } from '../components/feature-off-note';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { ReceiptPrintButton } from '../components/receipt-print-dialog';
import { ShiftCloseDialog, VarianceText } from '../components/shift-close-dialog';
import {
  useCashMovementRequests,
  useCashMovements,
  useShiftCloseState,
} from '../hooks/use-shift-close';
import { writesLocked } from '../lib/pos-context';
import { posFailureKey } from '../lib/request-failure';
import { canMoveCash, formatInZone } from '../lib/shifts';

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
  const cashMovesOn = contextFeature(data, 'cash_moves');
  // Only the cashier's own shift is handled here; other people's open shifts
  // are closed from the POS dashboard.
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
  const time = (value: string | null | undefined) => formatInZone(value, i18n.language, timeZone);

  return (
    <PosPage title={t('myShiftTitle')} description={t('myShiftHint')}>
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
                {own && canMoveCash(capabilities) && !cashMovesOn ? (
                  <FeatureOffNote feature="cash_moves" id="cash-moves-off" />
                ) : null}
                <div className="row">
                  {own && canMoveCash(capabilities) ? (
                    <button
                      type="button"
                      disabled={locked || !cashMovesOn}
                      aria-describedby={cashMovesOn ? undefined : 'cash-moves-off'}
                      onClick={() => setMoving(true)}
                    >
                      {t('cashMovementOpen')}
                    </button>
                  ) : null}
                  {own && state.data?.can_close ? (
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
              <ReceiptPrintButton
                sourceId={closed.data.closure.id}
                label={t('receiptOpenClosure')}
              />
            </section>
          ) : null}
        </>
      )}
      {moving && shift && cashMovesOn ? (
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
