import { useAuth } from '@spree/dashboard-core'
import { createFileRoute, Outlet, useRouter, useRouterState } from '@tanstack/react-router'
import { useEffect } from 'react'
import { loginRedirect } from '../lib/safe-redirect'
export const Route = createFileRoute('/_authenticated')({ component: AuthenticatedLayout })
function AuthenticatedLayout() {
  const { isInitializing, isAuthenticated } = useAuth()
  const router = useRouter()
  const href = useRouterState({ select: (state) => state.location.href })
  const signedOut = !isInitializing && !isAuthenticated
  // Remember the page (path + search) so sign-in returns there, whether the
  // session expired or a protected URL was opened while signed out.
  // The layout can still be mounted while the router moves to /login, so the
  // sign-in URL itself must not trigger a second navigation that drops it.
  useEffect(() => {
    if (signedOut && !href.startsWith('/login'))
      void router.navigate({
        to: '/login',
        search: { redirect: loginRedirect(href) },
        replace: true,
      })
  }, [signedOut, router, href])
  return isAuthenticated ? <Outlet /> : null
}
