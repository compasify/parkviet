import { defineTable, i18n, ResourceNameCell } from '@spree/dashboard'
import { ActiveBadge } from '@spree/dashboard-ui'
import { Building2Icon } from '@spree/dashboard-ui/icons'
import type { StoreRow } from '../schemas/store'

// Registered from plugins.ts, after this app's translations are merged in.
// A label read at import time would still be the untranslated key.
export function registerStoresTable() {
  defineTable<StoreRow>('stores', {
    title: i18n.t('admin.multi_store.title'),
    description: i18n.t('admin.multi_store.subtitle'),
    searchParam: 'q',
    searchPlaceholder: i18n.t('admin.multi_store.search_placeholder'),
    defaultSort: { field: 'name', direction: 'asc' },
    emptyIcon: <Building2Icon className="size-8 text-muted-foreground" />,
    emptyMessage: i18n.t('admin.multi_store.empty'),
    columns: [
      {
        key: 'name',
        label: i18n.t('admin.multi_store.fields.name'),
        sortable: true,
        filterable: true,
        filterType: 'string',
        default: true,
        render: (store) => (
          <ResourceNameCell id={store.id} dataAttr="data-store-id" name={store.name} />
        ),
      },
      {
        key: 'code',
        label: i18n.t('admin.multi_store.fields.code'),
        sortable: true,
        filterable: true,
        filterType: 'string',
        default: true,
        render: (store) => <span className="text-muted-foreground">{store.code}</span>,
      },
      {
        key: 'current',
        label: i18n.t('admin.multi_store.current'),
        default: true,
        render: (store) => (
          <ActiveBadge
            active={store.current}
            activeLabel={i18n.t('admin.multi_store.current')}
            dashWhenInactive
          />
        ),
      },
    ],
  })
}
