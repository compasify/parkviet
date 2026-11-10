import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../../lib/route-access'
import { BranchProductsPage } from '../../../../../pages/branch-products'
export const Route = createFileRoute('/_authenticated/$storeId/branches/$branchId/products')({
  component: () => (
    <PosRouteGuard page="products">
      <BranchProductsPage />
    </PosRouteGuard>
  ),
})
