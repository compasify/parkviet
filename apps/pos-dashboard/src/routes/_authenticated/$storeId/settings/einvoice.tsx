import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../lib/route-access'
import { EinvoiceSettingsPage } from '../../../../pages/einvoice-settings'
export const Route = createFileRoute('/_authenticated/$storeId/settings/einvoice')({
  component: () => (
    <PosRouteGuard page="einvoice-settings">
      <EinvoiceSettingsPage />
    </PosRouteGuard>
  ),
})
