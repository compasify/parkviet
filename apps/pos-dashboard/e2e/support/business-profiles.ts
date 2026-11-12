// `GET /pos/business_profiles` as the server sends it (server/config/pos/
// business_profiles.yml, version 4): 13 retail profiles and 6 food & drink
// profiles, karaoke / billiard included. The server has no profile "coming
// soon" any more; `withComingSoon` marks one so for the interest scenarios,
// as the server specs do with `treat_as_planned`.

const ALL = ['retail.units', 'retail.measured', 'retail.traceability'];

type Row = {
  key: string;
  group: 'retail' | 'fnb';
  modules: string[];
  branch_defaults?: Record<string, unknown>;
  view?: 'cards' | 'list';
  recommended_features?: string[];
  sample_units?: string[];
  kitchen_stations?: string[];
  optional_modules?: string[];
  surface?: 'menu_grid' | 'table_grid' | 'floor_plan' | 'resource_board';
};

const SHOP = { kitchen_send_trigger: 'on_complete' };
const TABLES = ['resources', 'fnb.tables', 'fnb.postpay', 'fnb.service_charge'];
const AVAILABLE_FNB = ['fnb.menu', 'fnb.kitchen', 'fnb.order_number', 'fnb.cup_label', 'fnb.recipes', 'fnb.delivery_platforms'];

const ROWS: Row[] = [
  { key: 'tap_hoa_sieu_thi', group: 'retail', modules: ALL, branch_defaults: { return_window_days: 7, lot_selection: 'fefo' }, view: 'list', recommended_features: ['credit', 'vietqr', 'customer_display'], sample_units: ['pack', 'case', 'kg'] },
  { key: 'thoi_trang', group: 'retail', modules: [], branch_defaults: { return_window_days: 7 }, view: 'cards', recommended_features: ['returns', 'refunds', 'exchanges', 'vietqr'] },
  { key: 'dien_tu_dien_may', group: 'retail', modules: ['retail.traceability'], branch_defaults: { return_window_days: 7 }, view: 'cards', recommended_features: ['traceability', 'returns', 'refunds', 'exchanges', 'credit'] },
  { key: 'vat_lieu_xay_dung', group: 'retail', modules: ['retail.units'], branch_defaults: { return_window_days: 7 }, view: 'list', recommended_features: ['credit', 'vietqr'], sample_units: ['bao', 'tam', 'cay', 'xe'] },
  { key: 'nong_san_thuc_pham', group: 'retail', modules: ALL, branch_defaults: { return_window_days: 1, lot_selection: 'fefo' }, view: 'cards', recommended_features: ['vietqr'], sample_units: ['kg'] },
  { key: 'nha_thuoc', group: 'retail', modules: ['retail.units', 'retail.traceability'], branch_defaults: { return_window_days: 7, lot_selection: 'fefo' }, view: 'list', recommended_features: ['traceability', 'returns', 'refunds'], sample_units: ['vien', 'vi', 'hop', 'chai'] },
  { key: 'xe_may_moc', group: 'retail', modules: ['retail.traceability'], branch_defaults: { return_window_days: 7 }, view: 'list', recommended_features: ['traceability', 'credit'], sample_units: ['bo'] },
  { key: 'my_pham', group: 'retail', modules: ['retail.traceability'], branch_defaults: { return_window_days: 7, lot_selection: 'fefo' }, view: 'cards', recommended_features: ['returns', 'exchanges'] },
  { key: 'noi_that_gia_dung', group: 'retail', modules: ['retail.units'], branch_defaults: { return_window_days: 7 }, view: 'cards', recommended_features: ['credit'], sample_units: ['bo'] },
  { key: 'me_be', group: 'retail', modules: ['retail.units', 'retail.traceability'], branch_defaults: { return_window_days: 7, lot_selection: 'fefo' }, view: 'cards', recommended_features: ['returns', 'exchanges'], sample_units: ['hop', 'pack', 'case'] },
  { key: 'sach_van_phong_pham', group: 'retail', modules: ['retail.units'], branch_defaults: { return_window_days: 7 }, view: 'list', recommended_features: ['credit'], sample_units: ['quyen', 'ram', 'hop'] },
  { key: 'hoa_qua_tang', group: 'retail', modules: [], view: 'cards', recommended_features: ['vietqr'], sample_units: ['bo_hoa', 'gio'] },
  { key: 'khac', group: 'retail', modules: ALL, view: 'cards' },
  { key: 'quan_an', group: 'fnb', modules: ['retail.units', 'retail.measured', 'fnb.menu', 'fnb.kitchen', 'fnb.order_number', 'fnb.recipes', 'fnb.delivery_platforms'], branch_defaults: SHOP, recommended_features: ['vietqr', 'credit', 'delivery'], kitchen_stations: ['prep', 'bar'], optional_modules: TABLES },
  { key: 'cafe_tra_sua', group: 'fnb', modules: ['retail.units', 'fnb.menu', 'fnb.kitchen', 'fnb.order_number', 'fnb.cup_label', 'fnb.recipes', 'fnb.delivery_platforms'], branch_defaults: SHOP, recommended_features: ['vietqr', 'customer_display'], kitchen_stations: ['prep', 'bar'] },
  { key: 'karaoke_bida', group: 'fnb', modules: ['resources', 'fnb.tables', 'timed_billing', 'fnb.menu', 'fnb.kitchen', 'fnb.postpay', 'fnb.bottle_keep'], branch_defaults: { kitchen_send_trigger: 'manual', operating_windows: [{ days: [0, 1, 2, 3, 4, 5, 6], from: '08:00', to: '24:00' }] }, surface: 'resource_board', recommended_features: ['vietqr'], kitchen_stations: ['bar'] },
  { key: 'bar_pub_club', group: 'fnb', modules: ['fnb.menu', 'fnb.kitchen', ...TABLES], branch_defaults: { kitchen_send_trigger: 'manual' }, surface: 'table_grid', recommended_features: ['vietqr', 'customer_display'], kitchen_stations: ['prep', 'bar'] },
  { key: 'cang_tin_tram_dung', group: 'fnb', modules: ['fnb.menu', 'fnb.kitchen', 'fnb.order_number', 'retail.units'], branch_defaults: SHOP, recommended_features: ['vietqr', 'customer_display'], kitchen_stations: ['prep'] },
  { key: 'nha_hang', group: 'fnb', modules: ['fnb.menu', 'fnb.kitchen', ...TABLES], branch_defaults: { kitchen_send_trigger: 'manual', service_charge_rate: 5 }, surface: 'floor_plan', recommended_features: ['vietqr', 'customer_display'], kitchen_stations: ['prep', 'bar'] },
];

export const PROFILE_MODULES: Record<string, string[]> = Object.fromEntries(ROWS.map((row) => [row.key, row.modules]));

export const BUSINESS_PROFILES = {
  version: 4,
  modules: [
    { key: 'retail.units', group: 'retail', status: 'available', depends_on: [] },
    { key: 'retail.measured', group: 'retail', status: 'available', depends_on: ['retail.units'] },
    { key: 'retail.traceability', group: 'retail', status: 'available', depends_on: [] },
    ...AVAILABLE_FNB.map((key) => ({ key, group: 'fnb', status: 'available', depends_on: [] })),
    { key: 'resources', group: 'fnb', status: 'available', depends_on: [] },
    { key: 'fnb.tables', group: 'fnb', status: 'available', depends_on: ['resources'] },
    { key: 'fnb.postpay', group: 'fnb', status: 'available', depends_on: [] },
    { key: 'fnb.service_charge', group: 'fnb', status: 'available', depends_on: [] },
    { key: 'fnb.bottle_keep', group: 'fnb', status: 'available', depends_on: [] },
    { key: 'timed_billing', group: 'fnb', status: 'available', depends_on: ['resources', 'fnb.tables'] },
  ],
  profiles: ROWS.map((row, index) => ({
    key: row.key,
    group: row.group,
    order: index + 1,
    status: 'available',
    modules: row.modules,
    optional_modules: row.optional_modules ?? [],
    branch_defaults: row.branch_defaults ?? {},
    display: row.group === 'fnb' ? { surface: row.surface ?? 'menu_grid' } : row.view ? { catalog_view: row.view } : {},
    recommended_features: row.recommended_features ?? [],
    sample_units: row.sample_units ?? [],
    kitchen_stations: row.kitchen_stations ?? [],
  })),
  tax_categories: [
    { code: 'vat_food', rate: '0.08' },
    { code: 'vat_special', rate: '0.1' },
  ],
  menu_tax_defaults: { food: 'vat_food', alcohol: 'vat_special' },
};

export function profileOf(key: string) {
  return BUSINESS_PROFILES.profiles.find((profile) => profile.key === key);
}

// The catalogue with one profile not open yet: the profile is "coming soon"
// and the modules only it uses are planned.
export function withComingSoon(key: string): typeof BUSINESS_PROFILES {
  const target = profileOf(key);
  const others = new Set(BUSINESS_PROFILES.profiles.filter((profile) => profile.key !== key).flatMap((profile) => profile.modules));
  const own = new Set((target?.modules ?? []).filter((module) => !others.has(module)));
  return {
    ...BUSINESS_PROFILES,
    modules: BUSINESS_PROFILES.modules.map((module) => (own.has(module.key) ? { ...module, status: 'planned' } : module)),
    profiles: BUSINESS_PROFILES.profiles.map((profile) => (profile.key === key ? { ...profile, status: 'coming_soon', display: {} } : profile)),
  };
}