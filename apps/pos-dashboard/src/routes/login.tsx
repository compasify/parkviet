import { createFileRoute } from '@tanstack/react-router'
import { safeRedirect } from '../lib/safe-redirect'
import { LoginPage } from '../pages/login'

type LoginSearch = { redirect?: string }

export const Route = createFileRoute('/login')({
  validateSearch: (search: Record<string, unknown>): LoginSearch => ({
    redirect: safeRedirect(search.redirect) ?? undefined,
  }),
  component: LoginPage,
})
