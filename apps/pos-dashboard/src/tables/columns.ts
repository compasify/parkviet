import type { ColumnDef } from '@spree/dashboard-core'

// POS records carry no timestamps, so the created/updated columns ResourceTable
// adds by default would only ever show dashes and filter nothing.
export const hiddenTimestamps = <T>(): ColumnDef<T>[] =>
  ['created_at', 'updated_at'].map((key) => ({
    key,
    label: '',
    displayable: false,
    filterable: false,
    sortable: false,
  }))
