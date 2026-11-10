import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../../lib/route-access'
import { BranchPrintingTab } from '../../../../../pages/branch-printing'
export const Route = createFileRoute('/_authenticated/$storeId/branches/$branchId/printing')({
  component: () => (
    <PosRouteGuard page="branch-printing">
      <BranchPrintingTab />
    </PosRouteGuard>
  ),
})
