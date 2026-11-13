import { Skeleton } from '@spree/dashboard-ui'
import { useTranslation } from 'react-i18next'

type Variant = 'page' | 'cards' | 'list'

// Placeholder shaped like the content that is about to appear, so a branch or
// store switch keeps the layout steady instead of flashing a sentence.
// Screen readers still hear one short status message.
export function PageSkeleton({ variant = 'list' }: { variant?: Variant }) {
  const { t } = useTranslation()
  return (
    <div role="status" aria-busy="true" data-testid="page-skeleton" className="space-y-6">
      <span className="sr-only">{t('contextWaiting')}</span>
      {variant === 'page' && (
        <div className="space-y-2" aria-hidden>
          <Skeleton className="h-8 w-56" />
          <Skeleton className="h-4 w-96 max-w-full" />
        </div>
      )}
      {variant === 'cards' ? <CardGrid /> : <Rows />}
    </div>
  )
}

function CardGrid() {
  return (
    <div className="grid gap-4 sm:grid-cols-2 xl:grid-cols-3" aria-hidden>
      {[0, 1, 2].map((index) => (
        <div key={index} className="space-y-4 rounded-xl border bg-card p-5">
          <div className="flex items-center gap-3">
            <Skeleton className="size-8 rounded-lg" />
            <Skeleton className="h-5 w-32" />
          </div>
          <Skeleton className="h-4 w-full" />
          <div className="flex items-center justify-between">
            <Skeleton className="h-9 w-14" />
            <Skeleton className="h-8 w-20" />
          </div>
        </div>
      ))}
    </div>
  )
}

function Rows() {
  return (
    <div className="space-y-3 rounded-xl border bg-card p-5" aria-hidden>
      <Skeleton className="h-5 w-40" />
      {[0, 1, 2, 3].map((index) => (
        <div key={index} className="flex items-center gap-4">
          <Skeleton className="h-4 flex-1" />
          <Skeleton className="h-4 w-24" />
        </div>
      ))}
    </div>
  )
}
