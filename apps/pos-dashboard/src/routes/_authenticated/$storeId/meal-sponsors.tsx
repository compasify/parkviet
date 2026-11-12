import { resourceSearchSchema } from '@spree/dashboard-core'
import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../lib/route-access'
import { MealSponsorsPage } from '../../../pages/meal-sponsors'
export const Route = createFileRoute('/_authenticated/$storeId/meal-sponsors')({
  validateSearch: resourceSearchSchema,
  component: () => (
    <PosRouteGuard page="meal-sponsors">
      <MealSponsorsPage />
    </PosRouteGuard>
  ),
})
