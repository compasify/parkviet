import { resourceSearchSchema } from '@spree/dashboard-core'
import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../lib/route-access'
import { MealAccountsPage } from '../../../pages/meal-accounts'
export const Route = createFileRoute('/_authenticated/$storeId/meal-accounts')({
  validateSearch: resourceSearchSchema,
  component: () => (
    <PosRouteGuard page="meal-accounts">
      <MealAccountsPage />
    </PosRouteGuard>
  ),
})
