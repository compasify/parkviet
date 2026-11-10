import type { LabelFormat } from '@parkviet/pos-shared/label-format'
import { moduleEnabled } from '@parkviet/pos-shared/pos-modules'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import {
  defineTable,
  ResourceTable,
  resourceSearchSchema,
  useResourceMutation,
} from '@spree/dashboard-core'
import {
  ActiveBadge,
  Button,
  ResourceNameCell,
  RowActions,
  useConfirm,
  useRowClickBridge,
} from '@spree/dashboard-ui'
import { BanIcon } from '@spree/dashboard-ui/icons'
import { useQueryClient } from '@tanstack/react-query'
import { useSearch } from '@tanstack/react-router'
import { useCallback, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchSettingsFrame, type BranchSettingsScope } from '../components/branch-settings-frame'
import { LabelFormatEditor } from '../components/label-format-editor'
import { disableLabelFormat } from '../hooks/use-branch-catalog'
import { allPages } from '../hooks/use-topology'
import { hiddenTimestamps } from '../tables/columns'
import { localList } from '../tables/local-list'

const ROW_ATTRIBUTE = 'data-pos-label-format-id' as const

export function LabelFormatsPage() {
  return (
    <BranchSettingsFrame section="labels">
      {(scope) => <LabelFormats key={scope.branch.id} {...scope} />}
    </BranchSettingsFrame>
  )
}
export function LabelFormats({ branch, access, modules, storeId }: BranchSettingsScope) {
  const { t } = useTranslation()
  const confirm = useConfirm()
  const client = useQueryClient()
  const searchParams = resourceSearchSchema.parse(useSearch({ strict: false }))
  const measuredOn = moduleEnabled(modules, 'retail.measured')
  const canSetUp = access.write && measuredOn
  const [editor, setEditor] = useState<{ format?: LabelFormat } | null>(null)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const refresh = () => client.invalidateQueries({ queryKey: ['pos', storeId, 'label-formats'] })
  const mutation = useResourceMutation({
    mutationFn: async (format: LabelFormat) => {
      if (!access.write) throw Object.assign(new Error('Access denied'), { status: 403 })
      return disableLabelFormat(branch.id, format.id)
    },
    successMessage: false,
    errorMessage: false,
  })
  async function disable(format: LabelFormat) {
    if (
      !access.write ||
      mutation.isPending ||
      !(await confirm({
        message: t('labelFormatConfirmDisable', { name: format.name }),
        variant: 'destructive',
        confirmLabel: t('adminDisable'),
        cancelLabel: t('adminCancel'),
      }))
    )
      return
    setNotice(null)
    try {
      await mutation.mutateAsync(format)
      setNotice({ text: t('labelFormatDisabled', { name: format.name }), failed: false })
    } catch (failure) {
      setNotice({ text: describeFailure(failure, t), failed: true })
    } finally {
      await refresh()
    }
  }
  function edit(format?: LabelFormat) {
    setNotice(null)
    setEditor({ format })
  }
  const editable = (format: LabelFormat) => canSetUp && format.status === 'active'
  // The bridge listens on the document once; the ref hands it the current rows.
  const rows = useRef<LabelFormat[]>([])
  const openFormat = useRef<(id: string) => void>(() => {})
  openFormat.current = (id) => {
    const format = rows.current.find((row) => row.id === id)
    if (format && editable(format)) edit(format)
  }
  const openRow = useCallback((id: string) => openFormat.current(id), [])
  useRowClickBridge(ROW_ATTRIBUTE, openRow)
  const summary = (format: LabelFormat) =>
    [
      t('labelFormatSummary', {
        prefix: format.prefix,
        item: format.item_code_length,
        value: format.value_length,
      }),
      t('labelFormatVersion', { version: format.version }),
    ].join(' · ')
  const tableKey = 'pos-label-formats'
  defineTable<LabelFormat>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('adminSearchName'),
    defaultSort: { field: 'name', direction: 'asc' },
    emptyMessage: `${t('labelFormatsEmpty')}. ${t('labelFormatsEmptyHint')}`,
    columns: [
      {
        key: 'name',
        label: t('labelFormatName'),
        sortable: true,
        default: true,
        render: (format) => (
          <ResourceNameCell
            id={format.id}
            dataAttr={editable(format) ? ROW_ATTRIBUTE : undefined}
            name={format.name}
            secondary={summary(format)}
          />
        ),
      },
      {
        key: 'kind',
        label: t('labelFormatKind'),
        sortable: true,
        filterable: true,
        default: true,
        filterType: 'enum',
        filterOptions: (['weight', 'price'] as const).map((value) => ({
          value,
          label: t(`labelFormatKind_${value}`),
        })),
        render: (format) => (
          <div>
            <div>{t(`labelFormatKind_${format.kind}`)}</div>
            <div className="text-xs text-muted-foreground">
              {format.kind === 'weight' && format.value_unit_code
                ? format.value_unit_code
                : t('labelFormatToleranceShort', { tolerance: format.price_tolerance })}{' '}
              · {t('labelFormatDecimalsShort', { decimals: format.value_decimals })}
            </div>
          </div>
        ),
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
        render: (format) => (
          <ActiveBadge
            active={format.status === 'active'}
            activeLabel={t('statusActive')}
            inactiveLabel={t('statusDisabled')}
          />
        ),
      },
      ...hiddenTimestamps<LabelFormat>(),
    ],
  })
  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <p className="text-sm text-muted-foreground">{t('labelFormatsHint')}</p>
        {canSetUp && (
          <Button disabled={mutation.isPending} onClick={() => edit()}>
            {t('labelFormatCreate')}
          </Button>
        )}
      </div>
      {!measuredOn && <p role="note">{t('posModules.retail_measured.off')}</p>}
      {!access.write && <p>{t('adminReadAccess')}</p>}
      {notice && (
        <p
          role={notice.failed ? 'alert' : 'status'}
          className={notice.failed ? 'text-destructive' : 'text-muted-foreground'}
        >
          {notice.text}
        </p>
      )}
      <ResourceTable<LabelFormat>
        tableKey={tableKey}
        hideHeader
        queryKey={['pos', 'label-formats', branch.id, 'table']}
        queryFn={async (params: Record<string, unknown>) => {
          const all = await allPages<LabelFormat>(`/pos/branches/${branch.id}/label_formats`)
          rows.current = all.data
          return localList(all.data, params, {
            searchParam: 'search',
            text: (format) => `${format.name} ${format.prefix}`,
          })
        }}
        searchParams={searchParams}
        rowActions={(format) => (
          <RowActions
            actions={[
              {
                key: 'edit',
                label: t('adminEdit'),
                visible: editable(format),
                disabled: mutation.isPending,
                onSelect: () => edit(format),
              },
              {
                key: 'disable',
                label: t('adminDisable'),
                icon: <BanIcon className="size-4" />,
                visible: access.write && format.status === 'active',
                destructive: true,
                disabled: mutation.isPending,
                onSelect: () => void disable(format),
              },
            ]}
          />
        )}
      />
      {editor && canSetUp && (
        <LabelFormatEditor
          branchId={branch.id}
          format={editor.format}
          onSaved={async (saved) => {
            setNotice({ text: t('labelFormatSaved', { name: saved.name }), failed: false })
            await refresh()
          }}
          onClose={() => setEditor(null)}
        />
      )}
    </div>
  )
}
