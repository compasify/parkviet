# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_einvoice_helpers'

# Invoice lines come from what the order posted: each line with its own tax
# rate, order-level fees (service charge, delivery) as taxed lines of their
# own, and time-billed lines in hours with two decimals.
RSpec.describe Spree::Pos::Einvoices::Builder do
  include PosEinvoiceHelpers

  let(:store) { einvoice_store }
  let(:branch) { credit_branch(store) }

  def add_product(sale, price)
    product = create(:product, store: store, status: 'active', name: "Hàng #{SecureRandom.hex(3)}")
    product.default_variant.set_price(sale.workspace.order.currency, price)
    Spree::Pos::BranchProduct.create!(branch: branch, product: product)
    branch.stock_location.restock(product.default_variant, 10)
    workspace = sale.workspace.reload
    Spree::Pos::Workspaces::ManageLineItem.add(workspace: workspace, staff: sale.cashier, revision: workspace.revision,
                                               key: SecureRandom.uuid, lease_generation: workspace.lease_generation,
                                               editor_id: sale.editor_id, variant_id: product.default_variant.prefixed_id, quantity: 1)
    workspace.order.reload.line_items.find_by!(variant_id: product.default_variant.id)
  end

  def tax!(order, owner, amount, rate, label)
    Spree::TaxLine.create!(order: order, amount: amount, rate: BigDecimal(rate), label: label, included: true,
                           **(owner.is_a?(Spree::Fee) ? { fee_id: owner.id } : { line_item: owner }))
  end

  it 'gives every line its own rate and totals each rate' do
    sale = credit_sale(store, branch, price: 54_000)
    order = sale.workspace.order
    food = order.line_items.first
    drink = add_product(sale, 33_000)
    tax!(order, food, 4000, '0.08', 'VAT thực phẩm')
    tax!(order, drink, 3000, '0.10', 'VAT đặc biệt')

    built = described_class.call(sale.workspace.reload)
    lines = built[:lines]
    keys = %w[position kind tax_rate tax_amount amount_before_tax amount]
    expect(lines.map { |line| line.slice(*keys).values }).to eq(
      [[1, 'goods', '8', '4000.0', '50000.0', '54000.0'], [2, 'goods', '10', '3000.0', '30000.0', '33000.0']]
    )
    expect(lines.first).to include('name' => food.variant.product.name, 'unit' => 'Cái', 'quantity' => '1', 'price_includes_tax' => true)
    expect(built[:totals]).to include('amount_before_tax' => '80000.0', 'tax_amount' => '7000.0')
    expect(built[:totals]['taxes']).to contain_exactly(
      { 'tax_rate' => '8', 'amount_before_tax' => '50000.0', 'tax_amount' => '4000.0' },
      { 'tax_rate' => '10', 'amount_before_tax' => '30000.0', 'tax_amount' => '3000.0' }
    )
  end

  it 'adds the service charge as a taxed line of its own' do
    sale = credit_sale(store, branch, price: 108_000)
    order = sale.workspace.order
    tax!(order, order.line_items.first, 8000, '0.08', 'VAT thực phẩm')
    fee = Spree::Fee.create!(order: order, amount: 5400, label: 'Phí phục vụ 5%', kind: 'surcharge')
    tax!(order, fee, 400, '0.08', 'VAT thực phẩm')

    line = described_class.call(sale.workspace.reload)[:lines].last
    expect(line).to include('kind' => 'service_charge', 'name' => 'Phí phục vụ 5%', 'quantity' => '1', 'tax_rate' => '8',
                            'tax_amount' => '400.0', 'amount_before_tax' => '5000.0', 'amount' => '5400.0')
  end

  it 'bills time in hours with two decimals' do
    sale = credit_sale(store, branch, price: 90_000)
    Spree::Pos::SaleLine.where(workspace_id: sale.workspace.id).update_all(kind: 'timed', sale_quantity: BigDecimal('1.5833'))

    line = described_class.call(sale.workspace.reload)[:lines].first
    expect(line).to include('unit' => 'giờ', 'quantity' => '1.58')
  end

  it 'writes the payment method as invoices do' do
    sale = completed_sale(store, branch)
    expect(described_class.call(sale.workspace)[:payment_method]).to eq('TM')
  end
end
