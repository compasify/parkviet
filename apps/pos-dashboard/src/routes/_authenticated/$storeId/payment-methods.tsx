import { resourceSearchSchema } from '@spree/dashboard-core'
import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../lib/route-access'
import { PaymentMethodsPage } from '../../../pages/payment-methods'
export const Route = createFileRoute('/_authenticated/$storeId/payment-methods')({
  validateSearch: resourceSearchSchema,
  component: () => (
    <PosRouteGuard page="payment-methods">
      <PaymentMethodsPage />
    </PosRouteGuard>
  ),
})
