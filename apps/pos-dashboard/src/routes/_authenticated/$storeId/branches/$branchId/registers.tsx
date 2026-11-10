import { resourceSearchSchema } from '@spree/dashboard-core'
import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../../lib/route-access'
import { TopologyPage } from '../../../../../pages/topology'
export const Route = createFileRoute('/_authenticated/$storeId/branches/$branchId/registers')({
  validateSearch: resourceSearchSchema,
  component: () => (
    <PosRouteGuard page="registers">
      <TopologyPage kind="registers" branchId={Route.useParams().branchId} />
    </PosRouteGuard>
  ),
})
