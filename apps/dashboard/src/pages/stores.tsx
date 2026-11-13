// Settings → Stores: every store the signed-in admin can manage, and opening
// a new one — a restaurant beside a retail shop, each with its own catalog,
// orders and settings. Switching between them is the sidebar store switcher.
import {
  Button,
  Can,
  Field,
  FieldDescription,
  FieldError,
  FieldLabel,
  Input,
  i18n,
  mapSpreeErrorsToForm,
  ResourceTable,
  RowActions,
  resourceSearchSchema,
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
  Subject,
  useAuth,
  useRowClickBridge,
  useStore,
} from '@spree/dashboard'
import { ArrowLeftRightIcon, PlusIcon } from '@spree/dashboard-ui/icons'
import { useNavigate } from '@tanstack/react-router'
import { useMemo, useState } from 'react'
import { Controller, type UseFormReturn, useForm } from 'react-hook-form'
import { useTranslation } from 'react-i18next'
import { useCountryCodes, useCreateStore } from '../hooks/use-stores'
import {
  EMPTY_NEW_STORE,
  type NewStoreFormValues,
  newStorePayload,
  pageStores,
} from '../schemas/store'

export function StoresPage({ searchParams = {} }: { searchParams?: Record<string, unknown> }) {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const { user } = useAuth()
  const { store: currentStore } = useStore()
  const [creating, setCreating] = useState(false)
  const rows = (user?.stores ?? []).map((store) => ({
    ...store,
    current: store.id === currentStore?.id,
  }))
  const search = resourceSearchSchema.parse(searchParams)

  function openStore(id: string) {
    navigate({ to: `/${id}` as never })
  }

  useRowClickBridge('data-store-id', openStore)

  return (
    <>
      <ResourceTable
        tableKey="stores"
        queryKey={[
          'managed-stores',
          rows.map((row) => `${row.id}:${row.name}:${row.current}`).join('|'),
        ]}
        queryFn={(params) => Promise.resolve(pageStores(rows, params))}
        searchParams={search}
        rowActions={(store) => (
          <RowActions
            actions={[
              {
                key: 'switch',
                label: t('admin.multi_store.switch'),
                icon: <ArrowLeftRightIcon className="size-4" />,
                visible: store.id !== currentStore?.id,
                onSelect: () => openStore(store.id),
              },
            ]}
          />
        )}
        actions={
          <Can I="update" a={Subject.Store}>
            <Button size="sm" className="h-[2.125rem]" onClick={() => setCreating(true)}>
              <PlusIcon className="size-4" />
              {t('admin.multi_store.add')}
            </Button>
          </Can>
        }
      />
      {creating && <NewStoreSheet onClose={() => setCreating(false)} />}
    </>
  )
}

function NewStoreSheet({ onClose }: { onClose: () => void }) {
  const { t } = useTranslation()
  const navigate = useNavigate()
  const createStore = useCreateStore()
  const form = useForm<NewStoreFormValues>({ defaultValues: EMPTY_NEW_STORE })

  async function onSubmit(values: NewStoreFormValues) {
    try {
      const created = await createStore.mutateAsync(newStorePayload(values))
      onClose()
      navigate({ to: `/${created.id}` as never })
    } catch (err) {
      if (!mapSpreeErrorsToForm(err, form.setError)) throw err
    }
  }

  return (
    <Sheet open onOpenChange={(open) => !open && onClose()}>
      <SheetContent>
        <SheetHeader>
          <SheetTitle>{t('admin.multi_store.add')}</SheetTitle>
          <SheetDescription>{t('admin.multi_store.sheet_description')}</SheetDescription>
        </SheetHeader>
        <form onSubmit={form.handleSubmit(onSubmit)} className="flex min-h-0 flex-1 flex-col">
          <div className="flex flex-1 flex-col gap-4 overflow-y-auto p-4">
            <TextField form={form} name="name" required />
            <CountryField form={form} />
            <TextField
              form={form}
              name="mail_from_address"
              help={t('admin.multi_store.help.copied_from_current')}
            />
            <TextField
              form={form}
              name="customer_support_email"
              help={t('admin.multi_store.help.copied_from_current')}
            />
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
              {form.formState.isSubmitting
                ? t('admin.multi_store.creating')
                : t('admin.multi_store.create')}
            </Button>
          </SheetFooter>
        </form>
      </SheetContent>
    </Sheet>
  )
}

function CountryField({ form }: { form: UseFormReturn<NewStoreFormValues> }) {
  const { t } = useTranslation()
  const { data: codes = [] } = useCountryCodes()
  const countries = useMemo(() => {
    const names = new Intl.DisplayNames([i18n.language], { type: 'region' })
    return codes
      .map((code) => ({ value: code, label: names.of(code) ?? code }))
      .sort((a, b) => a.label.localeCompare(b.label))
  }, [codes])
  const error = form.formState.errors.country_code

  return (
    <Field>
      <FieldLabel htmlFor="store-country_code">
        {t('admin.multi_store.fields.country_code')}
      </FieldLabel>
      <Controller
        control={form.control}
        name="country_code"
        render={({ field }) => (
          <Select value={field.value} onValueChange={(value) => field.onChange(value as string)}>
            <SelectTrigger id="store-country_code" aria-invalid={!!error || undefined}>
              <SelectValue>
                {(value) => countries.find((country) => country.value === value)?.label ?? value}
              </SelectValue>
            </SelectTrigger>
            <SelectContent>
              {countries.map((country) => (
                <SelectItem key={country.value} value={country.value}>
                  {country.label}
                </SelectItem>
              ))}
            </SelectContent>
          </Select>
        )}
      />
      <FieldDescription>{t('admin.multi_store.help.country')}</FieldDescription>
      <FieldError errors={[error]} />
    </Field>
  )
}

function TextField({
  form,
  name,
  required,
  help,
}: {
  form: UseFormReturn<NewStoreFormValues>
  name: 'name' | 'mail_from_address' | 'customer_support_email'
  required?: boolean
  help?: string
}) {
  const { t } = useTranslation()
  const error = form.formState.errors[name]
  return (
    <Field>
      <FieldLabel htmlFor={`store-${name}`}>{t(`admin.multi_store.fields.${name}`)}</FieldLabel>
      <Input
        id={`store-${name}`}
        type={name === 'name' ? 'text' : 'email'}
        autoComplete="off"
        aria-invalid={!!error || undefined}
        {...form.register(
          name,
          required ? { required: t('admin.multi_store.validation.required') } : {},
        )}
      />
      {help && <FieldDescription>{help}</FieldDescription>}
      <FieldError errors={[error]} />
    </Field>
  )
}
