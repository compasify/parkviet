# frozen_string_literal: true

require 'openssl'
require_relative 'pos_counter_service_helpers'

# Self-ordering kiosks built on the real workflows: a counter-service
# branch running the menu, the kitchen, call numbers and kiosks; a kiosk
# register with a device paired to it (which provisions its service
# account); its shift opened by a manager; VietQR with a SePay account whose
# webhook a spec can send.
module PosKioskHelpers
  include PosCounterServiceHelpers

  KIOSK_MANAGER = [Spree::Pos::Capabilities::DEVICE_MANAGE, Spree::Pos::Capabilities::OPEN_SHIFT].freeze
  WEBHOOK_SECRET = 'sepay-kiosk-secret'

  def kiosk_branch(store, trigger: 'on_complete')
    branch = counter_branch(store, trigger: trigger, cup_labels: false)
    set_pos_module(branch, 'fnb.kiosk', true)
    branch
  end

  def kiosk_register!(branch, name: 'Kiosk 1')
    Spree::Pos::Register.create!(store: branch.store, branch: branch, name: name, code: "k#{SecureRandom.hex(4)}", status: 'active',
                                 kind: 'kiosk')
  end

  # [device, token] of a kiosk paired to `register` by `manager`.
  def pair_kiosk!(register, manager)
    pairing = Spree::Pos::Devices::Pairing.call(store: register.store, staff: manager, key: SecureRandom.uuid, branch_id: register.branch.prefixed_id,
                                                mode: 'kiosk', register_id: register.prefixed_id, base_url: 'http://pos.test')
    paired = Spree::Pos::Devices::Pair.call(code: pairing['code'], platform: 'android', name: 'Kiosk sảnh')
    [Spree::Pos::Device.find_by_prefix_id!(paired[:device][:id]), paired[:token]]
  end

  def open_kiosk_shift!(register, manager)
    Spree::Pos::Kiosks::Shifts.open(store: register.store, staff: manager, key: SecureRandom.uuid, register_id: register.prefixed_id)
  end

  def kiosk_vietqr!(store)
    method = Spree::PaymentMethod::Vietqr.create!(store: store, name: 'Chuyển khoản VietQR', active: true)
    method.receiving_accounts.create!(provider: 'sepay', bank_bin: '970436', bank_name: 'Vietcombank', account_number: '0123456789',
                                      account_name: 'PARK VIET', webhook_secret: WEBHOOK_SECRET)
    method
  end

  def kiosk_items(variant, quantity: 1, modifiers: [])
    [{ 'variant_id' => variant.prefixed_id, 'quantity' => quantity, 'modifiers' => modifiers }]
  end

  def place_kiosk_order(device, items, payment:, key: SecureRandom.uuid)
    Spree::Pos::Kiosks::Order.place(device: device, key: key, items: items, payment: payment)
  end

  # The bank tells SePay (and so the server) the guest paid the order's QR.
  def bank_webhook!(transfer_content, amount)
    body = { id: SecureRandom.random_number(10**9), gateway: 'Vietcombank', transactionDate: Time.current.to_s,
             accountNumber: '0123456789', content: "chuyen tien #{transfer_content}", transferType: 'in', transferAmount: amount,
             referenceCode: "FT#{SecureRandom.hex(4).upcase}" }.to_json
    timestamp = Time.current.to_i.to_s
    signature = "sha256=#{OpenSSL::HMAC.hexdigest('SHA256', WEBHOOK_SECRET, "#{timestamp}.#{body}")}"
    post '/webhooks/payments/sepay', params: body, headers: { 'CONTENT_TYPE' => 'application/json', 'X-SePay-Signature' => signature,
                                                               'X-SePay-Timestamp' => timestamp }
    expect(response).to have_http_status(:ok)
  end

  def kiosk_workspace(view)
    Spree::Pos::Workspace.find_by_prefix_id!(view['id'] || view[:id])
  end

  def kiosk_account(device)
    Spree::Pos::StaffMembership.find_by!(device_id: device.id)
  end
end
