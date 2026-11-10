# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_credit_helpers'

RSpec.describe Spree::Pos::Devices::Pairing do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:manager) { credit_staff(store, branch, PosCreditHelpers::MANAGER + [Spree::Pos::Capabilities::DEVICE_MANAGE]) }

  def issue(mode: 'kds', **extra)
    described_class.call(store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                         mode: mode, base_url: 'https://pos.quan-a.lan', **extra)
  end

  it 'returns a one-time code and a QR payload with the server address' do
    issued = issue
    expect(issued['code'].length).to eq(8)
    expect(issued['qr']).to eq('v' => 1, 'kind' => 'parkviet.device', 'url' => 'https://pos.quan-a.lan', 'code' => issued['code'])
    expect(Spree::Pos::DevicePairing.last.code_digest).not_to eq(issued[:code])

    paired = Spree::Pos::Devices::Pair.call(code: issued['code'], platform: 'android', name: 'Bếp')
    expect(paired[:token]).to be_present
    expect(Spree::Pos::Device.authenticate(paired[:token]).name).to eq('Bếp')
    expect { Spree::Pos::Devices::Pair.call(code: issued['code'], platform: 'android', name: 'Bếp') }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('pairing_invalid') }
  end

  it 'rejects an expired code' do
    issued = issue
    Spree::Pos::DevicePairing.last.update!(expires_at: 1.minute.ago)
    expect { Spree::Pos::Devices::Pair.call(code: issued['code'], platform: 'ios', name: 'Bếp') }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('pairing_invalid') }
  end

  it 'locks a membership on the fifth wrong PIN and accepts the right one after reset' do
    cashier = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    membership = Spree::Pos::StaffMembership.find_by!(staff: cashier, branch: branch)
    Spree::Pos::Devices::SetPin.call(store: store, staff: cashier, key: SecureRandom.uuid, membership_id: membership.prefixed_id, pin: '1234')
    issued = issue(mode: 'waiter')
    paired = Spree::Pos::Devices::Pair.call(code: issued['code'], platform: 'android', name: 'Phục vụ')
    device = Spree::Pos::Device.authenticate(paired[:token])

    4.times do
      expect { Spree::Pos::Devices::StaffSignIn.call(device: device, membership_id: membership.prefixed_id, pin: '0000') }.
        to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('pin_incorrect') }
    end
    expect { Spree::Pos::Devices::StaffSignIn.call(device: device, membership_id: membership.prefixed_id, pin: '0000') }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('pin_locked') }
    expect(Spree::Pos::AuditEntry.where(action: 'device.pin_lockout').count).to eq(1)

    Spree::Pos::DevicePinFailure.where(device: device).delete_all
    signed = Spree::Pos::Devices::StaffSignIn.call(device: device, membership_id: membership.prefixed_id, pin: '1234')
    expect(signed[:token]).to be_present
    Spree::Pos::Devices::ResetPin.call(store: store, staff: manager, key: SecureRandom.uuid, membership_id: membership.prefixed_id)
    expect { Spree::Pos::Devices::StaffSignIn.call(device: device.reload, membership_id: membership.prefixed_id, pin: '1234') }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('pin_not_set') }
  end
end
