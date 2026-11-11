import { posCapabilities } from '@parkviet/pos-shared/pos-capabilities'
import { describe, expect, it } from 'vitest'
import { capabilityGroups, capabilityLabel, changesSensitive } from './capability-groups'

describe('capability groups', () => {
  it('lists every assignable capability exactly once', () => {
    const grouped = capabilityGroups.flatMap((group) => group.capabilities.map((c) => c.value))
    expect([...grouped].sort()).toEqual(posCapabilities.map(([value]) => value).sort())
  })
  it('labels capabilities with the shared translation keys', () => {
    expect(capabilityLabel('pos.shift.open')).toBe('capabilityShift')
    expect(capabilityLabel('pos.resource.manage')).toBe('capabilityResourceManage')
    expect(capabilityLabel('pos.unknown')).toBe('adminUnknownPermission')
  })
  it('flags sensitive grants and removals only', () => {
    expect(changesSensitive(['pos.shift.open'], ['pos.shift.open', 'pos.customer.write'])).toBe(
      false,
    )
    expect(changesSensitive(['pos.shift.open'], ['pos.shift.open', 'pos.cash.move'])).toBe(true)
    expect(changesSensitive(['pos.cash.move'], [])).toBe(true)
    expect(changesSensitive([], ['pos.resource.manage'])).toBe(true)
    expect(changesSensitive([], ['pos.table.serve'])).toBe(false)
  })
})
