# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_credit_helpers'
require_relative '../../../../support/pos_race_helpers'

RSpec.describe 'device pairing race' do
  include_context 'with committed POS race rows'
  include PosCreditHelpers

  it 'lets only one device spend a pairing code' do
    branch = credit_branch(store)
    manager = credit_staff(store, branch, PosCreditHelpers::MANAGER + [Spree::Pos::Capabilities::DEVICE_MANAGE])
    code = Spree::Pos::DevicePairing.new_code
    pairing = Spree::Pos::DevicePairing.create!(
      store: store, branch: branch, mode: 'kds', created_by: manager,
      code_digest: Spree::Pos::DevicePairing.digest(code), expires_at: 10.minutes.from_now, attrs: {}
    )

    outcomes = race(pairing) do
      Spree::Pos::Devices::Pair.call(code: code, platform: 'android', name: 'Bếp')
    end

    expect(outcomes.map(&:first)).to contain_exactly(:success, :conflict)
    expect(Spree::Pos::Device.where(branch: branch).count).to eq(1)
  end

  it 'counts two concurrent wrong PINs one at a time' do
    branch = credit_branch(store)
    manager = credit_staff(store, branch, PosCreditHelpers::MANAGER)
    staff = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    membership = Spree::Pos::StaffMembership.find_by!(staff: staff, branch: branch)
    membership.set_pin!('1234')
    device = Spree::Pos::Device.create!(store: store, branch: branch, name: 'Phục vụ', mode: 'waiter', platform: 'android',
                                        token_digest: Spree::Pos::Device.digest(Spree::Pos::Device.new_token), paired_by: manager)
    4.times { Spree::Pos::DevicePinFailure.create!(device: device, staff_membership: membership, failed_at: Time.current) }

    outcomes = race(device) do
      Spree::Pos::Devices::StaffSignIn.call(device: Spree::Pos::Device.find(device.id), membership_id: membership.prefixed_id, pin: '0000')
    end

    expect(outcomes.map(&:first)).to eq(%i[conflict conflict])
    expect(Spree::Pos::DevicePinFailure.where(device: device).count).to eq(5)
  end
end
