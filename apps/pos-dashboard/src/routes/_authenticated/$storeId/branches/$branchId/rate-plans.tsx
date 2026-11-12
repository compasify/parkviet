import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../../lib/route-access'
import { BranchRatePlansTab } from '../../../../../pages/branch-rate-plans'
export const Route = createFileRoute('/_authenticated/$storeId/branches/$branchId/rate-plans')({
  component: () => (
    <PosRouteGuard page="branch-rate-plans">
      <BranchRatePlansTab />
    </PosRouteGuard>
  ),
})
