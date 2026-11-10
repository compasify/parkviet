import { resourceSearchSchema } from '@spree/dashboard-core'
import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../lib/route-access'
import { UnitsPage } from '../../../pages/units'
export const Route = createFileRoute('/_authenticated/$storeId/units')({
  validateSearch: resourceSearchSchema,
  component: () => (
    <PosRouteGuard page="units">
      <UnitsPage />
    </PosRouteGuard>
  ),
})
