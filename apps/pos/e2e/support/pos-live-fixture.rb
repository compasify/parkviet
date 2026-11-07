# frozen_string_literal: true

# Synthetic fixture for the POS live e2e runs, development only.
#
# Run through the Spree CLI from the project root, e.g.
# `pnpm spree exec bin/rails runner log/pos-live-fixture.rb cleanup`.
#
#   bin/rails runner log/pos-live-fixture.rb            create a new fixture
#   bin/rails runner log/pos-live-fixture.rb cleanup    retire every fixture
#   bin/rails runner log/pos-live-fixture.rb cleanup store-flags-off=returns,refunds
#
# Create makes new records tagged `POS Live <tag>` (never touches others) and
# writes the credentials, readable by the owner only, to
# log/pos-live/fixture-<tag>.json (server/log is gitignored); delete it after
# the run. The staff get only what the live journeys use: the cashier sells,
# returns and closes a shift; the manager approves, configures goods and
# flips the store feature switches the journeys need.
#
# Cleanup works only on staff `pos-live-*@example.test`:
# - store feature defaults still switched on by a fixture account (a run
#   that stopped before restoring them) go back off, as do those named in
#   `store-flags-off=`; both are audited, by a fixture manager;
# - unpaid drafts are canceled, drafts paid in full completed, prepared
#   tenders canceled, and each open shift counted at its expected cash and
#   closed;
# - the staff lose their POS memberships, admin roles and password, and are
#   deactivated where the user model supports it.
# It prints what it did and anything it left. No record is deleted except the
# role grants of the fixture accounts.
require 'fileutils'
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
  # The live runs only switch a store default on when it was off, so one a
  # fixture account left on is a leftover of an interrupted run.
  left_on = Spree::Pos::FeatureFlag.for_store(store).where(branch_id: nil, enabled: true, changed_by_id: staff.map(&:id))
                                   .pluck(:feature)
  # Only defaults still on need a change (an absent row already means off).
  restore = ((left_on + flags_off).uniq & Spree::Pos::FeatureFlag::FEATURES)
            .select { |feature| Spree::Pos::FeaturePolicy.store_enabled?(store, feature) }
  report[:unknown_flags_ignored] = flags_off - Spree::Pos::FeatureFlag::FEATURES
  if restore.any?
    actor = staff.find do |user|
      user.email.start_with?('pos-live-manager-') &&
        Spree::Pos::FeaturePolicy.store_manager?(Spree::Pos::AccessPolicy.new(store: store, staff: user))
    end
    abort 'No fixture manager with store rights left to switch store defaults off' unless actor
    restore.each do |feature|
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
    # Retire the account even where something above was left: it can no
    # longer sign in nor act at any branch.
    memberships = Spree::Pos::StaffMembership.for_store(store).where(staff_id: user.id, status: 'active')
    report[:memberships_disabled] << user.email if memberships.update_all(status: 'disabled', updated_at: Time.current).positive?
    grants = Spree::RoleUser.where(user: user)
    report[:roles_removed] << user.email if grants.any? && grants.destroy_all
    password = SecureRandom.base58(32)
    user.update!(password: password, password_confirmation: password)
    report[:passwords_scrambled] << user.email
    if user.respond_to?(:deactivate!) && !(user.respond_to?(:deactivated?) && user.deactivated?)
      user.deactivate!
      report[:staff_deactivated] << user.email
    end
  end
  report.delete(:unknown_flags_ignored) if report[:unknown_flags_ignored].empty?
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
# Sell (including serials and lots, which need the trace reader), recover a
# lost answer on its own draft, return and pay a cash refund, close the shift.
cashier_caps = [caps::OPEN_SHIFT, caps::PAYMENT, caps::RETURN, caps::REPORT_READ, caps::TAKEOVER, caps::INVENTORY_TRACE]
# Approve a refund, set units and label codes, open tracked stock. The store
# feature switches come from the role's `write_pos_topology`, not from here.
manager_caps = [caps::APPROVE, caps::MANAGE, caps::INVENTORY_MANAGE]

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

# log/ is bind-mounted from server/log (gitignored); the container's tmp/ is not.
directory = Rails.root.join('log/pos-live')
FileUtils.mkdir_p(directory)
path = directory.join("fixture-#{result[:tag]}.json")
File.open(path, File::WRONLY | File::CREAT | File::TRUNC, 0o600) { |file| file.write(JSON.pretty_generate(result)) }
puts "POS live fixture #{result[:tag]}: branch #{result[:branch_id]}, register #{result[:register_id]}, " \
     "credentials in server/log/pos-live/#{path.basename}"
