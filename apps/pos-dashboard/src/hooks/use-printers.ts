import type { PrintJobDocument } from '@parkviet/pos-shared/receipt-template/types'
import type { Printer, PrintJob } from '@parkviet/pos-shared/types/print-adapter'
import { useResourceMutation } from '@spree/dashboard-core'
import { useQuery, useQueryClient } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { useSession } from './use-session'

export type PrintStation = { id: string; name: string }
export type PrinterTestResult = { print_job: PrintJob | null; document: PrintJobDocument | null }

export function usePrinters(branchId: string) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'printers', branchId),
    queryFn: async () =>
      (
        await posRequest<{ data: Printer[] }>('GET', '/pos/printers', {
          params: { branch_id: branchId },
        })
      ).data,
  })
}

export function usePrintStations(branchId: string, enabled: boolean) {
  const { storeId } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'print-stations', branchId),
    enabled,
    queryFn: async () =>
      (
        await posRequest<{ data: PrintStation[] }>('GET', '/pos/printers/stations', {
          params: { branch_id: branchId },
        })
      ).data,
  })
}

// Every printer write is a command with its own idempotency key.
export function usePrinterWrite() {
  const client = useQueryClient()
  const { storeId } = useSession()
  return useResourceMutation({
    mutationFn: ({ method, path, body }: { method: string; path: string; body?: unknown }) =>
      posRequest<{ data: unknown }>(method, path, {
        body: body ?? {},
        idempotencyKey: crypto.randomUUID(),
      }),
    successMessage: false,
    errorMessage: false,
    onSuccess: () => client.invalidateQueries({ queryKey: posKey(storeId, 'printers') }),
  })
}
