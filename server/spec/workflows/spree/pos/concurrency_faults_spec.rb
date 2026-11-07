# frozen_string_literal: true

require_relative '../../../support/pos_race_helpers'
require_relative '../../../support/pos_shift_helpers'
require_relative '../../../support/pos_trace_helpers'

# Crashes injected at each write boundary of the money and stock commands,
# on committed rows: the crashed command leaves nothing behind, the retry
# with the same key does the work exactly once, a second retry replays it,
# recovery sweeps only raise attention, and commands arriving out of order
# are refused instead of guessed.
module PosFaultInjection
  class Crash < StandardError; end
end

RSpec.describe 'POS fault injection and replay', type: :request do
  include PosShiftHelpers
  include PosTraceHelpers
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosShiftHelpers::LEAD) }
  let(:manager) { credit_staff(store, branch, PosShiftHelpers::MANAGER) }

  # Raises once, at the first call the matcher accepts: after the original
  # wrote its row (`after: true`, a crash before commit) or instead of it.
  def crash_once(target, method, after: true, any_instance: false, &matcher)
    fired = false
    stub = any_instance ? allow_any_instance_of(target) : allow(target)
    stub.to receive(method).and_wrap_original do |original, *args, **kwargs, &block|
      hit = !fired && (matcher.nil? || matcher.call(*args, **kwargs))
      fired ||= hit
      raise PosFaultInjection::Crash, "#{target}.#{method}" if hit && !after

      result = original.call(*args, **kwargs, &block)
      raise PosFaultInjection::Crash, "#{target}.#{method}" if hit

      result
    end
  end

  def audited(action)
    ->(*_args, **kwargs) { kwargs[:action] == action }
  end

  def outbox(event)
    ->(*_args, **kwargs) { kwargs[:event_type] == event }
  end

  def method_id(kind)
    method = Spree::Pos::PaymentMethodResolver.new(store: store).available.find { |row| row.kind == kind }
    method.prefixed_id || "posmethod-#{kind}"
  end

  def money(workspace)
    funds = Spree::Pos::ReceivedFunds.where(workspace_id: workspace.id)
    [funds.count, Spree::Pos::FundsAllocation.where(workspace_id: workspace.id).count, workspace.order.payments.reload.count,
     Spree::Pos::CashMovement.where(received_funds_id: funds.select(:id)).sum(:amount),
     Spree::Pos::TenderAttempt.where(workspace_id: workspace.id).count]
  end

  # Runs the command, expects the injected crash, then retries twice with the same key.
  def crash_then_retry(&command)
    key = SecureRandom.uuid
    expect { command.call(key) }.to raise_error(PosFaultInjection::Crash)
    first = command.call(key)
    expect(command.call(key)).to eq(first)
    first
  end

  describe 'on committed rows' do
    include_context 'with committed POS rows'

    it 'takes a cash tender once whatever write of the receipt crashes' do
      boundaries = {
        intent: -> { crash_once(Spree::Pos::TenderAttempt, :create!) },
        receipt: -> { crash_once(Spree::Pos::ReceivedFunds, :create!) },
        evidence: -> { crash_once(Spree::Pos::ReceiptEvidence, :create!) },
        payment: -> { crash_once(Spree::Payment, :complete!, any_instance: true) },
        allocation: -> { crash_once(Spree::Pos::FundsAllocation, :create!) },
        drawer: -> { crash_once(Spree::Pos::CashMovement, :create!) },
        audit: -> { crash_once(Spree::Pos::AuditEntry, :record!, &audited('tender.confirm')) },
        outbox: -> { crash_once(Spree::Pos::OutboxEntry, :record!, &outbox('tender.confirmed')) }
      }
      product = stocked_product(store, branch, price: 40_000, stock: 50)
      boundaries.each do |name, arm|
        sale = open_sale(store, branch, cashier: cashier, product: product)
        workspace = sale.workspace.reload
        if name == :intent
          arm.call
          args = editing_args(sale)
          # Resolved once: the store's cash method may be persisted by the first prepare.
          cash = method_id('cash')
          crash_then_retry do |key|
            Spree::Pos::Tenders::Prepare.call(**args, key: key, payment_method_id: cash, amount: '40000')
          end
          expect(money(workspace)).to eq([0, 0, 0, 0, 1]), "after a crash at #{name}"
          next
        end

        Spree::Pos::Tenders::Prepare.call(**editing_args(sale), payment_method_id: method_id('cash'), amount: '40000')
        attempt = Spree::Pos::TenderAttempt.where(workspace_id: workspace.id).sole
        arm.call
        args = editing_args(sale)
        key = SecureRandom.uuid
        expect do
          Spree::Pos::Tenders::Confirm.call(**args, key: key, attempt_id: attempt.prefixed_id, evidence_kind: 'cash_count',
                                                    handed_amount: '50000')
        end.to raise_error(PosFaultInjection::Crash)
        expect(money(workspace.reload)).to eq([0, 0, 0, 0, 1]), "a crash at #{name} left money behind"
        expect(attempt.reload.status).to eq('prepared')
        first = Spree::Pos::Tenders::Confirm.call(**args, key: key, attempt_id: attempt.prefixed_id, evidence_kind: 'cash_count',
                                                          handed_amount: '50000')
        again = Spree::Pos::Tenders::Confirm.call(**args, key: key, attempt_id: attempt.prefixed_id, evidence_kind: 'cash_count',
                                                          handed_amount: '50000')
        expect(again).to eq(first)
        expect(money(workspace.reload)).to eq([1, 1, 1, BigDecimal('40000'), 1]), "after a crash at #{name}"
        expect(attempt.reload.status).to eq('confirmed')
      end
    end

    it 'places an order once after a crash at placement or at the outbox, and the sweep only raises attention' do
      product = stocked_product(store, branch, price: 30_000, stock: 5)
      level = branch.stock_location.stock_level(product.default_variant)
      [[Spree::Pos::Inventory::AllocateTraceability, :commit!, nil], [Spree::Pos::OutboxEntry, :record!, outbox('workspace.completed')]].
        each do |target, method, matcher|
        sale = open_sale(store, branch, cashier: cashier, product: product)
        take_tender(sale, 'cash', 30_000)
        workspace = sale.workspace.reload
        crash_once(target, method, &matcher)
        key = SecureRandom.uuid
        args = editing_args(sale).merge(key: key)
        expect { Spree::Pos::Workspaces::Complete.call(**args) }.to raise_error(PosFaultInjection::Crash)
        expect(workspace.order.reload.completed?).to be(false)
        expect(workspace.reload.operational_status).to eq('editing')
        expect(Spree::Pos::ReceiptSnapshot.where(source_type: 'sale', source_id: workspace.id)).to be_empty

        # The receipt was taken before placement: the sweep surfaces it once and never places the order itself.
        workspace.update_columns(updated_at: 20.minutes.ago)
        2.times { Spree::Pos::RecoverSettlementJob.perform_now }
        expect(Spree::Pos::OutboxEntry.where(event_type: 'workspace.completion_pending', aggregate_id: workspace.id).count).to eq(1)
        expect(workspace.order.reload.completed?).to be(false)

        first = Spree::Pos::Workspaces::Complete.call(**args)
        expect(Spree::Pos::Workspaces::Complete.call(**args)).to eq(first)
        expect(workspace.order.reload.completed?).to be(true)
        expect(workspace.order.payments.where(status: 'completed').count).to eq(1)
        expect(Spree::Pos::ReceiptSnapshot.where(source_type: 'sale', source_id: workspace.id).count).to eq(1)
        expect(Spree::Pos::OutboxEntry.where(event_type: 'workspace.completed', aggregate_id: workspace.id).count).to eq(1)
      end
      expect(level.reload).to have_attributes(count_on_hand: 5, allocated_count: 2)
    end

    it 'moves stock, serials and lots once after a crash during handover or a return' do
      phone = stocked_product(store, branch, price: 900_000, stock: 1)
      track_variant!(store, phone.default_variant, 'serial')
      enroll_serials!(branch, phone.default_variant, %w[SN-1 SN-2], opened_by: manager)
      sale = open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 10_000))
      workspace = sale.workspace.reload
      Spree::Pos::Workspaces::ManageLineItem.add(workspace: workspace, staff: cashier, revision: workspace.revision, key: SecureRandom.uuid,
                                                 lease_generation: workspace.lease_generation, editor_id: sale.editor_id,
                                                 variant_id: phone.default_variant.prefixed_id, quantity: 1, serial_codes: ['SN-1'])
      complete_paid(sale)
      shelf = -> { branch.stock_location.stock_level(phone.default_variant).reload.attributes.slice('count_on_hand', 'allocated_count') }
      movements = -> { Spree::StockMovement.where(stock_item_id: branch.stock_location.stock_level(phone.default_variant).id).count }
      before = [shelf.call, movements.call]

      crash_once(Spree::Pos::AuditEntry, :record!) { |**kwargs| kwargs[:action].to_s.start_with?('order.handover') }
      key = SecureRandom.uuid
      expect { hand_over(sale, key: key) }.to raise_error(PosFaultInjection::Crash)
      expect([shelf.call, movements.call]).to eq(before)
      sold = Spree::Pos::TraceAllocation.joins(:serial_unit).where(spree_pos_serial_units: { serial: 'SN-1' })
      expect(sold.pluck(:status)).to eq(['committed'])
      hand_over(sale, key: key)
      hand_over(sale, key: key)
      hand_over(sale)
      expect(shelf.call).to eq('count_on_hand' => 1, 'allocated_count' => 0)
      expect(movements.call).to eq(before.last + 1)
      expect(Spree::Pos::SerialUnit.find_by!(serial: 'SN-1').status).to eq('sold')
      expect(sold.pluck(:status)).to eq(['consumed'])

      line = Spree::Pos::SaleLine.find_by!(workspace_id: workspace.id, variant_id: phone.default_variant.id)
      prepared = Spree::Pos::Returns::Prepare.call(
        store: store, staff: cashier, key: SecureRandom.uuid, branch_id: branch.prefixed_id, order_id: workspace.order.prefixed_id,
        reason: 'Lỗi máy', lines: [{ 'sale_line_id' => line.prefixed_id, 'quantity' => 1, 'condition' => 'resellable', 'serial_codes' => ['SN-1'] }]
      )
      crash_once(Spree::Pos::OutboxEntry, :record!) { |**kwargs| kwargs[:event_type].to_s.start_with?('return.') }
      crash_then_retry { |retry_key| receive_return(store, cashier, prepared, key: retry_key) }
      expect(shelf.call).to eq('count_on_hand' => 2, 'allocated_count' => 0)
      expect(Spree::Pos::SerialUnit.find_by!(serial: 'SN-1').status).to eq('in_stock')
      expect(Spree::Pos::TraceReturn.where(return_operation: operation(prepared)).count).to eq(1)
      expect(Spree::Pos::StockIntegration.blocked_reason(branch, phone.default_variant)).to be_nil
    end

    it 'pays a refund once after a crash at the payout and closes a shift once after a crash at the cutoff' do
      sale = paid_sale(store, branch, cashier: cashier, price: 60_000, quantity: 2)
      received = return_and_receive(store, cashier, branch, sale, quantity: 2)
      boundaries = [[Spree::Pos::CashMovement, :create!, nil], [Spree::Pos::OutboxEntry, :record!, outbox('refund.confirmed')]]
      boundaries.each do |target, method, matcher|
        refund = request_refund(store, cashier, received, amount: 60_000)
        approve_refund(store, manager, refund)
        crash_once(target, method, &matcher)
        crash_then_retry { |key| confirm_refund(store, cashier, refund, key: key) }
        request = Spree::Pos::RefundRequest.find_by_prefix_id!(refund['id'])
        expect(request.status).to eq('confirmed')
        expect(Spree::Pos::CashMovement.where(refund_request: request).sum(:amount)).to eq(BigDecimal('-60000'))
      end
      expect(Spree::Refund.where(payment_id: sale.workspace.order.payments.select(:id)).sum(:amount)).to eq(BigDecimal('120000'))

      shift = sale.workspace.reload.shift
      count_shift(shift, cashier, expected_cash(shift))
      crash_once(Spree::Pos::ShiftClosure, :create!)
      closure = crash_then_retry { |key| close_shift(shift, cashier, key: key) }
      expect(Spree::Pos::ShiftClosure.where(shift_id: shift.id).count).to eq(1)
      expect(closure['variance']).to eq('0.0')
      expect(shift.reload.status).to eq('closed')
    end

    it 'refuses commands that arrive out of order instead of guessing' do
      sale = open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 20_000))
      reason = lambda do |&command|
        command.call
        raise 'expected a refusal'
      rescue Spree::Pos::Conflict => e
        e.reason || e.message
      end

      # Handover before placement, completion before the money.
      expect { hand_over(sale) }.to raise_error(Spree::Pos::Conflict)
      expect { Spree::Pos::Workspaces::Complete.call(**editing_args(sale)) }.to raise_error(Spree::Pos::Conflict, /cover/)
      # A confirmation that arrives after its tender was canceled.
      Spree::Pos::Tenders::Prepare.call(**editing_args(sale), payment_method_id: method_id('cash'), amount: '20000')
      attempt = Spree::Pos::TenderAttempt.where(workspace: sale.workspace).sole
      Spree::Pos::Tenders::Cancel.call(**editing_args(sale), attempt_id: attempt.prefixed_id)
      expect(reason.call do
        Spree::Pos::Tenders::Confirm.call(**editing_args(sale), attempt_id: attempt.prefixed_id, evidence_kind: 'cash_count',
                                                                handed_amount: '20000')
      end).to match(/not prepared/)
      # A confirmation built against an older revision.
      stale = editing_args(sale)
      take_tender(sale, 'cash', 20_000)
      expect(reason.call { Spree::Pos::Workspaces::Complete.call(**stale) }).to match(/revision|stale/i)
      expect(Spree::Pos::ReceivedFunds.where(workspace_id: sale.workspace.id).count).to eq(1)

      complete_paid_args = editing_args(sale)
      Spree::Pos::Workspaces::Complete.call(**complete_paid_args)
      hand_over(sale)
      # A refund confirmed before anyone approved it, then a receive after a cancel.
      prepared = prepare_return(store, cashier, branch, sale, quantity: 1)
      Spree::Pos::Returns::Cancel.call(store: store, staff: cashier, key: SecureRandom.uuid, return_id: prepared['id'], reason: 'Nhầm')
      expect { receive_return(store, cashier, prepared) }.to raise_error(Spree::Pos::Conflict)
      received = return_and_receive(store, cashier, branch, sale, quantity: 1)
      refund = request_refund(store, cashier, received, amount: 20_000)
      expect { confirm_refund(store, cashier, refund) }.to raise_error(Spree::Pos::Conflict, /needs an approval/)
      expect(Spree::Refund.count).to eq(0)
    end
  end

  describe 'on two connections' do
    include_context 'with committed POS race rows'

    let(:store) { Spree::Store.default }

    it 'places and hands over an order once when two counters complete and hand it over at the same moment' do
      sale = open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 15_000, stock: 3))
      take_tender(sale, 'cash', 15_000)
      workspace = sale.workspace.reload
      args = editing_args(sale)
      outcomes = race(workspace) do
        Spree::Pos::Workspaces::Complete.call(**args, workspace: Spree::Pos::Workspace.find(workspace.id), key: SecureRandom.uuid)
      end
      expect(outcomes.map(&:first)).to contain_exactly(:success, :conflict)
      expect(workspace.order.reload.completed?).to be(true)

      outcomes = race(workspace.reload) do
        Spree::Pos::Orders::Handover.call(workspace: Spree::Pos::Workspace.find(workspace.id), staff: cashier, key: SecureRandom.uuid)
      end
      expect(outcomes.map(&:first).count(:success)).to be >= 1
      expect(outcomes.map(&:first) - %i[success conflict]).to be_empty
      level = branch.stock_location.stock_level(sale.product.default_variant).reload
      expect(level).to have_attributes(count_on_hand: 2, allocated_count: 0)
      expect(Spree::Pos::ReceivedFunds.where(workspace_id: workspace.id).count).to eq(1)
    end
  end
end
