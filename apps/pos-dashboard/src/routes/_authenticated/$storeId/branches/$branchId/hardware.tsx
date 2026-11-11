import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../../lib/route-access'
import { BranchHardwareTab } from '../../../../../pages/branch-hardware'
export const Route = createFileRoute('/_authenticated/$storeId/branches/$branchId/hardware')({
  component: () => (
    <PosRouteGuard page="branch-hardware">
      <BranchHardwareTab />
    </PosRouteGuard>
  ),
})
