import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../../lib/route-access'
import { BranchPlatformsTab } from '../../../../../pages/branch-platforms'
export const Route = createFileRoute('/_authenticated/$storeId/branches/$branchId/platforms')({
  component: () => (
    <PosRouteGuard page="branch-platforms">
      <BranchPlatformsTab />
    </PosRouteGuard>
  ),
})
