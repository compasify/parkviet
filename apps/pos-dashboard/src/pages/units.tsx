import {
  defineTable,
  mapSpreeErrorsToForm,
  PageHeader,
  ResourceTable,
  resourceSearchSchema,
} from '@spree/dashboard-core'
import {
  ActiveBadge,
  Badge,
  Button,
  DialogFooter,
  ResourceNameCell,
  RowActions,
  useConfirm,
  useRowClickBridge,
} from '@spree/dashboard-ui'
import { BanIcon, RotateCcwIcon } from '@spree/dashboard-ui/icons'
import { useQueryClient } from '@tanstack/react-query'
import { useSearch } from '@tanstack/react-router'
import { useCallback, useRef, useState } from 'react'
import { useForm } from 'react-hook-form'
import { useTranslation } from 'react-i18next'
import { MasterNotice, MasterState } from '../components/master-page'
import { TopologyDialog } from '../components/topology-dialog'
import { Input, TopologyField, TopologySelect } from '../components/topology-fields'
import {
  masterFailure,
  readUnits,
  type StoreUnit,
  UNIT_DIMENSIONS,
  type UnitDimension,
  useStoreWrite,
} from '../hooks/use-master-data'
import { usePosSession } from '../hooks/use-pos-session'
import { useSession } from '../hooks/use-session'
import { posKey } from '../lib/query-keys'
import { unitBody, unitSchema } from '../schemas/master-data'
import { hiddenTimestamps } from '../tables/columns'
import { localList } from '../tables/local-list'

const ROW_ATTRIBUTE = 'data-pos-unit-id' as const
const PRECISIONS = ['0', '1', '2', '3'] as const

// The store's units of measure. What a quantity means (code, dimension,
// conversion) is fixed once created; only the name and the sale precision
// change. A unit in use cannot be disabled.
export function UnitsPage() {
  const { t } = useTranslation()
  const confirm = useConfirm()
  const client = useQueryClient()
  const { storeId } = useSession()
  const { context } = usePosSession()
  const searchParams = resourceSearchSchema.parse(useSearch({ strict: false }))
  const access = context.data?.administration ?? { read: false, write: false }
  const write = useStoreWrite()
  const [editor, setEditor] = useState<{ unit?: StoreUnit } | null>(null)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const rows = useRef<StoreUnit[]>([])
  async function setStatus(unit: StoreUnit) {
    const disabling = unit.status === 'active'
    if (
      !access.write ||
      write.isPending ||
      !(await confirm({
        message: t(disabling ? 'adminConfirmDisable' : 'adminConfirmEnable', { name: unit.name }),
        variant: disabling ? 'destructive' : 'default',
        confirmLabel: t(disabling ? 'adminDisable' : 'adminEnable'),
        cancelLabel: t('adminCancel'),
      }))
    )
      return
    setNotice(null)
    try {
      await write.mutateAsync({
        method: 'POST',
        path: `/pos/units/${unit.id}/${disabling ? 'disable' : 'enable'}`,
        body: {},
      })
      setNotice({ text: t('saved'), failed: false })
    } catch (failure) {
      setNotice({ text: masterFailure(failure, t), failed: true })
    }
  }
  function edit(unit?: StoreUnit) {
    setNotice(null)
    setEditor({ unit })
  }
  const openUnit = useRef<(id: string) => void>(() => {})
  openUnit.current = (id) => {
    const unit = rows.current.find((row) => row.id === id)
    if (unit && access.write) edit(unit)
  }
  const openRow = useCallback((id: string) => openUnit.current(id), [])
  useRowClickBridge(ROW_ATTRIBUTE, openRow)
  const tableKey = 'pos-units'
  defineTable<StoreUnit>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('adminSearchName'),
    defaultSort: { field: 'code', direction: 'asc' },
    emptyMessage: t('adminNoResults'),
    columns: [
      {
        key: 'code',
        label: t('adminName'),
        sortable: true,
        default: true,
        render: (unit) => (
          <ResourceNameCell
            id={unit.id}
            dataAttr={access.write ? ROW_ATTRIBUTE : undefined}
            name={unit.name}
            secondary={unit.code}
          />
        ),
      },
      {
        key: 'dimension',
        label: t('units.dimension'),
        sortable: true,
        filterable: true,
        default: true,
        filterType: 'enum',
        filterOptions: UNIT_DIMENSIONS.map((value) => ({
          value,
          label: t(`units.dimension_${value}`),
        })),
        render: (unit) => t(`units.dimension_${unit.dimension}`),
      },
      {
        key: 'base_code',
        label: t('units.conversion'),
        default: true,
        render: (unit) =>
          unit.base_code === unit.code
            ? t('units.canonical')
            : t('units.conversionValue', {
                code: unit.code,
                factor: unit.factor_to_base,
                base: unit.base_code,
              }),
      },
      {
        key: 'sale_precision',
        label: t('units.precision'),
        sortable: true,
        default: true,
        className: 'tabular-nums',
      },
      {
        key: 'status',
        label: t('adminStatus'),
        sortable: true,
        filterable: true,
        default: true,
        filterType: 'enum',
        quickFilter: true,
        filterOptions: ['active', 'disabled'].map((value) => ({
          value,
          label: t(value === 'active' ? 'statusActive' : 'statusDisabled'),
        })),
        render: (unit) => (
          <ActiveBadge
            active={unit.status === 'active'}
            activeLabel={t('statusActive')}
            inactiveLabel={t('statusDisabled')}
          />
        ),
      },
      ...hiddenTimestamps<StoreUnit>(),
    ],
  })
  return (
    <div className="space-y-6">
      <PageHeader
        title={t('units.title')}
        description={t('units.intro')}
        actions={
          access.write ? (
            <Button disabled={write.isPending} onClick={() => edit()}>
              {t('units.create')}
            </Button>
          ) : access.read ? (
            <Badge variant="outline">{t('adminReadAccess')}</Badge>
          ) : undefined
        }
      />
      <MasterState>
        <MasterNotice notice={notice} />
        <ResourceTable<StoreUnit>
          tableKey={tableKey}
          hideHeader
          queryKey={['pos', 'units', 'table']}
          queryFn={async (params: Record<string, unknown>) => {
            const all = await client.fetchQuery({
              queryKey: posKey(storeId, 'units', 'all'),
              queryFn: () => readUnits(true),
            })
            rows.current = all
            return localList(all, params, {
              searchParam: 'search',
              text: (unit) => `${unit.name} ${unit.code}`,
            })
          }}
          searchParams={searchParams}
          rowActions={(unit) => (
            <RowActions
              actions={[
                {
                  key: 'edit',
                  label: t('adminEdit'),
                  visible: access.write,
                  disabled: write.isPending,
                  onSelect: () => edit(unit),
                },
                {
                  key: unit.status === 'active' ? 'disable' : 'enable',
                  label: t(unit.status === 'active' ? 'adminDisable' : 'adminEnable'),
                  icon:
                    unit.status === 'active' ? (
                      <BanIcon className="size-4" />
                    ) : (
                      <RotateCcwIcon className="size-4" />
                    ),
                  visible: access.write,
                  destructive: unit.status === 'active',
                  disabled: write.isPending,
                  onSelect: () => void setStatus(unit),
                },
              ]}
            />
          )}
        />
      </MasterState>
      {editor && access.write && (
        <UnitDialog
          unit={editor.unit}
          units={rows.current}
          onSave={async (body) => {
            await write.mutateAsync({
              method: editor.unit ? 'PATCH' : 'POST',
              path: `/pos/units${editor.unit ? `/${editor.unit.id}` : ''}`,
              body,
            })
            setNotice({ text: t('saved'), failed: false })
          }}
          onClose={() => setEditor(null)}
        />
      )}
    </div>
  )
}

type Values = {
  code: string
  name: string
  dimension: UnitDimension
  base_code: string
  factor_to_base: string
  sale_precision: (typeof PRECISIONS)[number]
}
function UnitDialog({
  unit,
  units,
  onSave,
  onClose,
}: {
  unit?: StoreUnit
  units: StoreUnit[]
  onSave: (body: Record<string, unknown>) => Promise<void>
  onClose: () => void
}) {
  const { t } = useTranslation()
  const form = useForm<Values>({
    defaultValues: {
      code: unit?.code ?? '',
      name: unit?.name ?? '',
      dimension: unit?.dimension ?? 'count',
      base_code: unit && unit.base_code !== unit.code ? unit.base_code : '',
      factor_to_base: String(unit?.factor_to_base ?? 1),
      sale_precision: PRECISIONS.find((p) => p === String(unit?.sale_precision)) ?? '0',
    },
  })
  const draft = form.watch()
  const [error, setError] = useState('')
  const busy = form.formState.isSubmitting
  const dirty = form.formState.isDirty
  const fixed = Boolean(unit)
  const set = <K extends keyof Values>(key: K, value: Values[K]) =>
    form.setValue(key, value as never, { shouldDirty: true })
  // Conversions point at the canonical unit of the same dimension.
  const bases = units.filter(
    (row) =>
      row.code === row.base_code &&
      row.dimension === draft.dimension &&
      row.code !== draft.code &&
      (row.status === 'active' || row.code === draft.base_code),
  )
  async function submit(values: Values) {
    form.clearErrors()
    const parsed = unitSchema.safeParse(values)
    if (!parsed.success) {
      for (const issue of parsed.error.issues)
        form.setError(issue.path[0] as keyof Values, { message: t(issue.message) })
      return
    }
    setError('')
    try {
      await onSave(unitBody(parsed.data, !unit))
      onClose()
    } catch (failure) {
      mapSpreeErrorsToForm(failure, form.setError)
      setError(masterFailure(failure, t))
    }
  }
  const text = (key: 'code' | 'name' | 'factor_to_base', label: string, hint?: string) => (
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
          disabled={fixed && key !== 'name'}
          inputMode={key === 'factor_to_base' ? 'numeric' : 'text'}
          maxLength={key === 'name' ? 64 : key === 'code' ? 16 : 7}
          value={draft[key]}
          onChange={(event) => set(key, event.target.value)}
        />
      )}
    </TopologyField>
  )
  return (
    <TopologyDialog
      title={t(unit ? 'units.editTitle' : 'units.createTitle')}
      subtitle={unit?.name}
      dirty={dirty}
      busy={busy}
      onClose={onClose}
    >
      {(close) => (
        <form onSubmit={form.handleSubmit(submit)} aria-busy={busy} className="space-y-5">
          <fieldset disabled={busy} className="space-y-4">
            <div className="grid gap-4 sm:grid-cols-2">
              {text('name', 'adminName')}
              {text('code', 'code', 'units.codeHint')}
            </div>
            <TopologyField label={t('units.dimension')}>
              {(id) => (
                <TopologySelect
                  id={id}
                  value={draft.dimension}
                  disabled={fixed}
                  options={UNIT_DIMENSIONS.map((value) => ({
                    value,
                    label: t(`units.dimension_${value}`),
                  }))}
                  onChange={(value) => {
                    set('dimension', value as UnitDimension)
                    set('base_code', '')
                    set('factor_to_base', '1')
                  }}
                />
              )}
            </TopologyField>
            <div className="grid gap-4 sm:grid-cols-2">
              <TopologyField label={t('units.base')} hint={t('units.baseHint')}>
                {(id, describedBy) => (
                  <TopologySelect
                    id={id}
                    describedBy={describedBy}
                    value={draft.base_code}
                    disabled={fixed}
                    options={[
                      { value: '', label: t('units.canonical') },
                      ...bases.map((row) => ({
                        value: row.code,
                        label: `${row.name} (${row.code})`,
                      })),
                    ]}
                    onChange={(value) => {
                      set('base_code', value)
                      if (!value) set('factor_to_base', '1')
                    }}
                  />
                )}
              </TopologyField>
              {draft.base_code && text('factor_to_base', 'units.factor', 'units.factorHint')}
            </div>
            <TopologyField label={t('units.precision')} hint={t('units.precisionHint')}>
              {(id, describedBy) => (
                <TopologySelect
                  id={id}
                  describedBy={describedBy}
                  value={draft.sale_precision}
                  options={PRECISIONS.map((value) => ({ value, label: value }))}
                  onChange={(value) => set('sale_precision', value as Values['sale_precision'])}
                />
              )}
            </TopologyField>
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
            <Button type="submit" disabled={busy || !dirty}>
              {t(busy ? 'waiting' : 'save')}
            </Button>
          </DialogFooter>
        </form>
      )}
    </TopologyDialog>
  )
}
