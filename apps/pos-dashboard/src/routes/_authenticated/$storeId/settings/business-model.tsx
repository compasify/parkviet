import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../lib/route-access'
import { StoreBusinessModelPage } from '../../../../pages/business-model'
export const Route = createFileRoute('/_authenticated/$storeId/settings/business-model')({
  component: () => (
    <PosRouteGuard page="store-model">
      <StoreBusinessModelPage />
    </PosRouteGuard>
  ),
})
