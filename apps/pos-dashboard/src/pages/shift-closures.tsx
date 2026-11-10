import { formatMoney } from '@parkviet/pos-shared/money'
import { describeShiftFailure } from '@parkviet/pos-shared/shifts'
import { defineTable, ResourceTable } from '@spree/dashboard-core'
import {
  ResourceNameCell,
  RowActions,
  Sheet,
  SheetContent,
  SheetHeader,
  SheetTitle,
  useRowClickBridge,
} from '@spree/dashboard-ui'
import { useNavigate, useSearch } from '@tanstack/react-router'
import { useCallback } from 'react'
import { useTranslation } from 'react-i18next'
import { ClosureSnapshot, VarianceText } from '../components/shift-close-dialog'
import { usePosSession } from '../hooks/use-pos-session'
import { type ClosureRow, fetchClosures, useShiftCloseState } from '../hooks/use-shifts'
import { branchTimeZone, formatInstant } from '../lib/format-time'
import { closureSearchSchema } from '../schemas/list-search'
import { hiddenTimestamps } from '../tables/columns'
import { ShiftsFrame } from './shifts'

// Closed shifts of the branch by close time (today unless a date range is
// chosen), each with its immutable snapshot.
export function ShiftClosuresPage() {
  const { t } = useTranslation()
  return (
    <ShiftsFrame title={t('shiftClosuresTitle')} description={t('shiftClosuresHint')}>
      {(branchId) => <Closures branchId={branchId} />}
    </ShiftsFrame>
  )
}

function Closures({ branchId }: { branchId: string }) {
  const { t, i18n } = useTranslation()
  const { context } = usePosSession()
  const navigate = useNavigate()
  const search = closureSearchSchema.parse(useSearch({ strict: false }))
  const timeZone = branchTimeZone(context.data)
  const open = useCallback(
    (shiftId: string) =>
      void navigate({
        to: '.',
        search: (previous: Record<string, unknown>) => ({ ...previous, shiftId }),
      }),
    [navigate],
  )
  useRowClickBridge('data-pos-shift-id', open)

  const tableKey = 'pos-shift-closures'
  defineTable<ClosureRow & { id: string }>(tableKey, {
    searchParam: 'search',
    searchPlaceholder: t('shiftClosuresSearch'),
    defaultSort: { field: 'closed_at', direction: 'desc' },
    emptyMessage: t('shiftClosuresEmpty'),
    columns: [
      {
        key: 'cashier',
        label: t('shiftOwner'),
        default: true,
        sortable: false,
        render: (row) => (
          <ResourceNameCell
            id={row.shift_id}
            dataAttr="data-pos-shift-id"
            name={row.cashier}
            secondary={row.register ?? t('shiftNoRegister')}
          />
        ),
      },
      {
        key: 'closed_at',
        label: t('shiftClosedAt'),
        default: true,
        sortable: false,
        filterable: true,
        filterType: 'date',
        quickFilter: true,
        className: 'whitespace-nowrap',
        render: (row) => formatInstant(row.closed_at, i18n.language, timeZone),
      },
      {
        key: 'expected',
        label: t('shiftExpected'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (row) => formatMoney(row.expected, row.currency),
      },
      {
        key: 'counted',
        label: t('shiftCounted'),
        default: true,
        sortable: false,
        className: 'text-right tabular-nums',
        render: (row) => formatMoney(row.counted, row.currency),
      },
      {
        key: 'variance',
        label: t('shiftVarianceLabel'),
        default: true,
        sortable: false,
        render: (row) => <VarianceText variance={row.variance} currency={row.currency} />,
      },
      {
        key: 'approver',
        label: t('shiftApprovedBy'),
        default: false,
        sortable: false,
        render: (row) => row.approver ?? '—',
      },
      ...hiddenTimestamps<ClosureRow & { id: string }>(),
    ],
  })

  return (
    <>
      <ResourceTable<ClosureRow & { id: string }>
        tableKey={tableKey}
        hideHeader
        queryKey={['pos', 'shift-close', 'closures', branchId]}
        queryFn={async (params: Record<string, unknown>) => {
          const page = await fetchClosures(branchId, params)
          // The report has no text search: the box narrows the loaded page.
          const term = String(params.search ?? '')
            .trim()
            .toLocaleLowerCase()
          const rows = page.data
            .map((row) => ({ ...row, id: row.closure_id }))
            .filter(
              (row) =>
                !term || [row.cashier, row.register].join(' ').toLocaleLowerCase().includes(term),
            )
          return { ...page, data: rows }
        }}
        searchParams={search}
        rowActions={(row) => (
          <RowActions
            actions={[
              { key: 'view', label: t('shiftClosureView'), onSelect: () => open(row.shift_id) },
            ]}
          />
        )}
      />
      {search.shiftId && (
        <ClosureSheet
          key={search.shiftId}
          shiftId={search.shiftId}
          timeZone={timeZone}
          onClose={() =>
            void navigate({
              to: '.',
              search: (previous: Record<string, unknown>) => ({ ...previous, shiftId: undefined }),
            })
          }
        />
      )}
    </>
  )
}

function ClosureSheet({
  shiftId,
  timeZone,
  onClose,
}: {
  shiftId: string
  timeZone: string
  onClose: () => void
}) {
  const { t } = useTranslation()
  const state = useShiftCloseState(shiftId)
  return (
    <Sheet
      open
      onOpenChange={(open) => {
        if (!open) onClose()
      }}
    >
      <SheetContent className="overflow-y-auto">
        <SheetHeader>
          <SheetTitle>{t('shiftClosureView')}</SheetTitle>
        </SheetHeader>
        <div className="px-4 pb-6">
          {state.isError ? (
            <p role="alert">{describeShiftFailure(state.error, t)}</p>
          ) : !state.data ? (
            <p role="status">{t('waiting')}</p>
          ) : state.data.closure ? (
            <ClosureSnapshot closure={state.data.closure} timeZone={timeZone} />
          ) : (
            <p role="alert">{t('missing')}</p>
          )}
        </div>
      </SheetContent>
    </Sheet>
  )
}
