import { formatDocumentTime, type TemplateData } from '@parkviet/pos-shared/receipt-template/data'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import { Badge, Button, Sheet, SheetContent, SheetHeader, SheetTitle } from '@spree/dashboard-ui'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { type ReceiptTemplate, useReceiptTemplateVersions } from '../../hooks/use-receipt-templates'
import { Notice } from './controls'
import { TemplatePreview } from './template-preview'

export function VersionDrawer({
  template,
  data,
  timeZone,
  busy,
  onRestore,
  onClose,
}: {
  template: ReceiptTemplate
  data: TemplateData
  timeZone: string
  busy: boolean
  onRestore: (version: number) => void
  onClose: () => void
}) {
  const { t } = useTranslation('pos')
  const versions = useReceiptTemplateVersions(template.id, true)
  const [selected, setSelected] = useState<number | null>(null)
  const rows = versions.data?.pages.flatMap((page) => page.data) ?? []
  const shown = rows.find((row) => row.version === selected) ?? rows[0] ?? null
  return (
    <Sheet
      open
      onOpenChange={(open) => {
        if (!open && !busy) onClose()
      }}
    >
      <SheetContent className="data-[side=right]:max-w-4xl" showCloseButton={!busy}>
        <SheetHeader>
          <SheetTitle>{t('receiptTemplates.history.title', { name: template.name })}</SheetTitle>
        </SheetHeader>
        <div className="grid min-h-0 gap-4 overflow-auto p-4 md:grid-cols-[240px_minmax(0,1fr)]">
          {versions.isPending ? <p role="status">{t('waiting')}</p> : null}
          {versions.isError ? <Notice failed text={describeFailure(versions.error, t)} /> : null}
          <div className="grid content-start gap-3">
            <ol className="grid gap-3" aria-label={t('receiptTemplates.history.list')}>
              {rows.map((row) => {
                const current = row.version === template.current_version
                return (
                  <li
                    key={row.version}
                    className="grid gap-2 rounded-lg border p-3 data-[selected=true]:border-primary"
                    data-selected={shown?.version === row.version || undefined}
                  >
                    <Button
                      type="button"
                      variant="ghost"
                      className="h-auto flex-col items-start whitespace-normal text-left"
                      aria-pressed={shown?.version === row.version}
                      onClick={() => setSelected(row.version)}
                    >
                      <strong>
                        {t('receiptTemplates.history.version', { version: row.version })}
                      </strong>
                      <small className="text-muted-foreground">
                        {formatDocumentTime(row.created_at, timeZone)}
                        {row.created_by ? ` · ${row.created_by.name}` : ''}
                      </small>
                      {current ? (
                        <Badge variant="secondary">{t('receiptTemplates.history.current')}</Badge>
                      ) : null}
                    </Button>
                    {!current ? (
                      <Button
                        type="button"
                        variant="outline"
                        disabled={busy}
                        aria-label={t('receiptTemplates.history.restoreVersion', {
                          version: row.version,
                        })}
                        onClick={() => onRestore(row.version)}
                      >
                        {t('receiptTemplates.history.restore')}
                      </Button>
                    ) : null}
                  </li>
                )
              })}
            </ol>
            {versions.hasNextPage ? (
              <Button
                type="button"
                variant="outline"
                disabled={versions.isFetchingNextPage}
                onClick={() => void versions.fetchNextPage()}
              >
                {versions.isFetchingNextPage ? t('waiting') : t('receiptTemplates.history.more')}
              </Button>
            ) : null}
          </div>
          {shown ? (
            <section
              className="min-w-0"
              aria-label={t('receiptTemplates.history.previewOf', { version: shown.version })}
            >
              <TemplatePreview
                config={shown.config}
                data={data}
                paper={template.paper}
                testId="receipt-template-version-preview"
              />
            </section>
          ) : null}
        </div>
      </SheetContent>
    </Sheet>
  )
}
