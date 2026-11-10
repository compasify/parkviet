import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../lib/route-access'
import { DeliveriesPage } from '../../../pages/deliveries'
import { deliverySearchSchema } from '../../../schemas/list-search'
export const Route = createFileRoute('/_authenticated/$storeId/deliveries')({
  validateSearch: deliverySearchSchema,
  component: () => (
    <PosRouteGuard page="deliveries">
      <DeliveriesPage />
    </PosRouteGuard>
  ),
})
