import { normalizeModules, type PosModules } from '@parkviet/pos-shared/pos-modules'
import { useQuery } from '@tanstack/react-query'
import { posRequest } from '../lib/pos-request'
import { usePosSession as usePosSelection } from './use-pos-session'
import { useSession } from './use-session'

export const branchModulesKey = (storeId: string, branchId: string | null) =>
  ['pos', storeId, 'branch-modules', branchId] as const

// Modules on at a branch, for settings pages that show a branch by URL. The
// selected branch reads them from the context; any other branch asks
// `GET /pos/branches/:id/modules`. Null means unknown (loading, refused, a
// server without modules): the caller then hides nothing and lets the server
// decide, the same rule as a context without `modules`.
export function useBranchModules(branchId: string | null | undefined): PosModules | null {
  const snapshot = useSession()
  const { context, selection } = usePosSelection()
  const id = branchId || null
  const selected =
    id !== null && selection.branchId === id && context.data?.selection.branch_id === id
  const query = useQuery({
    queryKey: branchModulesKey(snapshot.generation, id),
    enabled: !selected && id !== null && snapshot.status === 'authenticated',
    staleTime: 30_000,
    retry: false,
    queryFn: async (): Promise<PosModules | null> => {
      const response = await posRequest<{ data?: unknown }>(
        'GET',
        `/pos/branches/${encodeURIComponent(id ?? '')}/modules`,
        {},
      )
      const data = response.data
      return typeof data === 'object' && data !== null && !Array.isArray(data)
        ? normalizeModules((data as { modules?: unknown }).modules)
        : null
    },
  })
  if (selected) return context.data?.modules ?? null
  return query.data ?? null
}

async function request<T>(method: 'GET' | 'POST' | 'PUT', path: string, body?: unknown) {
  return await posRequest<{ data?: T }>(method, path, body === undefined ? {} : { body })
}

function record(value: unknown): Record<string, unknown> | null {
  return typeof value === 'object' && value !== null && !Array.isArray(value)
    ? (value as Record<string, unknown>)
    : null
}

function strings(value: unknown): string[] {
  return Array.isArray(value)
    ? value.filter((item): item is string => typeof item === 'string')
    : []
}

export type BranchModuleSetting = {
  module: string
  enabled: boolean
  reason: string
  changed_by_name: string | null
  changed_at: string | null
}

export type BranchModuleDetail = { modules: PosModules; settings: BranchModuleSetting[] }

// Module switches of a branch with who changed them last and why
// (`GET /pos/branches/:id/modules`), for the business model page. Always asks
// the server, also for the selected branch, so the rows are current.
export function useBranchModuleDetail(branchId: string | null, enabled = true) {
  const snapshot = useSession()
  return useQuery({
    queryKey: [...branchModulesKey(snapshot.generation, branchId), 'detail'] as const,
    enabled: enabled && branchId !== null && snapshot.status === 'authenticated',
    retry: false,
    queryFn: async (): Promise<BranchModuleDetail> => {
      const data = record(
        (
          await request<unknown>(
            'GET',
            `/pos/branches/${encodeURIComponent(branchId ?? '')}/modules`,
          )
        ).data,
      )
      const settings = (Array.isArray(data?.settings) ? data.settings : []).flatMap((row) => {
        const item = record(row)
        if (!item || typeof item.module !== 'string' || typeof item.enabled !== 'boolean') return []
        return [
          {
            module: item.module,
            enabled: item.enabled,
            reason: typeof item.reason === 'string' ? item.reason : '',
            changed_by_name: typeof item.changed_by_name === 'string' ? item.changed_by_name : null,
            changed_at: typeof item.changed_at === 'string' ? item.changed_at : null,
          },
        ]
      })
      return { modules: normalizeModules(data?.modules) ?? {}, settings }
    },
  })
}

// `PUT /pos/branches/:id/modules/:key`. Switching on also switches on what the
// module depends on (`also_enabled`); switching off a module another one needs
// is refused with 409 `module_required_by`. A reason is required.
export async function setBranchModule(
  branchId: string,
  key: string,
  enabled: boolean,
  reason: string,
): Promise<{ alsoEnabled: string[] }> {
  const data = record(
    (
      await request<unknown>(
        'PUT',
        `/pos/branches/${encodeURIComponent(branchId)}/modules/${encodeURIComponent(key)}`,
        { enabled, reason },
      )
    ).data,
  )
  return { alsoEnabled: strings(data?.also_enabled) }
}

export type ProfileDefaultChange = { field: string; current: unknown; profile: unknown }

export type ProfilePreview = {
  from: string
  to: string
  enable: string[]
  disable: string[]
  // Per module to switch off: how much of the branch's setup it holds (a
  // warning only; selling what is configured never changes, D5).
  inUse: Record<string, Record<string, number>>
  defaults: ProfileDefaultChange[]
  sampleUnits: string[]
  recommendedFeatures: string[]
  tables: ProfileTables
}

// Table service under the new profile: always on, or offered as a question;
// whether the branch still lacks a register for table orders, and the
// kitchen stations the profile would create at a branch that has none.
export type ProfileTables = {
  always: boolean
  optional: boolean
  optionalModules: string[]
  registerNeeded: boolean
  defaultStations: string[]
}

export function normalizePreview(value: unknown): ProfilePreview | null {
  const data = record(value)
  if (!data || typeof data.to !== 'string') return null
  const modules = record(data.modules) ?? {}
  const tables = record(data.tables) ?? {}
  const inUse = Object.fromEntries(
    Object.entries(record(modules.in_use) ?? {}).map(([key, counts]) => [
      key,
      Object.fromEntries(
        Object.entries(record(counts) ?? {}).filter(
          (entry): entry is [string, number] =>
            typeof entry[1] === 'number' && Number.isFinite(entry[1]),
        ),
      ),
    ]),
  )
  return {
    from: typeof data.from === 'string' ? data.from : '',
    to: data.to,
    enable: strings(modules.enable),
    disable: strings(modules.disable),
    inUse,
    defaults: (Array.isArray(data.defaults) ? data.defaults : []).flatMap((row) => {
      const item = record(row)
      return item && typeof item.field === 'string'
        ? [{ field: item.field, current: item.current ?? null, profile: item.profile ?? null }]
        : []
    }),
    sampleUnits: strings(data.sample_units),
    recommendedFeatures: strings(data.recommended_features),
    tables: {
      always: tables.always === true,
      optional: tables.optional === true,
      optionalModules: strings(tables.optional_modules),
      registerNeeded: tables.register_needed === true,
      defaultStations: strings(tables.default_stations),
    },
  }
}

// What moving the branch to `profileKey` would change; changes nothing.
export async function previewBranchProfile(branchId: string, profileKey: string) {
  const preview = normalizePreview(
    (
      await request<unknown>(
        'POST',
        `/pos/branches/${encodeURIComponent(branchId)}/profile/preview`,
        { profile_key: profileKey },
      )
    ).data,
  )
  if (!preview) throw new Error('Unexpected profile preview.')
  return preview
}

// `PUT /pos/branches/:id/profile`: only the picked defaults are applied (D7).
// `expected_profile_key` is the profile the preview was made from; when the
// branch moved meanwhile the server answers 409 `profile_conflict`.
export async function applyBranchProfile(
  branchId: string,
  body: {
    profile_key: string
    expected_profile_key: string
    apply_modules: boolean
    apply_defaults: string[]
    reason: string
    has_tables?: boolean
    table_register_id?: string
    apply_stations?: boolean
  },
) {
  return (
    await request<unknown>('PUT', `/pos/branches/${encodeURIComponent(branchId)}/profile`, body)
  ).data
}
