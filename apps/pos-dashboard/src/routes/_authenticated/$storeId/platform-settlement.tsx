import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../lib/route-access'
import { PlatformSettlementPage } from '../../../pages/platform-settlement'
export const Route = createFileRoute('/_authenticated/$storeId/platform-settlement')({
  component: () => (
    <PosRouteGuard page="platform-settlement">
      <PlatformSettlementPage />
    </PosRouteGuard>
  ),
})
