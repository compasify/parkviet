import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../lib/route-access'
import { EinvoicesPage } from '../../../pages/einvoices'
export const Route = createFileRoute('/_authenticated/$storeId/einvoices')({
  component: () => (
    <PosRouteGuard page="einvoices">
      <EinvoicesPage />
    </PosRouteGuard>
  ),
})
