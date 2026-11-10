// A branch member's POS context for operational screens. Presentation
// fixture only: the real API decides capabilities per branch membership.
export const branch = {
  id: 'branch_main',
  name: 'Chi nhánh chính',
  code: 'main',
  status: 'active',
  timezone: 'Asia/Ho_Chi_Minh',
  stock_location_id: 'stock_main',
  receiving_stock_location_id: null,
  receiving_note: null,
};
export const staff = { id: 'staff_admin', email: 'admin@example.test', full_name: 'Quản trị Hiền' };

export function posContext(
  url: URL,
  options: { capabilities: string[]; features?: Record<string, boolean> | null; admin?: boolean },
) {
  return {
    sales_channel: { id: 'ch_pos', code: 'pos', name: 'POS', status: 'active' },
    staff,
    store: { id: 'store_1', name: 'Siêu thị Hiền', currency: 'VND', timezone: 'Asia/Ho_Chi_Minh' },
    administration: { read: options.admin ?? false, write: options.admin ?? false },
    capabilities: options.capabilities,
    features: options.features ?? null,
    branches: [branch],
    registers: [
      { id: 'reg_1', branch_id: 'branch_main', name: 'Quầy 1', code: 'Q1', status: 'active' },
      { id: 'reg_2', branch_id: 'branch_main', name: 'Quầy 2', code: 'Q2', status: 'active' },
    ],
    shift: null,
    selection: { branch_id: url.searchParams.get('branch_id') ?? 'branch_main', register_id: null },
  };
}

export const pageMeta = (count: number, page = 1, limit = 25) => {
  const pages = count === 0 ? 0 : Math.ceil(count / limit);
  const from = count === 0 ? 0 : (page - 1) * limit + 1;
  return {
    page,
    limit,
    count,
    pages,
    from,
    to: count === 0 ? 0 : Math.min(count, page * limit),
    previous: page > 1 ? page - 1 : null,
    next: page < pages ? page + 1 : null,
  };
};
