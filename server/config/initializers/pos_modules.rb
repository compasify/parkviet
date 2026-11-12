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
    modules.register(key: 'fnb.menu', group: 'fnb', depends_on: [],
                     entrypoints: ['Spree::Api::V3::Admin::Pos::MenuController', 'Spree::Pos::Menu::Pricing'])
    modules.register(key: 'fnb.recipes', group: 'fnb', depends_on: ['fnb.menu', 'retail.units'],
                     entrypoints: ['Spree::Api::V3::Admin::Pos::RecipesController', 'Spree::Pos::Recipes::Consume'])
    modules.register(key: 'fnb.kitchen', group: 'fnb', depends_on: ['fnb.menu'],
                     entrypoints: ['Spree::Api::V3::Admin::Pos::KitchenStationsController', 'Spree::Pos::Kitchen::Send'])
    modules.register(key: 'fnb.order_number', group: 'fnb', depends_on: [],
                     entrypoints: ['Spree::Pos::OrderNumbers', 'Spree::Pos::CallBoard'])
    modules.register(key: 'fnb.cup_label', group: 'fnb', depends_on: ['fnb.menu'],
                     entrypoints: ['Spree::Api::V3::Admin::Pos::Workspaces::CupLabelsController', 'Spree::Pos::CupLabels::Issue'])
    # GrabFood / ShopeeFood orders typed in at the counter.
    modules.register(key: 'fnb.delivery_platforms', group: 'fnb', depends_on: ['fnb.menu'],
                     entrypoints: ['Spree::Api::V3::Admin::Pos::PlatformOrdersController', 'Spree::Pos::PlatformOrders::Enter'])

    # Areas and tables (rooms, billiard tables) on a branch's floor plan.
    modules.register(key: 'resources', group: 'fnb', depends_on: [],
                     entrypoints: ['Spree::Api::V3::Admin::Pos::ResourcesController', 'Spree::Pos::ResourceState'])
    # Orders at a table: open, move, merge, split.
    modules.register(key: 'fnb.tables', group: 'fnb', depends_on: ['resources'],
                     entrypoints: ['Spree::Api::V3::Admin::Pos::TablesController', 'Spree::Pos::Tables::Open'])
    # Pay after eating: recorded pre-bills and payment requests.
    modules.register(key: 'fnb.postpay', group: 'fnb', depends_on: [],
                     entrypoints: ['Spree::Api::V3::Admin::Pos::PrebillsController', 'Spree::Pos::Workspaces::Prebill'])
    # A taxed percentage charge on the items after discounts.
    modules.register(key: 'fnb.service_charge', group: 'fnb', depends_on: [],
                     entrypoints: ['Spree::Pos::ServiceCharges::Apply'])

    # Bookings of tables and rooms, with deposits kept for the guest.
    modules.register(key: 'fnb.reservations', group: 'fnb', depends_on: ['resources'],
                     entrypoints: ['Spree::Api::V3::Admin::Pos::ReservationsController', 'Spree::Pos::Reservations::Create'])
    # A bar's bottle-keeping book: guests' bottles kept by code, no money.
    modules.register(key: 'fnb.bottle_keep', group: 'fnb', depends_on: [],
                     entrypoints: ['Spree::Api::V3::Admin::Pos::BottleKeepsController', 'Spree::Pos::BottleKeeps::Open'])
    # Pours measured in ml from open bottles, through the recipes.
    modules.register(key: 'fnb.pour_tracking', group: 'fnb', depends_on: ['fnb.recipes'],
                     entrypoints: ['Spree::Api::V3::Admin::Pos::OpenBottlesController', 'Spree::Pos::Fnb::PourTracker'])

    # A canteen's meal accounts: eaters by employee code, prepaid wallets
    # and company sponsors that pay on credit.
    modules.register(key: 'fnb.meal_accounts', group: 'fnb', depends_on: [],
                     entrypoints: ['Spree::Api::V3::Admin::Pos::MealAccountsController', 'Spree::Pos::MealAccounts::Swipe'])
    # A rest stop's coach visits and the commission paid to their drivers.
    modules.register(key: 'fnb.vehicle_commission', group: 'fnb', depends_on: [],
                     entrypoints: ['Spree::Api::V3::Admin::Pos::VehicleVisitsController', 'Spree::Pos::VehicleVisits::Close'])

    # Play time on rooms and billiard tables: rate plans by time of day and
    # kind of day, and clocks billed as a timed line of the room's order.
    modules.register(key: 'timed_billing', group: 'fnb', depends_on: ['resources', 'fnb.tables'],
                     entrypoints: ['Spree::Api::V3::Admin::Pos::TimedSessionsController', 'Spree::Pos::Timed::Start'])

    # Names only, so "coming soon" profiles can refer to them. No code, and
    # no branch can turn them on.
    # Billiard table lights switched by relays.
    modules.planned 'resources.iot_relay', group: 'fnb'
  end

  Spree::Pos::SaleLineKinds.define! do |kinds|
    kinds.add 'ordinary', mergeable: true
    kinds.add 'measured', owner: 'retail.measured', mergeable: true
    kinds.add 'tracked', owner: 'retail.traceability', mergeable: true
    # Lines merge only with the same options and note (see SaleLine.build_merge_key).
    kinds.add 'menu', owner: 'fnb.menu', mergeable: true
    kinds.add 'timed', owner: 'timed_billing'
    kinds.add 'cover', owner: 'fnb.tables'
  end

  Spree::Pos::BusinessProfiles.reload!
end
