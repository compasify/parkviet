import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../../lib/route-access'
import { BranchOverviewTab } from '../../../../../pages/branch-overview'
export const Route = createFileRoute('/_authenticated/$storeId/branches/$branchId/')({
  component: () => (
    <PosRouteGuard page="branch">
      <BranchOverviewTab />
    </PosRouteGuard>
  ),
})
