# frozen_string_literal: true

require 'json'
require_relative '../../../support/pos_shift_helpers'
require_relative '../../../support/pos_trace_helpers'

# One retail day at one counter on the installed core, across every POS
# feature, then a reconciliation of the source facts: sales against receipts,
# debt, credit notes, refunds, drawer cash, core stock, lots, serials and the
# printed snapshots. Finally every idempotent command of the day is replayed
# with its own key, and nothing moves a second time.
RSpec.describe 'POS full retail day', type: :request do
  include PosShiftHelpers
  include PosTraceHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:caps) { Spree::Pos::Capabilities }
  let(:cashier) { credit_staff(store, branch, PosShiftHelpers::LEAD) }
  let(:manager) { credit_staff(store, branch, PosShiftHelpers::MANAGER + [caps::INVENTORY_MANAGE, caps::INVENTORY_TRACE]) }
  let(:auditor) { credit_staff(store, branch, PosShiftHelpers::MANAGER) }

  def method_id(kind)
    method = Spree::Pos::PaymentMethodResolver.new(store: store).available.find { |row| row.kind == kind }
    method.prefixed_id || "posmethod-#{kind}"
  end

  def prepare_tender(sale, kind, amount)
    Spree::Pos::Tenders::Prepare.call(**editing_args(sale), payment_method_id: method_id(kind), amount: amount.to_s)
    Spree::Pos::TenderAttempt.where(workspace: sale.workspace).order(:id).last
  end

  def pay_cash(sale, amount, handed: amount)
    attempt = prepare_tender(sale, 'cash', amount)
    Spree::Pos::Tenders::Confirm.call(**editing_args(sale), attempt_id: attempt.prefixed_id, evidence_kind: 'cash_count',
                                                            handed_amount: handed.to_s)
  end

  def add(sale, product, **params)
    workspace = sale.workspace.reload
    Spree::Pos::Workspaces::ManageLineItem.add(workspace: workspace, staff: sale.cashier, revision: workspace.revision,
                                               lease_generation: workspace.lease_generation, editor_id: sale.editor_id,
                                               key: SecureRandom.uuid, variant_id: product.default_variant.prefixed_id, **params)
  end

  def complete(sale, **params)
    Spree::Pos::Workspaces::Complete.call(**editing_args(sale), **params)
  end

  def new_sale(staff = cashier)
    editor_id = SecureRandom.uuid
    register = Spree::Pos::Shift.for_store(store).open_now.find_by!(branch_id: branch.id, owner_id: staff.id).register
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: staff, register_id: register.prefixed_id,
                                                  key: SecureRandom.uuid, editor_id: editor_id)
    PosCreditHelpers::Sale.new(workspace: Spree::Pos::Workspace.find_by_prefix_id!(created['id']), cashier: staff,
                               editor_id: editor_id, product: nil)
  end

  def tracked_return(sale, line, quantity, **detail)
    row = { 'sale_line_id' => line.prefixed_id, 'quantity' => quantity, 'condition' => 'resellable' }
    Spree::Pos::Returns::Prepare.call(
      store: store, staff: cashier, key: SecureRandom.uuid, branch_id: branch.prefixed_id, order_id: sale.workspace.order.prefixed_id,
      reason: 'Khách trả', lines: [row.merge(detail.stringify_keys)]
    )
  end

  def lines_of(sale)
    Spree::Pos::SaleLine.where(workspace_id: sale.workspace.id).order(:id).to_a
  end

  def on_shelf(product)
    branch.stock_location.stock_level(product.default_variant).reload.count_on_hand
  end

  def ledger
    [Spree::Order.count, Spree::Payment.count, Spree::Payment.sum(:amount), Spree::Refund.count, Spree::StockMovement.count,
     Spree::Pos::ReceivedFunds.count, Spree::Pos::FundsAllocation.count, Spree::Pos::CashMovement.count,
     Spree::Pos::CashMovement.sum(:amount), Spree::Pos::ReceivableEntry.count, Spree::Pos::RefundRequest.count,
     Spree::Pos::ReturnOperation.count, Spree::Pos::TraceAllocation.count, Spree::Pos::TraceReturn.count,
     Spree::Pos::ReceiptSnapshot.count, Spree::Pos::CashReconciliation.count, Spree::Pos::ShiftClosure.count,
     Spree::Pos::CommandReceipt.count, Spree::Pos::AuditEntry.count, Spree::Pos::OutboxEntry.count,
     Spree::StockLevel.where(stock_location_id: branch.stock_location_id).order(:id).pluck(:count_on_hand, :allocated_count),
     Spree::Pos::InventoryLot.order(:id).pluck(:on_hand, :quarantined_quantity), Spree::Pos::SerialUnit.order(:id).pluck(:status)]
  end

  it 'reconciles a whole day of sales, debt, returns, refunds, cash and traced stock, and replays without effects' do
    commands = []
    allow(Spree::Pos::CommandExecutor).to receive(:call).and_wrap_original do |original, **args, &block|
      result = original.call(**args, &block)
      commands << [args, block, JSON.parse(result.to_json)]
      result
    end

    plain = stocked_product(store, branch, price: 100_000, stock: 10)
    side = stocked_product(store, branch, price: 50_000, stock: 10)
    phone = stocked_product(store, branch, price: 2_000_000, stock: 1)
    track_variant!(store, phone.default_variant, 'serial')
    enroll_serials!(branch, phone.default_variant, %w[IMEI-1 IMEI-2 IMEI-3], opened_by: manager)
    milk = stocked_product(store, branch, price: 30_000, stock: 1)
    track_variant!(store, milk.default_variant, 'lot')
    early, late = enroll_lots!(branch, milk.default_variant, [['L1', Date.current + 10, 5], ['L2', Date.current + 40, 5]],
                               opened_by: manager)
    profile = credit_customer(store, manager)
    configure_credit(store, manager, branch, profile, limit: 5_000_000)

    shift = open_shift(store, branch, cashier, float: 200_000)

    # Three customers at once: A waits on a bank transfer, B pays cash, C is still scanning.
    a = new_sale
    add(a, plain, quantity: 1)
    bank = prepare_tender(a, 'bank_manual', 100_000)
    c = new_sale
    add(c, phone, quantity: 1, serial_codes: ['IMEI-1'])
    b = new_sale
    add(b, side, quantity: 2)
    pay_cash(b, 100_000, handed: 200_000)
    complete(b)
    hand_over(b)
    expect(bank.reload.status).to eq('prepared')
    expect(a.workspace.reload.operational_status).to eq('editing')
    add(c, milk, quantity: 6)
    pay_cash(c, 2_180_000)
    complete(c)
    hand_over(c)

    # Credit sale with a manager approval, then a collection.
    d = new_sale
    add(d, plain, quantity: 2)
    assign(d, profile)
    pay_cash(d, 50_000)
    approval = approve_credit(d, manager, 150_000)
    complete(d, credit_approval_id: approval['approval_id'])
    hand_over(d)
    account = Spree::Pos::CreditAccount.find_by!(customer_profile: profile)
    Spree::Pos::Collections::Receive.call(
      store: store, staff: cashier, key: SecureRandom.uuid, branch_id: branch.prefixed_id, credit_account_id: account.prefixed_id,
      kind: 'cash', amount: '100000', allocations: [{ 'order_id' => d.workspace.order.prefixed_id, 'amount' => '100000' }]
    )
    expect(receivable_balance(d.workspace.order)).to eq(BigDecimal('50000'))

    # Partial return of the credit sale: the remaining debt is credited first, the rest is refunded in cash.
    d_return = return_and_receive(store, cashier, branch, d, quantity: 1)
    expect(d_return).to include('entitlement_total' => '100000.0', 'credit_note_amount' => '50000.0', 'refund_entitlement' => '50000.0')
    expect(receivable_balance(d.workspace.order)).to eq(0)
    d_refund = request_refund(store, cashier, d_return, amount: 50_000)
    approve_refund(store, manager, d_refund)
    confirm_refund(store, cashier, d_refund)

    # Exchange: B brings one item back and takes another product; two separate legs.
    b_return = return_and_receive(store, cashier, branch, b, quantity: 1)
    b_refund = request_refund(store, cashier, b_return, amount: 50_000)
    approve_refund(store, manager, b_refund)
    confirm_refund(store, cashier, b_refund)
    exchange = Spree::Pos::Exchanges::Execute.call(store: store, staff: cashier, key: SecureRandom.uuid, return_id: b_return['id'],
                                                   editor_id: (editor = SecureRandom.uuid), register_id: shift.register.prefixed_id)
    replacement = PosCreditHelpers::Sale.new(workspace: Spree::Pos::Workspace.find_by_prefix_id!(exchange['replacement_workspace_id']),
                                             cashier: cashier, editor_id: editor, product: nil)
    add(replacement, plain, quantity: 1)
    pay_cash(replacement, 100_000)
    complete(replacement)
    hand_over(replacement)

    # Partial return of traced goods back to the lot they came from.
    milk_line = lines_of(c).find { |line| line.variant_id == milk.default_variant.id }
    c_return = receive_return(store, cashier, tracked_return(c, milk_line, 2, lot_code: 'L1'))
    expect(c_return['entitlement_total']).to eq('60000.0')

    # A's customer never paid: the transfer is canceled and the draft dropped, nothing recorded.
    Spree::Pos::Tenders::Cancel.call(**editing_args(a), attempt_id: bank.prefixed_id)
    workspace = a.workspace.reload
    Spree::Pos::Workspaces::ChangeStatus.call(workspace: workspace, staff: cashier, status: 'canceled', revision: workspace.revision,
                                              lease_generation: workspace.lease_generation, key: SecureRandom.uuid, editor_id: a.editor_id)

    # Close: 30k late cash went into the drawer unrecorded, so the count is over.
    # float 200k + B 100k + C 2180k + D 50k + collection 100k + replacement 100k - refunds 100k
    expect(expected_cash(shift)).to eq(BigDecimal('2630000'))
    count_shift(shift, cashier, 2_660_000, reason: 'Khách gửi tiền lẻ chưa ghi')
    approve_close(shift, manager)
    closure = close_shift(shift, cashier)
    expect(closure).to include('expected' => '2630000.0', 'counted' => '2660000.0', 'variance' => '30000.0', 'approver_id' => manager.prefixed_id)
    held = held_cash(store, branch, shift.reload, manager, 30_000, note: 'Tiền khách gửi, đã nằm trong két khi đếm')
    reconcile(store, branch, auditor, outcome: 'safe', funds_id: held.prefixed_id, custody_reference: 'KET-01')
    closure_row = Spree::Pos::ShiftClosure.find_by_prefix_id!(closure['id'])
    expect(closure_row.reconciled_amount).to eq(closure_row.variance)

    # Source facts reconcile.
    sales = [b, c, d, replacement].map { |sale| sale.workspace.reload }
    expect(sales.map(&:operational_status).uniq).to eq(['completed'])
    sales.each do |sale|
      order = sale.order.reload
      own = Spree::Pos::FundsAllocation.where(workspace_id: sale.id, collection_id: nil, status: 'active').sum(:amount)
      debit = Spree::Pos::ReceivableEntry.where(order_id: order.id, kind: 'debit').sum(:amount)
      expect(own + debit).to eq(order.total)
      receipt = Spree::Pos::ReceiptSnapshot.find_by!(source_type: 'sale', source_id: sale.id)
      expect(BigDecimal(receipt.payload.dig('totals', 'total'))).to eq(order.total)
    end
    expect(sales.sum { |sale| sale.order.total }).to eq(BigDecimal('100000') + BigDecimal('2180000') + BigDecimal('200000') + BigDecimal('100000'))
    expect(Spree::Pos::ReceivableEntry.balance_sum(Spree::Pos::ReceivableEntry.all)).to eq(0)
    expect(Spree::Pos::ReturnOperation.sum(:credit_note_amount)).to eq(BigDecimal('50000'))
    expect(Spree::Refund.sum(:amount)).to eq(BigDecimal('100000'))
    expect(Spree::Pos::RefundRequest.pluck(:status)).to eq(%w[confirmed confirmed])
    expect(Spree::Pos::ReturnOperation.where(id: operation(c_return).id).pick(:refund_entitlement)).to eq(BigDecimal('60000'))
    drawer = Spree::Pos::CashMovement.where(shift_id: shift.id)
    expect(shift.opening_float + drawer.sum(:amount)).to eq(BigDecimal('2630000'))
    expect(Spree::Pos::ReceivedFunds.where(kind: 'cash', custody: 'drawer').sum(:received_net) -
           Spree::Pos::RefundRequest.where(status: 'confirmed', method: 'cash').sum(:amount)).to eq(drawer.sum(:amount))
    expect(Spree::Pos::TenderAttempt.unresolved).to be_empty

    expect([on_shelf(plain), on_shelf(side), on_shelf(phone), on_shelf(milk)]).to eq([8, 9, 2, 6])
    expect([early.reload.on_hand, late.reload.on_hand]).to eq([2, 4])
    expect(Spree::Pos::SerialUnit.order(:serial).pluck(:serial, :status)).to eq([%w[IMEI-1 sold], %w[IMEI-2 in_stock], %w[IMEI-3 in_stock]])
    expect([phone, milk]).to all(satisfy { |product| Spree::Pos::StockIntegration.blocked_reason(branch, product.default_variant).nil? })
    expect(Spree::StockLevel.where(stock_location_id: branch.stock_location_id).sum(:allocated_count)).to eq(0)
    expect(Spree::Pos::ReceiptSnapshot.group(:source_type).count).to include('sale' => 4, 'return' => 3, 'refund' => 2, 'shift_closure' => 1)

    # Replaying every command with its own key, after the day is closed,
    # returns the first answer, runs nothing again and moves nothing. Opening
    # a draft is replayed too although its shift is closed: the actor still
    # works at the branch.
    expect(commands.length).to be > 30
    before = ledger
    commands.dup.each do |args, block, first|
      replayed = Spree::Pos::CommandExecutor.call(**args, &block)
      expect(JSON.parse(replayed.to_json)).to eq(first), "replay of #{args[:payload]['command']} answered differently"
    end
    expect(commands.map { |args, _block, _first| args[:payload]['command'] }).
      to include('create', 'tender.confirm', 'workspace.complete', 'order.handover', 'credit.approve', 'collection.receive',
                 'return.receive', 'refund.confirm', 'exchange.execute', 'shift.close', 'cash.reconcile')

    # Once the cashier no longer works at the branch, the draft is not handed out again.
    Spree::Pos::StaffMembership.find_by!(staff: cashier, branch: branch).update!(status: 'disabled')
    create_args, create_block, = commands.find { |args, _block, _first| args[:payload]['command'] == 'create' }
    expect { Spree::Pos::CommandExecutor.call(**create_args, &create_block) }.to raise_error(CanCan::AccessDenied)
    expect(ledger).to eq(before)
  end
end
