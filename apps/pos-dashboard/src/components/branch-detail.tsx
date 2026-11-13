import { branchSettingVisible } from '@parkviet/pos-shared/module-registry'
import type { PosModules } from '@parkviet/pos-shared/pos-modules'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import type { PosBranch } from '@parkviet/pos-shared/types/pos-context'
import { PageHeader, usePermissions } from '@spree/dashboard-core'
import { ActiveBadge, Button, DropdownMenuItem, useConfirm } from '@spree/dashboard-ui'
import { BanIcon, RotateCcwIcon } from '@spree/dashboard-ui/icons'
import { Outlet, useNavigate, useParams, useSearch } from '@tanstack/react-router'
import { createContext, useContext, useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useBranchModules } from '../hooks/use-branch-modules'
import { useStoreWrite } from '../hooks/use-master-data'
import { usePosSession } from '../hooks/use-pos-session'
import { useSession } from '../hooks/use-session'
import { useBranches, useLocationOptions } from '../hooks/use-topology'
import { branchTabs, canManageBranch, hasCapability } from '../lib/pos-access'
import { BranchFormDialog } from './branch-form-dialog'
import { PillTabs } from './pill-tabs'

export type BranchScope = {
  branch: PosBranch
  // Store administration; branch capabilities never grant it.
  access: { read: boolean; write: boolean }
  // May change this branch's features and modules: store writers, and members
  // holding `pos.topology.manage` here.
  branchWrite: boolean
  storeId: string
  modules: PosModules | null
}
const BranchContext = createContext<BranchScope | null>(null)
export function useBranchScope() {
  const scope = useContext(BranchContext)
  if (!scope) throw new Error('useBranchScope requires the branch page')
  return scope
}

// One branch's page: its header and tabs around the current tab. The session
// selection follows the branch of the URL, so the selected-branch context
// (capabilities, modules, features) is this branch's.
export function BranchDetailLayout() {
  const { t } = useTranslation()
  const { storeId } = useSession()
  const navigate = useNavigate()
  const { permissionKeys } = usePermissions()
  const { context } = usePosSession()
  const { branchId } = useParams({ strict: false }) as { branchId: string }
  const search = useSearch({ strict: false }) as { branch?: string }
  const access = context.data?.administration ?? { read: false, write: false }
  const branches = useBranches(access.read)
  const modules = useBranchModules(branchId)
  const branch =
    branches.data?.data.find((row) => row.id === branchId) ??
    context.data?.branches.find((row) => row.id === branchId)
  // Keep the picked branch for the pages opened next from here.
  useEffect(() => {
    if (search.branch !== branchId)
      void navigate({
        to: '.',
        search: (previous: Record<string, unknown>) => ({
          ...previous,
          branch: branchId,
          register: undefined,
        }),
        replace: true,
      })
  }, [search.branch, branchId, navigate])
  if (!branch)
    return branches.isError ? (
      <div role="alert">
        {describeFailure(branches.error, t)}
        <Button onClick={() => void branches.refetch()}>{t('retry')}</Button>
      </div>
    ) : (
      <p role={branches.isPending && access.read ? 'status' : 'alert'}>
        {t(branches.isPending && access.read ? 'waiting' : 'branchSettingsMissing')}
      </p>
    )
  const posAccess = { permissionKeys, context: context.data }
  const base = `/${storeId}/branches/${branchId}`
  const tabs = branchTabs(posAccess).map((tab) => ({
    key: tab.key,
    label: t(`branchTabs.${tab.key}`),
    to: `${base}${tab.path}`,
  }))
  const scope: BranchScope = {
    branch,
    access,
    branchWrite: canManageBranch(posAccess, branchId),
    storeId,
    modules,
  }
  return (
    <BranchContext.Provider value={scope}>
      <div className="space-y-6">
        <BranchHeader
          scope={scope}
          recoverable={hasCapability(posAccess, 'pos.topology.recover')}
        />
        <PillTabs tabs={tabs} />
        <Outlet />
      </div>
    </BranchContext.Provider>
  )
}

function BranchHeader({ scope, recoverable }: { scope: BranchScope; recoverable: boolean }) {
  const { t } = useTranslation()
  const confirm = useConfirm()
  const { context } = usePosSession()
  const { branch, access, storeId, modules } = scope
  const locations = useLocationOptions(access.write)
  const write = useStoreWrite()
  const [editing, setEditing] = useState(false)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const active = branch.status === 'active'
  async function changeStatus() {
    if (write.isPending) return
    if (
      !(await confirm({
        message: t(active ? 'adminConfirmDisable' : 'adminConfirmEnable', { name: branch.name }),
        variant: active ? 'destructive' : 'default',
        confirmLabel: t(active ? 'adminDisable' : 'adminEnable'),
        cancelLabel: t('adminCancel'),
      }))
    )
      return
    setNotice(null)
    try {
      await write.mutateAsync({
        method: 'POST',
        path: `/pos/branches/${branch.id}/${active ? 'disable' : 'enable'}`,
        body: {},
      })
      setNotice({ text: t('saved'), failed: false })
    } catch (failure) {
      setNotice({ text: describeFailure(failure, t), failed: true })
    }
  }
  return (
    <>
      <PageHeader
        title={branch.name}
        subtitle={branch.code}
        backTo={access.read ? `/${storeId}/branches` : undefined}
        badges={
          <ActiveBadge
            active={active}
            activeLabel={t('statusActive')}
            inactiveLabel={t('statusDisabled')}
          />
        }
        actions={
          access.write ? (
            <Button
              variant="outline"
              disabled={!locations.isSuccess || write.isPending}
              onClick={() => {
                setNotice(null)
                setEditing(true)
              }}
            >
              {t('branchEditInfo')}
            </Button>
          ) : undefined
        }
        destructiveItems={
          access.write ? (
            <DropdownMenuItem
              variant={active ? 'destructive' : 'default'}
              disabled={write.isPending || (!active && !recoverable)}
              onClick={() => void changeStatus()}
            >
              {active ? <BanIcon className="size-4" /> : <RotateCcwIcon className="size-4" />}
              {t(active ? 'adminDisable' : recoverable ? 'adminEnable' : 'adminRecoveryRequired')}
            </DropdownMenuItem>
          ) : undefined
        }
      />
      {notice && (
        <p
          role={notice.failed ? 'alert' : 'status'}
          className={notice.failed ? 'text-destructive' : 'text-muted-foreground'}
        >
          {notice.text}
        </p>
      )}
      {editing && locations.data && (
        <BranchFormDialog
          record={branch}
          branches={[]}
          staff={[]}
          memberships={[]}
          locations={locations.data.data}
          hideLotSelection={!branchSettingVisible({ ...context.data, modules }, 'lot-selection')}
          onSave={async (body) => {
            await write.mutateAsync({ method: 'PATCH', path: `/pos/branches/${branch.id}`, body })
            setNotice({ text: t('saved'), failed: false })
          }}
          onClose={() => setEditing(false)}
        />
      )}
    </>
  )
}
