import { describe, expect, it } from 'vitest';
import en from './locales/en.json';
import vi from './locales/vi.json';
import {
  type BusinessModule,
  type BusinessProfile,
  modulesEnabledWith,
  modulesRequiring,
} from './pos-modules';
import {
  branchCodeFrom,
  defaultsFromProfile,
  editableDefaults,
  initialSetup,
  nextStep,
  onboardingPayload,
  onboardingSelection,
  previousStep,
  type SetupAction,
  type SetupState,
  setupReducer,
  setupSteps,
  shopDefaults,
  stepProblems,
  suggestedRetailProfile,
  tablesOn,
  validBranchCode,
} from './setup-wizard';

function profile(key: string, extra: Partial<BusinessProfile> = {}): BusinessProfile {
  return {
    key,
    group: 'retail',
    order: 1,
    status: 'available',
    modules: [],
    branch_defaults: {},
    display: {},
    recommended_features: [],
    sample_units: [],
    kitchen_stations: [],
    optional_modules: [],
    ...extra,
  };
}

// The catalogue as the server sends it (phase 1 table), trimmed to what the
// wizard reads.
const PROFILES: BusinessProfile[] = [
  profile('tap_hoa_sieu_thi', {
    order: 1,
    modules: ['retail.units', 'retail.measured', 'retail.traceability'],
    branch_defaults: { return_window_days: 7, lot_selection: 'fefo' },
    recommended_features: ['credit', 'vietqr', 'customer_display'],
    sample_units: ['pack', 'case', 'kg'],
  }),
  profile('thoi_trang', {
    order: 2,
    branch_defaults: { return_window_days: 7 },
    recommended_features: ['returns', 'refunds', 'exchanges', 'vietqr'],
  }),
  profile('nha_thuoc', {
    order: 6,
    modules: ['retail.units', 'retail.traceability'],
    branch_defaults: { return_window_days: 7, lot_selection: 'fefo' },
    display: { catalog_view: 'list' },
    recommended_features: ['traceability', 'returns', 'refunds', 'future_flag'],
    sample_units: ['vien', 'vi', 'hop', 'chai'],
  }),
  profile('khac', {
    order: 13,
    modules: ['retail.units', 'retail.measured', 'retail.traceability'],
  }),
  profile('karaoke_bida', {
    group: 'fnb',
    order: 16,
    status: 'coming_soon',
    modules: ['resources', 'timed_billing', 'fnb.menu'],
  }),
  profile('cafe_tra_sua', {
    group: 'fnb',
    order: 15,
    modules: ['retail.units', 'fnb.menu', 'fnb.kitchen', 'fnb.order_number', 'fnb.cup_label'],
    branch_defaults: { kitchen_send_trigger: 'on_complete' },
    display: { surface: 'menu_grid' },
    kitchen_stations: ['prep', 'bar'],
  }),
  profile('cang_tin_tram_dung', {
    group: 'fnb',
    order: 18,
    status: 'coming_soon',
    modules: ['fnb.menu', 'retail.units'],
  }),
];

function run(actions: SetupAction[], state: SetupState = initialSetup('Asia/Ho_Chi_Minh')) {
  return actions.reduce(setupReducer, state);
}

const choose = (key: string): SetupAction => ({ type: 'choose', key, profiles: PROFILES });
const answer = (sellsGoods: boolean): SetupAction => ({
  type: 'answer-interest',
  sellsGoods,
  profiles: PROFILES,
});

describe('setup wizard state', () => {
  it('starts on step 1 with the store time zone, "Quầy 1", self grant ticked and no feature', () => {
    const state = initialSetup('Asia/Bangkok');
    expect(state).toMatchObject({
      step: 1,
      profileKey: null,
      interests: [],
      wholesale: false,
      registerName: 'Quầy 1',
      grantSelf: true,
      features: [],
      branch: { timezone: 'Asia/Bangkok', code: '', codeEdited: false },
    });
    expect(initialSetup(null).branch.timezone).toBe('Asia/Ho_Chi_Minh');
    expect(initialSetup('  ').branch.timezone).toBe('Asia/Ho_Chi_Minh');
  });

  it('a retail card picks the profile and its defaults', () => {
    const state = run([choose('nha_thuoc')]);
    expect(state.choice).toBe('nha_thuoc');
    expect(state.profileKey).toBe('nha_thuoc');
    expect(state.defaults).toEqual({
      return_window_days: '7',
      lot_selection: 'fefo',
      variance_threshold: '',
      adjustment_approval_threshold: '',
    });
    // Recommended features stay unticked (D6).
    expect(state.features).toEqual([]);
  });

  it('a coming-soon card asks first; yes records the interest and suggests a retail profile', () => {
    const asked = run([choose('karaoke_bida')]);
    expect(asked).toMatchObject({ choice: 'karaoke_bida', profileKey: null, interests: [] });
    expect(stepProblems(asked, 1, { profiles: PROFILES, locationIds: [] })).toEqual(['profile']);

    const yes = setupReducer(asked, answer(true));
    expect(yes).toMatchObject({
      choice: 'khac',
      profileKey: 'khac',
      interests: ['karaoke_bida'],
      declined: false,
    });
    expect(stepProblems(yes, 1, { profiles: PROFILES, locationIds: [] })).toEqual([]);

    // A canteen sells packaged goods like a grocery.
    const canteen = run([choose('cang_tin_tram_dung'), answer(true)]);
    expect(canteen).toMatchObject({
      profileKey: 'tap_hoa_sieu_thi',
      interests: ['cang_tin_tram_dung'],
    });
  });

  it('no keeps the interest, creates nothing, and blocks step 1 until a retail card is chosen', () => {
    const declined = run([choose('karaoke_bida'), answer(false)]);
    expect(declined).toMatchObject({
      declined: true,
      profileKey: null,
      interests: ['karaoke_bida'],
    });
    expect(stepProblems(declined, 1, { profiles: PROFILES, locationIds: [] })).toEqual(['profile']);
    const picked = setupReducer(declined, choose('thoi_trang'));
    expect(picked).toMatchObject({
      declined: false,
      profileKey: 'thoi_trang',
      interests: ['karaoke_bida'],
    });
  });

  it('a coming-soon card after a retail one keeps the retail profile but blocks until answered', () => {
    const state = run([choose('thoi_trang'), choose('karaoke_bida')]);
    expect(state.profileKey).toBe('thoi_trang');
    expect(stepProblems(state, 1, { profiles: PROFILES, locationIds: [] })).toEqual(['profile']);
  });

  it('records each interest once and can drop one', () => {
    const state = run([
      choose('karaoke_bida'),
      answer(true),
      choose('karaoke_bida'),
      answer(true),
      choose('cang_tin_tram_dung'),
      answer(false),
    ]);
    expect(state.interests).toEqual(['karaoke_bida', 'cang_tin_tram_dung']);
    expect(setupReducer(state, { type: 'remove-interest', key: 'karaoke_bida' }).interests).toEqual(
      ['cang_tin_tram_dung'],
    );
  });

  it('ignores a key the catalogue does not have', () => {
    const state = initialSetup();
    expect(setupReducer(state, choose('unknown'))).toBe(state);
  });

  it('another industry replaces the defaults and drops features it does not recommend', () => {
    const state = run([
      choose('nha_thuoc'),
      { type: 'feature', feature: 'returns', value: true },
      { type: 'feature', feature: 'traceability', value: true },
      { type: 'default', field: 'return_window_days', value: '30' },
      choose('thoi_trang'),
    ]);
    expect(state.features).toEqual(['returns']);
    expect(state.defaults.return_window_days).toBe('7');
    expect(state.defaults.lot_selection).toBe('fefo');
    // Choosing the same card again keeps the edits.
    const edited = run(
      [{ type: 'default', field: 'return_window_days', value: '3' }, choose('thoi_trang')],
      state,
    );
    expect(edited.defaults.return_window_days).toBe('3');
  });

  it('features tick and untick without duplicates', () => {
    const state = run([
      choose('nha_thuoc'),
      { type: 'feature', feature: 'refunds', value: true },
      { type: 'feature', feature: 'refunds', value: true },
    ]);
    expect(state.features).toEqual(['refunds']);
    expect(
      setupReducer(state, { type: 'feature', feature: 'refunds', value: false }).features,
    ).toEqual([]);
  });
});

describe('branch code', () => {
  it('comes from the name without Vietnamese marks', () => {
    expect(branchCodeFrom('Nhà thuốc Hạnh Phúc')).toBe('nha-thuoc-hanh-phuc');
    expect(branchCodeFrom('Đại lý Đông Đô số 2')).toBe('dai-ly-dong-do-so-2');
    expect(branchCodeFrom('  --Cửa hàng #1!!  ')).toBe('cua-hang-1');
    expect(branchCodeFrom('Siêu thị Ánh Dương – Chi nhánh Quận Bình Thạnh')).toHaveLength(32);
    expect(validBranchCode(branchCodeFrom('Siêu thị Ánh Dương – Chi nhánh Quận Bình Thạnh'))).toBe(
      true,
    );
    // A cut never ends on a dash.
    expect(branchCodeFrom('aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa bbb')).toBe(
      'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    );
    expect(branchCodeFrom('***')).toBe('chi-nhanh-1');
  });

  it('follows the name until the owner edits it', () => {
    const named = run([{ type: 'branch-name', value: 'Nhà thuốc Minh Châu' }]);
    expect(named.branch.code).toBe('nha-thuoc-minh-chau');
    const edited = run(
      [
        { type: 'branch-code', value: 'MC-01' },
        { type: 'branch-name', value: 'Nhà thuốc khác' },
      ],
      named,
    );
    expect(edited.branch).toMatchObject({
      code: 'mc-01',
      codeEdited: true,
      name: 'Nhà thuốc khác',
    });
    // Clearing the code hands it back to the name.
    const cleared = run(
      [
        { type: 'branch-code', value: '' },
        { type: 'branch-name', value: 'Quận 3' },
      ],
      edited,
    );
    expect(cleared.branch).toMatchObject({ code: 'quan-3', codeEdited: false });
    expect(run([{ type: 'branch-name', value: '' }], cleared).branch.code).toBe('');
  });

  it('accepts what POST /branches accepts', () => {
    expect(validBranchCode('a')).toBe(true);
    expect(validBranchCode('cn_1-a')).toBe(true);
    expect(validBranchCode('-cn')).toBe(false);
    expect(validBranchCode('CN')).toBe(false);
    expect(validBranchCode('a'.repeat(33))).toBe(false);
    expect(validBranchCode('')).toBe(false);
  });
});

describe('step checks', () => {
  const ready = run([
    choose('nha_thuoc'),
    { type: 'branch-name', value: 'Nhà thuốc 1' },
    { type: 'stock-location', value: 'sloc_1' },
  ]);

  it('step 3 needs a name, a valid code, a time zone and an existing stock location', () => {
    expect(stepProblems(ready, 3, { profiles: PROFILES, locationIds: ['sloc_1'] })).toEqual([]);
    const blank = run(
      [
        { type: 'branch-name', value: ' ' },
        { type: 'branch-code', value: 'Bad code' },
        { type: 'timezone', value: '' },
        { type: 'stock-location', value: 'sloc_gone' },
      ],
      ready,
    );
    expect(stepProblems(blank, 3, { profiles: PROFILES, locationIds: ['sloc_1'] })).toEqual([
      'name',
      'code',
      'timezone',
      'location',
    ]);
  });

  it('a store without stock locations cannot go past step 3', () => {
    expect(stepProblems(ready, 3, { profiles: PROFILES, locationIds: [] })).toEqual([
      'no-locations',
    ]);
    expect(stepProblems(ready, 2, { profiles: PROFILES, locationIds: [] })).toEqual([]);
  });

  it('step 4 checks the edited defaults', () => {
    const bad = run(
      [
        { type: 'default', field: 'return_window_days', value: '4000' },
        { type: 'default', field: 'variance_threshold', value: '1,5' },
        { type: 'default', field: 'adjustment_approval_threshold', value: '-1' },
      ],
      ready,
    );
    expect(stepProblems(bad, 4, { profiles: PROFILES, locationIds: ['sloc_1'] })).toEqual([
      'return-window',
      'variance',
      'adjustment',
    ]);
    expect(stepProblems(ready, 6, { profiles: PROFILES, locationIds: ['sloc_1'] })).toEqual([]);
  });
});

describe('onboarding payload', () => {
  const pharmacy = PROFILES.find((item) => item.key === 'nha_thuoc') as BusinessProfile;

  it('sends what the owner saw, with no risky feature unless ticked', () => {
    const state = run([
      choose('karaoke_bida'),
      answer(true),
      choose('nha_thuoc'),
      { type: 'branch-name', value: '  Nhà thuốc 1 ' },
      { type: 'stock-location', value: 'sloc_1' },
    ]);
    expect(onboardingPayload(state, pharmacy)).toEqual({
      profile_key: 'nha_thuoc',
      wholesale: false,
      interests: ['karaoke_bida'],
      branch: {
        name: 'Nhà thuốc 1',
        code: 'nha-thuoc-1',
        timezone: 'Asia/Ho_Chi_Minh',
        stock_location_id: 'sloc_1',
        return_window_days: 7,
        lot_selection: 'fefo',
      },
      register: { name: 'Quầy 1' },
      grant_self: true,
      features: [],
    });
  });

  it('keeps edits, drops a blank register, and only sends recommended ticked features', () => {
    const state = run([
      choose('nha_thuoc'),
      { type: 'wholesale', value: true },
      { type: 'branch-name', value: 'NT' },
      { type: 'stock-location', value: 'sloc_1' },
      { type: 'register-name', value: '   ' },
      { type: 'grant-self', value: false },
      { type: 'default', field: 'return_window_days', value: '' },
      { type: 'default', field: 'lot_selection', value: 'cashier_pick' },
      { type: 'feature', feature: 'returns', value: true },
      // Not recommended for this industry: never sent.
      { type: 'feature', feature: 'credit', value: true },
    ]);
    const payload = onboardingPayload(state, pharmacy);
    expect(payload).not.toHaveProperty('register');
    expect(payload).toMatchObject({
      wholesale: true,
      grant_self: false,
      features: ['returns'],
      branch: { return_window_days: null, lot_selection: 'cashier_pick' },
    });
  });

  it('a profile without tracking sends no lot picking', () => {
    const fashion = PROFILES.find((item) => item.key === 'thoi_trang') as BusinessProfile;
    const state = run([choose('thoi_trang'), { type: 'branch-name', value: 'Shop' }]);
    expect(editableDefaults(fashion)).toEqual(['return_window_days']);
    expect(onboardingPayload(state, fashion).branch).not.toHaveProperty('lot_selection');
  });

  it('thresholds a profile presets are offered and sent as numbers', () => {
    const custom = profile('custom', {
      branch_defaults: { variance_threshold: '50000.0', adjustment_approval_threshold: 5 },
    });
    expect(editableDefaults(custom)).toEqual([
      'return_window_days',
      'variance_threshold',
      'adjustment_approval_threshold',
    ]);
    expect(defaultsFromProfile(custom)).toMatchObject({
      variance_threshold: '50000',
      adjustment_approval_threshold: '5',
    });
    const state = {
      ...initialSetup(),
      profileKey: 'custom',
      defaults: defaultsFromProfile(custom),
    };
    expect(onboardingPayload(state, custom).branch).toMatchObject({
      return_window_days: null,
      variance_threshold: 50000,
      adjustment_approval_threshold: 5,
    });
  });

  it('the same answers give the same body, so a retry reuses the submission key', () => {
    const state = run([choose('nha_thuoc'), { type: 'branch-name', value: 'NT' }]);
    expect(JSON.stringify(onboardingPayload(state, pharmacy))).toBe(
      JSON.stringify(onboardingPayload({ ...state }, pharmacy)),
    );
  });

  it('reads the new branch and register from the answer', () => {
    expect(
      onboardingSelection({ branch: { id: 'posbranch_1' }, register: { id: 'posreg_1' } }),
    ).toEqual({
      branchId: 'posbranch_1',
      registerId: 'posreg_1',
    });
    expect(onboardingSelection({ branch: { id: 'posbranch_1' }, register: null })).toEqual({
      branchId: 'posbranch_1',
      registerId: null,
    });
    expect(onboardingSelection({ branch: null })).toBeNull();
    expect(onboardingSelection(null)).toBeNull();
  });
});

describe('suggested retail profile', () => {
  it('falls back to the first available profile when the preferred one is missing', () => {
    expect(suggestedRetailProfile('karaoke_bida', PROFILES)).toBe('khac');
    expect(suggestedRetailProfile('cang_tin_tram_dung', PROFILES)).toBe('tap_hoa_sieu_thi');
    expect(
      suggestedRetailProfile(
        'karaoke_bida',
        PROFILES.filter((item) => item.key !== 'khac'),
      ),
    ).toBe('tap_hoa_sieu_thi');
    expect(suggestedRetailProfile('karaoke_bida', [])).toBeNull();
  });
});

describe('module dependencies', () => {
  const catalogue: BusinessModule[] = [
    { key: 'retail.units', group: 'retail', status: 'available', depends_on: [] },
    { key: 'retail.measured', group: 'retail', status: 'available', depends_on: ['retail.units'] },
    { key: 'retail.traceability', group: 'retail', status: 'available', depends_on: [] },
  ];

  it('lists what switching a module on also switches on', () => {
    expect(modulesEnabledWith('retail.measured', catalogue, {})).toEqual(['retail.units']);
    expect(modulesEnabledWith('retail.measured', catalogue, { 'retail.units': true })).toEqual([]);
    expect(modulesEnabledWith('retail.traceability', catalogue, {})).toEqual([]);
    const chain: BusinessModule[] = [
      ...catalogue,
      { key: 'x.c', group: 'x', status: 'available', depends_on: ['retail.measured'] },
    ];
    expect(modulesEnabledWith('x.c', chain, {})).toEqual(['retail.measured', 'retail.units']);
  });

  it('lists modules that keep one from switching off', () => {
    expect(
      modulesRequiring('retail.units', catalogue, {
        'retail.units': true,
        'retail.measured': true,
      }),
    ).toEqual(['retail.measured']);
    expect(modulesRequiring('retail.units', catalogue, { 'retail.units': true })).toEqual([]);
    expect(
      modulesRequiring('retail.traceability', catalogue, { 'retail.traceability': true }),
    ).toEqual([]);
  });
});

describe('setup and business model texts', () => {
  type Tree = { [key: string]: string | Tree };
  function keys(tree: Tree, prefix = ''): string[] {
    return Object.entries(tree).flatMap(([key, value]) =>
      typeof value === 'string' ? [`${prefix}${key}`] : keys(value, `${prefix}${key}.`),
    );
  }
  // English splits counted texts into _one/_other; Vietnamese has one form.
  const base = (key: string) => key.replace(/_(one|other)$/, '');

  it('exist in both languages', () => {
    for (const section of ['setup'] as const) {
      const viKeys = new Set(keys((vi as unknown as Record<string, Tree>)[section]).map(base));
      const enKeys = new Set(keys((en as unknown as Record<string, Tree>)[section]).map(base));
      expect([...viKeys].filter((key) => !enKeys.has(key))).toEqual([]);
      expect([...enKeys].filter((key) => !viKeys.has(key))).toEqual([]);
    }
  });

  it('names every problem a step can report and every sample unit of the catalogue', () => {
    const setup = (vi as unknown as { setup: Record<string, unknown> }).setup;
    for (const problem of [
      'profile',
      'name',
      'code',
      'timezone',
      'location',
      'no-locations',
      'return-window',
      'variance',
      'adjustment',
      'station-name',
      'station-duplicate',
      'tax',
      'table-register',
    ])
      expect(setup).toHaveProperty([`problem_${problem}`]);
    const units = setup.unit as Record<string, string>;
    for (const code of [
      'pack',
      'case',
      'kg',
      'chai',
      'vien',
      'vi',
      'hop',
      'bao',
      'tam',
      'cay',
      'xe',
      'quyen',
      'ram',
      'bo',
      'bo_hoa',
      'gio',
    ])
      expect(units[code]).toBeTruthy();
  });
});

describe('the F&B shop step', () => {
  const cafe = PROFILES.find((item) => item.key === 'cafe_tra_sua') as BusinessProfile;
  const pharmacy = PROFILES.find((item) => item.key === 'nha_thuoc') as BusinessProfile;
  const catalogue = {
    tax_categories: [
      { code: 'vat_food', rate: '0.08' },
      { code: 'vat_special', rate: '0.1' },
    ],
    menu_tax_defaults: { food: 'vat_food', alcohol: 'vat_special' },
  };
  const names = (kind: string) => (kind === 'bar' ? 'Bar' : 'Bếp');
  const shop = shopDefaults(cafe, catalogue, names);

  it('comes after the preview only for profiles with the menu', () => {
    expect(setupSteps(cafe)).toEqual([1, 2, 3, 4, 5, 6]);
    expect(setupSteps(pharmacy)).toEqual([1, 2, 3, 4, 6]);
    expect(nextStep(4, pharmacy)).toBe(6);
    expect(previousStep(6, pharmacy)).toBe(4);
    expect(nextStep(4, cafe)).toBe(5);
    expect(nextStep(6, cafe)).toBe(6);
  });

  it('proposes the profile stations, the tax codes and the send trigger', () => {
    expect(shop).toEqual({
      profileKey: 'cafe_tra_sua',
      stations: [
        { kind: 'prep', name: 'Bếp' },
        { kind: 'bar', name: 'Bar' },
      ],
      foodTax: 'vat_food',
      alcoholTax: 'vat_special',
      trigger: 'on_complete',
    });
    const noKitchen = profile('menu_only', { modules: ['fnb.menu'], kitchen_stations: ['prep'] });
    expect(shopDefaults(noKitchen, catalogue, names).stations).toEqual([]);
  });

  it('keeps edits for the same profile and starts over for another', () => {
    const state = run([
      choose('cafe_tra_sua'),
      { type: 'shop-init', value: shop },
      { type: 'station-name', index: 1, value: 'Quầy pha chế' },
      { type: 'station-add', name: 'Bếp 2' },
      { type: 'station-remove', index: 0 },
      { type: 'shop-tax', role: 'alcohol', value: 'vat_food' },
      { type: 'shop-trigger', value: 'manual' },
      { type: 'shop-init', value: shop },
    ]);
    expect(state.shop).toMatchObject({
      stations: [
        { kind: 'bar', name: 'Quầy pha chế' },
        { kind: 'prep', name: 'Bếp 2' },
      ],
      alcoholTax: 'vat_food',
      trigger: 'manual',
    });
    expect(setupReducer(state, choose('nha_thuoc')).shop).toBeNull();
  });

  it('needs named, distinct stations and both tax choices', () => {
    const state = run([
      choose('cafe_tra_sua'),
      { type: 'branch-name', value: 'Cà phê' },
      { type: 'stock-location', value: 'sloc_1' },
      { type: 'shop-init', value: shop },
      { type: 'station-name', index: 1, value: ' bếp ' },
      { type: 'station-add', name: '' },
      { type: 'shop-tax', role: 'food', value: '' },
    ]);
    const options = { profiles: PROFILES, locationIds: ['sloc_1'] };
    expect(stepProblems(state, 4, options)).toEqual([]);
    expect(stepProblems(state, 5, options)).toEqual(['station-name', 'station-duplicate', 'tax']);
  });

  it('sends the step as fnb_setup, and never for a retail profile', () => {
    const state = run([
      choose('cafe_tra_sua'),
      { type: 'branch-name', value: 'Cà phê' },
      { type: 'shop-init', value: shop },
      { type: 'station-name', index: 0, value: '  Bếp nóng ' },
    ]);
    expect(onboardingPayload(state, cafe).fnb_setup).toEqual({
      stations: [
        { name: 'Bếp nóng', kind: 'prep' },
        { name: 'Bar', kind: 'bar' },
      ],
      tax_categories: { food: 'vat_food', alcohol: 'vat_special' },
      kitchen_send_trigger: 'on_complete',
    });
    expect(onboardingPayload(run([choose('nha_thuoc')], state), pharmacy)).not.toHaveProperty(
      'fnb_setup',
    );
  });
});

describe('table service at setup', () => {
  const eatery = profile('quan_an', {
    group: 'fnb',
    modules: ['fnb.menu', 'fnb.kitchen'],
    optional_modules: ['resources', 'fnb.tables', 'fnb.postpay', 'fnb.service_charge'],
  });
  const restaurant = profile('nha_hang', {
    group: 'fnb',
    modules: ['fnb.menu', 'fnb.kitchen', 'resources', 'fnb.tables', 'fnb.postpay'],
  });
  const cafe = PROFILES.find((item) => item.key === 'cafe_tra_sua') as BusinessProfile;
  const profiles = [...PROFILES, eatery, restaurant];
  const options = { profiles, locationIds: ['sloc_1'] };
  const ready = (key: string, extra: SetupAction[] = []) =>
    run([
      { type: 'choose', key, profiles },
      { type: 'branch-name', value: 'Quán 1' },
      { type: 'stock-location', value: 'sloc_1' },
      ...extra,
    ]);

  it('asks an eatery and sends the answer; a restaurant always serves tables', () => {
    const plain = ready('quan_an');
    expect(tablesOn(plain, eatery)).toBe(false);
    expect(onboardingPayload(plain, eatery).answers).toEqual({ has_tables: false });
    const tables = ready('quan_an', [{ type: 'has-tables', value: true }]);
    expect(tablesOn(tables, eatery)).toBe(true);
    expect(onboardingPayload(tables, eatery).answers).toEqual({ has_tables: true });
    expect(tablesOn(ready('nha_hang'), restaurant)).toBe(true);
    expect(onboardingPayload(ready('nha_hang'), restaurant)).not.toHaveProperty('answers');
    expect(onboardingPayload(ready('cafe_tra_sua'), cafe)).not.toHaveProperty('answers');
  });

  it('needs a register for table orders', () => {
    const blank: SetupAction = { type: 'register-name', value: ' ' };
    expect(stepProblems(ready('quan_an', [blank]), 5, options)).toEqual([]);
    expect(
      stepProblems(ready('quan_an', [blank, { type: 'has-tables', value: true }]), 5, options),
    ).toEqual(['table-register']);
    expect(stepProblems(ready('nha_hang', [blank]), 6, options)).toEqual(['table-register']);
    expect(stepProblems(ready('nha_hang'), 6, options)).toEqual([]);
  });
});
