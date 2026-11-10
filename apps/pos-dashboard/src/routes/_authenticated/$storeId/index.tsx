import { createFileRoute, Navigate } from '@tanstack/react-router'
import { usePosSession } from '../../../hooks/use-pos-session'
import { HomePage } from '../../../pages/home'
export const Route = createFileRoute('/_authenticated/$storeId/')({ component: Overview })
function Overview() {
  const { context } = usePosSession()
  // Only someone who can run setup is sent there; others keep the overview.
  const onboarding = context.data?.onboarding
  if (context.data && onboarding?.required && onboarding.can_setup)
    return <Navigate to="/$storeId/setup" params={{ storeId: context.data.store.id }} replace />
  return <HomePage />
}
