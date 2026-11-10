import { resourceSearchSchema } from '@spree/dashboard-core'
import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../lib/route-access'
import { StaffRolesPage } from '../../../pages/staff-roles'
export const Route = createFileRoute('/_authenticated/$storeId/staff-roles')({
  validateSearch: resourceSearchSchema,
  component: () => (
    <PosRouteGuard page="staff-roles">
      <StaffRolesPage />
    </PosRouteGuard>
  ),
})
