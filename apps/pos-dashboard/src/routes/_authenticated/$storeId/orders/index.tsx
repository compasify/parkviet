import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../lib/route-access'
import { OrdersPage } from '../../../../pages/orders'
import { orderSearchSchema } from '../../../../schemas/list-search'
export const Route = createFileRoute('/_authenticated/$storeId/orders/')({
  validateSearch: orderSearchSchema,
  component: () => (
    <PosRouteGuard page="orders">
      <OrdersPage />
    </PosRouteGuard>
  ),
})
