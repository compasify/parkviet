// Settings → VietQR: the bank accounts each VietQR payment method routes
// transfers to, and the bank webhooks received for them. The payment method
// itself (name, timeout, transfer prefix, routing) is edited on the built-in
// Payment methods page; POS only decides per branch whether VietQR is offered.
import {
  ActiveBadge,
  Button,
  CopyToClipboardButton,
  Empty,
  EmptyDescription,
  EmptyHeader,
  EmptyTitle,
  Field,
  FieldDescription,
  FieldError,
  FieldGroup,
  FieldLabel,
  Input,
  mapSpreeErrorsToForm,
  RelativeTime,
  RowActions,
  SecretInput,
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
  Sheet,
  SheetContent,
  SheetDescription,
  SheetFooter,
  SheetHeader,
  SheetTitle,
  StatusBadge,
  Switch,
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableHeaderRow,
  TableRow,
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
  useConfirm,
} from '@spree/dashboard'
import { useEffect, useState } from 'react'
import { Controller, type UseFormReturn, useForm } from 'react-hook-form'
import { useTranslation } from 'react-i18next'
import {
  isResolvableWebhookEvent,
  useCreateVietqrReceivingAccount,
  useDeleteVietqrReceivingAccount,
  useManualMatchVietqrWebhookEvent,
  useRetryVietqrWebhookEvent,
  useUpdateVietqrReceivingAccount,
  useVietqrBanks,
  useVietqrPaymentMethods,
  useVietqrReceivingAccounts,
  useVietqrWebhookEvent,
  useVietqrWebhookEvents,
  VIETQR_WEBHOOK_STATUSES,
  type VietqrWebhookEvent,
} from '../hooks/use-vietqr'
import {
  EMPTY_RECEIVING_ACCOUNT,
  receivingAccountPayload,
  receivingAccountToForm,
  secretFieldsFor,
  VIETQR_PROVIDERS,
  type VietqrReceivingAccount,
  type VietqrReceivingAccountFormValues,
} from '../schemas/vietqr-receiving-account'

const vnd = new Intl.NumberFormat('vi-VN')
const formatAmount = (value: number | null | undefined) =>
  value == null ? '—' : `${vnd.format(value)} ₫`

export function VietqrSettingsPage() {
  const { t } = useTranslation()
  const { data: methods = [], isLoading } = useVietqrPaymentMethods()
  const [methodId, setMethodId] = useState<string>()

  useEffect(() => {
    if (!methodId && methods.length > 0) setMethodId(methods[0].id)
  }, [methodId, methods])

  if (isLoading) return <p className="text-sm text-muted-foreground">{t('admin.common.loading')}</p>

  if (methods.length === 0) {
    return (
      <Empty>
        <EmptyHeader>
          <EmptyTitle>{t('admin.vietqr.no_method.title')}</EmptyTitle>
          <EmptyDescription>{t('admin.vietqr.no_method.description')}</EmptyDescription>
        </EmptyHeader>
      </Empty>
    )
  }

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-wrap items-end justify-between gap-4">
        <div>
          <h1 className="text-xl font-semibold">{t('admin.vietqr.title')}</h1>
          <p className="text-sm text-muted-foreground">{t('admin.vietqr.subtitle')}</p>
        </div>
        {methods.length > 1 && (
          <Select value={methodId ?? ''} onValueChange={(value) => setMethodId(value as string)}>
            <SelectTrigger className="w-64" aria-label={t('admin.vietqr.payment_method')}>
              <SelectValue>
                {(value) => methods.find((m) => m.id === value)?.name ?? ''}
              </SelectValue>
            </SelectTrigger>
            <SelectContent>
              {methods.map((method) => (
                <SelectItem key={method.id} value={method.id}>
                  {method.name}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        )}
      </div>

      <Tabs defaultValue="accounts">
        <TabsList>
          <TabsTrigger value="accounts">{t('admin.vietqr.tabs.accounts')}</TabsTrigger>
          <TabsTrigger value="events">{t('admin.vietqr.tabs.events')}</TabsTrigger>
        </TabsList>
        <TabsContent value="accounts" className="pt-4">
          {methodId && <ReceivingAccountsPanel paymentMethodId={methodId} />}
        </TabsContent>
        <TabsContent value="events" className="pt-4">
          <WebhookEventsPanel />
        </TabsContent>
      </Tabs>
    </div>
  )
}

// --- Receiving accounts -----------------------------------------------------

function ReceivingAccountsPanel({ paymentMethodId }: { paymentMethodId: string }) {
  const { t } = useTranslation()
  const confirm = useConfirm()
  const { data, isLoading } = useVietqrReceivingAccounts(paymentMethodId)
  const deleteMutation = useDeleteVietqrReceivingAccount()
  const [editing, setEditing] = useState<VietqrReceivingAccount | 'new' | null>(null)
  const accounts = data?.data ?? []

  async function handleDelete(account: VietqrReceivingAccount) {
    const ok = await confirm({
      title: t('admin.vietqr.accounts.delete_confirm.title'),
      message: t('admin.vietqr.accounts.delete_confirm.message', {
        account: account.account_number,
      }),
      variant: 'destructive',
      confirmLabel: t('admin.actions.delete'),
    })
    if (ok) await deleteMutation.mutateAsync(account.id).catch(() => undefined)
  }

  return (
    <div className="flex flex-col gap-3">
      <div className="flex items-center justify-between gap-4">
        <p className="text-sm text-muted-foreground">{t('admin.vietqr.accounts.help')}</p>
        <Button size="sm" onClick={() => setEditing('new')}>
          {t('admin.vietqr.accounts.add')}
        </Button>
      </div>
      <Table>
        <TableHeader>
          <TableHeaderRow>
            <TableHead>{t('admin.vietqr.fields.bank')}</TableHead>
            <TableHead>{t('admin.vietqr.fields.account_number')}</TableHead>
            <TableHead>{t('admin.vietqr.fields.account_name')}</TableHead>
            <TableHead>{t('admin.vietqr.fields.provider')}</TableHead>
            <TableHead>{t('admin.vietqr.fields.period_confirmed')}</TableHead>
            <TableHead>{t('admin.vietqr.fields.active')}</TableHead>
            <TableHead />
          </TableHeaderRow>
        </TableHeader>
        <TableBody>
          {accounts.map((account) => (
            <TableRow
              key={account.id}
              className="cursor-pointer"
              onClick={() => setEditing(account)}
            >
              <TableCell>{account.bank_name ?? account.bank_bin}</TableCell>
              <TableCell className="font-mono">{account.account_number}</TableCell>
              <TableCell>{account.account_name}</TableCell>
              <TableCell>{t(`admin.vietqr.providers.${account.provider}`)}</TableCell>
              <TableCell>
                {formatAmount(account.period_confirmed_amount)}
                {account.monthly_quota_amount != null && (
                  <span className="text-muted-foreground">
                    {' '}
                    / {formatAmount(account.monthly_quota_amount)}
                  </span>
                )}
              </TableCell>
              <TableCell>
                <ActiveBadge active={account.active} />
              </TableCell>
              <TableCell onClick={(event) => event.stopPropagation()}>
                <RowActions
                  actions={[
                    { key: 'edit', onSelect: () => setEditing(account) },
                    {
                      key: 'delete',
                      destructive: true,
                      disabled: deleteMutation.isPending,
                      onSelect: () => handleDelete(account),
                    },
                  ]}
                />
              </TableCell>
            </TableRow>
          ))}
          {!isLoading && accounts.length === 0 && (
            <TableRow>
              <TableCell colSpan={7} className="py-8 text-center text-muted-foreground">
                {t('admin.vietqr.accounts.empty')}
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>

      {editing && (
        <ReceivingAccountSheet
          paymentMethodId={paymentMethodId}
          account={editing === 'new' ? null : editing}
          onClose={() => setEditing(null)}
        />
      )}
    </div>
  )
}

function ReceivingAccountSheet({
  paymentMethodId,
  account,
  onClose,
}: {
  paymentMethodId: string
  account: VietqrReceivingAccount | null
  onClose: () => void
}) {
  const { t } = useTranslation()
  const createMutation = useCreateVietqrReceivingAccount(paymentMethodId)
  const updateMutation = useUpdateVietqrReceivingAccount(account?.id ?? '')
  const form = useForm<VietqrReceivingAccountFormValues>({
    defaultValues: account ? receivingAccountToForm(account) : EMPTY_RECEIVING_ACCOUNT,
  })

  async function onSubmit(values: VietqrReceivingAccountFormValues) {
    try {
      const payload = receivingAccountPayload(values)
      if (account) await updateMutation.mutateAsync(payload)
      else await createMutation.mutateAsync(payload)
      onClose()
    } catch (err) {
      if (!mapSpreeErrorsToForm(err, form.setError)) throw err
    }
  }

  return (
    <Sheet open onOpenChange={(open) => !open && onClose()}>
      <SheetContent>
        <SheetHeader>
          <SheetTitle>
            {account ? account.account_number : t('admin.vietqr.accounts.add')}
          </SheetTitle>
          <SheetDescription>{t('admin.vietqr.accounts.sheet_description')}</SheetDescription>
        </SheetHeader>
        <form onSubmit={form.handleSubmit(onSubmit)} className="flex min-h-0 flex-1 flex-col">
          <div className="flex flex-1 flex-col gap-4 overflow-y-auto p-4">
            <ReceivingAccountFields form={form} webhookUrl={account?.webhook_url ?? null} />
          </div>
          <SheetFooter>
            <Button
              type="button"
              variant="outline"
              onClick={onClose}
              disabled={form.formState.isSubmitting}
            >
              {t('admin.actions.cancel')}
            </Button>
            <Button type="submit" disabled={form.formState.isSubmitting}>
              {form.formState.isSubmitting ? t('admin.actions.saving') : t('admin.actions.save')}
            </Button>
          </SheetFooter>
        </form>
      </SheetContent>
    </Sheet>
  )
}

function TextField({
  form,
  name,
  required,
  inputMode,
  help,
}: {
  form: UseFormReturn<VietqrReceivingAccountFormValues>
  name: keyof VietqrReceivingAccountFormValues
  required?: boolean
  inputMode?: 'numeric'
  help?: string
}) {
  const { t } = useTranslation()
  const error = form.formState.errors[name]
  return (
    <Field>
      <FieldLabel htmlFor={`vietqr-${name}`}>{t(`admin.vietqr.fields.${name}`)}</FieldLabel>
      <Input
        id={`vietqr-${name}`}
        inputMode={inputMode}
        autoComplete="off"
        aria-invalid={!!error || undefined}
        {...form.register(
          name,
          required ? { required: t('admin.vietqr.validation.required') } : {},
        )}
      />
      {help && <FieldDescription>{help}</FieldDescription>}
      <FieldError errors={[error]} />
    </Field>
  )
}

function ReceivingAccountFields({
  form,
  webhookUrl,
}: {
  form: UseFormReturn<VietqrReceivingAccountFormValues>
  webhookUrl: string | null
}) {
  const { t } = useTranslation()
  const { data: banks = [] } = useVietqrBanks()
  const provider = form.watch('provider')
  const { errors } = form.formState

  return (
    <FieldGroup>
      {errors.root?.message && (
        <p className="text-sm text-destructive" role="alert">
          {errors.root.message}
        </p>
      )}
      <Field>
        <FieldLabel htmlFor="vietqr-provider">{t('admin.vietqr.fields.provider')}</FieldLabel>
        <Controller
          name="provider"
          control={form.control}
          render={({ field }) => (
            <Select value={field.value} onValueChange={(value) => field.onChange(value)}>
              <SelectTrigger id="vietqr-provider">
                <SelectValue>
                  {(value) => t(`admin.vietqr.providers.${value as string}`)}
                </SelectValue>
              </SelectTrigger>
              <SelectContent>
                {VIETQR_PROVIDERS.map((value) => (
                  <SelectItem key={value} value={value}>
                    {t(`admin.vietqr.providers.${value}`)}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          )}
        />
        <FieldDescription>{t(`admin.vietqr.provider_help.${provider}`)}</FieldDescription>
      </Field>

      {webhookUrl && provider !== 'manual' && (
        <Field>
          <FieldLabel>{t('admin.vietqr.fields.webhook_url')}</FieldLabel>
          <div className="flex items-center gap-2 rounded-md border bg-muted/30 px-3 py-2 font-mono text-xs">
            <span className="flex-1 break-all">{webhookUrl}</span>
            <CopyToClipboardButton
              value={webhookUrl}
              aria-label={t('admin.vietqr.fields.webhook_url')}
            />
          </div>
        </Field>
      )}

      <Field>
        <FieldLabel htmlFor="vietqr-bank_bin">{t('admin.vietqr.fields.bank')}</FieldLabel>
        <Controller
          name="bank_bin"
          control={form.control}
          rules={{ required: t('admin.vietqr.validation.required') }}
          render={({ field }) => (
            <Select
              value={field.value}
              onValueChange={(value) => {
                field.onChange(value)
                const bank = banks.find((item) => item.bin === value)
                if (bank) form.setValue('bank_name', bank.name, { shouldDirty: true })
              }}
            >
              <SelectTrigger id="vietqr-bank_bin" aria-invalid={!!errors.bank_bin || undefined}>
                <SelectValue placeholder={t('admin.vietqr.fields.bank_placeholder')}>
                  {(value) => {
                    const bank = banks.find((item) => item.bin === value)
                    return bank ? `${bank.name} (${bank.bin})` : (value as string)
                  }}
                </SelectValue>
              </SelectTrigger>
              <SelectContent>
                {banks.map((bank) => (
                  <SelectItem key={bank.bin} value={bank.bin}>
                    {bank.name} ({bank.bin})
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>
          )}
        />
        <FieldError errors={[errors.bank_bin]} />
      </Field>

      <TextField form={form} name="account_number" required inputMode="numeric" />
      <TextField
        form={form}
        name="account_name"
        required
        help={t('admin.vietqr.help.account_name')}
      />
      <TextField form={form} name="keyword_init" help={t('admin.vietqr.help.keyword_init')} />

      {provider === 'sepay' && (
        <>
          <TextField form={form} name="sub_account" help={t('admin.vietqr.help.sub_account')} />
          <TextField form={form} name="virtual_account_number" />
        </>
      )}
      {provider === 'payos' && <TextField form={form} name="payos_client_id" required />}

      {secretFieldsFor(provider).map((name) => (
        <Controller
          key={name}
          name={name}
          control={form.control}
          render={({ field }) => (
            <SecretInput
              id={`vietqr-${name}`}
              label={t(`admin.vietqr.fields.${name}`)}
              value={field.value}
              onChange={(value) => field.onChange(String(value ?? ''))}
            />
          )}
        />
      ))}

      <div className="grid grid-cols-2 gap-4">
        <TextField
          form={form}
          name="priority"
          inputMode="numeric"
          help={t('admin.vietqr.help.priority')}
        />
        <TextField
          form={form}
          name="routing_weight"
          inputMode="numeric"
          help={t('admin.vietqr.help.routing_weight')}
        />
        <TextField
          form={form}
          name="monthly_quota_amount"
          inputMode="numeric"
          help={t('admin.vietqr.help.monthly_quota')}
        />
        <TextField
          form={form}
          name="monthly_threshold_amount"
          inputMode="numeric"
          help={t('admin.vietqr.help.monthly_threshold')}
        />
      </div>

      <Field orientation="horizontal">
        <Controller
          name="active"
          control={form.control}
          render={({ field }) => (
            <Switch
              id="vietqr-active"
              checked={field.value}
              onCheckedChange={(checked) => field.onChange(checked)}
            />
          )}
        />
        <FieldLabel htmlFor="vietqr-active">{t('admin.vietqr.fields.active')}</FieldLabel>
      </Field>
    </FieldGroup>
  )
}

// --- Bank webhooks ----------------------------------------------------------

const EVENT_TONES: Record<string, 'success' | 'warning' | 'destructive' | 'neutral'> = {
  confirmed: 'success',
  duplicate: 'neutral',
  unmatched: 'warning',
  rejected: 'destructive',
  error: 'destructive',
}

function WebhookEventStatus({ status }: { status: string }) {
  const { t } = useTranslation()
  return (
    <StatusBadge
      status={status}
      tone={EVENT_TONES[status]}
      label={t(`admin.vietqr.events.statuses.${status}`)}
    />
  )
}

function WebhookEventsPanel() {
  const { t } = useTranslation()
  const [status, setStatus] = useState('all')
  const [query, setQuery] = useState('')
  const [page, setPage] = useState(1)
  const [openId, setOpenId] = useState<string>()
  const { data, isFetching } = useVietqrWebhookEvents({ status, q: query.trim(), page })
  const events = data?.data ?? []
  const pages = data?.meta.pages ?? 1

  return (
    <div className="flex flex-col gap-3">
      <div className="flex flex-wrap items-center gap-2">
        <Input
          className="w-72"
          value={query}
          placeholder={t('admin.vietqr.events.search_placeholder')}
          onChange={(event) => {
            setQuery(event.target.value)
            setPage(1)
          }}
        />
        <Select
          value={status}
          onValueChange={(value) => {
            setStatus(value as string)
            setPage(1)
          }}
        >
          <SelectTrigger className="w-48" aria-label={t('admin.vietqr.fields.status')}>
            <SelectValue>
              {(value) =>
                value === 'all'
                  ? t('admin.vietqr.events.all_statuses')
                  : t(`admin.vietqr.events.statuses.${value as string}`)
              }
            </SelectValue>
          </SelectTrigger>
          <SelectContent>
            <SelectItem value="all">{t('admin.vietqr.events.all_statuses')}</SelectItem>
            {VIETQR_WEBHOOK_STATUSES.map((value) => (
              <SelectItem key={value} value={value}>
                {t(`admin.vietqr.events.statuses.${value}`)}
              </SelectItem>
            ))}
          </SelectContent>
        </Select>
      </div>

      <Table>
        <TableHeader>
          <TableHeaderRow>
            <TableHead>{t('admin.vietqr.fields.received_at')}</TableHead>
            <TableHead>{t('admin.vietqr.fields.provider')}</TableHead>
            <TableHead>{t('admin.vietqr.fields.amount')}</TableHead>
            <TableHead>{t('admin.vietqr.fields.order')}</TableHead>
            <TableHead>{t('admin.vietqr.fields.transaction')}</TableHead>
            <TableHead>{t('admin.vietqr.fields.status')}</TableHead>
          </TableHeaderRow>
        </TableHeader>
        <TableBody>
          {events.map((event) => (
            <TableRow key={event.id} className="cursor-pointer" onClick={() => setOpenId(event.id)}>
              <TableCell>
                <RelativeTime iso={event.created_at} />
              </TableCell>
              <TableCell>
                {t(`admin.vietqr.providers.${event.provider}`, { defaultValue: event.provider })}
              </TableCell>
              <TableCell>{formatAmount(event.amount)}</TableCell>
              <TableCell>{event.matched_order_number ?? event.parsed_order_code ?? '—'}</TableCell>
              <TableCell className="font-mono text-xs">
                {event.provider_transaction_id ?? '—'}
              </TableCell>
              <TableCell>
                <WebhookEventStatus status={event.status} />
              </TableCell>
            </TableRow>
          ))}
          {!isFetching && events.length === 0 && (
            <TableRow>
              <TableCell colSpan={6} className="py-8 text-center text-muted-foreground">
                {t('admin.vietqr.events.empty')}
              </TableCell>
            </TableRow>
          )}
        </TableBody>
      </Table>

      {pages > 1 && (
        <div className="flex items-center justify-end gap-2 text-sm">
          <Button
            size="sm"
            variant="outline"
            disabled={page <= 1}
            onClick={() => setPage(page - 1)}
          >
            {t('admin.vietqr.events.previous')}
          </Button>
          <span>{t('admin.vietqr.events.page', { page, pages })}</span>
          <Button
            size="sm"
            variant="outline"
            disabled={page >= pages}
            onClick={() => setPage(page + 1)}
          >
            {t('admin.vietqr.events.next')}
          </Button>
        </div>
      )}

      {openId && <WebhookEventSheet id={openId} onClose={() => setOpenId(undefined)} />}
    </div>
  )
}

function WebhookEventSheet({ id, onClose }: { id: string; onClose: () => void }) {
  const { t } = useTranslation()
  const { data: event, isLoading } = useVietqrWebhookEvent(id)

  return (
    <Sheet open onOpenChange={(open) => !open && onClose()}>
      <SheetContent>
        <SheetHeader>
          <SheetTitle>{t('admin.vietqr.events.detail_title')}</SheetTitle>
          <SheetDescription>{event?.provider_transaction_id ?? id}</SheetDescription>
        </SheetHeader>
        {isLoading || !event ? (
          <div className="p-4 text-sm text-muted-foreground">{t('admin.common.loading')}</div>
        ) : (
          <div className="flex flex-1 flex-col gap-4 overflow-y-auto p-4 text-sm">
            <dl className="grid grid-cols-[auto_1fr] gap-x-4 gap-y-2">
              <dt className="text-muted-foreground">{t('admin.vietqr.fields.status')}</dt>
              <dd>
                <WebhookEventStatus status={event.status} />
              </dd>
              <dt className="text-muted-foreground">{t('admin.vietqr.fields.amount')}</dt>
              <dd>{formatAmount(event.amount)}</dd>
              <dt className="text-muted-foreground">{t('admin.vietqr.fields.account_number')}</dt>
              <dd className="font-mono">{event.account_number ?? '—'}</dd>
              <dt className="text-muted-foreground">{t('admin.vietqr.fields.order')}</dt>
              <dd>{event.matched_order_number ?? event.parsed_order_code ?? '—'}</dd>
              {event.error_message && (
                <>
                  <dt className="text-muted-foreground">{t('admin.vietqr.fields.error')}</dt>
                  <dd className="text-destructive">{event.error_message}</dd>
                </>
              )}
            </dl>
            {isResolvableWebhookEvent(event) && <ResolveWebhookEvent event={event} />}
            {event.raw_payload && (
              <details>
                <summary className="cursor-pointer text-muted-foreground">
                  {t('admin.vietqr.events.payload')}
                </summary>
                <pre className="mt-2 overflow-x-auto rounded-md bg-muted/40 p-3 text-xs">
                  {JSON.stringify(event.raw_payload, null, 2)}
                </pre>
              </details>
            )}
          </div>
        )}
      </SheetContent>
    </Sheet>
  )
}

function ResolveWebhookEvent({ event }: { event: VietqrWebhookEvent }) {
  const { t } = useTranslation()
  const [orderNumber, setOrderNumber] = useState('')
  const match = useManualMatchVietqrWebhookEvent(event.id)
  const retry = useRetryVietqrWebhookEvent(event.id)
  const busy = match.isPending || retry.isPending

  return (
    <div className="flex flex-col gap-3 rounded-md border p-3">
      <p className="font-medium">{t('admin.vietqr.events.resolve_title')}</p>
      <p className="text-muted-foreground">{t('admin.vietqr.events.resolve_help')}</p>
      <div className="flex gap-2">
        <Input
          value={orderNumber}
          placeholder={t('admin.vietqr.events.order_number_placeholder')}
          onChange={(e) => setOrderNumber(e.target.value)}
        />
        <Button
          disabled={busy || orderNumber.trim() === ''}
          onClick={() => match.mutateAsync(orderNumber.trim()).catch(() => undefined)}
        >
          {t('admin.vietqr.events.match')}
        </Button>
      </div>
      <Button
        variant="outline"
        disabled={busy}
        onClick={() => retry.mutateAsync().catch(() => undefined)}
      >
        {t('admin.vietqr.events.retry')}
      </Button>
    </div>
  )
}
