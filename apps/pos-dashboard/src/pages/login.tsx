import { adminClient, useAuth } from '@spree/dashboard-core'
import { Button, Card, CardContent, CardHeader, CardTitle, Input, Label } from '@spree/dashboard-ui'
import { Link, useRouter, useSearch } from '@tanstack/react-router'
import { type FormEvent, useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { safeRedirect } from '../lib/safe-redirect'

export function LoginPage() {
  const { t } = useTranslation()
  const auth = useAuth()
  const router = useRouter()
  // Validated again here: the route already sanitizes it, but this is the
  // last step before the target becomes a navigation.
  const target = safeRedirect(useSearch({ from: '/login' }).redirect) ?? '/'
  const [error, setError] = useState(false)
  // One path for both cases: an already signed-in visit and a fresh sign-in.
  // `href` keeps the remembered search string intact.
  useEffect(() => {
    if (auth.isAuthenticated) void router.navigate({ href: target, replace: true })
  }, [auth.isAuthenticated, router, target])
  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const form = new FormData(event.currentTarget)
    setError(false)
    try {
      await auth.login(String(form.get('email')), String(form.get('password')))
    } catch {
      setError(true)
    }
  }
  if (auth.isAuthenticated) return null
  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <Card className="w-full max-w-sm">
        <CardHeader>
          <CardTitle>{t('posDashboard.title')}</CardTitle>
        </CardHeader>
        <CardContent>
          <form className="space-y-4" onSubmit={submit}>
            <div className="space-y-2">
              <Label htmlFor="email">{t('posDashboard.email')}</Label>
              <Input id="email" name="email" type="email" autoComplete="username" required />
            </div>
            <div className="space-y-2">
              <Label htmlFor="password">{t('posDashboard.password')}</Label>
              <Input
                id="password"
                name="password"
                type="password"
                autoComplete="current-password"
                required
              />
            </div>
            {error && <p role="alert">{t('posDashboard.error')}</p>}
            <Button
              type="submit"
              className="w-full"
              disabled={auth.isLoading || auth.isInitializing}
            >
              {t('posDashboard.signIn')}
            </Button>
            <Button variant="link" asChild>
              <Link to="/forgot-password">{t('posDashboard.forgotPassword')}</Link>
            </Button>
          </form>
        </CardContent>
      </Card>
    </main>
  )
}

export function ForgotPasswordPage() {
  const { t } = useTranslation()
  const [state, setState] = useState<'idle' | 'pending' | 'sent' | 'error'>('idle')
  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault()
    const email = String(new FormData(event.currentTarget).get('email'))
    setState('pending')
    try {
      await adminClient.auth.requestPasswordReset({ email })
      setState('sent')
    } catch {
      setState('error')
    }
  }
  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <Card className="w-full max-w-sm">
        <CardHeader>
          <CardTitle>{t('posDashboard.forgotPassword')}</CardTitle>
        </CardHeader>
        <CardContent>
          <form className="space-y-4" onSubmit={submit}>
            <Label htmlFor="email">{t('posDashboard.email')}</Label>
            <Input id="email" name="email" type="email" autoComplete="email" required />
            <Button type="submit" disabled={state === 'pending'}>
              {t('posDashboard.resetPassword')}
            </Button>
            {state === 'sent' && <p role="status">{t('posDashboard.resetSent')}</p>}
            {state === 'error' && <p role="alert">{t('posDashboard.error')}</p>}
            <Button variant="link" asChild>
              <Link to="/login">{t('posDashboard.backToLogin')}</Link>
            </Button>
          </form>
        </CardContent>
      </Card>
    </main>
  )
}
