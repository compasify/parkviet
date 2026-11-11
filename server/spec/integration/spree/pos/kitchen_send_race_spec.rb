# frozen_string_literal: true

require_relative '../../../support/pos_kitchen_helpers'
require_relative '../../../support/pos_race_helpers'

# Two "send to kitchen" presses at the same moment, on two connections, with
# different keys: the workspace lock lets one send everything and the other
# finds nothing left, so each unsent part reaches the kitchen once.
RSpec.describe 'POS kitchen send race', type: :integration do
  include PosKitchenHelpers

  include_context 'with committed POS race rows'

  it 'sends each unsent part once' do
    branch = kitchen_branch(store, trigger: 'manual')
    kitchen_station!(branch, name: 'Bếp', default: true)
    item = menu_item!(store, branch, name: 'Bánh mì', price: 25_000)
    sale = menu_sale(store, branch)
    add_menu(sale, size(item), quantity: 3)
    args = editing_args(sale).except(:key)

    outcomes = race(sale.workspace) do |index|
      Spree::Pos::Kitchen::Send.command(**args, key: "race-#{index}-#{SecureRandom.hex(4)}")['tickets'].size
    rescue Spree::Pos::Conflict => e
      e.message
    end

    # The loser either sent nothing or found the revision moved on.
    expect(outcomes.map(&:first)).to all(eq(:success))
    expect(outcomes.map(&:last)).to include(1)
    tickets = Spree::Pos::KitchenTicket.where(workspace_id: sale.workspace.id)
    expect(tickets.count).to eq(1)
    expect(tickets.sole.items.sum(:quantity)).to eq(3)
    expect(Spree::Pos::SaleLine.where(workspace_id: sale.workspace.id).sole.kitchen_sent_quantity).to eq(3)
  end
end
