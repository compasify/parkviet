import {
  Table as DataTable,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@spree/dashboard-ui'
import type { ReactNode } from 'react'

// The installed dashboard-ui exports the table primitive as Table, not DataTable.
export function TopologyTable<T extends { id: string }>({
  label,
  columns,
  rows,
  busy,
}: {
  label: string
  columns: { label: string; cell: (row: T) => ReactNode }[]
  rows: T[]
  busy?: boolean
}) {
  return (
    <DataTable scrollX aria-label={label} aria-busy={busy}>
      <TableHeader>
        <TableRow>
          {columns.map((column) => (
            <TableHead key={column.label}>{column.label}</TableHead>
          ))}
        </TableRow>
      </TableHeader>
      <TableBody>
        {rows.map((row) => (
          <TableRow key={row.id}>
            {columns.map((column) => (
              <TableCell className="whitespace-normal align-top" key={column.label}>
                {column.cell(row)}
              </TableCell>
            ))}
          </TableRow>
        ))}
      </TableBody>
    </DataTable>
  )
}
