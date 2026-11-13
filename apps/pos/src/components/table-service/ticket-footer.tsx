import { formatMoney } from '@parkviet/pos-shared/money';
import { rateLabel } from '@parkviet/pos-shared/receipt-template/data';
import { useTranslation } from 'react-i18next';
import type { PosWorkspace } from '../../lib/pos-context';
import { courseName } from '../../lib/table-courses';
import type { SellingWorkspace } from '../workspace-tabs';

// The course "Giữ món" holds the next dishes in when none was picked.
const HOLD_COURSE = 2;
const OPEN_STATUSES = ['editing', 'parked'];

// The foot of the table ticket: what the order holds and costs, the
// secondary tools (pre-bill, hold, send and stay), then the two big buttons
// "Gửi bếp (n)" and "Thanh toán · total".
export function TicketFooter({
  selling,
  active,
  pending,
  sending,
  onSend,
  onPay,
}: {
  selling: SellingWorkspace;
  active: PosWorkspace;
  // Units the next kitchen send takes.
  pending: number;
  sending: boolean;
  onSend: (stay: boolean) => void;
  onPay: () => void;
}) {
  const { t } = useTranslation();
  const {
    data,
    activeTable,
    kitchenOn,
    locked,
    busy,
    editDisabled,
    isEditor,
    canAppend,
    placement,
    setPlacement,
    setPrebillOpen,
  } = selling;
  const table = activeTable.table !== null;
  const currency = active.totals?.currency ?? 'VND';
  const branch = data?.branches.find((row) => row.id === active.branch_id);
  // A table order is always sent by hand; another order only when the
  // branch does not send as the sale completes.
  const canSend = kitchenOn && (table || branch?.kitchen_send_trigger !== 'on_complete');
  // Anyone serving a table sends its additions; another order is sent by
  // the person holding it.
  const sendLocked = table
    ? locked || busy || !OPEN_STATUSES.includes(active.operational_status)
    : editDisabled || !isEditor;
  const sendDisabled = sending || pending <= 0 || sendLocked;
  const canHold = kitchenOn && table && !active.payments;
  const count = (active.line_items ?? []).reduce(
    (sum, line) => sum + Math.max(0, line.quantity),
    0,
  );
  const charge = activeTable.serviceCharge;
  const summary = [
    t('ticketSummary', { count }),
    ...(charge?.applies && !charge.waived && charge.rate
      ? [t('ticketServiceCharge', { rate: charge.rate.replace(/\.0+$/, '') })]
      : []),
    ...(active.totals?.taxes ?? []).map((tax) => `${tax.label} ${rateLabel(tax.rate)}`),
  ];
  const placed = [
    placement.seat ? t('ticketSeat', { seat: placement.seat }) : null,
    placement.course ? courseName(placement.course) : null,
    placement.course && placement.hold ? t('ticketPlacementHeld') : null,
  ].filter((part): part is string => part !== null);

  return (
    <footer className="ticket-footer">
      <p className="ticket-summary">
        <span>{summary.join(' · ')}</span>
        {active.totals ? (
          <span>
            {t('ticketSubtotal', { amount: formatMoney(active.totals.item_total, currency) })}
          </span>
        ) : null}
      </p>
      {canHold && placed.length > 0 ? (
        <p className="ticket-placement" role="status">
          <span>{t('ticketPlacement', { place: placed.join(' · ') })}</span>
          <button type="button" disabled={!canAppend || busy} onClick={() => setPlacement({})}>
            {t('ticketPlacementClear')}
          </button>
        </p>
      ) : null}
      <div className="ticket-tools">
        <button
          type="button"
          disabled={active.operational_status !== 'editing'}
          onClick={() => setPrebillOpen(true)}
        >
          {t('receiptPrebillOpen')}
        </button>
        {canHold ? (
          <button
            type="button"
            aria-pressed={Boolean(placement.course && placement.hold)}
            disabled={!canAppend || busy}
            title={t('ticketHoldHint', { course: courseName(placement.course ?? HOLD_COURSE) })}
            onClick={() =>
              setPlacement(
                placement.course && placement.hold
                  ? { ...placement, hold: false }
                  : { ...placement, course: placement.course ?? HOLD_COURSE, hold: true },
              )
            }
          >
            {t('ticketHold')}
          </button>
        ) : null}
        {canSend ? (
          <button type="button" disabled={sendDisabled} onClick={() => onSend(true)}>
            {t('ticketSendStay')}
          </button>
        ) : null}
      </div>
      <div className={canSend ? 'ticket-main' : 'ticket-main ticket-main-single'}>
        {canSend ? (
          <button
            type="button"
            className="ticket-send"
            disabled={sendDisabled}
            onClick={() => onSend(false)}
          >
            {t('ticketSend', { count: pending })}
          </button>
        ) : null}
        <button type="button" className="ticket-pay" onClick={onPay}>
          <small>{t('ticketPay')}</small>{' '}
          <b>{formatMoney(active.totals?.total ?? '0', currency)}</b>
        </button>
      </div>
    </footer>
  );
}
