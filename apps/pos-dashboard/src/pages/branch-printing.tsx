import type { DocumentType } from '@parkviet/pos-shared/receipt-template/types'
import { posFailureKey } from '@parkviet/pos-shared/request-failure'
import { Button } from '@spree/dashboard-ui'
import { ReceiptTextIcon } from '@spree/dashboard-ui/icons'
import { type FormEvent, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { useBranchScope } from '../components/branch-detail'
import { BranchPrinters } from '../components/branch-printers'
import { ModelCard, ModelNotice, ModelSelect, ModelState } from '../components/setup/model-ui'
import {
  type BranchTemplateAssignment,
  masterFailure,
  useBranchReceiptTemplates,
  useStoreWrite,
} from '../hooks/use-master-data'
import { type ReceiptTemplate, useReceiptTemplates } from '../hooks/use-receipt-templates'

// The branch's printers, and for store administrators its print templates.
export function BranchPrintingTab() {
  const { access } = useBranchScope()
  return (
    <div className="space-y-6">
      <BranchPrinters />
      {access.read ? <BranchTemplates /> : null}
    </div>
  )
}

// The print template the branch uses per document type. A type without a
// choice, or whose chosen template was disabled since, prints with the store
// default.
function BranchTemplates() {
  const { t } = useTranslation()
  const { branch, access } = useBranchScope()
  const assignments = useBranchReceiptTemplates(branch.id, access.read)
  const templates = useReceiptTemplates(access.read)
  const failed = assignments.error ?? templates.error
  return (
    <ModelCard title={t('branchPrinting.title')} id="branch-printing" icon={<ReceiptTextIcon />}>
      <p className="text-sm text-muted-foreground">{t('branchPrinting.intro')}</p>
      {assignments.isPending || templates.isPending ? (
        <ModelState title={t('waiting')} />
      ) : failed || !assignments.data || !templates.data ? (
        <ModelState
          error
          title={t(posFailureKey(failed))}
          retry={() => void Promise.all([assignments.refetch(), templates.refetch()])}
        />
      ) : (
        <TemplateChoice
          branchId={branch.id}
          write={access.write}
          assignments={assignments.data}
          templates={templates.data}
        />
      )}
    </ModelCard>
  )
}

const chosenId = (row: BranchTemplateAssignment) =>
  row.receipt_template?.status === 'active' ? row.receipt_template.id : ''

function TemplateChoice({
  branchId,
  write,
  assignments,
  templates,
}: {
  branchId: string
  write: boolean
  assignments: BranchTemplateAssignment[]
  templates: ReceiptTemplate[]
}) {
  const { t } = useTranslation()
  const mutation = useStoreWrite()
  const [chosen, setChosen] = useState<Partial<Record<DocumentType, string>>>({})
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const value = (row: BranchTemplateAssignment) => chosen[row.document_type] ?? chosenId(row)
  const changes = Object.fromEntries(
    assignments
      .filter((row) => value(row) !== chosenId(row))
      .map((row) => [row.document_type, value(row) || null]),
  )
  const changed = Object.keys(changes).length > 0
  async function save(event: FormEvent) {
    event.preventDefault()
    if (!write || !changed || mutation.isPending) return
    setNotice(null)
    try {
      await mutation.mutateAsync({
        method: 'PUT',
        path: `/pos/branches/${branchId}/receipt_templates`,
        body: { templates: changes },
      })
      setChosen({})
      setNotice({ text: t('saved'), failed: false })
    } catch (failure) {
      setNotice({ text: masterFailure(failure, t), failed: true })
    }
  }
  return (
    <form className="space-y-5" onSubmit={(event) => void save(event)}>
      <ModelNotice notice={notice} />
      <div className="grid gap-5 sm:grid-cols-2">
        {assignments.map((row) => {
          const type = row.document_type
          const storeDefault = templates.find(
            (template) => template.document_type === type && template.is_default,
          )
          const disabledChoice =
            row.receipt_template && row.receipt_template.status !== 'active'
              ? t('branchPrinting.disabledChoice', { name: row.receipt_template.name })
              : undefined
          return (
            <ModelSelect
              key={type}
              label={t(`receiptTemplates.type.${type}`)}
              value={value(row)}
              disabled={!write || mutation.isPending}
              hint={disabledChoice}
              onChange={(next) => setChosen((current) => ({ ...current, [type]: next }))}
              options={[
                {
                  value: '',
                  label: t('branchPrinting.storeDefault', {
                    name: storeDefault?.name ?? row.effective_template?.name ?? '—',
                  }),
                },
                ...templates
                  .filter(
                    (template) => template.document_type === type && template.status === 'active',
                  )
                  .map((template) => ({ value: template.id, label: template.name })),
              ]}
            />
          )
        })}
      </div>
      {write ? (
        <Button type="submit" disabled={!changed || mutation.isPending}>
          {t(mutation.isPending ? 'waiting' : 'save')}
        </Button>
      ) : (
        <p>{t('adminReadAccess')}</p>
      )}
    </form>
  )
}
