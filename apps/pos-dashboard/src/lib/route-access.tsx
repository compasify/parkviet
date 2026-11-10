import { PageHeader, usePermissions } from '@spree/dashboard-core'
import { useParams } from '@tanstack/react-router'
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'
import { usePosSession } from '../hooks/use-pos-session'
import { canAdminister, type PosPage, visibleNav } from './pos-access'

export function PosRouteGuard({ page, children }: { page: PosPage; children: ReactNode }) {
  const { t } = useTranslation()
  const { permissionKeys, isLoading } = usePermissions()
  const { context } = usePosSession()
  const { branchId } = useParams({ strict: false })
  if (isLoading || context.isPending) return <p role="status">{t('contextWaiting')}</p>
  const access = { permissionKeys, context: context.data }
  // Setup is reachable by readers: the page shows ask-admin guidance instead
  // of a wizard. Nav keeps it write-only. Labels stay reachable when the
  // branch's measured-goods module is off, so existing formats can be seen.
  const allowed =
    page === 'setup' || page === 'labels' ? canAdminister(access) : visibleNav(page, access)
  if (!allowed || (branchId && context.data?.selection.branch_id !== branchId))
    return (
      <div role="alert">
        <PageHeader title={t('adminAccessDeniedTitle')} />
        <p className="text-muted-foreground">{t('adminAccessDenied')}</p>
      </div>
    )
  return children
}
