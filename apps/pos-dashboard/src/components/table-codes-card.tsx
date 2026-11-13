import { describeFailure } from '@parkviet/pos-shared/request-failure'
import { Button, useConfirm } from '@spree/dashboard-ui'
import { HashIcon } from '@spree/dashboard-ui/icons'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { encode } from 'uqr'
import { useFloorPlanWrite, useTableCodes } from '../hooks/use-floor-plan'
import { usePrinters } from '../hooks/use-printers'
import { useBranchScope } from './branch-detail'
import { ModelCard, ModelNotice, ModelSelect, ModelState, modelDate } from './setup/model-ui'

type Issued = { name: string; url: string; printed: boolean }

// The QR drawn locally as SVG; the link never goes to a remote QR service.
function QrImage({ url, label }: { url: string; label: string }) {
  const { size, data } = encode(url, { ecc: 'M', border: 2 })
  const path = data
    .flatMap((row, y) => row.flatMap((dark, x) => (dark ? [`M${x} ${y}h1v1h-1z`] : [])))
    .join('')
  return (
    <svg
      role="img"
      aria-label={label}
      viewBox={`0 0 ${size} ${size}`}
      className="h-48 w-48 bg-white"
      shapeRendering="crispEdges"
    >
      <path d={path} fill="#000" />
    </svg>
  )
}

// The QR stickers of a branch's tables. A new code stops the old sticker and
// every phone that scanned it; the link is shown once, when it is made, and
// can be printed on a receipt printer of the branch.
export function TableCodesCard({ write }: { write: boolean }) {
  const { t, i18n } = useTranslation()
  const { branch } = useBranchScope()
  const codes = useTableCodes(branch.id, true)
  const printers = usePrinters(branch.id)
  const mutation = useFloorPlanWrite()
  const confirm = useConfirm()
  const [printerId, setPrinterId] = useState('')
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const [issued, setIssued] = useState<Issued | null>(null)
  const printerOptions = [
    { value: '', label: t('floorPlan.qrNoPrint') },
    ...(printers.data ?? [])
      .filter((printer) => printer.status === 'active' && printer.command_language === 'escpos')
      .map((printer) => ({ value: printer.id, label: printer.name })),
  ]

  const issue = async (row: { resource_id: string; name: string; table_code: unknown }) => {
    if (
      row.table_code &&
      !(await confirm({
        message: t('floorPlan.qrRotateConfirm', { name: row.name }),
        variant: 'destructive',
        confirmLabel: t('floorPlan.qrRotate'),
        cancelLabel: t('adminCancel'),
      }))
    )
      return
    setNotice(null)
    setIssued(null)
    try {
      const response = (await mutation.mutateAsync({
        method: 'POST',
        path: '/pos/table_codes',
        body: { resource_id: row.resource_id, ...(printerId ? { printer_id: printerId } : {}) },
      })) as { meta?: { url?: unknown; print_job?: unknown } }
      const url = typeof response.meta?.url === 'string' ? response.meta.url : null
      if (url) setIssued({ name: row.name, url, printed: Boolean(response.meta?.print_job) })
      setNotice({ text: t('floorPlan.qrIssued', { name: row.name }), failed: false })
    } catch (failure) {
      setNotice({ text: describeFailure(failure, t), failed: true })
    }
  }

  return (
    <ModelCard title={t('floorPlan.qrTitle')} id="branch-table-codes" icon={<HashIcon />}>
      <p className="text-sm text-muted-foreground">{t('floorPlan.qrIntro')}</p>
      <ModelNotice notice={notice} />
      {issued ? (
        <div className="flex flex-col items-start gap-2 rounded-md border p-4 sm:flex-row sm:items-center">
          <QrImage url={issued.url} label={t('floorPlan.qrImage', { name: issued.name })} />
          <div className="min-w-0 space-y-2 text-sm">
            <p className="font-medium">{issued.name}</p>
            <p className="break-all font-mono text-xs">{issued.url}</p>
            <p className="text-muted-foreground">
              {t(issued.printed ? 'floorPlan.qrPrinted' : 'floorPlan.qrShownOnce')}
            </p>
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() => void navigator.clipboard?.writeText(issued.url)}
            >
              {t('floorPlan.qrCopy')}
            </Button>
          </div>
        </div>
      ) : null}
      {write ? (
        <ModelSelect
          label={t('floorPlan.qrPrinter')}
          value={printerId}
          options={printerOptions}
          hint={t('floorPlan.qrPrinterHint')}
          onChange={setPrinterId}
        />
      ) : null}
      {codes.isPending ? (
        <ModelState title={t('waiting')} />
      ) : codes.error ? (
        <ModelState
          error
          title={describeFailure(codes.error, t)}
          retry={() => void codes.refetch()}
        />
      ) : (codes.data ?? []).length === 0 ? (
        <ModelState title={t('floorPlan.qrNoTables')} />
      ) : (
        <ul className="divide-y rounded-md border">
          {(codes.data ?? []).map((row) => (
            <li key={row.resource_id} className="flex items-center justify-between gap-3 p-3">
              <div className="min-w-0">
                <p className="font-medium">{row.name}</p>
                <p className="text-sm text-muted-foreground">
                  {row.table_code
                    ? t('floorPlan.qrActiveSince', {
                        at: modelDate(row.table_code.rotated_at, i18n.language, branch.timezone),
                      })
                    : t('floorPlan.qrNone')}
                </p>
              </div>
              {write ? (
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  disabled={mutation.isPending}
                  onClick={() => void issue(row)}
                >
                  {t(row.table_code ? 'floorPlan.qrRotate' : 'floorPlan.qrCreate')}
                </Button>
              ) : null}
            </li>
          ))}
        </ul>
      )}
    </ModelCard>
  )
}
