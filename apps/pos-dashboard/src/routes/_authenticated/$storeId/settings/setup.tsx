import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../lib/route-access'
import { SetupPage } from '../../../../pages/setup'
export const Route = createFileRoute('/_authenticated/$storeId/settings/setup')({
  component: () => (
    <PosRouteGuard page="setup">
      <SetupPage />
    </PosRouteGuard>
  ),
})
