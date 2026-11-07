# frozen_string_literal: true

# Synthetic fixture for the POS live e2e runs, development only.
#
#   bin/rails runner log/pos-live-fixture.rb            create a new fixture
#   bin/rails runner log/pos-live-fixture.rb cleanup    retire every fixture
#   bin/rails runner log/pos-live-fixture.rb cleanup store-flags-off=returns,refunds
#
# Create makes new records tagged `POS Live <tag>` (never touches others) and
# writes the credentials to log/pos-live-fixture.json; move that file out of
# the repo at once. Cleanup works only on staff `pos-live-*@example.test`:
# cancels their unpaid drafts, completes drafts already paid in full, cancels
# prepared tenders, counts each open shift at its expected cash and closes it,
# then deactivates the staff. It prints what it did and anything it left.
# Nothing is deleted. `store-flags-off=` switches those store defaults off
# again (audited, by one of the fixture managers, before deactivation).
require 'json'
require 'securerandom'

abort 'Development environment required' unless Rails.env.development?
host = ActiveRecord::Base.connection_db_config.host.to_s
# Local: no host, loopback, or a single-label docker service name (e.g. `postgres`).
local = host.empty? || %w[localhost 127.0.0.1 ::1].include?(host) || host.match?(/\A[a-z0-9_-]+\z/i)
abort "Refusing to run against a non-local database host (#{host})" unless local

store = Spree::Store.default
Spree::Current.store = store
caps = Spree::Pos::Capabilities
EMAIL_PATTERN = 'pos-live-%@example.test'

def key = SecureRandom.uuid

def cleanup(store, flags_off)
  staff = Spree.admin_user_class.where('email LIKE ?', EMAIL_PATTERN).to_a
  report = Hash.new { |hash, name| hash[name] = [] }
  if flags_off.any?
    actor = staff.find { |user| user.email.start_with?('pos-live-manager-') }
    abort 'No fixture manager left to switch store defaults off' unless actor
    flags_off.each do |feature|
      Spree::Pos::FeaturePolicy.set!(store: store, actor: actor, feature: feature, enabled: false,
                                     reason: 'Khôi phục sau kiểm thử e2e thật')
      report[:store_flags_off] << feature
    end
  end
  staff.each do |user|
    Spree::Pos::Shift.for_store(store).where(owner_id: user.id, status: 'open').find_each do |shift|
      Spree::Pos::Workspace.where(shift_id: shift.id).where(operational_status: %w[editing parked]).find_each do |workspace|
        editor = SecureRandom.uuid
        Spree::Pos::Workspaces::ClaimLease.call(workspace: workspace, staff: user, key: key, editor_id: editor, takeover: true)
        args = -> { w = workspace.reload; { workspace: w, staff: user, revision: w.revision, lease_generation: w.lease_generation, editor_id: editor, key: key } }
        Spree::Pos::TenderAttempt.where(workspace_id: workspace.id, status: 'prepared').find_each do |attempt|
          Spree::Pos::Tenders::Cancel.call(**args.call, attempt_id: attempt.prefixed_id)
          report[:tenders_canceled] << attempt.prefixed_id
        end
        begin
          Spree::Pos::Workspaces::ChangeStatus.call(**args.call, status: 'canceled')
          report[:drafts_canceled] << workspace.prefixed_id
        rescue Spree::Pos::Conflict => e
          raise unless e.reason == 'payments_recorded'

          # Paid in full: complete it, as the cashier would have.
          Spree::Pos::Workspaces::Complete.call(**args.call)
          report[:drafts_completed] << workspace.prefixed_id
        end
      rescue StandardError => e
        report[:drafts_left] << "#{workspace.prefixed_id}: #{e.class}: #{e.message}"
      end
      begin
        expected = Spree::Pos::CashbookProjection.new(shift.reload).expected
        Spree::Pos::Shifts::Count.call(store: store, staff: user, key: key, shift_id: shift.prefixed_id, counted: expected.to_s)
        Spree::Pos::Shifts::Close.call(store: store, staff: user, key: key, shift_id: shift.prefixed_id)
        report[:shifts_closed] << "#{shift.prefixed_id} (#{expected.to_s('F')})"
      rescue StandardError => e
        report[:shifts_left] << "#{shift.prefixed_id}: #{e.class}: #{e.message}"
      end
    end
    if user.respond_to?(:deactivate!) && !(user.respond_to?(:deactivated?) && user.deactivated?)
      user.deactivate!
      report[:staff_deactivated] << user.email
    end
  end
  puts JSON.pretty_generate(report)
end

if ARGV.first == 'cleanup'
  flags = ARGV.find { |arg| arg.start_with?('store-flags-off=') }&.split('=', 2)&.last.to_s.split(',')
  cleanup(store, flags.map(&:strip).reject(&:empty?))
  exit
end

tag = SecureRandom.hex(5)
# The cashier only sells: order and shift permissions, no topology writes.
cashier_permissions = %w[read_pos_orders write_pos_orders write_pos_workspaces read_pos_shifts write_pos_shifts]
manager_permissions = cashier_permissions + %w[read_pos_topology write_pos_topology]
cashier_caps = [caps::OPEN_SHIFT, caps::PAYMENT, caps::RESOLVE, caps::CUSTOMER, caps::CREDIT_SELL, caps::RETURN,
                caps::CASH_MOVE, caps::REPORT_READ, caps::TAKEOVER, caps::INVENTORY_TRACE]
manager_caps = [caps::OPEN_SHIFT, caps::PAYMENT, caps::RESOLVE, caps::APPROVE, caps::CREDIT_MANAGE, caps::RETURN,
                caps::CASH_MOVE, caps::RECOVER, caps::MANAGE, caps::TAKEOVER, caps::INVENTORY_MANAGE, caps::INVENTORY_TRACE,
                caps::REPORT_READ, caps::REPORT_EXPORT]

result = ActiveRecord::Base.transaction do
  location = Spree::StockLocation.create!(
    store: store, name: "POS Live #{tag}", address1: '1 Synthetic St', city: 'HCM', zipcode: '70000',
    country_code: 'VN', active: true, backorderable_default: false, propagate_all_variants: false
  )
  branch = Spree::Pos::Branch.create!(store: store, stock_location: location, name: "POS Live #{tag}", code: "live#{tag}",
                                      timezone: 'Asia/Ho_Chi_Minh', status: 'active', return_window_days: 30)
  register = Spree::Pos::Register.create!(store: store, branch: branch, name: "POS Live #{tag}", code: "q#{tag}", status: 'active')
  roles = {
    'cashier' => Spree::Role.create!(name: "pos-live-cashier-#{tag}", resource: store, permissions: cashier_permissions),
    'manager' => Spree::Role.create!(name: "pos-live-manager-#{tag}", resource: store, permissions: manager_permissions)
  }
  staff = %w[cashier manager].to_h do |kind|
    password = SecureRandom.base58(20)
    user = Spree.admin_user_class.create!(email: "pos-live-#{kind}-#{tag}@example.test", password: password,
                                          password_confirmation: password)
    user.update!(first_name: 'POS Live', last_name: kind == 'cashier' ? 'Thu ngân' : 'Quản lý') if user.respond_to?(:first_name=)
    Spree::RoleUser.create!(role: roles[kind], user: user)
    Spree::Pos::StaffMembership.create!(store: store, branch: branch, staff: user, status: 'active',
                                        capabilities: kind == 'cashier' ? cashier_caps : manager_caps)
    [kind, { user: user, password: password }]
  end
  manager = staff['manager'][:user]
  # Feature flags stay off here: every live test turns on what it needs
  # through PUT /pos/feature_flags as the manager and restores it afterwards.
  products = {
    'rice' => ['Gạo live', 100_000, 100],
    'water' => ['Nước live', 5_000, 100],
    'pork' => ['Thịt live', 100_000, 10_000],
    'phone' => ['Điện thoại live', 2_500_000, 3],
    'yogurt' => ['Sữa chua live', 50_000, 12]
  }.to_h do |name_key, (name, price, stock)|
    product = Spree::Product.create!(name: "#{name} #{tag}",
                                     status: 'active', store: store)
    variant = product.default_variant
    variant.set_price(store.default_currency, price)
    barcode = "89#{rand(10**10).to_s.rjust(10, '0')}"
    variant.update!(barcode: barcode) if variant.respond_to?(:barcode=)
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    location.restock(variant, stock)
    [name_key, { product_id: product.prefixed_id, variant_id: variant.prefixed_id, barcode: barcode, name: product.name, price: price }]
  end
  Spree::Pos::Shifts::Open.call(store: store, staff: staff['cashier'][:user], register: register, opening_float: '0')
  {
    tag: tag, branch_id: branch.prefixed_id, register_id: register.prefixed_id,
    cashier: { email: staff['cashier'][:user].email, password: staff['cashier'][:password] },
    manager: { email: manager.email, password: staff['manager'][:password] },
    label_code: rand(10_000..99_999).to_s, products: products
  }
end

File.write(Rails.root.join('log/pos-live-fixture.json'), JSON.pretty_generate(result))
puts "POS live fixture #{result[:tag]}: branch #{result[:branch_id]}, register #{result[:register_id]}"
