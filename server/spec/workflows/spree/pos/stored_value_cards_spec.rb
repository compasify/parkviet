# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/pos_timed_helpers'

# Prepaid cards of a karaoke or billiard shop. A money card holds money
# received for its holder and pays orders; a minutes card holds play
# minutes, each top-up at its own price per minute, and pays a clock's time
# when it stops. Both are money held, never revenue, until spent.
RSpec.describe 'Prepaid money and minutes cards' do
  include PosTimedHelpers

  let(:store) { menu_store }
  let(:branch) { timed_branch(store) }
  let(:operator) { credit_staff(store, branch, PosTimedHelpers::OPERATOR) }
  let(:manager) { credit_staff(store, branch, PosCreditHelpers::MANAGER) }
  let(:area) { area!(branch) }
  let(:service) { time_service!(store, branch) }
  let(:room) { room!(area, name: 'Bàn 1', type: 'billiard', kind: 'billiard') }

  before do
    table_register!(branch, operator)
    rate_plan!(branch, variant: service, type: 'billiard')
  end

  after { travel_back }

  def sell(kind, amount, token:, minutes: nil, staff: operator, key: SecureRandom.uuid)
    Spree::Pos::StoredValueCards::TopUp.call(store: store, staff: staff, key: key, branch_id: branch.prefixed_id, kind: 'cash',
                                             amount: amount.to_s, card_kind: kind, card_token: token, minutes: minutes,
                                             holder_name: 'Anh Minh')
  end

  def card_of(result)
    Spree::Pos::StoredValueAccount.find_by_prefix_id!(result['card'][:id] || result['card']['id'])
  end

  def card_approval(card, action, amount)
    Spree::Pos::Approval.create!(store: store, branch: branch, approver: manager, requester: operator, action: action,
                                 amount: amount, currency: amount && store.default_currency, revision: card.reload.revision.to_s,
                                 subject_type: card.class.name, subject_id: card.id, status: 'active', expires_at: 10.minutes.from_now)
  end

  describe 'selling' do
    it 'keeps the money as held funds, the card only by its digest, and replays the same key' do
      key = SecureRandom.uuid
      result = nil
      expect { result = sell('minutes', 500_000, token: 'THE-000123', minutes: 600, key: key) }.
        to change(Spree::Payment, :count).by(0).
        and change(Spree::Pos::CashMovement.where(kind: 'receipt'), :count).by(1)
      again = sell('minutes', 500_000, token: 'THE-000123', minutes: 600, key: key)

      card = card_of(result)
      expect(again['card']).to eq(result['card'])
      expect(card).to have_attributes(kind: 'minutes', card_hint: '0123', holder_name: 'Anh Minh', customer_profile_id: nil)
      expect(card.card_digest).not_to include('THE-000123')
      expect(card).to have_attributes(balance: 500_000, minutes_balance: 600)
      expect(Spree::Pos::ReceivedFunds.order(:id).last).to have_attributes(workspace_id: nil, received_net: 500_000)
      expect(result['document']).to be_present
      expect(Spree::Pos::StoredValueAccount.find_card(store, 'THE-000123')).to eq(card)
      expect { sell('money', 100_000, token: 'THE-000123') }.
        to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('stored_value_card_taken') }
    end

    it 'needs the payment capability and the module' do
      waiter = credit_staff(store, branch, PosTableHelpers::WAITER)
      expect { sell('money', 100_000, token: 'MONEY-0001', staff: waiter) }.to raise_error(CanCan::AccessDenied)
      set_pos_module(branch, 'timed_billing', false)
      expect { sell('money', 100_000, token: 'MONEY-0001') }.to raise_error(Spree::Pos::Conflict)
    end
  end

  describe 'minutes cards on a clock' do
    it 'pays 90 minutes of a 600-minute card bought for 500 000 with 75 000 and keeps 510 minutes' do
      card = card_of(sell('minutes', 500_000, token: 'THE-000123', minutes: 600))
      clock_at('2026-11-12 14:00')
      session = session_of(start_clock(operator, room, card_token: 'THE-000123'))
      expect(session.stored_value_account).to eq(card)
      clock_at('2026-11-12 15:30')
      stop_clock(session, operator)

      expect(session.reload).to have_attributes(billed_minutes: 90, amount: 75_000)
      expect(session.timed_quote_lines.map { |line| [line.kind, line.minutes, line.amount.to_i] }).to eq([['card', 90, 75_000]])
      expect(card.reload).to have_attributes(minutes_balance: 510, balance: 425_000)
      workspace = session.workspace
      expect(Spree::Pos::FundsAllocation.where(workspace: workspace).sum(:amount)).to eq(75_000)

      order = order_of(session, operator)
      Spree::Pos::Workspaces::Complete.call(**editing_args(order))
      expect(workspace.order.reload).to be_complete
      expect(Spree::Pos::AuditEntry.where(action: 'stored_value.spend_minutes', subject_id: card.id).count).to eq(1)
    end

    it 'bills the minutes the card does not have at the rate' do
      card = card_of(sell('minutes', 60_000, token: 'THE-000456', minutes: 60))
      clock_at('2026-11-12 14:00')
      session = session_of(start_clock(operator, room))
      Spree::Pos::Timed::ApplyMinutesCard.call(session: session, staff: operator, key: SecureRandom.uuid, card_token: 'THE-000456')
      clock_at('2026-11-12 15:30')
      stop_clock(session, operator)

      # 60 minutes from the card at 1 000 a minute, 30 at 100 000 an hour.
      expect(session.reload.timed_quote_lines.map { |line| [line.kind, line.minutes, line.amount.to_i] }).
        to eq([['card', 60, 60_000], ['rate', 30, 50_000]])
      expect(session.amount).to eq(110_000)
      expect(card.reload).to have_attributes(minutes_balance: 0, balance: 0)
    end

    it 'prices each top-up at its own rate, oldest first' do
      card = card_of(sell('minutes', 60_000, token: 'THE-000789', minutes: 60))
      Spree::Pos::StoredValueCards::TopUp.call(store: store, staff: operator, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                               kind: 'cash', amount: '90000', card_id: card.prefixed_id, minutes: 60)
      clock_at('2026-11-12 14:00')
      session = session_of(start_clock(operator, room, card_token: 'THE-000789'))
      clock_at('2026-11-12 15:30')
      stop_clock(session, operator)

      # 60 minutes at 1 000, then 30 of the 60 bought for 90 000.
      expect(session.reload.amount).to eq(105_000)
      expect(card.reload).to have_attributes(minutes_balance: 30, balance: 45_000)
    end

    it 'refuses an unknown card and a money card' do
      card_of(sell('money', 100_000, token: 'MONEY-0002'))
      clock_at('2026-11-12 14:00')
      expect { start_clock(operator, room, card_token: 'NOPE-0000') }.
        to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('stored_value_card_unknown') }
      expect { start_clock(operator, room, card_token: 'MONEY-0002') }.
        to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('stored_value_card_unknown') }
    end
  end

  describe 'money cards' do
    it 'pays an order from the card under the lease' do
      card = card_of(sell('money', 200_000, token: 'MONEY-0003'))
      clock_at('2026-11-12 14:00')
      session = session_of(start_clock(operator, room))
      clock_at('2026-11-12 15:00')
      stop_clock(session, operator)
      order = order_of(session, operator)

      Spree::Pos::StoredValueCards::Pay.call(**editing_args(order), card_token: 'MONEY-0003')
      Spree::Pos::Workspaces::Complete.call(**editing_args(order))

      expect(order.workspace.order.reload).to be_complete
      expect(card.reload.balance).to eq(100_000)
    end

    it 'refunds and corrects only with an approval' do
      card = card_of(sell('money', 200_000, token: 'MONEY-0004'))
      refund = lambda do |approval_id = nil|
        Spree::Pos::StoredValueCards::Refund.call(store: store, staff: operator, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                  card_id: card.prefixed_id, amount: '50000', approval_id: approval_id)
      end
      expect { refund.call }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('approval_required') }

      approval = card_approval(card, Spree::Pos::Approval::STORED_VALUE_REFUND_ACTION, 50_000)
      result = refund.call(approval.prefixed_id)
      expect(result['payouts'].size).to eq(1)
      expect(card.reload.balance).to eq(150_000)
      expect(approval.reload.status).to eq('consumed')

      adjust = Spree::Pos::Approval::STORED_VALUE_ADJUST_ACTION
      expect do
        Spree::Pos::StoredValueCards::Adjust.call(store: store, staff: operator, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                  card_id: card.prefixed_id, amount: '-10000', note: 'Nhập nhầm')
      end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('approval_required') }
      Spree::Pos::StoredValueCards::Adjust.call(store: store, staff: operator, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                card_id: card.prefixed_id, amount: '-10000', note: 'Nhập nhầm',
                                                approval_id: card_approval(card, adjust, 10_000).prefixed_id)
      expect(card.reload.balance).to eq(140_000)
      expect(Spree::Pos::AuditEntry.where(subject_id: card.id, action: [adjust, Spree::Pos::Approval::STORED_VALUE_REFUND_ACTION]).count).to eq(2)
    end

    it 'pays a minutes card back whole with its minutes' do
      card = card_of(sell('minutes', 500_000, token: 'THE-000999', minutes: 600))
      approval = card_approval(card, Spree::Pos::Approval::STORED_VALUE_REFUND_ACTION, 500_000)
      expect do
        Spree::Pos::StoredValueCards::Refund.call(store: store, staff: operator, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                  card_id: card.prefixed_id, amount: '100000')
      end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('stored_value_amount_invalid') }
      Spree::Pos::StoredValueCards::Refund.call(store: store, staff: operator, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                                card_id: card.prefixed_id, approval_id: approval.prefixed_id)

      expect(card.reload).to have_attributes(balance: 0, minutes_balance: 0)
    end
  end
end
