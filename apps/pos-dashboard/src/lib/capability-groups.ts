import { posCapabilities, sensitiveCapabilities } from '@parkviet/pos-shared/pos-capabilities'

type Capability = (typeof posCapabilities)[number][0]
// Assignable capabilities grouped by the work they open, for staff role and
// membership forms. Labels come from the shared capability translation keys.
const GROUPS: { key: string; capabilities: Capability[] }[] = [
  {
    key: 'selling',
    capabilities: [
      'pos.shift.open',
      'pos.discount.apply',
      'pos.price.override',
      'pos.customer.write',
      'pos.return.process',
      'pos.credit.sell',
    ],
  },
  {
    key: 'money',
    capabilities: [
      'pos.payment.collect',
      'pos.payment.resolve',
      'pos.cash.move',
      'pos.einvoice.manage',
    ],
  },
  {
    key: 'management',
    capabilities: [
      'pos.approval.grant',
      'pos.workspace.takeover',
      'pos.topology.manage',
      'pos.topology.recover',
      'pos.credit.manage',
      'pos.device.manage',
      'pos.printer.manage',
    ],
  },
  { key: 'reports', capabilities: ['pos.report.read', 'pos.report.export'] },
  { key: 'stock', capabilities: ['pos.inventory.manage', 'pos.inventory.trace'] },
  {
    key: 'menu',
    capabilities: [
      'pos.menu.manage',
      'pos.menu.sold_out',
      'pos.kitchen.operate',
      'pos.kitchen.manage',
    ],
  },
]
const labels = new Map<string, string>(posCapabilities)
export const capabilityLabel = (value: string) => labels.get(value) ?? 'adminUnknownPermission'
export const capabilityGroups = GROUPS.map((group) => ({
  key: group.key,
  capabilities: group.capabilities.map((value) => ({ value, label: capabilityLabel(value) })),
}))
// Whether going from `before` to `after` grants or removes a sensitive capability.
export const changesSensitive = (before: readonly string[], after: readonly string[]) =>
  sensitiveCapabilities.some((value) => before.includes(value) !== after.includes(value))
