import { useInfiniteQuery, useQuery } from '@tanstack/react-query';
import { session } from '../lib/app-session';
import type { ReceiptSnapshot } from '../lib/print-adapter';
import { queryClient } from '../lib/query-client';
import type { DocumentType, PaperSize, TemplateConfig } from '../lib/receipt-template/types';
import { posFailureKey } from '../lib/request-failure';
import { SessionSuperseded } from '../lib/session-coordinator';
import { useSession } from './use-session';

// The store's print templates (`/pos/receipt_templates`). Every save on the
// server adds an immutable version; edits carry the version they started
// from and a stale one is refused with a 409.

export type ReceiptTemplate = {
  id: string;
  document_type: DocumentType;
  name: string;
  paper: PaperSize;
  status: 'active' | 'disabled';
  is_default: boolean;
  current_version: number;
  // The version `config` belongs to.
  version: number;
  config: TemplateConfig;
  updated_by: { id: string; name: string } | null;
  created_at: string;
  updated_at: string;
};

export type ReceiptTemplateVersion = {
  version: number;
  config: TemplateConfig;
  created_at: string;
  created_by: { id: string; name: string } | null;
};

export const RECEIPT_TEMPLATES_KEY = ['pos', 'receipt-templates'] as const;

async function request<T>(
  method: string,
  path: string,
  options?: { body?: unknown; params?: Record<string, string | undefined> },
): Promise<T> {
  try {
    return await session.request<T>(method, path, options);
  } catch (error) {
    if (!(error instanceof SessionSuperseded) && posFailureKey(error) === 'unauthorized')
      session.abandon();
    throw error;
  }
}

// Every template of the store; disabled ones only for administrators.
export function useReceiptTemplates(enabled: boolean, includeDisabled = false) {
  const snapshot = useSession();
  return useQuery({
    queryKey: [...RECEIPT_TEMPLATES_KEY, 'list', snapshot.generation, includeDisabled],
    enabled: enabled && snapshot.status === 'authenticated',
    queryFn: async () =>
      (
        await request<{ data: ReceiptTemplate[] }>('GET', '/pos/receipt_templates', {
          params: { include_disabled: includeDisabled ? '1' : undefined },
        })
      ).data,
  });
}

export function useReceiptTemplate(id: string, enabled: boolean) {
  const snapshot = useSession();
  return useQuery({
    queryKey: [...RECEIPT_TEMPLATES_KEY, 'detail', snapshot.generation, id],
    enabled: enabled && snapshot.status === 'authenticated' && id !== '',
    queryFn: async () =>
      (await request<{ data: ReceiptTemplate }>('GET', `/pos/receipt_templates/${id}`)).data,
  });
}

export const VERSIONS_PAGE_SIZE = 10;

// The saved versions of a template, newest first, a page at a time (needs
// the write permission). Each entry carries its config, so pages stay small.
export function useReceiptTemplateVersions(id: string, enabled: boolean) {
  const snapshot = useSession();
  return useInfiniteQuery({
    queryKey: [...RECEIPT_TEMPLATES_KEY, 'versions', snapshot.generation, id],
    enabled: enabled && snapshot.status === 'authenticated' && id !== '',
    initialPageParam: 1,
    queryFn: ({ pageParam }) =>
      request<{ data: ReceiptTemplateVersion[]; meta?: { next: number | null } }>(
        'GET',
        `/pos/receipt_templates/${id}/versions`,
        { params: { limit: String(VERSIONS_PAGE_SIZE), page: String(pageParam) } },
      ),
    getNextPageParam: (last) => last.meta?.next ?? undefined,
  });
}

// The newest posted receipt of a document type at a branch, to preview a
// template with real content. Null when the branch has none.
export function useLatestReceipt(
  branchId: string | null,
  sourceType: ReceiptSnapshot['source_type'] | null,
  enabled: boolean,
) {
  const snapshot = useSession();
  return useQuery({
    queryKey: [...RECEIPT_TEMPLATES_KEY, 'latest', snapshot.generation, branchId, sourceType],
    enabled: enabled && snapshot.status === 'authenticated' && Boolean(branchId && sourceType),
    retry: false,
    queryFn: async () =>
      (
        await request<{ data: ReceiptSnapshot[] }>('GET', '/pos/receipts', {
          params: {
            branch_id: branchId ?? undefined,
            source_type: sourceType ?? undefined,
            limit: '1',
          },
        })
      ).data[0] ?? null,
  });
}

export const refreshReceiptTemplates = () =>
  queryClient.invalidateQueries({ queryKey: RECEIPT_TEMPLATES_KEY });

type Saved = { data: ReceiptTemplate };

export function createReceiptTemplate(body: {
  from_default: DocumentType;
  name: string;
  paper: PaperSize;
}) {
  return request<Saved>('POST', '/pos/receipt_templates', { body });
}

export function updateReceiptTemplate(
  id: string,
  body: { expected_version: number; name: string; paper: PaperSize; config: TemplateConfig },
) {
  return request<Saved>('PATCH', `/pos/receipt_templates/${id}`, { body });
}

export function duplicateReceiptTemplate(id: string) {
  return request<Saved>('POST', `/pos/receipt_templates/${id}/duplicate`, { body: {} });
}

export function makeDefaultReceiptTemplate(id: string) {
  return request<Saved>('POST', `/pos/receipt_templates/${id}/default`, { body: {} });
}

export function disableReceiptTemplate(id: string) {
  return request<Saved>('POST', `/pos/receipt_templates/${id}/disable`, { body: {} });
}

export function restoreReceiptTemplate(id: string, version: number, expectedVersion: number) {
  return request<Saved>('POST', `/pos/receipt_templates/${id}/restore`, {
    body: { version, expected_version: expectedVersion },
  });
}
