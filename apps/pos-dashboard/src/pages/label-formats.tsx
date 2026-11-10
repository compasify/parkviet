import type { LabelFormat } from '@parkviet/pos-shared/label-format'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import {
  defineTable,
  PageHeader,
  ResourceTable,
  resourceSearchSchema,
  useResourceMutation,
} from '@spree/dashboard-core'
import {
  ActiveBadge,
  Badge,
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
import { LabelFormatEditor } from '../components/label-format-editor'
import { MasterNotice, MasterState } from '../components/master-page'
import { disableLabelFormat } from '../hooks/use-branch-catalog'
import { readStoreLabelFormats, type StoreLabelFormat } from '../hooks/use-master-data'
import { usePosSession } from '../hooks/use-pos-session'
import { useSession } from '../hooks/use-session'
import { posKey } from '../lib/query-keys'
import { hiddenTimestamps } from '../tables/columns'
import { localList } from '../tables/local-list'

const ROW_ATTRIBUTE = 'data-pos-label-format-id' as const

// The store's scale label formats. Branches pick the ones they read on their
// Features tab; a format is disabled, never deleted, and every change bumps
// the version sale lines record.
export function LabelFormatsPage() {
  const { t } = useTranslation()
  const confirm = useConfirm()
  const client = useQueryClient()
  const { storeId } = useSession()
  const { context } = usePosSession()
  const searchParams = resourceSearchSchema.parse(useSearch({ strict: false }))
  const access = context.data?.administration ?? { read: false, write: false }
  const branchName = (id: string) =>
    context.data?.branches.find((branch) => branch.id === id)?.name ?? t('adminUnavailable')
  const [editor, setEditor] = useState<{ format?: LabelFormat } | null>(null)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const refresh = () => client.invalidateQueries({ queryKey: ['pos', storeId] })
  const mutation = useResourceMutation({
    mutationFn: (format: LabelFormat) => disableLabelFormat(format.id),
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
  const editable = (format: LabelFormat) => access.write && format.status === 'active'
  // The bridge listens on the document once; the ref hands it the current rows.
  const rows = useRef<StoreLabelFormat[]>([])
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
  defineTable<StoreLabelFormat>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('adminSearchName'),
    defaultSort: { field: 'name', direction: 'asc' },
    emptyMessage: t('labelFormatsEmpty'),
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
        key: 'branch_ids',
        label: t('labelFormatBranches'),
        default: true,
        className: 'whitespace-normal',
        render: (format) =>
          format.branch_ids.length ? (
            <div className="flex flex-wrap gap-1">
              {format.branch_ids.map((id) => (
                <Badge key={id} variant="outline">
                  {branchName(id)}
                </Badge>
              ))}
            </div>
          ) : (
            <span className="text-muted-foreground">{t('labelFormatNoBranches')}</span>
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
      ...hiddenTimestamps<StoreLabelFormat>(),
    ],
  })
  return (
    <div className="space-y-6">
      <PageHeader
        title={t('labelFormatsTitle')}
        description={t('labelFormatsIntro')}
        actions={
          access.write ? (
            <Button disabled={mutation.isPending} onClick={() => edit()}>
              {t('labelFormatCreate')}
            </Button>
          ) : access.read ? (
            <Badge variant="outline">{t('adminReadAccess')}</Badge>
          ) : undefined
        }
      />
      <MasterState>
        <MasterNotice notice={notice} />
        <ResourceTable<StoreLabelFormat>
          tableKey={tableKey}
          hideHeader
          queryKey={['pos', 'label-formats', 'table']}
          queryFn={async (params: Record<string, unknown>) => {
            const all = await client.fetchQuery({
              queryKey: posKey(storeId, 'label-formats'),
              queryFn: readStoreLabelFormats,
            })
            rows.current = all
            return localList(all, params, {
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
                  visible: editable(format),
                  destructive: true,
                  disabled: mutation.isPending,
                  onSelect: () => void disable(format),
                },
              ]}
            />
          )}
        />
      </MasterState>
      {editor && access.write && (
        <LabelFormatEditor
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
