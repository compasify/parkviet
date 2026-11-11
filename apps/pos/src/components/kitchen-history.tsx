import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useKitchenTickets } from '../hooks/use-kitchen';
import { unsentKitchenQuantity } from '../lib/kitchen';
import type { PosWorkspace } from '../lib/pos-context';
import { PosIcon } from './pos-icon';

type Props = {
  workspace: PosWorkspace;
  // The branch sends on "Báo bếp" rather than as the sale completes.
  manual: boolean;
  disabled: boolean;
  disabledReason?: string;
  onSend: () => Promise<unknown>;
};

const formatTime = (value: string) =>
  new Date(value).toLocaleTimeString('vi-VN', { hour: '2-digit', minute: '2-digit' });

const quantityText = (value: string) => String(Number(value));

// "Báo bếp" with the count of menu units not sent yet, and what the kitchen
// was told about this order, send by send, with each item's status.
export function KitchenHistory({ workspace, manual, disabled, disabledReason, onSend }: Props) {
  const { t } = useTranslation();
  const [open, setOpen] = useState(false);
  const [sending, setSending] = useState(false);
  const unsent = unsentKitchenQuantity(workspace);
  const hasMenu = (workspace.line_items ?? []).some((line) => line.kind === 'menu');
  const tickets = useKitchenTickets(workspace, hasMenu && open);
  if (!hasMenu) return null;

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
        {manual ? (
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
      {open ? (
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
