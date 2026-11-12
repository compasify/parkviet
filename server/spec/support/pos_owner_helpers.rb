# frozen_string_literal: true

# An owner's phone paired through the real pairing workflows, and the
# person signed in on it with their PIN.
module PosOwnerHelpers
  # [device, device token] of an owner device paired at `branch`.
  def pair_owner_device!(branch)
    admin = credit_staff(branch.store, branch, [Spree::Pos::Capabilities::DEVICE_MANAGE])
    pairing = Spree::Pos::Devices::Pairing.call(store: branch.store, staff: admin, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                mode: 'owner', base_url: 'http://pos.test')
    paired = Spree::Pos::Devices::Pair.call(code: pairing['code'], platform: 'ios', name: 'Điện thoại chủ')
    [Spree::Pos::Device.find_by_prefix_id!(paired[:device][:id]), paired[:token]]
  end

  # Request headers of `staff` signed in on the owner device.
  def owner_headers(branch, staff, token)
    membership = Spree::Pos::StaffMembership.find_by!(staff: staff, branch: branch)
    membership.set_pin!('2468')
    post '/api/v3/pos_device/staff_sessions', headers: { 'Authorization' => "Device #{token}" },
                                              params: { membership_id: membership.prefixed_id, pin: '2468' }, as: :json
    { 'Authorization' => "Device #{token}", 'X-Pos-Staff-Session' => response.parsed_body.dig('data', 'token') }
  end
end
