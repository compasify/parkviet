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
  ['pos.credit.sell', 'capabilityCreditSell'],
  ['pos.credit.manage', 'capabilityCreditManage'],
  ['pos.return.process', 'capabilityReturn'],
] as const;

export const sensitiveCapabilities = [
  'pos.discount.apply',
  'pos.price.override',
  'pos.payment.resolve',
  'pos.approval.grant',
  'pos.workspace.takeover',
  'pos.topology.manage',
  'pos.topology.recover',
  'pos.credit.sell',
  'pos.credit.manage',
  'pos.return.process',
];
