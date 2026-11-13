import { branchSettingVisible } from '@parkviet/pos-shared/module-registry'
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
  ResourceNameCell,
  type RowAction,
  RowActions,
  SectionTitle,
  useConfirm,
  useRowClickBridge,
} from '@spree/dashboard-ui'
import {
  BanIcon,
  RotateCcwIcon,
  ShieldAlertIcon,
  TabletIcon,
  UsersIcon,
} from '@spree/dashboard-ui/icons'
import { useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { useCallback, useRef, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { PageSkeleton } from '../components/page-skeleton'
import { ModelCard } from '../components/setup/model-ui'
import {
  type TopologyDraft,
  TopologyEditor,
  type TopologyKind,
} from '../components/topology-editor'
import { useBranchModules } from '../hooks/use-branch-modules'
import { useBusinessProfiles } from '../hooks/use-business-profiles'
import { useStaffRoles } from '../hooks/use-master-data'
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
import { capabilityLabel } from '../lib/capability-groups'
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
  custom_capabilities?: string[]
  staff_role?: { id: string; name: string } | null
}

// The store's branches, or (with `branchId`) the registers or staff of one
// branch embedded in that branch's page, where the branch is fixed.
export function TopologyPage({
  kind = 'branches',
  branchId,
}: {
  kind?: TopologyKind
  branchId?: string
}) {
  const { t } = useTranslation()
  const { context } = usePosSession()
  const { storeId } = useSession()
  const navigate = useNavigate()
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
  const roles = useStaffRoles(access.read && kind === 'memberships')
  const [editor, setEditor] = useState<TopologyDraft | null>(null)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const editedModules = useBranchModules(kind === 'branches' ? (editor?.id ?? null) : null)
  const dependencies = [
    branches,
    registers,
    memberships,
    staff,
    locations,
    ...(kind === 'memberships' ? [roles] : []),
  ]
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
  // A membership opens with its own capability list and its role; the role's
  // grants show read-only while it has one.
  const draftOf = (record: TopologyRow): TopologyDraft =>
    kind === 'memberships'
      ? {
          ...record,
          capabilities: record.custom_capabilities ?? record.capabilities,
          effective_capabilities: record.capabilities,
          staff_role_id: record.staff_role?.id ?? null,
          staff_role_name: record.staff_role?.name ?? null,
        }
      : record
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
        onSelect: () => edit(draftOf(record)),
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

  const tableKey = `pos-${kind}${branchId ? '-branch' : ''}`
  const rowAttribute = `data-pos-${kind}-id` as const
  const records = (): TopologyRow[] =>
    ((kind === 'branches'
      ? branchRows
      : kind === 'registers'
        ? registers.data?.data
        : membershipRows) ?? []) as TopologyRow[]
  // A branch row opens the branch's page; other rows open their editor.
  const openRecord = useRef<(id: string) => void>(() => {})
  openRecord.current = (id) => {
    if (kind === 'branches') {
      void navigate({
        to: '/$storeId/branches/$branchId',
        params: { storeId, branchId: id },
        search: (previous: Record<string, unknown>) => ({
          ...previous,
          branch: id,
          register: undefined,
        }),
      })
      return
    }
    const record = records().find((row) => row.id === id)
    if (record && canEdit) edit(draftOf(record))
  }
  const openRow = useCallback((id: string) => openRecord.current(id), [])
  useRowClickBridge(rowAttribute, openRow)
  const nameCell = (row: TopologyRow, name: string, secondary?: string) => (
    <ResourceNameCell
      id={row.id}
      dataAttr={kind === 'branches' || canEdit ? rowAttribute : undefined}
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
            {
              key: 'kind',
              label: t('adminRegisterKind'),
              default: true,
              render: (row) => t(`adminRegisterKind_${row.kind === 'kiosk' ? 'kiosk' : 'counter'}`),
            },
            ...(branchId ? [] : [branchColumn]),
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
            ...(branchId ? [] : [branchColumn]),
            {
              key: 'staff_role',
              label: t('staffRoles.field'),
              default: true,
              render: (row) => row.staff_role?.name ?? t('staffRoles.custom'),
            },
            {
              key: 'capabilities',
              label: t('membership'),
              default: true,
              className: 'whitespace-normal',
              render: (row) => (
                <div className="flex flex-wrap gap-1">
                  {(row.capabilities ?? []).map((capability) => (
                    <Badge key={capability} variant="outline">
                      {t(capabilityLabel(capability))}
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

  const headerActions =
    access.read && access.write ? (
      <Button
        disabled={!ready || mutation.isPending}
        onClick={() => edit(branchId ? { branch_id: branchId } : {})}
      >
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
  return (
    <div className="space-y-6">
      {branchId ? (
        <div className="flex flex-col gap-3">
          <div className="flex flex-wrap items-center justify-between gap-3">
            <SectionTitle>
              {kind === 'registers' ? <TabletIcon /> : <UsersIcon />}
              {t(`adminResource_${kind}`)}
            </SectionTitle>
            {headerActions}
          </div>
          <p className="text-base text-muted-foreground">{t(`adminHint_${kind}`)}</p>
        </div>
      ) : (
        <PageHeader
          title={t(`adminResource_${kind}`)}
          description={t(`adminHint_${kind}`)}
          actions={headerActions}
        />
      )}
      {context.isPending ? (
        <PageSkeleton />
      ) : context.isError ? (
        <div role="alert">
          {describeFailure(context.error, t)}
          <Button onClick={() => void context.refetch()}>{t('retry')}</Button>
        </div>
      ) : !access.read ? (
        <ModelCard title={t('forbidden')} id="topology-forbidden" icon={<ShieldAlertIcon />}>
          <p>{t('adminAccessDenied')}</p>
        </ModelCard>
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
            queryKey={['pos', 'topology-table', kind, branchId ?? 'all']}
            queryFn={async (params: Record<string, unknown>) => {
              const all = await queryClient.fetchQuery({
                queryKey: posKey(storeId, 'topology', kind),
                queryFn: () => allPages<TopologyRow>(`/pos/${kind}`),
              })
              const rows = branchId
                ? all.data.filter((row) => row.branch_id === branchId)
                : all.data
              return localList(rows, params, {
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
            rowActions={(row) => <RowActions actions={rowActions(row)} />}
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
          lockBranch={Boolean(branchId)}
          roles={(roles.data ?? []).filter((role) => role.status === 'active')}
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
