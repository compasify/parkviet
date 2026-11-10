import { parseVndInput } from '@parkviet/pos-shared/money';
import { posCapabilities, sensitiveCapabilities } from '@parkviet/pos-shared/pos-capabilities';
import { type BusinessProfile, profileLabelKey } from '@parkviet/pos-shared/pos-modules';
import { defaultsFromProfile } from '@parkviet/pos-shared/setup-wizard';
import { type FormEvent, useEffect, useRef, useState } from 'react';
import { useTranslation } from 'react-i18next';
import type { LocationOption, StaffOption } from '../hooks/use-topology';
import type { PosBranch, PosMembership } from '../lib/pos-context';
import { posFailureKey } from '../lib/request-failure';
import { PosIcon } from './pos-icon';

// A new branch's form after picking an industry: the profile and the branch
// defaults it presets (blank where it has none), ready to edit.
function profileDraft(profile: BusinessProfile): Partial<TopologyDraft> {
  const defaults = defaultsFromProfile(profile);
  return {
    profile_key: profile.key,
    return_window_days: defaults.return_window_days,
    lot_selection: defaults.lot_selection,
    variance_threshold: defaults.variance_threshold,
    adjustment_approval_threshold: defaults.adjustment_approval_threshold,
  };
}

export type TopologyKind = 'branches' | 'registers' | 'memberships';
export type TopologyDraft = {
  id?: string;
  name?: string;
  code?: string;
  timezone?: string;
  stock_location_id?: string;
  receiving_stock_location_id?: string | null;
  receiving_note?: string | null;
  // Days a sale stays returnable at the branch; blank keeps returns off.
  return_window_days?: string | number | null;
  // Closing variance above this needs an approval; blank means any variance does.
  variance_threshold?: string | null;
  // FEFO picks lots for the cashier unless the branch lets them choose.
  lot_selection?: string;
  // Base units a positive stock count may add without approval; blank means
  // every positive count needs one.
  adjustment_approval_threshold?: string | number | null;
  // Industry profile of a new branch (sent on create only).
  profile_key?: string;
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
  hideLotSelection = false,
  profiles = [],
  defaultProfileKey,
  onSave,
  onClose,
}: {
  kind: TopologyKind;
  record: TopologyDraft;
  // Available industry profiles offered to a new branch, and the one picked
  // first (the store's main profile).
  profiles?: BusinessProfile[];
  defaultProfileKey?: string;
  // The branch has `retail.traceability` off: lot picking is not offered and
  // the stored value is sent back as it is.
  hideLotSelection?: boolean;
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
  const offersProfile = kind === 'branches' && !record.id && profiles.length > 0;

  // The catalogue or the store's profile may arrive after the form opened:
  // until the form is touched, it follows the store's main profile.
  useEffect(() => {
    if (!offersProfile || dirty) return;
    const profile =
      profiles.find((item) => item.key === defaultProfileKey) ??
      profiles.find((item) => item.key === 'khac');
    if (!profile) return;
    setDraft((current) =>
      current.profile_key === profile.key ? current : { ...current, ...profileDraft(profile) },
    );
  }, [offersProfile, dirty, defaultProfileKey, profiles]);

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
    // Blank turns returns off; anything else must be a whole number of days.
    const windowText = String(draft.return_window_days ?? '').trim();
    if (
      kind === 'branches' &&
      windowText !== '' &&
      (!/^\d{1,4}$/.test(windowText) || Number(windowText) > 3650)
    ) {
      setError(t('adminReturnWindowInvalid'));
      return;
    }
    const thresholdText = String(draft.variance_threshold ?? '')
      .trim()
      .replace(/\.0+$/, '');
    const threshold = thresholdText === '' ? null : parseVndInput(thresholdText);
    if (kind === 'branches' && thresholdText !== '' && threshold === null) {
      setError(t('adminVarianceThresholdInvalid'));
      return;
    }
    const adjustmentText = String(draft.adjustment_approval_threshold ?? '').trim();
    if (kind === 'branches' && adjustmentText !== '' && !/^\d{1,9}$/.test(adjustmentText)) {
      setError(t('adminAdjustmentThresholdInvalid'));
      return;
    }
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
              return_window_days:
                String(draft.return_window_days ?? '').trim() === ''
                  ? null
                  : Number(String(draft.return_window_days).trim()),
              variance_threshold: threshold,
              lot_selection: draft.lot_selection === 'cashier_pick' ? 'cashier_pick' : 'fefo',
              adjustment_approval_threshold: adjustmentText === '' ? null : Number(adjustmentText),
              ...(offersProfile && draft.profile_key ? { profile_key: draft.profile_key } : {}),
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
              {offersProfile ? (
                <label>
                  {t('businessModel.branchProfile')}
                  <select
                    value={draft.profile_key ?? ''}
                    aria-describedby="branch-profile-hint"
                    onChange={(event) => {
                      const profile = profiles.find((item) => item.key === event.target.value);
                      if (!profile) return;
                      setDraft((current) => ({ ...current, ...profileDraft(profile) }));
                      setDirty(true);
                    }}
                  >
                    {draft.profile_key ? null : (
                      <option value="">{t('businessModel.chooseProfile')}</option>
                    )}
                    {profiles.map((profile) => (
                      <option key={profile.key} value={profile.key}>
                        {t(profileLabelKey(profile.key), { defaultValue: profile.key })}
                      </option>
                    ))}
                  </select>
                  <small id="branch-profile-hint">{t('businessModel.branchProfileHint')}</small>
                </label>
              ) : null}
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
                {t('adminReturnWindow')}
                <input
                  // Text, not number: a number input reports invalid typing as
                  // empty, which would silently turn returns off.
                  type="text"
                  inputMode="numeric"
                  maxLength={4}
                  value={String(draft.return_window_days ?? '')}
                  aria-describedby="return-window-hint"
                  onChange={(event) => set('return_window_days', event.target.value)}
                />
                <small id="return-window-hint">{t('adminReturnWindowHint')}</small>
              </label>
              {hideLotSelection ? null : (
                <label>
                  {t('adminLotSelection')}
                  <select
                    value={draft.lot_selection === 'cashier_pick' ? 'cashier_pick' : 'fefo'}
                    aria-describedby="lot-selection-hint"
                    onChange={(event) => set('lot_selection', event.target.value)}
                  >
                    <option value="fefo">{t('adminLotSelection_fefo')}</option>
                    <option value="cashier_pick">{t('adminLotSelection_cashier_pick')}</option>
                  </select>
                  <small id="lot-selection-hint">{t('adminLotSelectionHint')}</small>
                </label>
              )}
              <label>
                {t('adminAdjustmentThreshold')}
                <input
                  type="text"
                  inputMode="numeric"
                  maxLength={9}
                  value={String(draft.adjustment_approval_threshold ?? '')}
                  aria-describedby="adjustment-threshold-hint"
                  onChange={(event) => set('adjustment_approval_threshold', event.target.value)}
                />
                <small id="adjustment-threshold-hint">{t('adminAdjustmentThresholdHint')}</small>
              </label>
              <label>
                {t('adminVarianceThreshold')}
                <input
                  type="text"
                  inputMode="numeric"
                  maxLength={20}
                  value={String(draft.variance_threshold ?? '').replace(/\.0+$/, '')}
                  aria-describedby="variance-threshold-hint"
                  onChange={(event) => set('variance_threshold', event.target.value)}
                />
                <small id="variance-threshold-hint">{t('adminVarianceThresholdHint')}</small>
              </label>
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
