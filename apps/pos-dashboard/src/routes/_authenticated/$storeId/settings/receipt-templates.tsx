import { createFileRoute, Outlet } from '@tanstack/react-router'
export const Route = createFileRoute('/_authenticated/$storeId/settings/receipt-templates')({
  component: Outlet,
})
