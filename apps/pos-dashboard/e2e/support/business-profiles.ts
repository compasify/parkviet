// `GET /pos/business_profiles` as the server sends it (server/config/pos/
// business_profiles.yml, the table approved in plan 261108-1830 phase 1):
// 13 retail profiles available, 6 food & entertainment "coming soon".

const ALL = ['retail.units', 'retail.measured', 'retail.traceability'];

type Row = {
  key: string;
  group: 'retail' | 'fnb';
  modules: string[];
  branch_defaults?: Record<string, unknown>;
  view?: 'cards' | 'list';
  recommended_features?: string[];
  sample_units?: string[];
};

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
  { key: 'quan_an', group: 'fnb', modules: ['fnb.menu', 'fnb.kitchen'] },
  { key: 'cafe_tra_sua', group: 'fnb', modules: ['fnb.menu', 'fnb.kitchen', 'fnb.order_number'] },
  { key: 'karaoke_bida', group: 'fnb', modules: ['resources', 'timed_billing', 'fnb.menu', 'fnb.postpay'] },
  { key: 'bar_pub_club', group: 'fnb', modules: ['fnb.menu', 'fnb.kitchen', 'fnb.postpay', 'fnb.service_charge'] },
  { key: 'cang_tin_tram_dung', group: 'fnb', modules: ['fnb.menu', 'fnb.kitchen', 'fnb.order_number', 'retail.units'] },
  { key: 'nha_hang', group: 'fnb', modules: ['fnb.menu', 'fnb.kitchen', 'resources', 'fnb.tables', 'fnb.postpay', 'fnb.service_charge'] },
];

export const PROFILE_MODULES: Record<string, string[]> = Object.fromEntries(ROWS.map((row) => [row.key, row.modules]));

export const BUSINESS_PROFILES = {
  version: 1,
  modules: [
    { key: 'retail.units', group: 'retail', status: 'available', depends_on: [] },
    { key: 'retail.measured', group: 'retail', status: 'available', depends_on: ['retail.units'] },
    { key: 'retail.traceability', group: 'retail', status: 'available', depends_on: [] },
    ...['fnb.menu', 'fnb.kitchen', 'fnb.order_number', 'fnb.recipes', 'resources', 'fnb.tables', 'fnb.postpay', 'fnb.service_charge', 'timed_billing'].map(
      (key) => ({ key, group: 'fnb', status: 'planned', depends_on: [] }),
    ),
  ],
  profiles: ROWS.map((row, index) => ({
    key: row.key,
    group: row.group,
    order: index + 1,
    status: row.group === 'retail' ? 'available' : 'coming_soon',
    modules: row.modules,
    branch_defaults: row.branch_defaults ?? {},
    display: row.view ? { catalog_view: row.view } : {},
    recommended_features: row.recommended_features ?? [],
    sample_units: row.sample_units ?? [],
  })),
};

export function profileOf(key: string) {
  return BUSINESS_PROFILES.profiles.find((profile) => profile.key === key);
}
