# frozen_string_literal: true

require_relative '../../../support/pos_return_helpers'

# Stock effects of the counter: placement allocates once, handover depletes
# once, a short shelf is recorded (not forced negative, not blocking), and a
# return restocks only resellable units, once, into the receiving branch.
RSpec.describe 'POS fulfillment and returns', type: :request do
  include PosReturnHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:manager) { credit_staff(store, branch, PosReturnHelpers::APPROVER) }
  let(:cashier) { credit_staff(store, branch, PosReturnHelpers::RETURNS) }

  def level(branch_for, product)
    branch_for.stock_location.stock_level(product.default_variant).reload
  end

  it 'allocates on placement and depletes on handover exactly once across complete, handover and receive retries' do
    product = stocked_product(store, branch, price: 50_000, stock: 10)
    sale = open_sale(store, branch, cashier: cashier, product: product, quantity: 2)
    take_tender(sale, 'cash', 100_000)
    args = editing_args(sale)
    completed = Spree::Pos::Workspaces::Complete.call(**args)
    expect(Spree::Pos::Workspaces::Complete.call(**args)).to eq(completed)
    expect { Spree::Pos::Workspaces::Complete.call(**editing_args(sale)) }.to raise_error(Spree::Pos::Conflict)
    expect(level(branch, product)).to have_attributes(count_on_hand: 10, allocated_count: 2)

    key = SecureRandom.uuid
    hand_over(sale, key: key)
    hand_over(sale, key: key)
    hand_over(sale)
    expect(level(branch, product)).to have_attributes(count_on_hand: 8, allocated_count: 0)

    prepared = prepare_return(store, cashier, branch, sale, quantity: 2)
    receive_key = SecureRandom.uuid
    received = receive_return(store, cashier, prepared, key: receive_key)
    expect(receive_return(store, cashier, prepared, key: receive_key)).to eq(received)
    expect { receive_return(store, cashier, prepared) }.to raise_error(Spree::Pos::Conflict, /already received/)
    expect(level(branch, product).count_on_hand).to eq(10)
    expect(operation(prepared).core_return.reload.status).to eq('received')
  end

  it 'moves no stock when a debt is collected later' do
    profile = credit_customer(store, manager)
    configure_credit(store, manager, branch, profile, limit: 1_000_000)
    product = stocked_product(store, branch, price: 100_000, stock: 5)
    sale = open_sale(store, branch, cashier: cashier, product: product)
    assign(sale, profile)
    complete_on_credit(sale, approve_credit(sale, manager, 100_000)['approval_id'])
    hand_over(sale)
    before = level(branch, product).attributes.slice('count_on_hand', 'allocated_count')
    open_drawer(store, branch, manager)
    Spree::Pos::Collections::Receive.call(
      store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
      credit_account_id: Spree::Pos::CreditAccount.find_by!(customer_profile: profile).prefixed_id, kind: 'cash', amount: '100000',
      allocations: [{ 'order_id' => sale.workspace.order.prefixed_id, 'amount' => '100000' }]
    )
    expect(level(branch, product).attributes.slice('count_on_hand', 'allocated_count')).to eq(before)
  end

  it 'records a short shelf at handover without blocking or going negative, and ships once after reconciliation' do
    product = stocked_product(store, branch, price: 20_000, stock: 3)
    sale = open_sale(store, branch, cashier: cashier, product: product, quantity: 3)
    complete_paid(sale)
    # The shelf changed after the sale was rung up (an online order shipped,
    # a count was corrected); the goods are still in front of the cashier.
    level(branch, product).update_columns(count_on_hand: 1)
    result = hand_over(sale)

    expect(result['stock_discrepancies'].first).to include('needed' => 3, 'on_hand' => 1, 'status' => 'open')
    expect(level(branch, product)).to have_attributes(count_on_hand: 1, allocated_count: 3)
    hand_over(sale)
    expect(Spree::Pos::StockDiscrepancy.where(order_id: sale.workspace.order_id).count).to eq(1)
    expect(Spree::Pos::OutboxEntry.where(event_type: 'stock.discrepancy').count).to eq(1)
    expect { prepare_return(store, cashier, branch, sale, quantity: 1) }.to raise_error(Spree::Pos::Conflict, /not handed over/)

    branch.stock_location.restock(product.default_variant, 2)
    hand_over(sale)
    hand_over(sale)
    expect(level(branch, product)).to have_attributes(count_on_hand: 0, allocated_count: 0)
    expect(Spree::Pos::StockDiscrepancy.find_by!(order_id: sale.workspace.order_id).status).to eq('resolved')
  end

  it 'records damaged units without restocking them, and still grants their value' do
    product = stocked_product(store, branch, price: 30_000, stock: 5)
    sale = paid_sale(store, branch, cashier: cashier, price: 30_000, quantity: 2, product: product)
    prepared = prepare_return(store, cashier, branch, sale, quantity: 2, condition: 'damaged')
    expect(prepared).to include('status' => 'pending_approval', 'damaged' => true, 'requires_approval' => true)
    expect { receive_return(store, cashier, prepared) }.to raise_error(Spree::Pos::Conflict, /needs an approval/)

    approved = Spree::Pos::Returns::Approve.call(store: store, staff: manager, key: SecureRandom.uuid, return_id: prepared['id'])
    received = receive_return(store, cashier, prepared, approval_id: approved.dig('approval', 'id'))

    expect(level(branch, product).count_on_hand).to eq(3)
    expect(received['lines'].first).to include('received_quantity' => 2, 'restocked_quantity' => 0, 'condition' => 'damaged')
    expect(received).to include('entitlement_total' => '60000.0', 'refund_entitlement' => '60000.0')
    expect(operation(prepared).core_return.return_line_items.first.resellable).to be(false)
  end

  it 'takes a cross-branch return only with approval, restocking the receiving branch and leaving the selling branch alone' do
    product = stocked_product(store, branch, price: 40_000, stock: 5)
    sale = paid_sale(store, branch, cashier: cashier, price: 40_000, product: product)
    other = returns_branch(store)
    other_cashier = credit_staff(store, other, PosReturnHelpers::RETURNS)
    other_manager = credit_staff(store, other, PosReturnHelpers::APPROVER)

    prepared = prepare_return(store, other_cashier, other, sale, quantity: 1)
    expect(prepared).to include('cross_branch' => true, 'status' => 'pending_approval', 'branch_id' => other.prefixed_id)
    # An approver of the selling branch is not an approver here.
    expect do
      Spree::Pos::Returns::Approve.call(store: store, staff: manager, key: SecureRandom.uuid, return_id: prepared['id'])
    end.to raise_error(CanCan::AccessDenied)
    approved = Spree::Pos::Returns::Approve.call(store: store, staff: other_manager, key: SecureRandom.uuid, return_id: prepared['id'])
    receive_return(store, other_cashier, prepared, approval_id: approved.dig('approval', 'id'))

    expect(level(other, product).count_on_hand).to eq(1)
    expect(level(branch, product).count_on_hand).to eq(4)
    expect(operation(prepared).core_return.stock_location).to eq(other.stock_location)
  end

  it 'refuses returns where they are off, and asks for approval outside the window' do
    sale = paid_sale(store, branch, cashier: cashier, price: 10_000)
    closed = credit_branch(store)
    closed_staff = credit_staff(store, closed, PosReturnHelpers::RETURNS)
    expect { prepare_return(store, closed_staff, closed, sale, quantity: 1) }.to raise_error(Spree::Pos::Conflict, /not enabled/)

    sale.workspace.order.update_columns(completed_at: 40.days.ago)
    prepared = prepare_return(store, cashier, branch, sale, quantity: 1)
    expect(prepared).to include('out_of_window' => true, 'requires_approval' => true)
  end

  it 'refuses an approval reused for another return, after a re-price, or after it was consumed' do
    sale = paid_sale(store, branch, cashier: cashier, price: 10_000, quantity: 3)
    first = prepare_return(store, cashier, branch, sale, quantity: 1, condition: 'damaged')
    second = prepare_return(store, cashier, branch, sale, quantity: 1, condition: 'damaged')
    approval = Spree::Pos::Returns::Approve.call(store: store, staff: manager, key: SecureRandom.uuid, return_id: first['id']).dig('approval', 'id')

    expect { receive_return(store, cashier, second, approval_id: approval) }.to raise_error(Spree::Pos::Conflict, /does not match/)
    receive_return(store, cashier, first, approval_id: approval)
    expect(Spree::Pos::Approval.find_by_prefix_id!(approval).status).to eq('consumed')
    other = Spree::Pos::Returns::Approve.call(store: store, staff: manager, key: SecureRandom.uuid, return_id: second['id']).dig('approval', 'id')
    Spree::Pos::Approvals::Revoke.call(approval: Spree::Pos::Approval.find_by_prefix_id!(other), staff: manager)
    expect { receive_return(store, cashier, second, approval_id: other) }.to raise_error(Spree::Pos::Conflict, /reused/)
    expect do
      Spree::Pos::Returns::Approve.call(store: store, staff: cashier, key: SecureRandom.uuid, return_id: second['id'])
    end.to raise_error(CanCan::AccessDenied)
  end

  it 'links an exchange to a replacement sale that is paid through normal tenders' do
    sale = paid_sale(store, branch, cashier: cashier, price: 100_000)
    returned = return_and_receive(store, cashier, branch, sale, quantity: 1)
    register = Spree::Pos::Shift.open_now.find_by!(owner: cashier).register
    editor_id = SecureRandom.uuid
    exchange = Spree::Pos::Exchanges::Execute.call(store: store, staff: cashier, key: SecureRandom.uuid, return_id: returned['id'],
                                                   editor_id: editor_id, register_id: register.prefixed_id)
    expect(exchange).to include('return_id' => returned['id'], 'refund_entitlement' => '100000.0', 'replacement_status' => 'editing')
    replacement = Spree::Pos::Workspace.find_by_prefix_id!(exchange['replacement_workspace_id'])
    expect(replacement.order).not_to eq(sale.workspace.order)
    expect do
      Spree::Pos::Exchanges::Execute.call(store: store, staff: cashier, key: SecureRandom.uuid, return_id: returned['id'],
                                          editor_id: SecureRandom.uuid, register_id: register.prefixed_id)
    end.to raise_error(Spree::Pos::Conflict, /already has an exchange/)
    # No difference is shown until the replacement has a total.
    record = Spree::Pos::ExchangeOperation.find_by_prefix_id!(exchange['id'])
    expect(record.to_pos).to include(store_refunds: nil, customer_pays: nil)

    pricier = stocked_product(store, branch, price: 150_000)
    replacement.reload
    Spree::Pos::Workspaces::ManageLineItem.add(workspace: replacement, staff: cashier, revision: replacement.revision,
                                               key: SecureRandom.uuid, lease_generation: replacement.lease_generation,
                                               editor_id: editor_id, variant_id: pricier.default_variant.prefixed_id, quantity: 1)
    expect(record.reload.to_pos).to include(refund_owed: '100000.0', customer_pays: '50000.0', store_refunds: '0.0')

    # Once the 100k was paid back in cash, the customer owes the full 150k on the new sale.
    refund = request_refund(store, cashier, returned, amount: 100_000)
    approve_refund(store, manager, refund)
    confirm_refund(store, cashier, refund)
    expect(record.reload.to_pos).to include(refunded: '100000.0', refund_owed: '0.0', customer_pays: '150000.0')
  end

  context 'when a counter handover was short' do
    def short_sale
      product = stocked_product(store, branch, price: 20_000, stock: 2)
      sale = open_sale(store, branch, cashier: cashier, product: product, quantity: 2)
      complete_paid(sale)
      level(branch, product).update_columns(count_on_hand: 1)
      hand_over(sale)
      [sale, product]
    end

    it 'emits handover_short, not handed_over, and keeps the order allocated' do
      sale, = short_sale
      events = Spree::Pos::OutboxEntry.where(aggregate_type: 'Spree::Pos::Workspace', aggregate_id: sale.workspace.id).pluck(:event_type)
      expect(events).to include('order.handover_short')
      expect(events).not_to include('order.handed_over')
      expect(Spree::Pos::AuditEntry.where(subject_id: sale.workspace.id, action: 'order.handover_short')).to exist
    end

    it 'lets a resolver of the branch finish it after the cashier shift closed, once the shelf was corrected' do
      sale, product = short_sale
      Spree::Pos::Shift.where(owner_id: cashier.id).update_all(status: 'closed')
      order_id = sale.workspace.order.prefixed_id
      reconcile = ->(staff) { Spree::Pos::Orders::ReconcileHandover.call(store: store, staff: staff, key: SecureRandom.uuid, order_id: order_id) }

      expect { reconcile.call(cashier) }.to raise_error(CanCan::AccessDenied)
      still_short = reconcile.call(manager)
      expect(still_short['stock_discrepancies'].length).to eq(1)
      expect(level(branch, product).count_on_hand).to eq(1)

      branch.stock_location.restock(product.default_variant, 1)
      done = reconcile.call(manager)
      expect(done['stock_discrepancies']).to eq([])
      reconcile.call(manager)
      expect(level(branch, product)).to have_attributes(count_on_hand: 0, allocated_count: 0)
      expect(Spree::Pos::OutboxEntry.where(aggregate_id: sale.workspace.id, aggregate_type: 'Spree::Pos::Workspace',
                                           event_type: 'order.handed_over').count).to eq(1)
    end

    it 'dispatches from the recovery job once the shelf covers it, and not before' do
      sale, product = short_sale
      Spree::Pos::RecoverReturnOperationJob.perform_now
      expect(level(branch, product).count_on_hand).to eq(1)
      expect(Spree::Pos::AuditEntry.where(subject_id: sale.workspace.id, action: 'order.handover_recovered_short')).to be_empty

      branch.stock_location.restock(product.default_variant, 1)
      Spree::Pos::RecoverReturnOperationJob.perform_now
      expect(level(branch, product)).to have_attributes(count_on_hand: 0, allocated_count: 0)
      expect(Spree::Pos::StockDiscrepancy.find_by!(order_id: sale.workspace.order_id).status).to eq('resolved')
    end

    it 'records no shortfall for an order that is neither paid nor on approved credit' do
      sale, = short_sale
      order = sale.workspace.order
      order.payments.update_all(status: 'void')
      expect { hand_over(sale) }.to raise_error(Spree::Pos::Conflict, /not paid/)
    end
  end

  it 're-checks the window and the branch policy when the goods are received' do
    sale = paid_sale(store, branch, cashier: cashier, price: 10_000, quantity: 2)
    prepared = prepare_return(store, cashier, branch, sale, quantity: 1)
    expect(prepared).to include('status' => 'ready', 'requires_approval' => false)

    sale.workspace.order.update_columns(completed_at: 40.days.ago)
    waiting = receive_return(store, cashier, prepared)
    expect(waiting).to include('status' => 'pending_approval', 'out_of_window' => true, 'revision' => 2)
    expect(operation(prepared).core_return.reload.status).to eq('requested')

    second = prepare_return(store, cashier, branch, sale, quantity: 1)
    branch.update!(return_window_days: nil)
    expect { receive_return(store, cashier, second) }.to raise_error(Spree::Pos::Conflict, /not enabled/)
  end

  it 'returns a line shipped in two fulfillment items as one chunk per item, worth the whole line' do
    product = stocked_product(store, branch, price: 10_000, stock: 5)
    sale = open_sale(store, branch, cashier: cashier, product: product, quantity: 3)
    complete_paid(sale)
    fulfillment = sale.workspace.order.fulfillments.first
    line_item = sale.workspace.order.line_items.first
    split = Spree.fulfillment_fulfill_workflow.call(fulfillment: fulfillment, items: [{ line_item: line_item, quantity: 1 }],
                                                    notify_customer: false)
    expect(split).to be_success
    hand_over(sale)
    expect(Spree::FulfillmentItem.where(line_item_id: line_item.id).count).to eq(2)

    result = return_and_receive(store, cashier, branch, sale, quantity: 3)
    rows = operation(result).reservations.order(:sequence).to_a
    expect(rows.map(&:quantity).sort).to eq([1, 2])
    expect(rows.map(&:fulfillment_item_id).uniq.length).to eq(2)
    expect(result).to include('entitlement_status' => 'posted', 'entitlement_total' => '30000.0')
    expect(level(branch, product).count_on_hand).to eq(5)
  end
end
