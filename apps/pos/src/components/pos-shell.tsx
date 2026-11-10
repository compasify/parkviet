import { Link, Outlet, useLocation, useNavigate } from '@tanstack/react-router';
import { useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useReceiptTemplates } from '../hooks/use-receipt-templates';
import { useSession } from '../hooks/use-session';
import { session } from '../lib/app-session';
import { commandQueue } from '../lib/command-queue';
import {
  FINANCIAL_RECOVERY_CHANGED,
  type FinancialRecoveryState,
  financialRecoveryState,
  forgetFinancialRecord,
  scopedFinancialRecords,
} from '../lib/financial-recovery';
import { writesLocked } from '../lib/pos-context';
import { posDashboardUrl } from '../lib/pos-dashboard-url';
import { queryClient } from '../lib/query-client';
import { failureStatus, posFailureKey } from '../lib/request-failure';
import {
  forgetIntent,
  hasPendingIntents,
  hasUncertainIntents,
  INTENTS_CHANGED,
  scopedIntents,
} from '../lib/uncertain-intents';
import { ContextSelector } from './context-selector';
import { ContextSetupDialog } from './context-setup-dialog';
import { OpenShiftDialog } from './open-shift-dialog';
import { PosIcon } from './pos-icon';
import { PosSelectionProvider, usePosSelection } from './pos-selection';
import { ScannerCalibrationDialog } from './scanner-calibration';
import { UserMenu } from './user-menu';

export function PosShell() {
  return (
    <PosSelectionProvider>
      <ShellFrame />
    </PosSelectionProvider>
  );
}

function ShellFrame() {
  const { t } = useTranslation();
  const navigate = useNavigate();
  const snapshot = useSession();
  const { context, selection, registerMode } = usePosSelection();
  // Print templates load with the POS, so the first print never waits for them.
  useReceiptTemplates(true);
  const pathname = useLocation({ select: (location) => location.pathname.replace(/\/+$/, '') });
  const pageTitle = pathname.endsWith('/payment-attention')
    ? t('attentionNav')
    : pathname.endsWith('/funds')
      ? t('fundsNav')
      : pathname.endsWith('/receivables')
        ? t('receivablesNav')
        : pathname.endsWith('/credit-accounts')
          ? t('creditAccountsNav')
          : pathname.endsWith('/credit-approvals')
            ? t('creditApprovalsNav')
            : pathname.endsWith('/orders')
              ? t('ordersNav')
              : pathname.endsWith('/deliveries')
                ? t('deliveriesNav')
                : pathname.endsWith('/returns')
                  ? t('returnsNav')
                  : pathname.endsWith('/shifts')
                    ? t('shiftsNav')
                    : pathname.endsWith('/reports')
                      ? t('reportsNav')
                      : pathname.endsWith('/inventory')
                        ? t('inventoryNav')
                        : pathname.endsWith('/receipts')
                          ? t('receiptsTitle')
                          : t('sellingArea');
  const isSale =
    !/\/(funds|receivables|credit-accounts|credit-approvals|payment-attention|orders|deliveries|returns|shifts|reports|inventory|receipts)(\/|$)/.test(
      pathname,
    );
  // A store not set up yet, seen by someone who may set it up, is pointed at
  // the setup wizard of the POS dashboard instead of the branch picker dialog.
  // Without that permission the picker asks for an administrator
  // (context-selector.tsx).
  const setupNeeded = Boolean(
    context.data?.onboarding?.required && context.data.onboarding.can_setup,
  );
  const setupUrl = setupNeeded ? posDashboardUrl(context.data?.store.id, 'setup') : null;
  const contextPicker = useRef<HTMLDetailsElement>(null);
  // A header navigation must not leave the picker covering the destination page.
  // biome-ignore lint/correctness/useExhaustiveDependencies: the route change is the dismissal trigger
  useEffect(() => {
    if (contextPicker.current) contextPicker.current.open = false;
  }, [pathname]);
  useEffect(() => {
    const dismiss = (event: Event) => {
      if (event.target instanceof Node && !contextPicker.current?.contains(event.target)) {
        if (contextPicker.current) contextPicker.current.open = false;
      }
    };
    const onEscape = (event: KeyboardEvent) => {
      if (event.key === 'Escape' && contextPicker.current?.open) {
        contextPicker.current.open = false;
        contextPicker.current.querySelector('summary')?.focus();
      }
    };
    document.addEventListener('pointerdown', dismiss);
    document.addEventListener('focusin', dismiss);
    document.addEventListener('keydown', onEscape);
    return () => {
      document.removeEventListener('pointerdown', dismiss);
      document.removeEventListener('focusin', dismiss);
      document.removeEventListener('keydown', onEscape);
    };
  }, []);
  const [online, setOnline] = useState(() => globalThis.navigator?.onLine !== false);
  const [busy, setBusy] = useState(false);
  const [calibrating, setCalibrating] = useState(false);
  const [logoutError, setLogoutError] = useState('');
  const [intentsVersion, setIntentsVersion] = useState(0);
  const [financialVersion, setFinancialVersion] = useState(0);
  const [financialState, setFinancialState] = useState<FinancialRecoveryState>({
    pending: 0,
    storageUnavailable: false,
  });
  const [checkingIntents, setCheckingIntents] = useState(false);
  const [recoveryCheck, setRecoveryCheck] = useState<{
    staffId: string;
    storeId: string;
    confirmed: number;
    notCommitted: number;
    missing: number;
    blocked: number;
    failed: number;
  } | null>(null);

  useEffect(() => {
    if (snapshot.status === 'anonymous') void navigate({ to: '/login' });
  }, [navigate, snapshot.status]);

  useEffect(() => {
    const onOnline = () => setOnline(true);
    const onOffline = () => setOnline(false);
    const onVisible = () => {
      if (document.visibilityState === 'visible') void session.resume();
    };
    const onLeave = (event: BeforeUnloadEvent) => {
      if (!commandQueue.hasPending() && !hasPendingIntents() && !hasUncertainIntents()) return;
      event.preventDefault();
    };
    const onIntentsChanged = () => setIntentsVersion((version) => version + 1);
    const onFinancialChanged = () => setFinancialVersion((version) => version + 1);
    window.addEventListener('online', onOnline);
    window.addEventListener('offline', onOffline);
    document.addEventListener('visibilitychange', onVisible);
    window.addEventListener('beforeunload', onLeave);
    window.addEventListener(INTENTS_CHANGED, onIntentsChanged);
    window.addEventListener(FINANCIAL_RECOVERY_CHANGED, onFinancialChanged);
    return () => {
      window.removeEventListener('online', onOnline);
      window.removeEventListener('offline', onOffline);
      document.removeEventListener('visibilitychange', onVisible);
      window.removeEventListener('beforeunload', onLeave);
      window.removeEventListener(INTENTS_CHANGED, onIntentsChanged);
      window.removeEventListener(FINANCIAL_RECOVERY_CHANGED, onFinancialChanged);
    };
  }, []);

  useEffect(() => {
    void financialVersion;
    let active = true;
    const staffId = context.data?.staff.id;
    const storeId = context.data?.store.id;
    if (!staffId || !storeId) {
      setFinancialState({ pending: 0, storageUnavailable: false });
      return;
    }
    void financialRecoveryState(staffId, storeId).then((value) => {
      if (active) setFinancialState(value);
    });
    return () => {
      active = false;
    };
  }, [context.data?.staff.id, context.data?.store.id, financialVersion]);

  async function logout() {
    if (
      (commandQueue.hasPending() ||
        hasPendingIntents() ||
        hasUncertainIntents() ||
        financialUncertain) &&
      !window.confirm(t('unsent'))
    )
      return;
    setBusy(true);
    setLogoutError('');
    try {
      await session.logout();
    } catch {
      setLogoutError(t('logoutFailure'));
    } finally {
      setBusy(false);
    }
  }

  async function checkIntents(staffId: string, storeId: string) {
    setCheckingIntents(true);
    setRecoveryCheck(null);
    const result = {
      staffId,
      storeId,
      confirmed: 0,
      notCommitted: 0,
      missing: 0,
      blocked: 0,
      failed: 0,
    };
    function recordFailure(error: unknown) {
      const failure = posFailureKey(error);
      if (failure === 'missing') result.missing++;
      else if (failure === 'forbidden' || failure === 'unauthorized') result.blocked++;
      else result.failed++;
    }
    try {
      for (const intent of scopedIntents(staffId, storeId)) {
        try {
          await session.request('GET', '/pos/command_receipts', {
            params: { idempotency_key: intent.key },
          });
          forgetIntent(intent.scope);
          result.confirmed++;
        } catch (error) {
          recordFailure(error);
          // A missing or inaccessible receipt does not prove the command cannot commit.
        }
      }
      for (const record of await scopedFinancialRecords(staffId, storeId)) {
        try {
          await session.request('GET', '/pos/command_receipts', {
            params: { idempotency_key: record.idempotencyKey },
          });
          await forgetFinancialRecord(record.scope);
          result.confirmed++;
        } catch (error) {
          // The receipt is written in the command's own transaction: no receipt
          // for this user means the money command never committed.
          if (failureStatus(error) === 404) {
            await forgetFinancialRecord(record.scope);
            result.notCommitted++;
            continue;
          }
          recordFailure(error);
          // Keep financial evidence for manual reconciliation; never mint a new tender.
        }
      }
      await queryClient.invalidateQueries({ queryKey: ['pos', 'workspaces'] });
      await queryClient.invalidateQueries({ queryKey: ['pos', 'received-funds'] });
    } catch (error) {
      recordFailure(error);
    } finally {
      setRecoveryCheck(result);
      setCheckingIntents(false);
    }
  }

  const failure = context.error ? posFailureKey(context.error) : null;
  const financialUncertain = financialState.pending > 0;
  const store = context.data?.store;
  void intentsVersion;
  const uncertain =
    context.data && hasUncertainIntents(context.data.staff.id, context.data.store.id);
  // From the sale screen, other pages open in a new tab so the open invoices
  // keep their edit lease (see UserMenu).
  const newTab = isSale ? ({ target: '_blank', rel: 'noopener' } as const) : {};
  const offline = !online || failure === 'offline';
  const connection = offline
    ? t('connectionOffline')
    : context.isPending
      ? t('contextWaiting')
      : t('connectionOnline');
  const branch = context.data?.branches.find((item) => item.id === selection.branchId);
  const register = context.data?.registers.find((item) => item.id === selection.registerId);

  return (
    <main className={`layout pos-layout${isSale ? ' pos-sale' : ''}`}>
      <a className="skip-link" href={isSale ? '#pos-product-search' : '#pos-page-title'}>
        {t(isSale ? 'skipToSale' : 'skipToContent')}
      </a>
      <header className="header">
        {isSale ? (
          <h1 id="title" className="visually-hidden">
            {t('sellingArea')}
          </h1>
        ) : null}
        <strong>
          ParkViet <span>POS</span>
        </strong>
        <span className="header-title">{pageTitle}</span>
        <details className="pos-context-details" ref={contextPicker}>
          <summary title={t('changeContext')}>
            <span>
              <b className="context-label">{t('branch')}:</b> {branch?.name ?? t('chooseBranch')}
            </span>
            {registerMode === 'required' || selection.registerId ? (
              <span>
                <b className="context-label">{t('register')}:</b>{' '}
                {register?.name ?? t('chooseRegister')}
              </span>
            ) : null}
            <span className="context-change">
              <span className="visually-hidden">{t('changeContext')}</span>
              <PosIcon name="chevron" />
            </span>
          </summary>
          <div className="context-popover">
            <p className="context-account">{snapshot.name}</p>
            <ContextSelector
              onRegisterSelected={() => {
                if (contextPicker.current) contextPicker.current.open = false;
              }}
            />
            {store ? (
              <p>
                {t('storeLine', { name: store.name || store.id, currency: store.currency || '—' })}
              </p>
            ) : null}
          </div>
        </details>
        <div className="pos-context-status">
          <span
            className="connection-status"
            data-offline={offline}
            role="status"
            title={connection}
          >
            <span className="connection-dot" />
            <span className={offline ? '' : 'visually-hidden'}>{connection}</span>
          </span>
          {isSale ? (
            <span>{context.data?.shift ? t('shiftOpenCompact') : t('shiftNotOpen')}</span>
          ) : null}
        </div>
        <UserMenu
          name={snapshot.name}
          data={context.data}
          branchId={selection.branchId}
          registerId={selection.registerId}
          isSale={isSale}
          busy={busy}
          onCalibrate={() => setCalibrating(true)}
          onLogout={() => void logout()}
        />
      </header>
      {calibrating && selection.registerId ? (
        <ScannerCalibrationDialog
          registerId={selection.registerId}
          onClose={() => setCalibrating(false)}
        />
      ) : null}
      <ContextSetupDialog enabled={isSale && !setupNeeded} />
      <section className="shell" aria-labelledby={isSale ? 'title' : 'pos-page-title'}>
        <div className="pos-context-card pos-alerts">
          {context.data?.sales_channel && context.data.sales_channel.status !== 'active' ? (
            <p className="error" role="status">
              {t(
                context.data.sales_channel.status === 'missing'
                  ? 'pos_channel_missing'
                  : 'pos_channel_inactive',
              )}
            </p>
          ) : null}
          {setupNeeded ? (
            <p role="status">
              {t('setup.requiredInDashboard')}{' '}
              {setupUrl ? (
                <a href={setupUrl} target="_blank" rel="noopener">
                  {t('setup.openDashboard')}
                </a>
              ) : null}
            </p>
          ) : null}
          {isSale && context.data && writesLocked(context.data, selection) ? (
            <p className="error" role="status">
              {t('writesLocked')}
            </p>
          ) : null}
        </div>
        {/* Recovery notices float over the page: they come and go with the
            outcome of a request and must not push the sale screen around. */}
        <div className="pos-floating-alerts" aria-live="polite">
          {uncertain ? (
            <p className="error" role="status">
              {t('uncertainWarning')}
            </p>
          ) : null}
          {financialState.storageUnavailable ? (
            <p className="error" role="status">
              {t('financialStorageWarning')}{' '}
              <Link to="/payment-attention" {...newTab}>
                {t('fundsAttentionTitle')}
              </Link>
            </p>
          ) : null}
          {financialUncertain ? (
            <p className="error" role="status">
              {t('financialUncertainWarning')}{' '}
              <Link to="/payment-attention" {...newTab}>
                {t('fundsAttentionTitle')}
              </Link>
            </p>
          ) : null}
          {(uncertain || financialUncertain) && context.data ? (
            <button
              type="button"
              disabled={checkingIntents}
              onClick={() => void checkIntents(context.data.staff.id, context.data.store.id)}
            >
              {checkingIntents
                ? t('waiting')
                : t(financialUncertain ? 'checkFinancialRecovery' : 'checkUncertain')}
            </button>
          ) : null}
          {recoveryCheck &&
          recoveryCheck.staffId === context.data?.staff.id &&
          recoveryCheck?.storeId === context.data?.store.id ? (
            <div className="recovery-check-result" role="status" aria-live="polite">
              <p>{t('recoveryChecked', { count: recoveryCheck.confirmed })}</p>
              {recoveryCheck.notCommitted > 0 ? (
                <p>{t('recoveryNotCommitted', { count: recoveryCheck.notCommitted })}</p>
              ) : null}
              {recoveryCheck.missing > 0 ? (
                <p>{t('recoveryMissing', { count: recoveryCheck.missing })}</p>
              ) : null}
              {recoveryCheck.blocked > 0 ? (
                <p>{t('recoveryBlocked', { count: recoveryCheck.blocked })}</p>
              ) : null}
              {recoveryCheck.failed > 0 ? (
                <p>{t('recoveryFailed', { count: recoveryCheck.failed })}</p>
              ) : null}
            </div>
          ) : null}
        </div>
        <div className="pos-context-card pos-alerts">
          {logoutError && (
            <p className="error" role="alert">
              {logoutError}
            </p>
          )}
          {failure && failure !== 'offline' && (
            <p className="error" role="alert">
              {t(failure)}
            </p>
          )}
          {isSale && context.data && context.data.capabilities.length === 0 ? (
            <p>{t('capabilitiesEmpty')}</p>
          ) : null}
          {isSale ? <OpenShiftDialog /> : null}
        </div>
        <Outlet />
      </section>
    </main>
  );
}
