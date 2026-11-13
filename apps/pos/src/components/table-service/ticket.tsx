import {
  groupTicketLines,
  pendingKitchenUnits,
  TICKET_GROUP_MODES,
  type TicketGroupMode,
} from '@parkviet/pos-shared/ticket-groups';
import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { commandQueue } from '../../lib/command-queue';
import { PosIcon } from '../pos-icon';
import {
  ActivePrebillDialog,
  ActiveVoidDialog,
  orderTimeZone,
  type SellingWorkspace,
} from '../workspace-tabs';
import { TicketFooter } from './ticket-footer';
import { TicketHeader } from './ticket-header';
import { TicketLines } from './ticket-lines';
import { TicketMoreMenu, type TicketMorePanel } from './ticket-more-menu';

// The grouping picked on this device.
const GROUP_KEY = 'parkviet-pos:ticket-group';

function savedMode(): TicketGroupMode {
  try {
    const value = localStorage.getItem(GROUP_KEY);
    return (TICKET_GROUP_MODES as readonly string[]).includes(value ?? '')
      ? (value as TicketGroupMode)
      : 'round';
  } catch {
    return 'round';
  }
}

function saveMode(mode: TicketGroupMode) {
  try {
    localStorage.setItem(GROUP_KEY, mode);
  } catch {
    // A device that keeps nothing groups by send next time.
  }
}

// Minutes on the ticket (seated, cooking) move on by themselves.
function useNow(intervalMs = 30_000): number {
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    const timer = window.setInterval(() => setNow(Date.now()), intervalMs);
    return () => window.clearInterval(timer);
  }, [intervalMs]);
  return now;
}

// The table ticket beside the menu: who sits there and since when, the
// dishes grouped by send, course or seat with the unsent ones on top, and
// the kitchen send and payment at the foot. A send returns to the board;
// "Gửi & ở lại" stays on the order.
export function Ticket({
  selling,
  onBoard,
  onPay,
  onNotice,
}: {
  selling: SellingWorkspace;
  onBoard: () => void;
  onPay: () => void;
  // A short confirmation the screen shows, on the board too.
  onNotice: (text: string) => void;
}) {
  const { t, i18n } = useTranslation();
  const { active, activeTable, kitchenOn, workspaces, command, run, busy, lockReason, isEditor } =
    selling;
  const [mode, setMode] = useState<TicketGroupMode>(savedMode);
  const [more, setMore] = useState<TicketMorePanel | null>(null);
  const [sending, setSending] = useState(false);
  const now = useNow();

  if (!active)
    return (
      <aside className="ticket" aria-label={t('tableTicketTitle')}>
        <div className="ticket-header">
          <div className="ticket-header-row">
            <button
              type="button"
              className="ticket-back"
              aria-label={t('ticketBackLabel')}
              onClick={onBoard}
            >
              <PosIcon name="back" /> {t('boardOpen')}
            </button>
          </div>
        </div>
        <p className="ticket-empty">{t('ticketNoOrder')}</p>
      </aside>
    );

  const table = activeTable.table !== null;
  // Takeaway and delivery orders have no seats.
  const modes = TICKET_GROUP_MODES.filter((value) => table || value !== 'seat');
  const shown: TicketGroupMode = modes.includes(mode) ? mode : 'round';
  const groups = groupTicketLines(active, shown);
  const pending = pendingKitchenUnits(active);
  const timeZone = orderTimeZone(selling, active);
  const clock = {
    now,
    time: (value: string) =>
      new Date(value).toLocaleTimeString(i18n.language, {
        hour: '2-digit',
        minute: '2-digit',
        timeZone,
      }),
  };

  async function send(stay: boolean) {
    if (!active || sending) return;
    const count = pending;
    setSending(true);
    try {
      const sent = await run(() => command(active, (current) => workspaces.sendToKitchen(current)));
      if (!sent) return;
      onNotice(t('ticketSent', { count }));
      if (!stay) onBoard();
    } finally {
      setSending(false);
    }
  }

  return (
    <aside className="ticket" aria-label={t('tableTicketTitle')}>
      <TicketHeader
        selling={selling}
        active={active}
        now={now}
        onBoard={onBoard}
        onMore={setMore}
      />
      {kitchenOn ? (
        <fieldset className="ticket-view">
          <legend>{t('ticketGroupBy')}</legend>
          {modes.map((value) => (
            <button
              key={value}
              type="button"
              aria-pressed={shown === value}
              onClick={() => {
                setMode(value);
                saveMode(value);
              }}
            >
              {t(`ticketGroup_${value}`)}
            </button>
          ))}
        </fieldset>
      ) : null}
      <TicketLines
        key={active.id}
        selling={selling}
        active={active}
        groups={groups}
        mode={shown}
        plain={!kitchenOn}
        clock={clock}
      />
      {lockReason && isEditor ? (
        <p className="workspace-hint ticket-hint" role="status">
          {lockReason}
        </p>
      ) : null}
      {busy || commandQueue.hasPending(active.id) ? (
        <p className="muted ticket-hint" role="status">
          {t('waiting')}
        </p>
      ) : null}
      <TicketFooter
        selling={selling}
        active={active}
        pending={pending}
        sending={sending}
        onSend={(stay) => void send(stay)}
        onPay={onPay}
      />
      {more ? (
        <TicketMoreMenu
          selling={selling}
          active={active}
          panel={more}
          onPanel={setMore}
          onClose={() => setMore(null)}
          onCanceled={() => {
            setMore(null);
            onBoard();
          }}
        />
      ) : null}
      {selling.prebillOpen && active.operational_status === 'editing' ? (
        <ActivePrebillDialog selling={selling} active={active} />
      ) : null}
      {selling.voiding?.sale_line_id ? (
        <ActiveVoidDialog
          key={selling.voiding.id}
          selling={selling}
          active={active}
          line={selling.voiding}
        />
      ) : null}
    </aside>
  );
}
