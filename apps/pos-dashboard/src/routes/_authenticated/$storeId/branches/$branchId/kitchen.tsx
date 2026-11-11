import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../../lib/route-access'
import { BranchKitchenTab } from '../../../../../pages/branch-kitchen'
export const Route = createFileRoute('/_authenticated/$storeId/branches/$branchId/kitchen')({
  component: () => (
    <PosRouteGuard page="branch-kitchen">
      <BranchKitchenTab />
    </PosRouteGuard>
  ),
})
