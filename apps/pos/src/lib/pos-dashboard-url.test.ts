import { describe, expect, it } from 'vitest';
import { posDashboardHomeUrl, posDashboardUrl } from './pos-dashboard-url';

describe('POS dashboard links', () => {
  it('uses the development port only in development', () => {
    expect(posDashboardUrl('store_1', '', null, { development: true })).toBe(
      'http://localhost:5176/store_1',
    );
    expect(posDashboardUrl('store_1', '', null, { development: false })).toBeNull();
  });

  it('preserves the deployment subpath and encodes store and branch identities', () => {
    expect(
      posDashboardUrl('store /1', '/features', 'branch /2', {
        baseUrl: 'https://admin.example.test/pos-admin/?old=1#old',
      }),
    ).toBe('https://admin.example.test/pos-admin/store%20%2F1/features?branch=branch+%2F2');
  });

  it('links to receipt settings without carrying a sale or session token', () => {
    expect(
      posDashboardUrl('store_1', '/settings/receipt-templates', null, {
        baseUrl: 'https://admin.example.test',
      }),
    ).toBe('https://admin.example.test/store_1/settings/receipt-templates');
  });

  it('fails closed on missing identity and unsafe configuration or paths', () => {
    expect(posDashboardUrl(null, '', null, { development: true })).toBeNull();
    expect(posDashboardUrl('..', '', null, { development: true })).toBeNull();
    for (const baseUrl of ['invalid', 'javascript:alert(1)', 'https://user:pass@example.test']) {
      expect(posDashboardUrl('store_1', '', null, { baseUrl })).toBeNull();
    }
    for (const path of ['../login', '//other.test/login', 'https://other.test', 'features?x=1']) {
      expect(posDashboardUrl('store_1', path, null, { development: true })).toBeNull();
    }
  });

  it('opens the dashboard entry without a store, keeping the deployment subpath', () => {
    expect(posDashboardHomeUrl({ development: true })).toBe('http://localhost:5176/');
    expect(posDashboardHomeUrl({ development: false })).toBeNull();
    expect(
      posDashboardHomeUrl({ baseUrl: 'https://admin.example.test/pos-admin/?old=1#old' }),
    ).toBe('https://admin.example.test/pos-admin/');
    for (const baseUrl of ['invalid', 'javascript:alert(1)', 'https://user:pass@example.test']) {
      expect(posDashboardHomeUrl({ baseUrl })).toBeNull();
    }
  });
});
