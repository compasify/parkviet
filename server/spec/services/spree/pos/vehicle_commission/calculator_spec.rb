# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_vehicle_helpers'

# Coach commission: a fixed amount per visit by vehicle type, an amount per
# guest, or both added up, paid only once the visit reaches the rule's
# minimum guests and revenue. A bus operator's own rule wins over the
# branch's general rule, and only rules in force on the visit's date count.
RSpec.describe Spree::Pos::VehicleCommission::Calculator do
  include PosVehicleHelpers

  let(:store) { Spree::Store.default }
  let(:branch) { rest_stop_branch(store) }
  let(:manager) { credit_staff(store, branch, PosVehicleHelpers::STOP_MANAGER) }

  def amount(rule, vehicle_type: 'seat_29', guests: 20, revenue: 1_000_000)
    described_class.call(rule: rule, vehicle_type: vehicle_type, guest_count: guests, revenue: BigDecimal(revenue.to_s))
  end

  it 'pays per vehicle, per guest, or both added up' do
    per_vehicle = commission_rule!(store, manager, branch, per_vehicle_amounts: { 'seat_29' => '100000' }, per_guest_amount: '0')
    per_guest = commission_rule!(store, manager, branch, per_vehicle_amounts: {}, per_guest_amount: '5000')
    both = commission_rule!(store, manager, branch, per_vehicle_amounts: { 'seat_29' => '100000', 'seat_45' => '150000' },
                                                    per_guest_amount: '5000')

    expect(amount(per_vehicle)).to include('vehicle_amount' => '100000.0', 'guest_amount' => '0.0', 'amount' => '100000.0', 'qualified' => true)
    expect(amount(per_guest)).to include('vehicle_amount' => '0.0', 'guest_amount' => '100000.0', 'amount' => '100000.0')
    expect(amount(both)).to include('amount' => '200000.0')
    expect(amount(both, vehicle_type: 'seat_45', guests: 40)).to include('amount' => '350000.0')
    # A type the rule has no amount for pays only per guest.
    expect(amount(both, vehicle_type: 'seat_16', guests: 10)).to include('vehicle_amount' => '0.0', 'amount' => '50000.0')
  end

  it 'pays nothing below the minimum guests or revenue, or without a rule' do
    rule = commission_rule!(store, manager, branch, min_guests: '10', min_revenue: '500000')

    expect(amount(rule, guests: 9)).to include('amount' => '0.0', 'qualified' => false, 'reason' => 'min_guests')
    expect(amount(rule, revenue: 499_999)).to include('amount' => '0.0', 'qualified' => false, 'reason' => 'min_revenue')
    expect(amount(rule, guests: 10, revenue: 500_000)).to include('amount' => '200000.0', 'qualified' => true)
    expect(amount(nil)).to include('amount' => '0.0', 'reason' => 'no_rule', 'rule' => nil)
  end

  it "prefers the operator's own rule in force on the visit's date over the branch's general one" do
    allow(Spree::Pos::Workspace).to receive(:business_now).and_return(Time.zone.parse('2026-11-12 05:30:00 UTC'))
    operator = bus_operator!(store, manager, branch, name: 'Phương Trang')
    general = commission_rule!(store, manager, branch, name: 'Chung')
    own = commission_rule!(store, manager, branch, name: 'Riêng', bus_operator_id: operator.prefixed_id, per_guest_amount: '20000')
    commission_rule!(store, manager, branch, name: 'Hết hạn', bus_operator_id: operator.prefixed_id, starts_on: '2026-01-01',
                                             ends_on: '2026-10-31', per_guest_amount: '90000')
    commission_rule!(store, manager, branch, name: 'Lưu trữ', bus_operator_id: operator.prefixed_id, status: 'archived')

    with_operator = open_visit!(store, manager, branch, bus_operator_id: operator.prefixed_id)
    without = open_visit!(store, manager, branch, plate: '29A-99999')
    other = open_visit!(store, manager, branch, plate: '30A-11111', bus_operator_id: bus_operator!(store, manager, branch).prefixed_id)

    expect(described_class.rule_for(with_operator)).to eq(own)
    expect(described_class.rule_for(without)).to eq(general)
    expect(described_class.rule_for(other)).to eq(general)
  end
end
