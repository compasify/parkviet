# frozen_string_literal: true

require_relative 'pos_kitchen_helpers'

# Delivery platform orders entered at a counter-service branch, built on the
# real models and workflows, for platform order workflow, report and request
# specs.
module PosPlatformHelpers
  include PosKitchenHelpers

  Counter = Struct.new(:cashier, :register, :editor_id, keyword_init: true)

  def platform_branch(store, rate: 25, trigger: 'on_complete')
    branch = kitchen_branch(store, trigger: trigger)
    set_pos_module(branch, 'fnb.order_number', true)
    set_pos_module(branch, 'fnb.delivery_platforms', true)
    Spree::Pos::PlatformSetting.create!(store: store, branch: branch, platform: 'grabfood', commission_rate: rate, status: 'active')
    branch
  end

  # A cashier with an open drawer, and the editor id of their screen.
  def platform_counter(store, branch, capabilities: PosCreditHelpers::CASHIER)
    cashier = credit_staff(store, branch, capabilities)
    Counter.new(cashier: cashier, register: open_drawer(store, branch, cashier), editor_id: SecureRandom.uuid)
  end

  def platform_line(variant, quantity: 1, price: nil, modifiers: nil, note: nil)
    { 'variant_id' => variant.prefixed_id, 'quantity' => quantity, 'platform_price' => price&.to_s, 'modifiers' => modifiers,
      'note' => note }.compact
  end

  def enter_platform(store, counter, lines:, ref: "GF-#{SecureRandom.hex(3)}", platform: 'grabfood', pickup: 'A12',
                     key: SecureRandom.uuid)
    result = Spree::Pos::PlatformOrders::Enter.call(
      store: store, staff: counter.cashier, key: key, editor_id: counter.editor_id, register_id: counter.register.prefixed_id,
      platform: platform, platform_order_ref: ref, pickup_code: pickup, lines: lines
    )
    Spree::Pos::PlatformOrder.find_by_prefix_id!(result['id'])
  end

  def complete_platform(order, counter, key: SecureRandom.uuid)
    Spree::Pos::PlatformOrders::Complete.call(platform_order: order.reload, staff: counter.cashier, key: key,
                                              editor_id: counter.editor_id)
  end

  def bump_platform(order, actor)
    Spree::Pos::KitchenTicket.where(workspace_id: order.workspace_id).find_each do |ticket|
      Spree::Pos::Kitchen::ChangeItemStatus.bump(ticket: ticket, actor: actor)
    end
  end
end
