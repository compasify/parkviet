import { createFileRoute, Outlet } from '@tanstack/react-router'
export const Route = createFileRoute('/_authenticated/$storeId/receivables')({ component: Outlet })
