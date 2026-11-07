import { useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  canOpenDisplayWindow,
  openDisplayWindow,
  type PairingCode,
  useDisplaySession,
} from '../hooks/use-display';
import { pinDecision } from '../lib/display-generation';
import { formatMoney } from '../lib/money';
import type { PosWorkspace } from '../lib/pos-context';
import { conflictReason, describeFailure } from '../lib/request-failure';
import { FeatureOffNote } from './feature-off-note';

const DISPLAY_REASONS = [
  'display_ack_required',
  'display_busy',
  'display_inactive',
  'generation_stale',
];

// Cashier control of the customer display. Nothing here follows the active
// tab: the display changes only when the cashier pins or clears it.
// With the branch feature off nothing new reaches the customer: no bind, pin,
// pairing or rebind. Clearing and disconnecting a display that is already
// showing something stay available so it can always be emptied.
export function DisplayPinControl({
  shiftId,
  ownsShift,
  enabled = true,
  workspace,
}: {
  shiftId: string | null;
  ownsShift: boolean;
  enabled?: boolean;
  workspace: PosWorkspace | null;
}) {
  const { t } = useTranslation();
  const display = useDisplaySession(shiftId, ownsShift);
  const [message, setMessage] = useState('');
  const [pairing, setPairing] = useState<PairingCode | null>(null);
  const [revealed, setRevealed] = useState(false);
  const [now, setNow] = useState(() => Date.now());
  useEffect(() => {
    const timer = window.setInterval(() => setNow(Date.now()), 1000);
    return () => window.clearInterval(timer);
  }, []);
  const loaded = display.query.data ?? null;
  const busy =
    display.bind.isPending ||
    display.pin.isPending ||
    display.clear.isPending ||
    display.revoke.isPending ||
    display.pairing.isPending;
  if (!ownsShift || !shiftId) return null;

  // A failed poll or an answer older than the window proves nothing: the
  // cashier then sees the display as unconfirmed and cannot pin.
  const stale =
    display.query.isError ||
    (loaded !== null && now - display.query.dataUpdatedAt > loaded.freshness_ttl_seconds * 1000);
  const session = loaded && stale ? { ...loaded, ack_current: false } : loaded;

  const fail = (error: unknown) => {
    const reason = conflictReason(error);
    setMessage(
      reason && DISPLAY_REASONS.includes(reason)
        ? t(`display_${reason}`)
        : describeFailure(error, t),
    );
  };
  const act = (action: () => Promise<unknown>) => {
    setMessage('');
    action().catch(fail);
  };

  const decision = workspace ? pinDecision(session, workspace.id) : null;
  const waitingBank = (workspace?.financial?.attempts ?? []).filter(
    (attempt) => attempt.kind === 'bank_manual' && attempt.status === 'prepared',
  );
  const pinnable = enabled && workspace?.operational_status === 'editing';
  const freshness = !session
    ? null
    : session.ack_current && session.acked_generation === session.generation
      ? 'confirmed'
      : 'unconfirmed';
  // The override only makes sense once a device has been reading this display.
  const deviceSeen = Boolean(session?.last_seen_at || session?.acked_at);
  const pairingLive = pairing && new Date(pairing.expires_at).getTime() > now;

  return (
    <section className="display-control" aria-label={t('displayTitle')}>
      <h3>{t('displayTitle')}</h3>
      {!enabled ? <FeatureOffNote feature="customer_display" /> : null}
      {!session ? (
        enabled ? (
          <button
            type="button"
            disabled={busy}
            onClick={() => act(() => display.bind.mutateAsync())}
          >
            {t('displayBind')}
          </button>
        ) : null
      ) : (
        <>
          <p className="display-status" role="status" data-freshness={freshness}>
            {session.pinned_order_number
              ? t('displayShowing', { number: session.pinned_order_number })
              : t('displayShowingNothing')}
            {' · '}
            {t(freshness === 'confirmed' ? 'displayConfirmed' : 'displayUnconfirmed', {
              generation: session.generation,
            })}
          </p>
          {workspace && pinnable ? (
            <div className="row">
              <button
                type="button"
                disabled={busy || !decision?.allowed}
                onClick={() =>
                  act(() => display.pin.mutateAsync({ session, workspaceId: workspace.id }))
                }
              >
                {t('displayPinOrder')}
              </button>
              {waitingBank.map((attempt) => (
                <button
                  key={attempt.id}
                  type="button"
                  disabled={busy || !decision?.allowed}
                  onClick={() =>
                    act(() =>
                      display.pin.mutateAsync({
                        session,
                        workspaceId: workspace.id,
                        attemptId: attempt.id,
                      }),
                    )
                  }
                >
                  {t('displayPinBank', { amount: formatMoney(attempt.amount, attempt.currency) })}
                </button>
              ))}
            </div>
          ) : null}
          {decision && !decision.allowed && pinnable ? (
            <p className="muted">{t(`displayBlocked_${decision.reason}`)}</p>
          ) : null}
          {session.pinned_workspace_id ? (
            <>
              <button
                type="button"
                disabled={busy}
                onClick={() => act(() => display.clear.mutateAsync(session))}
              >
                {t('displayClear')}
              </button>
              <p className="muted display-warning">{t('displayClearWarning')}</p>
            </>
          ) : null}
          {!session.pinned_workspace_id && freshness === 'unconfirmed' && deviceSeen ? (
            <button
              type="button"
              className="danger"
              disabled={busy}
              onClick={() => {
                if (window.confirm(t('displayUnresponsiveConfirm')))
                  act(() =>
                    display.revoke.mutateAsync({ sessionId: session.id, reason: 'unresponsive' }),
                  );
              }}
            >
              {t('displayUnresponsive')}
            </button>
          ) : null}
          <details className="checkout-optional">
            <summary>{t('displayDevice')}</summary>
            <div className="row">
              {/* Opening the window only shows what the session already displays. */}
              <button
                type="button"
                disabled={busy || !canOpenDisplayWindow(session.id)}
                onClick={() => {
                  if (!openDisplayWindow(session.id)) setMessage(t('displayPopupBlocked'));
                }}
              >
                {t('displayOpenWindow')}
              </button>
              {enabled ? (
                <>
                  <button
                    type="button"
                    disabled={busy}
                    onClick={() =>
                      act(async () => {
                        setRevealed(false);
                        setPairing(await display.pairing.mutateAsync(session.id));
                      })
                    }
                  >
                    {t('displayPairingIssue')}
                  </button>
                  <button
                    type="button"
                    disabled={busy}
                    onClick={() => act(() => display.bind.mutateAsync())}
                  >
                    {t('displayRebind')}
                  </button>
                </>
              ) : null}
              <button
                type="button"
                disabled={busy}
                onClick={() =>
                  act(() => display.revoke.mutateAsync({ sessionId: session.id, reason: 'ended' }))
                }
              >
                {t('displayDisconnect')}
              </button>
            </div>
            {enabled && pairing && pairingLive ? (
              <p className="display-pairing" role="status">
                {t('displayPairingCode')}{' '}
                <strong data-testid="display-pairing-code">
                  {revealed ? `${pairing.code.slice(0, 4)}-${pairing.code.slice(4)}` : '••••-••••'}
                </strong>{' '}
                <button type="button" onClick={() => setRevealed((value) => !value)}>
                  {t(revealed ? 'displayPairingHide' : 'displayPairingReveal')}
                </button>{' '}
                <small>
                  {t('displayPairingExpires', {
                    minutes: Math.max(
                      1,
                      Math.ceil((new Date(pairing.expires_at).getTime() - now) / 60000),
                    ),
                  })}
                </small>
              </p>
            ) : null}
          </details>
        </>
      )}
      {message ? (
        <p className="error" role="alert">
          {message}
        </p>
      ) : null}
    </section>
  );
}
