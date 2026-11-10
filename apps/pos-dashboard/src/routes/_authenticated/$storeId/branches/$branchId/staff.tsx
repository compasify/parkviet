import { resourceSearchSchema } from '@spree/dashboard-core'
import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../../lib/route-access'
import { TopologyPage } from '../../../../../pages/topology'
export const Route = createFileRoute('/_authenticated/$storeId/branches/$branchId/staff')({
  validateSearch: resourceSearchSchema,
  component: () => (
    <PosRouteGuard page="staff">
      <TopologyPage kind="memberships" branchId={Route.useParams().branchId} />
    </PosRouteGuard>
  ),
})
