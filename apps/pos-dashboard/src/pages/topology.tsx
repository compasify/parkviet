import { branchSettingVisible } from '@parkviet/pos-shared/module-registry'
import { posCapabilities } from '@parkviet/pos-shared/pos-capabilities'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import {
  type ColumnDef,
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
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  ResourceNameCell,
  type RowAction,
  RowActions,
  useConfirm,
  useRowClickBridge,
} from '@spree/dashboard-ui'
import {
  BanIcon,
  PackageIcon,
  RotateCcwIcon,
  SlidersHorizontalIcon,
  StoreIcon,
  TagIcon,
} from '@spree/dashboard-ui/icons'
import { useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { useCallback, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import {
  type TopologyDraft,
  TopologyEditor,
  type TopologyKind,
} from '../components/topology-editor'
import { useBranchModules } from '../hooks/use-branch-modules'
import { useBusinessProfiles } from '../hooks/use-business-profiles'
import { useStoreProfile } from '../hooks/use-onboarding'
import { usePosSession } from '../hooks/use-pos-session'
import { useSession } from '../hooks/use-session'
import {
  allPages,
  useBranches,
  useLocationOptions,
  useMemberships,
  useRegisters,
  useStaffOptions,
} from '../hooks/use-topology'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { hiddenTimestamps } from '../tables/columns'
import { localList } from '../tables/local-list'

type TopologyRow = TopologyDraft & {
  id: string
  status: string
  branch_id?: string
  staff_id?: string
  staff?: { id: string; email: string; full_name: string | null }
}

// Branch pages reached from the row menu. Label formats only exist for branches
// whose modules include them, which is a per-branch lookup.
function BranchRowActions({ row, actions }: { row: TopologyRow; actions: RowAction[] }) {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const { storeId } = useSession()
  const { context } = usePosSession()
  const modules = useBranchModules(row.id)
  const open = (path: string) => () =>
    void navigate({ to: `/${storeId}/branches/${row.id}/${path}` as string })
  return (
    <RowActions
      actions={[
        ...actions.slice(0, 1),
        {
          key: 'products',
          label: t('branchProductsTitle'),
          icon: <PackageIcon className="size-4" />,
          onSelect: open('products'),
        },
        {
          key: 'label-formats',
          label: t('labelFormatsTitle'),
          icon: <TagIcon className="size-4" />,
          visible: branchSettingVisible({ ...context.data, modules }, 'label-formats'),
          onSelect: open('label-formats'),
        },
        {
          key: 'features',
          label: t('branchFeaturesTitle'),
          icon: <SlidersHorizontalIcon className="size-4" />,
          onSelect: open('features'),
        },
        {
          key: 'business-model',
          label: t('businessModel.title'),
          icon: <StoreIcon className="size-4" />,
          onSelect: open('business-model'),
        },
        ...actions.slice(1),
      ]}
    />
  )
}

export function TopologyPage({ kind = 'branches' }: { kind?: TopologyKind }) {
  const { t } = useTranslation()
  const { context } = usePosSession()
  const { storeId } = useSession()
  const queryClient = useQueryClient()
  const confirm = useConfirm()
  const searchParams = resourceSearchSchema.parse(useSearch({ strict: false }))
  // Selling-membership capabilities never authorize store administration.
  const access = context.data?.administration ?? { read: false, write: false }
  const branches = useBranches(access.read)
  const registers = useRegisters(access.read)
  const memberships = useMemberships(access.read)
  const staff = useStaffOptions(access.read)
  const locations = useLocationOptions(access.read)
  const profiles = useBusinessProfiles(context.data?.store.id ?? null, access.write)
  const storeProfile = useStoreProfile(context.data?.store.id ?? null, access.write)
  const [editor, setEditor] = useState<TopologyDraft | null>(null)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const editedModules = useBranchModules(kind === 'branches' ? (editor?.id ?? null) : null)
  const dependencies = [branches, registers, memberships, staff, locations]
  const ready = dependencies.every((query) => query.isSuccess)
  const loadError = dependencies.find((query) => query.isError)?.error
  const branchRows = branches.data?.data ?? []
  const membershipRows = memberships.data?.data ?? []
  const locationRows = locations.data?.data ?? []
  const staffRows = [
    ...(staff.data?.data ?? []),
    ...membershipRows.flatMap((m) => (m.staff ? [m.staff] : [])),
  ].filter((user, index, all) => all.findIndex((other) => other.id === user.id) === index)
  const branchName = (id?: string) =>
    branchRows.find((branch) => branch.id === id)?.name ?? t('adminUnavailable')
  const locationName = (id?: string | null) =>
    locationRows.find((item) => item.id === id)?.name ?? t('adminUnavailable')
  const staffUser = (row: TopologyRow) =>
    row.staff ?? staffRows.find((item) => item.id === row.staff_id)
  const staffName = (row: TopologyRow) => {
    const user = staffUser(row)
    return user
      ? `${user.full_name ? `${user.full_name} · ` : ''}${user.email}`
      : t('adminUnavailable')
  }
  const rowName = (row: TopologyRow) => (kind === 'memberships' ? staffName(row) : (row.name ?? ''))
  const canEdit = access.write && ready
  async function refresh() {
    await queryClient.invalidateQueries({
      predicate: (query) => query.queryKey[0] === 'pos' && query.queryKey[1] === storeId,
    })
  }
  const mutation = useResourceMutation({
    mutationFn: async ({
      method,
      path,
      body,
    }: {
      method: string
      path: string
      body: Record<string, unknown>
    }) => {
      if (!access.write) throw Object.assign(new Error('Access denied'), { status: 403 })
      return posRequest(method, path, { body })
    },
    successMessage: false,
    errorMessage: false,
  })
  async function save(body: Record<string, unknown>) {
    if (!editor) return
    await mutation.mutateAsync({
      method: editor.id ? 'PATCH' : 'POST',
      path: `/pos/${kind}${editor.id ? `/${editor.id}` : ''}`,
      body,
    })
    setNotice({ text: t('saved'), failed: false })
    await refresh()
  }
  async function changeStatus(record: TopologyRow) {
    if (mutation.isPending || !access.write) return
    const name = rowName(record)
    const disabling = record.status === 'active'
    if (
      !(await confirm({
        message: t(disabling ? 'adminConfirmDisable' : 'adminConfirmEnable', { name }),
        variant: disabling ? 'destructive' : 'default',
        confirmLabel: t(disabling ? 'adminDisable' : 'adminEnable'),
        cancelLabel: t('adminCancel'),
      }))
    )
      return
    setNotice(null)
    try {
      await mutation.mutateAsync({
        method: 'POST',
        path: `/pos/${kind}/${record.id}/${disabling ? 'disable' : 'enable'}`,
        body: {},
      })
      setNotice({ text: t('saved'), failed: false })
      await refresh()
    } catch (failure) {
      setNotice({ text: describeFailure(failure, t), failed: true })
    }
  }
  function edit(record: TopologyDraft) {
    setNotice(null)
    setEditor(record)
  }
  // Re-enabling needs the recovery capability at the record's branch.
  const recoverable = (record: TopologyRow) =>
    record.status === 'active' ||
    membershipRows.some(
      (m) =>
        m.branch_id === (kind === 'branches' ? record.id : record.branch_id) &&
        m.staff_id === context.data?.staff.id &&
        m.capabilities.includes('pos.topology.recover'),
    )
  function rowActions(record: TopologyRow): RowAction[] {
    const active = record.status === 'active'
    return [
      {
        key: 'edit',
        label: t('adminEdit'),
        visible: access.write,
        disabled: !canEdit || mutation.isPending,
        onSelect: () => edit(record),
      },
      {
        key: active ? 'disable' : 'enable',
        label: t(
          active ? 'adminDisable' : recoverable(record) ? 'adminEnable' : 'adminRecoveryRequired',
        ),
        icon: active ? <BanIcon className="size-4" /> : <RotateCcwIcon className="size-4" />,
        visible: access.write,
        destructive: active,
        disabled: mutation.isPending || !recoverable(record),
        onSelect: () => void changeStatus(record),
      },
    ]
  }

  const tableKey = `pos-${kind}`
  const rowAttribute = `data-pos-${kind}-id` as const
  const records = (): TopologyRow[] =>
    ((kind === 'branches'
      ? branchRows
      : kind === 'registers'
        ? registers.data?.data
        : membershipRows) ?? []) as TopologyRow[]
  // The bridge listens on the document once; the ref hands it the current rows.
  const openRecord = useRef<(id: string) => void>(() => {})
  openRecord.current = (id) => {
    const record = records().find((row) => row.id === id)
    if (record && canEdit) edit(record)
  }
  const openRow = useCallback((id: string) => openRecord.current(id), [])
  useRowClickBridge(rowAttribute, openRow)
  const nameCell = (row: TopologyRow, name: string, secondary?: string) => (
    <ResourceNameCell
      id={row.id}
      dataAttr={canEdit ? rowAttribute : undefined}
      name={name}
      secondary={secondary}
    />
  )
  const statusColumn: ColumnDef<TopologyRow> = {
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
    render: (row) => (
      <ActiveBadge
        active={row.status === 'active'}
        activeLabel={t('statusActive')}
        inactiveLabel={t('statusDisabled')}
      />
    ),
  }
  const branchColumn: ColumnDef<TopologyRow> = {
    key: 'branch_id',
    label: t('branch'),
    sortable: true,
    filterable: true,
    default: true,
    filterType: 'enum',
    quickFilter: true,
    filterOptions: branchRows.map((branch) => ({ value: branch.id, label: branch.name })),
    render: (row) => branchName(row.branch_id),
  }
  const columns: ColumnDef<TopologyRow>[] =
    kind === 'branches'
      ? [
          {
            key: 'name',
            label: t('adminName'),
            sortable: true,
            default: true,
            render: (row) => nameCell(row, row.name ?? '', row.code),
          },
          {
            key: 'stock_location_id',
            label: t('stockLocation'),
            sortable: true,
            filterable: true,
            default: true,
            filterType: 'enum',
            filterOptions: locationRows.map((item) => ({ value: item.id, label: item.name })),
            render: (row) => locationName(row.stock_location_id),
          },
          {
            key: 'timezone',
            label: t('timezone'),
            sortable: true,
            default: true,
            className: 'whitespace-nowrap text-muted-foreground',
          },
          {
            key: 'receiving_note',
            label: t('adminReceivingNote'),
            render: (row) => row.receiving_note || '—',
          },
          statusColumn,
        ]
      : kind === 'registers'
        ? [
            {
              key: 'name',
              label: t('adminName'),
              sortable: true,
              default: true,
              render: (row) => nameCell(row, row.name ?? '', row.code),
            },
            branchColumn,
            statusColumn,
          ]
        : [
            {
              key: 'staff_id',
              label: t('adminStaff'),
              sortable: true,
              default: true,
              render: (row) => {
                const user = staffUser(row)
                return user
                  ? nameCell(
                      row,
                      user.full_name || user.email,
                      user.full_name ? user.email : undefined,
                    )
                  : t('adminUnavailable')
              },
            },
            branchColumn,
            {
              key: 'capabilities',
              label: t('membership'),
              default: true,
              className: 'whitespace-normal',
              render: (row) => (
                <div className="flex flex-wrap gap-1">
                  {(row.capabilities ?? []).map((capability) => (
                    <Badge key={capability} variant="outline">
                      {t(
                        posCapabilities.find(([value]) => value === capability)?.[1] ??
                          'adminUnknownPermission',
                      )}
                    </Badge>
                  ))}
                </div>
              ),
            },
            statusColumn,
          ]
  defineTable<TopologyRow>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t(kind === 'memberships' ? 'adminSearchStaff' : 'adminSearchName'),
    defaultSort: { field: kind === 'memberships' ? 'staff_id' : 'name', direction: 'asc' },
    emptyMessage: t('adminNoResults'),
    columns: [...columns, ...hiddenTimestamps<TopologyRow>()],
  })

  return (
    <div className="space-y-6">
      <PageHeader
        title={t(`adminResource_${kind}`)}
        description={t(`adminHint_${kind}`)}
        actions={
          access.read && access.write ? (
            <Button disabled={!ready || mutation.isPending} onClick={() => edit({})}>
              {t(
                kind === 'branches'
                  ? 'createBranch'
                  : kind === 'registers'
                    ? 'createRegister'
                    : 'assignMembership',
              )}
            </Button>
          ) : access.read ? (
            <Badge variant="outline">{t('adminReadAccess')}</Badge>
          ) : undefined
        }
      />
      {context.isPending ? (
        <p role="status">{t('contextWaiting')}</p>
      ) : context.isError ? (
        <div role="alert">
          {describeFailure(context.error, t)}
          <Button onClick={() => void context.refetch()}>{t('retry')}</Button>
        </div>
      ) : !access.read ? (
        <Card>
          <CardHeader>
            <CardTitle>{t('forbidden')}</CardTitle>
          </CardHeader>
          <CardContent>{t('adminAccessDenied')}</CardContent>
        </Card>
      ) : (
        <>
          {notice && (
            <p
              role={notice.failed ? 'alert' : 'status'}
              className={notice.failed ? 'text-destructive' : 'text-muted-foreground'}
            >
              {notice.text}
            </p>
          )}
          {loadError && (
            <div role="alert">
              <p>{describeFailure(loadError, t)}</p>
              <p>{t('adminOptionsError')}</p>
              <Button onClick={() => void Promise.all(dependencies.map((q) => q.refetch()))}>
                {t('retry')}
              </Button>
            </div>
          )}
          <ResourceTable<TopologyRow>
            key={kind}
            tableKey={tableKey}
            hideHeader
            queryKey={['pos', 'topology-table', kind]}
            queryFn={async (params: Record<string, unknown>) => {
              const all = await queryClient.fetchQuery({
                queryKey: posKey(storeId, 'topology', kind),
                queryFn: () => allPages<TopologyRow>(`/pos/${kind}`),
              })
              return localList(all.data, params, {
                searchParam: 'search',
                text: (row) =>
                  kind === 'branches'
                    ? `${row.name} ${row.code}`
                    : kind === 'registers'
                      ? `${row.name} ${row.code} ${branchName(row.branch_id)}`
                      : `${staffName(row)} ${branchName(row.branch_id)}`,
                sortValue: (row, field) =>
                  field === 'branch_id'
                    ? branchName(row.branch_id)
                    : field === 'stock_location_id'
                      ? locationName(row.stock_location_id)
                      : field === 'staff_id'
                        ? staffName(row)
                        : undefined,
              })
            }}
            searchParams={searchParams}
            rowActions={(row) =>
              kind === 'branches' ? (
                <BranchRowActions row={row} actions={rowActions(row)} />
              ) : (
                <RowActions actions={rowActions(row)} />
              )
            }
          />
        </>
      )}
      {editor && access.write && ready && (
        <TopologyEditor
          kind={kind}
          record={editor}
          branches={branchRows}
          staff={staffRows}
          memberships={membershipRows}
          locations={locationRows}
          profiles={(profiles.data?.profiles ?? []).filter(
            (profile) => profile.status === 'available',
          )}
          defaultProfileKey={storeProfile.data?.profile_key ?? 'khac'}
          hideLotSelection={
            kind === 'branches' &&
            Boolean(editor.id) &&
            !branchSettingVisible({ ...context.data, modules: editedModules }, 'lot-selection')
          }
          onSave={save}
          onClose={() => setEditor(null)}
        />
      )}
    </div>
  )
}
