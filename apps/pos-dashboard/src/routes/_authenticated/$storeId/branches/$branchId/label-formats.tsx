import { resourceSearchSchema } from '@spree/dashboard-core'
import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../../lib/route-access'
import { LabelFormatsPage } from '../../../../../pages/label-formats'
export const Route = createFileRoute('/_authenticated/$storeId/branches/$branchId/label-formats')({
  validateSearch: resourceSearchSchema,
  component: () => (
    <PosRouteGuard page="labels">
      <LabelFormatsPage />
    </PosRouteGuard>
  ),
})
