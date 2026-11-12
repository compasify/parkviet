import { describeTraceFailure } from '@parkviet/pos-shared/traceability';
import { type FormEvent, useEffect, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { useOpenVehicleVisits, useVehicleVisitCommands } from '../hooks/use-vehicle-visits';
import type { PosWorkspace } from '../lib/pos-context';
import { conflictReason } from '../lib/request-failure';
import {
  minutesLeft,
  VEHICLE_TYPES,
  type VehicleType,
  vehicleReasonKey,
} from '../lib/vehicle-visits';

// "Coaches at the stop": the open visits with their guests and the minutes
// left before each closes by itself. Tapping a coach puts the current order on
// it (tapping it again takes it off); the order's price never changes. "New
// coach" opens a visit when one pulls in.
export function VehicleVisitBar({
  branchId,
  staffId,
  storeId,
  workspace,
  disabled,
  onAttach,
}: {
  branchId: string | null;
  staffId: string | null;
  storeId: string | null;
  workspace: PosWorkspace | null;
  disabled: boolean;
  onAttach: (visitId: string | null) => Promise<unknown>;
}) {
  const { t } = useTranslation();
  const visits = useOpenVehicleVisits(branchId, true);
  const commands = useVehicleVisitCommands(branchId, staffId, storeId);
  const [now, setNow] = useState(() => Date.now());
  const [adding, setAdding] = useState(false);
  const [plate, setPlate] = useState('');
  const [type, setType] = useState<VehicleType>('seat_29');
  const [guests, setGuests] = useState('');
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  const [error, setError] = useState('');

  useEffect(() => {
    const timer = window.setInterval(() => setNow(Date.now()), 30_000);
    return () => window.clearInterval(timer);
  }, []);

  function fail(failure: unknown) {
    const key = vehicleReasonKey(conflictReason(failure));
    setError(key ? t(key) : describeTraceFailure(failure, t));
  }

  async function open(event: FormEvent) {
    event.preventDefault();
    setBusy(true);
    setError('');
    setMessage('');
    try {
      const visit = await commands.open({
        plate,
        vehicleType: type,
        guestCount: Number.parseInt(guests, 10) || 0,
      });
      setMessage(
        visit.warnings.includes('plate_open_today')
          ? t('vehicleWarningPlateToday', { plate: visit.plate })
          : t('vehicleOpened', { plate: visit.plate }),
      );
      setPlate('');
      setGuests('');
      setAdding(false);
    } catch (failure) {
      fail(failure);
    } finally {
      setBusy(false);
    }
  }

  async function attach(visitId: string) {
    if (!workspace) return;
    setBusy(true);
    setError('');
    setMessage('');
    try {
      await onAttach(workspace.vehicle_visit_id === visitId ? null : visitId);
    } catch (failure) {
      fail(failure);
    } finally {
      setBusy(false);
    }
  }

  const rows = visits.data ?? [];
  const attachedId = workspace?.vehicle_visit_id ?? null;
  const attachDisabled = disabled || busy || !workspace;

  return (
    <section className="vehicle-visit-bar" aria-label={t('vehicleBarTitle')}>
      <div className="vehicle-visit-bar__head">
        <strong>{t('vehicleBarTitle')}</strong>
        <button type="button" onClick={() => setAdding((value) => !value)} disabled={busy}>
          {t('vehicleNew')}
        </button>
      </div>
      {adding ? (
        <form className="vehicle-visit-bar__form" onSubmit={open}>
          <label>
            {t('vehiclePlate')}
            <input
              value={plate}
              onChange={(event) => setPlate(event.target.value)}
              maxLength={20}
              required
              autoComplete="off"
            />
          </label>
          <label>
            {t('vehicleType')}
            <select value={type} onChange={(event) => setType(event.target.value as VehicleType)}>
              {VEHICLE_TYPES.map((item) => (
                <option key={item} value={item}>
                  {t(`vehicleType_${item}`)}
                </option>
              ))}
            </select>
          </label>
          <label>
            {t('vehicleGuests')}
            <input
              value={guests}
              onChange={(event) => setGuests(event.target.value.replace(/\D/g, ''))}
              inputMode="numeric"
            />
          </label>
          <button type="submit" disabled={busy || plate.trim() === ''}>
            {t('vehicleOpen')}
          </button>
        </form>
      ) : null}
      {rows.length === 0 ? (
        <p className="vehicle-visit-bar__empty">{t('vehicleNone')}</p>
      ) : (
        <ul className="vehicle-visit-bar__list">
          {rows.map((visit) => {
            const attached = attachedId === visit.id;
            return (
              <li key={visit.id}>
                <button
                  type="button"
                  aria-pressed={attached}
                  className={attached ? 'is-attached' : undefined}
                  disabled={attachDisabled}
                  onClick={() => void attach(visit.id)}
                  title={attached ? t('vehicleDetach') : t('vehicleAttach')}
                >
                  <span className="vehicle-visit-bar__plate">{visit.plate}</span>
                  {visit.bus_operator ? <span>{visit.bus_operator.name}</span> : null}
                  <span>{t('vehicleGuestCount', { count: visit.guest_count })}</span>
                  <span>{t('vehicleMinutesLeft', { count: minutesLeft(visit, now) })}</span>
                </button>
              </li>
            );
          })}
        </ul>
      )}
      {message ? <p role="status">{message}</p> : null}
      {error ? <p role="alert">{error}</p> : null}
    </section>
  );
}
