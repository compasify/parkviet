import { describe, expect, it } from 'vitest'
import {
  KIOSK_IDLE_RANGE,
  KIOSK_QR_TIMEOUT_RANGE,
  normalizeKioskSettings,
  secondsWithin,
} from './use-kiosk-settings'

describe('kiosk settings', () => {
  it('reads the settings and kiosks the server sends, skipping malformed kiosks', () => {
    const settings = normalizeKioskSettings({
      branch_id: 'posbranch_1',
      kiosk_idle_seconds: 90,
      kiosk_qr_timeout_seconds: 240,
      kiosk_kitchen_before_payment: true,
      kiosks: [
        {
          register: { id: 'posregister_1', name: 'Kiosk 1', status: 'active' },
          device: { id: 'posdevice_1', name: 'Kiosk sảnh', last_seen_at: '2026-11-12T03:00:00Z' },
          provisioned: true,
          shift: {
            id: 'posshift_1',
            opened_at: '2026-11-12T01:00:00Z',
            business_date: '2026-11-12',
          },
          waiting_orders: 2,
        },
        { register: null },
        'junk',
        { register: { id: 'posregister_2', name: 'Kiosk 2' }, device: null, shift: null },
      ],
    })
    expect(settings).toMatchObject({
      kiosk_idle_seconds: 90,
      kiosk_qr_timeout_seconds: 240,
      kiosk_kitchen_before_payment: true,
    })
    expect(settings.kiosks).toHaveLength(2)
    expect(settings.kiosks[0]).toMatchObject({
      device_name: 'Kiosk sảnh',
      provisioned: true,
      shift_open: true,
      waiting_orders: 2,
    })
    expect(settings.kiosks[1]).toMatchObject({
      device_name: null,
      provisioned: false,
      shift_open: false,
      waiting_orders: 0,
    })
  })

  it('falls back to the server defaults for a missing body', () => {
    expect(normalizeKioskSettings(null)).toEqual({
      branch_id: '',
      kiosk_idle_seconds: 60,
      kiosk_qr_timeout_seconds: 180,
      kiosk_kitchen_before_payment: false,
      kiosks: [],
    })
  })

  it('accepts whole seconds within the ranges only', () => {
    expect(secondsWithin('60', KIOSK_IDLE_RANGE)).toBe(60)
    expect(secondsWithin(' 15 ', KIOSK_IDLE_RANGE)).toBe(15)
    expect(secondsWithin('14', KIOSK_IDLE_RANGE)).toBeNull()
    expect(secondsWithin('601', KIOSK_IDLE_RANGE)).toBeNull()
    expect(secondsWithin('1.5', KIOSK_IDLE_RANGE)).toBeNull()
    expect(secondsWithin('', KIOSK_QR_TIMEOUT_RANGE)).toBeNull()
    expect(secondsWithin('900', KIOSK_QR_TIMEOUT_RANGE)).toBe(900)
  })
})
