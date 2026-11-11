import { formatMoney } from '@parkviet/pos-shared/money'
import { PageHeader, usePermissions } from '@spree/dashboard-core'
import { Badge, Button, Card, CardContent, Textarea, useConfirm } from '@spree/dashboard-ui'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { BranchPicker } from '../components/branch-picker'
import { Input, TopologyField, TopologySelect } from '../components/topology-fields'
import {
  type Einvoice,
  type EinvoiceBuyer,
  useCancelEinvoice,
  useEinvoiceSummary,
  useEinvoices,
  useReplaceEinvoice,
  useRetryEinvoices,
  useUpdateEinvoiceBuyer,
} from '../hooks/use-einvoices'
import { usePosSession } from '../hooks/use-pos-session'
import { einvoiceFailure } from '../lib/einvoice-failure'
import { canManageEinvoices, type PosAccess } from '../lib/pos-access'

type Notice = { text: string; failed: boolean } | null
type Editor = { einvoice: Einvoice; mode: 'buyer' | 'replace' | 'cancel' } | null

const STATUS_FILTERS = ['outstanding', 'failed', 'issued', 'canceled', 'replaced', ''] as const
const BUYER_FIELDS = [
  'tax_code',
  'name',
  'address',
  'email',
  'phone',
  'personal_id',
  'passport_no',
  'nationality',
  'buyer_note',
] as const
type BuyerField = (typeof BUYER_FIELDS)[number]

const STATUS_VARIANT: Record<string, 'default' | 'secondary' | 'destructive' | 'outline'> = {
  issued: 'default',
  failed: 'destructive',
  pending: 'secondary',
  issuing: 'secondary',
}

function buyerForm(buyer: EinvoiceBuyer): Record<BuyerField, string> {
  return Object.fromEntries(BUYER_FIELDS.map((key) => [key, buyer[key] ?? ''])) as Record<
    BuyerField,
    string
  >
}

function compact(form: Record<BuyerField, string>): EinvoiceBuyer {
  return Object.fromEntries(
    Object.entries(form)
      .map(([key, value]) => [key, value.trim()])
      .filter(([, value]) => value !== ''),
  )
}

// "Hóa đơn điện tử": invoices of the selected branch's completed sales. The
// default view lists the ones not issued yet (waiting, being issued, failed).
// Managers retry, fill in buyer details before issue, cancel one never sent,
// or request a replacement for an issued one. The summary shows the year's
// turnover against the 1 billion VND mark.
export function EinvoicesPage() {
  const { t } = useTranslation()
  const confirm = useConfirm()
  const { context, selection } = usePosSession()
  const { permissionKeys } = usePermissions()
  const access: PosAccess = { permissionKeys, context: context.data }
  const manage = canManageEinvoices(access)
  const branchId = selection.branchId
  const [status, setStatus] = useState<string>('outstanding')
  const [q, setQ] = useState('')
  const [page, setPage] = useState(1)
  const list = useEinvoices({ branchId, status, q, page })
  const summary = useEinvoiceSummary(branchId)
  const retry = useRetryEinvoices()
  const updateBuyer = useUpdateEinvoiceBuyer()
  const replace = useReplaceEinvoice()
  const cancel = useCancelEinvoice()
  const [notice, setNotice] = useState<Notice>(null)
  const [editor, setEditor] = useState<Editor>(null)
  const [buyer, setBuyer] = useState<Record<BuyerField, string>>(buyerForm({}))
  const [reason, setReason] = useState('')

  async function run(action: () => Promise<unknown>, message: string) {
    setNotice(null)
    try {
      await action()
      setNotice({ text: message, failed: false })
      return true
    } catch (failure) {
      setNotice({ text: einvoiceFailure(failure, t), failed: true })
      return false
    }
  }

  function open(einvoice: Einvoice, mode: 'buyer' | 'replace' | 'cancel') {
    setEditor({ einvoice, mode })
    setBuyer(buyerForm(mode === 'replace' ? {} : einvoice.buyer))
    setReason('')
    setNotice(null)
  }

  async function submit() {
    if (!editor) return
    const { einvoice, mode } = editor
    let done = false
    if (mode === 'buyer')
      done = await run(
        () => updateBuyer.mutateAsync({ id: einvoice.id, buyer: compact(buyer) }),
        t('saved'),
      )
    else if (mode === 'replace')
      done = await run(
        () => replace.mutateAsync({ id: einvoice.id, buyer: compact(buyer), reason }),
        t('einvoices.replaceDone'),
      )
    else {
      const sure = await confirm({
        message: t('einvoices.confirmCancel', { number: einvoice.order_number }),
        variant: 'destructive',
        confirmLabel: t('einvoices.cancel'),
        cancelLabel: t('adminCancel'),
      })
      if (!sure) return
      done = await run(
        () => cancel.mutateAsync({ id: einvoice.id, reason }),
        t('einvoices.cancelDone'),
      )
    }
    if (done) setEditor(null)
  }

  const rows = list.data?.data ?? []
  const pages = list.data?.meta?.pages ?? 1
  const revenue = summary.data?.revenue
  const busy = updateBuyer.isPending || replace.isPending || cancel.isPending
  return (
    <div className="space-y-6">
      <PageHeader
        title={t('einvoices.title')}
        description={t('einvoices.intro')}
        actions={
          <div className="flex items-center gap-2">
            <BranchPicker />
            {!manage && <Badge variant="outline">{t('adminReadAccess')}</Badge>}
          </div>
        }
      />
      {notice && (
        <p
          role={notice.failed ? 'alert' : 'status'}
          className={notice.failed ? 'text-destructive' : 'text-muted-foreground'}
        >
          {notice.text}
        </p>
      )}
      {!branchId ? (
        <p className="text-muted-foreground">{t('pageChooseBranchHint')}</p>
      ) : (
        <>
          {summary.data && revenue && (
            <Card>
              <CardContent className="flex flex-wrap items-center gap-x-6 gap-y-2 pt-6">
                <span>{t('einvoices.outstandingCount', { count: summary.data.outstanding })}</span>
                {summary.data.einvoice_type === 'none' && (
                  <span className="text-muted-foreground">{t('einvoices.typeNone')}</span>
                )}
                <span className="tabular-nums">
                  {t('einvoices.revenue', {
                    year: revenue.year,
                    total: formatMoney(revenue.total, 'VND'),
                    threshold: formatMoney(revenue.threshold, 'VND'),
                    percent: Math.round(Number(revenue.share) * 100),
                  })}
                </span>
                {revenue.level !== 'ok' && (
                  <p
                    role="alert"
                    className={revenue.level === 'reached' ? 'text-destructive' : 'text-amber-700'}
                  >
                    {t(`einvoices.revenue_${revenue.level}`)}
                  </p>
                )}
              </CardContent>
            </Card>
          )}
          <Card>
            <CardContent className="space-y-4 pt-6">
              <div className="flex flex-wrap items-end gap-3">
                <div className="w-56">
                  <TopologyField label={t('einvoices.statusFilter')}>
                    {(id) => (
                      <TopologySelect
                        id={id}
                        value={status}
                        onChange={(value) => {
                          setStatus(value)
                          setPage(1)
                        }}
                        options={STATUS_FILTERS.map((value) => ({
                          value,
                          label: t(`einvoices.filter_${value || 'all'}`),
                        }))}
                      />
                    )}
                  </TopologyField>
                </div>
                <div className="w-56">
                  <TopologyField label={t('einvoices.search')}>
                    {(id) => (
                      <Input
                        id={id}
                        value={q}
                        onChange={(event) => {
                          setQ(event.target.value)
                          setPage(1)
                        }}
                      />
                    )}
                  </TopologyField>
                </div>
                {manage && (
                  <Button
                    type="button"
                    variant="outline"
                    className="ml-auto"
                    disabled={retry.isPending || (summary.data?.counts.failed ?? 0) === 0}
                    onClick={() =>
                      void run(async () => {
                        const response = await retry.mutateAsync({ branch_id: branchId })
                        return response.data
                      }, t('einvoices.retryQueued'))
                    }
                  >
                    {t('einvoices.retryFailed', { count: summary.data?.counts.failed ?? 0 })}
                  </Button>
                )}
              </div>
              {list.isPending ? (
                <p role="status">{t('contextWaiting')}</p>
              ) : list.isError ? (
                <p role="alert" className="text-destructive">
                  {einvoiceFailure(list.error, t)}
                </p>
              ) : rows.length === 0 ? (
                <p className="text-muted-foreground">{t('einvoices.none')}</p>
              ) : (
                <ul className="divide-y" aria-label={t('einvoices.title')}>
                  {rows.map((row) => (
                    <li key={row.id} className="space-y-1 py-3">
                      <div className="flex flex-wrap items-center gap-x-4 gap-y-1">
                        <span className="min-w-32 font-medium">{row.order_number}</span>
                        <Badge variant={STATUS_VARIANT[row.status] ?? 'outline'}>
                          {t(`einvoices.status_${row.status}`)}
                        </Badge>
                        {row.relation === 'replacement' && (
                          <Badge variant="outline">{t('einvoices.replacement')}</Badge>
                        )}
                        <span className="tabular-nums">
                          {row.total ? formatMoney(row.total, row.currency) : ''}
                        </span>
                        <span className="text-sm text-muted-foreground">
                          {row.buyer.name || row.buyer.label || t('einvoices.consumer')}
                          {row.buyer.tax_code ? ` · ${row.buyer.tax_code}` : ''}
                        </span>
                        {row.number && (
                          <span className="text-sm">
                            {row.template_code}
                            {row.symbol} · {row.number}
                          </span>
                        )}
                        {manage && (
                          <span className="ml-auto flex flex-wrap gap-2">
                            {row.status === 'failed' && (
                              <Button
                                size="sm"
                                variant="outline"
                                disabled={retry.isPending}
                                onClick={() =>
                                  void run(
                                    () => retry.mutateAsync({ ids: [row.id] }),
                                    t('einvoices.retryQueued'),
                                  )
                                }
                              >
                                {t('einvoices.retry')}
                              </Button>
                            )}
                            {(row.status === 'pending' || row.status === 'failed') && (
                              <>
                                <Button
                                  size="sm"
                                  variant="outline"
                                  onClick={() => open(row, 'buyer')}
                                >
                                  {t('einvoices.editBuyer')}
                                </Button>
                                <Button
                                  size="sm"
                                  variant="outline"
                                  onClick={() => open(row, 'cancel')}
                                >
                                  {t('einvoices.cancel')}
                                </Button>
                              </>
                            )}
                            {row.status === 'issued' && (
                              <Button
                                size="sm"
                                variant="outline"
                                onClick={() => open(row, 'replace')}
                              >
                                {t('einvoices.replace')}
                              </Button>
                            )}
                          </span>
                        )}
                      </div>
                      {row.last_error && row.status === 'failed' && (
                        <p className="text-sm text-destructive">
                          {t('einvoices.lastError', {
                            error: row.last_error,
                            attempts: row.attempts,
                          })}
                        </p>
                      )}
                    </li>
                  ))}
                </ul>
              )}
              {pages > 1 && (
                <div className="flex items-center gap-2">
                  <Button
                    size="sm"
                    variant="outline"
                    disabled={page <= 1}
                    onClick={() => setPage(page - 1)}
                  >
                    {t('einvoices.previous')}
                  </Button>
                  <span className="text-sm">{t('einvoices.page', { page, pages })}</span>
                  <Button
                    size="sm"
                    variant="outline"
                    disabled={page >= pages}
                    onClick={() => setPage(page + 1)}
                  >
                    {t('einvoices.next')}
                  </Button>
                </div>
              )}
            </CardContent>
          </Card>
          {editor && (
            <Card>
              <CardContent className="space-y-4 pt-6">
                <h2 className="font-medium">
                  {t(`einvoices.editor_${editor.mode}`, { number: editor.einvoice.order_number })}
                </h2>
                {editor.mode !== 'cancel' && (
                  <div className="grid gap-4 md:grid-cols-2">
                    {BUYER_FIELDS.map((field) => (
                      <TopologyField key={field} label={t(`einvoices.field_${field}`)}>
                        {(id) => (
                          <Input
                            id={id}
                            value={buyer[field]}
                            onChange={(event) =>
                              setBuyer({ ...buyer, [field]: event.target.value })
                            }
                          />
                        )}
                      </TopologyField>
                    ))}
                  </div>
                )}
                {editor.mode !== 'buyer' && (
                  <TopologyField label={t('einvoices.reason')}>
                    {(id) => (
                      <Textarea
                        id={id}
                        value={reason}
                        onChange={(event) => setReason(event.target.value)}
                      />
                    )}
                  </TopologyField>
                )}
                <div className="flex gap-2">
                  <Button type="button" disabled={busy} onClick={() => void submit()}>
                    {editor.mode === 'cancel' ? t('einvoices.cancel') : t('save')}
                  </Button>
                  <Button type="button" variant="outline" onClick={() => setEditor(null)}>
                    {t('adminCancel')}
                  </Button>
                </div>
              </CardContent>
            </Card>
          )}
        </>
      )}
    </div>
  )
}
