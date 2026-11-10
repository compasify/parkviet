import { createFileRoute } from '@tanstack/react-router'
import { BranchTabRedirect } from '../../../lib/route-access'
export const Route = createFileRoute('/_authenticated/$storeId/products')({
  component: () => <BranchTabRedirect tab="products" />,
})
