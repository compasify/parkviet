import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../lib/route-access'
import { VehicleCommissionPage } from '../../../pages/vehicle-commission'
export const Route = createFileRoute('/_authenticated/$storeId/vehicle-commission')({
  component: () => (
    <PosRouteGuard page="vehicle-commission">
      <VehicleCommissionPage />
    </PosRouteGuard>
  ),
})
