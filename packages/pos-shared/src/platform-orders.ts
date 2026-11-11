// Delivery platform orders (GrabFood, ShopeeFood) typed in at the counter, as
// GET /pos/platform_orders and /pos/platform_settings send them. Shared by the
// POS app (entering and handing over) and the POS administration app (rates
// and settlement).
import { PLATFORM_ORDER_SOURCES, type PlatformOrderSource } from './types/pos-context';

export const PLATFORMS = PLATFORM_ORDER_SOURCES;
export type Platform = PlatformOrderSource;

export const PLATFORM_ORDER_STATUSES = ['accepted', 'ready', 'completed', 'canceled'] as const;
export type PlatformOrderStatus = (typeof PLATFORM_ORDER_STATUSES)[number];

export type PlatformOrderItem = {
  name: string;
  quantity: string;
  modifiers: string[];
  note: string | null;
};

export type PlatformOrder = {
  id: string;
  workspace_id: string;
  order_id: string;
  order_number: number | null;
  business_date: string | null;
  platform: Platform;
  platform_order_ref: string;
  pickup_code: string | null;
  status: PlatformOrderStatus;
  gross_amount: string;
  commission_rate: string;
  commission_amount: string;
  net_amount: string;
  currency: string;
  entered_at: string | null;
  ready_at: string | null;
  completed_at: string | null;
  canceled_at: string | null;
  cancel_reason: string | null;
  settled_at: string | null;
  settlement_reference: string | null;
  items: PlatformOrderItem[];
};

export type PlatformSetting = {
  platform: Platform;
  status: 'active' | 'disabled';
  commission_rate: string;
  updated_at: string | null;
};

export type PlatformSettings = {
  module_enabled: boolean;
  platforms: PlatformSetting[];
};

// Locale key of a platform's name ("GrabFood", "ShopeeFood").
export const platformKey = (platform: Platform) => `platform_${platform}`;

// Platforms the counter takes orders from at the branch.
export function activePlatforms(settings: PlatformSettings | null | undefined): Platform[] {
  return (settings?.platforms ?? [])
    .filter((row) => row.status === 'active' && PLATFORMS.includes(row.platform))
    .map((row) => row.platform);
}

// Still with the shop: entered and not yet handed to the driver.
export function platformOrderOpen(order: Pick<PlatformOrder, 'status'>): boolean {
  return order.status === 'accepted' || order.status === 'ready';
}

// A platform order code as the platforms print them: letters, digits, dot,
// dash and underscore, at most 64, starting with a letter or digit.
export function validPlatformOrderRef(value: string): boolean {
  return /^[A-Za-z0-9][A-Za-z0-9._-]{0,63}$/.test(value.trim());
}
