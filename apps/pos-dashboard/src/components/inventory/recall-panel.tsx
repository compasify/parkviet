import {
  describeInventoryFailure,
  formatExpiry,
  type RecallSale,
} from '@parkviet/pos-shared/traceability'
import { defineTable, ResourceTable, resourceSearchSchema } from '@spree/dashboard-core'
import {
  Badge,
  Button,
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
  ResourceNameCell,
} from '@spree/dashboard-ui'
import { SearchIcon } from '@spree/dashboard-ui/icons'
import { useQueryClient } from '@tanstack/react-query'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { useState } from 'react'
import { useTranslation } from 'react-i18next'
import { fetchRecall, type RecallQuery, recallKey, useRecall } from '../../hooks/use-inventory'
import { useSession } from '../../hooks/use-session'
import { formatInstant } from '../../lib/format-time'
import { hiddenTimestamps } from '../../tables/columns'
import { quantity, tableMeta, variantLabel } from './inventory-helpers'
import { ChoiceField, Expiry, type InventoryScope, TextField } from './inventory-shared'

type SaleRow = RecallSale & { id: string }

// Where a lot or serial went: stock still holding it and the sales that took
// it, with customers masked by the server.
export function RecallPanel({ scope }: { scope: InventoryScope }) {
  const { t } = useTranslation()
  const [kind, setKind] = useState<RecallQuery['kind']>('lot_code')
  const [value, setValue] = useState('')
  const [query, setQuery] = useState<RecallQuery | null>(null)
  const recall = useRecall(query)
  const navigate = useNavigate()
  const result = recall.data?.data
  return (
    <div className="space-y-4">
      <Card>
        <CardHeader>
          <CardTitle>{t('inventoryTab_recall')}</CardTitle>
          <CardDescription>{t('inventoryRecallHint')}</CardDescription>
        </CardHeader>
        <CardContent>
          <form
            className="grid items-end gap-3 sm:grid-cols-[12rem_1fr_auto]"
            aria-label={t('inventoryTab_recall')}
            onSubmit={(event) => {
              event.preventDefault()
              const text = value.trim()
              setQuery(text ? { kind, value: text } : null)
              // A new search starts the sales from their first page.
              void navigate({
                to: '.',
                search: (previous: Record<string, unknown>) => ({ ...previous, page: 1 }),
              })
            }}
          >
            <ChoiceField
              label={t('inventoryRecallBy')}
              value={kind}
              onChange={(next) => setKind(next === 'serial' ? 'serial' : 'lot_code')}
              options={[
                { value: 'lot_code', label: t('inventoryLotCode') },
                { value: 'serial', label: t('inventorySerial') },
              ]}
            />
            <TextField
              label={t('inventoryRecallValue')}
              value={value}
              maxLength={100}
              onChange={setValue}
            />
            <Button type="submit">
              <SearchIcon className="size-4" />
              {t('inventorySearch')}
            </Button>
          </form>
        </CardContent>
      </Card>
      {query && recall.isPending && (
        <p role="status" className="text-sm text-muted-foreground">
          {t('waiting')}
        </p>
      )}
      {recall.isError && (
        <p role="alert" className="text-sm text-destructive">
          {describeInventoryFailure(recall.error, t)}
        </p>
      )}
      {query && result && (
        <div className="space-y-4" aria-live="polite">
          {recall.data?.meta.truncated && (
            <p className="rounded-md border border-warning-border bg-warning-bg p-2 text-sm">
              {t('inventoryRecallTruncated')}
            </p>
          )}
          <Card>
            <CardHeader>
              <CardTitle>{t('inventoryRecallStock')}</CardTitle>
            </CardHeader>
            <CardContent className="space-y-3">
              {result.lots.length === 0 && result.serial_units.length === 0 && (
                <p className="text-sm text-muted-foreground">{t('inventoryEmpty')}</p>
              )}
              {result.lots.length > 0 && (
                <ul
                  className="divide-y rounded-md border text-sm"
                  aria-label={t('inventoryRecallLots')}
                >
                  {result.lots.map((lot) => (
                    <li key={lot.id} className="flex flex-wrap items-center gap-x-4 gap-y-1 p-3">
                      <span className="font-medium">{lot.lot_code}</span>
                      <span>{variantLabel(lot)}</span>
                      <Expiry value={lot.expiry_on} today={scope.today} />
                      <span>
                        {t('inventoryOnHand')}: {quantity(lot.on_hand, lot.base_unit)}
                      </span>
                      <Badge variant="secondary">{t(`inventoryLotStatus_${lot.status}`)}</Badge>
                    </li>
                  ))}
                </ul>
              )}
              {result.serial_units.length > 0 && (
                <ul
                  className="divide-y rounded-md border text-sm"
                  aria-label={t('inventoryRecallSerials')}
                >
                  {result.serial_units.map((unit) => (
                    <li key={unit.id} className="flex flex-wrap items-center gap-x-4 gap-y-1 p-3">
                      <span className="font-medium">{unit.serial}</span>
                      <span>{variantLabel(unit)}</span>
                      <Badge variant="secondary">{t(`inventorySerialStatus_${unit.status}`)}</Badge>
                    </li>
                  ))}
                </ul>
              )}
            </CardContent>
          </Card>
          <section aria-label={t('inventoryRecallSales')} className="space-y-2">
            <h3 className="font-medium">{t('inventoryRecallSales')}</h3>
            <RecallSales key={`${query.kind}:${query.value}`} scope={scope} query={query} />
          </section>
        </div>
      )}
    </div>
  )
}

function RecallSales({ scope, query }: { scope: InventoryScope; query: RecallQuery }) {
  const { t, i18n } = useTranslation()
  const { storeId } = useSession()
  const client = useQueryClient()
  const search = resourceSearchSchema.parse(useSearch({ strict: false }))

  const tableKey = 'pos-inventory-recall-sales'
  defineTable<SaleRow>(tableKey, {
    searchParam: 'search',
    emptyMessage: t('inventoryRecallNoSales'),
    columns: [
      {
        key: 'order_number',
        label: t('inventoryRecallOrder'),
        default: true,
        sortable: false,
        render: (sale) => <ResourceNameCell id={sale.order_id} name={sale.order_number} />,
      },
      { key: 'branch_name', label: t('inventoryRecallBranch'), default: true, sortable: false },
      {
        key: 'sold_at',
        label: t('inventoryRecallSoldAt'),
        default: true,
        sortable: false,
        className: 'whitespace-nowrap',
        render: (sale) => formatInstant(sale.sold_at, i18n.language, scope.timeZone),
      },
      {
        key: 'name',
        label: t('orderLineItem'),
        default: true,
        sortable: false,
        render: (sale) => (sale.sku ? `${sale.name} · ${sale.sku}` : sale.name),
      },
      {
        key: 'trace',
        label: t('inventoryRecallTrace'),
        default: true,
        sortable: false,
        render: (sale) =>
          sale.serial ??
          (sale.lot_code
            ? `${sale.lot_code} · ${t('inventoryExpiryShort')} ${formatExpiry(sale.expiry_on)}`
            : '—'),
      },
      {
        key: 'quantity',
        label: t('inventoryRecallQuantity'),
        default: true,
        sortable: false,
        render: (sale) =>
          t('inventoryRecallReturned', {
            quantity: quantity(sale.quantity, sale.base_unit),
            returned: quantity(sale.returned_quantity, sale.base_unit),
          }),
      },
      {
        key: 'customer',
        label: t('inventoryRecallCustomer'),
        default: true,
        sortable: false,
        render: (sale) =>
          sale.customer
            ? `${sale.customer.name}${sale.customer.phone ? ` · ${sale.customer.phone}` : ''}`
            : t('inventoryRecallWalkIn'),
      },
      ...hiddenTimestamps<SaleRow>(),
    ],
  })

  return (
    <ResourceTable<SaleRow>
      tableKey={tableKey}
      hideHeader
      queryKey={['pos', 'inventory', 'recall', query, 'sales']}
      queryFn={async (params: Record<string, unknown>) => {
        const page = Math.max(1, Number(params.page) || 1)
        // Shares the cache of the stock summary, which reads the first page.
        const answer = await client.fetchQuery({
          queryKey: recallKey(storeId, query, page),
          queryFn: () => fetchRecall(query, page),
          staleTime: 10_000,
        })
        const rows = answer.data.sales.map((sale) => ({
          ...sale,
          id: `${sale.sale_line_id}:${sale.lot_code ?? ''}:${sale.serial ?? ''}`,
        }))
        return { data: rows, meta: tableMeta(answer.meta, rows.length, 50) }
      }}
      searchParams={{ ...search, limit: 50 }}
    />
  )
}
