import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  type KitchenHistoryEntry,
  useKitchenHistory,
  useKitchenTickets,
} from '../hooks/use-kitchen';
import { unsentKitchenQuantity } from '../lib/kitchen';
import type { PosWorkspace } from '../lib/pos-context';
import { isTableOrder } from '../lib/tables';
import { PosIcon } from './pos-icon';

type Props = {
  workspace: PosWorkspace;
  // The branch sends on "Báo bếp" rather than as the sale completes. A table
  // order always does.
  manual: boolean;
  disabled: boolean;
  disabledReason?: string;
  onSend: () => Promise<unknown>;
};

const formatTime = (value: string) =>
  new Date(value).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });

const quantityText = (value: string) => String(Number(value));

// "Báo bếp" with the count of menu units not sent yet, and what the kitchen
// was told about this order: for a table order every send and void with who
// made it, otherwise its tickets with each item's status.
export function KitchenHistory({ workspace, manual, disabled, disabledReason, onSend }: Props) {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const [sending, setSending] = useState(false);
  const unsent = unsentKitchenQuantity(workspace);
  const table = isTableOrder(workspace);
  const hasMenu = (workspace.line_items ?? []).some((line) => line.kind === 'menu');
  const tickets = useKitchenTickets(workspace, hasMenu && open && !table);
  const history = useKitchenHistory(workspace, open && table);
  if (!hasMenu && !(table && (workspace.kitchen_sends?.length ?? 0) > 0)) return null;

  async function send() {
    setSending(true);
    try {
      await onSend();
    } finally {
      setSending(false);
    }
  }

  return (
    <section className="kitchen-history" aria-label={t('kitchenTitle')}>
      <div className="kitchen-history-actions">
        {manual || table ? (
          <button
            type="button"
            className="kitchen-send"
            disabled={disabled || sending || unsent === 0}
            title={unsent === 0 ? t('kitchenNothingToSend') : disabledReason}
            onClick={() => void send()}
          >
            <PosIcon name="play" /> {t('kitchenSend')}
            {unsent > 0 ? (
              <span className="kitchen-unsent" title={t('kitchenUnsent', { count: unsent })}>
                {unsent}
                <span className="visually-hidden">{t('kitchenUnsent', { count: unsent })}</span>
              </span>
            ) : null}
          </button>
        ) : null}
        <button type="button" aria-expanded={open} onClick={() => setOpen((value) => !value)}>
          {t('kitchenHistory')}
        </button>
      </div>
      {open && table ? (
        history.isPending ? (
          <p className="muted">{t('waiting')}</p>
        ) : history.isError ? (
          <p role="alert">{t('kitchenHistoryFailed')}</p>
        ) : history.data.length === 0 ? (
          <p className="muted">{t('kitchenNoTickets')}</p>
        ) : (
          <ol className="kitchen-tickets" data-testid="kitchen-history-entries">
            {history.data.map((entry, index) => (
              <HistoryEntry key={entry.id ?? `send-${index}`} entry={entry} />
            ))}
          </ol>
        )
      ) : open ? (
        tickets.isPending ? (
          <p className="muted">{t('waiting')}</p>
        ) : tickets.isError ? (
          <p role="alert">{t('kitchenHistoryFailed')}</p>
        ) : tickets.data.length === 0 ? (
          <p className="muted">{t('kitchenNoTickets')}</p>
        ) : (
          <ol className="kitchen-tickets">
            {tickets.data.map((ticket) => (
              <li key={ticket.id}>
                <strong>
                  {t('kitchenTicket', { number: ticket.sequence })} · {ticket.station_name} ·{' '}
                  {formatTime(ticket.sent_at)}
                </strong>
                <ul>
                  {ticket.items.map((item) => (
                    <li key={item.id}>
                      {quantityText(item.quantity)} × {item.name}
                      {item.modifiers.length > 0
                        ? ` (${item.modifiers.map((row) => row.name).join(', ')})`
                        : ''}{' '}
                      — {t(`kitchenStatus_${item.status}`)}
                    </li>
                  ))}
                </ul>
              </li>
            ))}
          </ol>
        )
      ) : null}
    </section>
  );
}

function HistoryEntry({ entry }: { entry: KitchenHistoryEntry }) {
  const { t } = useTranslation();
  const title =
    entry.kind === 'void'
      ? t('kitchenVoidEntry')
      : entry.sequence
        ? t('kitchenSendEntry', { number: entry.sequence })
        : t('kitchenSend');
  return (
    <li className={`kitchen-history-${entry.kind}`}>
      <strong>
        {title} · {formatTime(entry.at)}
        {entry.staff_name ? ` · ${entry.staff_name}` : ''}
      </strong>
      {entry.kind === 'void' ? (
        <p className="muted">
          {t(`kitchenVoidReason_${entry.reason_code}`, { defaultValue: entry.reason_code })}
          {entry.note ? `: ${entry.note}` : ''}
          {entry.wasted ? ` · ${t('kitchenEntryWasted')}` : ''}
          {entry.approver_name
            ? ` · ${t('kitchenEntryApprovedBy', { name: entry.approver_name })}`
            : ''}
        </p>
      ) : null}
      <ul>
        {entry.items.map((item, index) => (
          // biome-ignore lint/suspicious/noArrayIndexKey: a recorded entry's items never change or reorder.
          <li key={`${item.name}-${index}`}>
            {Number(item.quantity) > 0 ? '+' : ''}
            {quantityText(item.quantity)} × {item.name}
            {item.station_name ? ` · ${item.station_name}` : ''}
            {entry.kind === 'send' && item.status ? ` — ${t(`kitchenStatus_${item.status}`)}` : ''}
          </li>
        ))}
      </ul>
    </li>
  );
}
