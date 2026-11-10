import { PageHeader } from '@spree/dashboard-core'
import { createFileRoute, Navigate } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import { usePosSession } from '../../../hooks/use-pos-session'
export const Route = createFileRoute('/_authenticated/$storeId/')({ component: Overview })
function Overview() {
  const { t } = useTranslation()
  const { context } = usePosSession()
  // Only someone who can run setup is sent there; others keep the overview.
  const onboarding = context.data?.onboarding
  if (context.data && onboarding?.required && onboarding.can_setup)
    return <Navigate to="/$storeId/setup" params={{ storeId: context.data.store.id }} replace />
  return <PageHeader title={t('posDashboard.title')} />
}
