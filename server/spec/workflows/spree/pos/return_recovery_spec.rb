# frozen_string_literal: true

require_relative '../../../support/pos_return_helpers'

# The return recovery sweep: abandoned returns expire through the cancel
# workflow, stuck items are raised once for attention, and one failing item
# never stops the rest of the sweep.
RSpec.describe 'POS return recovery', type: :request do
  include PosReturnHelpers
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosReturnHelpers::RETURNS) }

  def attention(event_type)
    Spree::Pos::OutboxEntry.where(event_type: event_type)
  end

  it 'cancels returns nobody received within the TTL and frees their units' do
    sale = paid_sale(store, branch, cashier: cashier, price: 10_000, quantity: 2)
    abandoned = prepare_return(store, cashier, branch, sale, quantity: 2)

    travel(Spree::Pos::ReturnOperation::TTL + 1.minute) { Spree::Pos::RecoverReturnOperationJob.perform_now }

    expect(operation(abandoned).reload).to have_attributes(status: 'canceled', entitlement_status: 'canceled')
    expect(operation(abandoned).core_return.reload.status).to eq('canceled')
    expect(Spree::Pos::AuditEntry.where(action: 'return.expire')).to exist
    expect(prepare_return(store, cashier, branch, sale, quantity: 2)['status']).to eq('ready')
  end

  it 'raises stale and waiting returns once each' do
    sale = paid_sale(store, branch, cashier: cashier, price: '0.4', quantity: 5)
    prepare_return(store, cashier, branch, sale, quantity: 1)
    waiting = prepare_return(store, cashier, branch, sale, quantity: 1)
    receive_return(store, cashier, waiting)
    expect(operation(waiting).entitlement_status).to eq('awaiting_predecessor')

    travel(20.minutes) do
      2.times { Spree::Pos::RecoverReturnOperationJob.perform_now }
    end
    expect(attention('return.stale').count).to eq(1)
    expect(attention('return.awaiting_predecessor').count).to eq(1)
  end

  it 'keeps sweeping after one item fails and raises that item for attention' do
    sale = paid_sale(store, branch, cashier: cashier, price: 10_000, quantity: 4)
    first = prepare_return(store, cashier, branch, sale, quantity: 1)
    second = prepare_return(store, cashier, branch, sale, quantity: 1)
    failing = operation(first).id
    allow(Spree::Pos::Returns::Cancel).to receive(:expire!).and_wrap_original do |original, op|
      raise ActiveRecord::StatementTimeout, 'canceled statement' if op.id == failing

      original.call(op)
    end

    travel(Spree::Pos::ReturnOperation::TTL + 1.minute) { Spree::Pos::RecoverReturnOperationJob.perform_now }

    expect(operation(first).reload.status).to eq('pending_approval').or eq('ready')
    expect(attention('recovery.failed').where(aggregate_id: failing)).to exist
    # The later return depends on the failing one and is re-priced only if it
    # can be; it is still canceled on its own.
    expect(operation(second).reload.status).to eq('canceled')
  end

  it 'records each attention item once even when called twice' do
    sale = paid_sale(store, branch, cashier: cashier, price: 10_000)
    workspace = sale.workspace
    2.times { Spree::Pos::OutboxEntry.record_once!(store_id: store.id, event_type: 'x.once', aggregate: workspace) }
    expect(attention('x.once').count).to eq(1)
  end
end
