import { describeFailure } from '@parkviet/pos-shared/request-failure'
import { Button } from '@spree/dashboard-ui'
import { ShieldAlertIcon } from '@spree/dashboard-ui/icons'
import type { ReactNode } from 'react'
import { useTranslation } from 'react-i18next'
import { usePosSession } from '../hooks/use-pos-session'
import { ModelCard } from './setup/model-ui'

// Body of a store master-data page: waits for the session context, explains
// a refusal, and shows the content only to store administration readers.
export function MasterState({ children }: { children: ReactNode }) {
  const { t } = useTranslation()
  const { context } = usePosSession()
  if (context.isPending) return <p role="status">{t('contextWaiting')}</p>
  if (context.isError)
    return (
      <div role="alert">
        {describeFailure(context.error, t)}
        <Button onClick={() => void context.refetch()}>{t('retry')}</Button>
      </div>
    )
  if (!context.data?.administration?.read)
    return (
      <ModelCard title={t('forbidden')} id="master-forbidden" icon={<ShieldAlertIcon />}>
        <p>{t('adminAccessDenied')}</p>
      </ModelCard>
    )
  return <>{children}</>
}

export function MasterNotice({ notice }: { notice: { text: string; failed: boolean } | null }) {
  return notice ? (
    <p
      role={notice.failed ? 'alert' : 'status'}
      className={notice.failed ? 'text-destructive' : 'text-muted-foreground'}
    >
      {notice.text}
    </p>
  ) : null
}
