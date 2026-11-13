import type { PrintJobDocument } from '@parkviet/pos-shared/receipt-template/types'
import { posFailureKey } from '@parkviet/pos-shared/request-failure'
import type {
  Printer,
  PrinterConnection,
  PrinterRole,
} from '@parkviet/pos-shared/types/print-adapter'
import { usePermissions } from '@spree/dashboard-core'
import { Button, Input, Label, useConfirm } from '@spree/dashboard-ui'
import { PrinterIcon } from '@spree/dashboard-ui/icons'
import { type FormEvent, useCallback, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { masterFailure } from '../hooks/use-master-data'
import { usePosSession } from '../hooks/use-pos-session'
import {
  type PrinterTestResult,
  usePrinters,
  usePrinterWrite,
  usePrintStations,
} from '../hooks/use-printers'
import { printTestPage } from '../lib/direct-print'
import { canAdminister, hasCapability } from '../lib/pos-access'
import { useBranchScope } from './branch-detail'
import { ReceiptFrame } from './receipt-template/template-preview'
import { ModelCard, ModelCheck, ModelNotice, ModelSelect, ModelState } from './setup/model-ui'

const CONNECTIONS: readonly PrinterConnection[] = [
  'browser',
  'epson_epos',
  'star_webprnt',
  'escpos_lan',
  'escpos_bluetooth',
  'sunmi_builtin',
]
const STATION: readonly PrinterConnection[] = ['escpos_lan', 'escpos_bluetooth', 'sunmi_builtin']
const ADDRESSED: readonly PrinterConnection[] = ['epson_epos', 'star_webprnt', 'escpos_lan']
const ROLES: readonly PrinterRole[] = [
  'receipt',
  'prebill',
  'kitchen_ticket',
  'void_ticket',
  'cup_label',
  'checklist',
  'table_qr',
]

type Draft = {
  id: string | null
  name: string
  connection: PrinterConnection
  address: string
  bluetoothId: string
  paper: Printer['paper']
  language: Printer['command_language']
  roles: PrinterRole[]
  device: string
  register: string
  https: boolean
  cut: boolean
}

const blank: Draft = {
  id: null,
  name: '',
  connection: 'browser',
  address: '',
  bluetoothId: '',
  paper: '80mm',
  language: 'escpos',
  roles: ['receipt'],
  device: '',
  register: '',
  https: false,
  cut: true,
}

const draftOf = (row: Printer): Draft => ({
  id: row.id,
  name: row.name,
  connection: row.connection,
  address: row.address ?? '',
  bluetoothId: row.bluetooth_id ?? '',
  paper: row.paper,
  language: row.command_language,
  roles: row.roles,
  device: row.print_station_device_id ?? '',
  register: row.register_id ?? '',
  https: row.settings.https === true,
  cut: row.settings.cut !== false,
})

// Only the fields this connection uses go to the server, which refuses the rest.
function bodyOf(draft: Draft) {
  const station = STATION.includes(draft.connection)
  return {
    name: draft.name.trim(),
    connection: draft.connection,
    address: ADDRESSED.includes(draft.connection) ? draft.address.trim() : null,
    bluetooth_id: draft.connection === 'escpos_bluetooth' ? draft.bluetoothId.trim() : null,
    paper: draft.paper,
    command_language: station ? draft.language : 'escpos',
    roles: draft.roles,
    print_station_device_id: station ? draft.device || null : null,
    register_id: draft.register || null,
    settings: {
      cut: draft.cut,
      ...(draft.connection === 'epson_epos' || draft.connection === 'star_webprnt'
        ? { https: draft.https }
        : {}),
    },
  }
}

// The branch's printers: what each one is, which documents it takes, and a
// test page. Disabling keeps a printer's history; deleting is only for one
// that never had a job.
export function BranchPrinters() {
  const { t } = useTranslation()
  const { branch } = useBranchScope()
  const { permissionKeys } = usePermissions()
  const { context } = usePosSession()
  const posAccess = { permissionKeys, context: context.data }
  const manage = canAdminister(posAccess, true) || hasCapability(posAccess, 'pos.printer.manage')
  const printers = usePrinters(branch.id)
  const stations = usePrintStations(branch.id, manage)
  const write = usePrinterWrite()
  const confirm = useConfirm()
  const [draft, setDraft] = useState<Draft | null>(null)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const [frame, setFrame] = useState<{
    document: PrintJobDocument
    paper: Printer['paper']
  } | null>(null)
  const registers = (context.data?.registers ?? []).filter((row) => row.branch_id === branch.id)

  const attempt = async (work: () => Promise<void>) => {
    setNotice(null)
    try {
      await work()
    } catch (failure) {
      setNotice({ text: masterFailure(failure, t), failed: true })
    }
  }

  const save = (event: FormEvent) => {
    event.preventDefault()
    if (!draft || write.isPending) return
    void attempt(async () => {
      await (draft.id
        ? write.mutateAsync({
            method: 'PATCH',
            path: `/pos/printers/${draft.id}`,
            body: bodyOf(draft),
          })
        : write.mutateAsync({
            method: 'POST',
            path: '/pos/printers',
            body: { branch_id: branch.id, ...bodyOf(draft) },
          }))
      setDraft(null)
      setNotice({ text: t('saved'), failed: false })
    })
  }

  const setStatus = (row: Printer, status: Printer['status']) =>
    attempt(async () => {
      await write.mutateAsync({
        method: 'PATCH',
        path: `/pos/printers/${row.id}`,
        body: { status },
      })
    })

  const remove = async (row: Printer) => {
    const accepted = await confirm({
      message: t('branchPrinters.deleteConfirm', { name: row.name }),
      variant: 'destructive',
      confirmLabel: t('branchPrinters.delete'),
      cancelLabel: t('adminCancel'),
    })
    if (!accepted) return
    await attempt(async () => {
      await write.mutateAsync({ method: 'DELETE', path: `/pos/printers/${row.id}` })
    })
  }

  const test = (row: Printer) =>
    attempt(async () => {
      const { data } = (await write.mutateAsync({
        method: 'POST',
        path: `/pos/printers/${row.id}/test`,
      })) as { data: PrinterTestResult }
      if (data.print_job) {
        setNotice({ text: t('branchPrinters.testQueued', { name: row.name }), failed: false })
      } else if (data.document && row.connection === 'browser') {
        setFrame({ document: data.document, paper: row.paper })
      } else if (data.document) {
        const outcome = await printTestPage(row, data.document)
        setNotice(
          outcome.ok
            ? { text: t('branchPrinters.testSent', { name: row.name }), failed: false }
            : {
                text: t(`branchPrinters.outcome_${outcome.reason}`, { name: row.name }),
                failed: true,
              },
        )
      }
    })

  const printReady = useCallback(
    (element: HTMLIFrameElement) => {
      try {
        if (!element.contentWindow) throw new Error('Print frame unavailable')
        element.contentWindow.focus()
        element.contentWindow.print()
      } catch {
        setNotice({ text: t('receiptPrintFailed'), failed: true })
      } finally {
        setFrame(null)
      }
    },
    [t],
  )

  const edit = (patch: Partial<Draft>) =>
    setDraft((current) => (current ? { ...current, ...patch } : current))

  return (
    <ModelCard title={t('branchPrinters.title')} id="branch-printers" icon={<PrinterIcon />}>
      <p className="text-sm text-muted-foreground">{t('branchPrinters.intro')}</p>
      <ModelNotice notice={notice} />
      {printers.isPending ? (
        <ModelState title={t('waiting')} />
      ) : printers.error || !printers.data ? (
        <ModelState
          error
          title={t(posFailureKey(printers.error))}
          retry={() => void printers.refetch()}
        />
      ) : printers.data.length === 0 ? (
        <p>{t('branchPrinters.empty')}</p>
      ) : (
        <ul className="divide-y" aria-label={t('branchPrinters.title')}>
          {printers.data.map((row) => (
            <li
              key={row.id}
              className="flex flex-wrap items-center gap-3 py-3"
              data-testid="printer-row"
            >
              <div className="min-w-0 flex-1">
                <strong>{row.name}</strong>
                <p className="text-sm text-muted-foreground">
                  {t(`branchPrinters.connection_${row.connection}`)}
                  {row.address ? ` · ${row.address}` : ''} · {row.paper}
                  {row.status === 'disabled' ? ` · ${t('branchPrinters.disabled')}` : ''}
                </p>
              </div>
              {manage ? (
                <div className="flex flex-wrap gap-2">
                  <Button
                    variant="outline"
                    disabled={write.isPending || row.status === 'disabled'}
                    onClick={() => void test(row)}
                  >
                    {t('branchPrinters.test')}
                  </Button>
                  <Button variant="outline" onClick={() => setDraft(draftOf(row))}>
                    {t('branchPrinters.edit')}
                  </Button>
                  <Button
                    variant="outline"
                    disabled={write.isPending}
                    onClick={() =>
                      void setStatus(row, row.status === 'active' ? 'disabled' : 'active')
                    }
                  >
                    {t(
                      row.status === 'active' ? 'branchPrinters.disable' : 'branchPrinters.enable',
                    )}
                  </Button>
                  <Button
                    variant="outline"
                    disabled={write.isPending}
                    onClick={() => void remove(row)}
                  >
                    {t('branchPrinters.delete')}
                  </Button>
                </div>
              ) : null}
            </li>
          ))}
        </ul>
      )}
      {manage && !draft ? (
        <Button onClick={() => setDraft(blank)}>{t('branchPrinters.add')}</Button>
      ) : null}
      {draft ? (
        <form className="space-y-4" onSubmit={save} aria-label={t('branchPrinters.formTitle')}>
          <div className="grid gap-4 sm:grid-cols-2">
            <div className="flex flex-col gap-2">
              <Label htmlFor="printer-name">{t('branchPrinters.name')}</Label>
              <Input
                id="printer-name"
                required
                maxLength={80}
                value={draft.name}
                onChange={(event) => edit({ name: event.target.value })}
              />
            </div>
            <ModelSelect
              label={t('branchPrinters.connection')}
              value={draft.connection}
              onChange={(value) => edit({ connection: value as PrinterConnection })}
              options={CONNECTIONS.map((value) => ({
                value,
                label: t(`branchPrinters.connection_${value}`),
              }))}
            />
            {ADDRESSED.includes(draft.connection) ? (
              <div className="flex flex-col gap-2">
                <Label htmlFor="printer-address">{t('branchPrinters.address')}</Label>
                <Input
                  id="printer-address"
                  required
                  placeholder="192.168.1.20:8008"
                  value={draft.address}
                  onChange={(event) => edit({ address: event.target.value })}
                />
              </div>
            ) : null}
            {draft.connection === 'escpos_bluetooth' ? (
              <div className="flex flex-col gap-2">
                <Label htmlFor="printer-bluetooth">{t('branchPrinters.bluetooth')}</Label>
                <Input
                  id="printer-bluetooth"
                  required
                  maxLength={64}
                  value={draft.bluetoothId}
                  onChange={(event) => edit({ bluetoothId: event.target.value })}
                />
              </div>
            ) : null}
            {STATION.includes(draft.connection) ? (
              <>
                <ModelSelect
                  label={t('branchPrinters.station')}
                  value={draft.device}
                  hint={stations.data?.length === 0 ? t('branchPrinters.noStations') : undefined}
                  onChange={(value) => edit({ device: value })}
                  options={[
                    { value: '', label: '—' },
                    ...(stations.data ?? []).map((row) => ({ value: row.id, label: row.name })),
                  ]}
                />
                <ModelSelect
                  label={t('branchPrinters.language')}
                  value={draft.language}
                  onChange={(value) => edit({ language: value as Printer['command_language'] })}
                  options={[
                    { value: 'escpos', label: 'ESC/POS' },
                    { value: 'tspl', label: 'TSPL' },
                  ]}
                />
              </>
            ) : null}
            <ModelSelect
              label={t('branchPrinters.paper')}
              value={draft.paper}
              onChange={(value) => edit({ paper: value as Printer['paper'] })}
              options={[
                { value: '58mm', label: '58mm' },
                { value: '80mm', label: '80mm' },
              ]}
            />
            <ModelSelect
              label={t('branchPrinters.register')}
              value={draft.register}
              onChange={(value) => edit({ register: value })}
              options={[
                { value: '', label: t('branchPrinters.wholeBranch') },
                ...registers.map((row) => ({ value: row.id, label: row.name })),
              ]}
            />
          </div>
          <fieldset className="grid gap-2 sm:grid-cols-2">
            <legend className="mb-2 text-sm font-medium">{t('branchPrinters.roles')}</legend>
            {ROLES.map((role) => (
              <ModelCheck
                key={role}
                checked={draft.roles.includes(role)}
                onChange={(on) =>
                  edit({
                    roles: on
                      ? [...draft.roles, role]
                      : draft.roles.filter((item) => item !== role),
                  })
                }
              >
                {t(`branchPrinters.role_${role}`)}
              </ModelCheck>
            ))}
          </fieldset>
          <ModelCheck checked={draft.cut} onChange={(cut) => edit({ cut })}>
            {t('branchPrinters.cut')}
          </ModelCheck>
          {draft.connection === 'epson_epos' || draft.connection === 'star_webprnt' ? (
            <ModelCheck
              checked={draft.https}
              onChange={(https) => edit({ https })}
              description={t('branchPrinters.httpsHint')}
            >
              {t('branchPrinters.https')}
            </ModelCheck>
          ) : null}
          <div className="flex gap-2">
            <Button type="submit" disabled={write.isPending}>
              {t(write.isPending ? 'waiting' : 'save')}
            </Button>
            <Button type="button" variant="outline" onClick={() => setDraft(null)}>
              {t('branchPrinters.close')}
            </Button>
          </div>
        </form>
      ) : null}
      {frame ? (
        <div className="pointer-events-none fixed -left-[10000px] top-0" aria-hidden="true">
          <ReceiptFrame
            document={{ ...frame.document, documentType: frame.document.documentType ?? 'sale' }}
            paper={frame.paper}
            title={t('branchPrinters.test')}
            testId="printer-test-print"
            onReady={printReady}
          />
        </div>
      ) : null}
    </ModelCard>
  )
}
