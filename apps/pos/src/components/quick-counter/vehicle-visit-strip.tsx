import { useState } from 'react';
import { useTranslation } from 'react-i18next';
import {
  useOpenVehicleVisits,
  useVehicleVisitCommands,
  type VehicleVisitDraft,
} from '../../hooks/use-vehicle-visits';
import {
  canOperateVehicleVisits,
  unpaidOnVisit,
  type VehicleVisit,
} from '../../lib/vehicle-visits';
import {
  describeVehicleFailure,
  VehicleVisitOpenForm,
  vehicleOpenedText,
} from '../vehicle-visit-bar';
import type { SellingWorkspace } from '../workspace-tabs';

// The coaches at a rest stop, above the quick counter's menu: each open
// visit with its plate, its coach company and the orders put on it. Tapping a
// coach puts the order on the ticket on it (tapping it again takes it off);
// the price never changes. "+ Lượt xe" records a coach pulling in and "Chốt
// lượt" closes one that left, asking once more first and warning of orders
// on it still unpaid here, with the same commands as the counter's coach
// bar; both are for staff allowed to operate the visits.
export function VehicleVisitStrip({ selling }: { selling: SellingWorkspace }) {
  const { t } = useTranslation();
  const {
    data,
    active,
    rows: orders,
    selection,
    staffId,
    storeId,
    editable,
    channelUnavailable,
    command,
    workspaces,
  } = selling;
  const canOperate = canOperateVehicleVisits(data?.capabilities);
  const branchId = selection.branchId;
  const visits = useOpenVehicleVisits(branchId, true);
  const commands = useVehicleVisitCommands(branchId, staffId, storeId);
  const [adding, setAdding] = useState(false);
  // The coach whose closing waits for a second tap.
  const [closing, setClosing] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  async function act(task: () => Promise<void>) {
    if (busy) return;
    setBusy(true);
    setError('');
    setMessage('');
    try {
      await task();
    } catch (failure) {
      setError(describeVehicleFailure(failure, t));
    } finally {
      setBusy(false);
    }
  }

  async function open(draft: VehicleVisitDraft) {
    let opened = false;
    await act(async () => {
      setMessage(vehicleOpenedText(await commands.open(draft), t));
      setAdding(false);
      opened = true;
    });
    return opened;
  }

  function attach(visit: VehicleVisit) {
    const order = active;
    if (!order) return;
    const visitId = order.vehicle_visit_id === visit.id ? null : visit.id;
    void act(async () => {
      await command(order, (current) => workspaces.vehicleVisit(current, visitId));
      // The count of orders on each coach moved.
      void visits.refetch();
    });
  }

  function close(visit: VehicleVisit) {
    void act(async () => {
      await commands.close(visit);
      setClosing(null);
      setMessage(t('vehicleStripClosed', { plate: visit.plate }));
    });
  }

  const rows = visits.data ?? [];
  const attachedId = active?.vehicle_visit_id ?? null;
  const attachDisabled = busy || !active || !editable || channelUnavailable;

  return (
    <section className="vehicle-strip" aria-label={t('vehicleBarTitle')}>
      <div className="vehicle-strip-row">
        <strong className="vehicle-strip-title">{t('vehicleBarTitle')}</strong>
        {rows.length === 0 ? (
          <span className="vehicle-strip-empty">{t('vehicleNone')}</span>
        ) : (
          <ul className="vehicle-strip-list">
            {rows.map((visit) => {
              const attached = attachedId === visit.id;
              const unpaid =
                closing === visit.id
                  ? unpaidOnVisit(active ? [active, ...orders] : orders, visit.id)
                  : 0;
              return (
                <li key={visit.id} className="vehicle-strip-visit">
                  <button
                    type="button"
                    className="vehicle-strip-coach"
                    aria-pressed={attached}
                    disabled={attachDisabled}
                    title={attached ? t('vehicleDetach') : t('vehicleAttach')}
                    onClick={() => attach(visit)}
                  >
                    <span className="vehicle-strip-plate">{visit.plate}</span>
                    {visit.bus_operator ? <span>{visit.bus_operator.name}</span> : null}
                    <span>
                      {t('vehicleGuestCount', { count: visit.guest_count })}
                      {visit.workspaces_count != null
                        ? ` · ${t('vehicleStripOrders', { count: visit.workspaces_count })}`
                        : ''}
                    </span>
                  </button>
                  {!canOperate ? null : closing === visit.id ? (
                    <>
                      {unpaid > 0 ? (
                        <span className="vehicle-strip-warning" role="alert">
                          {t('vehicleStripCloseUnpaid', { count: unpaid })}
                        </span>
                      ) : null}
                      <button
                        type="button"
                        className="vehicle-strip-confirm"
                        disabled={busy}
                        onClick={() => close(visit)}
                      >
                        {t('vehicleStripCloseConfirm', { plate: visit.plate })}
                      </button>
                      <button type="button" disabled={busy} onClick={() => setClosing(null)}>
                        {t('vehicleStripCancel')}
                      </button>
                    </>
                  ) : (
                    <button
                      type="button"
                      disabled={busy}
                      aria-label={t('vehicleStripCloseLabel', { plate: visit.plate })}
                      onClick={() => setClosing(visit.id)}
                    >
                      {t('vehicleStripClose')}
                    </button>
                  )}
                </li>
              );
            })}
          </ul>
        )}
        {canOperate ? (
          <button
            type="button"
            className="vehicle-strip-new"
            aria-expanded={adding}
            disabled={busy}
            onClick={() => setAdding((value) => !value)}
          >
            {t('vehicleStripNew')}
          </button>
        ) : null}
      </div>
      {adding && canOperate ? (
        <VehicleVisitOpenForm className="vehicle-strip-form" busy={busy} onOpen={open} />
      ) : null}
      {message ? (
        <p className="vehicle-strip-message" role="status">
          {message}
        </p>
      ) : null}
      {error ? (
        <p className="error vehicle-strip-message" role="alert">
          {error}
        </p>
      ) : null}
    </section>
  );
}
