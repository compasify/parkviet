import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../../lib/route-access'
import { ReceiptTemplatesPage } from '../../../../../pages/receipt-templates'
export const Route = createFileRoute('/_authenticated/$storeId/settings/receipt-templates/')({
  component: () => (
    <PosRouteGuard page="receipt-templates">
      <ReceiptTemplatesPage />
    </PosRouteGuard>
  ),
})
