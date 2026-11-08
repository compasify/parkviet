# frozen_string_literal: true

require_relative '../../../support/pos_return_helpers'

# Plan 261103 (I08): ordinary packages of one variant with different prices
# stay separate SaleLines and separate core line items from the draft through
# payment, handover and a partial return. Returning one package grants that
# package's own price and never touches the other package's entitlement.
RSpec.describe 'POS package split for one variant', type: :request do
  include PosReturnHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { returns_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosReturnHelpers::RETURNS + [Spree::Pos::Capabilities::PRICE_OVERRIDE]) }

  def add(sale, **params)
    workspace = sale.workspace.reload
    Spree::Pos::Workspaces::ManageLineItem.add(workspace: workspace, staff: cashier, revision: workspace.revision,
                                               lease_generation: workspace.lease_generation, editor_id: sale.editor_id,
                                               key: SecureRandom.uuid, variant_id: sale.product.default_variant.prefixed_id, **params)
  end

  def lines_of(sale)
    Spree::Pos::SaleLine.where(workspace_id: sale.workspace.id).order(:id).to_a
  end

  it 'keeps two differently priced packages apart through checkout, handover and a partial return' do
    product = stocked_product(store, branch, price: 100_000, stock: 10)
    # First package at list price (100 000 x 2), then a second package of the
    # same variant at an overridden price (80 000 x 3). No merge is requested.
    sale = open_sale(store, branch, cashier: cashier, product: product, quantity: 2)
    add(sale, quantity: 3, price_override: '80000')
    # A merge request whose key differs (different price) must not merge either.
    add(sale, quantity: 1, price_override: '90000', merge: true)

    full, cheap, other = lines_of(sale)
    expect([full, cheap, other].map(&:line_item_id).uniq.size).to eq(3)
    expect(full.line_item.reload).to have_attributes(quantity: 2, price: BigDecimal('100000'))
    expect(cheap.line_item.reload).to have_attributes(quantity: 3, price: BigDecimal('80000'))
    expect(other.line_item.reload).to have_attributes(quantity: 1, price: BigDecimal('90000'))
    expect(sale.workspace.reload.order.total).to eq(BigDecimal('530000'))

    complete_paid(sale)
    hand_over(sale)
    expect(on_hand(branch, product)).to eq(4)
    order = sale.workspace.reload.order
    expect(order.line_items.reload.map { |line| [line.quantity, line.price.to_i] }).
      to contain_exactly([2, 100_000], [3, 80_000], [1, 90_000])

    # Identity survives the order: each SaleLine still points at its own line.
    expect(lines_of(sale).map(&:line_item_id)).to eq([full.line_item_id, cheap.line_item_id, other.line_item_id])

    # Return two units of the cheap package: worth 2 x 80 000, not an average.
    received = receive_return(store, cashier, prepare_return(store, cashier, branch, sale, quantity: 2, line: cheap))
    expect(received).to include('entitlement_total' => '160000.0')
    expect(on_hand(branch, product)).to eq(6)
    expect(Spree::Pos::ReturnReservation.where(sale_line_id: full.id)).to be_empty
    expect(Spree::Pos::ReturnReservation.where(sale_line_id: other.id)).to be_empty

    # The cheap package has one unit left; the full-price one still has two.
    expect { prepare_return(store, cashier, branch, sale, quantity: 2, line: cheap) }.to raise_error(Spree::Pos::Conflict)
    rest = receive_return(store, cashier, prepare_return(store, cashier, branch, sale, quantity: 2, line: full))
    expect(rest).to include('entitlement_total' => '200000.0')
    expect(on_hand(branch, product)).to eq(8)
  end

  it 'edits and removes one package without re-pricing or merging the other' do
    product = stocked_product(store, branch, price: 50_000, stock: 10)
    sale = open_sale(store, branch, cashier: cashier, product: product, quantity: 1)
    add(sale, quantity: 1, price_override: '45000')
    first, second = lines_of(sale)

    workspace = sale.workspace.reload
    Spree::Pos::Workspaces::ManageLineItem.update_quantity(workspace: workspace, staff: cashier, revision: workspace.revision,
                                                           lease_generation: workspace.lease_generation, editor_id: sale.editor_id,
                                                  key: SecureRandom.uuid, sale_line_id: first.prefixed_id, quantity: 3)
    expect(first.line_item.reload).to have_attributes(quantity: 3, price: BigDecimal('50000'))
    expect(second.line_item.reload).to have_attributes(quantity: 1, price: BigDecimal('45000'))

    workspace = sale.workspace.reload
    Spree::Pos::Workspaces::ManageLineItem.remove(workspace: workspace, staff: cashier, revision: workspace.revision,
                                                  lease_generation: workspace.lease_generation, editor_id: sale.editor_id,
                                                  key: SecureRandom.uuid, sale_line_id: first.prefixed_id)
    expect(lines_of(sale)).to eq([second])
    expect(second.line_item.reload).to have_attributes(quantity: 1, price: BigDecimal('45000'))
    expect(sale.workspace.reload.order.total).to eq(BigDecimal('45000'))
  end
end
