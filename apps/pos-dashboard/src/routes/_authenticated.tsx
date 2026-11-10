import { useAuth } from '@spree/dashboard-core'
import { createFileRoute, Navigate, Outlet } from '@tanstack/react-router'
export const Route = createFileRoute('/_authenticated')({ component: AuthenticatedLayout })
function AuthenticatedLayout() {
  const { isInitializing, isAuthenticated } = useAuth()
  if (isInitializing) return null
  return isAuthenticated ? <Outlet /> : <Navigate to="/login" replace />
}
