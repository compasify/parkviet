import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../lib/route-access'
import { SystemStatusPage } from '../../../../pages/system-status'
export const Route = createFileRoute('/_authenticated/$storeId/settings/system')({
  component: () => (
    <PosRouteGuard page="system">
      <SystemStatusPage />
    </PosRouteGuard>
  ),
})
