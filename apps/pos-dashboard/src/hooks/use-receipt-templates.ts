import type {
  DocumentType,
  PaperSize,
  TemplateConfig,
} from '@parkviet/pos-shared/receipt-template/types'
import type { ReceiptSnapshot } from '@parkviet/pos-shared/types/print-adapter'
import { useInfiniteQuery, useQuery } from '@tanstack/react-query'
import { getActiveStoreId } from '../lib/active-store'
import { posRequest } from '../lib/pos-request'
import { queryClient } from '../lib/query-client'
import { useSession } from './use-session'

// The store's print templates (`/pos/receipt_templates`). Every save on the
// server adds an immutable version; edits carry the version they started
// from and a stale one is refused with a 409.

export type ReceiptTemplate = {
  id: string
  document_type: DocumentType
  name: string
  paper: PaperSize
  status: 'active' | 'disabled'
  is_default: boolean
  current_version: number
  // The version `config` belongs to.
  version: number
  config: TemplateConfig
  updated_by: { id: string; name: string } | null
  created_at: string
  updated_at: string
}

export type ReceiptTemplateVersion = {
  version: number
  config: TemplateConfig
  created_at: string
  created_by: { id: string; name: string } | null
}

export const RECEIPT_TEMPLATES_KEY = ['pos'] as const
export const receiptTemplatesKey = (storeId: string) =>
  ['pos', storeId, 'receipt-templates'] as const

async function request<T>(
  method: string,
  path: string,
  options?: { body?: unknown; params?: Record<string, string | undefined> },
): Promise<T> {
  return posRequest<T>(method, path, options)
}

// Template reads that print waits on give up after this long: a hung
// request must fall back to the built-in template, never stall a print.
const PRINT_READ_TIMEOUT_MS = 8000

function withTimeout<T>(promise: Promise<T>, ms: number): Promise<T> {
  return new Promise<T>((resolve, reject) => {
    const timer = setTimeout(() => reject(new Error('Receipt template request timed out.')), ms)
    promise.then(
      (value) => {
        clearTimeout(timer)
        resolve(value)
      },
      (error: unknown) => {
        clearTimeout(timer)
        reject(error)
      },
    )
  })
}

// One saved version of a template; versions never change, so it is cached
// for good once read.
const versionKey = (storeId: string, id: string | null, version: number | null) =>
  [...receiptTemplatesKey(storeId), 'version', id, version] as const

const readVersion = async (id: string, version: number) =>
  (
    await withTimeout(
      request<{ data: ReceiptTemplate }>('GET', `/pos/receipt_templates/${id}`, {
        params: { version: String(version) },
      }),
      PRINT_READ_TIMEOUT_MS,
    )
  ).data

// Every template of the store; disabled ones only for administrators. The
// active list is what the counter prints with: loaded when the POS opens,
// kept for a while and refreshed when the window regains focus. Each
// entry also fills the cache of its current version.
// Reads the store's templates, seeding each one's current version in the cache.
export async function readReceiptTemplates(storeId: string, includeDisabled: boolean) {
  const read = request<{ data: ReceiptTemplate[] }>('GET', '/pos/receipt_templates', {
    params: { include_disabled: includeDisabled ? '1' : undefined },
  })
  const templates = (includeDisabled ? await read : await withTimeout(read, PRINT_READ_TIMEOUT_MS))
    .data
  for (const template of templates)
    queryClient.setQueryData(versionKey(storeId, template.id, template.version), template)
  return templates
}

export function useReceiptTemplates(enabled: boolean, includeDisabled = false) {
  const snapshot = useSession()
  const generation = snapshot.generation
  return useQuery({
    queryKey: [...receiptTemplatesKey(generation), 'list', includeDisabled],
    enabled: enabled && snapshot.status === 'authenticated',
    staleTime: includeDisabled ? 0 : 5 * 60_000,
    refetchOnWindowFocus: !includeDisabled,
    queryFn: () => readReceiptTemplates(generation, includeDisabled),
  })
}

// The template as saved in `version`, disabled templates included.
export function useReceiptTemplateVersion(id: string | null, version: number | null) {
  const snapshot = useSession()
  return useQuery({
    queryKey: versionKey(snapshot.generation, id, version),
    enabled: snapshot.status === 'authenticated' && Boolean(id) && version !== null,
    staleTime: Number.POSITIVE_INFINITY,
    queryFn: () => readVersion(id ?? '', version ?? 0),
  })
}

// The same read outside a component, for the layout the server recorded.
export function loadReceiptTemplateVersion(id: string, version: number) {
  return queryClient.fetchQuery({
    queryKey: versionKey(getActiveStoreId(), id, version),
    staleTime: Number.POSITIVE_INFINITY,
    queryFn: () => readVersion(id, version),
  })
}

export function useReceiptTemplate(id: string, enabled: boolean) {
  const snapshot = useSession()
  return useQuery({
    queryKey: [...receiptTemplatesKey(snapshot.generation), 'detail', id],
    enabled: enabled && snapshot.status === 'authenticated' && id !== '',
    queryFn: async () =>
      (await request<{ data: ReceiptTemplate }>('GET', `/pos/receipt_templates/${id}`)).data,
  })
}

export const VERSIONS_PAGE_SIZE = 10

// The saved versions of a template, newest first, a page at a time (needs
// the write permission). Each entry carries its config, so pages stay small.
export function useReceiptTemplateVersions(id: string, enabled: boolean) {
  const snapshot = useSession()
  return useInfiniteQuery({
    queryKey: [...receiptTemplatesKey(snapshot.generation), 'versions', id],
    enabled: enabled && snapshot.status === 'authenticated' && id !== '',
    initialPageParam: 1,
    queryFn: ({ pageParam }) =>
      request<{ data: ReceiptTemplateVersion[]; meta?: { next: number | null } }>(
        'GET',
        `/pos/receipt_templates/${id}/versions`,
        { params: { limit: String(VERSIONS_PAGE_SIZE), page: String(pageParam) } },
      ),
    getNextPageParam: (last) => last.meta?.next ?? undefined,
  })
}

// The newest posted receipt of a document type at a branch, to preview a
// template with real content. Null when the branch has none.
export function useLatestReceipt(
  branchId: string | null,
  sourceType: ReceiptSnapshot['source_type'] | null,
  enabled: boolean,
) {
  const snapshot = useSession()
  return useQuery({
    queryKey: [...receiptTemplatesKey(snapshot.generation), 'latest', branchId, sourceType],
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
  })
}

export const refreshReceiptTemplates = (storeId = getActiveStoreId()) =>
  queryClient.invalidateQueries({ queryKey: receiptTemplatesKey(storeId) })

type Saved = { data: ReceiptTemplate }

export function createReceiptTemplate(body: {
  from_default: DocumentType
  name: string
  paper: PaperSize
}) {
  return request<Saved>('POST', '/pos/receipt_templates', { body })
}

export function updateReceiptTemplate(
  id: string,
  body: { expected_version: number; name: string; paper: PaperSize; config: TemplateConfig },
) {
  return request<Saved>('PATCH', `/pos/receipt_templates/${id}`, { body })
}

export function duplicateReceiptTemplate(id: string) {
  return request<Saved>('POST', `/pos/receipt_templates/${id}/duplicate`, { body: {} })
}

export function makeDefaultReceiptTemplate(id: string) {
  return request<Saved>('POST', `/pos/receipt_templates/${id}/default`, { body: {} })
}

export function disableReceiptTemplate(id: string) {
  return request<Saved>('POST', `/pos/receipt_templates/${id}/disable`, { body: {} })
}

export function restoreReceiptTemplate(id: string, version: number, expectedVersion: number) {
  return request<Saved>('POST', `/pos/receipt_templates/${id}/restore`, {
    body: { version, expected_version: expectedVersion },
  })
}
