import receiptCss from '@parkviet/pos-shared/receipt.css?inline'
import { snapshotData, type TemplateData } from '@parkviet/pos-shared/receipt-template/data'
import { renderDocument } from '@parkviet/pos-shared/receipt-template/render'
import { sampleData, withLogo } from '@parkviet/pos-shared/receipt-template/sample-data'
import type {
  DocumentType,
  PaperSize,
  PrintDocument,
  TemplateConfig,
} from '@parkviet/pos-shared/receipt-template/types'
import type { PosBranch, PosContext, PosRegister } from '@parkviet/pos-shared/types/pos-context'
import { useEffect, useMemo, useRef, useState } from 'react'
import { createPortal } from 'react-dom'
import { useTranslation } from 'react-i18next'
import { useLatestReceipt } from '../../hooks/use-receipt-templates'
import { Choice } from './controls'
import { PrintSheet } from './print-sheet'

export type PreviewSource = 'sample' | 'latest'
const RECEIPT_SOURCES = {
  sale: 'sale',
  return: 'return',
  refund: 'refund',
  shift_closure: 'shift_closure',
} as const
export type PreviewStatus = 'sample' | 'loading' | 'latest' | 'empty' | 'failed'

export function usePreviewData({
  documentType,
  source,
  context,
  branch,
  register,
}: {
  documentType: DocumentType
  source: PreviewSource
  context: PosContext | undefined
  branch: PosBranch | null
  register: PosRegister | null
}): { data: TemplateData; status: PreviewStatus } {
  const { t } = useTranslation('pos')
  const sourceType = RECEIPT_SOURCES[documentType as keyof typeof RECEIPT_SOURCES] ?? null
  const wantsLatest = source === 'latest' && sourceType !== null && branch !== null
  const latest = useLatestReceipt(branch?.id ?? null, sourceType, wantsLatest)
  const place = useMemo(
    () => ({
      storeName: context?.store.name ?? null,
      storeProfile: context?.store.profile ?? null,
      branchName: branch?.name ?? null,
      branchCode: branch?.code ?? null,
      returnWindowDays: branch?.return_window_days ?? null,
      registerName: register?.name ?? null,
      cashier: context?.staff.full_name || context?.staff.email || null,
      timeZone: branch?.timezone ?? context?.store.timezone ?? null,
    }),
    [context, branch, register],
  )
  const now = useMemo(() => new Date(), [])
  return useMemo(() => {
    if (wantsLatest && latest.data)
      return { data: withLogo(snapshotData(latest.data, t), place), status: 'latest' }
    const status: PreviewStatus = !wantsLatest
      ? 'sample'
      : latest.isPending
        ? 'loading'
        : latest.isError
          ? 'failed'
          : 'empty'
    return { data: sampleData(documentType, place, t, now), status }
  }, [wantsLatest, latest.data, latest.isPending, latest.isError, documentType, place, t, now])
}

export function PreviewControls({
  documentType,
  source,
  status,
  branches,
  canReadReceipts,
  registers,
  branchId,
  registerId,
  onSource,
  onBranch,
  onRegister,
}: {
  documentType: DocumentType
  source: PreviewSource
  status: PreviewStatus
  branches: PosBranch[]
  canReadReceipts: boolean
  registers: PosRegister[]
  branchId: string
  registerId: string
  onSource: (source: PreviewSource) => void
  onBranch: (id: string) => void
  onRegister: (id: string) => void
}) {
  const { t } = useTranslation('pos')
  const hasReceipts = documentType in RECEIPT_SOURCES
  return (
    <div className="grid gap-3">
      <Choice
        label={t('receiptTemplates.preview.source')}
        value={source}
        options={[
          { value: 'sample', label: t('receiptTemplates.preview.sample') },
          {
            value: 'latest',
            label: t('receiptTemplates.preview.latest'),
            disabled: !hasReceipts || !canReadReceipts,
          },
        ]}
        onChange={onSource}
      />
      <Choice
        label={t('branch')}
        value={branchId}
        options={
          branches.length
            ? branches.map((branch) => ({ value: branch.id, label: branch.name }))
            : [{ value: '', label: t('receiptTemplates.preview.noBranch') }]
        }
        onChange={onBranch}
      />
      <Choice
        label={t('receiptTemplates.preview.register')}
        value={registerId}
        disabled={source === 'latest' && hasReceipts}
        options={[
          { value: '', label: t('receiptTemplates.preview.noRegister') },
          ...registers
            .filter((register) => register.branch_id === branchId)
            .map((register) => ({ value: register.id, label: register.name })),
        ]}
        onChange={onRegister}
      />
      {!hasReceipts ? (
        <small className="text-muted-foreground">{t('receiptTemplates.preview.sampleOnly')}</small>
      ) : !canReadReceipts ? (
        <small className="text-muted-foreground">
          {t('receiptTemplates.preview.noMembership')}
        </small>
      ) : source === 'latest' ? (
        <small className="text-muted-foreground">
          {t('receiptTemplates.preview.memberBranches')}
        </small>
      ) : null}
      {status === 'loading' ? (
        <small role="status">{t('waiting')}</small>
      ) : status === 'empty' ? (
        <small role="status">{t('receiptTemplates.preview.noReceipt')}</small>
      ) : status === 'failed' ? (
        <small role="status">{t('receiptTemplates.preview.receiptFailed')}</small>
      ) : null}
    </div>
  )
}

const FRAME_HTML = '<!doctype html><html><head><meta charset="utf-8"></head><body></body></html>'
const PAPER_WIDTH: Record<PaperSize, string> = {
  '58mm': '58mm',
  '80mm': '80mm',
  a4: '210mm',
  a5: '148mm',
  a6: '105mm',
}

// React portals keep text escaped. No template HTML or scripts are interpolated
// into srcDoc, and neither dashboard CSS nor receipt CSS crosses the frame.
export function ReceiptFrame({
  document: printDocument,
  paper,
  title,
  testId,
  markOverflow = false,
  onReady,
}: {
  document: PrintDocument
  paper: PaperSize
  title: string
  testId: string
  markOverflow?: boolean
  onReady?: (frame: HTMLIFrameElement) => void
}) {
  const ref = useRef<HTMLIFrameElement>(null)
  const [body, setBody] = useState<HTMLElement | null>(null)
  const [height, setHeight] = useState(400)
  useEffect(() => {
    if (!body) return
    const measure = () => setHeight(Math.max(200, body.scrollHeight + 24))
    const observer = new ResizeObserver(measure)
    observer.observe(body)
    measure()
    return () => observer.disconnect()
  }, [body])
  useEffect(() => {
    if (!body || !ref.current || !onReady) return
    const frame = ref.current
    let disposed = false
    const ready = async () => {
      let timer: ReturnType<typeof setTimeout> | undefined
      const assets = Promise.all([
        frame.contentDocument?.fonts.ready,
        ...Array.from(body.querySelectorAll('img')).map((image) =>
          image.decode().catch(() => {
            image.hidden = true
          }),
        ),
      ])
      await Promise.race([
        assets,
        new Promise<void>((resolve) => {
          timer = setTimeout(resolve, 1500)
        }),
      ])
      clearTimeout(timer)
      for (const image of body.querySelectorAll('img'))
        if (!image.complete || image.naturalWidth === 0) image.hidden = true
      if (!disposed) onReady(frame)
    }
    void ready()
    return () => {
      disposed = true
    }
  }, [body, onReady])
  return (
    <div className="max-w-full overflow-auto rounded-lg border bg-muted/40 p-3">
      <iframe
        ref={ref}
        title={title}
        data-testid={`${testId}-frame`}
        srcDoc={FRAME_HTML}
        sandbox="allow-same-origin allow-modals"
        className="mx-auto block border-0 bg-white"
        style={{ width: PAPER_WIDTH[paper], height }}
        onLoad={(event) => {
          const doc = event.currentTarget.contentDocument
          if (!doc) return
          doc.title = title
          doc.documentElement.setAttribute('data-receipt-printing', paper)
          const style = doc.createElement('style')
          style.textContent = `${receiptCss}\nhtml,body{margin:0;padding:0;background:white;color:black}body{width:${PAPER_WIDTH[paper]}}@page{size:${paper === '58mm' || paper === '80mm' ? `${paper} 297mm` : paper};margin:${printDocument.page.margin_mm}mm} @media print{html,body{width:auto}.receipt-sheet{box-shadow:none!important;margin:0!important}}`
          doc.head.append(style)
          setBody(doc.body)
        }}
      />
      {body
        ? createPortal(
            <div className="receipt-print-root">
              <PrintSheet
                document={printDocument}
                paper={paper}
                testId={testId}
                markOverflow={markOverflow}
              />
            </div>,
            body,
          )
        : null}
    </div>
  )
}

export function TemplatePreview({
  config,
  data,
  paper,
  testId = 'receipt-template-preview',
  markOverflow = false,
}: {
  config: TemplateConfig
  data: TemplateData
  paper: PaperSize
  testId?: string
  markOverflow?: boolean
}) {
  const { t } = useTranslation('pos')
  const document = useMemo(() => renderDocument(config, data), [config, data])
  // Recreate only when paper or margin changes; content stays live via portal.
  return (
    <ReceiptFrame
      key={`${paper}-${config.page.margin_mm}`}
      document={document}
      paper={paper}
      title={t('receiptTemplates.preview.title')}
      testId={testId}
      markOverflow={markOverflow}
    />
  )
}
