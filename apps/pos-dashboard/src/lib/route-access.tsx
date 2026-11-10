import { PageHeader, usePermissions } from '@spree/dashboard-core'
import { useParams } from '@tanstack/react-router'
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'
import { usePosSession } from '../hooks/use-pos-session'
import { type PosPage, routeAllowed } from './pos-access'

export function PosRouteGuard({ page, children }: { page: PosPage; children: ReactNode }) {
  const { t } = useTranslation()
  const { permissionKeys, isLoading } = usePermissions()
  const { context } = usePosSession()
  const { branchId } = useParams({ strict: false })
  if (isLoading || context.isPending) return <p role="status">{t('contextWaiting')}</p>
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
