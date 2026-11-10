import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../../lib/route-access'
import { BranchPaymentsTab } from '../../../../../pages/branch-payments'
export const Route = createFileRoute('/_authenticated/$storeId/branches/$branchId/payments')({
  component: () => (
    <PosRouteGuard page="branch-payments">
      <BranchPaymentsTab />
    </PosRouteGuard>
  ),
})
