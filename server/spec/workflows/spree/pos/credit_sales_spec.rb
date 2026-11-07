# frozen_string_literal: true

require_relative '../../../support/pos_credit_helpers'

# Credit sales through the real workflows: the approved debt is a receivable,
# never a Payment, and core payment status is left to derive from actual money.
RSpec.describe 'POS credit sales', type: :request do
  include PosCreditHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:manager) { credit_staff(store, branch, PosCreditHelpers::MANAGER) }
  let(:profile) { credit_customer(store, manager) }

  it 'sells 500k as cash 200k + bank 200k + approved debt 100k without making the order paid' do
    sale = credit_sale(store, branch, price: 500_000)
    assign(sale, profile)
    account = configure_credit(store, manager, branch, profile, limit: 300_000, due_days: 30)
    take_tender(sale, 'cash', 200_000)
    take_tender(sale, 'bank_manual', 200_000)

    approval = approve_credit(sale, manager, 100_000)
    expect(account.reload.exposure.reserved).to eq(BigDecimal('100000'))
    expect(account.exposure.available).to eq(BigDecimal('200000'))

    complete_on_credit(sale, approval['approval_id'])
    order = sale.workspace.reload.order
    expect(order).to be_placed
    expect(order.payments.where(status: 'completed').sum(:amount)).to eq(BigDecimal('400000'))
    expect(order.payments.count).to eq(2)
    expect(order.payment_status).not_to eq('paid')
    expect(receivable_balance(order)).to eq(BigDecimal('100000'))
    debit = Spree::Pos::ReceivableEntry.find_by!(order_id: order.id, kind: 'debit')
    expect(debit.due_on).to eq(Time.now.in_time_zone('Asia/Ho_Chi_Minh').to_date + 30)
    expect(account.reload.exposure.reserved).to eq(0)
    expect(account.exposure.open_debt).to eq(BigDecimal('100000'))
    expect(Spree::Pos::CreditReservation.find_by!(workspace: sale.workspace).status).to eq('committed')

    Spree::Pos::Orders::Handover.call(workspace: sale.workspace.reload, staff: sale.cashier, key: SecureRandom.uuid)
    level = branch.stock_location.stock_level(sale.product.default_variant).reload
    expect(level.count_on_hand).to eq(9)
    expect(order.reload.payment_status).not_to eq('paid')
    expect { debit.update!(amount: 1) }.to raise_error(ActiveRecord::ReadOnlyRecord)
  end

  it 'refuses credit for a walk-in, without an account, beyond the limit or on a suspended account' do
    sale = credit_sale(store, branch, price: 500_000)
    expect { approve_credit(sale, manager, 500_000) }.to raise_error(Spree::Pos::Conflict, /identified customer/)

    assign(sale, profile)
    expect { approve_credit(sale, manager, 500_000) }.to raise_error(Spree::Pos::Conflict, /no credit account/)

    account = configure_credit(store, manager, branch, profile, limit: 400_000)
    expect { approve_credit(sale, manager, 500_000) }.to raise_error(Spree::Pos::Conflict, /limit/)
    expect { approve_credit(sale, manager, 400_000) }.to raise_error(Spree::Pos::Conflict, /unpaid remainder/)

    account.update!(credit_limit: 1_000_000, status: 'suspended', updated_by: manager)
    expect { approve_credit(sale, manager, 500_000) }.to raise_error(Spree::Pos::Conflict, /suspended/)
    expect(Spree::Pos::CreditReservation.count).to eq(0)
  end

  it 'refuses a self-approval and a requester without the credit capability' do
    self_approver = credit_staff(store, branch, PosCreditHelpers::CASHIER + [Spree::Pos::Capabilities::APPROVE, Spree::Pos::Capabilities::CREDIT_MANAGE])
    sale = credit_sale(store, branch, price: 100_000, cashier: self_approver)
    assign(sale, profile)
    configure_credit(store, manager, branch, profile, limit: 500_000)
    workspace = sale.workspace.reload
    expect do
      Spree::Pos::Credit::Approve.call(workspace: workspace, staff: sale.cashier, key: SecureRandom.uuid,
                                       requester_id: sale.cashier.prefixed_id, amount: '100000', revision: workspace.revision)
    end.to raise_error(Spree::Pos::Conflict, /own credit sale/)

    Spree::Pos::StaffMembership.find_by!(staff: sale.cashier).update!(capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PAYMENT])
    expect { approve_credit(sale, manager, 100_000) }.to raise_error(CanCan::AccessDenied)
  end

  it 'releases the reservation with an audit when the customer changes, and refuses a stale approval at completion' do
    sale = credit_sale(store, branch, price: 300_000)
    assign(sale, profile)
    account = configure_credit(store, manager, branch, profile, limit: 1_000_000)
    first = approve_credit(sale, manager, 300_000)

    other = credit_customer(store, manager, name: 'Anh Binh')
    assign(sale, other)
    reservation = Spree::Pos::CreditReservation.find_by_prefix_id!(first['id'])
    expect(reservation.reload).to have_attributes(status: 'released', released_reason: 'customer_changed')
    expect(reservation.approval.reload.status).to eq('revoked')
    expect(account.reload.exposure.reserved).to eq(0)

    assign(sale, profile)
    second = approve_credit(sale, manager, 300_000)
    expect { complete_on_credit(sale, first['approval_id']) }.to raise_error(Spree::Pos::Conflict, /no longer usable/)

    # An edit after approval moves the revision: the same command releases the
    # reservation with an audit, and completion refuses the dead approval.
    Spree::Pos::Workspaces::UpdateNote.call(**editing_args(sale), note: 'Giao chiều')
    expect(account.reload.exposure.reserved).to eq(0)
    released = Spree::Pos::CreditReservation.find_by_prefix_id!(second['id'])
    expect(released.reload).to have_attributes(status: 'released', released_reason: 'snapshot_changed')
    expect { complete_on_credit(sale, second['approval_id']) }.to raise_error(Spree::Pos::Conflict)
    expect(Spree::Pos::AuditEntry.where(action: 'credit.release', subject_id: sale.workspace.id).count).to eq(2)
    expect(sale.workspace.reload.order).not_to be_placed
    expect(Spree::Pos::ReceivableEntry.count).to eq(0)
  end

  it 'closes an approval that a later payment made unusable, then completes without credit' do
    sale = credit_sale(store, branch, price: 200_000)
    assign(sale, profile)
    account = configure_credit(store, manager, branch, profile, limit: 500_000)
    approve_credit(sale, manager, 200_000)

    take_tender(sale, 'cash', 200_000)
    reservation = Spree::Pos::CreditReservation.sole
    expect(reservation.reload).to have_attributes(status: 'released', released_reason: 'snapshot_changed')
    expect(reservation.approval.reload.status).to eq('revoked')
    Spree::Pos::Workspaces::Complete.call(**editing_args(sale))
    expect(sale.workspace.reload.order).to be_placed
    expect(account.reload.exposure.reserved).to eq(0)
    expect(Spree::Pos::ReceivableEntry.count).to eq(0)
  end

  it 'refuses an approval that expired before completion and records its release' do
    sale = credit_sale(store, branch, price: 100_000)
    assign(sale, profile)
    configure_credit(store, manager, branch, profile, limit: 500_000)
    approval = approve_credit(sale, manager, 100_000)
    Spree::Pos::Approval.find_by_prefix_id!(approval['approval_id']).update_columns(expires_at: 1.minute.ago)

    expect { complete_on_credit(sale, approval['approval_id']) }.to raise_error(Spree::Pos::Conflict, /no longer usable/)
    expect(Spree::Pos::CreditReservation.sole).to have_attributes(status: 'released', released_reason: 'stale_at_completion')
    expect(sale.workspace.reload.order).not_to be_placed
  end

  it 'sweeps expired reservations of untouched drafts from the recovery job' do
    sale = credit_sale(store, branch, price: 100_000)
    assign(sale, profile)
    configure_credit(store, manager, branch, profile, limit: 500_000)
    approval = approve_credit(sale, manager, 100_000)
    Spree::Pos::Approval.find_by_prefix_id!(approval['approval_id']).update_columns(expires_at: 1.minute.ago)

    Spree::Pos::RecoverSettlementJob.perform_now
    expect(Spree::Pos::CreditReservation.sole).to have_attributes(status: 'released', released_reason: 'expired_or_unusable')
    expect(Spree::Pos::AuditEntry.where(action: 'credit.release').count).to eq(1)
  end

  it 'turns a cashier request into an approval once per revision, and lets a later edit make it stale' do
    sale = credit_sale(store, branch, price: 300_000)
    assign(sale, profile)
    configure_credit(store, manager, branch, profile, limit: 1_000_000)

    first = request_credit(sale)
    expect(request_credit(sale)['id']).to eq(first['id'])
    expect(first).to include('status' => 'pending', 'amount' => '300000.0')

    Spree::Pos::Workspaces::UpdateNote.call(**editing_args(sale), note: 'Đổi ghi chú')
    expect(Spree::Pos::CreditRequest.find_by_prefix_id!(first['id']).status).to eq('stale')

    second = Spree::Pos::CreditRequest.find_by_prefix_id!(request_credit(sale)['id'])
    workspace = sale.workspace.reload
    Spree::Pos::Credit::Approve.call(workspace: workspace, staff: manager, key: SecureRandom.uuid,
                                     requester_id: second.requester.prefixed_id, amount: second.amount.to_s('F'),
                                     revision: second.workspace_revision, request: second)
    expect(second.reload).to have_attributes(status: 'approved', decided_by_id: manager.id)
    complete_on_credit(sale, second.credit_reservation.approval.prefixed_id)
    expect(receivable_balance(sale.workspace.order)).to eq(BigDecimal('300000'))

    other = credit_sale(store, branch, price: 100_000)
    assign(other, profile)
    rejected = Spree::Pos::CreditRequest.find_by_prefix_id!(request_credit(other)['id'])
    Spree::Pos::Credit::Reject.call(request: rejected, staff: manager, key: SecureRandom.uuid, reason: 'Khách đang nợ quá hạn')
    expect(rejected.reload).to have_attributes(status: 'rejected', reason: 'Khách đang nợ quá hạn')
    expect(request_credit(other)['status']).to eq('rejected')
  end

  it 'requires both approval and credit management grants to approve' do
    approver = credit_staff(store, branch, [Spree::Pos::Capabilities::APPROVE])
    sale = credit_sale(store, branch, price: 100_000)
    assign(sale, profile)
    configure_credit(store, manager, branch, profile, limit: 500_000)
    expect { approve_credit(sale, approver, 100_000) }.to raise_error(CanCan::AccessDenied)
  end

  it 'never forces a credit handover past a short shelf' do
    configure_credit(store, manager, branch, profile, limit: 500_000)
    sale = credit_order(store, branch, manager, profile, price: 100_000)
    level = branch.stock_location.stock_level(sale.product.default_variant)
    level.update_columns(count_on_hand: 0)

    expect do
      Spree::Pos::Orders::Handover.call(workspace: sale.workspace.reload, staff: sale.cashier, key: SecureRandom.uuid)
    end.to raise_error(Spree::Pos::Conflict, /shelf/)
    expect(level.reload.count_on_hand).to eq(0)
    expect(sale.workspace.order.fulfillments.first).not_to be_fulfilled
  end

  it 'releases exposure when the draft is canceled' do
    sale = credit_sale(store, branch, price: 100_000)
    assign(sale, profile)
    account = configure_credit(store, manager, branch, profile, limit: 100_000)
    approve_credit(sale, manager, 100_000)
    expect(account.reload.exposure.available).to eq(0)

    Spree::Pos::Workspaces::ChangeStatus.call(**editing_args(sale), status: 'canceled')
    expect(account.reload.exposure.available).to eq(BigDecimal('100000'))
    expect(Spree::Pos::CreditReservation.sole.released_reason).to eq('workspace_canceled')
  end
end
