import { formatMoney, parseVndInput } from '@parkviet/pos-shared/money';
import { Link } from '@tanstack/react-router';
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { MenuGrid } from '../components/menu-grid';
import { ReceiptPrintPortal } from '../components/receipt-sheet';
import { useConnectivity, useOfflineQueue, useStoredSnapshot } from '../hooks/use-offline';
import { useSession } from '../hooks/use-session';
import {
  addLine,
  BLOCKED_OFFLINE,
  changeDue,
  changeQuantity,
  lineAmount,
  lineSignature,
  menuLine,
  provisionalNumber,
  queueBlock,
  saleTotal,
  sequenceCounter,
  snapshotState,
} from '../lib/offline-sales';
import { offlineSlipDocument } from '../lib/offline-slip';
import {
  emitOfflineChanged,
  type OfflineSaleLine,
  offlineDb,
  type QueuedSale,
} from '../lib/offline-store';
import type { PosModifierSelection } from '../lib/pos-context';
import { createBrowserPrintAdapter } from '../lib/print-adapter';

const adapter = createBrowserPrintAdapter();

// Selling while the server is out of reach: cash sales of menu items, from
// the snapshot this register stored while it was online. Each sale is kept
// in this browser under a provisional number and sent when the server
// answers; the server then prices it again, books the cash and issues the
// order, receipt and e-invoice. Nothing else is done offline.
export function OfflineSalePage() {
  const { t } = useTranslation();
  const session = useSession();
  const { online } = useConnectivity();
  const stored = useStoredSnapshot();
  const snapshot = stored.snapshot?.data ?? null;
  const state = stored.loaded ? snapshotState(stored.snapshot) : null;
  const queue = useOfflineQueue(snapshot?.staff.id ?? null, snapshot?.store.id ?? null);
  const [lines, setLines] = useState<OfflineSaleLine[]>([]);
  const [handed, setHanded] = useState('');
  const [notice, setNotice] = useState('');
  const [saving, setSaving] = useState(false);
  const [lastSale, setLastSale] = useState<QueuedSale | null>(null);
  const total = saleTotal(lines);
  const cash = parseVndInput(handed);
  const change = cash ? changeDue(total, cash) : null;
  const block = queue.loaded ? queueBlock(queue.sales) : null;
  const volatile = Boolean(offlineDb().volatile);
  const pending = queue.sales.filter((sale) => sale.status === 'pending').length;
  const failed = queue.sales.filter((sale) => sale.status === 'failed').length;
  const currency = snapshot?.store.currency ?? 'VND';
  const slip = useMemo(
    () => (lastSale && snapshot ? offlineSlipDocument(lastSale, snapshot, t) : null),
    [lastSale, snapshot, t],
  );

  const sellBlocked =
    state !== 'ready'
      ? t(`offlineState_${state ?? 'missing'}`)
      : volatile
        ? t('offlineStorageVolatile')
        : queue.unreadable
          ? t('offlineStorageVolatile')
          : block
            ? t(`offline_${block}`)
            : '';
  const payBlocked =
    lines.length === 0
      ? t('offlineEmptySale')
      : !(Number(total) > 0)
        ? t('offlineZeroTotal')
        : !cash
          ? t('offlineEnterCash')
          : change === null
            ? t('offlineCashShort')
            : '';

  async function add(
    variantId: string,
    extra: { modifiers?: PosModifierSelection[]; note?: string },
  ) {
    if (!snapshot?.menu) return;
    setNotice('');
    const line = menuLine(snapshot.menu, variantId, extra.modifiers, extra.note);
    if (!line) {
      setNotice(t('offlineItemUnavailable'));
      return;
    }
    const next = addLine(lines, line);
    if (next.refused) setNotice(t('offlineTooManyItems'));
    setLines(next.lines);
    setLastSale(null);
  }

  async function sell() {
    if (!snapshot?.shift || sellBlocked || payBlocked || !cash) return;
    setSaving(true);
    setNotice('');
    try {
      const now = new Date();
      const db = offlineDb();
      const timeZone = snapshot.branch.timezone;
      const sequence = await db.nextSequence(sequenceCounter(snapshot.register.id, now, timeZone));
      const sale: QueuedSale = {
        offlineId: crypto.randomUUID(),
        staffId: snapshot.staff.id,
        storeId: snapshot.store.id,
        branchId: snapshot.branch.id,
        registerId: snapshot.register.id,
        shiftId: snapshot.shift.id,
        provisionalNumber: provisionalNumber(snapshot.register.code, now, timeZone, sequence),
        soldAt: now.toISOString(),
        total,
        handedAmount: cash,
        currency,
        lines,
        status: 'pending',
        attempts: 0,
        lastError: null,
        savedAt: Date.now(),
      };
      await db.putSale(sale);
      emitOfflineChanged();
      setLastSale(sale);
      setLines([]);
      setHanded('');
    } catch {
      setNotice(t('offlineSaveFailed'));
    } finally {
      setSaving(false);
    }
  }

  async function printSlip() {
    if (!lastSale) return;
    await adapter.deliver('80mm', { title: lastSale.provisionalNumber });
  }

  const money = (value: string) => formatMoney(value, currency);

  return (
    <main className="layout pos-layout offline-sale">
      <header className="header">
        <strong>
          ParkViet <span>POS</span>
        </strong>
        <span className="header-title">{t('offlineSaleTitle')}</span>
        {snapshot ? (
          <span className="offline-sale-place">
            {snapshot.branch.name} · {snapshot.register.name} · {snapshot.staff.name}
          </span>
        ) : null}
        <span className="connection-status" data-offline={!online} role="status">
          <span className="connection-dot" />
          <span>{t(online ? 'offlineServerBack' : 'offlineServerAway')}</span>
        </span>
        <Link to="/">{t('offlineBackToSale')}</Link>
      </header>
      <section className="shell offline-sale-shell" aria-labelledby="offline-title">
        <h1 id="offline-title" className="offline-sale-heading">
          {t('offlineSaleTitle')}
        </h1>
        <div className="pos-context-card pos-alerts">
          <p className="offline-sale-rules" role="note">
            {t('offlineRules')}
          </p>
          {pending + failed > 0 ? (
            <p role="status">
              {t('offlineQueued', { count: pending })}
              {failed > 0 ? ` ${t('offlineFailedCount', { count: failed })}` : ''}
            </p>
          ) : null}
          {online && pending > 0 ? (
            // Sales are sent from the sale screen, as the cashier signed in there.
            <p role="status">
              {t(session.status === 'authenticated' ? 'offlineBackToSync' : 'offlineSignInToSync')}{' '}
              <Link to="/">{t('offlineBackToSale')}</Link>
            </p>
          ) : null}
          {sellBlocked ? (
            <p className="error" role="alert">
              {sellBlocked}
            </p>
          ) : null}
          <details className="offline-blocked">
            <summary>{t('offlineBlockedTitle')}</summary>
            <ul>
              {BLOCKED_OFFLINE.map((feature) => (
                <li key={feature}>{t(`offlineBlocked_${feature}`)}</li>
              ))}
            </ul>
          </details>
        </div>
        {snapshot?.menu && state === 'ready' ? (
          <div className="offline-sale-body">
            <MenuGrid
              branchId={snapshot.branch.id}
              menuData={snapshot.menu}
              addDisabled={Boolean(sellBlocked)}
              addDisabledReason={sellBlocked || undefined}
              canSetSoldOut={false}
              onAdd={(variantId, extra) => add(variantId, extra)}
            />
            <aside className="offline-cart" aria-label={t('offlineCart')}>
              <h3>{t('offlineCart')}</h3>
              {notice ? (
                <p className="workspace-hint" role="alert">
                  {notice}
                </p>
              ) : null}
              {lines.length === 0 ? <p className="muted">{t('offlineEmptySale')}</p> : null}
              <ul className="offline-cart-lines">
                {lines.map((line, index) => (
                  <li key={lineSignature(line)}>
                    <span className="offline-line-name">
                      {line.name}
                      {(line.modifier_names ?? []).map((name) => (
                        <small key={name}> + {name}</small>
                      ))}
                      {line.note ? <small> * {line.note}</small> : null}
                    </span>
                    <span className="offline-line-qty">
                      <button
                        type="button"
                        aria-label={t('decreaseQuantity', { name: line.name })}
                        onClick={() => setLines(changeQuantity(lines, index, -1))}
                      >
                        −
                      </button>
                      <output>{line.quantity}</output>
                      <button
                        type="button"
                        aria-label={t('increaseQuantity', { name: line.name })}
                        onClick={() => setLines(changeQuantity(lines, index, 1))}
                      >
                        +
                      </button>
                    </span>
                    <span className="offline-line-amount">{money(lineAmount(line))}</span>
                  </li>
                ))}
              </ul>
              <p className="offline-total">
                {t('offlineTotal')}: <strong>{money(total)}</strong>
              </p>
              <label>
                {t('offlineCashHanded')}
                <input
                  inputMode="numeric"
                  value={handed}
                  onChange={(event) => setHanded(event.target.value)}
                />
              </label>
              {change !== null ? (
                <p>
                  {t('offlineChange')}: <strong>{money(change)}</strong>
                </p>
              ) : null}
              <button
                type="button"
                className="primary"
                disabled={saving || Boolean(sellBlocked) || Boolean(payBlocked)}
                title={sellBlocked || payBlocked || undefined}
                onClick={() => void sell()}
              >
                {t('offlineTakeCash')}
              </button>
              {payBlocked && lines.length > 0 ? <p className="muted">{payBlocked}</p> : null}
              {lastSale ? (
                <div className="offline-saved" role="status">
                  <p>{t('offlineSaved', { number: lastSale.provisionalNumber })}</p>
                  <button type="button" onClick={() => void printSlip()}>
                    {t('offlinePrintSlip')}
                  </button>
                </div>
              ) : null}
            </aside>
          </div>
        ) : null}
      </section>
      {slip ? <ReceiptPrintPortal document={slip} paper="80mm" /> : null}
    </main>
  );
}
