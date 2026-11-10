# frozen_string_literal: true

# POS modules and industry profiles. `to_prepare` runs once at boot and again
# after every code reload in development, so the registry (a reloadable
# constant) is rebuilt with the code. Both steps raise on a bad definition,
# which stops the boot: a dependency cycle, a dependency on a planned module,
# or a profile naming an unknown module, feature, unit or branch default.
Rails.application.config.to_prepare do
  Spree::Pos::Modules.define! do |modules|
    modules.register(key: 'retail.units', group: 'retail', depends_on: [],
                     entrypoints: ['Spree::Api::V3::Admin::Pos::UnitsController'])
    modules.register(key: 'retail.measured', group: 'retail', depends_on: ['retail.units'],
                     entrypoints: ['Spree::Api::V3::Admin::Pos::LabelFormatsController'])
    modules.register(key: 'retail.traceability', group: 'retail', depends_on: [],
                     entrypoints: ['Spree::Pos::Inventory::OpenBalance'])

    # Names only, so "coming soon" profiles can refer to them. No code, and
    # no branch can turn them on.
    modules.planned 'fnb.menu', 'fnb.kitchen', 'fnb.order_number', 'fnb.recipes', 'resources', 'fnb.tables',
                    'fnb.postpay', 'fnb.service_charge', 'timed_billing', group: 'fnb'
  end

  Spree::Pos::SaleLineKinds.define! do |kinds|
    kinds.add 'ordinary', mergeable: true
    kinds.add 'measured', owner: 'retail.measured', mergeable: true
    kinds.add 'tracked', owner: 'retail.traceability', mergeable: true
    kinds.add 'menu', owner: 'fnb.menu'
    kinds.add 'timed', owner: 'timed_billing'
    kinds.add 'cover', owner: 'fnb.tables'
  end

  Spree::Pos::BusinessProfiles.reload!
end
