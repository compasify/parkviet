import { posFailureKey } from '@parkviet/pos-shared/request-failure'
import { Button } from '@spree/dashboard-ui'
import { type FormEvent, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useBranchScope } from '../components/branch-detail'
import { ModelCard, ModelCheck, ModelNotice, ModelState } from '../components/setup/model-ui'
import {
  type BranchPaymentMethods,
  masterFailure,
  useBranchPaymentMethods,
  useStoreWrite,
} from '../hooks/use-master-data'

// Which of the store's payment methods the branch offers. Without a choice it
// offers every active method, including ones added later.
export function BranchPaymentsTab() {
  const { t } = useTranslation()
  const { branch, access } = useBranchScope()
  const selection = useBranchPaymentMethods(branch.id, access.read)
  return (
    <ModelCard title={t('branchPayments.title')} id="branch-payments">
      <p className="text-sm text-muted-foreground">{t('branchPayments.intro')}</p>
      {selection.isPending ? (
        <ModelState title={t('waiting')} />
      ) : selection.isError ? (
        <ModelState
          error
          title={t(posFailureKey(selection.error))}
          retry={() => void selection.refetch()}
        />
      ) : (
        <PaymentChoice branchId={branch.id} write={access.write} selection={selection.data} />
      )}
    </ModelCard>
  )
}

function PaymentChoice({
  branchId,
  write,
  selection,
}: {
  branchId: string
  write: boolean
  selection: BranchPaymentMethods
}) {
  const { t } = useTranslation()
  const mutation = useStoreWrite()
  const active = selection.payment_methods.filter((method) => method.status === 'active')
  const initial = active.filter((method) => method.enabled).map((method) => method.id)
  const [all, setAll] = useState(!selection.customized)
  const [chosen, setChosen] = useState(initial)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const changed =
    all !== !selection.customized ||
    (!all && [...chosen].sort().join() !== [...initial].sort().join())
  const empty = !all && chosen.length === 0
  async function save(event: FormEvent) {
    event.preventDefault()
    if (!write || !changed || empty || mutation.isPending) return
    setNotice(null)
    try {
      await mutation.mutateAsync({
        method: 'PUT',
        path: `/pos/branches/${branchId}/payment_methods`,
        body: { payment_method_ids: all ? null : chosen },
      })
      setNotice({ text: t('saved'), failed: false })
    } catch (failure) {
      setNotice({ text: masterFailure(failure, t), failed: true })
    }
  }
  return (
    <form className="space-y-4" onSubmit={(event) => void save(event)}>
      <ModelNotice notice={notice} />
      <ModelCheck
        checked={all}
        disabled={!write || mutation.isPending}
        onChange={(on) => {
          setAll(on)
          if (!on && chosen.length === 0) setChosen(active.map((method) => method.id))
        }}
        description={t('branchPayments.allHint')}
      >
        {t('branchPayments.all')}
      </ModelCheck>
      <fieldset className="space-y-3 rounded-md border p-4" aria-label={t('branchPayments.title')}>
        {selection.payment_methods.map((method) => (
          <ModelCheck
            key={method.id}
            checked={method.status === 'active' && (all || chosen.includes(method.id))}
            disabled={!write || all || method.status !== 'active' || mutation.isPending}
            onChange={(on) =>
              setChosen((ids) =>
                on
                  ? [...ids.filter((id) => id !== method.id), method.id]
                  : ids.filter((id) => id !== method.id),
              )
            }
            description={[
              t(`paymentMethods.kind_${method.kind}`),
              method.status === 'active' ? null : t('statusDisabled'),
            ]
              .filter(Boolean)
              .join(' · ')}
          >
            {method.name}
          </ModelCheck>
        ))}
      </fieldset>
      {empty && (
        <p role="alert" className="text-sm text-destructive">
          {t('branchPayments.empty')}
        </p>
      )}
      {write ? (
        <Button type="submit" disabled={!changed || empty || mutation.isPending}>
          {t(mutation.isPending ? 'waiting' : 'save')}
        </Button>
      ) : (
        <p>{t('adminReadAccess')}</p>
      )}
    </form>
  )
}
