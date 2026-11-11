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

  def signed_in_device(mode: 'waiter')
    issued = issue(mode: mode)
    paired = Spree::Pos::Devices::Pair.call(code: issued['code'], platform: 'android', name: 'Phục vụ')
    Spree::Pos::Device.authenticate(paired[:token])
  end

  def member_with_pin(pin = '1234')
    staff = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    membership = Spree::Pos::StaffMembership.find_by!(staff: staff, branch: branch)
    Spree::Pos::Devices::SetPin.call(store: store, staff: staff, key: SecureRandom.uuid, membership_id: membership.prefixed_id, pin: pin)
    membership
  end

  def refusal(device, membership, pin)
    Spree::Pos::Devices::StaffSignIn.call(device: device, membership_id: membership.prefixed_id, pin: pin)
    nil
  rescue Spree::Pos::Conflict => e
    e.reason
  end

  it 'keeps the lock for fifteen minutes from the fifth wrong PIN' do
    device = signed_in_device
    membership = member_with_pin
    start = Time.current
    [14, 13, 12, 11, 0].each do |minutes_ago|
      Spree::Pos::DevicePinFailure.create!(device: device, staff_membership: membership, failed_at: start - minutes_ago.minutes)
    end

    expect(Spree::Pos::DevicePinFailure.locked?(device, membership, start + 14.minutes)).to be(true)
    expect(Spree::Pos::DevicePinFailure.locked?(device, membership, start + 16.minutes)).to be(false)
  end

  it 'caps wrong PINs per device across memberships' do
    device = signed_in_device
    other = member_with_pin
    victim = member_with_pin
    Spree::Pos::DevicePinFailure::DEVICE_LIMIT.times do
      Spree::Pos::DevicePinFailure.create!(device: device, staff_membership: other, failed_at: 20.minutes.ago)
    end
    expect(refusal(device, victim, '0000')).to eq('pin_incorrect')
    Spree::Pos::DevicePinFailure.where(device: device).update_all(failed_at: 1.minute.ago)
    expect(refusal(device, victim, '1234')).to eq('pin_rate_limited')
  end

  it 'keeps no plain hash of the PIN in the command receipt' do
    membership = member_with_pin('1234')
    payload = { 'command' => 'staff.pin_set', 'membership_id' => membership.prefixed_id, 'pin_digest' => Digest::SHA256.hexdigest('1234') }
    plain = Spree::Pos::CommandReceipt.digest_for('workspace_id' => nil, 'payload' => payload)
    expect(Spree::Pos::CommandReceipt.where(actor_id: membership.staff_id).pluck(:digest)).not_to include(plain)
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
