# frozen_string_literal: true

require_relative '../../../support/pos_vehicle_helpers'
require_relative '../../../support/pos_race_helpers'

# Two screens pay the same coach visit at the same moment, on two
# connections, with different keys: the visit row lock lets one cash out
# request through and refuses the other, so the driver is paid once.
RSpec.describe 'POS coach commission payout race', type: :integration do
  include PosVehicleHelpers

  include_context 'with committed POS race rows'

  it 'creates one cash out request for two simultaneous payouts of one visit' do
    branch = rest_stop_branch(store)
    cashier = credit_staff(store, branch, PosVehicleHelpers::STOP_CASHIER)
    commission_rule!(store, cashier, branch, per_vehicle_amounts: { 'seat_29' => '100000' }, per_guest_amount: '0')
    complete_in_cash(stop_sale(store, branch, cashier, price: 300_000))
    visit = close_visit(open_visit!(store, cashier, branch), cashier)

    outcomes = race(visit) { |_index| pay_visit(visit, cashier)['status'] }

    expect(outcomes.map(&:first)).to contain_exactly(:success, :conflict)
    expect(Spree::Pos::CashMovementRequest.where(evidence_reference: visit.prefixed_id).count).to eq(1)
    expect(visit.reload).to have_attributes(status: 'paid', payout_method: 'cash')
  end
end
