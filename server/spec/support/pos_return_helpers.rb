# frozen_string_literal: true

require_relative 'pos_credit_helpers'

# Sells, hands over and returns through the real POS workflows, so return,
# refund and race specs share one setup.
module PosReturnHelpers
  include PosCreditHelpers

  CAPS = Spree::Pos::Capabilities
  RETURNS = [CAPS::OPEN_SHIFT, CAPS::PAYMENT, CAPS::CREDIT_SELL, CAPS::DISCOUNT, CAPS::RETURN].freeze
  APPROVER = [CAPS::OPEN_SHIFT, CAPS::PAYMENT, CAPS::RESOLVE, CAPS::APPROVE, CAPS::CREDIT_MANAGE, CAPS::RETURN].freeze

  def returns_branch(store, window: 30)
    branch = credit_branch(store)
    branch.update!(return_window_days: window)
    branch
  end

  def stocked_product(store, branch, price:, stock: 10)
    product = create(:product, store: store, status: 'active', name: "Hang #{SecureRandom.hex(3)}")
    product.default_variant.set_price(store.default_currency, price)
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    branch.stock_location.restock(product.default_variant, stock)
    product
  end

  # A sale of `quantity` units at the cashier's own drawer, not yet paid.
  def open_sale(store, branch, cashier:, product:, quantity: 1)
    editor_id = SecureRandom.uuid
    register = Spree::Pos::Shift.for_store(store).open_now.find_by(branch_id: branch.id, owner_id: cashier.id)&.register ||
      open_drawer(store, branch, cashier)
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: cashier, register_id: register.prefixed_id,
                                                  key: SecureRandom.uuid, editor_id: editor_id)
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
    Spree::Pos::Workspaces::ManageLineItem.add(workspace: workspace, staff: cashier, revision: 0, key: SecureRandom.uuid,
                                               lease_generation: workspace.lease_generation, editor_id: editor_id,
                                               variant_id: product.default_variant.prefixed_id, quantity: quantity)
    PosCreditHelpers::Sale.new(workspace: workspace.reload, cashier: cashier, editor_id: editor_id, product: product)
  end

  def complete_paid(sale, kind: 'cash')
    take_tender(sale, kind, sale.workspace.reload.order.total.to_i)
    Spree::Pos::Workspaces::Complete.call(**editing_args(sale))
  end

  def hand_over(sale, key: SecureRandom.uuid)
    Spree::Pos::Orders::Handover.call(workspace: sale.workspace.reload, staff: sale.cashier, key: key)
  end

  # Paid in full (cash) and handed over.
  def paid_sale(store, branch, cashier:, price:, quantity: 1, product: nil, kind: 'cash')
    product ||= stocked_product(store, branch, price: price)
    sale = open_sale(store, branch, cashier: cashier, product: product, quantity: quantity)
    complete_paid(sale, kind: kind)
    hand_over(sale)
    sale
  end

  def sale_line(sale)
    Spree::Pos::SaleLine.where(workspace_id: sale.workspace.id).order(:id).first
  end

  def prepare_return(store, staff, branch, sale, quantity:, condition: 'resellable', line: sale_line(sale), key: SecureRandom.uuid)
    Spree::Pos::Returns::Prepare.call(
      store: store, staff: staff, key: key, branch_id: branch.prefixed_id, order_id: sale.workspace.order.prefixed_id,
      reason: 'Khách đổi ý', lines: [{ 'sale_line_id' => line.prefixed_id, 'quantity' => quantity, 'condition' => condition }]
    )
  end

  def receive_return(store, staff, result, approval_id: nil, key: SecureRandom.uuid)
    Spree::Pos::Returns::Receive.call(store: store, staff: staff, key: key, return_id: result['id'], approval_id: approval_id)
  end

  def return_and_receive(store, staff, branch, sale, quantity:, condition: 'resellable')
    receive_return(store, staff, prepare_return(store, staff, branch, sale, quantity: quantity, condition: condition))
  end

  def operation(result)
    Spree::Pos::ReturnOperation.find_by_prefix_id!(result['id'])
  end

  def allocation_of(sale)
    Spree::Pos::FundsAllocation.where(order_id: sale.workspace.order_id, status: 'active').order(:id).first
  end

  def request_refund(store, staff, result, amount:, method: 'cash', allocation: nil, key: SecureRandom.uuid)
    op = operation(result)
    allocation ||= Spree::Pos::FundsAllocation.where(order_id: op.order_id, status: 'active').order(:id).first
    Spree::Pos::Refunds::Request.call(store: store, staff: staff, key: key, return_id: op.prefixed_id,
                                      allocation_id: allocation.prefixed_id, amount: amount.to_s, method: method,
                                      beneficiary_reference: method == 'bank_manual' ? 'VCB 0123 Nguyen Van A' : nil)
  end

  def approve_refund(store, approver, refund)
    Spree::Pos::Refunds::Approve.call(store: store, staff: approver, key: SecureRandom.uuid, refund_id: refund['id'])
  end

  def confirm_refund(store, staff, refund, key: SecureRandom.uuid, reference: nil)
    request = Spree::Pos::RefundRequest.find_by_prefix_id!(refund['id'])
    kind = request.method == 'cash' ? 'cash_count' : 'bank_manual'
    Spree::Pos::Refunds::ConfirmPayout.call(store: store, staff: staff, key: key, refund_id: refund['id'], evidence_kind: kind,
                                            reference: reference || (kind == 'bank_manual' ? "FT#{SecureRandom.hex(3)}" : nil))
  end

  def on_hand(branch, product)
    branch.stock_location.stock_level(product.default_variant).reload.count_on_hand
  end
end
