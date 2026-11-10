import { createFileRoute } from '@tanstack/react-router'
import { PosRouteGuard } from '../../../../../lib/route-access'
import { ReceiptTemplateEditorPage } from '../../../../../pages/receipt-template-editor'
export const Route = createFileRoute(
  '/_authenticated/$storeId/settings/receipt-templates/$templateId',
)({
  component: () => (
    <PosRouteGuard page="receipt-templates">
      <ReceiptTemplateEditorPage />
    </PosRouteGuard>
  ),
})
