import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../lib/route-access'
import { DevicesPage } from '../../../pages/devices'
export const Route = createFileRoute('/_authenticated/$storeId/devices')({
  component: () => (
    <PosRouteGuard page="devices">
      <DevicesPage />
    </PosRouteGuard>
  ),
})
