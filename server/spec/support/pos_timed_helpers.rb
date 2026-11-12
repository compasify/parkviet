# frozen_string_literal: true

require_relative 'pos_table_helpers'

# Karaoke rooms and billiard tables billed by the time played, built on the
# real workflows: a branch running `timed_billing`, the service sold for the
# time, rate plans and a clock driven by travel_to (the commands read the
# database clock through Workspace.database_now, stubbed to follow it).
module PosTimedHelpers
  include PosTableHelpers
  include ActiveSupport::Testing::TimeHelpers

  TIMED_MODULES = (PosTableHelpers::TABLE_MODULES + ['timed_billing']).freeze
  OPERATOR = (PosCreditHelpers::CASHIER + [Spree::Pos::Capabilities::TABLE_SERVE, Spree::Pos::Capabilities::TIMED_OPERATE]).freeze
  ZONE = ActiveSupport::TimeZone['Asia/Ho_Chi_Minh']

  def timed_branch(store)
    table_branch(store, modules: TIMED_MODULES)
  end

  # Moves the server's clock; every command after reads this time.
  def clock_at(text)
    travel_to(text.is_a?(String) ? ZONE.parse(text) : text)
    allow(Spree::Pos::Workspace).to receive(:database_now) { Time.current }
  end

  # Moves only the database clock the commands read, for request specs:
  # sign-in tokens keep the real time.
  def server_clock_at(text)
    at = text.is_a?(String) ? ZONE.parse(text) : text
    allow(Spree::Pos::Workspace).to receive(:database_now).and_return(at)
  end

  # The service product the time is sold as; not stocked.
  def time_service!(store, branch, name: 'Giờ hát', tax_category: nil)
    product = create(:product, store: store, status: 'active', name: name)
    product.update!(tax_category: tax_category) if tax_category
    variant = product.default_variant
    variant.update!(track_inventory: false)
    variant.set_price(store.default_currency, 0)
    Spree::Pos::BranchProduct.find_or_create_by!(branch: branch, product: product)
    variant
  end

  # Weekdays: `day` an hour until 18:00, `evening` after; weekends `weekend` all day.
  def rate_plan!(branch, variant:, type:, day: 100_000, evening: 150_000, weekend: 200_000, block: 15, grace: 5, minimum: 0,
                 evening_from: 1080)
    plan = Spree::Pos::RatePlan.new(store: branch.store, branch: branch, name: "Giá #{type}", resource_type_code: type, variant: variant,
                                    block_minutes: block, grace_minutes: grace, minimum_minutes: minimum, status: 'active', version: 1)
    plan.rate_rules.build(day_type: 'weekday', start_minute: 0, end_minute: evening_from, price_per_hour: day, label: 'Ngày', position: 1)
    plan.rate_rules.build(day_type: 'weekday', start_minute: evening_from, end_minute: 1440, price_per_hour: evening, label: 'Tối', position: 2)
    plan.rate_rules.build(day_type: 'weekend', start_minute: 0, end_minute: 1440, price_per_hour: weekend, label: 'Cuối tuần', position: 3)
    plan.save!
    plan
  end

  def room!(area, name:, type:, kind: 'room', x: 0)
    table!(area, name: name, kind: kind, resource_type_code: type, x: x)
  end

  def start_clock(staff, room, editor_id: SecureRandom.uuid, key: SecureRandom.uuid, **options)
    Spree::Pos::Timed::Start.call(store: room.store, staff: staff, key: key, editor_id: editor_id, branch_id: room.branch.prefixed_id,
                                  resource_id: room.prefixed_id, **options)
  end

  def session_of(result)
    Spree::Pos::TimedSession.find_by_prefix_id!(result['timed_session']['id'])
  end

  def stop_clock(session, staff, key: SecureRandom.uuid)
    Spree::Pos::Timed::Stop.call(session: session.reload, staff: staff, key: key)
  end

  def local(text) = ZONE.parse(text)

  # The room's order held by `staff` on `editor_id` from now, for editing
  # commands: the lease from the opening ran out while the clock ran.
  def order_of(session, staff, editor_id = SecureRandom.uuid)
    workspace = session.reload.workspace
    Spree::Pos::Workspaces::ClaimLease.call(workspace: workspace, staff: staff, key: SecureRandom.uuid, editor_id: editor_id)
    PosTableHelpers::TableOrder.new(workspace: workspace.reload, cashier: staff, editor_id: editor_id)
  end
end
