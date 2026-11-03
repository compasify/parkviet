# frozen_string_literal: true

RSpec.describe 'POS walk-in order policy' do
  def draft_without_email
    order = create(:order_with_totals, customer: nil, email: nil, bill_address: nil)
    order.recalculate_totals!
    order
  end

  it 'places a server-marked walk-in draft without inventing an email' do
    order = draft_without_email
    Pos::WalkInOrder.create!(order: order)

    result = Spree.order_complete_workflow.call(order: order, payment_pending: true, notify_customer: false)
    expect(result).to be_success
    expect(order.reload).to be_placed
    expect(order.email).to be_nil
    expect(order.payments).to be_empty
    expect(Pos::WalkInOrder.where(order: order).count).to eq(1)
  end

  it 'does not trust client-writable order metadata' do
    order = draft_without_email
    order.update!(metadata: { 'pos_walk_in' => true })

    expect do
      Spree.order_complete_workflow.call(order: order, payment_pending: true, notify_customer: false)
    end.to raise_error(ActiveRecord::RecordInvalid, /Email can't be blank/)
    expect(order.reload).to be_draft
  end

  it 'places a marked walk-in with a test payment through the core workflow' do
    order = draft_without_email
    Pos::WalkInOrder.create!(order: order)
    expect(order.total).to be > 0
    method = create(:check_payment_method, store: order.store)
    create(:payment, order: order, payment_method: method, amount: order.total)

    result = Spree.order_complete_workflow.call(order: order.reload, notify_customer: false)
    expect(result).to be_success
    expect(order.reload).to be_placed
    expect(order.email).to be_nil
    expect(order.payments.completed.sum(:amount)).to eq(order.total)
  end

  it 'still validates supplied email on a marked order' do
    order = draft_without_email
    Pos::WalkInOrder.create!(order: order)
    order.email = 'not-an-email'
    order.status = 'placed'

    expect(order).not_to be_valid
    expect(order.errors[:email]).to be_present
  end

  it 'does not exempt a customer-associated order without email' do
    order = create(:order_with_totals, email: nil)
    Pos::WalkInOrder.create!(order: order)
    order.email = nil
    order.status = 'placed'

    expect(order).not_to be_valid
    expect(order.errors[:email]).to be_present
  end

  it 'removes the marker when a draft is deleted' do
    order = draft_without_email
    marker = Pos::WalkInOrder.create!(order: order)

    order.destroy!
    expect(Pos::WalkInOrder.exists?(marker.id)).to be(false)
  end

  it 'requires email when a marked order opts in to marketing or account creation' do
    order = draft_without_email
    Pos::WalkInOrder.create!(order: order)
    order.status = 'placed'

    order.accept_marketing = true
    expect(order).not_to be_valid
    expect(order.errors[:email]).to be_present

    order.accept_marketing = false
    order.signup_for_an_account = true
    expect(order).not_to be_valid
    expect(order.errors[:email]).to be_present
  end
end
