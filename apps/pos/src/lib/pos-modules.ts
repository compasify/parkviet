// Branch modules: optional groups of setup screens (unit conversion, scale
// labels, serial/lot tracking) a branch turns on or off. A module that is off
// hides its setup entry points only. Selling, receipts and returns never read
// it, and the server refuses new setup with 409 `module_disabled` either way.
//
// The server owns the module catalogue: keys are kept as they come, so a module
// this client does not know yet is neither dropped nor treated as an error.

export type PosModules = Record<string, boolean>;

// Store-wide data a module still has, whatever the branch modules say. Today
// `retail.traceability`: the store still has SKUs tracked by serial or lot.
export type PosModuleUsage = Record<string, boolean>;

export type PosCatalogView = 'cards' | 'list';

// Industry profile of the selected branch, as the context sends it.
export type PosBranchProfile = {
  key: string;
  version: number | null;
  display: { catalog_view?: PosCatalogView };
};

export type PosOnboarding = { required: boolean; can_setup: boolean };

// Modules this client has labels and notes for. Translation only: whether a
// module is on is always read from the server's object, never from this list.
export const LABELLED_MODULES = ['retail.units', 'retail.measured', 'retail.traceability'] as const;

function record(value: unknown): Record<string, unknown> | null {
  return typeof value === 'object' && value !== null && !Array.isArray(value)
    ? (value as Record<string, unknown>)
    : null;
}

// Keeps every string key whose value is exactly `true`; anything else is off.
// Unknown keys stay. Null when the value is not an object (server without modules).
export function normalizeModules(value: unknown): PosModules | null {
  const source = record(value);
  if (!source) return null;
  return Object.fromEntries(
    Object.entries(source).flatMap(([key, enabled]) =>
      key.length > 0 && enabled === true ? [[key, true] as const] : [],
    ),
  );
}

// A server without modules sends no `modules` object: nothing is hidden. Once
// it sends one, a module is on only when its key is exactly `true`, so a
// missing or malformed value fails closed.
export function moduleEnabled(modules: PosModules | null | undefined, key: string): boolean {
  if (modules === null || modules === undefined) return true;
  return Object.hasOwn(modules, key) && modules[key] === true;
}

export function contextModule(
  context: { modules?: PosModules | null } | undefined,
  key: string,
): boolean {
  return moduleEnabled(context?.modules, key);
}

// Usage only ever keeps an entry visible; a missing or malformed value reads
// as "not in use", so the decision falls back to the module itself.
export function normalizeModuleUsage(value: unknown): PosModuleUsage {
  return normalizeModules(value) ?? {};
}

export function moduleInUse(
  context: { module_usage?: PosModuleUsage | null } | undefined,
  key: string,
): boolean {
  const usage = context?.module_usage;
  return Boolean(usage && Object.hasOwn(usage, key) && usage[key] === true);
}

export function normalizeProfile(value: unknown): PosBranchProfile | null {
  const source = record(value);
  if (!source || typeof source.key !== 'string' || !source.key) return null;
  const display = record(source.display);
  const view = display?.catalog_view;
  return {
    key: source.key,
    version:
      typeof source.version === 'number' && Number.isFinite(source.version) ? source.version : null,
    display: view === 'cards' || view === 'list' ? { catalog_view: view } : {},
  };
}

export function normalizeOnboarding(value: unknown): PosOnboarding | null {
  const source = record(value);
  if (!source) return null;
  return { required: source.required === true, can_setup: source.can_setup === true };
}

// The catalogue's first view at the branch: the profile's hint, else cards.
export function catalogViewOf(
  context: { profile?: PosBranchProfile | null } | undefined,
): PosCatalogView {
  return context?.profile?.display.catalog_view ?? 'cards';
}

// i18n key fragment of a module: dots would read as nesting in i18next.
export function moduleTextKey(key: string): string | null {
  return (LABELLED_MODULES as readonly string[]).includes(key) ? key.replaceAll('.', '_') : null;
}

export function moduleLabelKey(key: string): string | null {
  const text = moduleTextKey(key);
  return text ? `posModules.${text}.label` : null;
}

// --- Business profile catalogue (GET /pos/business_profiles) ---------------

export type BusinessModule = {
  key: string;
  group: string;
  status: string;
  depends_on: string[];
};

export type BusinessProfile = {
  key: string;
  group: string;
  order: number;
  // `available` or `coming_soon`; other values are kept as sent.
  status: string;
  modules: string[];
  branch_defaults: Record<string, unknown>;
  display: { catalog_view?: PosCatalogView };
  recommended_features: string[];
  sample_units: string[];
};

export type BusinessProfiles = {
  version: number | null;
  modules: BusinessModule[];
  profiles: BusinessProfile[];
};

function strings(value: unknown): string[] {
  return Array.isArray(value)
    ? value.filter((item): item is string => typeof item === 'string')
    : [];
}

// Tolerant reader: rows without a key are skipped, profiles come ordered by
// `order` then key. Labels are translated by key (`profiles.<key>.label`).
export function normalizeBusinessProfiles(value: unknown): BusinessProfiles {
  const source = record(value) ?? {};
  const modules = (Array.isArray(source.modules) ? source.modules : []).flatMap((row) => {
    const item = record(row);
    if (!item || typeof item.key !== 'string' || !item.key) return [];
    return [
      {
        key: item.key,
        group: typeof item.group === 'string' ? item.group : '',
        status: typeof item.status === 'string' ? item.status : '',
        depends_on: strings(item.depends_on),
      },
    ];
  });
  const profiles = (Array.isArray(source.profiles) ? source.profiles : [])
    .flatMap((row) => {
      const item = record(row);
      if (!item || typeof item.key !== 'string' || !item.key) return [];
      const view = record(item.display)?.catalog_view;
      return [
        {
          key: item.key,
          group: typeof item.group === 'string' ? item.group : '',
          order:
            typeof item.order === 'number' && Number.isFinite(item.order)
              ? item.order
              : Number.MAX_SAFE_INTEGER,
          status: typeof item.status === 'string' ? item.status : '',
          modules: strings(item.modules),
          branch_defaults: record(item.branch_defaults) ?? {},
          display: view === 'cards' || view === 'list' ? { catalog_view: view } : {},
          recommended_features: strings(item.recommended_features),
          sample_units: strings(item.sample_units),
        } satisfies BusinessProfile,
      ];
    })
    .sort((left, right) => left.order - right.order || left.key.localeCompare(right.key));
  return {
    version:
      typeof source.version === 'number' && Number.isFinite(source.version) ? source.version : null,
    modules,
    profiles,
  };
}

export function profileLabelKey(key: string): string {
  return `profiles.${key}.label`;
}

export function profileDescriptionKey(key: string): string {
  return `profiles.${key}.description`;
}
