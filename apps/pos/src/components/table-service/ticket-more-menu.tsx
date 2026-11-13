import { useId, useRef } from 'react';
import { useTranslation } from 'react-i18next';
import { useModalFocus } from '../../lib/dialog-focus';
import type { PosWorkspace } from '../../lib/pos-context';
import { coverLines } from '../../lib/table-courses';
import { useBuffetTiers } from '../buffet-tier-picker';
import { CourseSeatPicker } from '../course-seat-picker';
import { PosIcon } from '../pos-icon';
import {
  ActiveBuffetPicker,
  ActiveCustomerPanel,
  ActiveDiscountForm,
  ActiveNoteForm,
  ActiveTableOrderBar,
  type SellingWorkspace,
} from '../workspace-tabs';

export type TicketMorePanel =
  | 'menu'
  | 'table'
  | 'discount'
  | 'note'
  | 'customer'
  | 'course'
  | 'buffet';

type Props = {
  selling: SellingWorkspace;
  active: PosWorkspace;
  panel: TicketMorePanel;
  onPanel: (panel: TicketMorePanel) => void;
  onClose: () => void;
  // The order was canceled: back to the board.
  onCanceled: () => void;
};

// The rarer tools of a table order behind "⋯" (and behind the table's name):
// moving, merging and splitting the table with its service charge, the
// order's discount, note and customer, course and seat of the next dishes,
// the buffet tickets, and cancelling the order. Each runs the command the
// counter's basket runs.
export function TicketMoreMenu(props: Props) {
  const { selling, active, panel, onClose } = props;
  // The order's discount and note keep the counter's own popup forms.
  if (panel === 'discount')
    return (
      <div className="pos-popup-backdrop">
        <ActiveDiscountForm
          key={`${active.id}:${active.revision}:${active.discount?.id ?? 'new'}:${active.coupon?.code ?? 'no-coupon'}`}
          selling={selling}
          active={active}
          onClose={onClose}
        />
      </div>
    );
  if (panel === 'note')
    return (
      <div className="pos-popup-backdrop">
        <ActiveNoteForm
          key={`${active.id}:note:${active.note ?? ''}`}
          selling={selling}
          active={active}
          onClose={onClose}
        />
      </div>
    );
  return <MoreDialog key={panel} {...props} />;
}

const PANEL_TITLES: Record<TicketMorePanel, string> = {
  menu: 'ticketMore',
  table: 'ticketTableTools',
  discount: 'discountTitle',
  note: 'noteTitle',
  customer: 'customerTitle',
  course: 'coursePickerTitle',
  buffet: 'ticketBuffet',
};

function MoreDialog({ selling, active, panel, onPanel, onClose, onCanceled }: Props) {
  const { t } = useTranslation();
  const card = useRef<HTMLDivElement>(null);
  const titleId = useId();
  useModalFocus(card, onClose);
  const {
    activeTable,
    kitchenOn,
    canAppend,
    busy,
    locked,
    isEditor,
    placement,
    setPlacement,
    workspaces,
    command,
    run,
  } = selling;
  const table = activeTable.table !== null;
  const tableKitchen = table && kitchenOn && !active.payments;
  const tiers = useBuffetTiers(selling.selection.branchId, tableKitchen);
  const buffet = (tiers.data?.length ?? 0) > 0 || coverLines(active).length > 0;
  const canCancel =
    !busy && !locked && isEditor && active.operational_status !== 'canceled' && !active.payments;

  function cancelOrder() {
    if (!window.confirm(t('cancelDraftConfirm', { order: active.order_id }))) return;
    void run(() => command(active, (current) => workspaces.change(current, 'cancel'))).then(
      (canceled) => {
        if (canceled) onCanceled();
      },
    );
  }

  const entries: Array<{ panel: TicketMorePanel; shown: boolean }> = [
    { panel: 'table', shown: table },
    { panel: 'discount', shown: true },
    { panel: 'note', shown: true },
    { panel: 'customer', shown: true },
    { panel: 'course', shown: tableKitchen },
    { panel: 'buffet', shown: tableKitchen && buffet },
  ];

  return (
    <div className="pos-popup-backdrop">
      <div
        ref={card}
        role="dialog"
        aria-modal="true"
        aria-labelledby={titleId}
        tabIndex={-1}
        className="pos-popup-card ticket-more"
      >
        <div className="pos-popup-header">
          {panel !== 'menu' ? (
            <button
              type="button"
              aria-label={t('ticketMoreBack')}
              title={t('ticketMoreBack')}
              onClick={() => onPanel('menu')}
            >
              <PosIcon name="back" />
            </button>
          ) : null}
          <h4 id={titleId}>{t(PANEL_TITLES[panel])}</h4>
          <button
            type="button"
            aria-label={t('ticketClose')}
            title={t('ticketClose')}
            onClick={onClose}
          >
            <PosIcon name="close" />
          </button>
        </div>
        {panel === 'menu' ? (
          <div className="ticket-more-list">
            {entries
              .filter((entry) => entry.shown)
              .map((entry) => (
                <button key={entry.panel} type="button" onClick={() => onPanel(entry.panel)}>
                  {t(PANEL_TITLES[entry.panel])}
                </button>
              ))}
            <button
              type="button"
              className="ticket-danger"
              disabled={!canCancel}
              title={active.payments ? t('cancelDraftPayments') : undefined}
              onClick={cancelOrder}
            >
              {t('ticketCancelOrder')}
            </button>
          </div>
        ) : panel === 'table' ? (
          <ActiveTableOrderBar key={active.id} selling={selling} active={active} />
        ) : panel === 'customer' ? (
          <ActiveCustomerPanel key={active.id} selling={selling} active={active} />
        ) : panel === 'course' ? (
          <CourseSeatPicker
            workspace={active}
            value={placement}
            onChange={setPlacement}
            disabled={!canAppend || busy}
            onFire={(course) =>
              command(active, (current) => workspaces.fireCourse(current, course))
            }
          />
        ) : panel === 'buffet' ? (
          <ActiveBuffetPicker selling={selling} active={active} />
        ) : null}
      </div>
    </div>
  );
}
