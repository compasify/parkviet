import { resourceSearchSchema } from '@spree/dashboard-core'
import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../lib/route-access'
import { StaffPage } from '../../../pages/staff'
export const Route = createFileRoute('/_authenticated/$storeId/staff')({
  validateSearch: resourceSearchSchema,
  component: () => (
    <PosRouteGuard page="staff">
      <StaffPage />
    </PosRouteGuard>
  ),
})
