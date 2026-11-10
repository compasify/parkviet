import { resourceSearchSchema } from '@spree/dashboard-core'
import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../lib/route-access'
import { BranchesPage } from '../../../../pages/branches'
export const Route = createFileRoute('/_authenticated/$storeId/branches/')({
  validateSearch: resourceSearchSchema,
  component: () => (
    <PosRouteGuard page="branches">
      <BranchesPage />
    </PosRouteGuard>
  ),
})
