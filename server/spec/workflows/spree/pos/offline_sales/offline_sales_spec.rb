# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_kitchen_helpers'

# Cash sales a counter made offline, replayed on the server: priced again,
# completed once whatever the replays, or kept for review; then finished by
# the cashier through the ordinary approval of a kept price, or rejected.
RSpec.describe 'Spree::Pos::OfflineSales' do
  include PosKitchenHelpers

  let(:store) { menu_store }
  let(:branch) { kitchen_branch(store, trigger: 'on_complete') }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:manager) { credit_staff(store, branch, PosCreditHelpers::MANAGER) }
  let(:register) { open_drawer(store, branch, cashier) }
  let(:shift) { Spree::Pos::Shift.find_by!(register_id: register.id, status: 'open') }
  let(:item) { menu_item!(store, branch, name: 'Cà phê sữa', price: 30_000) }
  let(:variant) { item.product.default_variant }

  before { kitchen_station!(branch, name: 'Bar', default: true) }

  def sale_params(price: '30000', quantity: 2, handed: '100000', sold_at: 5.minutes.ago, client_now: Time.current, offline_id: SecureRandom.uuid)
    total = (BigDecimal(price) * quantity).to_s('F')
    { offline_id: offline_id, provisional_number: "OFF-#{register.code}-1", register_id: register.prefixed_id,
      shift_id: shift.prefixed_id, client_sold_at: sold_at.iso8601, client_now: client_now.iso8601, total: total,
      handed_amount: handed, lines: [{ variant_id: variant.prefixed_id, quantity: quantity, unit_price: price, name: 'Cà phê sữa' }] }
  end

  def ingest(params, staff: cashier)
    Spree::Pos::OfflineSales::Ingest.call(store: store, staff: staff, key: "offline:#{params[:offline_id]}", params: params)
  end

  def cash_in(shift_record)
    Spree::Pos::CashMovement.where(shift_id: shift_record.id, kind: 'receipt').sum(:amount)
  end

  it 'completes a cash sale at server prices on its shift, with no late kitchen ticket' do
    result = ingest(sale_params)

    expect(result).to include(status: 'completed', collected_total: '60000.0', review_reason: nil, clock_check: false)
    sale = Spree::Pos::OfflineSale.find_by_prefix_id!(result[:id])
    workspace = sale.workspace
    expect(workspace.operational_status).to eq('completed')
    expect(workspace.shift).to eq(shift)
    expect(workspace.order.total).to eq(60_000)
    funds = Spree::Pos::ReceivedFunds.find_by!(workspace_id: workspace.id)
    expect([funds.handed_amount, funds.applied_amount, funds.change_amount]).to eq([100_000, 60_000, 40_000])
    expect(cash_in(shift)).to eq(60_000)
    expect(Spree::Pos::KitchenTicket.where(workspace_id: workspace.id)).to be_empty
    expect(Spree::Pos::AuditEntry.where(action: 'offline_sale.completed')).to exist
  end

  it 'replays the same sale any number of times as one sale and one receipt of cash' do
    params = sale_params
    first = ingest(params)
    again = ingest(params.merge(client_now: 2.minutes.from_now.iso8601))

    expect(again[:id]).to eq(first[:id])
    expect(Spree::Pos::OfflineSale.count).to eq(1)
    expect(Spree::Pos::Workspace.where(shift_id: shift.id).count).to eq(1)
    expect(Spree::Pos::ReceivedFunds.count).to eq(1)
    expect(cash_in(shift)).to eq(60_000)
  end

  it 'refuses another sale under a key of the same offline id with other lines' do
    params = sale_params
    ingest(params)

    expect { ingest(params.merge(handed_amount: '200000')) }.to raise_error(Spree::Pos::Conflict, /reused/)
    expect { Spree::Pos::OfflineSales::Ingest.call(store: store, staff: cashier, key: 'offline:other', params: sale_params) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('offline_key_mismatch') }
  end

  it 'parks the order for review when the price changed while offline, with the cash noted' do
    variant.set_price('VND', 35_000)
    result = ingest(sale_params)

    expect(result).to include(status: 'needs_review', review_reason: 'price_changed', current_total: '70000.0')
    expect(result[:review_details]).to include('collected_total' => '60000.0', 'current_total' => '70000.0')
    workspace = Spree::Pos::OfflineSale.find_by_prefix_id!(result[:id]).workspace
    expect(workspace.operational_status).to eq('parked')
    expect(workspace.note).to include('60000.0')
    expect(Spree::Pos::ReceivedFunds.where(workspace_id: workspace.id)).to be_empty
    expect(cash_in(shift)).to eq(0)
  end

  it 'keeps a sale of a shift that closed meanwhile for review, without an order' do
    sale = sale_params
    shift.update_columns(status: 'closed', closed_at: Time.current)
    result = ingest(sale)

    expect(result).to include(status: 'needs_review', review_reason: 'shift_closed', workspace_id: nil)
    expect(Spree::Pos::Workspace.where(shift_id: shift.id)).to be_empty
  end

  it 'keeps a sale of an item sold out since for review' do
    Spree::Pos::MenuAvailability.create!(branch: branch, menu_item: item,
                                         sold_out_on: Spree::Pos::BusinessDay.for(branch, Spree::Pos::Workspace.business_now))
    result = ingest(sale_params)

    expect(result).to include(status: 'needs_review', review_reason: 'item_sold_out', workspace_id: nil)
  end

  it 'flags a counter clock far from the server' do
    result = ingest(sale_params(client_now: 30.minutes.ago))

    expect(result).to include(status: 'completed', clock_check: true)
  end

  it 'refuses a sale on someone else\'s shift' do
    other = credit_staff(store, branch, PosCreditHelpers::CASHIER)

    expect { ingest(sale_params, staff: other) }.to raise_error(CanCan::AccessDenied)
  end

  describe 'review' do
    let(:waiting) do
      variant.set_price('VND', 35_000)
      Spree::Pos::OfflineSale.find_by_prefix_id!(ingest(sale_params)[:id])
    end

    def resolve(sale, mode, staff: cashier, **options)
      Spree::Pos::OfflineSales::Resolve.call(store: store, staff: staff, key: SecureRandom.uuid, sale: sale, mode: mode, **options)
    end

    def price_approval(sale)
      workspace = sale.workspace.reload
      Spree::Pos::Approval.create!(store: store, branch: branch, approver: manager, requester: cashier,
                                   action: Spree::Pos::Workspaces::OverridePrice::ACTION,
                                   subject_type: workspace.class.name, subject_id: workspace.id,
                                   revision: workspace.revision.to_s, amount: sale.collected_total, currency: 'VND',
                                   expires_at: 10.minutes.from_now, status: 'active')
    end

    it 'keeps the collected prices with one approval of a price override and completes the sale' do
      expect { resolve(waiting, 'accept_collected') }.to raise_error(Spree::Pos::Conflict) { |error|
        expect(error.reason).to eq('approval_required')
        expect(error.details).to include(action: 'workspace.override_price', amount: '60000.0')
      }

      result = resolve(waiting, 'accept_collected', approval_id: price_approval(waiting).prefixed_id)

      expect(result).to include(status: 'completed', resolution: 'accept_collected')
      workspace = waiting.reload.workspace
      expect(workspace.operational_status).to eq('completed')
      expect(workspace.order.total).to eq(60_000)
      expect(cash_in(shift)).to eq(60_000)
      expect(Spree::Pos::AuditEntry.where(action: 'workspace.price.override')).to exist
    end

    it 'charges today\'s price with the cash now taken' do
      result = resolve(waiting, 'current_price', handed_amount: '100000')

      expect(result).to include(status: 'completed', resolution: 'current_price')
      expect(waiting.reload.workspace.order.total).to eq(70_000)
      expect(cash_in(shift)).to eq(70_000)
    end

    it 'sells other lines on a new order and cancels the parked one' do
      parked = waiting.workspace
      tea = menu_item!(store, branch, name: 'Trà đào', price: 30_000)
      lines = [{ variant_id: tea.product.default_variant.prefixed_id, quantity: 2, unit_price: '30000', name: 'Trà đào' }]
      result = resolve(waiting, 'edited', lines: lines, handed_amount: '60000')

      expect(result).to include(status: 'completed', resolution: 'edited')
      expect(parked.reload.operational_status).to eq('canceled')
      expect(waiting.reload.workspace.order.total).to eq(60_000)
    end

    it 'lets only the cashier who took the cash finish it, once' do
      other = credit_staff(store, branch, PosCreditHelpers::CASHIER)
      expect { resolve(waiting, 'current_price', staff: other, handed_amount: '70000') }.to raise_error(CanCan::AccessDenied)

      resolve(waiting, 'current_price', handed_amount: '70000')
      expect { resolve(waiting, 'current_price', handed_amount: '70000') }.
        to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('offline_sale_settled') }
    end

    it 'finishes a sale of a closed shift on the cashier\'s open shift' do
      params = sale_params
      shift.update_columns(status: 'closed', closed_at: Time.current)
      sale = Spree::Pos::OfflineSale.find_by_prefix_id!(ingest(params)[:id])
      next_shift = Spree::Pos::Shifts::Open.call(store: store, staff: cashier, register: register, opening_float: '0')
      next_shift = Spree::Pos::Shift.find_by!(register_id: register.id, status: 'open') unless next_shift.is_a?(Spree::Pos::Shift)

      resolve(sale, 'current_price')

      expect(sale.reload.workspace.shift).to eq(next_shift)
      expect(cash_in(next_shift)).to eq(60_000)
    end

    it 'is rejected by a manager with a reason, canceling the parked order' do
      expect do
        Spree::Pos::OfflineSales::Reject.call(store: store, staff: cashier, key: SecureRandom.uuid, sale: waiting, reason: 'Nhầm')
      end.to raise_error(CanCan::AccessDenied)

      result = Spree::Pos::OfflineSales::Reject.call(store: store, staff: manager, key: SecureRandom.uuid, sale: waiting, reason: 'Bán thử')

      expect(result).to include(status: 'rejected', resolution: 'rejected', resolution_note: 'Bán thử')
      expect(waiting.reload.workspace.operational_status).to eq('canceled')
      expect(Spree::Pos::AuditEntry.where(action: 'offline_sale.reject')).to exist
    end
  end
end
