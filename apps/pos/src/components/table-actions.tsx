import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useResourceBoard, useTableCommands } from '../hooks/use-resource-board';
import type { PosWorkspace } from '../lib/pos-context';
import {
  describeTableFailure,
  mergeTargets,
  moveTargets,
  tableOrderName,
  tableOrderOf,
} from '../lib/tables';
import { SplitOrderDialog } from './split-order-dialog';

const CANCEL_PREBILL_ACTION = 'workspace.cancel_prebill';

// The tools of a table order while it is being sold: move it to a free
// table, merge it into another open order, split lines off, take the service
// charge off or put it back, pass on the table's request for the bill, and
// take a pre-bill back with a manager's approval.
export function TableOrderBar({
  workspace,
  branchId,
  staffId,
  editDisabled,
  actionDisabled,
  canWaive,
  canApprove,
  postpay,
  onMove,
  onMerge,
  onSplit,
  onSplitBySeat,
  onServiceCharge,
  onRequestPayment,
  onResolvePayment,
  onPrebillChanged,
}: {
  workspace: PosWorkspace;
  branchId: string | null;
  staffId: string | null;
  // Commands that need the lease and an editable basket.
  editDisabled: boolean;
  // Commands that only need a working session.
  actionDisabled: boolean;
  canWaive: boolean;
  canApprove: boolean;
  postpay: boolean;
  onMove: (resourceId: string) => Promise<unknown>;
  onMerge: (targetId: string) => Promise<unknown>;
  onSplit: (input: { saleLineIds: string[]; resourceId?: string }) => Promise<unknown>;
  // One bill per seat; absent when the branch does not track seats.
  onSplitBySeat?: (shared: Record<string, number>) => Promise<unknown>;
  onServiceCharge: (waived: boolean) => Promise<unknown>;
  onRequestPayment: () => Promise<unknown>;
  onResolvePayment: (status: 'done' | 'canceled') => Promise<unknown>;
  onPrebillChanged: () => void;
}) {
  const { t } = useTranslation();
  const order = tableOrderOf(workspace);
  const board = useResourceBoard(branchId, Boolean(order.table));
  const commands = useTableCommands(branchId);
  const [moveTo, setMoveTo] = useState('');
  const [mergeInto, setMergeInto] = useState('');
  const [splitting, setSplitting] = useState(false);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  if (!order.table) return null;
  const tables = board.data?.resources ?? [];
  const freeTables = moveTargets(tables, order.table.id);
  const orders = mergeTargets(tables, workspace.id);
  const editing = workspace.operational_status === 'editing';
  const charge = order.serviceCharge;
  const prebill = order.prebill;
  const request = order.paymentRequest;

  async function act(action: () => Promise<unknown>) {
    if (busy) return false;
    setBusy(true);
    setError('');
    try {
      await action();
      return true;
    } catch (failure) {
      setError(describeTableFailure(failure, t));
      void commands.refreshBoard();
      return false;
    } finally {
      setBusy(false);
    }
  }

  const cancelPrebill = () =>
    act(async () => {
      if (!staffId) return;
      const approvalId = await commands.approve(workspace, staffId, CANCEL_PREBILL_ACTION);
      await commands.cancelPrebill(workspace, approvalId);
      onPrebillChanged();
    });

  return (
    <section className="table-order-bar" aria-label={t('tableOrderTools')}>
      <p className="table-order-title">
        <strong>{tableOrderName(order.table.name, order.label)}</strong>
        {order.guestCount != null ? (
          <span> · {t('tableGuests', { count: order.guestCount })}</span>
        ) : null}
        {request?.status === 'open' ? (
          <span className="table-state-badge table-tile-payment_requested">
            {t('tableState_payment_requested')}
          </span>
        ) : null}
        {prebill?.status === 'current' ? (
          <span className="table-state-badge table-tile-prebilled">
            {t('tablePrebillPrinted', { number: prebill.sequence })}
          </span>
        ) : null}
        {prebill?.stale ? (
          <span className="table-state-badge table-tile-waiting_long">
            {t('tableEditedAfterPrebill')}
          </span>
        ) : null}
      </p>
      {editing ? (
        <div className="table-order-tools">
          <label>
            {t('tableMoveTo')}
            <select
              value={moveTo}
              disabled={editDisabled || busy}
              onChange={(event) => setMoveTo(event.target.value)}
            >
              <option value="">{t('tablePickTable')}</option>
              {freeTables.map((row) => (
                <option key={row.id} value={row.id}>
                  {row.name}
                </option>
              ))}
            </select>
          </label>
          <button
            type="button"
            disabled={editDisabled || busy || !moveTo}
            onClick={() =>
              void act(() => onMove(moveTo)).then((done) => {
                if (done) setMoveTo('');
              })
            }
          >
            {t('tableMove')}
          </button>
          <label>
            {t('tableMergeInto')}
            <select
              value={mergeInto}
              disabled={editDisabled || busy}
              onChange={(event) => setMergeInto(event.target.value)}
            >
              <option value="">{t('tablePickOrder')}</option>
              {orders.map((row) => (
                <option key={row.id} value={row.id}>
                  {row.name}
                </option>
              ))}
            </select>
          </label>
          <button
            type="button"
            disabled={editDisabled || busy || !mergeInto}
            onClick={() => {
              const target = orders.find((row) => row.id === mergeInto);
              if (!target || !window.confirm(t('tableMergeConfirm', { target: target.name })))
                return;
              void act(() => onMerge(target.id)).then((done) => {
                if (done) setMergeInto('');
              });
            }}
          >
            {t('tableMerge')}
          </button>
          <button
            type="button"
            disabled={editDisabled || busy || (workspace.line_items?.length ?? 0) < 2}
            onClick={() => {
              setError('');
              setSplitting(true);
            }}
          >
            {t('tableSplit')}
          </button>
          {charge?.applies ? (
            <button
              type="button"
              disabled={editDisabled || busy || !canWaive}
              title={canWaive ? undefined : t('tableServiceChargeNeedsRight')}
              onClick={() => void act(() => onServiceCharge(!charge.waived))}
            >
              {charge.waived ? t('tableServiceChargeRestore') : t('tableServiceChargeWaive')}
            </button>
          ) : null}
          {postpay ? (
            request?.status === 'open' ? (
              <>
                <button
                  type="button"
                  disabled={actionDisabled || busy}
                  onClick={() => void act(() => onResolvePayment('done'))}
                >
                  {t('tablePaymentRequestDone')}
                </button>
                <button
                  type="button"
                  disabled={actionDisabled || busy}
                  onClick={() => void act(() => onResolvePayment('canceled'))}
                >
                  {t('tablePaymentRequestCancel')}
                </button>
              </>
            ) : (
              <button
                type="button"
                disabled={actionDisabled || busy}
                onClick={() => void act(onRequestPayment)}
              >
                {t('tablePaymentRequest')}
              </button>
            )
          ) : null}
          {postpay && prebill?.status === 'current' ? (
            <button
              type="button"
              disabled={actionDisabled || busy || !canApprove}
              title={canApprove ? undefined : t('tablePrebillApprovalNeeded')}
              onClick={() => {
                if (window.confirm(t('tablePrebillCancelConfirm'))) void cancelPrebill();
              }}
            >
              {t('tablePrebillCancel')}
            </button>
          ) : null}
        </div>
      ) : null}
      {charge?.applies && charge.waived ? (
        <p className="muted" role="status">
          {t('tableServiceChargeWaived')}
        </p>
      ) : null}
      {error ? (
        <p className="error" role="alert">
          {error}
        </p>
      ) : null}
      {splitting ? (
        <SplitOrderDialog
          workspace={workspace}
          tableId={order.table.id}
          tables={tables}
          busy={busy}
          error={error}
          onClose={() => setSplitting(false)}
          onSplit={(input) =>
            void act(() => onSplit(input)).then((done) => {
              if (done) setSplitting(false);
            })
          }
          onSplitBySeat={
            onSplitBySeat
              ? (shared) =>
                  void act(() => onSplitBySeat(shared)).then((done) => {
                    if (done) setSplitting(false);
                  })
              : undefined
          }
        />
      ) : null}
    </section>
  );
}
