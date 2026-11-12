# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../support/pos_guest_helpers'

# The table code and the guest sessions it opens: one active code per
# table, sessions that end with their order or their time, and one guest
# order per phone and key.
RSpec.describe Spree::Pos::GuestSession, type: :model do
  include PosGuestHelpers
  include ActiveSupport::Testing::TimeHelpers

  let(:store) { menu_store }
  let(:branch) { qr_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosCreditHelpers::CASHIER) }
  let(:table) { table!(area!(branch), name: 'Phòng 2', kind: 'room') }

  before { table_register!(branch, cashier) }

  it 'keeps one active code per table and only the digest of its token' do
    code, token = table_code!(table)
    expect(code.token_digest).to eq(Spree::Pos::TableCode.digest(token))
    expect(Spree::Pos::TableCode.authenticate(token)).to eq(code)

    duplicate = code.dup.tap { |row| row.token_digest = Spree::Pos::TableCode.digest('x' * 22) }
    expect { duplicate.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it 'ends with its order, after four hours and when the code is rotated' do
    order = open_table(cashier, table)
    _, token = table_code!(table)
    session, session_token = guest_session!(token)
    expect(described_class.authenticate(session_token)).to eq([session, nil])
    expect(session.workspace).to eq(order.workspace)

    travel_to(session.expires_at + 1.second) do
      expect(described_class.authenticate(session_token)).to eq([nil, 'session_expired'])
    end

    close_order!(order.workspace)
    expect(described_class.authenticate(session_token).last).to eq('session_expired')

    open_table(cashier, table)
    _, next_token = guest_session!(token)
    table_code!(table)
    expect(described_class.authenticate(next_token).last).to eq('session_expired')
    expect(described_class.authenticate('unknown').last).to eq('session_invalid')
  end

  it 'keeps one guest order per session and key in the database' do
    open_table(cashier, table)
    _, token = table_code!(table)
    session, = guest_session!(token)
    dish = size(menu_item!(store, branch, name: 'Bia', price: 25_000))
    order = submit_guest_order(session, guest_items(dish), key: 'same-key')

    copy = order.dup.tap { |row| row.append_batch_id = SecureRandom.uuid }
    expect { copy.save!(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
