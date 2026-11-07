# frozen_string_literal: true

# Qualification only. These examples do not authorize POS discounts or prove
# correctness for weighted items, all tax providers or later returns.
RSpec.describe 'POS draft pricing qualification' do
  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }

  it 'preserves a line-targeted core manual discount through draft recalculation' do
    order = create(:order, store: store, currency: 'VND')
    item = create(:line_item, order: order, quantity: 2, price: 100)
    Spree.order_recalculate_totals_workflow.call(order: order)
    result = Spree::Orders::Discounts::Create.call(order: order, label: 'Test', value: '10', value_type: 'percent', line_item: item)
    expect(result).to be_success
    expect(order.discounts.where(kind: 'manual').sum(:amount)).to eq(-20)
    Spree.order_recalculate_totals_workflow.call(order: order)
    expect(order.reload.discounts.where(kind: 'manual').sum(:amount)).to eq(-20)
    expect(order.total).to eq(180)
  end

  it 'characterizes fractional base-unit price for an integer quantity before tax or discount' do
    order = create(:order, store: store, currency: 'VND')
    create(:line_item, order: order, quantity: 1250, price: BigDecimal('0.4'))
    Spree.order_recalculate_totals_workflow.call(order: order)
    expect(order.reload.item_total).to eq(BigDecimal('500'))
    expect(order.total).to eq(BigDecimal('500'))
  end

  it 'characterizes core manual discounts as snapshots after quantity changes' do
    order = create(:order, store: store, currency: 'VND')
    first = create(:line_item, order: order, quantity: 1, price: 100)
    remaining = create(:line_item, order: order, quantity: 1, price: 100)
    Spree.order_recalculate_totals_workflow.call(order: order)
    result = Spree::Orders::Discounts::Create.call(order: order, label: 'Test', value: '10', value_type: 'percent')
    expect(result).to be_success
    expect(order.reload.total).to eq(180)
    first.destroy!
    Spree.order_recalculate_totals_workflow.call(order: order)
    expect(order.reload.total).to eq(90)
    remaining.variant.set_price('VND', 100)
    remaining.update!(quantity: 2)
    Spree.order_recalculate_totals_workflow.call(order: order)
    expect(order.reload.total).to eq(190)
  end

  it 'recalculates an experimental POS intent after the quantity changes' do
    staff = create(:admin_user)
    location = create(:stock_location, store: store)
    branch = Spree::Pos::Branch.create!(store: store, stock_location: location, name: 'Branch', code: 'branch', timezone: 'Asia/Ho_Chi_Minh', status: 'active')
    register = Spree::Pos::Register.create!(store: store, branch: branch, name: 'Register', code: 'register', status: 'active')
    shift = Spree::Pos::Shift.create!(store: store, branch: branch, register: register, owner: staff, opening_float: 0, currency: 'VND', status: 'open', opened_at: Time.current)
    order = create(:order, store: store, currency: 'VND')
    workspace = Spree::Pos::Workspace.create!(store: store, branch: branch, register: register, shift: shift, order: order)
    item = create(:line_item, order: order, quantity: 1, price: 100)
    item.variant.set_price('VND', 100)
    intent = Spree::Pos::DiscountIntent.create!(workspace: workspace, actor: staff, value_type: 'percent', value: '10', reason: 'Test')

    adjuster = Spree::Pos::Adjusters::ManualDiscount
    added_adjuster = !Spree.adjusters.include?(adjuster)
    Spree.adjusters << adjuster if added_adjuster
    begin
      Spree.order_recalculate_totals_workflow.call(order: order)
      expect(order.reload.total).to eq(90)
      item.update!(quantity: 2)
      Spree.order_recalculate_totals_workflow.call(order: order)
      expect(order.reload.total).to eq(180)
      Spree.order_recalculate_totals_workflow.call(order: order)
      expect(order.reload.total).to eq(180)
      expect(order.discounts.where(kind: 'manual').sum(:amount)).to eq(-20)

      intent.update!(value_type: 'flat', value: '150')
      Spree.order_recalculate_totals_workflow.call(order: order)
      expect(order.reload.total).to eq(50)
      expect {
        Spree::Order.transaction(requires_new: true) do
          item.update!(quantity: 1)
          Spree.order_recalculate_totals_workflow.call(order: order)
        end
      }.to raise_error(Spree::Pos::Conflict)
      expect(item.reload.quantity).to eq(2)
      expect(order.reload.total).to eq(50)
      expect(order.discounts.where(kind: 'manual').sum(:amount)).to eq(-150)

      intent.update!(value_type: 'percent', value: '10')
      item.destroy!
      Spree.order_recalculate_totals_workflow.call(order: order)
      expect(order.reload.total).to eq(0)
      expect(order.discounts).to be_empty

      create(:line_item, order: order, quantity: 1, price: 100)
      Spree.order_recalculate_totals_workflow.call(order: order)
      method = create(:check_payment_method, store: store)
      create(:payment, order: order, payment_method: method, amount: 1, status: 'pending')
      # After a payment the discount is part of the quoted snapshot: re-summing
      # the order (as completion does) keeps it, changing it is refused.
      before = order.discounts.where(kind: 'manual').pluck(:line_item_id, :amount)
      expect { Spree.order_recalculate_totals_workflow.call(order: order) }.not_to raise_error
      expect(order.reload.discounts.where(kind: 'manual').pluck(:line_item_id, :amount)).to eq(before)
      intent.update!(value: '20')
      expect { Spree.order_recalculate_totals_workflow.call(order: order) }.to raise_error(Spree::Pos::Conflict)
    ensure
      Spree.adjusters.delete(Spree::Pos::Adjusters::ManualDiscount) if added_adjuster
    end
  end
end
