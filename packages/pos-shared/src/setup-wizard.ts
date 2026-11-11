// First-run setup of a store (`/setup`): steps kept in memory only, sent
// to the server in one idempotent command at the last step
// (`POST /pos/onboarding`). The profile catalogue comes from the server (D3);
// nothing here lists industries.
//
// Risky features are never ticked for the user (D6): the wizard only labels
// the ones the industry usually uses. Granting the person setting up every
// permission at the new branch is ticked, and can be unticked.

import { isPosFeature, type PosFeature } from './pos-features';
import type { BusinessProfile, BusinessProfiles } from './pos-modules';

// 1 industry, 2 wholesale, 3 branch, 4 preview, 5 shop setup (profiles with
// the menu only), 6 summary.
export type SetupStep = 1 | 2 | 3 | 4 | 5 | 6;

export const SETUP_STEPS: readonly SetupStep[] = [1, 2, 3, 4, 5, 6];
export const SHOP_STEP: SetupStep = 5;
export const SUMMARY_STEP: SetupStep = 6;
export const MAX_STATIONS = 4;
export const STATION_NAME_MAX = 80;

export type KitchenSendTrigger = 'on_complete' | 'manual';
export type ShopStationKind = 'prep' | 'bar';

// The F&B "set up the shop" step: kitchen stations to create, the tax
// categories new menu items start with, and when orders reach the kitchen.
export type ShopSetup = {
  // The profile these defaults were made for; another profile starts over.
  profileKey: string;
  stations: { kind: ShopStationKind; name: string }[];
  foodTax: string;
  alcoholTax: string;
  trigger: KitchenSendTrigger;
};

// Profiles running the menu get the shop step; retail profiles skip it.
export function hasShopStep(profile: BusinessProfile | undefined): boolean {
  return Boolean(profile?.modules.includes('fnb.menu'));
}

export function hasKitchen(profile: BusinessProfile | undefined): boolean {
  return Boolean(profile?.modules.includes('fnb.kitchen'));
}

export function setupSteps(profile: BusinessProfile | undefined): SetupStep[] {
  return SETUP_STEPS.filter((step) => step !== SHOP_STEP || hasShopStep(profile));
}

export function nextStep(step: SetupStep, profile: BusinessProfile | undefined): SetupStep {
  const steps = setupSteps(profile);
  return steps[Math.min(steps.indexOf(step) + 1, steps.length - 1)] ?? SUMMARY_STEP;
}

export function previousStep(step: SetupStep, profile: BusinessProfile | undefined): SetupStep {
  const steps = setupSteps(profile);
  return steps[Math.max(steps.indexOf(step) - 1, 0)] ?? 1;
}

// What the shop step proposes for a profile: its station kinds named by the
// caller (translated), the catalogue's tax codes for food and alcohol, and
// the profile's send trigger.
export function shopDefaults(
  profile: BusinessProfile,
  catalogue: Pick<BusinessProfiles, 'tax_categories' | 'menu_tax_defaults'>,
  stationName: (kind: ShopStationKind) => string,
): ShopSetup {
  const codes = catalogue.tax_categories.map((row) => row.code);
  const pick = (code: string | undefined) =>
    code && codes.includes(code) ? code : (codes[0] ?? '');
  const kinds = hasKitchen(profile)
    ? profile.kitchen_stations.filter(
        (kind): kind is ShopStationKind => kind === 'prep' || kind === 'bar',
      )
    : [];
  return {
    profileKey: profile.key,
    stations: kinds.map((kind) => ({ kind, name: stationName(kind) })),
    foodTax: pick(catalogue.menu_tax_defaults.food),
    alcoholTax: pick(catalogue.menu_tax_defaults.alcohol),
    trigger: profile.branch_defaults.kitchen_send_trigger === 'manual' ? 'manual' : 'on_complete',
  };
}

// Branch fields an industry profile may preset, as the editable text of the
// form. `lot_selection` is `fefo` or `cashier_pick`; the others are digits or
// blank (blank sends null: no returns, every variance or count needs approval).
export type SetupDefaults = {
  return_window_days: string;
  lot_selection: 'fefo' | 'cashier_pick';
  variance_threshold: string;
  adjustment_approval_threshold: string;
};

export type SetupState = {
  step: SetupStep;
  // The card picked on step 1: an available profile, or a "coming soon" one
  // waiting for the owner's answer.
  choice: string | null;
  // The available (retail) profile the branch is created with.
  profileKey: string | null;
  // "Coming soon" profiles the owner asked for, in the order chosen.
  interests: string[];
  // The owner answered "no" to "do you also sell goods?" for the current choice.
  declined: boolean;
  wholesale: boolean;
  branch: {
    name: string;
    code: string;
    // The owner typed the code: renaming the branch no longer rewrites it.
    codeEdited: boolean;
    timezone: string;
    stockLocationId: string;
  };
  registerName: string;
  grantSelf: boolean;
  defaults: SetupDefaults;
  features: PosFeature[];
  shop: ShopSetup | null;
};

export const DEFAULT_REGISTER_NAME = 'Quầy 1';
export const DEFAULT_TIMEZONE = 'Asia/Ho_Chi_Minh';

const BLANK_DEFAULTS: SetupDefaults = {
  return_window_days: '',
  lot_selection: 'fefo',
  variance_threshold: '',
  adjustment_approval_threshold: '',
};

export function initialSetup(timezone?: string | null): SetupState {
  return {
    step: 1,
    choice: null,
    profileKey: null,
    interests: [],
    declined: false,
    wholesale: false,
    branch: {
      name: '',
      code: '',
      codeEdited: false,
      timezone: timezone?.trim() || DEFAULT_TIMEZONE,
      stockLocationId: '',
    },
    registerName: DEFAULT_REGISTER_NAME,
    grantSelf: true,
    defaults: { ...BLANK_DEFAULTS },
    features: [],
    shop: null,
  };
}

export function isAvailable(profile: BusinessProfile | undefined): profile is BusinessProfile {
  return profile?.status === 'available';
}

export function isComingSoon(profile: BusinessProfile | undefined): boolean {
  return profile?.status === 'coming_soon';
}

// The retail profile suggested to an owner whose industry is not served yet:
// a canteen or rest stop sells packaged goods like a grocery; anyone else
// starts from "Other", which turns every retail module on.
export function suggestedRetailProfile(
  comingSoonKey: string,
  profiles: BusinessProfile[],
): string | null {
  const preferred = comingSoonKey === 'cang_tin_tram_dung' ? 'tap_hoa_sieu_thi' : 'khac';
  const match = profiles.find((profile) => profile.key === preferred && isAvailable(profile));
  return match?.key ?? profiles.find(isAvailable)?.key ?? null;
}

// Editable branch defaults of a profile; fields it has no opinion on stay blank.
export function defaultsFromProfile(profile: BusinessProfile | undefined): SetupDefaults {
  const source = profile?.branch_defaults ?? {};
  const text = (value: unknown) =>
    typeof value === 'number' && Number.isFinite(value)
      ? String(value)
      : typeof value === 'string'
        ? value.trim()
        : '';
  return {
    return_window_days: text(source.return_window_days),
    lot_selection: source.lot_selection === 'cashier_pick' ? 'cashier_pick' : 'fefo',
    variance_threshold: text(source.variance_threshold).replace(/\.0+$/, ''),
    adjustment_approval_threshold: text(source.adjustment_approval_threshold),
  };
}

// Risky features the industry usually uses, as the client knows them. Unknown
// keys from a newer server are left out rather than shown without a label.
export function recommendedFeatures(profile: BusinessProfile | undefined): PosFeature[] {
  return (profile?.recommended_features ?? []).filter(isPosFeature);
}

const CODE_MAX = 32;
const CODE_PATTERN = /^[a-z0-9][a-z0-9_-]{0,31}$/;

// A branch code from its name: Vietnamese letters lose their marks (đ → d),
// anything else becomes a dash, at most 32 characters, as `POST /branches`
// accepts (`[a-z0-9][a-z0-9_-]{0,31}`). A name with no letter or digit gives
// "chi-nhanh-1".
export function branchCodeFrom(name: string): string {
  const slug = name
    .normalize('NFD')
    .replace(/[̀-ͯ]/g, '')
    .replace(/[đĐ]/g, 'd')
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+/, '')
    .slice(0, CODE_MAX)
    .replace(/-+$/, '');
  return slug || 'chi-nhanh-1';
}

export function validBranchCode(code: string): boolean {
  return CODE_PATTERN.test(code);
}

export function validDays(text: string): boolean {
  const value = text.trim();
  return value === '' || (/^\d{1,4}$/.test(value) && Number(value) <= 3650);
}

export function validCount(text: string): boolean {
  const value = text.trim();
  return value === '' || /^\d{1,9}$/.test(value);
}

export function validAmount(text: string): boolean {
  const value = text.trim().replace(/\.0+$/, '');
  return value === '' || /^\d{1,15}$/.test(value);
}

export type SetupAction =
  | { type: 'choose'; key: string; profiles: BusinessProfile[] }
  | { type: 'answer-interest'; sellsGoods: boolean; profiles: BusinessProfile[] }
  | { type: 'remove-interest'; key: string }
  | { type: 'wholesale'; value: boolean }
  | { type: 'branch-name'; value: string }
  | { type: 'branch-code'; value: string }
  | { type: 'timezone'; value: string }
  | { type: 'stock-location'; value: string }
  | { type: 'register-name'; value: string }
  | { type: 'grant-self'; value: boolean }
  | { type: 'default'; field: keyof SetupDefaults; value: string }
  | { type: 'feature'; feature: PosFeature; value: boolean }
  | { type: 'shop-init'; value: ShopSetup }
  | { type: 'station-name'; index: number; value: string }
  | { type: 'station-kind'; index: number; value: ShopStationKind }
  | { type: 'station-add'; name: string }
  | { type: 'station-remove'; index: number }
  | { type: 'shop-tax'; role: 'food' | 'alcohol'; value: string }
  | { type: 'shop-trigger'; value: KitchenSendTrigger }
  | { type: 'go'; step: SetupStep };

function withProfile(state: SetupState, key: string, profiles: BusinessProfile[]): SetupState {
  if (state.profileKey === key) return state;
  const profile = profiles.find((item) => item.key === key);
  // Another industry brings its own defaults; ticked features it does not
  // recommend are dropped so nothing is turned on unseen.
  const recommended = recommendedFeatures(profile);
  return {
    ...state,
    profileKey: key,
    defaults: defaultsFromProfile(profile),
    features: state.features.filter((feature) => recommended.includes(feature)),
    shop: null,
  };
}

function withShop(state: SetupState, change: (shop: ShopSetup) => ShopSetup): SetupState {
  return state.shop ? { ...state, shop: change(state.shop) } : state;
}

function editStation(
  state: SetupState,
  index: number,
  change: Partial<ShopSetup['stations'][number]>,
): SetupState {
  return withShop(state, (shop) => ({
    ...shop,
    stations: shop.stations.map((row, at) => (at === index ? { ...row, ...change } : row)),
  }));
}

export function setupReducer(state: SetupState, action: SetupAction): SetupState {
  switch (action.type) {
    case 'choose': {
      const profile = action.profiles.find((item) => item.key === action.key);
      if (isAvailable(profile))
        return {
          ...withProfile(state, profile.key, action.profiles),
          choice: profile.key,
          declined: false,
        };
      if (isComingSoon(profile)) return { ...state, choice: action.key, declined: false };
      return state;
    }
    case 'answer-interest': {
      const choice = state.choice;
      const profile = action.profiles.find((item) => item.key === choice);
      if (!choice || !isComingSoon(profile)) return state;
      const interests = state.interests.includes(choice)
        ? state.interests
        : [...state.interests, choice];
      if (!action.sellsGoods) return { ...state, interests, declined: true };
      const retail = suggestedRetailProfile(choice, action.profiles);
      if (!retail) return { ...state, interests, declined: true };
      return {
        ...withProfile({ ...state, interests }, retail, action.profiles),
        choice: retail,
        declined: false,
      };
    }
    case 'remove-interest':
      return { ...state, interests: state.interests.filter((key) => key !== action.key) };
    case 'wholesale':
      return { ...state, wholesale: action.value };
    case 'branch-name': {
      const code = state.branch.codeEdited
        ? state.branch.code
        : action.value.trim()
          ? branchCodeFrom(action.value)
          : '';
      return { ...state, branch: { ...state.branch, name: action.value, code } };
    }
    case 'branch-code':
      return {
        ...state,
        branch: {
          ...state.branch,
          code: action.value.trim().toLowerCase(),
          codeEdited: action.value.trim() !== '',
        },
      };
    case 'timezone':
      return { ...state, branch: { ...state.branch, timezone: action.value } };
    case 'stock-location':
      return { ...state, branch: { ...state.branch, stockLocationId: action.value } };
    case 'register-name':
      return { ...state, registerName: action.value };
    case 'grant-self':
      return { ...state, grantSelf: action.value };
    case 'default':
      return { ...state, defaults: { ...state.defaults, [action.field]: action.value } };
    case 'feature':
      return {
        ...state,
        features: action.value
          ? state.features.includes(action.feature)
            ? state.features
            : [...state.features, action.feature]
          : state.features.filter((feature) => feature !== action.feature),
      };
    case 'shop-init':
      // Kept while the profile stays the same, so going back keeps the edits.
      return state.shop?.profileKey === action.value.profileKey
        ? state
        : { ...state, shop: action.value };
    case 'station-name':
      return editStation(state, action.index, { name: action.value });
    case 'station-kind':
      return editStation(state, action.index, { kind: action.value });
    case 'station-add':
      return withShop(state, (shop) =>
        shop.stations.length >= MAX_STATIONS
          ? shop
          : { ...shop, stations: [...shop.stations, { kind: 'prep', name: action.name }] },
      );
    case 'station-remove':
      return withShop(state, (shop) => ({
        ...shop,
        stations: shop.stations.filter((_, index) => index !== action.index),
      }));
    case 'shop-tax':
      return withShop(state, (shop) =>
        action.role === 'food'
          ? { ...shop, foodTax: action.value }
          : { ...shop, alcoholTax: action.value },
      );
    case 'shop-trigger':
      return withShop(state, (shop) => ({ ...shop, trigger: action.value }));
    case 'go':
      return { ...state, step: action.step };
  }
}

export type SetupProblem =
  | 'profile'
  | 'name'
  | 'code'
  | 'timezone'
  | 'location'
  | 'no-locations'
  | 'return-window'
  | 'variance'
  | 'adjustment'
  | 'station-name'
  | 'station-duplicate'
  | 'tax';

// What keeps a step from moving on, in the order the fields appear.
export function stepProblems(
  state: SetupState,
  step: SetupStep,
  options: { profiles: BusinessProfile[]; locationIds: string[] },
): SetupProblem[] {
  const problems: SetupProblem[] = [];
  const profile = options.profiles.find((item) => item.key === state.profileKey);
  if (!isAvailable(profile) || state.choice !== state.profileKey) problems.push('profile');
  if (step === 1 || step === 2) return problems;
  if (!state.branch.name.trim()) problems.push('name');
  if (!validBranchCode(state.branch.code)) problems.push('code');
  if (!state.branch.timezone.trim()) problems.push('timezone');
  if (options.locationIds.length === 0) problems.push('no-locations');
  else if (!options.locationIds.includes(state.branch.stockLocationId)) problems.push('location');
  if (step === 3) return problems;
  if (!validDays(state.defaults.return_window_days)) problems.push('return-window');
  if (!validAmount(state.defaults.variance_threshold)) problems.push('variance');
  if (!validCount(state.defaults.adjustment_approval_threshold)) problems.push('adjustment');
  if (step === 4 || !hasShopStep(profile)) return problems;
  problems.push(...shopProblems(state.shop));
  return problems;
}

// Station names filled, short enough and distinct; both tax choices made.
export function shopProblems(shop: ShopSetup | null): SetupProblem[] {
  if (!shop) return [];
  const problems: SetupProblem[] = [];
  const names = shop.stations.map((row) => row.name.trim());
  if (names.some((name) => !name || name.length > STATION_NAME_MAX)) problems.push('station-name');
  if (new Set(names.map((name) => name.toLowerCase())).size !== names.length)
    problems.push('station-duplicate');
  if (!shop.foodTax || !shop.alcoholTax) problems.push('tax');
  return problems;
}

// Which defaults the preview offers to edit: the return window always, lot
// picking only with serial/lot tracking, thresholds only when the industry
// presets them.
export function editableDefaults(profile: BusinessProfile | undefined): (keyof SetupDefaults)[] {
  const fields: (keyof SetupDefaults)[] = ['return_window_days'];
  const defaults = profile?.branch_defaults ?? {};
  if (profile?.modules.includes('retail.traceability') || 'lot_selection' in defaults)
    fields.push('lot_selection');
  if ('variance_threshold' in defaults) fields.push('variance_threshold');
  if ('adjustment_approval_threshold' in defaults) fields.push('adjustment_approval_threshold');
  return fields;
}

export type OnboardingPayload = {
  profile_key: string;
  wholesale: boolean;
  interests: string[];
  branch: Record<string, string | number | null>;
  register?: { name: string };
  grant_self: boolean;
  features: PosFeature[];
  fnb_setup?: {
    stations: { name: string; kind: ShopStationKind }[];
    tax_categories: { food: string; alcohol: string };
    kitchen_send_trigger?: KitchenSendTrigger;
  };
};

// The body of `POST /pos/onboarding`. Every branch default the preview showed
// is sent as edited (a sent field, null included, wins over the profile's),
// so the branch gets exactly what the owner saw. A blank register name sends
// no register.
export function onboardingPayload(state: SetupState, profile: BusinessProfile): OnboardingPayload {
  const fields = editableDefaults(profile);
  const number = (text: string) => (text.trim() === '' ? null : Number(text.trim()));
  const branch: OnboardingPayload['branch'] = {
    name: state.branch.name.trim(),
    code: state.branch.code.trim(),
    timezone: state.branch.timezone.trim(),
    stock_location_id: state.branch.stockLocationId,
    return_window_days: number(state.defaults.return_window_days),
  };
  if (fields.includes('lot_selection')) branch.lot_selection = state.defaults.lot_selection;
  if (fields.includes('variance_threshold'))
    branch.variance_threshold = number(state.defaults.variance_threshold.replace(/\.0+$/, ''));
  if (fields.includes('adjustment_approval_threshold'))
    branch.adjustment_approval_threshold = number(state.defaults.adjustment_approval_threshold);
  const recommended = recommendedFeatures(profile);
  const registerName = state.registerName.trim();
  return {
    profile_key: profile.key,
    wholesale: state.wholesale,
    interests: [...state.interests],
    branch,
    ...(registerName ? { register: { name: registerName } } : {}),
    grant_self: state.grantSelf,
    // Only what the owner ticked, and only among what the industry recommends.
    features: state.features.filter((feature) => recommended.includes(feature)),
    ...shopPayload(state, profile),
  };
}

// The shop step as `fnb_setup`, only for a profile with the menu and only
// once the step was shown for it.
function shopPayload(
  state: SetupState,
  profile: BusinessProfile,
): Pick<OnboardingPayload, 'fnb_setup'> {
  const shop = state.shop;
  if (!hasShopStep(profile) || !shop || shop.profileKey !== profile.key) return {};
  const kitchen = hasKitchen(profile);
  return {
    fnb_setup: {
      stations: kitchen
        ? shop.stations.map((row) => ({ name: row.name.trim(), kind: row.kind }))
        : [],
      tax_categories: { food: shop.foodTax, alcohol: shop.alcoholTax },
      ...(kitchen ? { kitchen_send_trigger: shop.trigger } : {}),
    },
  };
}

// The new branch and register to select after setup, from the 201 body.
export function onboardingSelection(
  data: unknown,
): { branchId: string; registerId: string | null } | null {
  if (typeof data !== 'object' || data === null) return null;
  const record = data as { branch?: { id?: unknown } | null; register?: { id?: unknown } | null };
  const branchId = record.branch?.id;
  if (typeof branchId !== 'string' || !branchId) return null;
  const registerId = record.register?.id;
  return { branchId, registerId: typeof registerId === 'string' && registerId ? registerId : null };
}
