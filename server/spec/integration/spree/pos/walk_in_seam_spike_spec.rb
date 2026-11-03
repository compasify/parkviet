# frozen_string_literal: true

RSpec.describe 'POS walk-in seam spike' do
  it 'probes downstream staff draft placement with only the email predicate stubbed' do
    order = create(:order_with_totals, customer: nil, email: nil, bill_address: nil)
    order.recalculate_totals!

    # Experiment only: no production policy or trust boundary is established by
    # this stub. payment_pending is used to avoid a real payment in the spike.
    allow(order).to receive(:require_email).and_return(false)
    result = Spree.order_complete_workflow.call(order: order, payment_pending: true, notify_customer: false)

    expect(result).to be_success
    expect(order.reload).to be_placed
    expect(order.email).to be_nil
    expect(order.customer).to be_nil
    expect(order.payments).to be_empty
  end
end
