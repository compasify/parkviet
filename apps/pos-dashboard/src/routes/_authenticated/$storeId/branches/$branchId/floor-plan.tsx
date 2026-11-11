import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../../lib/route-access'
import { BranchFloorPlanTab } from '../../../../../pages/branch-floor-plan'
export const Route = createFileRoute('/_authenticated/$storeId/branches/$branchId/floor-plan')({
  component: () => (
    <PosRouteGuard page="branch-floor-plan">
      <BranchFloorPlanTab />
    </PosRouteGuard>
  ),
})
