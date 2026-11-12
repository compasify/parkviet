import type { ExportRequest, ReportPage } from '@parkviet/pos-shared/reports'
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query'
import { posRequest as request } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'
import { type PosReportType, type ReportFilters, reportView } from '../lib/report-table'
import { useSession } from './use-session'

export type ReportResult = ReportPage & { view: string }

// One page of a server report. Filters only travel as query parameters; the
// server allowlists and scopes them. `view` names the report and section the
// rows belong to, so rows kept while the next query loads are never shown
// under another report's columns.
export function reportQuery(
  storeId: string,
  type: PosReportType,
  branchId: string,
  filters: ReportFilters,
  page: number,
  limit: number,
) {
  return {
    queryKey: posKey(storeId, 'reports', type, branchId, filters, page, limit),
    queryFn: async (): Promise<ReportResult> => ({
      ...(await request<ReportPage>('GET', `/pos/reports/${type}`, {
        params: { branch_id: branchId, page: String(page), limit: String(limit), ...filters },
      })),
      view: reportView(type, filters),
    }),
  }
}

export function useReport(
  type: PosReportType,
  branchId: string,
  filters: ReportFilters,
  page: number,
  limit: number,
  enabled: boolean,
) {
  const { storeId, status } = useSession()
  const view = reportView(type, filters)
  return useQuery({
    ...reportQuery(storeId, type, branchId, filters, page, limit),
    enabled: enabled && status === 'authenticated',
    placeholderData: (previous) => (previous?.view === view ? previous : undefined),
  })
}

// The reader's own exports of the branch, polled while one is being made.
export function useExports(branchId: string, enabled: boolean) {
  const { storeId, status } = useSession()
  return useQuery({
    queryKey: posKey(storeId, 'exports', branchId),
    enabled: enabled && status === 'authenticated',
    refetchInterval: (query) =>
      query.state.data?.data.some((row) => row.status === 'queued' || row.status === 'processing')
        ? 3000
        : false,
    queryFn: () =>
      request<{ data: ExportRequest[] }>('GET', '/pos/exports', {
        params: { branch_id: branchId, limit: '10' },
      }),
  })
}

function post<T>(path: string, body: Record<string, unknown>) {
  const key = crypto.randomUUID()
  return request<T>('POST', path, {
    body: { ...body, idempotency_key: key },
    idempotencyKey: key,
  })
}

export function useCreateExport() {
  const { storeId } = useSession()
  const client = useQueryClient()
  return useMutation({
    mutationFn: (input: { branchId: string; type: PosReportType; filters: ReportFilters }) =>
      post<{ data: ExportRequest }>('/pos/exports', {
        branch_id: input.branchId,
        report_type: input.type,
        filters: input.filters,
      }),
    onSettled: () => client.invalidateQueries({ queryKey: ['pos', storeId, 'exports'] }),
  })
}

// The server re-authorizes and returns a one-minute signed link; the browser
// then downloads the file directly (streamed, never held in page memory).
export async function exportDownloadLink(id: string) {
  return (
    await post<{ data: { url: string; filename: string; expires_at: string } }>(
      `/pos/exports/${id}/download_link`,
      {},
    )
  ).data
}
