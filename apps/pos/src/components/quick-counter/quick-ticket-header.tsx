import { formatMoney } from '@parkviet/pos-shared/money';
import { activePlatforms, type Platform, platformKey } from '@parkviet/pos-shared/platform-orders';
import type { ServiceMode } from '@parkviet/pos-shared/types/pos-context';
import { useTranslation } from 'react-i18next';
import { usePlatformSettings } from '../../hooks/use-platform-orders';
import type { PosWorkspace } from '../../lib/pos-context';
import { GuestNameField } from '../guest-name-field';
import { SellingMealScan } from '../scan-input';
import { serviceModeOf } from '../service-mode-control';
import type { SellingWorkspace } from '../workspace-tabs';

// The order paid last, shown at the head of the next ticket for a moment:
// its call number, the change to give back, and its receipt.
export type QuickDone = {
  workspaceId: string;
  number: number | null;
  change: string;
  currency: string;
};

// The two ways a counter order is served, one tap each.
const MODES: ServiceMode[] = ['takeaway', 'dine_in'];

// The head of the quick counter's ticket: the call number large (the one
// just paid while it is fresh), how the order is served (takeaway or eat in,
// one tap), and the guest's name printed on the cup labels. A delivery
// platform's chip stands apart: it does not change this order (a counter
// draft cannot become a platform's) but enters that platform's order, so it
// does not follow this order's lock. A canteen's meal code field heads it,
// there for every order whether one is on the ticket or not, and takes the
// focus back after each order (`refocus`).
export function QuickTicketHeader({
  selling,
  active,
  done,
  refocus,
  onMealPending,
  onPrint,
  onPlatform,
  onMore,
}: {
  selling: SellingWorkspace;
  active: PosWorkspace | null;
  done: QuickDone | null;
  refocus: string | number | null;
  onMealPending: (pending: boolean) => void;
  onPrint: (workspaceId: string) => void;
  onPlatform: (platform: Platform) => void;
  onMore: () => void;
}) {
  const { t } = useTranslation();
  const {
    data,
    selection,
    callNumbers,
    cupLabels,
    platformOrders,
    sourceDisabled,
    lockReason,
    locked,
    channelUnavailable,
    workspaces,
    command,
    run,
    mealAccounts,
  } = selling;
  const settings = usePlatformSettings(selection.branchId, platformOrders);
  const platforms = platformOrders ? activePlatforms(settings.data) : [];
  const canEnterPlatform = Boolean(
    data?.shift && data.shift.owner_id === data.staff.id && !locked && !channelUnavailable,
  );
  const mode = active ? serviceModeOf(active.service_mode) : 'counter';

  return (
    <div className="ticket-header quick-ticket-header">
      {mealAccounts ? (
        <SellingMealScan
          selling={selling}
          focusArea=".quick-counter"
          refocus={refocus}
          onBusyChange={onMealPending}
        />
      ) : null}
      <div className="ticket-header-row">
        {done ? (
          <p className="quick-call quick-call-done" role="status" data-testid="quick-done">
            <span className="quick-call-number">
              {done.number != null
                ? t('callNumber', { number: done.number })
                : t('quickDoneNoNumber')}
            </span>
            <small>
              {t('quickDone')}
              {done.change !== '0'
                ? ` · ${t('payChange')}: ${formatMoney(done.change, done.currency)}`
                : ''}
            </small>
          </p>
        ) : (
          <p className="quick-call" data-testid="call-number">
            {active?.order_number != null ? (
              <span className="quick-call-number">
                {t('callNumber', { number: active.order_number })}
                {active.guest_name ? <small> · {active.guest_name}</small> : null}
              </span>
            ) : callNumbers ? (
              <small>{t('quickCallNumberPending')}</small>
            ) : (
              <span className="quick-call-order">{active?.order_id ?? ''}</span>
            )}
          </p>
        )}
        {done ? (
          <button type="button" className="quick-print" onClick={() => onPrint(done.workspaceId)}>
            {t('receiptPrint')}
          </button>
        ) : null}
        <button
          type="button"
          className="ticket-more-button"
          aria-haspopup="dialog"
          aria-label={t('ticketMore')}
          title={t('ticketMore')}
          disabled={!active}
          onClick={onMore}
        >
          <span aria-hidden="true">⋯</span>
        </button>
      </div>
      {active ? (
        <fieldset className="quick-modes" disabled={sourceDisabled}>
          <legend className="visually-hidden">{t('serviceMode.label')}</legend>
          {MODES.map((value) => (
            <button
              key={value}
              type="button"
              aria-pressed={mode === value}
              onClick={() => {
                if (mode !== value)
                  void run(() =>
                    command(active, (current) => workspaces.setServiceMode(current, value)),
                  );
              }}
            >
              {value === 'dine_in' ? t('quickDineIn') : t(`serviceMode.${value}`)}
            </button>
          ))}
        </fieldset>
      ) : null}
      {platforms.length > 0 ? (
        <div className="quick-platforms">
          {platforms.map((platform) => (
            <button
              key={platform}
              type="button"
              className="quick-mode-platform"
              data-platform={platform}
              disabled={!canEnterPlatform}
              onClick={() => onPlatform(platform)}
            >
              {t(platformKey(platform))}
            </button>
          ))}
        </div>
      ) : null}
      {active && (callNumbers || cupLabels) ? (
        <GuestNameField
          key={`${active.id}:guest:${active.guest_name ?? ''}`}
          workspace={active}
          disabled={sourceDisabled}
          disabledReason={lockReason}
          onSave={(guestName) =>
            command(active, (current) => workspaces.setGuestName(current, guestName))
          }
        />
      ) : null}
    </div>
  );
}
