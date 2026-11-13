import { formatMoney } from '@parkviet/pos-shared/money';
import { rateLabel } from '@parkviet/pos-shared/receipt-template/data';
import { ticketLineAmount } from '@parkviet/pos-shared/ticket-groups';
import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useResourceBoard } from '../../hooks/use-resource-board';
import { useTenders } from '../../hooks/use-tenders';
import type { PosWorkspace } from '../../lib/pos-context';
import { describeFailure } from '../../lib/request-failure';
import { canSplitBySeat } from '../../lib/table-courses';
import { describeTableFailure, tableOrderName } from '../../lib/tables';
import { DeliveryForm } from '../delivery-form';
import { MinimumSpendLines } from '../minimum-spend-lines';
import { type PaymentControls, PaymentPanel } from '../payment-panel';
import { PosIcon } from '../pos-icon';
import { ReservationDepositNote } from '../reservation-deposit-note';
import { serviceModeOf } from '../service-mode-control';
import { SplitOrderDialog } from '../split-order-dialog';
import {
  ActivePrebillDialog,
  activePaymentProps,
  SellingNotices,
  type SellingWorkspace,
} from '../workspace-tabs';

type PayDialog = 'lines' | 'seat' | 'delivery';

// Payment of a table order over the whole screen: the bill on the left, the
// counter's own payment on the right (what is due, the QR shown at once, the
// cash keypad, the other methods) and the bill's tools in the foot. "← Đơn"
// goes back to the order; a completed order is handed over at the table and
// the screen returns to the board.
export function PaymentScreen({
  selling,
  onOrder,
  onBoard,
  onCompleted,
}: {
  selling: SellingWorkspace;
  onOrder: () => void;
  onBoard: () => void;
  // `print`: the invoice was asked for; `failure`: the handover was refused.
  onCompleted: (workspaceId: string, options: { print: boolean; failure?: string }) => void;
}) {
  const { t } = useTranslation();
  const { active, data, staffId, storeId, command } = selling;
  const tenders = useTenders(staffId, storeId);

  async function completed(workspace: PosWorkspace, print: boolean) {
    let failure: string | undefined;
    // The dishes are already at the table: the order is handed over as it is paid.
    try {
      await command(workspace, (current) => tenders.handover(current));
    } catch (error) {
      failure = t('payHandoverFailed', { reason: describeFailure(error, t) });
    }
    onCompleted(workspace.id, { print, failure });
  }

  if (!active)
    return (
      <section
        className="draft-workspace table-service table-service-pay"
        aria-label={t('payTitle')}
      >
        <SellingNotices selling={selling} />
        <div className="pay-empty">
          <button type="button" className="ticket-back" onClick={onBoard}>
            <PosIcon name="back" /> {t('boardOpen')}
          </button>
          <p className="ticket-empty">
            {selling.workspaces.query.isLoading ? t('workspaceLoading') : t('ticketNoOrder')}
          </p>
        </div>
      </section>
    );

  return (
    <section className="draft-workspace table-service table-service-pay" aria-label={t('payTitle')}>
      <SellingNotices selling={selling} />
      <PaymentPanel
        key={active.id}
        {...activePaymentProps(selling, active)}
        layout="fullscreen"
        defaultTender="vietqr"
        cashTip={data?.modules?.['fnb.postpay'] === true}
        bill={(controls) => (
          <PayBill selling={selling} active={active} controls={controls} onOrder={onOrder} />
        )}
        tools={(controls) => <PayTools selling={selling} active={active} controls={controls} />}
        onCompleted={(workspace, { print }) => void completed(workspace, print)}
      />
    </section>
  );
}

type Props = { selling: SellingWorkspace; active: PosWorkspace; controls: PaymentControls };

// The order may still change under the screen's own waiting QR (the QR is
// let go first); any other payment freezes it as on the ticket.
function canEditBill(selling: SellingWorkspace, active: PosWorkspace) {
  const live = (active.financial?.attempts ?? []).filter(
    (attempt) => attempt.status !== 'canceled' && attempt.status !== 'failed',
  );
  const onlyQr =
    live.length > 0 &&
    live.every((attempt) => attempt.kind === 'vietqr' && attempt.status === 'prepared');
  return !selling.sourceDisabled && (!active.payments || onlyQr);
}

// The bill: the order back, the table, its dishes, discounts and charges on
// lines of their own, and the total; a seated booking's deposit under it.
function PayBill({ selling, active, controls, onOrder }: Props & { onOrder: () => void }) {
  const { t } = useTranslation();
  const { data, activeTable, workspaces, command, locked, busy, isEditor } = selling;
  const currency = active.totals?.currency ?? 'VND';
  const lines = active.line_items ?? [];
  const count = lines.reduce((sum, line) => sum + Math.max(0, line.quantity), 0);
  const totals = active.totals;
  const charge = activeTable.serviceCharge;
  const mode = serviceModeOf(active.service_mode);
  const name = activeTable.table
    ? tableOrderName(activeTable.table.name, activeTable.label)
    : t(`serviceMode.${mode}`);
  const details = [
    activeTable.guestCount != null ? t('tableGuests', { count: activeTable.guestCount }) : null,
    active.order_id ? `#${active.order_id}` : null,
  ].filter((part): part is string => part !== null);

  // Back to the order: the waiting QR goes, so the order may change again.
  function back() {
    controls.hold(true);
    void controls.release().then((released) => {
      if (released) onOrder();
      else controls.hold(false);
    });
  }

  return (
    <aside className="pay-bill" aria-label={t('payBill')}>
      <div className="pay-bill-header">
        <button
          type="button"
          className="ticket-back"
          aria-label={t('payBackLabel')}
          disabled={controls.busy}
          onClick={back}
        >
          <PosIcon name="back" /> {t('payBack')}
        </button>
        <h2 className="pay-bill-name">
          <span>{name}</span>
          {details.length > 0 ? <small> · {details.join(' · ')}</small> : null}
        </h2>
      </div>
      <ul className="pay-bill-lines">
        {lines.map((line) => (
          <li key={line.id}>
            <span className="pay-bill-qty">{line.quantity}</span>
            <span className="pay-bill-item">{line.name}</span>
            <span className="pay-bill-amount">
              {formatMoney(String(ticketLineAmount(line)), currency)}
            </span>
          </li>
        ))}
      </ul>
      {totals ? (
        <div className="pay-bill-sum">
          <div className="checkout-line">
            <span>{t('paySubtotal', { count })}</span>
            <span>{formatMoney(totals.item_total, currency)}</span>
          </div>
          {Number(totals.discount_total) !== 0 ? (
            <div className="checkout-line pay-bill-discount">
              <span>
                {t('discount')}
                {active.coupon ? ` · ${active.coupon.code}` : ''}
              </span>
              <span>{formatMoney(totals.discount_total, currency)}</span>
            </div>
          ) : null}
          {active.delivery ? (
            <div className="checkout-line">
              <span>{t('deliveryFee')}</span>
              <span>{formatMoney(totals.fee_total ?? active.delivery.fee, currency)}</span>
            </div>
          ) : null}
          {charge?.applies && !charge.waived ? (
            <div className="checkout-line">
              <span>
                {t('tableServiceCharge')}
                {charge.rate ? ` (${charge.rate.replace(/\.0+$/, '')}%)` : ''}
              </span>
              <span>{formatMoney(charge.amount, currency)}</span>
            </div>
          ) : null}
          <MinimumSpendLines
            workspace={active}
            currency={currency}
            canApprove={Boolean(data?.capabilities.includes('pos.approval.grant'))}
            disabled={!canEditBill(selling, active) || controls.busy}
            onWaive={(waived, approvalId) =>
              controls.whileReleased(() =>
                command(active, (current) =>
                  workspaces.setMinimumSpend(current, waived, approvalId),
                ),
              )
            }
          />
          {(totals.taxes ?? []).map((tax) => (
            <div className="checkout-line" key={`${tax.rate}:${tax.label}`}>
              <span>
                {tax.label} ({rateLabel(tax.rate)})
              </span>
              <span>{formatMoney(tax.amount, currency)}</span>
            </div>
          ))}
          <div className="checkout-line pay-bill-total">
            <span>{t('payTotal')}</span>
            <strong>{formatMoney(totals.total, currency)}</strong>
          </div>
        </div>
      ) : (
        <p className="muted pay-bill-sum">{t('totalsUnavailable')}</p>
      )}
      {active.reservation ? (
        <ReservationDepositNote
          workspace={active}
          disabled={locked || busy || !isEditor || active.operational_status !== 'editing'}
          onApply={() =>
            controls.whileReleased(() =>
              command(active, (current) => workspaces.applyDeposits(current)),
            )
          }
        />
      ) : null}
    </aside>
  );
}

// The foot's tools beside "Chia đều": split by dish or by seat (the table's
// own split commands), the pre-bill, and delivery details. A tool that
// changes the order lets the waiting QR go while its dialog is open.
function PayTools({ selling, active, controls }: Props) {
  const { t } = useTranslation();
  const {
    data,
    selection,
    activeTable,
    kitchenOn,
    workspaces,
    command,
    editDisabled,
    lockReason,
    prebillOpen,
    setPrebillOpen,
  } = selling;
  const table = activeTable.table;
  const board = useResourceBoard(selection.branchId, table !== null);
  const [dialog, setDialog] = useState<PayDialog | null>(null);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const canEdit = canEditBill(selling, active) && !controls.busy;
  const lineCount = active.line_items?.length ?? 0;
  const delivery = data?.features?.delivery === true || Boolean(active.delivery);

  function open(next: PayDialog) {
    setError('');
    controls.hold(true);
    void controls.release().then((released) => {
      if (released) setDialog(next);
      else controls.hold(false);
    });
  }

  function close() {
    setDialog(null);
    controls.hold(false);
  }

  async function act(action: () => Promise<unknown>) {
    if (busy) return;
    setBusy(true);
    setError('');
    try {
      await action();
      close();
    } catch (failure) {
      setError(describeTableFailure(failure, t));
    } finally {
      setBusy(false);
    }
  }

  return (
    <>
      {table ? (
        <button
          type="button"
          className="pay-tool"
          disabled={!canEdit || lineCount < 2}
          title={lineCount < 2 ? t('tableFailure_split_all_lines') : lockReason}
          onClick={() => open('lines')}
        >
          {t('paySplitLines')}
        </button>
      ) : null}
      {table && kitchenOn ? (
        <button
          type="button"
          className="pay-tool"
          disabled={!canEdit || !canSplitBySeat(active)}
          onClick={() => open('seat')}
        >
          {t('paySplitSeats')}
        </button>
      ) : null}
      <button
        type="button"
        className="pay-tool"
        disabled={active.operational_status !== 'editing'}
        onClick={() => setPrebillOpen(true)}
      >
        {t('receiptPrebillOpen')}
      </button>
      {delivery ? (
        <button
          type="button"
          className="pay-tool"
          disabled={!canEdit}
          title={lockReason}
          onClick={() => open('delivery')}
        >
          <PosIcon name="box" /> {t('deliveryTitle')}
        </button>
      ) : null}
      {(dialog === 'lines' || dialog === 'seat') && table ? (
        <SplitOrderDialog
          workspace={active}
          tableId={table.id}
          tables={board.data?.resources ?? []}
          busy={busy}
          error={error}
          initialMode={dialog === 'seat' ? 'seat' : 'lines'}
          onClose={close}
          onSplit={(input) =>
            void act(() =>
              command(
                active,
                async (current) => (await workspaces.splitTable(current, input)).workspace,
              ),
            )
          }
          onSplitBySeat={
            kitchenOn
              ? (shared) =>
                  void act(() =>
                    command(
                      active,
                      async (current) => (await workspaces.splitBySeat(current, shared)).workspace,
                    ),
                  )
              : undefined
          }
        />
      ) : null}
      {dialog === 'delivery' ? (
        <div className="pos-popup-backdrop">
          <DeliveryForm
            key={`${active.id}:delivery:${active.revision}`}
            workspace={active}
            disabled={editDisabled}
            disabledReason={lockReason}
            onSave={(input) => command(active, (current) => workspaces.setDelivery(current, input))}
            onClear={() => command(active, (current) => workspaces.clearDelivery(current))}
            onClose={close}
          />
        </div>
      ) : null}
      {prebillOpen && active.operational_status === 'editing' ? (
        <ActivePrebillDialog selling={selling} active={active} />
      ) : null}
    </>
  );
}
