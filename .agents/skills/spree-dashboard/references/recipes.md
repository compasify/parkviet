# Dashboard recipes

Worked examples for the most common extension shapes. All code lives in the host dashboard app (`apps/dashboard/src/…`) and imports from `@spree/dashboard`. In a distributed plugin, swap the import for `@spree/dashboard-core` / `@spree/dashboard-ui` (see the `spree-dashboard-plugins` skill). Strings are hardcoded here for brevity; real code routes every visible string through i18next.

## 1. Page action button (+ dropdown item)

`page.actions` and `page.actions_dropdown` render on every page that uses `<PageHeader>`, so the component must decide whether it applies.

```tsx
// src/slots/send-invoice-button.tsx
import { Button, adminClient, usePermissions, useResourceMutation } from '@spree/dashboard'
import { Send } from 'lucide-react'

export function SendInvoiceButton({ resource }: { resource?: { id: string; status?: string } }) {
  const { permissions } = usePermissions()
  const mutation = useResourceMutation({
    mutationFn: () => adminClient.request('POST', `/orders/${resource!.id}/send_invoice`),
    successMessage: 'Invoice sent',
    invalidate: [['orders']],
  })

  if (!resource?.id?.startsWith('or_')) return null          // only on order pages
  if (resource.status !== 'placed') return null                // resource-state gate
  if (!permissions.can('update', 'Spree::Order')) return null  // UX gate — API still authorizes

  return (
    <Button variant="outline" size="sm" onClick={() => mutation.mutate()} disabled={mutation.isPending}>
      <Send className="size-4" /> Send invoice
    </Button>
  )
}
```

```tsx
// src/slots/sync-to-erp-item.tsx — secondary action in the ⋯ menu
import { DropdownMenuItem, adminClient, useResourceMutation } from '@spree/dashboard'

export function SyncToErpItem({ resource }: { resource?: { id: string } }) {
  const mutation = useResourceMutation({
    mutationFn: () => adminClient.request('POST', `/orders/${resource!.id}/sync_to_erp`),
    successMessage: 'Synced',
  })
  if (!resource?.id?.startsWith('or_')) return null
  return (
    <DropdownMenuItem
      onClick={() => mutation.mutate()}  // Base UI Menu.Item: onClick (add closeOnClick={false} to keep the menu open)
      disabled={mutation.isPending}
    >
      Sync to ERP
    </DropdownMenuItem>
  )
}
```

```ts
// src/plugins.ts
defineDashboardPlugin({
  slots: {
    'page.actions': [{ id: 'send-invoice', component: SendInvoiceButton as never, position: 50 }],
    'page.actions_dropdown': [{ id: 'sync-to-erp', component: SyncToErpItem as never, position: 50 }],
  },
})
```

For destructive or expensive actions, confirm first: `const confirm = useConfirm()` then `if (await confirm({ message: 'Reset this cart?', variant: 'destructive' })) mutation.mutate()` — or wrap in a `<Dialog>`.

The `/orders/:id/send_invoice` endpoint is yours to add on the Rails side (custom Admin API controller — see `spree-resource` / `spree-api-v3`), including its permission check.

## 2. Sidebar widget that fetches its own data

```tsx
// src/hooks/use-loyalty.ts — components never call adminClient directly
import { adminClient, useResourceKey } from '@spree/dashboard'
import { useQuery } from '@tanstack/react-query'

export interface LoyaltyRecord { points: number; tier: 'bronze' | 'silver' | 'gold' }

export function useLoyalty(customerId: string, enabled: boolean) {
  return useQuery({
    queryKey: useResourceKey('loyalty', customerId),   // store-scoped key
    queryFn: () => adminClient.request<{ data: LoyaltyRecord | null }>('GET', `/customers/${customerId}/loyalty`),
    staleTime: 30_000,
    enabled,
  })
}
```

```tsx
// src/slots/customer-loyalty-card.tsx
import { Badge, Card, CardContent, CardHeader, CardTitle, Empty, EmptyDescription, Skeleton, usePermissions } from '@spree/dashboard'
import { useLoyalty } from '../hooks/use-loyalty'

export function CustomerLoyaltyCard({ customer }: { customer: { id: string } }) {
  const { permissions } = usePermissions()
  const canRead = permissions.can('read', 'MyApp::LoyaltyRecord')
  const { data, isLoading } = useLoyalty(customer.id, canRead)
  if (!canRead) return null

  return (
    <Card>
      <CardHeader><CardTitle>Loyalty</CardTitle></CardHeader>
      <CardContent>
        {isLoading ? <Skeleton className="h-8 w-32" />
          : !data?.data ? <Empty><EmptyDescription>Not enrolled</EmptyDescription></Empty>
          : <><Badge>{data.data.tier}</Badge> <p className="text-sm text-muted-foreground">{data.data.points} points</p></>}
      </CardContent>
    </Card>
  )
}
```

```ts
defineDashboardPlugin({
  slots: { 'customer.form_sidebar': [{ id: 'loyalty', component: CustomerLoyaltyCard as never, position: 50 }] },
})
```

- Three states (loading / empty / loaded) — "0 points" and "never enrolled" mean different things.
- If the host serializer already includes the data (`customer.tags`), read it from the slot props instead of fetching.
- `MyApp::LoyaltyRecord` resolves in `permissions.can` only once the backend registers a permission scope for it (`Spree.permissions.register_scope`, see `spree-auth-permissions`).

## 3. Custom form field

### Path A — custom field definition (no code)

Define it as data (Settings → Custom fields, or the API); the product form's Custom Fields card renders and saves it:

```bash
spree api post custom_field_definitions --data '{
  "resource_type": "Spree::Product", "namespace": "specs", "key": "tech_specs",
  "label": "Technical specifications", "field_type": "long_text"
}'
```

Field types: `short_text`, `long_text`, `rich_text`, `number`, `boolean`, `json`. Replace the widget for one definition, keyed `namespace.key`:

```tsx
import { type CustomFieldComponentProps, defineDashboardPlugin } from '@spree/dashboard'

function ColorInput({ id, value, onChange, ariaLabel }: CustomFieldComponentProps) {
  return <input id={id} type="color" aria-label={ariaLabel}
    value={(value as string) || '#000000'} onChange={(e) => onChange(e.target.value)} />
}

defineDashboardPlugin({ customFieldComponents: { 'specs.color': ColorInput } })
```

The component is controlled (`value` / `onChange`; also receives `definition`). Persistence stays with the card.

### Path B — a real column (extension form field)

Backend: column + serializer attribute + `additional_permitted_attributes` (see the end-to-end section in SKILL.md). Frontend:

```tsx
// src/slots/tech-specs-card.tsx
import { Card, CardContent, CardHeader, CardTitle, Field, FieldError, FieldLabel, Textarea, useHostForm } from '@spree/dashboard'

export function TechSpecsCard() {
  const form = useHostForm<{ tech_specs: string }>()
  const error = form.formState.errors.tech_specs?.message
  return (
    <Card>
      <CardHeader><CardTitle>Tech specs</CardTitle></CardHeader>
      <CardContent>
        <Field>
          <FieldLabel className="sr-only" htmlFor="tech_specs">Tech specs</FieldLabel>
          <Textarea id="tech_specs" rows={6} aria-invalid={Boolean(error)} {...form.register('tech_specs')} />
          {error && <FieldError>{error as string}</FieldError>}
        </Field>
      </CardContent>
    </Card>
  )
}
```

```ts
defineDashboardPlugin({
  formFields: { product: [{ name: 'tech_specs', from: (product) => product?.tech_specs ?? '' }] },
  slots: { 'product.form_sidebar': [{ id: 'tech-specs', component: TechSpecsCard as never, position: 80 }] },
})
```

`from` receives the fetched record, or `null` on the create form — return the blank value. `name` must equal both the serializer attribute and the permitted param. Rails validations are authoritative: a 422 lands inline on the field automatically.

Host forms exist on `product`, `category`, `collection` and `store` (keys match the `formFields` form key). Order/customer pages have none — use `useOptionalHostForm()` and save through your own `useResourceMutation`.

| Situation | Path |
|---|---|
| Merchant-defined attribute, no migration wanted, default widget OK | A |
| Needs Ransack filter/sort, DB constraints, indexes, or lives in your own card | B |

## 4. A custom list page for your own resource

```tsx
// src/tables/brands.tsx
import { RelativeTime, defineTable, i18n } from '@spree/dashboard'
import type { Brand } from '../types'

defineTable<Brand>('brands', {
  title: i18n.t('admin.brands.table.title'),
  searchParam: 'search',
  defaultSort: { field: 'name', direction: 'asc' },
  emptyMessage: i18n.t('admin.brands.table.empty'),
  columns: [
    { key: 'name', label: i18n.t('admin.brands.fields.name'), sortable: true, filterable: true, default: true },
    { key: 'created_at', label: i18n.t('admin.brands.fields.created_at'), sortable: true, default: true,
      render: (b) => <RelativeTime iso={b.created_at} /> },
  ],
})
```

```tsx
// src/pages/brands.tsx
import { PageHeader, ResourceLayout, ResourceTable, type ResourceSearch, adminClient } from '@spree/dashboard'
import type { PaginatedResponse } from '@spree/admin-sdk'
import type { Brand } from '../types'

export function BrandsPage({ searchParams }: { searchParams: Record<string, unknown> }) {
  return (
    <ResourceLayout
      header={<PageHeader title="Brands" />}
      main={
        <ResourceTable<Brand>
          tableKey="brands"
          queryKey="brands"
          queryFn={(params) => adminClient.request<PaginatedResponse<Brand>>('GET', '/brands', { params: params as never })}
          searchParams={searchParams as ResourceSearch}
        />
      }
    />
  )
}
```

```ts
// src/plugins.ts
import './tables/brands'
defineDashboardPlugin({
  nav: { addChildren: { products: [{ key: 'products.brands', labelKey: 'admin.brands.nav', path: '/brands', subject: 'Spree::Brand' }] } },
  routes: [{ key: 'brands', path: '/brands', component: BrandsPage, subject: 'Spree::Brand' }],
})
```

Every `sortable` / `filterable` column must be in the model's Ransack allowlist (`whitelisted_ransackable_attributes`) or the request fails. `bulkActions` and `rowActions` are props on `<ResourceTable>` — available on your own pages, not injectable into built-in tables.
