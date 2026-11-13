import { PageHeader, usePermissions, useStore } from '@spree/dashboard-core'
import { Navigate, useParams } from '@tanstack/react-router'
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'
import { PageSkeleton } from '../components/page-skeleton'
import { usePosSession } from '../hooks/use-pos-session'
import { BRANCH_TABS, type BranchTab, type PosPage, routeAllowed } from './pos-access'

export function PosRouteGuard({ page, children }: { page: PosPage; children: ReactNode }) {
  const { t } = useTranslation()
  const { permissionKeys, isLoading } = usePermissions()
  const { context } = usePosSession()
  const { branchId } = useParams({ strict: false })
  if (isLoading || context.isPending) return <PageSkeleton variant="page" />
  const access = { permissionKeys, context: context.data }
  if (!routeAllowed(page, access) || (branchId && context.data?.selection.branch_id !== branchId))
    return (
      <div role="alert">
        <PageHeader title={t('adminAccessDeniedTitle')} />
        <p className="text-muted-foreground">{t('adminAccessDenied')}</p>
      </div>
    )
  return children
}

// Earlier store-level URLs of branch settings open that tab of the selected
// branch's page, or the branch list when the store has no branch yet.
export function BranchTabRedirect({ tab }: { tab: BranchTab }) {
  const { storeId } = useStore()
  const { context, selection } = usePosSession()
  if (context.isPending) return <PageSkeleton variant="page" />
  const branchId = selection.branchId
  const path = BRANCH_TABS.find((entry) => entry.key === tab)?.path ?? ''
  return (
    <Navigate
      // The tab paths are concrete strings; the router's typed templates cannot express them.
      to={(branchId ? `/${storeId}/branches/${branchId}${path}` : `/${storeId}/branches`) as string}
      replace
    />
  )
}
