# frozen_string_literal: true

require_relative 'pos_kitchen_helpers'

# Tables, areas and table orders built on the real workflows, at a branch
# running the table modules with a table register whose shift is open.
module PosTableHelpers
  include PosKitchenHelpers

  TABLE_MODULES = %w[resources fnb.tables fnb.postpay fnb.service_charge].freeze
  WAITER = [Spree::Pos::Capabilities::TABLE_SERVE].freeze

  TableOrder = Struct.new(:workspace, :cashier, :editor_id, :product, keyword_init: true)

  def table_branch(store, modules: TABLE_MODULES)
    branch = kitchen_branch(store, trigger: 'manual')
    modules.each { |key| set_pos_module(branch, key, true) }
    branch
  end

  # The branch's table register, with `cashier`'s shift open on it.
  def table_register!(branch, cashier)
    register = open_drawer(branch.store, branch, cashier)
    branch.update!(table_register: register)
    register
  end

  def area!(branch, name: 'Tầng 1', width: 24, height: 16)
    Spree::Pos::Area.create!(store: branch.store, branch: branch, name: name, floor_width: width, floor_height: height)
  end

  def table!(area, name:, x: 0, y: 0, capacity: 4, **attributes)
    Spree::Pos::Resource.create!(store: area.store, branch: area.branch, area: area, name: name, x: x, y: y, capacity: capacity, **attributes)
  end

  def open_table(staff, table, guest_count: 2, add_order: false, editor_id: SecureRandom.uuid, key: SecureRandom.uuid)
    result = Spree::Pos::Tables::Open.call(store: table.store, staff: staff, key: key, editor_id: editor_id, branch_id: table.branch.prefixed_id,
                                           resource_id: table.prefixed_id, guest_count: guest_count, add_order: add_order)
    TableOrder.new(workspace: Spree::Pos::Workspace.find_by_prefix_id!(result['id']), cashier: staff, editor_id: editor_id)
  end

  def menu_product!(store, branch, name: "Món #{SecureRandom.hex(2)}", price: 50_000)
    size(menu_item!(store, branch, name: name, price: price))
  end

  def add_dish(order, variant, quantity: 1)
    Spree::Pos::Workspaces::ManageLineItem.add(**editing_args(order), variant_id: variant.prefixed_id, quantity: quantity)
  end

  # A cash tender prepared but not yet confirmed: it locks the order's snapshot.
  def prepare_cash(order, amount)
    method = Spree::Pos::PaymentMethodResolver.new(store: order.workspace.store).available.find { |row| row.kind == 'cash' }
    Spree::Pos::Tenders::Prepare.call(**editing_args(order), payment_method_id: method.prefixed_id || 'posmethod-cash', amount: amount.to_s)
  end
end
