import { useTranslation } from 'react-i18next';
import type { PosWorkspace } from '../../lib/pos-context';
import { tableOrderName } from '../../lib/tables';
import { PosIcon } from '../pos-icon';
import { serviceModeOf } from '../service-mode-control';
import type { SellingWorkspace } from '../workspace-tabs';
import type { TicketMorePanel } from './ticket-more-menu';

// When the order was opened; servers before it was sent give nothing.
function openedAt(workspace: PosWorkspace): number | null {
  const value = (workspace as { opened_at?: unknown }).opened_at;
  const at = typeof value === 'string' ? Date.parse(value) : Number.NaN;
  return Number.isNaN(at) ? null : at;
}

// Who serves the order: the person who added its first line.
function serverOf(workspace: PosWorkspace): string | null {
  return (workspace.line_items ?? []).find((line) => line.added_by?.name)?.added_by?.name ?? null;
}

// The head of the table ticket: back to the board, the table (tap to move,
// merge or split it), the rarer tools behind "⋯", then the guests, how long
// they have been seated, who serves them and how the order is served.
export function TicketHeader({
  selling,
  active,
  now,
  onBoard,
  onMore,
}: {
  selling: SellingWorkspace;
  active: PosWorkspace;
  now: number;
  onBoard: () => void;
  onMore: (panel: TicketMorePanel) => void;
}) {
  const { t } = useTranslation();
  const order = selling.activeTable;
  const opened = openedAt(active);
  const minutes = opened === null ? null : Math.max(0, Math.floor((now - opened) / 60_000));
  const server = serverOf(active);
  const mode = serviceModeOf(active.service_mode);
  return (
    <div className="ticket-header">
      <div className="ticket-header-row">
        <button
          type="button"
          className="ticket-back"
          aria-label={t('ticketBackLabel')}
          onClick={onBoard}
        >
          <PosIcon name="back" /> {order.table ? t('ticketBack') : t('boardOpen')}
        </button>
        {order.table ? (
          <button
            type="button"
            className="ticket-name"
            aria-haspopup="dialog"
            title={t('ticketTableTools')}
            onClick={() => onMore('table')}
          >
            <span>{tableOrderName(order.table.name, order.label)}</span>
            <PosIcon name="chevron" />
          </button>
        ) : (
          <h2 className="ticket-name">
            <span>{t(`serviceMode.${mode}`)}</span>
            <small>{active.order_id}</small>
          </h2>
        )}
        <button
          type="button"
          className="ticket-more-button"
          aria-haspopup="dialog"
          aria-label={t('ticketMore')}
          title={t('ticketMore')}
          onClick={() => onMore('menu')}
        >
          <span aria-hidden="true">⋯</span>
        </button>
      </div>
      <ul className="ticket-chips">
        {order.guestCount != null ? (
          <li>
            <PosIcon name="user" /> {t('tableGuests', { count: order.guestCount })}
          </li>
        ) : null}
        {minutes !== null ? (
          <li title={t('ticketSeated', { minutes })}>
            <span className="visually-hidden">{t('ticketSeated', { minutes })}</span>
            <span aria-hidden="true">{minutes}′</span>
          </li>
        ) : null}
        {server ? <li>{t('ticketServer', { name: server })}</li> : null}
        <li>{t(`serviceMode.${mode}`)}</li>
        {order.paymentRequest?.status === 'open' ? (
          <li className="ticket-chip-payment">{t('tableState_payment_requested')}</li>
        ) : null}
        {order.prebill?.status === 'current' ? (
          <li className="ticket-chip-prebilled">
            {t('tablePrebillPrinted', { number: order.prebill.sequence })}
          </li>
        ) : null}
      </ul>
    </div>
  );
}
