import { type BusinessProfile, profileLabelKey } from '@parkviet/pos-shared/pos-modules'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import { defaultsFromProfile } from '@parkviet/pos-shared/setup-wizard'
import { mapSpreeErrorsToForm } from '@spree/dashboard-core'
import {
  Button,
  Checkbox,
  DialogFooter,
  Field,
  FieldDescription,
  FieldLabel,
  Textarea,
} from '@spree/dashboard-ui'
import { useEffect, useState } from 'react'
import { useForm } from 'react-hook-form'
import { useTranslation } from 'react-i18next'
import type { StaffRole } from '../hooks/use-master-data'
import { changesSensitive } from '../lib/capability-groups'
import { branchBody, branchSchema } from '../schemas/branch'
import { membershipSchema } from '../schemas/membership'
import { registerSchema } from '../schemas/register'
import { CapabilityChecklist } from './capability-checklist'
import { TopologyDialog } from './topology-dialog'
import { Input, TopologyField, TopologySelect } from './topology-fields'

export type TopologyKind = 'branches' | 'registers' | 'memberships'
export type TopologyDraft = {
  id?: string
  name?: string
  code?: string
  timezone?: string
  business_day_cutoff?: string | null
  stock_location_id?: string
  receiving_stock_location_id?: string | null
  receiving_note?: string | null
  return_window_days?: string | number | null
  variance_threshold?: string | null
  adjustment_approval_threshold?: string | number | null
  lot_selection?: string
  profile_key?: string
  branch_id?: string
  staff_id?: string
  capabilities?: string[]
  // Memberships: the assigned staff role, and what the membership grants now
  // (the role's capabilities while it has one).
  staff_role_id?: string | null
  staff_role_name?: string | null
  effective_capabilities?: string[]
}
export type BranchOption = { id: string; name: string; status: string }
export type StaffOption = { id: string; email: string; full_name: string | null }
export type MembershipOption = {
  id: string
  branch_id: string
  staff_id: string
  capabilities: string[]
  status: string
  staff?: StaffOption
}
export type TopologyEditorProps = {
  kind: TopologyKind
  record: TopologyDraft
  branches: BranchOption[]
  staff: StaffOption[]
  locations: { id: string; name: string; active: boolean }[]
  memberships: MembershipOption[]
  hideLotSelection?: boolean
  // The branch is fixed by the page (a branch's own registers or staff).
  lockBranch?: boolean
  roles?: StaffRole[]
  profiles?: BusinessProfile[]
  defaultProfileKey?: string
  onSave: (body: Record<string, unknown>) => Promise<void>
  onClose: () => void
}
type Values = {
  name: string
  code: string
  timezone: string
  business_day_cutoff: string
  stock_location_id: string
  receiving_stock_location_id: string
  receiving_note: string
  return_window_days: string
  variance_threshold: string
  adjustment_approval_threshold: string
  lot_selection: 'fefo' | 'cashier_pick'
  profile_key: string
  branch_id: string
  staff_id: string
  capabilities: string[]
  staff_role_id: string
}
export function TopologyEditor({
  kind,
  record,
  branches,
  staff,
  locations,
  memberships,
  profiles = [],
  defaultProfileKey,
  hideLotSelection = false,
  lockBranch = false,
  roles = [],
  onSave,
  onClose,
}: TopologyEditorProps) {
  const { t } = useTranslation()
  const form = useForm<Values>({
    defaultValues: {
      name: record.name ?? '',
      code: record.code ?? '',
      timezone: record.timezone ?? 'Asia/Ho_Chi_Minh',
      business_day_cutoff: (record.business_day_cutoff ?? '04:00').slice(0, 5),
      stock_location_id: record.stock_location_id ?? '',
      receiving_stock_location_id: record.receiving_stock_location_id ?? '',
      receiving_note: record.receiving_note ?? '',
      return_window_days: String(record.return_window_days ?? ''),
      variance_threshold: String(record.variance_threshold ?? '').replace(/\.0+$/, ''),
      adjustment_approval_threshold: String(record.adjustment_approval_threshold ?? ''),
      lot_selection: record.lot_selection === 'cashier_pick' ? 'cashier_pick' : 'fefo',
      profile_key: record.profile_key ?? '',
      branch_id: record.branch_id ?? '',
      staff_id: record.staff_id ?? '',
      capabilities: record.capabilities ?? ['pos.shift.open'],
      staff_role_id: record.staff_role_id ?? '',
    },
  })
  const draft = form.watch()
  const [confirmed, setConfirmed] = useState(false)
  const [search, setSearch] = useState('')
  const [error, setError] = useState('')
  const busy = form.formState.isSubmitting
  const dirty = form.formState.isDirty
  const offersProfile = kind === 'branches' && !record.id && profiles.length > 0
  // A role the list no longer offers (disabled since) keeps its grants unknown here.
  const role = roles.find((item) => item.id === draft.staff_role_id)
  const granted = record.effective_capabilities ?? record.capabilities ?? ['pos.shift.open']
  const effective = draft.staff_role_id
    ? (role?.capabilities ?? (draft.staff_role_id === record.staff_role_id ? granted : []))
    : draft.capabilities
  const sensitive = kind === 'memberships' && changesSensitive(granted, effective)
  const roleOptions = [
    { value: '', label: t('staffRoles.custom') },
    ...roles.map((item) => ({ value: item.id, label: item.name })),
    ...(record.staff_role_id && !roles.some((item) => item.id === record.staff_role_id)
      ? [{ value: record.staff_role_id, label: record.staff_role_name ?? record.staff_role_id }]
      : []),
  ]
  useEffect(() => {
    if (!offersProfile || dirty) return
    const profile =
      profiles.find((p) => p.key === defaultProfileKey) ?? profiles.find((p) => p.key === 'khac')
    if (profile) {
      form.setValue('profile_key', profile.key)
      const defaults = defaultsFromProfile(profile)
      form.setValue('return_window_days', defaults.return_window_days)
      form.setValue('variance_threshold', defaults.variance_threshold)
      form.setValue('adjustment_approval_threshold', defaults.adjustment_approval_threshold)
      form.setValue('lot_selection', defaults.lot_selection)
    }
  }, [offersProfile, dirty, profiles, defaultProfileKey, form])
  function set<K extends keyof Values>(key: K, value: Values[K]) {
    form.setValue(key, value as never, { shouldDirty: true })
    setConfirmed(false)
    if (key === 'branch_id' && kind === 'memberships' && !record.id)
      form.setValue('staff_id', '', { shouldDirty: true })
  }
  async function submit(values: Values) {
    if (sensitive && !confirmed) return
    form.clearErrors()
    const parsed = (
      kind === 'branches' ? branchSchema : kind === 'registers' ? registerSchema : membershipSchema
    ).safeParse(values)
    if (!parsed.success) {
      for (const issue of parsed.error.issues)
        form.setError(issue.path[0] as keyof Values, { message: t(issue.message) })
      return
    }
    const body =
      kind === 'branches'
        ? branchBody(branchSchema.parse(values), offersProfile)
        : kind === 'registers'
          ? registerSchema.parse(values)
          : record.id
            ? { capabilities: values.capabilities, staff_role_id: values.staff_role_id || null }
            : membershipSchema.parse(values)
    setError('')
    try {
      await onSave(body)
      onClose()
    } catch (failure) {
      mapSpreeErrorsToForm(failure, form.setError)
      setError(describeFailure(failure, t))
    }
  }
  const text = (key: keyof Values, label: string, hint?: string, maxLength?: number) => (
    <TopologyField
      label={t(label)}
      hint={hint && t(hint)}
      error={form.formState.errors[key]?.message}
    >
      {(id, describedBy) => (
        <Input
          id={id}
          aria-describedby={describedBy}
          aria-invalid={Boolean(form.formState.errors[key])}
          maxLength={maxLength}
          value={String(draft[key])}
          onChange={(e) => set(key, e.target.value as never)}
        />
      )}
    </TopologyField>
  )
  const select = (
    key: keyof Values,
    label: string,
    options: { value: string; label: string }[],
    disabled = false,
    hint?: string,
  ) => (
    <TopologyField
      label={t(label)}
      hint={hint && t(hint)}
      error={form.formState.errors[key]?.message}
    >
      {(id, describedBy) => (
        <TopologySelect
          id={id}
          describedBy={describedBy}
          value={String(draft[key])}
          options={options}
          disabled={disabled}
          onChange={(value) => set(key, value as never)}
        />
      )}
    </TopologyField>
  )
  const warehouses = locations.map((location) => ({
    value: location.id,
    label: `${location.name}${location.active ? '' : ` · ${t('statusDisabled')}`}`,
  }))
  return (
    <TopologyDialog
      title={t(record.id ? 'adminEditTitle' : 'adminCreateTitle', {
        resource: t(`adminResource_${kind}`),
      })}
      subtitle={
        kind === 'memberships'
          ? `${staff.find((s) => s.id === draft.staff_id)?.email ?? ''} · ${branches.find((b) => b.id === draft.branch_id)?.name ?? ''}`
          : draft.name
      }
      dirty={dirty}
      busy={busy}
      onClose={onClose}
    >
      {(close) => (
        <form onSubmit={form.handleSubmit(submit)} aria-busy={busy} className="space-y-5">
          <fieldset disabled={busy} className="space-y-4">
            {kind !== 'memberships' && (
              <div className="grid gap-4 sm:grid-cols-2">
                {text('name', 'adminName', undefined, 100)}
                {text('code', 'code', 'adminCodeHint', 32)}
              </div>
            )}
            {kind !== 'branches' &&
              select(
                'branch_id',
                'branch',
                [
                  { value: '', label: t('chooseBranch') },
                  ...branches
                    .filter((b) => b.status === 'active' || b.id === draft.branch_id)
                    .map((b) => ({
                      value: b.id,
                      label: `${b.name}${b.status === 'disabled' ? ` · ${t('statusDisabled')}` : ''}`,
                    })),
                ],
                Boolean(record.id) || lockBranch,
              )}
            {kind === 'branches' && (
              <>
                {offersProfile && (
                  <TopologyField
                    label={t('businessModel.branchProfile')}
                    hint={t('businessModel.branchProfileHint')}
                  >
                    {(id) => (
                      <TopologySelect
                        id={id}
                        value={draft.profile_key}
                        options={[
                          { value: '', label: t('businessModel.chooseProfile') },
                          ...profiles.map((p) => ({
                            value: p.key,
                            label: t(profileLabelKey(p.key), { defaultValue: p.key }),
                          })),
                        ]}
                        onChange={(key) => {
                          const profile = profiles.find((p) => p.key === key)
                          if (!profile) return
                          set('profile_key', key)
                          const defaults = defaultsFromProfile(profile)
                          set('return_window_days', defaults.return_window_days)
                          set('variance_threshold', defaults.variance_threshold)
                          set('lot_selection', defaults.lot_selection)
                          set(
                            'adjustment_approval_threshold',
                            defaults.adjustment_approval_threshold,
                          )
                        }}
                      />
                    )}
                  </TopologyField>
                )}
                {select('stock_location_id', 'stockLocation', [
                  { value: '', label: t('adminChooseWarehouse') },
                  ...warehouses,
                ])}
                {select('receiving_stock_location_id', 'adminReceivingWarehouse', [
                  { value: '', label: t('adminDefaultWarehouse') },
                  ...warehouses,
                ])}
                {text('timezone', 'timezone', undefined, 64)}
                {text('business_day_cutoff', 'businessDayCutoff', 'businessDayCutoffHint', 5)}
                {text('return_window_days', 'adminReturnWindow', 'adminReturnWindowHint', 4)}
                {!hideLotSelection &&
                  select(
                    'lot_selection',
                    'adminLotSelection',
                    ['fefo', 'cashier_pick'].map((value) => ({
                      value,
                      label: t(`adminLotSelection_${value}`),
                    })),
                    false,
                    'adminLotSelectionHint',
                  )}
                {text(
                  'adjustment_approval_threshold',
                  'adminAdjustmentThreshold',
                  'adminAdjustmentThresholdHint',
                  9,
                )}
                {text(
                  'variance_threshold',
                  'adminVarianceThreshold',
                  'adminVarianceThresholdHint',
                  20,
                )}
                <TopologyField
                  label={t('adminReceivingNote')}
                  error={form.formState.errors.receiving_note?.message}
                >
                  {(id) => (
                    <Textarea
                      id={id}
                      maxLength={200}
                      value={draft.receiving_note}
                      onChange={(e) => set('receiving_note', e.target.value)}
                    />
                  )}
                </TopologyField>
              </>
            )}
            {kind === 'registers' && <FieldDescription>{t('adminRegisterNote')}</FieldDescription>}
            {kind === 'memberships' && (
              <>
                {!record.id && (
                  <TopologyField label={t('adminFindStaff')}>
                    {(id) => (
                      <Input
                        type="search"
                        id={id}
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                      />
                    )}
                  </TopologyField>
                )}
                {select(
                  'staff_id',
                  'adminStaff',
                  [
                    { value: '', label: t('adminChooseStaff') },
                    ...staff
                      .filter(
                        (user) =>
                          Boolean(record.id) ||
                          !memberships.some(
                            (m) => m.branch_id === draft.branch_id && m.staff_id === user.id,
                          ),
                      )
                      .filter(
                        (user) =>
                          user.id === draft.staff_id ||
                          `${user.full_name ?? ''} ${user.email}`
                            .toLocaleLowerCase()
                            .includes(search.toLocaleLowerCase()),
                      )
                      .map((user) => ({
                        value: user.id,
                        label: `${user.full_name ? `${user.full_name} · ` : ''}${user.email}`,
                      })),
                  ],
                  Boolean(record.id),
                  !record.id ? 'adminExistingMembershipHint' : undefined,
                )}
                <FieldDescription>{t('adminPermissionBoundary')}</FieldDescription>
                {select(
                  'staff_role_id',
                  'staffRoles.field',
                  roleOptions,
                  false,
                  'staffRoles.fieldHint',
                )}
                <fieldset aria-label={t('membership')}>
                  {draft.staff_role_id ? (
                    <>
                      <FieldDescription className="mb-4">
                        {t('staffRoles.fromRole', {
                          name: roleOptions.find((o) => o.value === draft.staff_role_id)?.label,
                        })}
                      </FieldDescription>
                      <CapabilityChecklist value={effective} disabled />
                    </>
                  ) : (
                    <CapabilityChecklist
                      value={draft.capabilities}
                      onChange={(next) => set('capabilities', next)}
                    />
                  )}
                </fieldset>
                {sensitive && (
                  <Field orientation="horizontal">
                    <Checkbox
                      id="confirm-permissions"
                      checked={confirmed}
                      onCheckedChange={(checked) => setConfirmed(checked === true)}
                    />
                    <FieldLabel htmlFor="confirm-permissions">
                      {t('adminConfirmPermissions')}
                    </FieldLabel>
                  </Field>
                )}
              </>
            )}
          </fieldset>
          {error && (
            <p role="alert" className="text-sm text-destructive">
              {error}
            </p>
          )}
          <DialogFooter>
            <Button type="button" variant="outline" disabled={busy} onClick={close}>
              {t('adminCancel')}
            </Button>
            <Button type="submit" disabled={busy || !dirty || (sensitive && !confirmed)}>
              {t(busy ? 'waiting' : 'save')}
            </Button>
          </DialogFooter>
        </form>
      )}
    </TopologyDialog>
  )
}
