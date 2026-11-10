import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../lib/route-access'
import { BranchFeaturesPage } from '../../../pages/branch-features'
export const Route = createFileRoute('/_authenticated/$storeId/features')({
  component: () => (
    <PosRouteGuard page="features">
      <BranchFeaturesPage />
    </PosRouteGuard>
  ),
})
