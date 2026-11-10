import { resourceSearchSchema } from '@spree/dashboard-core'
import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../../lib/route-access'
import { BranchProductsPage } from '../../../../../pages/branch-products'
export const Route = createFileRoute('/_authenticated/$storeId/branches/$branchId/products')({
  validateSearch: resourceSearchSchema,
  component: () => (
    <PosRouteGuard page="products">
      <BranchProductsPage />
    </PosRouteGuard>
  ),
})
