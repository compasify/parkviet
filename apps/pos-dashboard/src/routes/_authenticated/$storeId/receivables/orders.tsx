import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../lib/route-access'
import { ReceivablesPage } from '../../../../pages/receivables'
import { receivableSearchSchema } from '../../../../schemas/list-search'
export const Route = createFileRoute('/_authenticated/$storeId/receivables/orders')({
  validateSearch: receivableSearchSchema,
  component: () => (
    <PosRouteGuard page="receivables">
      <ReceivablesPage view="orders" />
    </PosRouteGuard>
  ),
})
