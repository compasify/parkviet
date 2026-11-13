import { formatMoney } from '@parkviet/pos-shared/money';
import {
  depositStatusKey,
  RESERVATIONS_MODULE,
  type Reservation,
  reservationActions,
  reservationStatusKey,
  timelineSpan,
} from '@parkviet/pos-shared/reservations';
import { useNavigate } from '@tanstack/react-router';
import { useMemo, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { RemoteApprovalButton } from '../components/remote-approval-button';
import {
  useAvailability,
  useReservationCommands,
  useReservations,
} from '../hooks/use-reservations';
import { useResourceBoard } from '../hooks/use-resource-board';
import { workspaceEditorId } from '../hooks/use-workspaces';
import { type ApprovalAsk, askFromFailure } from '../lib/approval-requests';
import { writesLocked } from '../lib/pos-context';
import { conflictReason, posFailureKey } from '../lib/request-failure';

// Today in the device's zone, as the date input wants it.
function today(): string {
  const now = new Date();
  const local = new Date(now.getTime() - now.getTimezoneOffset() * 60_000);
  return local.toISOString().slice(0, 10);
}

function timeOf(iso: string, language: string) {
  return new Date(iso).toLocaleTimeString(language, { hour: '2-digit', minute: '2-digit' });
}

// The local date-time of the form, as an instant the server reads.
function instant(local: string): string {
  const value = new Date(local);
  return Number.isNaN(value.getTime()) ? '' : value.toISOString();
}

const HOURS = Array.from({ length: 13 }, (_, index) => index + 10);

export function ReservationsPage() {
  const { context, selection } = usePosSelection();
  // Another staff, store or branch never keeps the previous day on screen.
  const scope = `${context.data?.staff.id}:${context.data?.store.id}:${selection.branchId}`;
  return <Reservations key={scope} />;
}

function Reservations() {
  const { t } = useTranslation();
  const { context, selection } = usePosSelection();
  const data = context.data;
  const branchId = selection.branchId;
  const capabilities = data?.capabilities ?? [];
  const enabled = data?.modules?.[RESERVATIONS_MODULE] === true;
  const canBook = capabilities.includes('pos.reservation.manage');
  const [date, setDate] = useState(today);
  const day = useReservations(branchId, date, enabled);
  const board = useResourceBoard(branchId, enabled);
  const commands = useReservationCommands(branchId, workspaceEditorId);
  const locked = writesLocked(data, selection);
  return (
    <PosPage title={t('reservationsTitle')} description={t('reservationsHint')}>
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !branchId ? (
        <PageState title={t('chooseBranch')} description={t('pageChooseBranchHint')} />
      ) : !enabled ? (
        <PageState title={t('posModules.fnb_reservations.off')} />
      ) : (
        <>
          <div className="page-toolbar">
            <label>
              {t('reservationsDate')}
              <input type="date" value={date} onChange={(event) => setDate(event.target.value)} />
            </label>
          </div>
          {canBook ? (
            <BookingForm
              branchId={branchId}
              date={date}
              disabled={locked}
              onBook={(draft) => commands.create(draft)}
            />
          ) : null}
          {day.isLoading ? <PageState kind="loading" title={t('waiting')} /> : null}
          {day.isError ? <PageState kind="error" title={t(posFailureKey(day.error))} /> : null}
          {day.isSuccess ? (
            <>
              <Timeline
                rows={day.data.rows}
                from={day.data.from}
                tables={(board.data?.resources ?? []).map((row) => ({
                  id: row.id,
                  name: row.name,
                }))}
              />
              {day.data.rows.length === 0 ? (
                <PageState kind="empty" title={t('reservationsEmpty')} />
              ) : (
                <ul className="record-list reservation-list" aria-label={t('reservationsList')}>
                  {day.data.rows.map((row) => (
                    <ReservationRow
                      key={row.id}
                      reservation={row}
                      disabled={locked}
                      canBook={canBook}
                      canCollect={capabilities.includes('pos.payment.collect')}
                      commands={commands}
                    />
                  ))}
                </ul>
              )}
            </>
          ) : null}
        </>
      )}
    </PosPage>
  );
}

// The day as rows of tables, each booking a block from its start to its end.
function Timeline({
  rows,
  from,
  tables,
}: {
  rows: Reservation[];
  from: string | null;
  tables: { id: string; name: string }[];
}) {
  const { t, i18n } = useTranslation();
  if (!from || tables.length === 0) return null;
  const start = HOURS[0] * 60;
  const span = (HOURS.length - 1) * 60;
  return (
    <section className="reservation-timeline" aria-label={t('reservationsTimeline')}>
      <div className="reservation-timeline-hours" aria-hidden="true">
        <span />
        {HOURS.map((hour) => (
          <span key={hour}>{`${hour}:00`}</span>
        ))}
      </div>
      {tables.map((table) => (
        <div className="reservation-timeline-row" key={table.id}>
          <strong>{table.name}</strong>
          <div className="reservation-timeline-track">
            {rows
              .filter((row) => row.resources.some((resource) => resource.id === table.id))
              .filter((row) => row.status === 'booked' || row.status === 'seated')
              .map((row) => {
                const place = timelineSpan(row, from);
                if (!place) return null;
                const left = Math.max(0, ((place.start - start) / span) * 100);
                const width = Math.max(
                  2,
                  ((place.end - Math.max(place.start, start)) / span) * 100,
                );
                return (
                  <span
                    key={row.id}
                    className={`reservation-block reservation-block-${row.status}`}
                    style={{ left: `${left}%`, width: `${Math.min(width, 100 - left)}%` }}
                    title={`${row.guest_name} · ${timeOf(row.starts_at, i18n.language)}`}
                  >
                    {row.guest_name} ({row.party_size})
                  </span>
                );
              })}
          </div>
        </div>
      ))}
    </section>
  );
}

function BookingForm({
  branchId,
  date,
  disabled,
  onBook,
}: {
  branchId: string;
  date: string;
  disabled: boolean;
  onBook: (draft: {
    guestName: string;
    phone: string;
    partySize: number;
    startsAt: string;
    note: string;
    resourceIds: string[];
  }) => Promise<unknown>;
}) {
  const { t } = useTranslation();
  const [guestName, setGuestName] = useState('');
  const [phone, setPhone] = useState('');
  const [partySize, setPartySize] = useState(2);
  const [time, setTime] = useState('19:00');
  const [note, setNote] = useState('');
  const [tableId, setTableId] = useState('');
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  const startsAt = useMemo(() => instant(`${date}T${time}`), [date, time]);
  const free = useAvailability(branchId, startsAt ? { startsAt, partySize } : null);
  const tables = free.data ?? [];
  const chosen = tables.some((row) => row.id === tableId) ? tableId : (tables[0]?.id ?? '');
  return (
    <form
      className="reservation-form"
      aria-label={t('reservationsNew')}
      onSubmit={(event) => {
        event.preventDefault();
        if (!guestName.trim() || !chosen || !startsAt) return;
        setBusy(true);
        setMessage('');
        void onBook({
          guestName: guestName.trim(),
          phone,
          partySize,
          startsAt,
          note,
          resourceIds: [chosen],
        })
          .then(() => {
            setGuestName('');
            setPhone('');
            setNote('');
            setMessage(t('reservationsBooked'));
          })
          .catch((error) => setMessage(failureText(t, error)))
          .finally(() => setBusy(false));
      }}
    >
      <h2>{t('reservationsNew')}</h2>
      <label>
        {t('reservationsGuest')}
        <input
          value={guestName}
          maxLength={80}
          required
          onChange={(event) => setGuestName(event.target.value)}
        />
      </label>
      <label>
        {t('reservationsPhone')}
        <input
          value={phone}
          maxLength={20}
          inputMode="tel"
          onChange={(event) => setPhone(event.target.value)}
        />
      </label>
      <label>
        {t('reservationsParty')}
        <input
          type="number"
          min={1}
          max={999}
          value={partySize}
          onChange={(event) => setPartySize(Math.max(1, Number(event.target.value) || 1))}
        />
      </label>
      <label>
        {t('reservationsTime')}
        <input
          type="time"
          value={time}
          required
          onChange={(event) => setTime(event.target.value)}
        />
      </label>
      <label>
        {t('reservationsTable')}
        <select value={chosen} onChange={(event) => setTableId(event.target.value)}>
          {tables.length === 0 ? <option value="">{t('reservationsNoTable')}</option> : null}
          {tables.map((row) => (
            <option key={row.id} value={row.id}>
              {row.capacity > 0
                ? `${row.name} · ${t('tableCapacity', { count: row.capacity })}`
                : row.name}
            </option>
          ))}
        </select>
      </label>
      <label>
        {t('reservationsNote')}
        <input value={note} maxLength={500} onChange={(event) => setNote(event.target.value)} />
      </label>
      <button
        type="submit"
        className="checkout-submit"
        disabled={disabled || busy || !chosen || !guestName.trim()}
      >
        {busy ? t('waiting') : t('reservationsBook')}
      </button>
      {message ? (
        <p className="workspace-hint" role="status">
          {message}
        </p>
      ) : null}
    </form>
  );
}

function failureText(
  t: (key: string, options?: Record<string, unknown>) => string,
  error: unknown,
) {
  const reason = conflictReason(error);
  return reason
    ? t(`reservationFailure_${reason}`, { defaultValue: t(posFailureKey(error)) })
    : t(posFailureKey(error));
}

function ReservationRow({
  reservation,
  disabled,
  canBook,
  canCollect,
  commands,
}: {
  reservation: Reservation;
  disabled: boolean;
  canBook: boolean;
  canCollect: boolean;
  commands: ReturnType<typeof useReservationCommands>;
}) {
  const { t, i18n } = useTranslation();
  const navigate = useNavigate();
  const actions = reservationActions(reservation);
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  const [depositOpen, setDepositOpen] = useState(false);
  const [amount, setAmount] = useState('');
  const [kind, setKind] = useState<'cash' | 'bank_manual'>('cash');
  const [reference, setReference] = useState('');
  const [account, setAccount] = useState('');
  // A refund or forfeit refused for want of an approval waits for its code.
  const [pending, setPending] = useState<{
    kind: 'refund' | 'forfeit';
    depositId: string;
    ask: ApprovalAsk | null;
  } | null>(null);
  const [approvalId, setApprovalId] = useState('');
  const currency = reservation.deposits[0]?.currency || 'VND';
  const act = (work: () => Promise<unknown>) => {
    setBusy(true);
    setMessage('');
    void work()
      .catch((error) => setMessage(failureText(t, error)))
      .finally(() => setBusy(false));
  };
  const resolve = (which: 'refund' | 'forfeit', depositId: string, approval?: string) =>
    act(async () => {
      try {
        await (which === 'refund'
          ? commands.refundDeposit(depositId, approval)
          : commands.forfeitDeposit(depositId, approval));
        setPending(null);
        setApprovalId('');
      } catch (error) {
        if (conflictReason(error) === 'approval_required') {
          setPending({
            kind: which,
            depositId,
            ask: askFromFailure(error, { revision: String(reservation.revision) }),
          });
          setMessage(t('reservationsApprovalNeeded'));
          return;
        }
        throw error;
      }
    });
  const held = reservation.deposits.find((row) => row.status === 'held');
  const refundable = reservation.deposits.find(
    (row) => (row.status === 'held' || row.status === 'applied') && Number(row.available) > 0,
  );
  const locked = disabled || busy;
  return (
    <li className="reservation-row" data-status={reservation.status}>
      <div className="record-copy">
        <strong>
          {timeOf(reservation.starts_at, i18n.language)} · {reservation.guest_name}
        </strong>
        <small>
          {t('tableGuests', { count: reservation.party_size })}
          {reservation.phone ? ` · ${reservation.phone}` : ''}
          {reservation.resources.length
            ? ` · ${reservation.resources.map((row) => row.name).join(', ')}`
            : ''}
        </small>
        <span className="status-tag">{t(reservationStatusKey(reservation.status))}</span>
        {reservation.note ? <small className="muted">{reservation.note}</small> : null}
        {reservation.deposits.map((deposit) => (
          <small key={deposit.id} className="reservation-deposit">
            {t('reservationsDeposit')}: {formatMoney(deposit.amount, deposit.currency || currency)}{' '}
            · {t(depositStatusKey(deposit.status))}
          </small>
        ))}
      </div>
      <div className="row reservation-actions">
        {canBook && actions.seat ? (
          <button
            type="button"
            className="checkout-submit"
            disabled={locked}
            onClick={() =>
              act(async () => {
                const seated = await commands.seat(reservation.id);
                // The sale opens the order the URL names by its order id.
                await navigate({
                  to: '/',
                  search: seated.orderId ? { order: seated.orderId } : {},
                });
              })
            }
          >
            {t('reservationsSeat')}
          </button>
        ) : null}
        {canCollect && actions.takeDeposit ? (
          <button type="button" disabled={locked} onClick={() => setDepositOpen((open) => !open)}>
            {t('reservationsTakeDeposit')}
          </button>
        ) : null}
        {canBook && actions.noShow ? (
          <button
            type="button"
            disabled={locked}
            onClick={() => act(() => commands.cancel(reservation.id, 'no_show'))}
          >
            {t('reservationsNoShow')}
          </button>
        ) : null}
        {canBook && actions.cancel ? (
          <button
            type="button"
            disabled={locked}
            onClick={() => {
              if (window.confirm(t('reservationsCancelConfirm', { name: reservation.guest_name })))
                act(() => commands.cancel(reservation.id, 'canceled'));
            }}
          >
            {t('reservationsCancel')}
          </button>
        ) : null}
        {actions.refundDeposit && refundable ? (
          <button type="button" disabled={locked} onClick={() => resolve('refund', refundable.id)}>
            {t('reservationsRefund')}
          </button>
        ) : null}
        {canCollect && actions.forfeitDeposit && held ? (
          <button type="button" disabled={locked} onClick={() => resolve('forfeit', held.id)}>
            {t('reservationsForfeit')}
          </button>
        ) : null}
      </div>
      {depositOpen ? (
        <form
          className="reservation-deposit-form"
          aria-label={t('reservationsTakeDeposit')}
          onSubmit={(event) => {
            event.preventDefault();
            act(async () => {
              await commands.takeDeposit(reservation.id, {
                kind,
                amount,
                reference: kind === 'bank_manual' ? reference : undefined,
                receivingAccount: kind === 'bank_manual' ? account : undefined,
              });
              setDepositOpen(false);
              setAmount('');
            });
          }}
        >
          <label>
            {t('reservationsDepositAmount')}
            <input
              inputMode="numeric"
              value={amount}
              required
              onChange={(event) => setAmount(event.target.value)}
            />
          </label>
          <label>
            {t('reservationsDepositKind')}
            <select
              value={kind}
              onChange={(event) => setKind(event.target.value as 'cash' | 'bank_manual')}
            >
              <option value="cash">{t('reservationsDepositCash')}</option>
              <option value="bank_manual">{t('reservationsDepositBank')}</option>
            </select>
          </label>
          {kind === 'bank_manual' ? (
            <>
              <label>
                {t('reservationsDepositReference')}
                <input
                  value={reference}
                  required
                  onChange={(event) => setReference(event.target.value)}
                />
              </label>
              <label>
                {t('reservationsDepositAccount')}
                <input
                  value={account}
                  required
                  onChange={(event) => setAccount(event.target.value)}
                />
              </label>
            </>
          ) : null}
          <button type="submit" className="checkout-submit" disabled={locked || !amount}>
            {busy ? t('waiting') : t('reservationsDepositSave')}
          </button>
        </form>
      ) : null}
      {pending ? (
        <form
          className="reservation-approval-form"
          onSubmit={(event) => {
            event.preventDefault();
            resolve(pending.kind, pending.depositId, approvalId.trim());
          }}
        >
          <label>
            {t('reservationsApprovalCode')}
            <input
              value={approvalId}
              required
              onChange={(event) => setApprovalId(event.target.value)}
            />
          </label>
          <button type="submit" disabled={locked || !approvalId.trim()}>
            {pending.kind === 'refund' ? t('reservationsRefund') : t('reservationsForfeit')}
          </button>
          <RemoteApprovalButton
            branchId={reservation.branch_id}
            subject={{ reservation_id: reservation.id }}
            ask={pending.ask}
            disabled={locked}
            onGranted={(id) => {
              setApprovalId(id);
              resolve(pending.kind, pending.depositId, id);
            }}
          />
        </form>
      ) : null}
      {message ? (
        <p className="workspace-hint" role="status">
          {message}
        </p>
      ) : null}
    </li>
  );
}
