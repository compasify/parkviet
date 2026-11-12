# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/pos_vehicle_helpers'

# A coach visit's own rules: its plate typed any way is one coach, its
# fields are checked by the model and the database, and the driver's phone
# is shown in full only to people managing visits.
RSpec.describe Spree::Pos::VehicleVisit do
  include PosVehicleHelpers

  let(:store) { Spree::Store.default }
  let(:branch) { rest_stop_branch(store) }
  let(:manager) { credit_staff(store, branch, PosVehicleHelpers::STOP_MANAGER) }
  let(:operator) { credit_staff(store, branch, [PosVehicleHelpers::CAPS::VEHICLE_VISIT_OPERATE]) }

  def savepoint(&)
    Spree::Pos::Record.transaction(requires_new: true, &)
  end

  it 'normalizes plates and validates its fields' do
    expect(described_class.normalize_plate(' 51b-123.45 ')).to eq('51B12345')
    expect(described_class.normalize_plate('--')).to be_nil

    visit = open_visit!(store, operator, branch, plate: '51b 123.45')
    expect(visit).to have_attributes(plate: '51B12345', status: 'open', vehicle_type: 'seat_29', guest_count: 20,
                                     currency: store.default_currency, opened_by_id: operator.id)
    expect(visit.closes_at - visit.arrived_at).to eq(60.minutes)

    visit.vehicle_type = 'seat_99'
    visit.guest_count = 1000
    expect(visit).not_to be_valid
    expect(visit.errors.attribute_names).to include(:vehicle_type, :guest_count)
    # Paid without a payout is refused by the database too.
    expect { savepoint { visit.reload.update_columns(status: 'paid') } }.to raise_error(ActiveRecord::StatementInvalid, /chk_pos_vehicle_visits/)
  end

  it "shows the driver's phone in full only to people managing visits" do
    visit = open_visit!(store, operator, branch, driver_phone: '0909123456')

    expect(Spree::Pos::VehicleVisits::Guard.to_pos(visit, operator)[:driver_phone]).to eq('••••••3456')
    expect(Spree::Pos::VehicleVisits::Guard.to_pos(visit, manager)[:driver_phone]).to eq('0909123456')
  end

  it 'refuses a rule that pays nothing' do
    error = refusal { commission_rule!(store, manager, branch, per_vehicle_amounts: { 'seat_29' => '0' }, per_guest_amount: '0') }
    expect(error.reason).to eq('commission_rule_invalid')
    expect do
      savepoint do
        Spree::Pos::CommissionRule.insert_all([{ store_id: store.id, branch_id: branch.id, per_vehicle_amounts: {}, per_guest_amount: 0,
                                                 created_at: Time.current, updated_at: Time.current }])
      end
    end.to raise_error(ActiveRecord::StatementInvalid, /chk_pos_commission_rules_pays/)
  end
end
