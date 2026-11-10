import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../lib/route-access'
import { ShiftsPage } from '../../../../pages/shifts'
export const Route = createFileRoute('/_authenticated/$storeId/shifts/')({
  component: () => (
    <PosRouteGuard page="shifts">
      <ShiftsPage />
    </PosRouteGuard>
  ),
})
