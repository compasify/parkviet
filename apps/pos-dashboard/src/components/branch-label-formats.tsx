import { describeFailure, posFailureKey } from '@parkviet/pos-shared/request-failure'
import { Button } from '@spree/dashboard-ui'
import { type FormEvent, useState } from 'react'
import { useTranslation } from 'react-i18next'
import {
  type StoreLabelFormat,
  useBranchLabelFormats,
  useStoreLabelFormats,
  useStoreWrite,
} from '../hooks/use-master-data'
import { ModelCard, ModelCheck, ModelNotice, ModelState } from './setup/model-ui'

// Which of the store's scale label formats a branch reads. Formats are made
// under Settings; here they are only picked. Two active formats of one branch
// never share a prefix, which the server refuses with a 409.
export function BranchLabelFormats({ branchId, write }: { branchId: string; write: boolean }) {
  const { t } = useTranslation()
  const store = useStoreLabelFormats(true)
  const assigned = useBranchLabelFormats(branchId, true)
  if (store.isPending || assigned.isPending)
    return (
      <ModelCard title={t('labelFormatsTitle')} id="branch-label-formats">
        <ModelState title={t('waiting')} />
      </ModelCard>
    )
  const failed = store.error ?? assigned.error
  if (failed || !store.data || !assigned.data)
    return (
      <ModelCard title={t('labelFormatsTitle')} id="branch-label-formats">
        <ModelState
          error
          title={t(posFailureKey(failed))}
          retry={() => void Promise.all([store.refetch(), assigned.refetch()])}
        />
      </ModelCard>
    )
  return (
    <LabelFormatChoice
      branchId={branchId}
      write={write}
      formats={store.data}
      assigned={assigned.data.map((format) => format.id)}
    />
  )
}

function LabelFormatChoice({
  branchId,
  write,
  formats,
  assigned,
}: {
  branchId: string
  write: boolean
  formats: StoreLabelFormat[]
  assigned: string[]
}) {
  const { t } = useTranslation()
  const mutation = useStoreWrite()
  const [chosen, setChosen] = useState(assigned)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  // Disabled formats can still be removed from the branch, never added.
  const rows = formats.filter(
    (format) => format.status === 'active' || assigned.includes(format.id),
  )
  const changed = [...chosen].sort().join() !== [...assigned].sort().join()
  async function save(event: FormEvent) {
    event.preventDefault()
    if (!write || !changed || mutation.isPending) return
    setNotice(null)
    try {
      await mutation.mutateAsync({
        method: 'PUT',
        path: `/pos/branches/${branchId}/label_formats`,
        body: { label_format_ids: chosen },
      })
      setNotice({ text: t('saved'), failed: false })
    } catch (failure) {
      setNotice({ text: describeFailure(failure, t), failed: true })
    }
  }
  return (
    <ModelCard title={t('labelFormatsTitle')} id="branch-label-formats">
      <p className="text-sm text-muted-foreground">{t('branchLabelFormatsIntro')}</p>
      <ModelNotice notice={notice} />
      {rows.length === 0 ? (
        <p>{t('labelFormatsEmpty')}</p>
      ) : (
        <form className="space-y-4" onSubmit={(event) => void save(event)}>
          <fieldset className="space-y-3" aria-label={t('labelFormatsTitle')}>
            {rows.map((format) => (
              <ModelCheck
                key={format.id}
                checked={chosen.includes(format.id)}
                disabled={!write || mutation.isPending}
                onChange={(on) =>
                  setChosen((ids) =>
                    on
                      ? [...ids.filter((id) => id !== format.id), format.id]
                      : ids.filter((id) => id !== format.id),
                  )
                }
                description={[
                  t('labelFormatSummary', {
                    prefix: format.prefix,
                    item: format.item_code_length,
                    value: format.value_length,
                  }),
                  format.status === 'active' ? null : t('statusDisabled'),
                ]
                  .filter(Boolean)
                  .join(' · ')}
              >
                {format.name}
              </ModelCheck>
            ))}
          </fieldset>
          {write && (
            <Button type="submit" disabled={!changed || mutation.isPending}>
              {t(mutation.isPending ? 'waiting' : 'save')}
            </Button>
          )}
        </form>
      )}
    </ModelCard>
  )
}
