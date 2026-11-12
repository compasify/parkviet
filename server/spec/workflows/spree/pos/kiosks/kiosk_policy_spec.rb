# frozen_string_literal: true

require_relative '../../../../support/pos_kiosk_helpers'

# A kiosk's service account reaches only what a kiosk needs, even when a
# manager hands it more capabilities by mistake: no discount, price change,
# cash, hand attestation of a transfer, or any command outside its list.
RSpec.describe 'POS kiosk service account', type: :request do
  include PosKioskHelpers

  let(:store) { menu_store }
  let(:branch) { kiosk_branch(store) }
  let(:manager) { credit_staff(store, branch, PosKioskHelpers::KIOSK_MANAGER) }
  let(:register) { kiosk_register!(branch) }
  let!(:device) { pair_kiosk!(register, manager).first }
  let(:account) { kiosk_account(device) }
  let(:staff) { account.staff }
  let(:editor) { Spree::Pos::Kiosks::Policy.editor_id(device) }
  let(:item) { menu_item!(store, branch, name: 'Trà đào', price: 40_000) }

  before do
    kiosk_vietqr!(store)
    open_kiosk_shift!(register, manager)
    # Granted by mistake: none of these may work.
    account.update!(capabilities: Spree::Pos::Kiosks::Policy::CAPABILITIES + [Spree::Pos::Capabilities::DISCOUNT,
                                                                                Spree::Pos::Capabilities::PRICE_OVERRIDE,
                                                                                Spree::Pos::Capabilities::CASH_MOVE,
                                                                                Spree::Pos::Capabilities::APPROVE])
  end

  def kiosk_order(payment)
    kiosk_workspace(place_kiosk_order(device, kiosk_items(item.product.default_variant), payment: payment))
  end

  def args(workspace)
    workspace.reload
    Spree::Pos::Workspaces::ClaimLease.call(workspace: workspace, staff: staff, key: SecureRandom.uuid, editor_id: editor) unless
      workspace.lease_current?(staff, editor)
    workspace.reload
    { workspace: workspace, staff: staff, revision: workspace.revision, lease_generation: workspace.lease_generation, editor_id: editor,
      key: SecureRandom.uuid }
  end

  it 'cuts its capabilities to the kiosk list whatever the membership says' do
    expect(account.allows?(Spree::Pos::Capabilities::DISCOUNT)).to be(false)
    expect(account.allows?(Spree::Pos::Capabilities::APPROVE)).to be(false)
    expect(account.allows?(Spree::Pos::Capabilities::OPEN_SHIFT)).to be(true)
  end

  it 'refuses discounts and price overrides' do
    workspace = kiosk_order('vietqr')
    Spree::Pos::Tenders::Cancel.call(**args(workspace), attempt_id: Spree::Pos::TenderAttempt.find_by!(workspace: workspace).prefixed_id)
    expect { Spree::Pos::Workspaces::ApplyDiscount.call(**args(workspace), value_type: 'percent', value: '50', reason: 'x') }.
      to raise_error(CanCan::AccessDenied)
    line = Spree::Pos::SaleLine.find_by!(workspace: workspace)
    expect { Spree::Pos::Workspaces::OverridePrice.call(**args(workspace), sale_line_id: line.prefixed_id, price: '1000', reason: 'x') }.
      to raise_error(CanCan::AccessDenied)
  end

  it 'takes no cash and confirms a transfer only from the bank webhook' do
    workspace = kiosk_order('vietqr')
    attempt = Spree::Pos::TenderAttempt.find_by!(workspace: workspace)
    expect { Spree::Pos::Tenders::Confirm.call(**args(workspace), attempt_id: attempt.prefixed_id, evidence_kind: 'vietqr_manual') }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('kiosk_evidence_forbidden') }
    expect(Spree::Pos::VietqrTender.payment_for(attempt).status).to eq('pending')

    Spree::Pos::Tenders::Cancel.call(**args(workspace), attempt_id: attempt.prefixed_id)
    cash = Spree::Pos::PaymentMethodResolver.new(store: store).available(branch: branch).find { |row| row.kind == 'cash' }
    expect do
      Spree::Pos::Tenders::Prepare.call(**args(workspace), payment_method_id: cash.prefixed_id || 'posmethod-cash', amount: '40000')
    end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('kiosk_tender_forbidden') }
  end

  it 'refuses every command outside the kiosk list' do
    workspace = kiosk_order('counter')
    expect { Spree::Pos::Workspaces::UpdateNote.call(**args(workspace), note: 'x') }.to raise_error(CanCan::AccessDenied)
    expect do
      Spree::Pos::Shifts::Open.call(store: store, staff: staff, register: Spree::Pos::Register.create!(store: store, branch: branch, name: 'R',
                                                                                                     code: "r#{SecureRandom.hex(3)}"),
                                    opening_float: '0')
    end.to raise_error(CanCan::AccessDenied)
  end

  it 'never lists the account as staff and turns it off when the device is revoked' do
    expect(Spree::Pos::StaffMembership.people.where(branch: branch).pluck(:staff_id)).not_to include(staff.id)
    Spree::Pos::Devices::Revoke.call(store: store, staff: manager, key: SecureRandom.uuid, device_id: device.prefixed_id)
    expect(account.reload.status).to eq('disabled')
    expect(Spree::Pos::Kiosks::Policy.account(device.reload)).to be_nil
  end

  it 'pairs a kiosk only with a kiosk register and keeps cashiers off it' do
    counter = Spree::Pos::Register.create!(store: store, branch: branch, name: 'Quầy', code: "q#{SecureRandom.hex(3)}")
    expect do
      Spree::Pos::Devices::Pairing.call(store: store, staff: manager, key: SecureRandom.uuid, branch_id: branch.prefixed_id, mode: 'kiosk',
                                        register_id: counter.prefixed_id, base_url: 'http://pos.test')
    end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('register_not_kiosk') }

    other = kiosk_register!(branch, name: 'Kiosk 2')
    expect { Spree::Pos::Shifts::Open.call(store: store, staff: manager, register: other, opening_float: '0') }.
      to raise_error(CanCan::AccessDenied)
  end
end
