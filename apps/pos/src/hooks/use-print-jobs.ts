import type { Printer, PrinterRole, PrintJob } from '@parkviet/pos-shared/types/print-adapter';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { useMemo } from 'react';
import { session } from '../lib/app-session';
import { BROWSER_ROUTE, choosePrintRoute, openPrintJobs } from '../lib/print-adapters';
import { pollInterval } from '../lib/realtime';
import { useRealtimeStatus } from './use-branch-events';
import { useSession } from './use-session';
import { abandonIfNeeded } from './use-tenders';

const QUEUE_POLL_MS = 15_000;
const PREBILL_REPRINT_ACTION = 'workspace.reprint_prebill';
const OPEN_STATUSES = 'queued,claimed,failed';
const APPROVAL_TTL_MS = 30 * 60_000;
const PAGE_LIMIT = '100';

async function read<T>(path: string, params: Record<string, string | undefined>): Promise<T> {
  try {
    return await session.request<T>('GET', path, { params });
  } catch (error) {
    abandonIfNeeded(error);
    throw error;
  }
}

// Every page: a failure stays until someone deals with it, however old it is.
async function readAllJobs(path: string, params: Record<string, string | undefined>) {
  const jobs: PrintJob[] = [];
  let page: number | null | undefined = 1;
  while (page) {
    const result: { data: PrintJob[]; meta?: { next?: number | null } } = await read(path, {
      ...params,
      limit: PAGE_LIMIT,
      page: String(page),
    });
    jobs.push(...result.data);
    page = result.meta?.next;
  }
  return jobs;
}

// The printer a document of this role goes to. While the catalogue is unknown
// or cannot be read, printing stays with the browser.
export function usePrintRoute(
  branchId: string | null,
  registerId: string | null,
  role: PrinterRole,
) {
  const snapshot = useSession();
  const printers = useQuery({
    queryKey: ['pos', 'printers', snapshot.generation, branchId],
    enabled: snapshot.status === 'authenticated' && Boolean(branchId),
    retry: false,
    staleTime: 60_000,
    queryFn: async () =>
      (await read<{ data: Printer[] }>('/pos/printers', { branch_id: branchId ?? undefined })).data,
  });
  const route = useMemo(
    () => (printers.data ? choosePrintRoute(printers.data, role, registerId) : BROWSER_ROUTE),
    [printers.data, role, registerId],
  );
  return { route, loading: printers.isLoading };
}

// `print_job.created` announces enqueues, requeues and failures, and
// `resource.updated` claims, prints and cancels, so every transition reaches
// this query and the poll may stretch while the stream is connected.
export function usePrintJobs(branchId: string | null) {
  const snapshot = useSession();
  const status = useRealtimeStatus();
  return useQuery({
    queryKey: ['pos', 'print-jobs', snapshot.generation, branchId],
    enabled: snapshot.status === 'authenticated' && Boolean(branchId),
    retry: false,
    refetchInterval: pollInterval(status, QUEUE_POLL_MS),
    queryFn: async () =>
      openPrintJobs(
        await readAllJobs('/pos/print_jobs', {
          branch_id: branchId ?? undefined,
          status: OPEN_STATUSES,
        }),
      ),
  });
}

// The printed pre-bills of open orders, for a reprint. The same events cover
// them, and `approval.requested` announces a granted approval.
export function usePrintedPrebills(branchId: string | null) {
  const snapshot = useSession();
  const status = useRealtimeStatus();
  return useQuery({
    queryKey: ['pos', 'print-jobs', snapshot.generation, branchId, 'prebills'],
    enabled: snapshot.status === 'authenticated' && Boolean(branchId),
    retry: false,
    refetchInterval: pollInterval(status, QUEUE_POLL_MS),
    queryFn: () =>
      readAllJobs('/pos/print_jobs/prebills', {
        branch_id: branchId ?? undefined,
      }),
  });
}

// A manager lets the person working the order reprint its pre-bill once, for
// the order as it stands now.
export function useGrantPrebillReprint() {
  const snapshot = useSession();
  const client = useQueryClient();
  return useMutation({
    mutationFn: async (job: PrintJob) =>
      session.request('POST', '/pos/approvals', {
        body: {
          branch_id: job.branch_id,
          workspace_id: job.workspace_id,
          requester_id: job.reprint?.requester_id,
          revision: job.reprint?.workspace_revision,
          action_name: PREBILL_REPRINT_ACTION,
          expires_at: new Date(Date.now() + APPROVAL_TTL_MS).toISOString(),
        },
      }),
    onSettled: () =>
      client.invalidateQueries({ queryKey: ['pos', 'print-jobs', snapshot.generation] }),
  });
}

export function usePrintJobAction() {
  const snapshot = useSession();
  const client = useQueryClient();
  return useMutation({
    mutationFn: async ({
      job,
      action,
      approvalId,
    }: {
      job: PrintJob;
      action: 'reprint' | 'cancel';
      approvalId?: string;
    }) => {
      const idempotencyKey = crypto.randomUUID();
      return session.request('POST', `/pos/print_jobs/${job.id}/${action}`, {
        body: approvalId ? { approval_id: approvalId } : {},
        idempotencyKey,
      });
    },
    onSettled: () =>
      client.invalidateQueries({ queryKey: ['pos', 'print-jobs', snapshot.generation] }),
  });
}
