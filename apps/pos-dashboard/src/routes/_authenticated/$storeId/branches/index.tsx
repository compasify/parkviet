import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../lib/route-access'
import { BranchesPage } from '../../../../pages/branches'
export const Route = createFileRoute('/_authenticated/$storeId/branches/')({
  component: () => (
    <PosRouteGuard page="branches">
      <BranchesPage />
    </PosRouteGuard>
  ),
})
