# frozen_string_literal: true

require_relative '../../../support/pos_table_helpers'
require_relative '../../../support/pos_race_helpers'

# Several people working one table at the same moment, on real connections:
# additions commute and both land, an addition and a payment are ordered by
# the workspace lock so the snapshot rule refuses whichever comes second, and
# a kitchen send is made once per key and never sends an item twice.
RSpec.describe 'POS table append race', type: :integration do
  include PosTableHelpers

  include_context 'with committed POS race rows'

  let(:branch) { table_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:waiter) { credit_staff(store, branch, PosTableHelpers::WAITER) }
  let(:dish) { menu_product!(store, branch, name: 'Cơm gà', price: 40_000) }

  before do
    table_register!(branch, cashier)
    kitchen_station!(branch, name: 'Bếp', default: true)
  end

  def table_order
    open_table(cashier, table!(area!(branch, name: "Tầng #{SecureRandom.hex(2)}"), name: "Bàn #{SecureRandom.hex(2)}"))
  end

  def append(staff, workspace, quantity: 1)
    Spree::Pos::Workspaces::AppendItems.call(workspace: Spree::Pos::Workspace.find(workspace.id), staff: staff, key: SecureRandom.uuid,
                                             items: [{ variant_id: dish.prefixed_id, quantity: quantity }])
  end

  it 'lands two batches added at once, each on its own line' do
    order = table_order
    revision = order.workspace.reload.revision

    outcomes = race(order.workspace) { |index| append(index.zero? ? waiter : cashier, order.workspace, quantity: index + 1)['sale_line_ids'] }

    expect(outcomes.map(&:first)).to eq(%i[success success])
    lines = Spree::Pos::SaleLine.where(workspace_id: order.workspace.id)
    expect(lines.map(&:sale_quantity).sort).to eq([1, 2])
    expect(order.workspace.reload.revision).to eq(revision + 2)
    expect(order.workspace.order.reload.item_total).to eq(120_000)
  end

  it 'refuses whichever of an addition and a payment comes second' do
    order = table_order
    append(cashier, order.workspace)
    args = editing_args(order)
    method = Spree::Pos::PaymentMethodResolver.new(store: store).available.find { |row| row.kind == 'cash' }

    outcomes = race(order.workspace) do |index|
      if index.zero?
        append(waiter, order.workspace)
        :appended
      else
        Spree::Pos::Tenders::Prepare.call(**args, payment_method_id: method.prefixed_id || 'posmethod-cash', amount: '10000')
        :prepared
      end
    end

    expect(outcomes.map(&:first).sort).to eq(%i[conflict success])
    winner = outcomes.find { |outcome| outcome.first == :success }.last
    lines = Spree::Pos::SaleLine.where(workspace_id: order.workspace.id).count
    tenders = Spree::Pos::TenderAttempt.where(workspace_id: order.workspace.id).count
    expect([lines, tenders]).to eq(winner == :appended ? [2, 0] : [1, 1])
  end

  it 'sends once per key, and a second key finds nothing left to send' do
    order = table_order
    append(waiter, order.workspace, quantity: 3)
    key = SecureRandom.uuid

    same = race(order.workspace) do
      Spree::Pos::Kitchen::Send.command(workspace: Spree::Pos::Workspace.find(order.workspace.id), staff: waiter, key: key)['ticket_count']
    end
    expect(same).to eq([[:success, 1], [:success, 1]])
    expect(Spree::Pos::KitchenSend.where(workspace_id: order.workspace.id).count).to eq(1)

    append(cashier, order.workspace)
    other = race(order.workspace) do |index|
      Spree::Pos::Kitchen::Send.command(workspace: Spree::Pos::Workspace.find(order.workspace.id), staff: index.zero? ? waiter : cashier,
                                        key: SecureRandom.uuid)['ticket_count']
    end
    expect(other.map(&:last).sort).to eq([0, 1])
    tickets = Spree::Pos::KitchenTicket.where(workspace_id: order.workspace.id)
    expect(tickets.count).to eq(2)
    expect(Spree::Pos::KitchenTicketItem.where(kitchen_ticket_id: tickets.select(:id)).sum(:quantity)).to eq(4)
    expect(Spree::Pos::SaleLine.where(workspace_id: order.workspace.id).sum(:kitchen_sent_quantity)).to eq(4)
  end
end
