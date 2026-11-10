import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../lib/route-access'
import { OrderDetailPage } from '../../../../pages/order-detail'
export const Route = createFileRoute('/_authenticated/$storeId/orders/$orderId')({
  component: OrderRoute,
})
function OrderRoute() {
  const { orderId } = Route.useParams()
  return (
    <PosRouteGuard page="orders">
      <OrderDetailPage key={orderId} orderId={orderId} />
    </PosRouteGuard>
  )
}
