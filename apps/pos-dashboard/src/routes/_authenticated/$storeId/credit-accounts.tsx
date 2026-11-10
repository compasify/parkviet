import { resourceSearchSchema } from '@spree/dashboard-core'
import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../lib/route-access'
import { CreditAccountsPage } from '../../../pages/credit-accounts'
export const Route = createFileRoute('/_authenticated/$storeId/credit-accounts')({
  validateSearch: resourceSearchSchema,
  component: () => (
    <PosRouteGuard page="credit-accounts">
      <CreditAccountsPage />
    </PosRouteGuard>
  ),
})
