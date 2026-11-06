export const posCapabilities = [
  ['pos.shift.open', 'capabilityShift'],
  ['pos.discount.apply', 'capabilityDiscount'],
  ['pos.price.override', 'capabilityPrice'],
  ['pos.customer.write', 'capabilityCustomer'],
  ['pos.payment.collect', 'capabilityPayment'],
  ['pos.payment.resolve', 'capabilityPaymentResolve'],
  ['pos.approval.grant', 'capabilityApprove'],
  ['pos.workspace.takeover', 'capabilityTakeover'],
  ['pos.topology.manage', 'capabilityManage'],
  ['pos.topology.recover', 'capabilityRecover'],
] as const;

export const sensitiveCapabilities = [
  'pos.discount.apply',
  'pos.price.override',
  'pos.payment.resolve',
  'pos.approval.grant',
  'pos.workspace.takeover',
  'pos.topology.manage',
  'pos.topology.recover',
];
