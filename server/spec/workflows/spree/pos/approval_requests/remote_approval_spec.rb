# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_return_helpers'

RSpec.describe 'POS remote approval workflows' do
  include PosReturnHelpers

  let(:store) { create(:store, default_currency: 'VND', supported_currencies: 'VND') }
  let(:branch) { credit_branch(store) }
  let(:cashier) { credit_staff(store, branch, [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PAYMENT]) }
  let(:manager) { credit_staff(store, branch, [Spree::Pos::Capabilities::APPROVE]) }
  let(:sale) { open_sale(store, branch, cashier: cashier, product: stocked_product(store, branch, price: 50_000)) }

  def submit(revision, action: 'kitchen.void_sent')
    Spree::Pos::ApprovalRequests::Submit.call(store: store, staff: cashier, key: SecureRandom.uuid, branch: branch, subject: sale.workspace,
                                              action: action, revision: revision, amount: nil, reason: nil)['approval_request']
  end

  it 'cancels the older request when the same action is asked for a newer revision' do
    first = submit(sale.workspace.reload.revision)
    sale.workspace.update!(revision: sale.workspace.revision + 1)
    second = submit(sale.workspace.revision)
    expect(Spree::Pos::ApprovalRequest.find_by_prefix_id!(first['id']).status).to eq('canceled')
    expect(second['status']).to eq('pending')
  end

  it 'announces the granted approval with the order ref the requesting device waits on' do
    request = Spree::Pos::ApprovalRequest.find_by_prefix_id!(submit(sale.workspace.reload.revision)['id'])
    published = []
    allow(Spree::Pos::Realtime).to receive(:publish) { |_branch, event, payload| published << [event, payload] }
    result = Spree::Pos::ApprovalRequests::Grant.call(request: request, staff: manager, key: SecureRandom.uuid)['approval_request']

    grant = published.find { |event, _| event == 'approval.requested' }
    expect(grant[1]).to eq(id: result['approval_id'], refs: { workspace_id: sale.workspace.prefixed_id })
    updated = published.find { |event, _| event == 'approval_request.updated' }
    expect(updated[1][:refs]).to eq(approval_id: result['approval_id'], workspace_id: sale.workspace.prefixed_id)
  end

  it 'refuses an action the remote flow does not carry' do
    expect { submit(sale.workspace.reload.revision, action: 'return.process') }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('approval_action_invalid') }
  end
end
