import { describeFailure } from '@parkviet/pos-shared/request-failure'
import type { PosMembership } from '@parkviet/pos-shared/types/pos-context'
import { PageHeader, usePermissions } from '@spree/dashboard-core'
import { Button, Input, Label, useConfirm } from '@spree/dashboard-ui'
import { useQuery } from '@tanstack/react-query'
import { encode } from 'uqr'
import { useEffect, useState } from 'react'
import { useTranslation } from 'react-i18next'
import { usePosSession } from '../hooks/use-pos-session'
import { useSession } from '../hooks/use-session'
import { useRegisters, useTopologyMutation } from '../hooks/use-topology'
import { hasCapability, canAdminister } from '../lib/pos-access'
import { posRequest } from '../lib/pos-request'
import { posKey } from '../lib/query-keys'

const MODES = ['waiter', 'kds', 'expo', 'kiosk', 'print_station', 'owner', 'bridge'] as const
type DeviceRow = {
  id: string
  name: string
  mode: string
  platform: string
  status: string
  last_seen_at: string | null
  register_id: string | null
}
type PinRow = PosMembership & { pin_set?: boolean; staff?: { full_name: string | null; email: string } }
type Pairing = {
  id: string
  code: string
  expires_at: string
  qr: { v: number; kind: string; url: string; code: string }
}

export function DevicesPage() {
  const { t } = useTranslation()
  const { storeId } = useSession()
  const { context } = usePosSession()
  const { permissionKeys } = usePermissions()
  const access = { permissionKeys, context: context.data }
  const manage = canAdminister(access, true) || hasCapability(access, 'pos.device.manage')
  const branchId = context.data?.selection.branch_id
  const devices = useQuery({
    queryKey: posKey(storeId, 'devices', branchId ?? undefined),
    enabled: manage && Boolean(branchId),
    queryFn: () =>
      posRequest<{ data: DeviceRow[] }>('GET', '/pos/devices', { params: { branch_id: branchId ?? undefined } }),
  })
  // Own row for everyone, every row for a device manager. The memberships
  // API needs topology access, which a cashier setting a PIN does not have.
  const pins = useQuery({
    queryKey: posKey(storeId, 'staff-pins', branchId ?? undefined),
    enabled: Boolean(branchId),
    queryFn: () =>
      posRequest<{ data: PinRow[] }>('GET', '/pos/staff_pins', { params: { branch_id: branchId ?? undefined } }),
  })
  const mine = context.data?.staff.id
  const rows = pins.data?.data ?? []
  return (
    <div className="space-y-6">
      <PageHeader title={t('devices.title')} subtitle={t('devices.intro')} />
      {!branchId ? <p>{t('devices.chooseBranch')}</p> : null}
      {manage && branchId ? (
        <DeviceList
          branchId={branchId}
          devices={devices.data?.data ?? []}
          pending={devices.isPending}
          error={devices.error}
        />
      ) : null}
      {branchId ? <PinList rows={rows} mine={mine} manage={manage} /> : null}
    </div>
  )
}

function DeviceList({
  branchId,
  devices,
  pending,
  error,
}: {
  branchId: string
  devices: DeviceRow[]
  pending: boolean
  error: unknown
}) {
  const { t } = useTranslation()
  const write = useTopologyMutation()
  const registers = useRegisters(true)
  const confirm = useConfirm()
  const [mode, setMode] = useState<(typeof MODES)[number]>('kds')
  const [registerId, setRegisterId] = useState('')
  const [pairing, setPairing] = useState<Pairing | null>(null)
  const [image, setImage] = useState('')
  const [left, setLeft] = useState('')
  const [notice, setNotice] = useState('')
  useEffect(() => {
    if (!pairing) return
    const { size, data } = encode(JSON.stringify(pairing.qr), { ecc: 'M', border: 2 })
    const scale = 6
    const canvas = document.createElement('canvas')
    canvas.width = size * scale
    canvas.height = size * scale
    const context = canvas.getContext('2d')
    if (context) {
      context.fillStyle = '#fff'
      context.fillRect(0, 0, canvas.width, canvas.height)
      context.fillStyle = '#000'
      data.forEach((row, y) => {
        row.forEach((dark, x) => {
          if (dark) context.fillRect(x * scale, y * scale, scale, scale)
        })
      })
      setImage(canvas.toDataURL())
    }
    const tick = () => {
      const seconds = Math.max(0, Math.floor((Date.parse(pairing.expires_at) - Date.now()) / 1000))
      setLeft(`${String(Math.floor(seconds / 60)).padStart(2, '0')}:${String(seconds % 60).padStart(2, '0')}`)
    }
    tick()
    const timer = window.setInterval(tick, 1000)
    return () => window.clearInterval(timer)
  }, [pairing])
  async function pair() {
    setNotice('')
    try {
      const key = crypto.randomUUID()
      const result = await write.mutateAsync({
        method: 'POST',
        path: '/pos/devices/pairing',
        body: {
          branch_id: branchId,
          mode,
          register_id: mode === 'kiosk' ? registerId : undefined,
          idempotency_key: key,
        },
      })
      setPairing((result as { data: Pairing }).data)
    } catch (failure) {
      setNotice(describeFailure(failure, t))
    }
  }
  async function revoke(device: DeviceRow) {
    if (!(await confirm({ message: t('devices.revokeConfirm', { name: device.name }), variant: 'destructive', confirmLabel: t('devices.revoke'), cancelLabel: t('adminCancel') })))
      return
    await send('POST', `/pos/devices/${device.id}/revoke`, {})
  }
  async function rename(device: DeviceRow) {
    const name = window.prompt(t('devices.rename'), device.name)
    if (!name || name === device.name) return
    await send('PATCH', `/pos/devices/${device.id}`, { name })
  }
  async function send(method: string, path: string, body: Record<string, unknown>) {
    setNotice('')
    try {
      await write.mutateAsync({ method, path, body: { ...body, idempotency_key: crypto.randomUUID() } })
    } catch (failure) {
      setNotice(describeFailure(failure, t))
    }
  }
  return (
    <section className="space-y-3">
      <h2 className="text-lg font-semibold">{t('devices.list')}</h2>
      {pending ? <p>{t('waiting')}</p> : null}
      {error ? <p role="alert">{describeFailure(error, t)}</p> : null}
      <ul className="space-y-2">
        {devices.map((device) => (
          <li key={device.id} className="flex flex-wrap items-center gap-3">
            <strong>{device.name}</strong>
            <span>{t(`devices.mode.${device.mode}`)}</span>
            <span>{device.status === 'active' ? t('devices.active') : t('devices.revoked')}</span>
            <span>{device.last_seen_at ? new Date(device.last_seen_at).toLocaleString() : t('devices.neverSeen')}</span>
            <Button type="button" onClick={() => void rename(device)}>{t('devices.rename')}</Button>
            {device.status === 'active' ? (
              <Button type="button" onClick={() => void revoke(device)}>{t('devices.revoke')}</Button>
            ) : null}
          </li>
        ))}
      </ul>
      <div className="flex flex-wrap items-end gap-3">
        <Label>
          {t('devices.modeLabel')}
          <select value={mode} onChange={(event) => setMode(event.target.value as (typeof MODES)[number])}>
            {MODES.map((item) => (
              <option key={item} value={item}>{t(`devices.mode.${item}`)}</option>
            ))}
          </select>
        </Label>
        {mode === 'kiosk' ? (
          <Label>
            {t('devices.register')}
            <select value={registerId} onChange={(event) => setRegisterId(event.target.value)}>
              <option value="">{t('devices.chooseRegister')}</option>
              {(registers.data?.data ?? []).filter((row) => row.branch_id === branchId).map((row) => (
                <option key={row.id} value={row.id}>{row.name}</option>
              ))}
            </select>
          </Label>
        ) : null}
        <Button type="button" onClick={() => void pair()}>{t('devices.pair')}</Button>
      </div>
      {notice ? <p role="alert">{notice}</p> : null}
      {pairing ? (
        <div>
          <p className="font-mono text-2xl">{pairing.code}</p>
          <p>{t('devices.expires', { time: left })}</p>
          {image ? <img src={image} alt={pairing.code} width={220} height={220} /> : null}
        </div>
      ) : null}
    </section>
  )
}

function PinList({
  rows,
  mine,
  manage,
}: {
  rows: PinRow[]
  mine?: string
  manage: boolean
}) {
  const { t } = useTranslation()
  const write = useTopologyMutation()
  const [pin, setPin] = useState('')
  const [notice, setNotice] = useState('')
  async function save(membershipId: string, reset: boolean) {
    setNotice('')
    try {
      const key = crypto.randomUUID()
      await write.mutateAsync({
        method: reset ? 'DELETE' : 'PUT',
        path: '/pos/staff_pins',
        body: { membership_id: membershipId, pin: reset ? undefined : pin, idempotency_key: key },
      })
      setPin('')
      setNotice(t('saved'))
    } catch (failure) {
      setNotice(describeFailure(failure, t))
    }
  }
  return (
    <section className="space-y-3">
      <h2 className="text-lg font-semibold">{t('devices.pinTitle')}</h2>
      <p className="text-sm text-muted-foreground">{t('devices.pinHint')}</p>
      {notice ? <p>{notice}</p> : null}
      <ul className="space-y-2">
        {rows.map((row) => {
          const own = row.staff_id === mine
          if (!own && !manage) return null
          return (
            <li key={row.id} className="flex flex-wrap items-center gap-3">
              <span>{row.staff?.full_name || row.staff?.email}</span>
              <span>{row.pin_set ? t('devices.pinSet') : t('devices.pinMissing')}</span>
              {own ? (
                <>
                  <Input value={pin} inputMode="numeric" maxLength={6} onChange={(event) => setPin(event.target.value)} aria-label={t('devices.pin')} />
                  <Button type="button" onClick={() => void save(row.id, false)}>{t('devices.pinSave')}</Button>
                </>
              ) : null}
              {manage && !own ? (
                <Button type="button" onClick={() => void save(row.id, true)}>{t('devices.pinReset')}</Button>
              ) : null}
            </li>
          )
        })}
      </ul>
    </section>
  )
}
