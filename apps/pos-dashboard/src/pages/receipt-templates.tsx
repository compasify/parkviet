import { formatDocumentTime } from '@parkviet/pos-shared/receipt-template/data'
import {
  DOCUMENT_TYPES,
  type DocumentType,
  type PaperSize,
} from '@parkviet/pos-shared/receipt-template/types'
import {
  MAX_ACTIVE_TEMPLATES,
  MAX_NAME_LENGTH,
} from '@parkviet/pos-shared/receipt-template/validate'
import {
  conflictReason,
  describeFailure,
  posFailureKey,
} from '@parkviet/pos-shared/request-failure'
import { useStore } from '@spree/dashboard-core'
import {
  Badge,
  Button,
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
  Dialog,
  DialogBody,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  Input,
  Label,
  useConfirm,
} from '@spree/dashboard-ui'
import { Link, useNavigate } from '@tanstack/react-router'
import { Plus } from 'lucide-react'
import { type FormEvent, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { Choice, Notice, PageState } from '../components/receipt-template/controls'
import { PaperPicker } from '../components/receipt-template/paper-picker'
import { usePosContext } from '../hooks/use-pos-context'
import {
  createReceiptTemplate,
  disableReceiptTemplate,
  duplicateReceiptTemplate,
  makeDefaultReceiptTemplate,
  type ReceiptTemplate,
  refreshReceiptTemplates,
  useReceiptTemplates,
} from '../hooks/use-receipt-templates'

export function templateFailure(error: unknown, t: (key: string) => string): string {
  switch (conflictReason(error)) {
    case 'template_version_conflict':
      return t('receiptTemplates.conflict')
    case 'template_limit_reached':
      return t('receiptTemplates.limitReached')
    case 'template_disabled':
      return t('receiptTemplates.disabledConflict')
    case 'template_default_required':
      return t('receiptTemplates.defaultRequired')
    default:
      return describeFailure(error, t)
  }
}

export function ReceiptTemplatesPage() {
  const { t } = useTranslation('pos')
  const navigate = useNavigate()
  const { storeId } = useStore()
  const context = usePosContext()
  const access = context.data?.administration ?? { read: false, write: false }
  const templates = useReceiptTemplates(access.read, true)
  const [creating, setCreating] = useState(false)
  const [pendingId, setPendingId] = useState<string | null>(null)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  const confirm = useConfirm()
  const rows = templates.data ?? []
  const zone = context.data?.store.timezone ?? 'Asia/Ho_Chi_Minh'
  const activeCount = (type: DocumentType) =>
    rows.filter((row) => row.document_type === type && row.status === 'active').length
  async function act(
    template: ReceiptTemplate,
    run: (id: string) => Promise<{ data: ReceiptTemplate }>,
    done: string,
  ) {
    if (!access.write || pendingId) return
    setPendingId(template.id)
    setNotice(null)
    try {
      const result = await run(template.id)
      setNotice({ text: t(done, { name: result.data.name }), failed: false })
    } catch (error) {
      setNotice({ text: templateFailure(error, t), failed: true })
    } finally {
      setPendingId(null)
      await refreshReceiptTemplates()
    }
  }
  async function disable(template: ReceiptTemplate) {
    if (!access.write || pendingId) return
    if (
      await confirm({
        title: t('receiptTemplates.disable'),
        message: t('receiptTemplates.confirmDisable', { name: template.name }),
        confirmLabel: t('receiptTemplates.disable'),
        cancelLabel: t('adminCancel'),
        variant: 'destructive',
      })
    )
      await act(template, disableReceiptTemplate, 'receiptTemplates.disabled')
  }
  return (
    <div className="mx-auto grid w-full max-w-6xl gap-6 p-4 md:p-6">
      <header className="grid gap-2">
        <h1 className="text-2xl font-semibold">{t('receiptTemplates.title')}</h1>
        <p className="text-muted-foreground">{t('receiptTemplates.intro')}</p>
      </header>
      {context.isPending ? (
        <PageState title={t('contextWaiting')} />
      ) : context.isError ? (
        <PageState
          title={t(posFailureKey(context.error))}
          error={describeFailure(context.error, t)}
          retry={() => void context.refetch()}
          retryLabel={t('retry')}
        />
      ) : !access.read ? (
        <PageState title={t('forbidden')} error={t('adminAccessDenied')} />
      ) : (
        <Card>
          <CardHeader className="flex flex-wrap items-start justify-between gap-3">
            <div className="grid gap-1">
              <CardTitle>{t('receiptTemplates.listTitle')}</CardTitle>
              <CardDescription>{t('receiptTemplates.listHint')}</CardDescription>
            </div>
            {access.write ? (
              <Button
                type="button"
                disabled={Boolean(pendingId) || !templates.isSuccess}
                onClick={() => {
                  setNotice(null)
                  setCreating(true)
                }}
              >
                <Plus />
                {t('receiptTemplates.create')}
              </Button>
            ) : null}
          </CardHeader>
          <CardContent className="grid gap-6">
            {notice ? <Notice {...notice} /> : null}
            {templates.isPending ? <PageState title={t('waiting')} /> : null}
            {templates.isError ? (
              <PageState
                title={t(posFailureKey(templates.error))}
                error={describeFailure(templates.error, t)}
                retry={() => void templates.refetch()}
                retryLabel={t('retry')}
              />
            ) : null}
            {templates.isSuccess
              ? DOCUMENT_TYPES.map((type) => {
                  const group = rows.filter((row) => row.document_type === type)
                  const full = activeCount(type) >= MAX_ACTIVE_TEMPLATES
                  const typeName = t(`receiptTemplates.type.${type}`)
                  return (
                    <section key={type} className="grid gap-3" aria-labelledby={`rt-group-${type}`}>
                      <h2 id={`rt-group-${type}`} className="font-semibold">
                        {typeName}
                      </h2>
                      {group.length === 0 ? (
                        <p className="text-sm text-muted-foreground">
                          {t('receiptTemplates.groupEmpty')}
                        </p>
                      ) : null}
                      <ul
                        className="divide-y rounded-lg border"
                        aria-label={t('receiptTemplates.groupList', { type: typeName })}
                      >
                        {group.map((template) => {
                          const active = template.status === 'active'
                          return (
                            <li key={template.id} className="flex flex-wrap items-center gap-3 p-4">
                              <div className="mr-auto grid min-w-0 gap-1">
                                <strong className="break-words">{template.name}</strong>
                                <small className="text-muted-foreground">
                                  {t(`receiptPaper_${template.paper}`)}
                                  {` · ${t('receiptTemplates.versionShort', { version: template.current_version })}`}
                                </small>
                                <small className="text-muted-foreground">
                                  {template.updated_by
                                    ? t('receiptTemplates.updatedBy', {
                                        time: formatDocumentTime(template.updated_at, zone),
                                        name: template.updated_by.name,
                                      })
                                    : t('receiptTemplates.updatedAt', {
                                        time: formatDocumentTime(template.updated_at, zone),
                                      })}
                                </small>
                              </div>
                              {template.is_default ? (
                                <Badge variant="secondary">{t('receiptTemplates.default')}</Badge>
                              ) : null}
                              {!active ? (
                                <Badge variant="outline">{t('statusDisabled')}</Badge>
                              ) : null}
                              <div className="flex flex-wrap gap-2">
                                <Button asChild variant="outline" size="sm">
                                  <Link
                                    to="/$storeId/settings/receipt-templates/$templateId"
                                    params={{ storeId, templateId: template.id }}
                                    aria-label={t(
                                      access.write && active
                                        ? 'receiptTemplates.editName'
                                        : 'receiptTemplates.viewName',
                                      { name: template.name },
                                    )}
                                  >
                                    {t(
                                      access.write && active
                                        ? 'adminEdit'
                                        : 'receiptTemplates.view',
                                    )}
                                  </Link>
                                </Button>
                                {access.write ? (
                                  <Button
                                    type="button"
                                    variant="outline"
                                    size="sm"
                                    disabled={Boolean(pendingId) || full}
                                    title={full ? t('receiptTemplates.limitReached') : undefined}
                                    aria-label={t('receiptTemplates.duplicateName', {
                                      name: template.name,
                                    })}
                                    onClick={() =>
                                      void act(
                                        template,
                                        duplicateReceiptTemplate,
                                        'receiptTemplates.duplicated',
                                      )
                                    }
                                  >
                                    {t('receiptTemplates.duplicate')}
                                  </Button>
                                ) : null}
                                {access.write && active && !template.is_default ? (
                                  <Button
                                    type="button"
                                    variant="outline"
                                    size="sm"
                                    disabled={Boolean(pendingId)}
                                    aria-label={t('receiptTemplates.makeDefaultName', {
                                      name: template.name,
                                    })}
                                    onClick={() =>
                                      void act(
                                        template,
                                        makeDefaultReceiptTemplate,
                                        'receiptTemplates.madeDefault',
                                      )
                                    }
                                  >
                                    {t('receiptTemplates.makeDefault')}
                                  </Button>
                                ) : null}
                                {access.write && active ? (
                                  <Button
                                    type="button"
                                    variant="destructive"
                                    size="sm"
                                    disabled={Boolean(pendingId)}
                                    aria-label={t('receiptTemplates.disableName', {
                                      name: template.name,
                                    })}
                                    onClick={() => void disable(template)}
                                  >
                                    {pendingId === template.id
                                      ? t('waiting')
                                      : t('receiptTemplates.disable')}
                                  </Button>
                                ) : null}
                              </div>
                            </li>
                          )
                        })}
                      </ul>
                      {full && access.write ? (
                        <small className="text-muted-foreground">
                          {t('receiptTemplates.limitNote', { count: MAX_ACTIVE_TEMPLATES })}
                        </small>
                      ) : null}
                    </section>
                  )
                })
              : null}
          </CardContent>
        </Card>
      )}
      {creating ? (
        <CreateTemplateDialog
          isFull={(type) => activeCount(type) >= MAX_ACTIVE_TEMPLATES}
          onClose={() => setCreating(false)}
          onCreated={async (template) => {
            await refreshReceiptTemplates()
            setCreating(false)
            await navigate({
              to: '/$storeId/settings/receipt-templates/$templateId',
              params: { storeId, templateId: template.id },
            })
          }}
        />
      ) : null}
    </div>
  )
}

function CreateTemplateDialog({
  isFull,
  onClose,
  onCreated,
}: {
  isFull: (type: DocumentType) => boolean
  onClose: () => void
  onCreated: (template: ReceiptTemplate) => Promise<void>
}) {
  const { t } = useTranslation('pos')
  const firstOpen = DOCUMENT_TYPES.find((type) => !isFull(type)) ?? 'sale'
  const [type, setType] = useState<DocumentType>(firstOpen)
  const [paper, setPaper] = useState<PaperSize>('80mm')
  const [name, setName] = useState(() => t(`receiptTemplates.defaultName.${firstOpen}`))
  const [named, setNamed] = useState(false)
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState('')
  const full = isFull(type)
  const blank = name.trim() === ''
  const close = () => {
    if (!busy && (!named || window.confirm(t('adminDiscard')))) onClose()
  }
  async function submit(event: FormEvent) {
    event.preventDefault()
    if (busy || full || blank) return
    setBusy(true)
    setError('')
    try {
      const result = await createReceiptTemplate({ from_default: type, name: name.trim(), paper })
      await onCreated(result.data)
    } catch (failure) {
      setError(templateFailure(failure, t))
      setBusy(false)
    }
  }
  return (
    <Dialog
      open
      onOpenChange={(open) => {
        if (!open) close()
      }}
    >
      <DialogContent showCloseButton={!busy}>
        <DialogHeader>
          <DialogTitle>{t('receiptTemplates.createTitle')}</DialogTitle>
          <DialogDescription>{t('receiptTemplates.createHint')}</DialogDescription>
        </DialogHeader>
        <form onSubmit={submit} className="contents">
          <DialogBody>
            <fieldset className="grid gap-4" disabled={busy}>
              <Choice
                label={t('receiptTemplates.documentType')}
                value={type}
                disabled={busy}
                options={DOCUMENT_TYPES.map((value) => ({
                  value,
                  label: t(`receiptTemplates.type.${value}`),
                }))}
                onChange={(next) => {
                  setType(next)
                  if (!named) setName(t(`receiptTemplates.defaultName.${next}`))
                }}
              />
              {full ? (
                <Notice
                  failed
                  text={t('receiptTemplates.limitNote', { count: MAX_ACTIVE_TEMPLATES })}
                />
              ) : null}
              <PaperPicker value={paper} disabled={busy} onChange={setPaper} />
              <div className="grid gap-2">
                <Label htmlFor="rt-create-name">{t('receiptTemplates.name')}</Label>
                <Input
                  id="rt-create-name"
                  value={name}
                  maxLength={MAX_NAME_LENGTH}
                  required
                  onChange={(event) => {
                    setName(event.target.value)
                    setNamed(true)
                  }}
                />
              </div>
              <p className="text-sm text-muted-foreground">
                {t('receiptTemplates.fromSuggestion')}
              </p>
            </fieldset>
            {error ? <Notice failed text={error} /> : null}
          </DialogBody>
          <DialogFooter>
            <Button type="button" variant="outline" onClick={close} disabled={busy}>
              {t('adminCancel')}
            </Button>
            <Button type="submit" disabled={busy || full || blank}>
              {busy ? t('waiting') : t('receiptTemplates.createSubmit')}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
