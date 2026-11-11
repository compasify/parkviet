import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../lib/route-access'
import { StockAlertsPage } from '../../../pages/stock-alerts'
export const Route = createFileRoute('/_authenticated/$storeId/stock-alerts')({
  component: () => (
    <PosRouteGuard page="stock-alerts">
      <StockAlertsPage />
    </PosRouteGuard>
  ),
})
