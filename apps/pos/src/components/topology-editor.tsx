import { type FormEvent, useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { LocationOption, StaffOption } from '../hooks/use-topology';
import { posCapabilities, sensitiveCapabilities } from '../lib/pos-capabilities';
import type { PosBranch, PosMembership } from '../lib/pos-context';
import { posFailureKey } from '../lib/request-failure';
import { PosIcon } from './pos-icon';

export type TopologyKind = 'branches' | 'registers' | 'memberships';
export type TopologyDraft = {
  id?: string;
  name?: string;
  code?: string;
  timezone?: string;
  stock_location_id?: string;
  receiving_stock_location_id?: string | null;
  receiving_note?: string | null;
  branch_id?: string;
  staff_id?: string;
  capabilities?: string[];
};

export function TopologyEditor({
  kind,
  record,
  branches,
  staff,
  locations,
  memberships,
  onSave,
  onClose,
}: {
  kind: TopologyKind;
  record: TopologyDraft;
  branches: PosBranch[];
  staff: StaffOption[];
  locations: LocationOption[];
  memberships: PosMembership[];
  onSave: (body: Record<string, unknown>) => Promise<void>;
  onClose: () => void;
}) {
  const { t } = useTranslation();
  const dialog = useRef<HTMLDialogElement>(null);
  const [draft, setDraft] = useState<TopologyDraft>({
    timezone: 'Asia/Ho_Chi_Minh',
    capabilities: ['pos.shift.open'],
    ...record,
  });
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [dirty, setDirty] = useState(false);
  const [staffSearch, setStaffSearch] = useState('');
  const [confirmed, setConfirmed] = useState(false);
  const sensitive =
    kind === 'memberships' &&
    sensitiveCapabilities.some(
      (capability) =>
        draft.capabilities?.includes(capability) !==
        (record.capabilities ?? ['pos.shift.open']).includes(capability),
    );
  const title = t(record.id ? 'adminEditTitle' : 'adminCreateTitle', {
    resource: t(`adminResource_${kind}`),
  });

  useEffect(() => {
    const element = dialog.current;
    const previous = document.activeElement;
    element?.showModal();
    element?.querySelector<HTMLElement>('input:not(:disabled), select:not(:disabled)')?.focus();
    return () => {
      element?.close();
      if (previous instanceof HTMLElement && previous.isConnected) previous.focus();
    };
  }, []);
  function close() {
    if (!busy && (!dirty || window.confirm(t('adminDiscard')))) onClose();
  }
  function set(key: keyof TopologyDraft, value: string | string[]) {
    setDraft((current) => ({
      ...current,
      [key]: value,
      ...(key === 'branch_id' && kind === 'memberships' && !record.id ? { staff_id: '' } : {}),
    }));
    setDirty(true);
    setConfirmed(false);
  }
  async function submit(event: FormEvent) {
    event.preventDefault();
    if (busy || (sensitive && !confirmed)) return;
    const body =
      kind === 'memberships'
        ? record.id
          ? { capabilities: draft.capabilities }
          : {
              branch_id: draft.branch_id,
              staff_id: draft.staff_id,
              capabilities: draft.capabilities,
            }
        : kind === 'registers'
          ? { name: draft.name?.trim(), code: draft.code?.trim(), branch_id: draft.branch_id }
          : {
              name: draft.name?.trim(),
              code: draft.code?.trim(),
              timezone: draft.timezone?.trim(),
              stock_location_id: draft.stock_location_id,
              receiving_stock_location_id: draft.receiving_stock_location_id || null,
              receiving_note: draft.receiving_note?.trim() || null,
            };
    setBusy(true);
    setError('');
    try {
      await onSave(body);
      onClose();
    } catch (failure) {
      const key = posFailureKey(failure);
      setError(
        key === 'invalid' && failure instanceof Error
          ? t('adminValidationDetail', { message: failure.message })
          : t(key),
      );
    } finally {
      setBusy(false);
    }
  }
  return (
    <dialog
      ref={dialog}
      className="topology-dialog"
      aria-labelledby="topology-editor-title"
      onCancel={(event) => {
        event.preventDefault();
        close();
      }}
    >
      <div className="topology-dialog-heading">
        <div>
          <p className="admin-eyebrow">{t('adminWorkspace')}</p>
          <h2 id="topology-editor-title">{title}</h2>
          <p className="admin-editor-context">
            {kind === 'memberships'
              ? [
                  staff.find((user) => user.id === draft.staff_id)?.email,
                  branches.find((branch) => branch.id === draft.branch_id)?.name,
                ]
                  .filter(Boolean)
                  .join(' · ')
              : draft.name}
          </p>
        </div>
        <button type="button" aria-label={t('adminClose')} disabled={busy} onClick={close}>
          <PosIcon name="close" />
        </button>
      </div>
      <form onSubmit={submit} aria-busy={busy}>
        <fieldset className="admin-form-fields" disabled={busy}>
          {kind !== 'memberships' ? (
            <div className="admin-form-grid">
              <label>
                {t('adminName')}
                <input
                  required
                  maxLength={100}
                  value={draft.name ?? ''}
                  onChange={(event) => set('name', event.target.value)}
                />
              </label>
              <label>
                {t('code')}
                <input
                  required
                  maxLength={32}
                  pattern={'[a-z0-9][a-z0-9_\\-]{0,31}'}
                  aria-label={t('code')}
                  aria-describedby="admin-code-hint"
                  value={draft.code ?? ''}
                  onChange={(event) => set('code', event.target.value)}
                />
                <small id="admin-code-hint">{t('adminCodeHint')}</small>
              </label>
            </div>
          ) : null}
          {kind !== 'branches' ? (
            <label>
              {t('branch')}
              <select
                required
                disabled={Boolean(record.id)}
                value={draft.branch_id ?? ''}
                aria-label={t('branch')}
                onChange={(event) => set('branch_id', event.target.value)}
              >
                <option value="">{t('chooseBranch')}</option>
                {branches
                  .filter((branch) => branch.status === 'active' || branch.id === draft.branch_id)
                  .map((branch) => (
                    <option key={branch.id} value={branch.id}>
                      {branch.name}
                      {branch.status === 'disabled' ? ` · ${t('statusDisabled')}` : ''}
                    </option>
                  ))}
              </select>
            </label>
          ) : null}
          {kind === 'branches' ? (
            <>
              <label>
                {t('stockLocation')}
                <select
                  required
                  value={draft.stock_location_id ?? ''}
                  aria-label={t('stockLocation')}
                  onChange={(event) => set('stock_location_id', event.target.value)}
                >
                  <option value="">{t('adminChooseWarehouse')}</option>
                  {locations.map((location) => (
                    <option key={location.id} value={location.id}>
                      {location.name}
                      {!location.active ? ` · ${t('statusDisabled')}` : ''}
                    </option>
                  ))}
                </select>
              </label>
              <div className="admin-form-grid">
                <label>
                  {t('adminReceivingWarehouse')}
                  <select
                    value={draft.receiving_stock_location_id ?? ''}
                    aria-label={t('adminReceivingWarehouse')}
                    onChange={(event) => set('receiving_stock_location_id', event.target.value)}
                  >
                    <option value="">{t('adminDefaultWarehouse')}</option>
                    {locations.map((location) => (
                      <option key={location.id} value={location.id}>
                        {location.name}
                      </option>
                    ))}
                  </select>
                </label>
                <label>
                  {t('timezone')}
                  <input
                    required
                    maxLength={64}
                    list="pos-timezones"
                    value={draft.timezone ?? ''}
                    onChange={(event) => set('timezone', event.target.value)}
                  />
                  <datalist id="pos-timezones">
                    <option value="Asia/Ho_Chi_Minh" />
                    <option value="Asia/Bangkok" />
                    <option value="UTC" />
                  </datalist>
                </label>
              </div>
              <label>
                {t('adminReceivingNote')}
                <textarea
                  maxLength={200}
                  rows={3}
                  value={draft.receiving_note ?? ''}
                  onChange={(event) => set('receiving_note', event.target.value)}
                />
              </label>
            </>
          ) : null}
          {kind === 'registers' ? <p className="admin-info">{t('adminRegisterNote')}</p> : null}
          {kind === 'memberships' ? (
            <>
              {!record.id ? (
                <label>
                  {t('adminFindStaff')}
                  <input
                    type="search"
                    value={staffSearch}
                    onChange={(event) => setStaffSearch(event.target.value)}
                  />
                </label>
              ) : null}
              <label>
                {t('adminStaff')}
                <select
                  required
                  disabled={Boolean(record.id)}
                  value={draft.staff_id ?? ''}
                  aria-label={t('adminStaff')}
                  aria-describedby={!record.id ? 'admin-existing-membership-hint' : undefined}
                  onChange={(event) => set('staff_id', event.target.value)}
                >
                  <option value="">{t('adminChooseStaff')}</option>
                  {staff
                    .filter(
                      (user) =>
                        Boolean(record.id) ||
                        !memberships.some(
                          (membership) =>
                            membership.branch_id === draft.branch_id &&
                            membership.staff_id === user.id,
                        ),
                    )
                    .filter(
                      (user) =>
                        user.id === draft.staff_id ||
                        `${user.full_name ?? ''} ${user.email}`
                          .toLocaleLowerCase()
                          .includes(staffSearch.toLocaleLowerCase()),
                    )
                    .map((user) => (
                      <option key={user.id} value={user.id}>
                        {user.full_name ? `${user.full_name} · ` : ''}
                        {user.email}
                      </option>
                    ))}
                </select>
                {!record.id ? (
                  <small id="admin-existing-membership-hint">
                    {t('adminExistingMembershipHint')}
                  </small>
                ) : null}
              </label>
              <p className="admin-info">{t('adminPermissionBoundary')}</p>
              <fieldset className="admin-permissions">
                <legend>{t('membership')}</legend>
                {posCapabilities.map(([value, label]) => (
                  <label key={value}>
                    <input
                      type="checkbox"
                      checked={draft.capabilities?.includes(value) ?? false}
                      onChange={(event) =>
                        set(
                          'capabilities',
                          event.target.checked
                            ? [...(draft.capabilities ?? []), value]
                            : (draft.capabilities ?? []).filter((item) => item !== value),
                        )
                      }
                    />
                    <span>
                      <strong>{t(label)}</strong>
                      <small>{t(`${label}Hint`)}</small>
                    </span>
                  </label>
                ))}
              </fieldset>
              {sensitive ? (
                <label className="admin-sensitive">
                  <input
                    type="checkbox"
                    checked={confirmed}
                    onChange={(event) => setConfirmed(event.target.checked)}
                  />
                  {t('adminConfirmPermissions')}
                </label>
              ) : null}
            </>
          ) : null}
        </fieldset>
        {error ? (
          <p role="alert" className="error">
            {error}
          </p>
        ) : null}
        <div className="topology-dialog-actions">
          <button type="button" disabled={busy} onClick={close}>
            {t('adminCancel')}
          </button>
          <button
            type="submit"
            className="primary-button"
            disabled={busy || !dirty || (sensitive && !confirmed)}
          >
            {busy ? t('waiting') : t('save')}
          </button>
        </div>
      </form>
    </dialog>
  );
}
