import type { LabelFormat } from '@parkviet/pos-shared/label-format'
import { moduleEnabled } from '@parkviet/pos-shared/pos-modules'
import { describeFailure } from '@parkviet/pos-shared/request-failure'
import { useResourceMutation } from '@spree/dashboard-core'
import { Badge, Button, Card, CardContent, useConfirm } from '@spree/dashboard-ui'
import { useQueryClient } from '@tanstack/react-query'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchSettingsFrame, type BranchSettingsScope } from '../components/branch-settings-frame'
import { LabelFormatEditor } from '../components/label-format-editor'
import { disableLabelFormat, useLabelFormats } from '../hooks/use-branch-catalog'
import { TopologyTable } from '../tables/topology'

export function LabelFormatsPage() {
  return (
    <BranchSettingsFrame section="labels">
      {(scope) => <LabelFormats key={scope.branch.id} {...scope} />}
    </BranchSettingsFrame>
  )
}
export function LabelFormats({ branch, access, modules, storeId }: BranchSettingsScope) {
  const { t } = useTranslation()
  const confirm = useConfirm()
  const client = useQueryClient()
  const measuredOn = moduleEnabled(modules, 'retail.measured')
  const canSetUp = access.write && measuredOn
  const formats = useLabelFormats(branch.id, access.read)
  const [editor, setEditor] = useState<{ format?: LabelFormat } | null>(null)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const refresh = () => client.invalidateQueries({ queryKey: ['pos', storeId, 'label-formats'] })
  const mutation = useResourceMutation({
    mutationFn: async (format: LabelFormat) => {
      if (!access.write) throw Object.assign(new Error('Access denied'), { status: 403 })
      return disableLabelFormat(branch.id, format.id)
    },
    successMessage: false,
    errorMessage: false,
  })
  async function disable(format: LabelFormat) {
    if (
      !access.write ||
      mutation.isPending ||
      !(await confirm({
        message: t('labelFormatConfirmDisable', { name: format.name }),
        variant: 'destructive',
        confirmLabel: t('adminDisable'),
        cancelLabel: t('adminCancel'),
      }))
    )
      return
    setNotice(null)
    try {
      await mutation.mutateAsync(format)
      setNotice({ text: t('labelFormatDisabled', { name: format.name }), failed: false })
    } catch (failure) {
      setNotice({ text: describeFailure(failure, t), failed: true })
    } finally {
      await refresh()
    }
  }
  return (
    <Card>
      <CardContent className="space-y-4 pt-6">
        <div className="flex flex-wrap items-center justify-between gap-3">
          <p>{t('labelFormatsHint')}</p>
          {canSetUp && (
            <Button
              disabled={mutation.isPending}
              onClick={() => {
                setNotice(null)
                setEditor({})
              }}
            >
              {t('labelFormatCreate')}
            </Button>
          )}
        </div>
        {!measuredOn && <p role="note">{t('posModules.retail_measured.off')}</p>}
        {!access.write && <p>{t('adminReadAccess')}</p>}
        {notice && (
          <p
            role={notice.failed ? 'alert' : 'status'}
            className={notice.failed ? 'text-destructive' : 'text-muted-foreground'}
          >
            {notice.text}
          </p>
        )}
        {formats.isPending && <p role="status">{t('waiting')}</p>}
        {formats.isError && (
          <div role="alert">
            {describeFailure(formats.error, t)}
            <Button onClick={() => void formats.refetch()}>{t('retry')}</Button>
          </div>
        )}
        {formats.isSuccess && formats.data.length === 0 && (
          <div>
            <p>{t('labelFormatsEmpty')}</p>
            <p>{t('labelFormatsEmptyHint')}</p>
          </div>
        )}
        <TopologyTable
          label={t('labelFormatList')}
          rows={formats.data ?? []}
          busy={formats.isFetching}
          columns={[
            {
              label: t('labelFormatName'),
              cell: (format) => (
                <div>
                  <strong>{format.name}</strong>
                  <p>
                    {t('labelFormatSummary', {
                      prefix: format.prefix,
                      item: format.item_code_length,
                      value: format.value_length,
                    })}
                  </p>
                  <p>
                    {t(`labelFormatKind_${format.kind}`)} ·{' '}
                    {format.kind === 'weight' && format.value_unit_code
                      ? format.value_unit_code
                      : t('labelFormatToleranceShort', { tolerance: format.price_tolerance })}{' '}
                    · {t('labelFormatDecimalsShort', { decimals: format.value_decimals })} ·{' '}
                    {t('labelFormatVersion', { version: format.version })}
                  </p>
                </div>
              ),
            },
            {
              label: t('adminStatus'),
              cell: (format) => (
                <Badge variant="outline">
                  {t(format.status === 'active' ? 'statusActive' : 'statusDisabled')}
                </Badge>
              ),
            },
            {
              label: t('adminEdit'),
              cell: (format) =>
                access.write &&
                format.status === 'active' && (
                  <div className="flex flex-wrap gap-2">
                    {canSetUp && (
                      <Button
                        variant="outline"
                        disabled={mutation.isPending}
                        aria-label={t('adminEditName', { name: format.name })}
                        onClick={() => {
                          setNotice(null)
                          setEditor({ format })
                        }}
                      >
                        {t('adminEdit')}
                      </Button>
                    )}
                    <Button
                      variant="destructive"
                      disabled={mutation.isPending}
                      aria-label={t('labelFormatDisableFor', { name: format.name })}
                      onClick={() => void disable(format)}
                    >
                      {t(
                        mutation.isPending && mutation.variables?.id === format.id
                          ? 'waiting'
                          : 'adminDisable',
                      )}
                    </Button>
                  </div>
                ),
            },
          ]}
        />
        {editor && canSetUp && (
          <LabelFormatEditor
            branchId={branch.id}
            format={editor.format}
            onSaved={async (saved) => {
              setNotice({ text: t('labelFormatSaved', { name: saved.name }), failed: false })
              await refresh()
            }}
            onClose={() => setEditor(null)}
          />
        )}
      </CardContent>
    </Card>
  )
}
