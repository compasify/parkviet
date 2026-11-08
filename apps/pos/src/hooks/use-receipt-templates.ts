import { useInfiniteQuery, useQuery } from '@tanstack/react-query';
import { useMemo, useState } from 'react';
import { session } from '../lib/app-session';
import type { ReceiptSnapshot } from '../lib/print-adapter';
import { queryClient } from '../lib/query-client';
import { defaultTemplate } from '../lib/receipt-template/defaults';
import {
  DEFAULT_PAPER,
  initialChoice,
  type PrintChoice,
  type PrintLayout,
  printChoices,
  rememberedTemplate,
} from '../lib/receipt-template/selection';
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

// Template reads that print waits on give up after this long: a hung
// request must fall back to the built-in template, never stall a print.
const PRINT_READ_TIMEOUT_MS = 8000;

function withTimeout<T>(promise: Promise<T>, ms: number): Promise<T> {
  return new Promise<T>((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error('Receipt template request timed out.')), ms);
    promise.then(
      (value) => {
        clearTimeout(timer);
        resolve(value);
      },
      (error: unknown) => {
        clearTimeout(timer);
        reject(error);
      },
    );
  });
}

// One saved version of a template; versions never change, so it is cached
// for good once read.
const versionKey = (generation: number, id: string | null, version: number | null) =>
  [...RECEIPT_TEMPLATES_KEY, 'version', generation, id, version] as const;

const readVersion = async (id: string, version: number) =>
  (
    await withTimeout(
      request<{ data: ReceiptTemplate }>('GET', `/pos/receipt_templates/${id}`, {
        params: { version: String(version) },
      }),
      PRINT_READ_TIMEOUT_MS,
    )
  ).data;

// Every template of the store; disabled ones only for administrators. The
// active list is what the counter prints with: loaded when the POS opens,
// kept for a while and refreshed when the window regains focus. Each
// entry also fills the cache of its current version.
export function useReceiptTemplates(enabled: boolean, includeDisabled = false) {
  const snapshot = useSession();
  const generation = snapshot.generation;
  return useQuery({
    queryKey: [...RECEIPT_TEMPLATES_KEY, 'list', generation, includeDisabled],
    enabled: enabled && snapshot.status === 'authenticated',
    staleTime: includeDisabled ? 0 : 5 * 60_000,
    refetchOnWindowFocus: !includeDisabled,
    queryFn: async () => {
      const read = request<{ data: ReceiptTemplate[] }>('GET', '/pos/receipt_templates', {
        params: { include_disabled: includeDisabled ? '1' : undefined },
      });
      const templates = (
        includeDisabled ? await read : await withTimeout(read, PRINT_READ_TIMEOUT_MS)
      ).data;
      for (const template of templates)
        queryClient.setQueryData(versionKey(generation, template.id, template.version), template);
      return templates;
    },
  });
}

// The template as saved in `version`, disabled templates included.
export function useReceiptTemplateVersion(id: string | null, version: number | null) {
  const snapshot = useSession();
  return useQuery({
    queryKey: versionKey(snapshot.generation, id, version),
    enabled: snapshot.status === 'authenticated' && Boolean(id) && version !== null,
    staleTime: Number.POSITIVE_INFINITY,
    queryFn: () => readVersion(id ?? '', version ?? 0),
  });
}

// The same read outside a component, for the layout the server recorded.
export function loadReceiptTemplateVersion(id: string, version: number) {
  return queryClient.fetchQuery({
    queryKey: versionKey(session.getSnapshot().generation, id, version),
    staleTime: Number.POSITIVE_INFINITY,
    queryFn: () => readVersion(id, version),
  });
}

export type PrintTemplate = {
  // Every template the print may use; empty when none could be loaded.
  choices: PrintChoice[];
  choice: PrintChoice | null;
  pick: (key: string) => void;
  // Back to the starting choice (the original's template on a reprint).
  reset: () => void;
  // The chosen template's config, or the built-in one while it loads or
  // when it cannot be loaded.
  config: TemplateConfig;
  paper: PaperSize;
  loading: boolean;
  // The built-in template is in use because the chosen one failed to load.
  fallback: boolean;
};

// The template a document prints with at the counter (see selection.ts).
// Loading or failing never blocks a print: the built-in template of the
// document type stands in.
export function usePrintTemplate(
  documentType: DocumentType,
  options: { original?: PrintLayout | null; remember?: boolean } = {},
): PrintTemplate {
  const { original = null, remember = false } = options;
  const list = useReceiptTemplates(true);
  const [picked, setPicked] = useState<string | null>(null);
  const remembered = useMemo(
    () => (remember ? rememberedTemplate(documentType) : null),
    [remember, documentType],
  );
  const templates = list.data ?? [];
  const listed = useMemo(
    () => printChoices(list.data ?? [], documentType, original),
    [list.data, documentType, original],
  );
  const key =
    picked && listed.some((choice) => choice.key === picked)
      ? picked
      : initialChoice(listed, templates, remembered);
  const selected = listed.find((choice) => choice.key === key) ?? null;
  const version = useReceiptTemplateVersion(
    selected?.templateId ?? null,
    selected?.version ?? null,
  );
  // A disabled original is not listed: its name comes with its version.
  const choices = listed.map((choice) =>
    choice.key === key && choice.name === null && version.data
      ? { ...choice, name: version.data.name }
      : choice,
  );
  const choice = choices.find((item) => item.key === key) ?? null;
  const config = choice && version.data ? version.data.config : null;
  const loading = choice ? version.isPending : list.isPending;
  return {
    choices,
    choice,
    pick: setPicked,
    reset: () => setPicked(null),
    config: config ?? defaultTemplate(documentType),
    paper: choice?.paper ?? DEFAULT_PAPER,
    loading,
    fallback: !loading && config === null,
  };
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
