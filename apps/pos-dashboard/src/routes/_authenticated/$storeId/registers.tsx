import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../lib/route-access'
import { RegistersPage } from '../../../pages/registers'
export const Route = createFileRoute('/_authenticated/$storeId/registers')({
  component: () => (
    <PosRouteGuard page="registers">
      <RegistersPage />
    </PosRouteGuard>
  ),
})
