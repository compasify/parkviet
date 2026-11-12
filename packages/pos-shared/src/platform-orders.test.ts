import { describe, expect, it } from 'vitest';
import { isPlatformSource, ORDER_SOURCES, PICKABLE_ORDER_SOURCES } from './order-source';
import { activePlatforms, platformOrderOpen, validPlatformOrderRef } from './platform-orders';

describe('platform orders', () => {
  it('keeps the platforms out of the sources a cashier picks', () => {
    expect(PICKABLE_ORDER_SOURCES).toEqual(['counter', 'facebook', 'zalo', 'other']);
    expect(ORDER_SOURCES).toEqual([
      'counter',
      'facebook',
      'zalo',
      'other',
      'grabfood',
      'shopeefood',
      'kiosk',
    ]);
    expect(isPlatformSource('grabfood')).toBe(true);
    expect(isPlatformSource('facebook')).toBe(false);
    expect(isPlatformSource(undefined)).toBe(false);
  });

  it('lists only the platforms turned on at the branch', () => {
    expect(
      activePlatforms({
        module_enabled: true,
        platforms: [
          { platform: 'grabfood', status: 'active', commission_rate: '25.0', updated_at: null },
          { platform: 'shopeefood', status: 'disabled', commission_rate: '0.0', updated_at: null },
        ],
      }),
    ).toEqual(['grabfood']);
    expect(activePlatforms(undefined)).toEqual([]);
  });

  it('treats accepted and ready orders as still at the shop', () => {
    expect(platformOrderOpen({ status: 'accepted' })).toBe(true);
    expect(platformOrderOpen({ status: 'ready' })).toBe(true);
    expect(platformOrderOpen({ status: 'completed' })).toBe(false);
  });

  it('accepts platform codes as the server does', () => {
    expect(validPlatformOrderRef('GF-1001')).toBe(true);
    expect(validPlatformOrderRef(' 05-AB.12_3 ')).toBe(true);
    expect(validPlatformOrderRef('GF 1')).toBe(false);
    expect(validPlatformOrderRef('-GF')).toBe(false);
    expect(validPlatformOrderRef('')).toBe(false);
  });
});
