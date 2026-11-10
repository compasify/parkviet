import { createFileRoute } from '@tanstack/react-router'
import { BranchDetailLayout } from '../../../../components/branch-detail'
import { PosRouteGuard } from '../../../../lib/route-access'
export const Route = createFileRoute('/_authenticated/$storeId/branches/$branchId')({
  component: () => (
    <PosRouteGuard page="branch">
      <BranchDetailLayout />
    </PosRouteGuard>
  ),
})
