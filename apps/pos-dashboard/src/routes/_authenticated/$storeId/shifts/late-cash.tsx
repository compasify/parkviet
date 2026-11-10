import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../lib/route-access'
import { LateCashPage } from '../../../../pages/late-cash'
export const Route = createFileRoute('/_authenticated/$storeId/shifts/late-cash')({
  component: () => (
    <PosRouteGuard page="late-cash">
      <LateCashPage />
    </PosRouteGuard>
  ),
})
