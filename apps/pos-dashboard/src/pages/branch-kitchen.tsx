import {
  conflictReason,
  describeFailure,
  posFailureKey,
} from '@parkviet/pos-shared/request-failure'
import { usePermissions } from '@spree/dashboard-core'
import { Button, Input, Label, useConfirm } from '@spree/dashboard-ui'
import { type FormEvent, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useBranchScope } from '../components/branch-detail'
import { ProductSearch } from '../components/product-search'
import {
  ModelCard,
  ModelCheck,
  ModelNotice,
  ModelSelect,
  ModelState,
} from '../components/setup/model-ui'
import {
  type CupLabelField,
  type CupLabelSettings,
  type KitchenSettings,
  type KitchenStation,
  type KitchenStationKind,
  type StationRoute,
  useCupLabelSettings,
  useKitchenSettings,
  useKitchenStations,
  useKitchenWrite,
  useStationRoutes,
} from '../hooks/use-kitchen'
import { usePosSession } from '../hooks/use-pos-session'
import { usePrinters } from '../hooks/use-printers'
import { canManageKitchen } from '../lib/pos-access'

const KINDS: readonly KitchenStationKind[] = ['prep', 'bar', 'expo']
const MODES = ['counter', 'dine_in', 'takeaway', 'delivery'] as const
const REFUSALS = [
  'kitchen_station_in_use',
  'station_route_taken',
  'module_disabled',
  'cup_label_printer_missing',
  'cup_label_settings_invalid',
  'printer_not_queued',
] as const

type Notice = { text: string; failed: boolean } | null
type T = (key: string, options?: Record<string, unknown>) => string

function kitchenFailure(error: unknown, t: T) {
  const reason = conflictReason(error)
  return reason && (REFUSALS as readonly string[]).includes(reason)
    ? t(`branchKitchen.failure_${reason}`)
    : describeFailure(error, t)
}

// The kitchen of one branch: when orders go to it, its stations (screen,
// printer, timers), which station makes what, and its cup labels.
export function BranchKitchenTab() {
  const { branch } = useBranchScope()
  const { permissionKeys } = usePermissions()
  const { context } = usePosSession()
  const write = canManageKitchen({ permissionKeys, context: context.data })
  const stations = useKitchenStations(branch.id)
  const settings = useKitchenSettings(branch.id)
  return (
    <div className="space-y-6">
      <TriggerCard settings={settings.data} loading={settings.isPending} write={write} />
      <StationsCard write={write} />
      {stations.data && stations.data.length > 0 ? (
        <RoutesCard stations={stations.data} write={write} />
      ) : null}
      <CupLabelsCard write={write} />
    </div>
  )
}

function TriggerCard({
  settings,
  loading,
  write,
}: {
  settings?: KitchenSettings
  loading: boolean
  write: boolean
}) {
  const { t } = useTranslation()
  const { branch } = useBranchScope()
  const mutation = useKitchenWrite()
  const [notice, setNotice] = useState<Notice>(null)
  async function pick(value: string) {
    setNotice(null)
    try {
      await mutation.mutateAsync({
        method: 'PUT',
        path: '/pos/kitchen_settings',
        body: { branch_id: branch.id, kitchen_send_trigger: value },
      })
      setNotice({ text: t('saved'), failed: false })
    } catch (failure) {
      setNotice({ text: kitchenFailure(failure, t), failed: true })
    }
  }
  return (
    <ModelCard title={t('branchKitchen.title')} id="branch-kitchen">
      <p className="text-sm text-muted-foreground">{t('branchKitchen.intro')}</p>
      {loading || !settings ? (
        <ModelState title={t('waiting')} />
      ) : (
        <>
          {settings.module_enabled ? null : (
            <p role="status" className="rounded-lg border p-3 text-sm">
              {t('branchKitchen.moduleOff')}
            </p>
          )}
          <ModelNotice notice={notice} />
          <ModelSelect
            label={t('branchKitchen.trigger')}
            value={settings.kitchen_send_trigger}
            disabled={!write || mutation.isPending}
            hint={t(`branchKitchen.triggerHint_${settings.kitchen_send_trigger}`)}
            options={[
              { value: 'on_complete', label: t('branchKitchen.trigger_on_complete') },
              { value: 'manual', label: t('branchKitchen.trigger_manual') },
            ]}
            onChange={(value) => void pick(value)}
          />
        </>
      )}
    </ModelCard>
  )
}

type StationDraft = {
  id?: string
  name: string
  kind: KitchenStationKind
  printer_id: string
  kds_enabled: boolean
  is_default: boolean
  warn_after_minutes: string
  late_after_minutes: string
  position: string
  active: boolean
}

const blankStation = (position: number): StationDraft => ({
  name: '',
  kind: 'prep',
  printer_id: '',
  kds_enabled: true,
  is_default: position === 0,
  warn_after_minutes: '8',
  late_after_minutes: '15',
  position: String(position),
  active: true,
})

const draftOf = (row: KitchenStation): StationDraft => ({
  id: row.id,
  name: row.name,
  kind: row.kind,
  printer_id: row.printer_id ?? '',
  kds_enabled: row.kds_enabled,
  is_default: row.is_default,
  warn_after_minutes: String(row.warn_after_minutes),
  late_after_minutes: String(row.late_after_minutes),
  position: String(row.position),
  active: row.active,
})

function StationsCard({ write }: { write: boolean }) {
  const { t } = useTranslation()
  const { branch } = useBranchScope()
  const stations = useKitchenStations(branch.id)
  const printers = usePrinters(branch.id)
  const mutation = useKitchenWrite()
  const confirm = useConfirm()
  const [draft, setDraft] = useState<StationDraft | null>(null)
  const [notice, setNotice] = useState<Notice>(null)

  const attempt = async (work: () => Promise<void>) => {
    setNotice(null)
    try {
      await work()
    } catch (failure) {
      setNotice({ text: kitchenFailure(failure, t), failed: true })
    }
  }

  const save = (event: FormEvent) => {
    event.preventDefault()
    if (!draft || mutation.isPending) return
    const body = {
      name: draft.name.trim(),
      kind: draft.kind,
      printer_id: draft.printer_id || null,
      kds_enabled: draft.kds_enabled,
      is_default: draft.is_default,
      warn_after_minutes: Number(draft.warn_after_minutes),
      late_after_minutes: Number(draft.late_after_minutes),
      position: Number(draft.position),
      active: draft.active,
    }
    void attempt(async () => {
      await (draft.id
        ? mutation.mutateAsync({ method: 'PATCH', path: `/pos/kitchen_stations/${draft.id}`, body })
        : mutation.mutateAsync({
            method: 'POST',
            path: '/pos/kitchen_stations',
            body: { branch_id: branch.id, ...body },
          }))
      setDraft(null)
      setNotice({ text: t('saved'), failed: false })
    })
  }

  const remove = async (row: KitchenStation) => {
    const accepted = await confirm({
      message: t('branchKitchen.deleteConfirm', { name: row.name }),
      variant: 'destructive',
      confirmLabel: t('branchKitchen.delete'),
      cancelLabel: t('adminCancel'),
    })
    if (!accepted) return
    await attempt(async () => {
      await mutation.mutateAsync({ method: 'DELETE', path: `/pos/kitchen_stations/${row.id}` })
    })
  }

  const edit = (patch: Partial<StationDraft>) =>
    setDraft((current) => (current ? { ...current, ...patch } : current))
  const printerOptions = [
    { value: '', label: t('branchKitchen.noPrinter') },
    ...(printers.data ?? [])
      .filter((row) => row.status === 'active')
      .map((row) => ({ value: row.id, label: row.name })),
  ]

  return (
    <ModelCard title={t('branchKitchen.stations')} id="branch-kitchen-stations">
      <p className="text-sm text-muted-foreground">{t('branchKitchen.stationsIntro')}</p>
      <ModelNotice notice={notice} />
      {stations.isPending ? (
        <ModelState title={t('waiting')} />
      ) : stations.error || !stations.data ? (
        <ModelState
          error
          title={t(posFailureKey(stations.error))}
          retry={() => void stations.refetch()}
        />
      ) : stations.data.length === 0 ? (
        <p>{t('branchKitchen.empty')}</p>
      ) : (
        <ul className="divide-y" aria-label={t('branchKitchen.stations')}>
          {stations.data.map((row) => (
            <li
              key={row.id}
              className="flex flex-wrap items-center gap-3 py-3"
              data-testid="station-row"
            >
              <div className="min-w-0 flex-1">
                <strong>{row.name}</strong>
                {row.is_default ? ` · ${t('branchKitchen.default')}` : ''}
                <p className="text-sm text-muted-foreground">
                  {t(`branchKitchen.kind_${row.kind}`)} ·{' '}
                  {row.printer_name ?? t('branchKitchen.noPrinter')} ·{' '}
                  {row.kds_enabled ? t('branchKitchen.screenOn') : t('branchKitchen.screenOff')} ·{' '}
                  {t('branchKitchen.timers', {
                    warn: row.warn_after_minutes,
                    late: row.late_after_minutes,
                  })}
                  {row.active ? '' : ` · ${t('branchKitchen.inactive')}`}
                </p>
              </div>
              {write ? (
                <div className="flex flex-wrap gap-2">
                  <Button variant="outline" onClick={() => setDraft(draftOf(row))}>
                    {t('branchKitchen.edit')}
                  </Button>
                  <Button
                    variant="outline"
                    disabled={mutation.isPending}
                    onClick={() => void remove(row)}
                  >
                    {t('branchKitchen.delete')}
                  </Button>
                </div>
              ) : null}
            </li>
          ))}
        </ul>
      )}
      {write && !draft ? (
        <div>
          <Button onClick={() => setDraft(blankStation(stations.data?.length ?? 0))}>
            {t('branchKitchen.add')}
          </Button>
        </div>
      ) : null}
      {draft ? (
        <form
          className="space-y-4 rounded-lg border p-4"
          aria-label={draft.id ? t('branchKitchen.edit') : t('branchKitchen.add')}
          onSubmit={save}
        >
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="flex flex-col gap-2">
              <Label htmlFor="kitchen-station-name">{t('branchKitchen.name')}</Label>
              <Input
                id="kitchen-station-name"
                required
                maxLength={80}
                value={draft.name}
                onChange={(event) => edit({ name: event.target.value })}
              />
            </div>
            <ModelSelect
              label={t('branchKitchen.kind')}
              value={draft.kind}
              options={KINDS.map((kind) => ({
                value: kind,
                label: t(`branchKitchen.kind_${kind}`),
              }))}
              onChange={(value) => edit({ kind: value as KitchenStationKind })}
            />
            <ModelSelect
              label={t('branchKitchen.printer')}
              value={draft.printer_id}
              options={printerOptions}
              hint={t('branchKitchen.printerHint')}
              onChange={(value) => edit({ printer_id: value })}
            />
            <div className="flex flex-col gap-2">
              <Label htmlFor="kitchen-station-position">{t('branchKitchen.position')}</Label>
              <Input
                id="kitchen-station-position"
                type="number"
                min={0}
                value={draft.position}
                onChange={(event) => edit({ position: event.target.value })}
              />
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="kitchen-station-warn">{t('branchKitchen.warnAfter')}</Label>
              <Input
                id="kitchen-station-warn"
                type="number"
                min={1}
                max={240}
                required
                value={draft.warn_after_minutes}
                onChange={(event) => edit({ warn_after_minutes: event.target.value })}
              />
            </div>
            <div className="flex flex-col gap-2">
              <Label htmlFor="kitchen-station-late">{t('branchKitchen.lateAfter')}</Label>
              <Input
                id="kitchen-station-late"
                type="number"
                min={1}
                max={240}
                required
                value={draft.late_after_minutes}
                onChange={(event) => edit({ late_after_minutes: event.target.value })}
              />
            </div>
          </div>
          <ModelCheck
            checked={draft.kds_enabled}
            onChange={(value) => edit({ kds_enabled: value })}
          >
            {t('branchKitchen.kdsEnabled')}
          </ModelCheck>
          <ModelCheck
            checked={draft.is_default}
            onChange={(value) => edit({ is_default: value })}
            description={t('branchKitchen.defaultHint')}
          >
            {t('branchKitchen.isDefault')}
          </ModelCheck>
          <ModelCheck checked={draft.active} onChange={(value) => edit({ active: value })}>
            {t('branchKitchen.active')}
          </ModelCheck>
          <div className="flex gap-2">
            <Button type="submit" disabled={mutation.isPending || !draft.name.trim()}>
              {t('save')}
            </Button>
            <Button type="button" variant="outline" onClick={() => setDraft(null)}>
              {t('adminCancel')}
            </Button>
          </div>
        </form>
      ) : null}
    </ModelCard>
  )
}

function RoutesCard({ stations, write }: { stations: KitchenStation[]; write: boolean }) {
  const { t } = useTranslation()
  const { branch } = useBranchScope()
  const routes = useStationRoutes(branch.id)
  const mutation = useKitchenWrite()
  const [notice, setNotice] = useState<Notice>(null)
  const [station, setStation] = useState(stations[0]?.id ?? '')
  const [target, setTarget] = useState<'product' | 'category'>('category')
  const [product, setProduct] = useState<{ id: string; name: string } | null>(null)
  const [category, setCategory] = useState('')
  const [mode, setMode] = useState('')

  const stationName = (id: string) => stations.find((row) => row.id === id)?.name ?? id
  const modeName = (value: string | null) =>
    value ? t(`branchKitchen.mode_${value}`) : t('branchKitchen.allModes')

  const attempt = async (work: () => Promise<void>) => {
    setNotice(null)
    try {
      await work()
    } catch (failure) {
      setNotice({ text: kitchenFailure(failure, t), failed: true })
    }
  }

  const ready =
    Boolean(station) && (target === 'product' ? Boolean(product) : Boolean(category.trim()))
  const add = (event: FormEvent) => {
    event.preventDefault()
    if (!ready || mutation.isPending) return
    void attempt(async () => {
      await mutation.mutateAsync({
        method: 'POST',
        path: '/pos/station_routes',
        body: {
          branch_id: branch.id,
          kitchen_station_id: station,
          product_id: target === 'product' ? product?.id : null,
          kitchen_category: target === 'category' ? category.trim() : null,
          service_mode: mode || null,
        },
      })
      setProduct(null)
      setCategory('')
      setNotice({ text: t('saved'), failed: false })
    })
  }

  const remove = (row: StationRoute) =>
    attempt(async () => {
      await mutation.mutateAsync({ method: 'DELETE', path: `/pos/station_routes/${row.id}` })
    })

  return (
    <ModelCard title={t('branchKitchen.routes')} id="branch-kitchen-routes">
      <p className="text-sm text-muted-foreground">{t('branchKitchen.routesIntro')}</p>
      <ModelNotice notice={notice} />
      {routes.isPending ? (
        <ModelState title={t('waiting')} />
      ) : routes.error || !routes.data ? (
        <ModelState
          error
          title={t(posFailureKey(routes.error))}
          retry={() => void routes.refetch()}
        />
      ) : routes.data.length === 0 ? (
        <p>{t('branchKitchen.noRoutes')}</p>
      ) : (
        <ul className="divide-y" aria-label={t('branchKitchen.routes')}>
          {routes.data.map((row) => (
            <li
              key={row.id}
              className="flex flex-wrap items-center gap-3 py-2"
              data-testid="route-row"
            >
              <span className="min-w-0 flex-1">
                {row.product_name ??
                  t('branchKitchen.categoryTarget', { category: row.kitchen_category })}{' '}
                → <strong>{stationName(row.kitchen_station_id)}</strong> ·{' '}
                {modeName(row.service_mode)}
              </span>
              {write ? (
                <Button
                  variant="outline"
                  disabled={mutation.isPending}
                  onClick={() => void remove(row)}
                >
                  {t('branchKitchen.delete')}
                </Button>
              ) : null}
            </li>
          ))}
        </ul>
      )}
      {write ? (
        <form
          className="space-y-4 rounded-lg border p-4"
          aria-label={t('branchKitchen.addRoute')}
          onSubmit={add}
        >
          <div className="grid gap-4 sm:grid-cols-3">
            <ModelSelect
              label={t('branchKitchen.routeStation')}
              value={station}
              options={stations.map((row) => ({ value: row.id, label: row.name }))}
              onChange={setStation}
            />
            <ModelSelect
              label={t('branchKitchen.routeTarget')}
              value={target}
              options={[
                { value: 'category', label: t('branchKitchen.target_category') },
                { value: 'product', label: t('branchKitchen.target_product') },
              ]}
              onChange={(value) => setTarget(value as 'product' | 'category')}
            />
            <ModelSelect
              label={t('branchKitchen.routeMode')}
              value={mode}
              options={[
                { value: '', label: t('branchKitchen.allModes') },
                ...MODES.map((value) => ({ value, label: t(`branchKitchen.mode_${value}`) })),
              ]}
              onChange={setMode}
            />
          </div>
          {target === 'category' ? (
            <div className="flex flex-col gap-2">
              <Label htmlFor="kitchen-route-category">{t('branchKitchen.category')}</Label>
              <Input
                id="kitchen-route-category"
                maxLength={40}
                value={category}
                onChange={(event) => setCategory(event.target.value)}
              />
              <small className="text-muted-foreground">{t('branchKitchen.categoryHint')}</small>
            </div>
          ) : (
            <div className="space-y-2">
              <ProductSearch
                branchId={branch.id}
                label={t('branchKitchen.product')}
                onPick={(hit) => setProduct({ id: hit.productId, name: hit.name })}
              />
              {product ? <p className="text-sm">{product.name}</p> : null}
            </div>
          )}
          <Button type="submit" disabled={!ready || mutation.isPending}>
            {t('branchKitchen.addRoute')}
          </Button>
        </form>
      ) : null}
    </ModelCard>
  )
}

type CupDraft = {
  printer_id: string
  size: string
  fields: CupLabelField[]
  pickup_minutes: string
}

const cupDraftOf = (settings: CupLabelSettings): CupDraft => ({
  printer_id: settings.printer_id ?? '',
  size: settings.size,
  fields: settings.fields,
  pickup_minutes: String(settings.pickup_minutes),
})

// Cup labels: the label printer, the label size, what each label shows, how
// long a ready call number stays on the call board, and a test label.
function CupLabelsCard({ write }: { write: boolean }) {
  const { t } = useTranslation()
  const { branch } = useBranchScope()
  const settings = useCupLabelSettings(branch.id)
  const printers = usePrinters(branch.id)
  const mutation = useKitchenWrite()
  const [draft, setDraft] = useState<CupDraft | null>(null)
  const [notice, setNotice] = useState<Notice>(null)
  const loaded = settings.data
  const current = draft ?? (loaded ? cupDraftOf(loaded) : null)

  const attempt = async (work: () => Promise<string>) => {
    setNotice(null)
    try {
      setNotice({ text: await work(), failed: false })
    } catch (failure) {
      setNotice({ text: kitchenFailure(failure, t), failed: true })
    }
  }

  const save = (event: FormEvent) => {
    event.preventDefault()
    if (!current || mutation.isPending) return
    void attempt(async () => {
      await mutation.mutateAsync({
        method: 'PUT',
        path: '/pos/cup_label_settings',
        body: {
          branch_id: branch.id,
          printer_id: current.printer_id || null,
          size: current.size,
          fields: current.fields,
          pickup_minutes: Number(current.pickup_minutes),
        },
      })
      setDraft(null)
      return t('saved')
    })
  }

  const testPrint = () =>
    void attempt(async () => {
      await mutation.mutateAsync({
        method: 'POST',
        path: '/pos/cup_label_settings/test',
        body: { branch_id: branch.id },
      })
      return t('branchKitchen.cupTestSent')
    })

  const edit = (patch: Partial<CupDraft>) =>
    setDraft((value) => ({ ...(value ?? (current as CupDraft)), ...patch }))
  const printerOptions = [
    { value: '', label: t('branchKitchen.noPrinter') },
    ...(printers.data ?? [])
      .filter((row) => row.status === 'active' || row.id === current?.printer_id)
      .map((row) => ({ value: row.id, label: row.name })),
  ]

  return (
    <ModelCard title={t('branchKitchen.cupTitle')} id="branch-cup-labels">
      <p className="text-sm text-muted-foreground">{t('branchKitchen.cupIntro')}</p>
      {!loaded || !current ? (
        <ModelState title={t('waiting')} />
      ) : (
        <form className="space-y-4" onSubmit={save}>
          {loaded.module_enabled ? null : (
            <p role="status" className="rounded-lg border p-3 text-sm">
              {t('branchKitchen.cupModuleOff')}
            </p>
          )}
          <ModelNotice notice={notice} />
          <div className="grid gap-4 sm:grid-cols-2">
            <ModelSelect
              label={t('branchKitchen.cupPrinter')}
              value={current.printer_id}
              disabled={!write}
              hint={t('branchKitchen.cupPrinterHint')}
              options={printerOptions}
              onChange={(value) => edit({ printer_id: value })}
            />
            <ModelSelect
              label={t('branchKitchen.cupSize')}
              value={current.size}
              disabled={!write}
              options={loaded.sizes.map((size) => ({
                value: size,
                label: t('branchKitchen.cupSizeLabel', { size: size.replace('x', ' × ') }),
              }))}
              onChange={(value) => edit({ size: value })}
            />
            <div className="space-y-2">
              <Label htmlFor="cup-pickup-minutes">{t('branchKitchen.cupPickup')}</Label>
              <Input
                id="cup-pickup-minutes"
                type="number"
                min={1}
                max={120}
                value={current.pickup_minutes}
                disabled={!write}
                onChange={(event) => edit({ pickup_minutes: event.target.value })}
              />
              <p className="text-sm text-muted-foreground">{t('branchKitchen.cupPickupHint')}</p>
            </div>
          </div>
          <fieldset className="space-y-2">
            <legend className="text-sm font-medium">{t('branchKitchen.cupFields')}</legend>
            {loaded.available_fields.map((field) => (
              <ModelCheck
                key={field}
                checked={current.fields.includes(field)}
                disabled={!write}
                onChange={(checked) =>
                  edit({
                    fields: checked
                      ? loaded.available_fields.filter(
                          (name) => name === field || current.fields.includes(name),
                        )
                      : current.fields.filter((name) => name !== field),
                  })
                }
              >
                {t(`branchKitchen.cupField_${field}`)}
              </ModelCheck>
            ))}
          </fieldset>
          {write ? (
            <div className="flex flex-wrap gap-2">
              <Button type="submit" disabled={mutation.isPending || !draft}>
                {t('branchKitchen.cupSave')}
              </Button>
              <Button
                type="button"
                variant="outline"
                disabled={mutation.isPending || !loaded.printer_id || Boolean(draft)}
                onClick={testPrint}
              >
                {t('branchKitchen.cupTest')}
              </Button>
            </div>
          ) : null}
        </form>
      )}
    </ModelCard>
  )
}
