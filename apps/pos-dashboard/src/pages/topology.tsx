import { branchSettingVisible } from '@parkviet/pos-shared/module-registry'
import { posCapabilities } from '@parkviet/pos-shared/pos-capabilities'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import type { PosBranch } from '@parkviet/pos-shared/types/pos-context'
import { PageHeader, useResourceMutation, useStore } from '@spree/dashboard-core'
import {
  Badge,
  Button,
  Card,
  CardContent,
  CardHeader,
  CardTitle,
  useConfirm,
} from '@spree/dashboard-ui'
import { useQueryClient } from '@tanstack/react-query'
import { Link } from '@tanstack/react-router'
import { type ReactNode, useState } from 'react'
import { useTranslation } from 'react-i18next'
import {
  type TopologyDraft,
  TopologyEditor,
  type TopologyKind,
} from '../components/topology-editor'
import { Input, TopologyField, TopologySelect } from '../components/topology-fields'
import { useBranchModules } from '../hooks/use-branch-modules'
import { useBusinessProfiles } from '../hooks/use-business-profiles'
import { useStoreProfile } from '../hooks/use-onboarding'
import { usePosSession } from '../hooks/use-pos-session'
import {
  useBranches,
  useLocationOptions,
  useMemberships,
  useRegisters,
  useStaffOptions,
} from '../hooks/use-topology'
import { posRequest } from '../lib/pos-request'
import { TopologyTable } from '../tables/topology'

function BranchLinks({ branch }: { branch: PosBranch }) {
  const { t } = useTranslation()
  const { storeId } = useStore()
  const { context } = usePosSession()
  const modules = useBranchModules(branch.id)
  return (
    <div className="flex flex-wrap gap-2">
      {[
        ['products', 'branchProductsTitle', 'branchProductsFor'],
        ...(branchSettingVisible({ ...context.data, modules }, 'label-formats')
          ? [['label-formats', 'labelFormatsTitle', 'labelFormatsFor']]
          : []),
        ['features', 'branchFeaturesTitle', 'branchFeaturesFor'],
        ['business-model', 'businessModel.title', 'businessModel.titleFor'],
      ].map(([path, label, aria]) => (
        <Button key={path} variant="outline" size="sm" asChild>
          <Link
            to={`/${storeId}/branches/${branch.id}/${path}` as string}
            aria-label={t(aria, { name: branch.name })}
          >
            {t(label)}
          </Link>
        </Button>
      ))}
    </div>
  )
}

export function TopologyPage({ kind = 'branches' }: { kind?: TopologyKind }) {
  const { t } = useTranslation()
  const { context } = usePosSession()
  const { storeId } = useStore()
  const queryClient = useQueryClient()
  const confirm = useConfirm()
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
  const [search, setSearch] = useState('')
  const [status, setStatus] = useState('all')
  const [branchFilter, setBranchFilter] = useState('')
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const editedModules = useBranchModules(kind === 'branches' ? (editor?.id ?? null) : null)
  const dependencies = [branches, registers, memberships, staff, locations]
  const ready = dependencies.every((query) => query.isSuccess)
  const loadError = dependencies.find((query) => query.isError)?.error
  const branchRows = branches.data?.data ?? []
  const membershipRows = memberships.data?.data ?? []
  const staffRows = [
    ...(staff.data?.data ?? []),
    ...membershipRows.flatMap((m) => (m.staff ? [m.staff] : [])),
  ].filter((user, index, all) => all.findIndex((other) => other.id === user.id) === index)
  const branchName = (id?: string) =>
    branchRows.find((branch) => branch.id === id)?.name ?? t('adminUnavailable')
  const staffName = (id: string) => {
    const user = staffRows.find((item) => item.id === id)
    return user
      ? `${user.full_name ? `${user.full_name} · ` : ''}${user.email}`
      : t('adminUnavailable')
  }
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
  async function changeStatus(
    record: TopologyDraft & { id: string; status: string },
    name: string,
  ) {
    if (mutation.isPending || !access.write) return
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
  const actions = (
    record: TopologyDraft & { id: string; status: string },
    name: string,
    branchId: string,
  ) => (
    <div className="flex flex-wrap gap-2">
      <Button
        size="sm"
        variant="outline"
        disabled={!access.write || !ready || mutation.isPending}
        aria-label={t('adminEditName', { name })}
        onClick={() => {
          setNotice(null)
          setEditor(record)
        }}
      >
        {t('adminEdit')}
      </Button>
      {record.status === 'active' ||
      membershipRows.some(
        (m) =>
          m.branch_id === branchId &&
          m.staff_id === context.data?.staff.id &&
          m.capabilities.includes('pos.topology.recover'),
      ) ? (
        <Button
          size="sm"
          variant={record.status === 'active' ? 'destructive' : 'outline'}
          disabled={!access.write || mutation.isPending}
          onClick={() => void changeStatus(record, name)}
        >
          {t(record.status === 'active' ? 'adminDisable' : 'adminEnable')}
        </Button>
      ) : (
        <span className="text-sm text-muted-foreground">{t('adminRecoveryRequired')}</span>
      )}
    </div>
  )
  function visible(record: { status: string; branch_id?: string }, name: string) {
    return (
      (status === 'all' || status === record.status) &&
      (!branchFilter || kind === 'branches' || record.branch_id === branchFilter) &&
      name.toLocaleLowerCase().includes(search.trim().toLocaleLowerCase())
    )
  }
  let table: ReactNode
  let count = 0
  if (kind === 'branches') {
    const rows = branchRows.filter((item) => visible(item, `${item.name} ${item.code}`))
    count = rows.length
    table = (
      <TopologyTable
        label={t('branchList')}
        rows={rows}
        columns={[
          {
            label: t('adminName'),
            cell: (branch) => (
              <div className="space-y-1">
                <strong>{branch.name}</strong>
                <p>
                  {branch.code} · {branch.timezone}
                </p>
                <p>
                  {locations.data?.data.find((item) => item.id === branch.stock_location_id)
                    ?.name ?? t('adminUnavailable')}
                </p>
                {branch.receiving_note && <p>{branch.receiving_note}</p>}
              </div>
            ),
          },
          {
            label: t('adminStatus'),
            cell: (branch) => (
              <Badge variant="outline">
                {t(branch.status === 'active' ? 'statusActive' : 'statusDisabled')}
              </Badge>
            ),
          },
          {
            label: t('adminEdit'),
            cell: (branch) => (
              <div className="space-y-3">
                {actions(branch, branch.name, branch.id)}
                <BranchLinks branch={branch} />
              </div>
            ),
          },
        ]}
      />
    )
  } else if (kind === 'registers') {
    const rows = (registers.data?.data ?? []).filter((item) =>
      visible(item, `${item.name} ${item.code} ${branchName(item.branch_id)}`),
    )
    count = rows.length
    table = (
      <TopologyTable
        label={t('adminRegisterList')}
        rows={rows}
        columns={[
          {
            label: t('adminName'),
            cell: (row) => (
              <div>
                <strong>{row.name}</strong>
                <p>
                  {row.code} · {branchName(row.branch_id)}
                </p>
              </div>
            ),
          },
          {
            label: t('adminStatus'),
            cell: (row) => t(row.status === 'active' ? 'statusActive' : 'statusDisabled'),
          },
          { label: t('adminEdit'), cell: (row) => actions(row, row.name, row.branch_id) },
        ]}
      />
    )
  } else {
    const rows = membershipRows.filter((item) =>
      visible(item, `${staffName(item.staff_id)} ${branchName(item.branch_id)}`),
    )
    count = rows.length
    table = (
      <TopologyTable
        label={t('staffList')}
        rows={rows}
        columns={[
          {
            label: t('adminStaff'),
            cell: (row) => (
              <div>
                <strong>{staffName(row.staff_id)}</strong>
                <p>{branchName(row.branch_id)}</p>
                <div className="flex flex-wrap gap-1">
                  {row.capabilities.map((capability) => (
                    <Badge key={capability} variant="outline">
                      {t(
                        posCapabilities.find(([value]) => value === capability)?.[1] ??
                          'adminUnknownPermission',
                      )}
                    </Badge>
                  ))}
                </div>
              </div>
            ),
          },
          {
            label: t('adminStatus'),
            cell: (row) => t(row.status === 'active' ? 'statusActive' : 'statusDisabled'),
          },
          {
            label: t('adminEdit'),
            cell: (row) => actions(row, staffName(row.staff_id), row.branch_id),
          },
        ]}
      />
    )
  }
  return (
    <div className="space-y-6">
      <PageHeader
        title={t(`adminResource_${kind}`)}
        description={t(`adminHint_${kind}`)}
        actions={
          access.read && access.write ? (
            <Button
              disabled={!ready || mutation.isPending}
              onClick={() => {
                setNotice(null)
                setEditor({})
              }}
            >
              {t(
                kind === 'branches'
                  ? 'createBranch'
                  : kind === 'registers'
                    ? 'createRegister'
                    : 'assignMembership',
              )}
            </Button>
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
          <Badge variant="outline">
            {t(access.write ? 'adminWriteAccess' : 'adminReadAccess')}
          </Badge>
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
          <Card>
            <CardContent className="space-y-4 pt-6">
              <div className="grid gap-4 sm:grid-cols-3">
                <TopologyField label={t('adminSearch')}>
                  {(id) => (
                    <Input
                      id={id}
                      type="search"
                      value={search}
                      placeholder={t(
                        kind === 'memberships' ? 'adminSearchStaff' : 'adminSearchName',
                      )}
                      onChange={(e) => setSearch(e.target.value)}
                    />
                  )}
                </TopologyField>
                {kind !== 'branches' && (
                  <TopologyField label={t('branch')}>
                    {(id) => (
                      <TopologySelect
                        id={id}
                        value={branchFilter}
                        onChange={setBranchFilter}
                        options={[
                          { value: '', label: t('adminAllBranches') },
                          ...branchRows.map((b) => ({ value: b.id, label: b.name })),
                        ]}
                      />
                    )}
                  </TopologyField>
                )}
                <TopologyField label={t('adminStatus')}>
                  {(id) => (
                    <TopologySelect
                      id={id}
                      value={status}
                      onChange={setStatus}
                      options={['all', 'active', 'disabled'].map((value) => ({
                        value,
                        label: t(
                          value === 'all'
                            ? 'adminAllStatuses'
                            : value === 'active'
                              ? 'statusActive'
                              : 'statusDisabled',
                        ),
                      }))}
                    />
                  )}
                </TopologyField>
              </div>
              {!ready && !loadError && <p role="status">{t('waiting')}</p>}
              {ready && count === 0 && (
                <div>
                  <p>{t('adminNoResults')}</p>
                  <p>{t('adminEmptyHint')}</p>
                </div>
              )}
              {table}
              <p>{t('adminResultCount', { count })}</p>
            </CardContent>
          </Card>
        </>
      )}
      {editor && access.write && ready && (
        <TopologyEditor
          kind={kind}
          record={editor}
          branches={branchRows}
          staff={staffRows}
          memberships={membershipRows}
          locations={locations.data?.data ?? []}
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
