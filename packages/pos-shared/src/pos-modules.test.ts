import { describe, expect, it } from 'vitest';
import en from './locales/en.json';
import vi from './locales/vi.json';
import {
  catalogViewOf,
  contextModule,
  LABELLED_MODULES,
  moduleEnabled,
  moduleInUse,
  moduleLabelKey,
  normalizeBusinessProfiles,
  normalizeModules,
  normalizeModuleUsage,
  normalizeOnboarding,
  normalizeProfile,
  profileDescriptionKey,
  profileLabelKey,
  profileModules,
  sellingLayoutOf,
  sellingSurfaceOf,
  tablesOptional,
} from './pos-modules';
import { describeFailure, moduleDisabledText } from './request-failure';
import { describeInventoryFailure, describeTraceFailure } from './traceability';

const translate = (key: string) => key;
const refusal = (details: Record<string, unknown>) => ({
  status: 409,
  message: 'Module retail.traceability is turned off.',
  details: { reason: 'module_disabled', ...details },
});

describe('branch modules', () => {
  it('hides nothing when the server sends no modules', () => {
    for (const key of [...LABELLED_MODULES, 'wholesale']) {
      expect(moduleEnabled(undefined, key)).toBe(true);
      expect(moduleEnabled(null, key)).toBe(true);
      expect(contextModule(undefined, key)).toBe(true);
      expect(contextModule({}, key)).toBe(true);
      expect(contextModule({ modules: null }, key)).toBe(true);
    }
  });

  it('turns a module on only for an explicit true once modules are sent', () => {
    const modules = normalizeModules({
      'retail.units': true,
      'retail.measured': false,
      'retail.traceability': 'yes',
      wholesale: true,
      '': true,
    });
    // Unknown keys stay (the server owns the catalogue); off and malformed go.
    expect(modules).toEqual({ 'retail.units': true, wholesale: true });
    expect(moduleEnabled(modules, 'retail.units')).toBe(true);
    expect(moduleEnabled(modules, 'wholesale')).toBe(true);
    expect(moduleEnabled(modules, 'retail.measured')).toBe(false);
    expect(moduleEnabled(modules, 'retail.traceability')).toBe(false);
    // A branch with no module on, and a key the server never sent.
    expect(moduleEnabled({}, 'retail.units')).toBe(false);
    expect(moduleEnabled(modules, 'toString')).toBe(false);
    expect(contextModule({ modules: { 'retail.units': false } }, 'retail.units')).toBe(false);
  });

  it('reads no modules from a value that is not an object', () => {
    expect(normalizeModules(undefined)).toBeNull();
    expect(normalizeModules(null)).toBeNull();
    expect(normalizeModules(['retail.units'])).toBeNull();
    expect(normalizeModules('retail.units')).toBeNull();
  });

  it('keeps an entry in use only for an explicit true', () => {
    expect(normalizeModuleUsage(undefined)).toEqual({});
    expect(normalizeModuleUsage({ 'retail.traceability': true, other: 1 })).toEqual({
      'retail.traceability': true,
    });
    expect(moduleInUse(undefined, 'retail.traceability')).toBe(false);
    expect(moduleInUse({ module_usage: null }, 'retail.traceability')).toBe(false);
    expect(
      moduleInUse({ module_usage: { 'retail.traceability': true } }, 'retail.traceability'),
    ).toBe(true);
  });
});

describe('branch profile', () => {
  it('reads the profile of the selected branch and its catalogue view', () => {
    const pharmacy = normalizeProfile({
      key: 'nha_thuoc',
      version: 1,
      display: { catalog_view: 'list' },
    });
    expect(pharmacy).toEqual({ key: 'nha_thuoc', version: 1, display: { catalog_view: 'list' } });
    expect(catalogViewOf({ profile: pharmacy })).toBe('list');
    expect(
      catalogViewOf({
        profile: normalizeProfile({ key: 'thoi_trang', display: { catalog_view: 'cards' } }),
      }),
    ).toBe('cards');
  });

  it('opens cards without a profile, a hint, or with a view it does not know', () => {
    expect(catalogViewOf(undefined)).toBe('cards');
    expect(catalogViewOf({ profile: null })).toBe('cards');
    const retired = normalizeProfile({ key: 'retired_profile', version: 1, display: {} });
    expect(retired).toEqual({ key: 'retired_profile', version: 1, display: {} });
    expect(catalogViewOf({ profile: retired })).toBe('cards');
    const odd = normalizeProfile({ key: 'x', version: '2', display: { catalog_view: 'grid' } });
    expect(odd).toEqual({ key: 'x', version: null, display: {} });
    expect(normalizeProfile(null)).toBeNull();
    expect(normalizeProfile({ version: 1 })).toBeNull();
  });

  it('reads the first-run setup flags', () => {
    expect(normalizeOnboarding({ required: true, can_setup: false })).toEqual({
      required: true,
      can_setup: false,
    });
    expect(normalizeOnboarding({ required: 'yes' })).toEqual({ required: false, can_setup: false });
    expect(normalizeOnboarding(undefined)).toBeNull();
  });
});

describe('business profile catalogue', () => {
  it('orders the profiles and keeps what the server sent', () => {
    const catalog = normalizeBusinessProfiles({
      version: 1,
      modules: [
        {
          key: 'retail.measured',
          group: 'retail',
          status: 'available',
          depends_on: ['retail.units'],
        },
        { key: 'fnb.menu', group: 'fnb', status: 'planned', depends_on: [] },
        { group: 'retail' },
      ],
      profiles: [
        {
          key: 'thoi_trang',
          group: 'retail',
          order: 2,
          status: 'available',
          modules: [],
          branch_defaults: { return_window_days: 7 },
          display: { catalog_view: 'cards' },
          recommended_features: ['returns'],
          sample_units: [],
        },
        {
          key: 'quan_an',
          group: 'fnb',
          order: 14,
          status: 'coming_soon',
          modules: ['fnb.menu'],
          branch_defaults: {},
          display: {},
          recommended_features: [],
          sample_units: [],
        },
        {
          key: 'tap_hoa_sieu_thi',
          group: 'retail',
          order: 1,
          status: 'available',
          modules: ['retail.units', 7],
          branch_defaults: null,
          display: { catalog_view: 'list' },
          recommended_features: 'credit',
          sample_units: ['pack'],
        },
        { order: 3 },
      ],
    });
    expect(catalog.version).toBe(1);
    expect(catalog.modules.map((row) => row.key)).toEqual(['retail.measured', 'fnb.menu']);
    expect(catalog.modules[0].depends_on).toEqual(['retail.units']);
    expect(catalog.profiles.map((row) => row.key)).toEqual([
      'tap_hoa_sieu_thi',
      'thoi_trang',
      'quan_an',
    ]);
    expect(catalog.profiles[0]).toMatchObject({
      modules: ['retail.units'],
      branch_defaults: {},
      display: { catalog_view: 'list' },
      recommended_features: [],
      sample_units: ['pack'],
    });
    expect(catalog.profiles[2]).toMatchObject({
      status: 'coming_soon',
      display: {},
      kitchen_stations: [],
    });
  });

  it('reads the selling surface, the proposed stations and the tax choices', () => {
    const catalog = normalizeBusinessProfiles({
      profiles: [
        {
          key: 'cafe_tra_sua',
          display: { surface: 'menu_grid', catalog_view: 'tiles' },
          kitchen_stations: ['prep', 'bar', 3],
        },
      ],
      tax_categories: [{ code: 'vat_food', rate: '0.08' }, { code: 7 }],
      menu_tax_defaults: { food: 'vat_food', alcohol: 'vat_special', other: 1 },
    });
    expect(catalog.profiles[0]).toMatchObject({
      display: { surface: 'menu_grid' },
      kitchen_stations: ['prep', 'bar'],
    });
    expect(catalog.tax_categories).toEqual([{ code: 'vat_food', rate: '0.08' }]);
    expect(catalog.menu_tax_defaults).toEqual({ food: 'vat_food', alcohol: 'vat_special' });
  });

  it('adds the optional table modules only for a shop that serves tables', () => {
    const catalog = normalizeBusinessProfiles({
      profiles: [
        {
          key: 'quan_an',
          modules: ['fnb.menu'],
          optional_modules: ['fnb.tables', 'fnb.postpay', 9],
        },
        { key: 'thoi_trang', modules: ['retail.variants'] },
      ],
    });
    const [eatery, fashion] = catalog.profiles;
    expect(eatery.optional_modules).toEqual(['fnb.tables', 'fnb.postpay']);
    expect(fashion.optional_modules).toEqual([]);
    expect(tablesOptional(eatery)).toBe(true);
    expect(tablesOptional(fashion)).toBe(false);
    expect(profileModules(eatery, true)).toEqual(['fnb.menu', 'fnb.tables', 'fnb.postpay']);
    expect(profileModules(eatery, false)).toEqual(['fnb.menu']);
  });

  it('sells from the menu only with fnb.menu on and no catalogue preference', () => {
    const profile = (surface?: string) => normalizeProfile({ key: 'p', display: { surface } });
    const on = { 'fnb.menu': true };
    expect(sellingSurfaceOf({ modules: on, profile: profile('menu_grid') })).toBe('menu_grid');
    expect(sellingSurfaceOf({ modules: on, profile: profile() })).toBe('menu_grid');
    expect(sellingSurfaceOf({ modules: on, profile: profile('catalog') })).toBe('catalog');
    expect(sellingSurfaceOf({ modules: {}, profile: profile('menu_grid') })).toBe('catalog');
    expect(sellingSurfaceOf({ modules: null, profile: profile('menu_grid') })).toBe('catalog');
    expect(sellingSurfaceOf(undefined)).toBe('catalog');
    // A table surface still picks items from the menu.
    expect(sellingSurfaceOf({ modules: on, profile: profile('floor_plan') })).toBe('menu_grid');
    expect(profile('table_grid')?.display).toEqual({ surface: 'table_grid' });
    expect(profile('kiosk')?.display).toEqual({});
  });

  it('serves tables and timed rooms on their own screen unless the profile starts on tabs', () => {
    const profile = (surface?: string) => normalizeProfile({ key: 'p', display: { surface } });
    const tables = { 'fnb.tables': true, 'fnb.menu': true };
    // No table module: the counter, whatever the profile suggests.
    expect(sellingLayoutOf(undefined)).toBe('counter');
    expect(sellingLayoutOf({ modules: null, profile: profile('floor_plan') })).toBe('counter');
    expect(sellingLayoutOf({ modules: { 'fnb.tables': false }, profile: profile() })).toBe(
      'counter',
    );
    // Tables on a floor plan or tiles, and an eatery whose profile starts on the menu.
    expect(sellingLayoutOf({ modules: tables, profile: profile('floor_plan') })).toBe(
      'table_service',
    );
    expect(sellingLayoutOf({ modules: tables, profile: profile('table_grid') })).toBe(
      'table_service',
    );
    expect(sellingLayoutOf({ modules: tables, profile: profile('menu_grid') })).toBe(
      'table_service',
    );
    expect(sellingLayoutOf({ modules: tables, profile: null })).toBe('table_service');
    // A board of timed rooms is a frame of table service, a karaoke's
    // postpaid clocks included; a bar's open tabs keep the counter layout.
    expect(sellingLayoutOf({ modules: tables, profile: profile('resource_board') })).toBe(
      'table_service',
    );
    expect(
      sellingLayoutOf({
        modules: { ...tables, timed_billing: true, 'fnb.postpay': true },
        profile: profile('resource_board'),
      }),
    ).toBe('table_service');
    expect(sellingLayoutOf({ modules: tables, profile: profile('tab_list') })).toBe('counter');
  });

  it('sells at the quick counter where the menu runs without tables', () => {
    const profile = (surface?: string) => normalizeProfile({ key: 'p', display: { surface } });
    const cafe = {
      'fnb.menu': true,
      'fnb.kitchen': true,
      'fnb.order_number': true,
      'fnb.cup_label': true,
      'fnb.delivery_platforms': true,
    };
    // A cafe, and an eatery that does not serve tables, whatever the profile hints.
    expect(sellingLayoutOf({ modules: cafe, profile: profile('menu_grid') })).toBe('quick_counter');
    expect(sellingLayoutOf({ modules: { 'fnb.menu': true }, profile: profile('floor_plan') })).toBe(
      'quick_counter',
    );
    expect(sellingLayoutOf({ modules: { 'fnb.menu': true, 'fnb.tables': false } })).toBe(
      'quick_counter',
    );
    // A canteen and a rest stop: meal codes and coach visits live on the quick counter.
    const canteen = {
      'fnb.menu': true,
      'fnb.kitchen': true,
      'fnb.order_number': true,
      'retail.units': true,
      'fnb.meal_accounts': true,
      'fnb.vehicle_commission': true,
    };
    expect(sellingLayoutOf({ modules: canteen, profile: profile('menu_grid') })).toBe(
      'quick_counter',
    );
    expect(sellingLayoutOf({ modules: { 'fnb.menu': true, 'fnb.meal_accounts': true } })).toBe(
      'quick_counter',
    );
    expect(
      sellingLayoutOf({
        modules: { 'fnb.menu': true, 'fnb.vehicle_commission': true },
        profile: profile('menu_grid'),
      }),
    ).toBe('quick_counter');
    // Without the menu, meal codes and coaches stay on the counter, and so
    // does a canteen whose orders are paid later.
    expect(
      sellingLayoutOf({
        modules: { 'retail.units': true, 'fnb.meal_accounts': true },
        profile: profile('catalog'),
      }),
    ).toBe('counter');
    expect(
      sellingLayoutOf({
        modules: { ...canteen, 'fnb.postpay': true },
        profile: profile('menu_grid'),
      }),
    ).toBe('counter');
    // Open tabs and timed rooms stay open across guests: without tables, the counter.
    expect(sellingLayoutOf({ modules: { 'fnb.menu': true }, profile: profile('tab_list') })).toBe(
      'counter',
    );
    expect(
      sellingLayoutOf({ modules: { 'fnb.menu': true }, profile: profile('resource_board') }),
    ).toBe('counter');
    expect(sellingLayoutOf({ modules: { 'fnb.menu': true, timed_billing: true } })).toBe('counter');
    expect(sellingLayoutOf({ modules: { 'fnb.menu': true, 'fnb.postpay': true } })).toBe('counter');
    // A profile that keeps the catalogue sells from search on the counter.
    expect(sellingLayoutOf({ modules: cafe, profile: profile('catalog') })).toBe('counter');
    // Retail, with the menu off or absent, keeps the counter.
    expect(
      sellingLayoutOf({ modules: { 'retail.units': true }, profile: profile('catalog') }),
    ).toBe('counter');
    expect(sellingLayoutOf({ modules: { 'fnb.menu': false }, profile: profile('menu_grid') })).toBe(
      'counter',
    );
    expect(sellingLayoutOf({ modules: {} })).toBe('counter');
  });

  it('reads an empty catalogue from anything else', () => {
    const empty = {
      version: null,
      modules: [],
      profiles: [],
      tax_categories: [],
      menu_tax_defaults: {},
    };
    expect(normalizeBusinessProfiles(undefined)).toEqual(empty);
    expect(normalizeBusinessProfiles([])).toEqual(empty);
  });
});

describe('module and profile labels', () => {
  // Mirrors server/config/pos/business_profiles.yml: every profile the server
  // offers has a label and a description in both languages.
  const PROFILES = [
    'tap_hoa_sieu_thi',
    'thoi_trang',
    'dien_tu_dien_may',
    'vat_lieu_xay_dung',
    'nong_san_thuc_pham',
    'nha_thuoc',
    'xe_may_moc',
    'my_pham',
    'noi_that_gia_dung',
    'me_be',
    'sach_van_phong_pham',
    'hoa_qua_tang',
    'khac',
    'quan_an',
    'cafe_tra_sua',
    'karaoke_bida',
    'bar_pub_club',
    'cang_tin_tram_dung',
    'nha_hang',
  ];
  const lookup = (bundle: unknown, key: string) =>
    key
      .split('.')
      .reduce<unknown>(
        (node, part) => (node as Record<string, unknown> | undefined)?.[part],
        bundle,
      );

  it('labels and describes all 19 profiles in Vietnamese and English', () => {
    expect(Object.keys(vi.profiles).sort()).toEqual([...PROFILES].sort());
    expect(Object.keys(en.profiles).sort()).toEqual([...PROFILES].sort());
    for (const key of PROFILES)
      for (const bundle of [vi, en]) {
        expect(lookup(bundle, profileLabelKey(key))).toEqual(expect.any(String));
        expect(lookup(bundle, profileDescriptionKey(key))).toEqual(expect.any(String));
      }
  });

  it('labels every module it knows, with its off note and refusal', () => {
    for (const key of LABELLED_MODULES) {
      const label = moduleLabelKey(key);
      expect(label).toBe(`posModules.${key.replaceAll('.', '_')}.label`);
      for (const bundle of [vi, en])
        for (const part of ['label', 'description', 'off', 'disabled'])
          expect(lookup(bundle, `posModules.${key.replaceAll('.', '_')}.${part}`)).toEqual(
            expect.any(String),
          );
    }
    expect(moduleLabelKey('wholesale')).toBeNull();
    expect(Object.keys(vi.posModules).sort()).toEqual(Object.keys(en.posModules).sort());
  });
});

describe('module_disabled refusals', () => {
  it('names the module the server refused, on every setup screen', () => {
    expect(moduleDisabledText(refusal({ module: 'retail.traceability' }), translate)).toBe(
      'posModules.retail_traceability.disabled',
    );
    expect(describeFailure(refusal({ module: 'retail.measured' }), translate)).toBe(
      'posModules.retail_measured.disabled',
    );
    expect(describeTraceFailure(refusal({ module: 'retail.units' }), translate)).toBe(
      'posModules.retail_units.disabled',
    );
    expect(describeInventoryFailure(refusal({ module: 'retail.traceability' }), translate)).toBe(
      'posModules.retail_traceability.disabled',
    );
  });

  it('falls back to the generic text for a missing or unknown module', () => {
    expect(describeFailure(refusal({}), translate)).toBe('moduleDisabled');
    expect(describeFailure(refusal({ module: 'wholesale' }), translate)).toBe('moduleDisabled');
  });

  it('leaves other refusals alone', () => {
    const feature = { status: 409, details: { reason: 'feature_disabled', feature: 'credit' } };
    expect(moduleDisabledText(feature, translate)).toBeNull();
    expect(describeFailure(feature, translate)).toBe('featureDisabled_credit');
    expect(
      moduleDisabledText({ status: 422, details: { reason: 'module_disabled' } }, translate),
    ).toBeNull();
  });
});
