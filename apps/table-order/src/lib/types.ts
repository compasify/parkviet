// The guest API's shapes (server/openapi/pos-guest.yaml).

export type GuestSession = {
  id: string;
  status: 'open' | 'table_closed';
  expires_at: string;
  table: { name: string; kind: string };
  branch: { name: string; store_name: string };
  currency: string;
  approval: 'staff_approval' | 'direct_to_kitchen';
  // A room billed by play time: the bill adds the time played.
  timed: boolean;
};

export type MenuCategory = { id: string; name: string; position: number; color: string | null };

export type MenuVariant = {
  id: string;
  name: string | null;
  price: string;
  price_label: string | null;
};

export type MenuItem = {
  id: string;
  name: string;
  kind: 'single' | 'combo';
  menu_category_id: string | null;
  position: number;
  image_url: string | null;
  sold_out: boolean;
  modifier_group_ids: string[];
  components: { name: string; quantity: number }[];
  variants: MenuVariant[];
};

export type ModifierOption = {
  id: string;
  name: string;
  price_delta: string;
  default_selected: boolean;
};

export type ModifierGroup = {
  id: string;
  name: string;
  min_select: number;
  max_select: number;
  allow_quantity: boolean;
  required: boolean;
  options: ModifierOption[];
};

export type GuestMenu = {
  currency: string;
  etag: string;
  categories: MenuCategory[];
  items: MenuItem[];
  modifier_groups: ModifierGroup[];
};

export type GuestOrderStatus = 'pending' | 'accepted' | 'rejected' | 'expired';

export type GuestOrder = {
  id: string;
  status: GuestOrderStatus;
  reject_reason: string | null;
  items: {
    name: string;
    size: string | null;
    quantity: number;
    amount: string;
    note?: string | null;
    outcome?: 'added' | 'left_out' | null;
    options: string[];
  }[];
  quoted_total: string;
  currency: string;
  created_at: string;
};

export type GuestRequest = {
  id: string;
  kind: 'call_staff' | 'request_bill';
  status: 'open' | 'done';
  created_at: string;
};

export type TableLine = {
  name: string;
  size: string | null;
  quantity: string;
  options: string[];
  amount: string;
  kitchen: 'waiting' | 'sent' | 'preparing' | 'ready' | 'served';
};

export type GuestTable = {
  lines: TableLine[];
  subtotal: string | null;
  has_timed: boolean;
  orders: GuestOrder[];
  requests: GuestRequest[];
};
