import { Toaster } from '@spree/dashboard-ui'
import { createRootRoute, Outlet } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'

function NotFound() {
  const { t } = useTranslation()
  return <p role="alert">{t('posDashboard.notFound')}</p>
}
function ErrorPage() {
  const { t } = useTranslation()
  return <p role="alert">{t('posDashboard.error')}</p>
}
export const Route = createRootRoute({
  component: () => (
    <>
      <Outlet />
      <Toaster />
    </>
  ),
  notFoundComponent: NotFound,
  errorComponent: ErrorPage,
})
