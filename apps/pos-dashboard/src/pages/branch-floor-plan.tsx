import {
  conflictReason,
  describeFailure,
  posFailureKey,
} from '@parkviet/pos-shared/request-failure'
import {
  type AreaRecord,
  MANUAL_STATUSES,
  normalizeArea,
  normalizeResource,
  type Placement,
  RESOURCE_KINDS,
  RESOURCE_SHAPES,
  type ResourceRecord,
} from '@parkviet/pos-shared/tables'
import { SERVICE_MODES, type ServiceMode } from '@parkviet/pos-shared/types/pos-context'
import { usePermissions } from '@spree/dashboard-core'
import { Button, Input, Label, useConfirm } from '@spree/dashboard-ui'
import { type FormEvent, useId, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useBranchScope } from '../components/branch-detail'
import { type CanvasTable, FloorPlanCanvas } from '../components/floor-plan-canvas'
import {
  ModelCard,
  ModelCheck,
  ModelNotice,
  ModelSelect,
  ModelState,
} from '../components/setup/model-ui'
import { TableCodesCard } from '../components/table-codes-card'
import {
  QR_ORDER_MODES,
  type QrOrderMode,
  type TableSettings,
  TIP_SPLIT_MODES,
  type TipSplit,
  useAreas,
  useFloorPlanWrite,
  useResources,
  useTableSettings,
} from '../hooks/use-floor-plan'
import { useStaffRoles } from '../hooks/use-master-data'
import { usePosSession } from '../hooks/use-pos-session'
import {
  BOTTLE_KEEP_DAYS_MAX,
  CAPACITY_MAX,
  changedFields,
  FLOOR_MAX,
  FLOOR_MIN,
  freeSpot,
  placementDraft,
  QR_MAX_ITEMS,
  readFloorSize,
  readKeepDays,
  readQrLimit,
  readQrMaxItems,
  readServiceChargeRate,
  readTableDraft,
  SERVICE_CHARGE_MAX,
  TABLE_SIZE_MAX,
  type TableDraft,
  tableDraftOf,
  tablesOutside,
} from '../lib/floor-plan'
import { canManageBranch, canManageResources } from '../lib/pos-access'

const REFUSALS = [
  'resource_outside_area',
  'area_in_use',
  'table_in_use',
  'area_archived',
  'table_archived',
  'manual_status_invalid',
  'service_charge_rate_invalid',
  'bottle_keep_days_invalid',
  'tip_split_invalid',
  'minimum_spend_invalid',
  'qr_order_settings_invalid',
  'qr_order_limit_required',
] as const
const NEW = 'new'
const DEFAULT_FLOOR = { width: 24, height: 16 }

type Notice = { text: string; failed: boolean } | null
type T = (key: string, options?: Record<string, unknown>) => string

function floorFailure(error: unknown, t: T) {
  const reason = conflictReason(error)
  return reason && (REFUSALS as readonly string[]).includes(reason)
    ? t(`floorPlan.failure_${reason}`)
    : describeFailure(error, t)
}

type Attempt = (work: () => Promise<string | null>) => Promise<void>

// Runs one write and reports it in the card's notice.
function useAttempt(t: T) {
  const [notice, setNotice] = useState<Notice>(null)
  const attempt: Attempt = async (work) => {
    setNotice(null)
    try {
      const text = await work()
      if (text) setNotice({ text, failed: false })
    } catch (failure) {
      setNotice({ text: floorFailure(failure, t), failed: true })
    }
  }
  return { notice, attempt }
}

// The floor plan of one branch: its areas, the tables drawn on each area's
// grid, and the table service settings (table register, service charge).
export function BranchFloorPlanTab() {
  const { branch, modules } = useBranchScope()
  const { permissionKeys } = usePermissions()
  const { context } = usePosSession()
  const access = { permissionKeys, context: context.data }
  return (
    <div className="space-y-6">
      <FloorCard write={canManageResources(access)} />
      <TableSettingsCard write={canManageBranch(access, branch.id)} />
      {modules?.['fnb.qr_order'] === true ? (
        <TableCodesCard write={canManageResources(access)} />
      ) : null}
    </div>
  )
}

function NumberField({
  label,
  value,
  min,
  max,
  disabled,
  onChange,
}: {
  label: string
  value: string
  min: number
  max?: number
  disabled?: boolean
  onChange: (value: string) => void
}) {
  const id = useId()
  return (
    <div className="flex flex-col gap-2">
      <Label htmlFor={id}>{label}</Label>
      <Input
        id={id}
        type="number"
        inputMode="numeric"
        min={min}
        max={max}
        step={1}
        required
        value={value}
        disabled={disabled}
        onChange={(event) => onChange(event.target.value)}
      />
    </div>
  )
}

function TextField({
  label,
  value,
  maxLength,
  disabled,
  onChange,
}: {
  label: string
  value: string
  maxLength: number
  disabled?: boolean
  onChange: (value: string) => void
}) {
  const id = useId()
  return (
    <div className="flex flex-col gap-2">
      <Label htmlFor={id}>{label}</Label>
      <Input
        id={id}
        required
        maxLength={maxLength}
        value={value}
        disabled={disabled}
        onChange={(event) => onChange(event.target.value)}
      />
    </div>
  )
}

type AreaDraft = { id?: string; name: string; width: string; height: string }

const areaDraftOf = (area: AreaRecord): AreaDraft => ({
  id: area.id,
  name: area.name,
  width: String(area.floor_width),
  height: String(area.floor_height),
})

const blankTable = (spot: Placement): TableDraft => ({
  name: '',
  kind: 'table',
  capacity: '4',
  shape: 'rect',
  ...placementDraft(spot),
  minimumSpend: '',
})

// The placement the canvas draws for a draft: what was typed when it is a
// whole number, the saved value otherwise.
function draftPlacement(draft: TableDraft, fallback: Placement): Placement {
  const read = (value: string, saved: number) =>
    /^\d+$/.test(value.trim()) ? Number(value) : saved
  return {
    x: read(draft.x, fallback.x),
    y: read(draft.y, fallback.y),
    w: Math.max(1, read(draft.w, fallback.w)),
    h: Math.max(1, read(draft.h, fallback.h)),
    rotation: read(draft.rotation, fallback.rotation),
  }
}

const sameDraft = (left: TableDraft, right: TableDraft) =>
  JSON.stringify(left) === JSON.stringify(right)

function FloorCard({ write }: { write: boolean }) {
  const { t } = useTranslation()
  const { branch } = useBranchScope()
  const areas = useAreas(branch.id)
  const resources = useResources(branch.id)
  const mutation = useFloorPlanWrite()
  const confirm = useConfirm()
  const { notice, attempt } = useAttempt(t)
  const [areaId, setAreaId] = useState<string | null>(null)
  const [areaDraft, setAreaDraft] = useState<AreaDraft | null>(null)
  const [draft, setDraft] = useState<TableDraft | null>(null)

  const area = areas.data?.find((row) => row.id === areaId) ?? areas.data?.[0] ?? null
  const tables = (resources.data ?? []).filter((row) => row.area_id === area?.id)
  const saved = draft?.id ? tables.find((row) => row.id === draft.id) : undefined
  const dirty = Boolean(draft && (!saved || !sameDraft(draft, tableDraftOf(saved))))

  // Leaving a table with unsaved changes asks first.
  const leaveDraft = async () =>
    !dirty ||
    (await confirm({
      message: t('floorPlan.discardConfirm'),
      variant: 'destructive',
      confirmLabel: t('floorPlan.discard'),
      cancelLabel: t('adminCancel'),
    }))

  const pickArea = async (id: string) => {
    if (id === area?.id || !(await leaveDraft())) return
    setDraft(null)
    setAreaDraft(null)
    setAreaId(id)
  }

  const select = async (key: string) => {
    if (key === (draft ? (draft.id ?? NEW) : null) || !(await leaveDraft())) return
    const row = tables.find((table) => table.id === key)
    setDraft(row ? tableDraftOf(row) : null)
  }

  const addTable = async () => {
    if (!area || !(await leaveDraft())) return
    setDraft(blankTable(freeSpot(tables, area, 2, 2)))
  }

  const saveArea = (event: FormEvent) => {
    event.preventDefault()
    if (!areaDraft || mutation.isPending) return
    const width = readFloorSize(areaDraft.width)
    const height = readFloorSize(areaDraft.height)
    if (width === null || height === null || !areaDraft.name.trim()) return
    const body = { name: areaDraft.name.trim(), floor_width: width, floor_height: height }
    void attempt(async () => {
      const result = areaDraft.id
        ? await mutation.mutateAsync({ method: 'PATCH', path: `/pos/areas/${areaDraft.id}`, body })
        : await mutation.mutateAsync({
            method: 'POST',
            path: '/pos/areas',
            body: { branch_id: branch.id, position: areas.data?.length ?? 0, ...body },
          })
      const written = normalizeArea(result.data)
      if (written) setAreaId(written.id)
      setAreaDraft(null)
      return t('saved')
    })
  }

  const archiveArea = async (row: AreaRecord) => {
    const accepted = await confirm({
      message: t('floorPlan.archiveAreaConfirm', { name: row.name }),
      variant: 'destructive',
      confirmLabel: t('floorPlan.archive'),
      cancelLabel: t('adminCancel'),
    })
    if (!accepted) return
    await attempt(async () => {
      await mutation.mutateAsync({ method: 'POST', path: `/pos/areas/${row.id}/archive` })
      setAreaId(null)
      setAreaDraft(null)
      setDraft(null)
      return t('floorPlan.archived')
    })
  }

  const canvasTables: CanvasTable[] = tables.map((row) =>
    draft && row.id === draft.id
      ? { ...row, ...draftPlacement(draft, row), name: draft.name, shape: draft.shape, key: row.id }
      : { ...row, key: row.id },
  )
  if (draft && !draft.id && area) {
    const spot = draftPlacement(draft, { x: 0, y: 0, w: 2, h: 2, rotation: 0 })
    canvasTables.push({
      ...spot,
      key: NEW,
      name: draft.name,
      capacity: Number(draft.capacity) || 0,
      shape: draft.shape,
      manual_status: 'available',
    })
  }

  const loading = areas.isPending || resources.isPending
  const failed = areas.error ?? resources.error

  return (
    <ModelCard title={t('floorPlan.title')} id="branch-floor-plan">
      <p className="text-sm text-muted-foreground">{t('floorPlan.intro')}</p>
      <ModelNotice notice={notice} />
      {loading ? (
        <ModelState title={t('waiting')} />
      ) : failed || !areas.data ? (
        <ModelState
          error
          title={t(posFailureKey(failed))}
          retry={() => {
            void areas.refetch()
            void resources.refetch()
          }}
        />
      ) : (
        <>
          <div className="flex flex-wrap items-end gap-3">
            {area ? (
              <div className="min-w-48">
                <ModelSelect
                  label={t('floorPlan.area')}
                  value={area.id}
                  options={areas.data.map((row) => ({ value: row.id, label: row.name }))}
                  onChange={(value) => void pickArea(value)}
                />
              </div>
            ) : (
              <p className="flex-1">{t('floorPlan.noAreas')}</p>
            )}
            {write && !areaDraft ? (
              <div className="flex flex-wrap gap-2">
                <Button
                  variant="outline"
                  onClick={() =>
                    setAreaDraft({
                      name: '',
                      width: String(DEFAULT_FLOOR.width),
                      height: String(DEFAULT_FLOOR.height),
                    })
                  }
                >
                  {t('floorPlan.addArea')}
                </Button>
                {area ? (
                  <>
                    <Button variant="outline" onClick={() => setAreaDraft(areaDraftOf(area))}>
                      {t('floorPlan.editArea')}
                    </Button>
                    <Button
                      variant="outline"
                      disabled={mutation.isPending}
                      onClick={() => void archiveArea(area)}
                    >
                      {t('floorPlan.archiveArea')}
                    </Button>
                  </>
                ) : null}
              </div>
            ) : null}
          </div>
          {areaDraft ? (
            <AreaForm
              draft={areaDraft}
              tables={areaDraft.id ? tables : []}
              busy={mutation.isPending}
              onChange={setAreaDraft}
              onSubmit={saveArea}
              onCancel={() => setAreaDraft(null)}
            />
          ) : null}
          {area ? (
            <div className="grid gap-4 lg:grid-cols-[minmax(0,1fr)_20rem]">
              <div className="min-w-0 space-y-2">
                <FloorPlanCanvas
                  area={area}
                  tables={canvasTables}
                  selected={draft ? (draft.id ?? NEW) : null}
                  write={write}
                  onSelect={(key) => void select(key)}
                  onPlace={(placement) =>
                    setDraft((current) =>
                      current ? { ...current, ...placementDraft(placement) } : current,
                    )
                  }
                />
                {tables.length === 0 && !draft ? (
                  <p className="text-sm text-muted-foreground">{t('floorPlan.noTables')}</p>
                ) : null}
                {write ? (
                  <Button variant="outline" onClick={() => void addTable()}>
                    {t('floorPlan.addTable')}
                  </Button>
                ) : null}
              </div>
              {draft ? (
                <TableForm
                  key={draft.id ?? NEW}
                  area={area}
                  draft={draft}
                  saved={saved}
                  dirty={dirty}
                  position={resources.data?.length ?? 0}
                  write={write}
                  attempt={attempt}
                  onChange={setDraft}
                  onClose={() => setDraft(null)}
                />
              ) : (
                <p className="text-sm text-muted-foreground">{t('floorPlan.pickTable')}</p>
              )}
            </div>
          ) : null}
        </>
      )}
    </ModelCard>
  )
}

function AreaForm({
  draft,
  tables,
  busy,
  onChange,
  onSubmit,
  onCancel,
}: {
  draft: AreaDraft
  tables: ResourceRecord[]
  busy: boolean
  onChange: (draft: AreaDraft) => void
  onSubmit: (event: FormEvent) => void
  onCancel: () => void
}) {
  const { t } = useTranslation()
  const width = readFloorSize(draft.width)
  const height = readFloorSize(draft.height)
  const outside =
    width !== null && height !== null
      ? tablesOutside(tables, { floor_width: width, floor_height: height })
      : []
  const problem = !draft.name.trim()
    ? null
    : width === null || height === null
      ? t('floorPlan.problem_floor', { min: FLOOR_MIN, max: FLOOR_MAX })
      : outside.length > 0
        ? t('floorPlan.problem_floorTooSmall', {
            names: outside.map((row) => row.name).join(', '),
          })
        : null
  const edit = (patch: Partial<AreaDraft>) => onChange({ ...draft, ...patch })
  return (
    <form
      className="space-y-4 rounded-lg border p-4"
      aria-label={draft.id ? t('floorPlan.editArea') : t('floorPlan.addArea')}
      onSubmit={onSubmit}
    >
      <div className="grid gap-4 sm:grid-cols-3">
        <TextField
          label={t('floorPlan.areaName')}
          value={draft.name}
          maxLength={80}
          onChange={(name) => edit({ name })}
        />
        <NumberField
          label={t('floorPlan.floorWidth')}
          value={draft.width}
          min={FLOOR_MIN}
          max={FLOOR_MAX}
          onChange={(value) => edit({ width: value })}
        />
        <NumberField
          label={t('floorPlan.floorHeight')}
          value={draft.height}
          min={FLOOR_MIN}
          max={FLOOR_MAX}
          onChange={(value) => edit({ height: value })}
        />
      </div>
      <p className="text-sm text-muted-foreground">{t('floorPlan.floorHint')}</p>
      {problem ? (
        <p role="alert" className="text-sm text-destructive">
          {problem}
        </p>
      ) : null}
      <div className="flex gap-2">
        <Button type="submit" disabled={busy || Boolean(problem) || !draft.name.trim()}>
          {t('save')}
        </Button>
        <Button type="button" variant="outline" onClick={onCancel}>
          {t('adminCancel')}
        </Button>
      </div>
    </form>
  )
}

function TableForm({
  area,
  draft,
  saved,
  dirty,
  position,
  write,
  attempt,
  onChange,
  onClose,
}: {
  area: AreaRecord
  draft: TableDraft
  saved: ResourceRecord | undefined
  dirty: boolean
  position: number
  write: boolean
  attempt: Attempt
  onChange: (draft: TableDraft) => void
  onClose: () => void
}) {
  const { t } = useTranslation()
  const { branch } = useBranchScope()
  const mutation = useFloorPlanWrite()
  const confirm = useConfirm()
  const read = readTableDraft(draft, area)
  const problem =
    'problem' in read
      ? t(`floorPlan.problem_${read.problem}`, {
          width: area.floor_width,
          height: area.floor_height,
          max: TABLE_SIZE_MAX,
        })
      : null
  const edit = (patch: Partial<TableDraft>) => onChange({ ...draft, ...patch })
  const locked = !write || mutation.isPending
  const minimumId = useId()

  const save = (event: FormEvent) => {
    event.preventDefault()
    if (!('values' in read) || mutation.isPending) return
    const values = read.values
    void attempt(async () => {
      if (saved) {
        const body = changedFields(saved, values)
        if (Object.keys(body).length === 0) return t('saved')
        const result = await mutation.mutateAsync({
          method: 'PATCH',
          path: `/pos/resources/${saved.id}`,
          body,
        })
        const row = normalizeResource(result.data)
        if (row) onChange(tableDraftOf(row))
        return t('saved')
      }
      const result = await mutation.mutateAsync({
        method: 'POST',
        path: '/pos/resources',
        body: { branch_id: branch.id, area_id: area.id, position, ...values },
      })
      const row = normalizeResource(result.data)
      if (row) onChange(tableDraftOf(row))
      else onClose()
      return t('saved')
    })
  }

  const archive = async () => {
    if (!saved) return
    const accepted = await confirm({
      message: t('floorPlan.archiveTableConfirm', { name: saved.name }),
      variant: 'destructive',
      confirmLabel: t('floorPlan.archive'),
      cancelLabel: t('adminCancel'),
    })
    if (!accepted) return
    await attempt(async () => {
      await mutation.mutateAsync({ method: 'POST', path: `/pos/resources/${saved.id}/archive` })
      onClose()
      return null
    })
  }

  const setStatus = (value: string) =>
    void attempt(async () => {
      if (!saved) return null
      await mutation.mutateAsync({
        method: 'POST',
        path: `/pos/resources/${saved.id}/manual_status`,
        body: { manual_status: value },
      })
      return t('saved')
    })

  return (
    <div className="space-y-4 rounded-lg border p-4">
      <form
        className="space-y-4"
        aria-label={saved ? t('floorPlan.editTable') : t('floorPlan.addTable')}
        onSubmit={save}
      >
        <h3 className="font-semibold">
          {saved ? t('floorPlan.editTable') : t('floorPlan.addTable')}
          {dirty ? (
            <span className="ml-2 text-sm font-normal text-muted-foreground">
              {t('floorPlan.unsaved')}
            </span>
          ) : null}
        </h3>
        <TextField
          label={t('floorPlan.tableName')}
          value={draft.name}
          maxLength={40}
          disabled={locked}
          onChange={(name) => edit({ name })}
        />
        <div className="grid grid-cols-2 gap-4">
          <ModelSelect
            label={t('floorPlan.kind')}
            value={draft.kind}
            disabled={locked}
            options={RESOURCE_KINDS.map((kind) => ({
              value: kind,
              label: t(`floorPlan.kind_${kind}`),
            }))}
            onChange={(value) => edit({ kind: value as TableDraft['kind'] })}
          />
          <ModelSelect
            label={t('floorPlan.shape')}
            value={draft.shape}
            disabled={locked}
            options={RESOURCE_SHAPES.map((shape) => ({
              value: shape,
              label: t(`floorPlan.shape_${shape}`),
            }))}
            onChange={(value) => edit({ shape: value as TableDraft['shape'] })}
          />
          <NumberField
            label={t('floorPlan.capacity')}
            value={draft.capacity}
            min={0}
            max={CAPACITY_MAX}
            disabled={locked}
            onChange={(capacity) => edit({ capacity })}
          />
          <div className="flex flex-col gap-2">
            <Label htmlFor={minimumId}>{t('floorPlan.minimumSpend')}</Label>
            <Input
              id={minimumId}
              inputMode="numeric"
              value={draft.minimumSpend}
              disabled={locked}
              aria-describedby={`${minimumId}-hint`}
              onChange={(event) => edit({ minimumSpend: event.target.value })}
            />
            <small id={`${minimumId}-hint`} className="text-muted-foreground">
              {t('floorPlan.minimumSpendHint')}
            </small>
          </div>
          <NumberField
            label={t('floorPlan.rotation')}
            value={draft.rotation}
            min={0}
            max={359}
            disabled={locked}
            onChange={(rotation) => edit({ rotation })}
          />
          <NumberField
            label={t('floorPlan.x')}
            value={draft.x}
            min={0}
            max={area.floor_width - 1}
            disabled={locked}
            onChange={(x) => edit({ x })}
          />
          <NumberField
            label={t('floorPlan.y')}
            value={draft.y}
            min={0}
            max={area.floor_height - 1}
            disabled={locked}
            onChange={(y) => edit({ y })}
          />
          <NumberField
            label={t('floorPlan.w')}
            value={draft.w}
            min={1}
            max={TABLE_SIZE_MAX}
            disabled={locked}
            onChange={(w) => edit({ w })}
          />
          <NumberField
            label={t('floorPlan.h')}
            value={draft.h}
            min={1}
            max={TABLE_SIZE_MAX}
            disabled={locked}
            onChange={(h) => edit({ h })}
          />
        </div>
        {problem && write ? (
          <p role="alert" className="text-sm text-destructive">
            {problem}
          </p>
        ) : null}
        <div className="flex flex-wrap gap-2">
          {write ? (
            <Button type="submit" disabled={mutation.isPending || Boolean(problem) || !dirty}>
              {t('save')}
            </Button>
          ) : null}
          <Button type="button" variant="outline" onClick={onClose}>
            {write && dirty ? t('adminCancel') : t('floorPlan.close')}
          </Button>
          {write && saved ? (
            <Button
              type="button"
              variant="outline"
              disabled={mutation.isPending}
              onClick={() => void archive()}
            >
              {t('floorPlan.archiveTable')}
            </Button>
          ) : null}
        </div>
      </form>
      {saved ? (
        <ModelSelect
          label={t('floorPlan.manualStatus')}
          value={saved.manual_status}
          disabled={locked}
          hint={t('floorPlan.manualStatusHint')}
          options={MANUAL_STATUSES.map((status) => ({
            value: status,
            label: t(`tableState_${status}`),
          }))}
          onChange={setStatus}
        />
      ) : null}
    </div>
  )
}

type SettingsDraft = {
  register: string
  rate: string
  modes: ServiceMode[]
  tax: string
  keepDays: string
  tipsAsRevenue: boolean
  tipSplit: TipSplit
  qrMode: QrOrderMode
  qrLimit: string
  qrMaxItems: string
}

const settingsDraftOf = (settings: TableSettings): SettingsDraft => ({
  qrMode: settings.qr_order_mode,
  qrLimit: settings.qr_order_auto_limit?.replace(/\.0+$/, '') ?? '',
  qrMaxItems: String(settings.qr_order_auto_max_items),
  register: settings.table_register_id ?? '',
  rate: settings.service_charge_rate ?? '',
  modes: settings.service_charge_applies_to,
  tax: settings.service_charge_tax_category_id ?? '',
  keepDays: settings.bottle_keep_days === null ? '' : String(settings.bottle_keep_days),
  tipsAsRevenue: settings.tips_as_revenue,
  tipSplit: settings.tip_split,
})

// A bar's settings: how long kept bottles stay (with `fnb.bottle_keep`), and
// with `fnb.postpay` whether tips count as revenue and how they are split
// among which roles (none chosen: every staff member of the branch).
function BarSettings({
  draft,
  write,
  bottleKeep,
  tips,
  keepDaysInvalid,
  roles,
  onChange,
}: {
  draft: SettingsDraft
  write: boolean
  bottleKeep: boolean
  tips: boolean
  keepDaysInvalid: boolean
  roles: { id: string; name: string }[]
  onChange: (patch: Partial<SettingsDraft>) => void
}) {
  const { t } = useTranslation()
  const keepId = useId()
  const split = (patch: Partial<TipSplit>) =>
    onChange({ tipSplit: { ...draft.tipSplit, ...patch } })
  return (
    <fieldset className="space-y-4">
      <legend className="text-sm font-medium">{t('floorPlan.barSettings')}</legend>
      {bottleKeep ? (
        <div className="flex flex-col gap-2">
          <Label htmlFor={keepId}>{t('floorPlan.bottleKeepDays')}</Label>
          <Input
            id={keepId}
            inputMode="numeric"
            value={draft.keepDays}
            disabled={!write}
            aria-invalid={keepDaysInvalid}
            aria-describedby={`${keepId}-hint`}
            onChange={(event) => onChange({ keepDays: event.target.value })}
          />
          <small
            id={`${keepId}-hint`}
            className={keepDaysInvalid ? 'text-destructive' : 'text-muted-foreground'}
          >
            {t('floorPlan.bottleKeepDaysHint', { max: BOTTLE_KEEP_DAYS_MAX })}
          </small>
        </div>
      ) : null}
      {tips ? (
        <>
          <ModelCheck
            checked={draft.tipsAsRevenue}
            disabled={!write}
            onChange={(tipsAsRevenue) => onChange({ tipsAsRevenue })}
          >
            {t('floorPlan.tipsAsRevenue')}
          </ModelCheck>
          <small className="block text-muted-foreground">{t('floorPlan.tipsAsRevenueHint')}</small>
          <ModelSelect
            label={t('floorPlan.tipSplitMode')}
            value={draft.tipSplit.mode}
            disabled={!write}
            options={TIP_SPLIT_MODES.map((mode) => ({
              value: mode,
              label: t(`floorPlan.tipSplit_${mode}`),
            }))}
            onChange={(mode) => split({ mode: mode as TipSplit['mode'] })}
          />
          {roles.length > 0 ? (
            <fieldset className="space-y-2">
              <legend className="text-sm font-medium">{t('floorPlan.tipSplitRoles')}</legend>
              {roles.map((role) => (
                <ModelCheck
                  key={role.id}
                  checked={draft.tipSplit.role_codes.includes(role.id)}
                  disabled={!write}
                  onChange={(checked) =>
                    split({
                      role_codes: checked
                        ? [...draft.tipSplit.role_codes, role.id]
                        : draft.tipSplit.role_codes.filter((code) => code !== role.id),
                    })
                  }
                >
                  {role.name}
                </ModelCheck>
              ))}
            </fieldset>
          ) : null}
        </>
      ) : null}
    </fieldset>
  )
}

// How guests' QR orders reach the kitchen: staff confirm each one, or orders
// within an amount and an item count go straight there. The second needs an
// amount; staff still see every order either way.
function QrOrderSettings({
  draft,
  write,
  limitInvalid,
  maxItemsInvalid,
  onChange,
}: {
  draft: SettingsDraft
  write: boolean
  limitInvalid: boolean
  maxItemsInvalid: boolean
  onChange: (patch: Partial<SettingsDraft>) => void
}) {
  const { t } = useTranslation()
  const limitId = useId()
  const countId = useId()
  return (
    <fieldset className="space-y-4">
      <legend className="text-sm font-medium">{t('floorPlan.qrOrder')}</legend>
      <ModelSelect
        label={t('floorPlan.qrOrderMode')}
        value={draft.qrMode}
        disabled={!write}
        hint={t('floorPlan.qrOrderModeHint')}
        options={QR_ORDER_MODES.map((mode) => ({
          value: mode,
          label: t(`floorPlan.qrMode_${mode}`),
        }))}
        onChange={(mode) => onChange({ qrMode: mode as QrOrderMode })}
      />
      <div className="grid gap-4 sm:grid-cols-2">
        <div className="flex flex-col gap-2">
          <Label htmlFor={limitId}>{t('floorPlan.qrOrderLimit')}</Label>
          <Input
            id={limitId}
            inputMode="numeric"
            value={draft.qrLimit}
            disabled={!write}
            aria-invalid={limitInvalid}
            aria-describedby={`${limitId}-hint`}
            onChange={(event) => onChange({ qrLimit: event.target.value })}
          />
          <small
            id={`${limitId}-hint`}
            className={limitInvalid ? 'text-destructive' : 'text-muted-foreground'}
          >
            {t(limitInvalid ? 'floorPlan.qrOrderLimitInvalid' : 'floorPlan.qrOrderLimitHint')}
          </small>
        </div>
        <div className="flex flex-col gap-2">
          <Label htmlFor={countId}>{t('floorPlan.qrOrderMaxItems')}</Label>
          <Input
            id={countId}
            inputMode="numeric"
            value={draft.qrMaxItems}
            disabled={!write}
            aria-invalid={maxItemsInvalid}
            aria-describedby={`${countId}-hint`}
            onChange={(event) => onChange({ qrMaxItems: event.target.value })}
          />
          <small
            id={`${countId}-hint`}
            className={maxItemsInvalid ? 'text-destructive' : 'text-muted-foreground'}
          >
            {t('floorPlan.qrOrderMaxItemsHint', { max: QR_MAX_ITEMS })}
          </small>
        </div>
      </div>
    </fieldset>
  )
}

// The register whose open shift table orders are booked on and, while the
// branch runs the service charge, its rate, service modes and tax category.
function TableSettingsCard({ write }: { write: boolean }) {
  const { t } = useTranslation()
  const { branch, modules } = useBranchScope()
  const { context } = usePosSession()
  const settings = useTableSettings(branch.id)
  const serviceCharge = modules?.['fnb.service_charge'] === true
  const bottleKeep = modules?.['fnb.bottle_keep'] === true
  const tips = modules?.['fnb.postpay'] === true
  const qrOrder = modules?.['fnb.qr_order'] === true
  const roles = useStaffRoles(write && tips)
  const mutation = useFloorPlanWrite()
  const { notice, attempt } = useAttempt(t)
  const [draft, setDraft] = useState<SettingsDraft | null>(null)
  const loaded = settings.data
  const current = draft ?? (loaded ? settingsDraftOf(loaded) : null)
  const rate = current ? readServiceChargeRate(current.rate) : null
  const keepDays = current ? readKeepDays(current.keepDays) : null
  const qrLimit = current ? readQrLimit(current.qrLimit) : null
  const qrMaxItems = current ? readQrMaxItems(current.qrMaxItems) : undefined
  const qrLimitInvalid =
    qrLimit === undefined || (current?.qrMode === 'direct_to_kitchen' && qrLimit === null)
  const qrInvalid = qrOrder && (qrLimitInvalid || qrMaxItems === undefined)

  const edit = (patch: Partial<SettingsDraft>) =>
    setDraft((value) => {
      const base = value ?? current
      return base ? { ...base, ...patch } : value
    })

  const save = (event: FormEvent) => {
    event.preventDefault()
    if (!current || !draft || mutation.isPending || (serviceCharge && rate === undefined)) return
    if ((bottleKeep && keepDays === undefined) || qrInvalid) return
    void attempt(async () => {
      await mutation.mutateAsync({
        method: 'PUT',
        path: '/pos/table_settings',
        body: {
          branch_id: branch.id,
          table_register_id: current.register || null,
          ...(serviceCharge
            ? {
                service_charge_rate: rate ?? null,
                service_charge_applies_to: current.modes,
                service_charge_tax_category_id: current.tax || null,
              }
            : {}),
          ...(bottleKeep && keepDays ? { bottle_keep_days: keepDays } : {}),
          ...(tips ? { tips_as_revenue: current.tipsAsRevenue, tip_split: current.tipSplit } : {}),
          ...(qrOrder
            ? {
                qr_order_mode: current.qrMode,
                qr_order_auto_limit: qrLimit ?? null,
                qr_order_auto_max_items: qrMaxItems,
              }
            : {}),
        },
      })
      setDraft(null)
      return t('saved')
    })
  }

  const registerOptions = [
    { value: '', label: t('floorPlan.noRegister') },
    ...(context.data?.registers ?? [])
      .filter(
        (row) =>
          row.branch_id === branch.id && (row.status === 'active' || row.id === current?.register),
      )
      .map((row) => ({ value: row.id, label: row.name })),
  ]
  if (current?.register && !registerOptions.some((row) => row.value === current.register))
    registerOptions.push({ value: current.register, label: t('floorPlan.registerOther') })
  const taxOptions = [
    { value: '', label: t('floorPlan.taxUnset') },
    ...(loaded?.tax_categories ?? []).map((row) => ({ value: row.id, label: row.name })),
  ]
  if (current?.tax && !taxOptions.some((row) => row.value === current.tax))
    taxOptions.push({ value: current.tax, label: t('floorPlan.taxCurrent') })

  return (
    <ModelCard title={t('floorPlan.settingsTitle')} id="branch-table-settings">
      <p className="text-sm text-muted-foreground">{t('floorPlan.settingsIntro')}</p>
      <ModelNotice notice={notice} />
      {settings.isPending ? (
        <ModelState title={t('waiting')} />
      ) : settings.error || !current ? (
        <ModelState
          error
          title={t(posFailureKey(settings.error))}
          retry={() => void settings.refetch()}
        />
      ) : (
        <form className="space-y-4" onSubmit={save}>
          <ModelSelect
            label={t('floorPlan.tableRegister')}
            value={current.register}
            disabled={!write}
            hint={t('floorPlan.tableRegisterHint')}
            options={registerOptions}
            onChange={(register) => edit({ register })}
          />
          {serviceCharge ? (
            <fieldset className="space-y-4">
              <legend className="text-sm font-medium">{t('floorPlan.serviceCharge')}</legend>
              <div className="grid gap-4 sm:grid-cols-2">
                <div className="flex flex-col gap-2">
                  <Label htmlFor="service-charge-rate">{t('floorPlan.serviceChargeRate')}</Label>
                  <Input
                    id="service-charge-rate"
                    inputMode="decimal"
                    value={current.rate}
                    disabled={!write}
                    aria-invalid={rate === undefined}
                    aria-describedby="service-charge-rate-hint"
                    onChange={(event) => edit({ rate: event.target.value })}
                  />
                  <small
                    id="service-charge-rate-hint"
                    className={rate === undefined ? 'text-destructive' : 'text-muted-foreground'}
                  >
                    {t(
                      rate === undefined
                        ? 'floorPlan.serviceChargeRateInvalid'
                        : 'floorPlan.serviceChargeRateHint',
                      { max: SERVICE_CHARGE_MAX },
                    )}
                  </small>
                </div>
                <ModelSelect
                  label={t('floorPlan.serviceChargeTax')}
                  value={current.tax}
                  disabled={!write}
                  hint={t('floorPlan.serviceChargeTaxHint')}
                  options={taxOptions}
                  onChange={(tax) => edit({ tax })}
                />
              </div>
              <fieldset className="space-y-2">
                <legend className="text-sm font-medium">{t('floorPlan.serviceChargeModes')}</legend>
                {SERVICE_MODES.map((mode) => (
                  <ModelCheck
                    key={mode}
                    checked={current.modes.includes(mode)}
                    disabled={!write}
                    onChange={(checked) =>
                      edit({
                        modes: checked
                          ? SERVICE_MODES.filter(
                              (name) => name === mode || current.modes.includes(name),
                            )
                          : current.modes.filter((name) => name !== mode),
                      })
                    }
                  >
                    {t(`floorPlan.mode_${mode}`)}
                  </ModelCheck>
                ))}
              </fieldset>
            </fieldset>
          ) : null}
          {bottleKeep || tips ? (
            <BarSettings
              draft={current}
              write={write}
              bottleKeep={bottleKeep}
              tips={tips}
              keepDaysInvalid={keepDays === undefined}
              roles={(roles.data ?? []).map((role) => ({ id: role.id, name: role.name }))}
              onChange={edit}
            />
          ) : null}
          {qrOrder ? (
            <QrOrderSettings
              draft={current}
              write={write}
              limitInvalid={qrLimitInvalid}
              maxItemsInvalid={qrMaxItems === undefined}
              onChange={edit}
            />
          ) : null}
          {write ? (
            <Button
              type="submit"
              disabled={
                mutation.isPending ||
                !draft ||
                (serviceCharge && rate === undefined) ||
                (bottleKeep && keepDays === undefined) ||
                qrInvalid
              }
            >
              {t('floorPlan.saveSettings')}
            </Button>
          ) : null}
        </form>
      )}
    </ModelCard>
  )
}
