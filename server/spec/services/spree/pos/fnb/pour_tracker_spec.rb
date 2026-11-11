# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_recipe_helpers'

# Measured pours: a recipe row in ml from a bottle counted by the bottle.
# Selling pours into the open bottle; a bottle that runs dry leaves the
# shelf, once, however often the sale is replayed.
RSpec.describe Spree::Pos::Fnb::PourTracker do
  include PosRecipeHelpers

  let(:store) { menu_store }
  let(:branch) { recipe_branch(store).tap { |row| set_pos_module(row, 'fnb.pour_tracking', true) } }
  let(:manager) { recipe_manager(store, branch) }
  let(:item) { menu_item!(store, branch, name: 'Whisky shot', price: 90_000) }
  let(:whisky) { ingredient!(store, branch, name: 'Chivas 12', base: 'chai', stock: 5, cost: 700_000) }

  before do
    Spree::Pos::Recipes::Save.call(store: store, staff: manager, key: SecureRandom.uuid, owner: size(item), confirm_stock_write_off: true,
                                   ingredients: [{ 'variant_id' => whisky.prefixed_id, 'quantity' => '30', 'unit_code' => 'ml',
                                                   'bottle_ml' => '700' }])
  end

  def sell(quantity)
    sale = menu_sale(store, branch)
    add_menu(sale, size(item), quantity: quantity)
    pay_and_complete(sale)
    sale
  end

  it 'keeps the pour as ml of a bottle in the recipe, costed by the ml' do
    row = Spree::Pos::RecipeIngredient.sole
    expect(row).to have_attributes(pour_ml: 30, bottle_ml: 700, base_quantity: 0)
    expect(row.to_pos(unit_cost: Spree::Pos::Recipes.unit_cost(store.id, whisky))).to include(cost: '30000.0')
  end

  it 'pours into the open bottle, opens the next when it runs dry and takes one bottle off the shelf' do
    sale = sell(24) # 720 ml

    bottles = Spree::Pos::OpenBottle.order(:id).to_a
    expect(bottles.map { |bottle| [bottle.status, bottle.remaining_ml] }).to eq([['finished', 0], ['open', 680]])
    expect(Spree::Pos::PourEvent.where(workspace_id: sale.workspace.id).sum(:ml)).to eq(720)
    expect(shelf(branch, whisky)).to eq(4)

    sell(1)
    expect(bottles.last.reload.remaining_ml).to eq(650)
    expect(shelf(branch, whisky)).to eq(4)
  end

  it 'pours a sale once, whatever replays it' do
    sale = sell(2)
    expect { described_class.call(workspace: sale.workspace.reload, actor: sale.cashier) }.
      not_to(change { [Spree::Pos::PourEvent.count, Spree::Pos::OpenBottle.sole.remaining_ml] })
    expect(Spree::Pos::OpenBottle.sole.remaining_ml).to eq(640)
  end

  it 'leaves bottles alone where pours are not tracked' do
    set_pos_module(branch, 'fnb.pour_tracking', false)
    sell(2)
    expect(Spree::Pos::OpenBottle.count).to eq(0)
    expect(shelf(branch, whisky)).to eq(5)
  end

  it 'finishes a bottle by hand, once, taking it off the shelf' do
    sell(1)
    bottle = Spree::Pos::OpenBottle.sole
    staff = credit_staff(store, branch, PosCreditHelpers::CASHIER)
    finish = -> { described_class.finish_by_hand(store: store, staff: staff, key: SecureRandom.uuid, bottle_id: bottle.prefixed_id) }

    expect(finish.call).to include('status' => 'finished')
    expect(shelf(branch, whisky)).to eq(4)
    expect { finish.call }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('bottle_finished') }
    expect(Spree::Pos::AuditEntry.where(action: 'open_bottle.finish').sole.metadata).to include('remaining_ml' => 670)
  end
end
