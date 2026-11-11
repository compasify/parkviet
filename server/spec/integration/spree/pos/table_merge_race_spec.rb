# frozen_string_literal: true

require_relative '../../../support/pos_race_helpers'
require_relative '../../../support/pos_table_helpers'

# Two people merge two tables into each other at the same moment (A into B
# and B into A). Both orders are locked in id order, so the merges run one
# after the other and the second finds the order it needs gone: one order
# survives with every line.
RSpec.describe 'POS crossed table merges', type: :integration do
  include_context 'with committed POS race rows'
  include PosTableHelpers

  it 'lets exactly one of two crossed merges through' do
    branch = table_branch(store)
    cashier = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    table_register!(branch, cashier)
    area = area!(branch)
    dish = menu_product!(store, branch, price: 40_000)
    first = open_table(cashier, table!(area, name: 'Bàn 1'))
    second = open_table(cashier, table!(area, name: 'Bàn 2', x: 4))
    add_dish(first, dish)
    add_dish(second, dish, quantity: 2)
    pairs = [[first, second], [second, first]].map { |source, target| [editing_args(source), target.workspace.prefixed_id] }
    lower = [first.workspace, second.workspace].min_by(&:id)

    outcomes = race(lower) do |index|
      arguments, target_id = pairs[index]
      Spree::Pos::Tables::Merge.call(**arguments, target_workspace_id: target_id)
    end

    expect(outcomes.map(&:first)).to contain_exactly(:success, :conflict)
    statuses = [first, second].map { |order| order.workspace.reload.operational_status }
    expect(statuses).to contain_exactly('editing', 'canceled')
    survivor = [first, second].map(&:workspace).find { |workspace| workspace.operational_status == 'editing' }
    expect(survivor.order.reload.line_items.sum(:quantity)).to eq(3)
    expect(Spree::Pos::SaleLine.where(workspace_id: [first.workspace.id, second.workspace.id]).distinct.pluck(:workspace_id)).to eq([survivor.id])
  end
end
