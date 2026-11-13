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
import {
  defineTable,
  PageHeader,
  ResourceTable,
  resourceSearchSchema,
  useStore,
} from '@spree/dashboard-core'
import {
  ActiveBadge,
  Badge,
  Button,
  Dialog,
  DialogBody,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  Input,
  Label,
  RelativeTime,
  ResourceNameCell,
  RowActions,
  useConfirm,
  useRowClickBridge,
} from '@spree/dashboard-ui'
import { BanIcon, CopyIcon, EyeIcon, PlusIcon, StarIcon } from '@spree/dashboard-ui/icons'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { type FormEvent, useCallback, useRef, useState } from 'react'
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
  readReceiptTemplates,
  refreshReceiptTemplates,
  useReceiptTemplates,
} from '../hooks/use-receipt-templates'
import { localList } from '../tables/local-list'

const ROW_ATTRIBUTE = 'data-pos-receipt-template-id' as const

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
  const fullTypes = DOCUMENT_TYPES.filter((type) => activeCount(type) >= MAX_ACTIVE_TEMPLATES)
  const searchParams = resourceSearchSchema.parse(useSearch({ strict: false }))
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
  const editable = (template: ReceiptTemplate) => access.write && template.status === 'active'
  const open = (template: ReceiptTemplate) =>
    void navigate({
      to: '/$storeId/settings/receipt-templates/$templateId',
      params: { storeId, templateId: template.id },
    })
  // The bridge listens on the document once; the ref hands it the current rows.
  const listed = useRef<ReceiptTemplate[]>([])
  const openTemplate = useRef<(id: string) => void>(() => {})
  openTemplate.current = (id) => {
    const template = listed.current.find((row) => row.id === id)
    if (template) open(template)
  }
  const openRow = useCallback((id: string) => openTemplate.current(id), [])
  useRowClickBridge(ROW_ATTRIBUTE, openRow)
  const tableKey = 'pos-receipt-templates'
  defineTable<ReceiptTemplate>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('adminSearchName'),
    defaultSort: { field: 'document_type', direction: 'asc' },
    emptyMessage: t('receiptTemplates.groupEmpty'),
    columns: [
      {
        key: 'name',
        label: t('receiptTemplates.name'),
        sortable: true,
        default: true,
        render: (template) => (
          <ResourceNameCell
            id={template.id}
            dataAttr={ROW_ATTRIBUTE}
            name={template.name}
            secondary={`${t(`receiptPaper_${template.paper}`)} · ${t(
              'receiptTemplates.versionShort',
              { version: template.current_version },
            )}`}
          />
        ),
      },
      {
        key: 'document_type',
        label: t('receiptTemplates.documentType'),
        sortable: true,
        filterable: true,
        default: true,
        filterType: 'enum',
        quickFilter: true,
        filterOptions: DOCUMENT_TYPES.map((value) => ({
          value,
          label: t(`receiptTemplates.type.${value}`),
        })),
        render: (template) => t(`receiptTemplates.type.${template.document_type}`),
      },
      {
        key: 'status',
        label: t('adminStatus'),
        sortable: true,
        filterable: true,
        default: true,
        filterType: 'enum',
        quickFilter: true,
        filterOptions: ['active', 'disabled'].map((value) => ({
          value,
          label: t(value === 'active' ? 'statusActive' : 'statusDisabled'),
        })),
        render: (template) => (
          <div className="flex flex-wrap items-center gap-2">
            <ActiveBadge
              active={template.status === 'active'}
              activeLabel={t('statusActive')}
              inactiveLabel={t('statusDisabled')}
            />
            {template.is_default ? (
              <Badge variant="secondary">{t('receiptTemplates.default')}</Badge>
            ) : null}
          </div>
        ),
      },
      {
        key: 'updated_at',
        label: '',
        sortable: true,
        filterable: false,
        default: true,
        render: (template) => (
          <span
            className="text-sm whitespace-nowrap text-muted-foreground"
            title={formatDocumentTime(template.updated_at, zone)}
          >
            <RelativeTime iso={template.updated_at} />
            {template.updated_by ? ` · ${template.updated_by.name}` : ''}
          </span>
        ),
      },
      { key: 'created_at', label: '', displayable: false, filterable: false, sortable: false },
    ],
  })
  return (
    <div className="space-y-6">
      <PageHeader
        title={t('receiptTemplates.title')}
        description={t('receiptTemplates.intro')}
        actions={
          access.read && access.write ? (
            <Button
              type="button"
              disabled={Boolean(pendingId) || !templates.isSuccess}
              onClick={() => {
                setNotice(null)
                setCreating(true)
              }}
            >
              <PlusIcon />
              {t('receiptTemplates.create')}
            </Button>
          ) : undefined
        }
      />
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
        <div className="space-y-4">
          <p className="text-sm text-muted-foreground">{t('receiptTemplates.listHint')}</p>
          {notice ? <Notice {...notice} /> : null}
          {access.write && fullTypes.length > 0 ? (
            <p className="text-sm text-muted-foreground">
              {fullTypes.map((type) => t(`receiptTemplates.type.${type}`)).join(', ')}:{' '}
              {t('receiptTemplates.limitNote', { count: MAX_ACTIVE_TEMPLATES })}
            </p>
          ) : null}
          <ResourceTable<ReceiptTemplate>
            tableKey={tableKey}
            hideHeader
            queryKey={['pos', 'receipt-templates', 'table']}
            queryFn={async (params: Record<string, unknown>) => {
              const all = await readReceiptTemplates(storeId, true)
              listed.current = all
              return localList(all, params, {
                searchParam: 'search',
                text: (template) =>
                  `${template.name} ${t(`receiptTemplates.type.${template.document_type}`)}`,
                sortValue: (template, field) =>
                  field === 'document_type'
                    ? String(DOCUMENT_TYPES.indexOf(template.document_type)).padStart(2, '0')
                    : undefined,
              })
            }}
            searchParams={searchParams}
            rowActions={(template) => {
              const active = template.status === 'active'
              const full = activeCount(template.document_type) >= MAX_ACTIVE_TEMPLATES
              return (
                <RowActions
                  actions={[
                    editable(template)
                      ? { key: 'edit', label: t('adminEdit'), onSelect: () => open(template) }
                      : {
                          key: 'view',
                          label: t('receiptTemplates.view'),
                          icon: <EyeIcon className="size-4" />,
                          onSelect: () => open(template),
                        },
                    {
                      key: 'duplicate',
                      label: full
                        ? t('receiptTemplates.limitReached')
                        : t('receiptTemplates.duplicate'),
                      icon: <CopyIcon className="size-4" />,
                      visible: access.write,
                      disabled: Boolean(pendingId) || full,
                      onSelect: () =>
                        void act(template, duplicateReceiptTemplate, 'receiptTemplates.duplicated'),
                    },
                    {
                      key: 'default',
                      label: t('receiptTemplates.makeDefault'),
                      icon: <StarIcon className="size-4" />,
                      visible: access.write && active && !template.is_default,
                      disabled: Boolean(pendingId),
                      onSelect: () =>
                        void act(
                          template,
                          makeDefaultReceiptTemplate,
                          'receiptTemplates.madeDefault',
                        ),
                    },
                    {
                      key: 'disable',
                      label: t('receiptTemplates.disable'),
                      icon: <BanIcon className="size-4" />,
                      visible: access.write && active,
                      destructive: true,
                      disabled: Boolean(pendingId),
                      onSelect: () => void disable(template),
                    },
                  ]}
                />
              )
            }}
          />
        </div>
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
