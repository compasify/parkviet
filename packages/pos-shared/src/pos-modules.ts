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

// The selling screen a profile suggests. menu_grid still needs fnb.menu; the
// table surfaces (the floor as tiles, as a plan, or as a board of rooms with
// their clocks) need fnb.tables; a bar's tab list needs fnb.postpay.
export type PosSellingSurface =
  | 'catalog'
  | 'menu_grid'
  | 'table_grid'
  | 'floor_plan'
  | 'resource_board'
  | 'tab_list';

export type PosTableSurface = 'table_grid' | 'floor_plan' | 'resource_board';

export const TABLE_SURFACES: readonly PosTableSurface[] = [
  'table_grid',
  'floor_plan',
  'resource_board',
];

const SELLING_SURFACES: readonly PosSellingSurface[] = [
  'catalog',
  'menu_grid',
  ...TABLE_SURFACES,
  'tab_list',
];

export type PosProfileDisplay = { catalog_view?: PosCatalogView; surface?: PosSellingSurface };

// Industry profile of the selected branch, as the context sends it.
export type PosBranchProfile = {
  key: string;
  version: number | null;
  display: PosProfileDisplay;
};

export type PosOnboarding = { required: boolean; can_setup: boolean };

// Modules this client has labels and notes for. Translation only: whether a
// module is on is always read from the server's object, never from this list.
export const LABELLED_MODULES = [
  'retail.units',
  'retail.measured',
  'retail.traceability',
  'fnb.menu',
  'fnb.recipes',
  'fnb.kitchen',
  'fnb.order_number',
  'fnb.cup_label',
  'fnb.delivery_platforms',
  'resources',
  'fnb.tables',
  'fnb.postpay',
  'fnb.service_charge',
  'fnb.reservations',
  'fnb.bottle_keep',
  'fnb.pour_tracking',
  'fnb.meal_accounts',
  'fnb.vehicle_commission',
  'fnb.qr_order',
  'fnb.kiosk',
  'timed_billing',
] as const;

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
  return {
    key: source.key,
    version:
      typeof source.version === 'number' && Number.isFinite(source.version) ? source.version : null,
    display: normalizeDisplay(source.display),
  };
}

// Known hints only; anything else reads as no opinion.
export function normalizeDisplay(value: unknown): PosProfileDisplay {
  const display = record(value);
  const view = display?.catalog_view;
  const surface = display?.surface;
  return {
    ...(view === 'cards' || view === 'list' ? { catalog_view: view } : {}),
    ...(SELLING_SURFACES.includes(surface as PosSellingSurface)
      ? { surface: surface as PosSellingSurface }
      : {}),
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

// What the counter picks items from: picture tiles of the menu when the branch
// runs `fnb.menu` and its profile does not ask for the catalogue, else the
// catalogue. A table surface in the profile still sells from the menu. The
// module decides; the profile only chooses between the two.
export function sellingSurfaceOf(
  context: { modules?: PosModules | null; profile?: PosBranchProfile | null } | undefined,
): 'catalog' | 'menu_grid' {
  if (context?.modules?.['fnb.menu'] !== true) return 'catalog';
  return context.profile?.display.surface === 'catalog' ? 'catalog' : 'menu_grid';
}

export function isTableSurface(value: unknown): value is PosTableSurface {
  return TABLE_SURFACES.includes(value as PosTableSurface);
}

// How the floor is shown at a branch running `fnb.tables`: the choice saved on
// this device, else the profile's table surface, else tiles. Null when the
// branch does not serve tables.
export function tableSurfaceOf(
  context: { modules?: PosModules | null; profile?: PosBranchProfile | null } | undefined,
  saved?: string | null,
): PosTableSurface | null {
  if (context?.modules?.['fnb.tables'] !== true) return null;
  if (isTableSurface(saved)) return saved;
  const suggested = context.profile?.display.surface;
  return isTableSurface(suggested) ? suggested : 'table_grid';
}

// The selling screen of a branch: table service (the floor first, then the
// order beside its ticket) when it runs `fnb.tables`, a board of timed rooms
// included, unless its profile starts on a bar's open tabs, which keep the
// counter layout. A branch selling from its menu tiles without tables sells
// at the quick counter (the menu beside one ticket paid on the spot), a
// canteen's meal codes and a rest stop's coaches included, except a branch
// paying later or by the clock (open tabs, timed rooms), whose orders stay
// open across guests. Without the menu, or with a profile that keeps the
// catalogue, it is the counter. Only the modules and the surface decide,
// never the industry.
export function sellingLayoutOf(
  context: { modules?: PosModules | null; profile?: PosBranchProfile | null } | undefined,
): 'table_service' | 'quick_counter' | 'counter' {
  const modules = context?.modules;
  const surface = context?.profile?.display.surface;
  const keepsCounter = surface === 'tab_list' || surface === 'resource_board';
  if (modules?.['fnb.tables'] !== true) {
    if (sellingSurfaceOf(context) !== 'menu_grid' || keepsCounter) return 'counter';
    return modules?.timed_billing === true || modules?.['fnb.postpay'] === true
      ? 'counter'
      : 'quick_counter';
  }
  return surface === 'tab_list' ? 'counter' : 'table_service';
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
  // Modules switched on only when the shop answers that it serves tables.
  optional_modules: string[];
  branch_defaults: Record<string, unknown>;
  display: PosProfileDisplay;
  recommended_features: string[];
  sample_units: string[];
  // Kitchen station kinds (`prep`, `bar`) the F&B setup step proposes.
  kitchen_stations: string[];
};

// A tax category the F&B setup step offers, by Spree tax code, with the rate
// a new store is seeded with (a fraction: `0.08`).
// The table module: a profile listing it among its optional modules asks
// whether the shop serves tables.
export const TABLES_MODULE = 'fnb.tables';

// The modules a branch gets from a profile, with the optional ones when the
// shop serves tables.
export function profileModules(profile: BusinessProfile, hasTables: boolean): string[] {
  return hasTables ? [...profile.modules, ...profile.optional_modules] : profile.modules;
}

export const tablesOptional = (profile: BusinessProfile) =>
  profile.optional_modules.includes(TABLES_MODULE);

export type BusinessTaxCategory = { code: string; rate: string };

export type BusinessProfiles = {
  version: number | null;
  modules: BusinessModule[];
  profiles: BusinessProfile[];
  tax_categories: BusinessTaxCategory[];
  // Tax codes proposed for new menu items: `food` and `alcohol`.
  menu_tax_defaults: Record<string, string>;
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
          optional_modules: strings(item.optional_modules),
          branch_defaults: record(item.branch_defaults) ?? {},
          display: normalizeDisplay(item.display),
          recommended_features: strings(item.recommended_features),
          sample_units: strings(item.sample_units),
          kitchen_stations: strings(item.kitchen_stations),
        } satisfies BusinessProfile,
      ];
    })
    .sort((left, right) => left.order - right.order || left.key.localeCompare(right.key));
  return {
    version:
      typeof source.version === 'number' && Number.isFinite(source.version) ? source.version : null,
    modules,
    profiles,
    tax_categories: (Array.isArray(source.tax_categories) ? source.tax_categories : []).flatMap(
      (row) => {
        const item = record(row);
        return item && typeof item.code === 'string' && item.code && typeof item.rate === 'string'
          ? [{ code: item.code, rate: item.rate }]
          : [];
      },
    ),
    menu_tax_defaults: Object.fromEntries(
      Object.entries(record(source.menu_tax_defaults) ?? {}).filter(
        (entry): entry is [string, string] => typeof entry[1] === 'string',
      ),
    ),
  };
}

// Modules switching `key` on would also switch on: its `depends_on`, followed
// to the end, that are off at the branch. The server turns them on with it
// (`also_enabled`); this only lets the page say so before asking.
export function modulesEnabledWith(
  key: string,
  catalogue: BusinessModule[],
  modules: PosModules | null | undefined,
): string[] {
  const found: string[] = [];
  const visit = (current: string) => {
    for (const dependency of catalogue.find((item) => item.key === current)?.depends_on ?? []) {
      if (dependency === key || found.includes(dependency)) continue;
      if (!moduleEnabled(modules, dependency)) found.push(dependency);
      visit(dependency);
    }
  };
  visit(key);
  return found;
}

// Modules on at the branch that need `key`: the server refuses to switch it
// off while any is on (409 `module_required_by`).
export function modulesRequiring(
  key: string,
  catalogue: BusinessModule[],
  modules: PosModules | null | undefined,
): string[] {
  return catalogue
    .filter(
      (item) =>
        item.key !== key && item.depends_on.includes(key) && moduleEnabled(modules, item.key),
    )
    .map((item) => item.key);
}

export function profileLabelKey(key: string): string {
  return `profiles.${key}.label`;
}

export function profileDescriptionKey(key: string): string {
  return `profiles.${key}.description`;
}
