// Shown in the VietQR payment method editor, above its preferences: how many
// receiving accounts it has and where to manage them.
import { Link, useParams } from '@tanstack/react-router'
import { useTranslation } from 'react-i18next'
import { useVietqrReceivingAccounts } from '../hooks/use-vietqr'

interface Props {
  mode: 'create' | 'edit'
  paymentMethod: { id: string } | null
}

export function VietqrPaymentMethodGuide({ mode, paymentMethod }: Props) {
  const { t } = useTranslation()
  const { storeId } = useParams({ strict: false }) as { storeId?: string }
  const { data } = useVietqrReceivingAccounts(mode === 'edit' ? paymentMethod?.id : undefined)
  const active = (data?.data ?? []).filter((account) => account.active).length

  return (
    <div className="rounded-md border bg-muted/30 p-3 text-sm">
      <p>{t('admin.vietqr.guide.intro')}</p>
      {mode === 'create' ? (
        <p className="mt-1 text-muted-foreground">{t('admin.vietqr.guide.after_create')}</p>
      ) : (
        <p className="mt-1">
          {active === 0 ? (
            <span className="text-destructive">{t('admin.vietqr.guide.no_account')}</span>
          ) : (
            <span className="text-muted-foreground">
              {t('admin.vietqr.guide.accounts', { count: active })}
            </span>
          )}{' '}
          <Link to={`/${storeId}/settings/vietqr` as never} className="font-medium underline">
            {t('admin.vietqr.guide.manage')}
          </Link>
        </p>
      )}
    </div>
  )
}
