import { PageHeader } from '@spree/dashboard-core'
import { Badge, Button } from '@spree/dashboard-ui'
import { FileTextIcon, SettingsIcon } from '@spree/dashboard-ui/icons'
import { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { ModelCard } from '../components/setup/model-ui'
import { Input, TopologyField, TopologySelect } from '../components/topology-fields'
import {
  type EinvoiceSample,
  type EinvoiceSetting,
  type EinvoiceSettingInput,
  type EinvoiceType,
  useEinvoiceSample,
  useEinvoiceSettings,
  useSaveEinvoiceSettings,
} from '../hooks/use-einvoices'
import { usePosSession } from '../hooks/use-pos-session'
import { einvoiceFailure } from '../lib/einvoice-failure'

type Notice = { text: string; failed: boolean } | null

const TEXT_FIELDS = [
  'template_code',
  'symbol',
  'seller_name',
  'seller_tax_code',
  'seller_address',
  'consumer_label',
  'lookup_url',
] as const
type TextField = (typeof TEXT_FIELDS)[number]
type Form = Record<TextField, string> & {
  provider: string
  status: 'active' | 'disabled'
  buyer_link_hours: string
}

function formOf(setting: EinvoiceSetting | undefined, provider: string): Form {
  return {
    provider: setting?.provider ?? provider,
    status: setting?.status ?? 'active',
    buyer_link_hours: setting?.buyer_link_hours ? String(setting.buyer_link_hours) : '',
    ...(Object.fromEntries(TEXT_FIELDS.map((key) => [key, setting?.[key] ?? ''])) as Record<
      TextField,
      string
    >),
  }
}

// "Hóa đơn điện tử" for store administrators: which invoice the store issues,
// the provider and its credentials (write-only), the symbol and seller details,
// for the store and, where a branch differs, for that branch. Only providers
// with an adapter on the server are offered.
export function EinvoiceSettingsPage() {
  const { t } = useTranslation()
  const { context } = usePosSession()
  const settings = useEinvoiceSettings()
  const save = useSaveEinvoiceSettings()
  const sample = useEinvoiceSample()
  const [notice, setNotice] = useState<Notice>(null)
  const [scope, setScope] = useState('')
  const [type, setType] = useState<EinvoiceType>('none')
  const [form, setForm] = useState<Form | null>(null)
  const [credentials, setCredentials] = useState<Record<string, string>>({})
  const [result, setResult] = useState<EinvoiceSample | null>(null)
  const data = settings.data
  const current = data?.settings.find((row) => (row.branch_id ?? '') === scope)

  useEffect(() => {
    if (!data) return
    setType(data.einvoice_type)
  }, [data])
  useEffect(() => {
    if (!data) return
    setForm(formOf(current, data.providers[0]?.key ?? ''))
    setCredentials({})
    setResult(null)
  }, [data, current])

  if (settings.isPending) return <p role="status">{t('contextWaiting')}</p>
  if (settings.isError)
    return (
      <p role="alert" className="text-destructive">
        {einvoiceFailure(settings.error, t)}
      </p>
    )
  if (!data || !form) return null

  const provider = data.providers.find((row) => row.key === form.provider)
  const branches = context.data?.branches ?? []
  const set = (key: keyof Form, value: string) => setForm({ ...form, [key]: value })

  async function run(action: () => Promise<unknown>, message = t('saved')) {
    setNotice(null)
    try {
      await action()
      setNotice({ text: message, failed: false })
    } catch (failure) {
      setNotice({ text: einvoiceFailure(failure, t), failed: true })
    }
  }

  function saveSetting() {
    if (!form) return
    const setting: EinvoiceSettingInput = {
      provider: form.provider,
      status: form.status,
      buyer_link_hours: form.buyer_link_hours ? Number(form.buyer_link_hours) : null,
      ...Object.fromEntries(TEXT_FIELDS.map((key) => [key, form[key].trim() || null])),
    }
    const filled = Object.fromEntries(
      Object.entries(credentials).filter(([, value]) => value.trim() !== ''),
    )
    if (Object.keys(filled).length > 0) setting.credentials = filled
    return run(() =>
      save
        .mutateAsync({ setting, ...(scope ? { branch_id: scope } : {}) })
        .then(() => setCredentials({})),
    )
  }

  return (
    <div className="space-y-6">
      <PageHeader title={t('einvoiceSettings.title')} description={t('einvoiceSettings.intro')} />
      {notice && (
        <p
          role={notice.failed ? 'alert' : 'status'}
          className={notice.failed ? 'text-destructive' : 'text-muted-foreground'}
        >
          {notice.text}
        </p>
      )}
      <ModelCard title={t('einvoiceSettings.typeTitle')} id="einvoice-type" icon={<FileTextIcon />}>
        <div className="flex flex-wrap items-end gap-3">
          <div className="w-72">
            <TopologyField
              label={t('einvoiceSettings.type')}
              hint={t(`einvoiceSettings.typeHint_${type}`)}
            >
              {(id, describedBy) => (
                <TopologySelect
                  id={id}
                  describedBy={describedBy}
                  value={type}
                  onChange={(value) => setType(value as EinvoiceType)}
                  options={(['none', 'cash_register', 'coded'] as const).map((value) => ({
                    value,
                    label: t(`einvoiceSettings.type_${value}`),
                  }))}
                />
              )}
            </TopologyField>
          </div>
          <Button
            type="button"
            disabled={save.isPending || type === data.einvoice_type}
            onClick={() => void run(() => save.mutateAsync({ einvoice_type: type }))}
          >
            {t('save')}
          </Button>
        </div>
      </ModelCard>
      <ModelCard
        title={t('einvoiceSettings.providerTitle')}
        id="einvoice-provider"
        icon={<SettingsIcon />}
      >
        {!data.public_link && (
          <p className="text-sm text-muted-foreground">{t('einvoiceSettings.noPublicLink')}</p>
        )}
        <div className="grid gap-4 md:grid-cols-2">
          <TopologyField label={t('einvoiceSettings.scope')}>
            {(id) => (
              <TopologySelect
                id={id}
                value={scope}
                onChange={setScope}
                options={[
                  { value: '', label: t('einvoiceSettings.scopeStore') },
                  ...branches.map((branch) => ({ value: branch.id, label: branch.name })),
                ]}
              />
            )}
          </TopologyField>
          <TopologyField label={t('einvoiceSettings.provider')}>
            {(id) => (
              <TopologySelect
                id={id}
                value={form.provider}
                onChange={(value) => set('provider', value)}
                options={data.providers.map((row) => ({
                  value: row.key,
                  label: row.sandbox
                    ? `${row.label} (${t('einvoiceSettings.sandbox')})`
                    : row.label,
                }))}
              />
            )}
          </TopologyField>
          {(provider?.credential_fields ?? []).map((field) => (
            <TopologyField
              key={field}
              label={field}
              hint={
                current?.credential_fields.includes(field)
                  ? t('einvoiceSettings.credentialStored')
                  : undefined
              }
            >
              {(id, describedBy) => (
                <Input
                  id={id}
                  type="password"
                  autoComplete="new-password"
                  aria-describedby={describedBy}
                  value={credentials[field] ?? ''}
                  onChange={(event) =>
                    setCredentials({ ...credentials, [field]: event.target.value })
                  }
                />
              )}
            </TopologyField>
          ))}
          {TEXT_FIELDS.map((field) => (
            <TopologyField
              key={field}
              label={t(`einvoices.field_${field}`)}
              hint={t(`einvoiceSettings.hint_${field}`, { defaultValue: '' }) || undefined}
            >
              {(id, describedBy) => (
                <Input
                  id={id}
                  aria-describedby={describedBy}
                  value={form[field]}
                  onChange={(event) => set(field, event.target.value)}
                />
              )}
            </TopologyField>
          ))}
          <TopologyField
            label={t('einvoices.field_buyer_link_hours')}
            hint={t('einvoiceSettings.hint_buyer_link_hours')}
          >
            {(id, describedBy) => (
              <Input
                id={id}
                inputMode="numeric"
                aria-describedby={describedBy}
                value={form.buyer_link_hours}
                onChange={(event) => set('buyer_link_hours', event.target.value.trim())}
              />
            )}
          </TopologyField>
          <TopologyField label={t('einvoiceSettings.status')}>
            {(id) => (
              <TopologySelect
                id={id}
                value={form.status}
                onChange={(value) => set('status', value)}
                options={[
                  { value: 'active', label: t('einvoiceSettings.status_active') },
                  { value: 'disabled', label: t('einvoiceSettings.status_disabled') },
                ]}
              />
            )}
          </TopologyField>
        </div>
        <div className="flex flex-wrap items-center gap-2">
          <Button
            type="button"
            disabled={save.isPending || !form.provider}
            onClick={() => void saveSetting()}
          >
            {t('save')}
          </Button>
          {provider?.sandbox && current && (
            <Button
              type="button"
              variant="outline"
              disabled={sample.isPending}
              onClick={() =>
                void run(async () => {
                  const response = await sample.mutateAsync(scope ? { branch_id: scope } : {})
                  setResult(response.data)
                }, t('einvoiceSettings.sampleDone'))
              }
            >
              {t('einvoiceSettings.sample')}
            </Button>
          )}
          {current && (
            <Badge variant="outline">{t(`einvoiceSettings.status_${current.status}`)}</Badge>
          )}
        </div>
        {result && (
          <dl className="grid grid-cols-[max-content_1fr] gap-x-4 gap-y-1 text-sm">
            <dt className="text-muted-foreground">{t('einvoices.number')}</dt>
            <dd>
              {result.template_code}
              {result.symbol} · {result.number}
            </dd>
            <dt className="text-muted-foreground">{t('einvoices.lookupCode')}</dt>
            <dd className="break-all">{result.lookup_code}</dd>
          </dl>
        )}
      </ModelCard>
    </div>
  )
}
