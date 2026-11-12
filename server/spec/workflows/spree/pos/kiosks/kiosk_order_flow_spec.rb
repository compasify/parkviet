# frozen_string_literal: true

require_relative '../../../../support/pos_kiosk_helpers'

# A guest at a self-ordering kiosk, through the real workflows: paying by
# bank QR completes the sale on the bank's webhook alone (call number,
# kitchen, receipt on the kiosk's printer); paying at the counter parks the
# order with its call number for a cashier, who takes it to their own shift
# and collects as usual.
RSpec.describe 'POS kiosk orders', type: :request do
  include PosKioskHelpers

  let(:store) { menu_store }
  let(:branch) { kiosk_branch(store) }
  let(:manager) { credit_staff(store, branch, PosKioskHelpers::KIOSK_MANAGER) }
  let(:register) { kiosk_register!(branch) }
  let!(:paired) { pair_kiosk!(register, manager) }
  let(:device) { paired.first }
  let!(:station) { kitchen_station!(branch, name: 'Bếp', default: true) }
  let(:item) { menu_item!(store, branch, name: 'Cà phê sữa', price: 30_000) }
  let(:variant) { item.product.default_variant }

  before do
    kiosk_vietqr!(store)
    open_kiosk_shift!(register, manager)
  end

  it 'provisions a service account with only what a kiosk needs' do
    account = kiosk_account(device)
    expect(account).to have_attributes(service_account: true, status: 'active', branch_id: branch.id)
    expect(account.capabilities).to match_array(Spree::Pos::Kiosks::Policy::CAPABILITIES)
    expect(account.pin_digest).to be_nil
    expect(Spree::Pos::Shift.open_now.find_by!(register_id: register.id).owner_id).to eq(account.staff_id)
    expect(Spree::Pos::Kiosks::State.call(device)).to include(open: true, reason: nil, payments: { vietqr: true, counter: true })
  end

  it 'completes a QR order on the bank webhook, with call number, kitchen ticket and server prices' do
    printer = cup_printer!(branch).tap { |row| row.update!(roles: %w[receipt], command_language: 'escpos', register: register) }
    view = place_kiosk_order(device, kiosk_items(variant, quantity: 2).map { |row| row.merge('price' => '1') }, payment: 'vietqr')
    workspace = kiosk_workspace(view)
    expect(view).to include('status' => 'awaiting_payment', 'total' => '60000.0', 'call_number' => nil)
    expect(view.dig('payment', 'state')).to eq('waiting')
    expect(view.dig('payment', 'qr', 'account_number')).to eq('0123456789')
    expect(workspace).to have_attributes(order_source: 'kiosk', register_id: register.id)
    expect(Spree::Pos::KitchenTicket.where(workspace_id: workspace.id)).to be_empty

    expect { Spree::Pos::Kiosks::Order.finish(device: device, workspace: workspace, key: SecureRandom.uuid) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('vietqr_not_received') }

    bank_webhook!(view.dig('payment', 'qr', 'transfer_note'), 60_000)
    expect(Spree::Pos::Kiosks::View.call(workspace.reload, device).dig(:payment, :state)).to eq('received')

    done = Spree::Pos::Kiosks::Order.finish(device: device, workspace: workspace, key: SecureRandom.uuid)
    expect(done).to include('status' => 'paid', 'call_number' => 1)
    expect(workspace.reload.operational_status).to eq('completed')
    attempt = Spree::Pos::TenderAttempt.find_by!(workspace: workspace)
    expect(Spree::Pos::ReceiptEvidence.find_by!(tender_attempt: attempt).kind).to eq('vietqr_webhook')
    expect(Spree::Pos::KitchenTicket.where(workspace_id: workspace.id).count).to eq(1)
    expect(Spree::Pos::PrintJob.where(printer: printer, kind: 'receipt').count).to eq(1)
    expect(Spree::Pos::AuditEntry.where(subject_type: workspace.class.name, subject_id: workspace.id, action: 'workspace.complete').sole.actor_id).to eq(kiosk_account(device).staff_id)
  end

  it 'gives the QR back and parks the order for the counter when the guest pays there instead' do
    view = place_kiosk_order(device, kiosk_items(variant), payment: 'vietqr')
    workspace = kiosk_workspace(view)
    parked = Spree::Pos::Kiosks::Order.pay_at_counter(device: device, workspace: workspace, key: SecureRandom.uuid)
    expect(parked).to include('status' => 'at_counter', 'call_number' => 1, 'payment' => nil)
    expect(Spree::Pos::TenderAttempt.find_by!(workspace: workspace).status).to eq('canceled')
    expect(Spree::Pos::KitchenTicket.where(workspace_id: workspace.id)).to be_empty
  end

  it 'lets a cashier take a counter order to their shift, collect cash and complete it, the kitchen hearing of it then' do
    workspace = kiosk_workspace(place_kiosk_order(device, kiosk_items(variant), payment: 'counter'))
    expect(workspace.reload).to have_attributes(operational_status: 'parked', order_number: 1)
    expect(Spree::Pos::KitchenTicket.where(workspace_id: workspace.id)).to be_empty
    expect(Spree::Pos::Kiosks::Handoff.list(branch).map { |row| row[:id] }).to eq([workspace.prefixed_id])

    cashier = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    open_drawer(store, branch, cashier)
    editor = SecureRandom.uuid
    Spree::Pos::Kiosks::Handoff.take(store: store, staff: cashier, key: SecureRandom.uuid, workspace: workspace, editor_id: editor)
    expect(workspace.reload).to have_attributes(operational_status: 'editing', lease_holder_id: cashier.id)
    expect(workspace.shift.owner_id).to eq(cashier.id)
    expect(Spree::Pos::Kiosks::Handoff.list(branch)).to be_empty

    sale = PosCreditHelpers::Sale.new(workspace: workspace, cashier: cashier, editor_id: editor)
    take_tender(sale, 'cash', 30_000)
    Spree::Pos::Workspaces::Complete.call(**editing_args(sale))
    expect(workspace.reload.operational_status).to eq('completed')
    expect(Spree::Pos::KitchenTicket.where(workspace_id: workspace.id).count).to eq(1)
    expect(workspace.order_number).to eq(1)
  end

  it 'sends a counter order to the kitchen before payment where the branch asks for it' do
    branch.update!(kiosk_kitchen_before_payment: true)
    workspace = kiosk_workspace(place_kiosk_order(device, kiosk_items(variant), payment: 'counter'))
    expect(Spree::Pos::KitchenTicket.where(workspace_id: workspace.id).count).to eq(1)
  end

  it 'replays an order for the same key and refuses sold out items and a closed shift' do
    key = SecureRandom.uuid
    first = place_kiosk_order(device, kiosk_items(variant), payment: 'counter', key: key)
    expect(place_kiosk_order(device, kiosk_items(variant), payment: 'counter', key: key)['id']).to eq(first['id'])

    sold_out = menu_item!(store, branch, name: 'Bánh mì', price: 20_000)
    Spree::Pos::MenuAvailability.create!(branch: branch, menu_item: sold_out,
                                         sold_out_on: Spree::Pos::BusinessDay.for(branch, Spree::Pos::Workspace.business_now))
    expect { place_kiosk_order(device, kiosk_items(sold_out.product.default_variant), payment: 'counter') }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('item_sold_out') }

    Spree::Pos::Kiosks::Shifts.close(store: store, staff: manager, key: SecureRandom.uuid, register_id: register.prefixed_id)
    expect(Spree::Pos::Kiosks::State.call(device)).to include(open: false, reason: 'shift_closed')
    expect { place_kiosk_order(device, kiosk_items(variant), payment: 'counter') }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('kiosk_paused') }
  end

  it 'cancels an unpaid QR order on idle and keeps a cashier from canceling one being paid' do
    view = place_kiosk_order(device, kiosk_items(variant), payment: 'vietqr')
    workspace = kiosk_workspace(view)
    cashier = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    open_drawer(store, branch, cashier)
    expect { Spree::Pos::Kiosks::Handoff.cancel(store: store, staff: cashier, key: SecureRandom.uuid, workspace: workspace) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('kiosk_qr_open') }

    canceled = Spree::Pos::Kiosks::Order.cancel(device: device, workspace: workspace, key: SecureRandom.uuid)
    expect(canceled['status']).to eq('canceled')
    expect(Spree::Payment.find(Spree::Pos::TenderAttempt.find_by!(workspace: workspace).snapshot['vietqr_payment_id']).status).to eq('void')
  end

  it 'settles an abandoned QR order the bank paid when a cashier takes it' do
    view = place_kiosk_order(device, kiosk_items(variant), payment: 'vietqr')
    workspace = kiosk_workspace(view)
    bank_webhook!(view.dig('payment', 'qr', 'transfer_note'), 30_000)
    cashier = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    open_drawer(store, branch, cashier)
    Spree::Pos::Kiosks::Handoff.take(store: store, staff: cashier, key: SecureRandom.uuid, workspace: workspace, editor_id: SecureRandom.uuid)
    expect(workspace.reload.operational_status).to eq('completed')
  end
end
