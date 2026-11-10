import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../../lib/route-access'
import { BusinessModelPage } from '../../../../../pages/business-model'
export const Route = createFileRoute('/_authenticated/$storeId/branches/$branchId/business-model')({
  component: () => (
    <PosRouteGuard page="business-model">
      <BusinessModelPage />
    </PosRouteGuard>
  ),
})
