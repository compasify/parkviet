import {
  defineTable,
  mapSpreeErrorsToForm,
  PageHeader,
  ResourceTable,
  resourceSearchSchema,
} from '@spree/dashboard-core'
import {
  ActiveBadge,
  Badge,
  Button,
  DialogFooter,
  ResourceNameCell,
  RowActions,
  useConfirm,
  useRowClickBridge,
} from '@spree/dashboard-ui'
import { BanIcon, RotateCcwIcon, TrashIcon } from '@spree/dashboard-ui/icons'
import { useQueryClient } from '@tanstack/react-query'
import { useSearch } from '@tanstack/react-router'
import { useCallback, useRef, useState } from 'react'
import { useForm } from 'react-hook-form'
import { useTranslation } from 'react-i18next'
import { MasterNotice, MasterState } from '../components/master-page'
import { TopologyDialog } from '../components/topology-dialog'
import { Input, TopologyField, TopologySelect } from '../components/topology-fields'
import {
  masterFailure,
  PAYMENT_METHOD_KINDS,
  type PaymentMethodKind,
  type PosPaymentMethod,
  readPaymentMethods,
  useStoreWrite,
} from '../hooks/use-master-data'
import { usePosSession } from '../hooks/use-pos-session'
import { useSession } from '../hooks/use-session'
import { posKey } from '../lib/query-keys'
import { paymentMethodBody, paymentMethodSchema } from '../schemas/master-data'
import { hiddenTimestamps } from '../tables/columns'
import { localList } from '../tables/local-list'

const ROW_ATTRIBUTE = 'data-pos-payment-method-id' as const

// The store's POS payment methods. Branches offer all active methods unless
// their Payments tab picks some; a method a tender used is disabled, never
// deleted, and the store keeps one active cash method.
export function PaymentMethodsPage() {
  const { t } = useTranslation()
  const confirm = useConfirm()
  const client = useQueryClient()
  const { storeId } = useSession()
  const { context } = usePosSession()
  const searchParams = resourceSearchSchema.parse(useSearch({ strict: false }))
  const access = context.data?.administration ?? { read: false, write: false }
  const write = useStoreWrite()
  const [editor, setEditor] = useState<{ method?: PosPaymentMethod } | null>(null)
  const [notice, setNotice] = useState<{ text: string; failed: boolean } | null>(null)
  async function run(
    request: { method: string; path: string; body?: unknown },
    question: { message: string; confirmLabel: string; destructive: boolean },
  ) {
    if (!access.write || write.isPending) return
    if (
      !(await confirm({
        message: question.message,
        variant: question.destructive ? 'destructive' : 'default',
        confirmLabel: question.confirmLabel,
        cancelLabel: t('adminCancel'),
      }))
    )
      return
    setNotice(null)
    try {
      await write.mutateAsync(request)
      setNotice({ text: t('saved'), failed: false })
    } catch (failure) {
      setNotice({ text: masterFailure(failure, t), failed: true })
    }
  }
  const setStatus = (method: PosPaymentMethod) => {
    const disabling = method.status === 'active'
    return run(
      {
        method: 'PATCH',
        path: `/pos/payment_methods/${method.id}`,
        body: { status: disabling ? 'disabled' : 'active' },
      },
      {
        message: t(disabling ? 'adminConfirmDisable' : 'adminConfirmEnable', { name: method.name }),
        confirmLabel: t(disabling ? 'adminDisable' : 'adminEnable'),
        destructive: disabling,
      },
    )
  }
  const remove = (method: PosPaymentMethod) =>
    run(
      { method: 'DELETE', path: `/pos/payment_methods/${method.id}` },
      {
        message: t('paymentMethods.confirmDelete', { name: method.name }),
        confirmLabel: t('paymentMethods.delete'),
        destructive: true,
      },
    )
  function edit(method?: PosPaymentMethod) {
    setNotice(null)
    setEditor({ method })
  }
  const rows = useRef<PosPaymentMethod[]>([])
  const openMethod = useRef<(id: string) => void>(() => {})
  openMethod.current = (id) => {
    const method = rows.current.find((row) => row.id === id)
    if (method && access.write) edit(method)
  }
  const openRow = useCallback((id: string) => openMethod.current(id), [])
  useRowClickBridge(ROW_ATTRIBUTE, openRow)
  const tableKey = 'pos-payment-methods'
  defineTable<PosPaymentMethod>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('adminSearchName'),
    defaultSort: { field: 'position', direction: 'asc' },
    emptyMessage: t('adminNoResults'),
    columns: [
      {
        key: 'name',
        label: t('adminName'),
        sortable: true,
        default: true,
        render: (method) => (
          <ResourceNameCell
            id={method.id}
            dataAttr={access.write ? ROW_ATTRIBUTE : undefined}
            name={method.name}
            secondary={method.code}
          />
        ),
      },
      {
        key: 'kind',
        label: t('paymentMethods.kind'),
        sortable: true,
        filterable: true,
        default: true,
        filterType: 'enum',
        filterOptions: PAYMENT_METHOD_KINDS.map((value) => ({
          value,
          label: t(`paymentMethods.kind_${value}`),
        })),
        render: (method) => t(`paymentMethods.kind_${method.kind}`),
      },
      {
        key: 'position',
        label: t('paymentMethods.position'),
        sortable: true,
        default: true,
        className: 'tabular-nums',
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
        render: (method) => (
          <ActiveBadge
            active={method.status === 'active'}
            activeLabel={t('statusActive')}
            inactiveLabel={t('statusDisabled')}
          />
        ),
      },
      ...hiddenTimestamps<PosPaymentMethod>(),
    ],
  })
  return (
    <div className="space-y-6">
      <PageHeader
        title={t('paymentMethods.title')}
        description={t('paymentMethods.intro')}
        actions={
          access.write ? (
            <Button disabled={write.isPending} onClick={() => edit()}>
              {t('paymentMethods.create')}
            </Button>
          ) : access.read ? (
            <Badge variant="outline">{t('adminReadAccess')}</Badge>
          ) : undefined
        }
      />
      <MasterState>
        <MasterNotice notice={notice} />
        <ResourceTable<PosPaymentMethod>
          tableKey={tableKey}
          hideHeader
          queryKey={['pos', 'payment-methods', 'table']}
          queryFn={async (params: Record<string, unknown>) => {
            const all = await client.fetchQuery({
              queryKey: posKey(storeId, 'payment-methods', 'all'),
              queryFn: () => readPaymentMethods(true),
            })
            rows.current = all
            return localList(all, params, {
              searchParam: 'search',
              text: (method) => `${method.name} ${method.code}`,
              sortValue: (method, field) =>
                field === 'position' ? String(method.position).padStart(6, '0') : undefined,
            })
          }}
          searchParams={searchParams}
          rowActions={(method) => (
            <RowActions
              actions={[
                {
                  key: 'edit',
                  label: t('adminEdit'),
                  visible: access.write,
                  disabled: write.isPending,
                  onSelect: () => edit(method),
                },
                {
                  key: method.status === 'active' ? 'disable' : 'enable',
                  label: t(method.status === 'active' ? 'adminDisable' : 'adminEnable'),
                  icon:
                    method.status === 'active' ? (
                      <BanIcon className="size-4" />
                    ) : (
                      <RotateCcwIcon className="size-4" />
                    ),
                  visible: access.write,
                  destructive: method.status === 'active',
                  disabled: write.isPending,
                  onSelect: () => void setStatus(method),
                },
                {
                  key: 'delete',
                  label: t('paymentMethods.delete'),
                  icon: <TrashIcon className="size-4" />,
                  visible: access.write,
                  destructive: true,
                  disabled: write.isPending,
                  onSelect: () => void remove(method),
                },
              ]}
            />
          )}
        />
      </MasterState>
      {editor && access.write && (
        <PaymentMethodDialog
          method={editor.method}
          onSave={async (body) => {
            await write.mutateAsync({
              method: editor.method ? 'PATCH' : 'POST',
              path: `/pos/payment_methods${editor.method ? `/${editor.method.id}` : ''}`,
              body,
            })
            setNotice({ text: t('saved'), failed: false })
          }}
          onClose={() => setEditor(null)}
        />
      )}
    </div>
  )
}

type Values = { kind: PaymentMethodKind; name: string; code: string; position: string }
function PaymentMethodDialog({
  method,
  onSave,
  onClose,
}: {
  method?: PosPaymentMethod
  onSave: (body: Record<string, unknown>) => Promise<void>
  onClose: () => void
}) {
  const { t } = useTranslation()
  const form = useForm<Values>({
    defaultValues: {
      kind: method?.kind ?? 'bank_manual',
      name: method?.name ?? '',
      code: method?.code ?? '',
      position: method ? String(method.position) : '',
    },
  })
  const draft = form.watch()
  const [error, setError] = useState('')
  const busy = form.formState.isSubmitting
  const dirty = form.formState.isDirty
  const set = <K extends keyof Values>(key: K, value: Values[K]) =>
    form.setValue(key, value as never, { shouldDirty: true })
  async function submit(values: Values) {
    form.clearErrors()
    const parsed = paymentMethodSchema.safeParse(values)
    if (!parsed.success) {
      for (const issue of parsed.error.issues)
        form.setError(issue.path[0] as keyof Values, { message: t(issue.message) })
      return
    }
    setError('')
    try {
      await onSave(paymentMethodBody(parsed.data, !method))
      onClose()
    } catch (failure) {
      mapSpreeErrorsToForm(failure, form.setError)
      setError(masterFailure(failure, t))
    }
  }
  const text = (key: 'name' | 'code' | 'position', label: string, hint?: string) => (
    <TopologyField
      label={t(label)}
      hint={hint && t(hint)}
      error={form.formState.errors[key]?.message}
    >
      {(id, describedBy) => (
        <Input
          id={id}
          aria-describedby={describedBy}
          aria-invalid={Boolean(form.formState.errors[key])}
          inputMode={key === 'position' ? 'numeric' : 'text'}
          maxLength={key === 'name' ? 64 : 32}
          value={draft[key]}
          onChange={(event) => set(key, event.target.value)}
        />
      )}
    </TopologyField>
  )
  return (
    <TopologyDialog
      title={t(method ? 'paymentMethods.editTitle' : 'paymentMethods.createTitle')}
      subtitle={method?.name}
      dirty={dirty}
      busy={busy}
      onClose={onClose}
    >
      {(close) => (
        <form onSubmit={form.handleSubmit(submit)} aria-busy={busy} className="space-y-5">
          <fieldset disabled={busy} className="space-y-4">
            <TopologyField label={t('paymentMethods.kind')} hint={t('paymentMethods.kindHint')}>
              {(id, describedBy) => (
                <TopologySelect
                  id={id}
                  describedBy={describedBy}
                  value={draft.kind}
                  disabled={Boolean(method)}
                  options={PAYMENT_METHOD_KINDS.map((value) => ({
                    value,
                    label: t(`paymentMethods.kind_${value}`),
                  }))}
                  onChange={(value) => set('kind', value as PaymentMethodKind)}
                />
              )}
            </TopologyField>
            {text('name', 'adminName')}
            {!method && text('code', 'code', 'paymentMethods.codeHint')}
            {text('position', 'paymentMethods.position', 'paymentMethods.positionHint')}
          </fieldset>
          {error && (
            <p role="alert" className="text-sm text-destructive">
              {error}
            </p>
          )}
          <DialogFooter>
            <Button type="button" variant="outline" disabled={busy} onClick={close}>
              {t('adminCancel')}
            </Button>
            <Button type="submit" disabled={busy || !dirty}>
              {t(busy ? 'waiting' : 'save')}
            </Button>
          </DialogFooter>
        </form>
      )}
    </TopologyDialog>
  )
}
