# frozen_string_literal: true

# POS modules and industry profiles. `to_prepare` runs once at boot and again
# after every code reload in development, so the registry (a reloadable
# constant) is rebuilt with the code. Both steps raise on a bad definition,
# which stops the boot: a dependency cycle, a dependency on a planned module,
# or a profile naming an unknown module, feature, unit or branch default.
Rails.application.config.to_prepare do
  Spree::Pos::Modules.define! do |modules|
    modules.register(key: 'retail.units', group: 'retail', depends_on: [])
    modules.register(key: 'retail.measured', group: 'retail', depends_on: ['retail.units'])
    modules.register(key: 'retail.traceability', group: 'retail', depends_on: [])

    # Names only, so "coming soon" profiles can refer to them. No code, and
    # no branch can turn them on.
    modules.planned 'fnb.menu', 'fnb.kitchen', 'fnb.order_number', 'fnb.recipes', 'resources', 'fnb.tables',
                    'fnb.postpay', 'fnb.service_charge', 'timed_billing', group: 'fnb'
  end

  Spree::Pos::BusinessProfiles.reload!
end
