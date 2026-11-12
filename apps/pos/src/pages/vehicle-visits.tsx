import { formatMoney, parseVndInput } from '@parkviet/pos-shared/money';
import { type FormEvent, useState } from 'react';
import { useTranslation } from 'react-i18next';
import { PageState, PosPage } from '../components/pos-page';
import { usePosSelection } from '../components/pos-selection';
import { useVehicleVisitCommands, useVehicleVisits } from '../hooks/use-vehicle-visits';
import { writesLocked } from '../lib/pos-context';
import { conflictReason, describeFailure } from '../lib/request-failure';
import {
  VEHICLE_COMMISSION_MODULE,
  type VehicleVisit,
  type VehicleVisitStatus,
  vehicleReasonKey,
  visitActions,
} from '../lib/vehicle-visits';

const STATUS_FILTERS: Record<string, VehicleVisitStatus[]> = {
  active: ['open', 'closed'],
  open: ['open'],
  closed: ['closed'],
  paid: ['paid'],
  voided: ['voided'],
  all: [],
};

function today() {
  const now = new Date();
  const pad = (value: number) => String(value).padStart(2, '0');
  return `${now.getFullYear()}-${pad(now.getMonth() + 1)}-${pad(now.getDate())}`;
}

function when(iso: string | null, language: string) {
  return iso
    ? new Date(iso).toLocaleTimeString(language, { hour: '2-digit', minute: '2-digit' })
    : '';
}

export function VehicleVisitsPage() {
  const { context, selection } = usePosSelection();
  const scope = `${context.data?.staff.id}:${context.data?.store.id}:${selection.branchId}`;
  return <VehicleVisits key={scope} />;
}

function useCommandForm() {
  const { t } = useTranslation();
  const [busy, setBusy] = useState(false);
  const [message, setMessage] = useState('');
  async function submit(action: () => Promise<void>) {
    setBusy(true);
    setMessage('');
    try {
      await action();
      return true;
    } catch (failure) {
      const key = vehicleReasonKey(conflictReason(failure));
      setMessage(key ? t(key) : describeFailure(failure, t));
      return false;
    } finally {
      setBusy(false);
    }
  }
  return { busy, message, submit };
}

function FormMessage({ text }: { text: string }) {
  return text ? (
    <p className="error" role="alert">
      {text}
    </p>
  ) : null;
}

// Coach visits of a day: close a coach that left, see how its commission was
// worked out, pay the driver in cash (a cash out a second person confirms) or
// record a transfer, correct a closed visit with a manager's approval, or void
// one that never happened.
function VehicleVisits() {
  const { t, i18n } = useTranslation();
  const { context, selection } = usePosSelection();
  const data = context.data;
  const branchId = selection.branchId;
  const capabilities = data?.capabilities ?? [];
  const enabled = data?.modules?.[VEHICLE_COMMISSION_MODULE] === true;
  const canManage = capabilities.includes('pos.vehicle_visit.manage');
  const [businessDate, setBusinessDate] = useState(today);
  const [status, setStatus] = useState('active');
  const [query, setQuery] = useState('');
  const [selectedId, setSelectedId] = useState<string | null>(null);
  // Outlives the visit leaving the list (a paid visit is not in "not paid yet").
  const [notice, setNotice] = useState('');
  const list = useVehicleVisits(
    branchId,
    { businessDate, statuses: STATUS_FILTERS[status] ?? [], q: query },
    enabled,
  );
  const commands = useVehicleVisitCommands(
    branchId,
    data?.staff.id ?? null,
    data?.store.id ?? null,
  );
  const rows = list.data ?? [];
  const selected = rows.find((row) => row.id === selectedId) ?? null;
  const locked = writesLocked(data, selection);

  return (
    <PosPage title={t('vehicleVisitsTitle')} description={t('vehicleVisitsHint')}>
      {context.isPending ? (
        <PageState kind="loading" title={t('contextWaiting')} />
      ) : !branchId ? (
        <PageState title={t('chooseBranch')} description={t('pageChooseBranchHint')} />
      ) : !enabled ? (
        <PageState title={t('posModules.fnb_vehicle_commission.off')} />
      ) : (
        <div className="vehicle-visits">
          <div className="page-toolbar">
            <label>
              {t('vehicleBusinessDate')}
              <input
                type="date"
                value={businessDate}
                onChange={(event) => setBusinessDate(event.target.value)}
              />
            </label>
            <label>
              {t('vehicleStatusFilter')}
              <select value={status} onChange={(event) => setStatus(event.target.value)}>
                {Object.keys(STATUS_FILTERS).map((key) => (
                  <option key={key} value={key}>
                    {t(`vehicleFilter_${key}`)}
                  </option>
                ))}
              </select>
            </label>
            <label className="tab-list-search">
              {t('vehiclePlate')}
              <input
                type="search"
                value={query}
                maxLength={20}
                onChange={(event) => setQuery(event.target.value)}
              />
            </label>
          </div>
          {list.isError ? <PageState kind="error" title={describeFailure(list.error, t)} /> : null}
          {list.isSuccess && rows.length === 0 ? (
            <PageState kind="empty" title={t('vehicleVisitsEmpty')} />
          ) : null}
          {rows.length > 0 ? (
            <table className="tab-list-table" aria-label={t('vehicleVisitsTitle')}>
              <thead>
                <tr>
                  <th scope="col">{t('vehiclePlate')}</th>
                  <th scope="col">{t('vehicleOperator')}</th>
                  <th scope="col">{t('vehicleType')}</th>
                  <th scope="col" className="numeric">
                    {t('vehicleGuests')}
                  </th>
                  <th scope="col">{t('vehicleArrived')}</th>
                  <th scope="col">{t('vehicleStatus')}</th>
                  <th scope="col" className="numeric">
                    {t('vehicleCommission')}
                  </th>
                </tr>
              </thead>
              <tbody>
                {rows.map((row) => (
                  <tr key={row.id} aria-selected={row.id === selectedId}>
                    <td>
                      <button
                        type="button"
                        className="link-button"
                        onClick={() => {
                          setSelectedId(row.id);
                          setNotice('');
                        }}
                      >
                        {row.plate}
                      </button>
                    </td>
                    <td>{row.bus_operator?.name ?? ''}</td>
                    <td>{t(`vehicleType_${row.vehicle_type}`)}</td>
                    <td className="numeric">{row.guest_count}</td>
                    <td>{when(row.arrived_at, i18n.language)}</td>
                    <td>{statusLabel(row, t)}</td>
                    <td className="numeric">
                      {row.commission_amount
                        ? formatMoney(row.commission_amount, row.currency)
                        : ''}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          ) : null}
          {selected ? (
            <VisitDetail
              key={`${selected.id}:${selected.revision}:${selected.status}`}
              visit={selected}
              canManage={canManage}
              locked={locked}
              commands={commands}
              onNotice={setNotice}
            />
          ) : null}
          {notice ? <p role="status">{notice}</p> : null}
        </div>
      )}
    </PosPage>
  );
}

function statusLabel(visit: VehicleVisit, t: (key: string) => string) {
  if (visit.status === 'paid' && visit.payout_status && visit.payout_status !== 'paid') {
    return t(`vehiclePayout_${visit.payout_status}`);
  }
  return t(`vehicleStatus_${visit.status}`);
}

type Commands = ReturnType<typeof useVehicleVisitCommands>;

function VisitDetail({
  visit,
  canManage,
  locked,
  commands,
  onNotice,
}: {
  visit: VehicleVisit;
  canManage: boolean;
  locked: boolean;
  commands: Commands;
  onNotice: (text: string) => void;
}) {
  const { t } = useTranslation();
  const actions = visitActions(visit, canManage);
  const form = useCommandForm();
  const off = locked || form.busy;
  const commission = visit.commission;
  return (
    <section className="detail-panel" aria-label={t('vehicleVisitDetail', { plate: visit.plate })}>
      <h2>{visit.plate}</h2>
      <dl className="vehicle-visit-calculation">
        <dt>{t('vehicleDriver')}</dt>
        <dd>{[visit.driver_name, visit.driver_phone].filter(Boolean).join(' · ')}</dd>
        <dt>{t('vehicleGuests')}</dt>
        <dd>{visit.guest_count}</dd>
        {visit.revenue_amount ? (
          <>
            <dt>{t('vehicleRevenue')}</dt>
            <dd>{formatMoney(visit.revenue_amount, visit.currency)}</dd>
          </>
        ) : null}
        {commission ? (
          <>
            <dt>{t('vehicleRule')}</dt>
            <dd>{commission.rule_name ?? t('vehicleNoRule')}</dd>
            <dt>{t('vehiclePerVehicle')}</dt>
            <dd>{formatMoney(commission.vehicle_amount, visit.currency)}</dd>
            <dt>{t('vehiclePerGuests')}</dt>
            <dd>{formatMoney(commission.guest_amount, visit.currency)}</dd>
            <dt>{t('vehicleCommission')}</dt>
            <dd>
              <strong>
                {formatMoney(visit.commission_amount ?? commission.amount, visit.currency)}
              </strong>
              {commission.manual ? ` (${t('vehicleManual')})` : null}
              {!commission.qualified && commission.reason
                ? ` — ${t(`vehicleNotQualified_${commission.reason}`)}`
                : null}
            </dd>
          </>
        ) : null}
        {visit.payout_method ? (
          <>
            <dt>{t('vehiclePayout')}</dt>
            <dd>
              {t(`vehiclePayoutMethod_${visit.payout_method}`)}
              {visit.transfer_reference ? ` · ${visit.transfer_reference}` : ''}
              {visit.payout_status ? ` · ${t(`vehiclePayout_${visit.payout_status}`)}` : ''}
            </dd>
          </>
        ) : null}
        {visit.void_reason ? (
          <>
            <dt>{t('vehicleVoidReason')}</dt>
            <dd>{visit.void_reason}</dd>
          </>
        ) : null}
      </dl>
      <div className="page-toolbar">
        {actions.close ? (
          <button
            type="button"
            disabled={off}
            onClick={() =>
              void form.submit(async () => {
                await commands.close(visit);
              })
            }
          >
            {t('vehicleClose')}
          </button>
        ) : null}
      </div>
      <FormMessage text={form.message} />
      {actions.pay ? (
        <PayForm visit={visit} disabled={locked} commands={commands} onPaid={onNotice} />
      ) : null}
      {actions.adjust ? <AdjustForm visit={visit} disabled={locked} commands={commands} /> : null}
      {actions.void ? <VoidForm visit={visit} disabled={locked} commands={commands} /> : null}
    </section>
  );
}

function PayForm({
  visit,
  disabled,
  commands,
  onPaid,
}: {
  visit: VehicleVisit;
  disabled: boolean;
  commands: Commands;
  onPaid: (text: string) => void;
}) {
  const { t } = useTranslation();
  const form = useCommandForm();
  const [method, setMethod] = useState<'cash' | 'transfer'>('cash');
  const [reference, setReference] = useState('');
  const off = disabled || form.busy;
  const ready = method === 'cash' || reference.trim() !== '';
  async function submit(event: FormEvent) {
    event.preventDefault();
    onPaid('');
    const ok = await form.submit(async () => {
      await commands.pay(
        visit,
        method === 'cash' ? { method } : { method, reference: reference.trim() },
      );
    });
    if (ok) onPaid(method === 'cash' ? t('vehiclePaidCash') : t('vehiclePaidTransfer'));
  }
  return (
    <form className="meal-account-action" onSubmit={submit} aria-label={t('vehiclePay')}>
      <h3>{t('vehiclePay')}</h3>
      <label>
        {t('vehiclePayoutMethodLabel')}
        <select
          value={method}
          disabled={off}
          onChange={(event) => setMethod(event.target.value as 'cash' | 'transfer')}
        >
          <option value="cash">{t('vehiclePayoutMethod_cash')}</option>
          <option value="transfer">{t('vehiclePayoutMethod_transfer')}</option>
        </select>
      </label>
      {method === 'transfer' ? (
        <label>
          {t('vehicleTransferReference')}
          <input
            value={reference}
            maxLength={64}
            disabled={off}
            onChange={(event) => setReference(event.target.value)}
          />
        </label>
      ) : null}
      <button type="submit" disabled={off || !ready}>
        {t('vehiclePayAmount', {
          amount: formatMoney(visit.commission_amount ?? '0', visit.currency),
        })}
      </button>
      <FormMessage text={form.message} />
    </form>
  );
}

function AdjustForm({
  visit,
  disabled,
  commands,
}: {
  visit: VehicleVisit;
  disabled: boolean;
  commands: Commands;
}) {
  const { t } = useTranslation();
  const form = useCommandForm();
  const [guests, setGuests] = useState(String(visit.guest_count));
  const [amountText, setAmountText] = useState('');
  const [note, setNote] = useState('');
  const [approvalId, setApprovalId] = useState('');
  const amount = amountText.trim() ? parseVndInput(amountText) : null;
  const guestCount = Number.parseInt(guests, 10);
  const changed = guestCount !== visit.guest_count || amount !== null;
  const off = disabled || form.busy;
  const ready =
    changed &&
    Number.isInteger(guestCount) &&
    (amountText.trim() === '' || amount !== null) &&
    note.trim() !== '' &&
    approvalId.trim() !== '';
  async function submit(event: FormEvent) {
    event.preventDefault();
    await form.submit(async () => {
      await commands.adjust(visit, {
        ...(guestCount !== visit.guest_count ? { guestCount } : {}),
        ...(amount !== null ? { commissionAmount: amount } : {}),
        note: note.trim(),
        approvalId: approvalId.trim(),
      });
    });
  }
  return (
    <form className="meal-account-action" onSubmit={submit} aria-label={t('vehicleAdjust')}>
      <h3>{t('vehicleAdjust')}</h3>
      <label>
        {t('vehicleGuests')}
        <input
          value={guests}
          inputMode="numeric"
          disabled={off}
          onChange={(event) => setGuests(event.target.value.replace(/\D/g, ''))}
        />
      </label>
      <label>
        {t('vehicleAdjustAmount')}
        <input
          value={amountText}
          inputMode="numeric"
          disabled={off}
          onChange={(event) => setAmountText(event.target.value)}
        />
      </label>
      <label>
        {t('vehicleAdjustNote')}
        <input
          value={note}
          maxLength={255}
          disabled={off}
          onChange={(event) => setNote(event.target.value)}
        />
      </label>
      <label>
        {t('vehicleApproval')}
        <input
          value={approvalId}
          maxLength={64}
          disabled={off}
          onChange={(event) => setApprovalId(event.target.value)}
        />
      </label>
      <button type="submit" disabled={off || !ready}>
        {t('vehicleAdjust')}
      </button>
      <FormMessage text={form.message} />
    </form>
  );
}

function VoidForm({
  visit,
  disabled,
  commands,
}: {
  visit: VehicleVisit;
  disabled: boolean;
  commands: Commands;
}) {
  const { t } = useTranslation();
  const form = useCommandForm();
  const [reason, setReason] = useState('');
  const off = disabled || form.busy;
  async function submit(event: FormEvent) {
    event.preventDefault();
    await form.submit(async () => {
      await commands.void(visit, reason);
    });
  }
  return (
    <form className="meal-account-action" onSubmit={submit} aria-label={t('vehicleVoid')}>
      <h3>{t('vehicleVoid')}</h3>
      <label>
        {t('vehicleVoidReason')}
        <input
          value={reason}
          maxLength={255}
          disabled={off}
          onChange={(event) => setReason(event.target.value)}
        />
      </label>
      <button type="submit" disabled={off || reason.trim() === ''}>
        {t('vehicleVoid')}
      </button>
      <FormMessage text={form.message} />
    </form>
  );
}
