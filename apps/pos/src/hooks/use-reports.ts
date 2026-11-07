import { keepPreviousData, useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import type { ExportRequest, ReportPage, ReportType } from '../lib/shifts';
import { useSession } from './use-session';
import { abandonIfNeeded } from './use-tenders';

export type ReportFilters = Record<string, string>;

async function request<T>(
  method: 'GET' | 'POST',
  path: string,
  options?: { params?: Record<string, string | undefined>; body?: Record<string, unknown> },
): Promise<T> {
  const key = method === 'POST' ? crypto.randomUUID() : undefined;
  try {
    return await session.request<T>(method, path, {
      params: options?.params,
      body: options?.body && key ? { ...options.body, idempotency_key: key } : undefined,
      idempotencyKey: key,
    });
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

// Filters only travel as query parameters; the server allowlists and scopes them.
export function useReport(
  type: ReportType,
  branchId: string | null,
  filters: ReportFilters,
  page: number,
  enabled: boolean,
) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'report', snapshot.generation, type, branchId, filters, page],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    placeholderData: keepPreviousData,
    // `view` names the report and section the rows belong to, so rows kept
    // while the next query loads are never shown under another report's columns.
    queryFn: async () => ({
      ...(await request<ReportPage>('GET', `/pos/reports/${type}`, {
        params: { branch_id: branchId ?? undefined, page: String(page), limit: '50', ...filters },
      })),
      view: `${type}:${filters.section ?? ''}`,
    }),
  });
}

export function useExports(branchId: string | null, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: ['pos', 'exports', snapshot.generation, branchId],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId),
    refetchInterval: (query) =>
      query.state.data?.data.some((row) => row.status === 'queued' || row.status === 'processing')
        ? 3000
        : false,
    queryFn: () =>
      request<{ data: ExportRequest[] }>('GET', '/pos/exports', {
        params: { branch_id: branchId ?? undefined, limit: '10' },
      }),
  });
}

export function useCreateExport() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (input: { branchId: string; type: ReportType; filters: ReportFilters }) =>
      request<{ data: ExportRequest }>('POST', '/pos/exports', {
        body: { branch_id: input.branchId, report_type: input.type, filters: input.filters },
      }),
    onSettled: () => queryClient.invalidateQueries({ queryKey: ['pos', 'exports'] }),
  });
}

// The server re-authorizes and returns a one-minute signed link; the browser
// then downloads the file directly (streamed, never held in page memory).
export async function exportDownloadLink(id: string) {
  return (
    await request<{ data: { url: string; filename: string; expires_at: string } }>(
      'POST',
      `/pos/exports/${id}/download_link`,
      { body: {} },
    )
  ).data;
}
