# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_kitchen_helpers'

# Kitchen items move forward one listed step at a time on the database
# clock; repeating a step is harmless, any other move is refused.
RSpec.describe Spree::Pos::Kitchen::ChangeItemStatus do
  include PosKitchenHelpers

  let(:store) { menu_store }
  let(:branch) { kitchen_branch(store, trigger: 'manual') }
  let(:item) { menu_item!(store, branch, name: 'Phở bò', price: 50_000) }
  let(:screen) { kitchen_screen!(branch, Spree::Pos::Device.new_token) }
  let(:sale) { menu_sale(store, branch) }
  let(:ticket) do
    kitchen_station!(branch, name: 'Bếp', default: true)
    add_menu(sale, size(item))
    add_menu(sale, size(item), note: 'Không hành')
    kitchen_send(sale)
    tickets_of(sale).sole
  end
  let(:first) { ticket.items.first }

  def move(row, action)
    described_class.call(item: row, action: action, actor: screen)
    row.reload
  end

  it 'walks an item from new to served and stamps every step' do
    expect(move(first, 'start')).to have_attributes(status: 'preparing', changed_by: screen)
    expect(first.started_at).to be_present
    expect(move(first, 'ready')).to have_attributes(status: 'ready')
    expect(first.ready_at).to be >= first.started_at
    expect(move(first, 'serve')).to have_attributes(status: 'served')
    expect(first.served_at).to be_present
  end

  it 'repeats a step without changing anything and refuses moves that are not listed' do
    move(first, 'start')
    stamp = first.started_at
    expect(move(first, 'start').started_at).to eq(stamp)

    expect { move(first, 'serve') }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('kitchen_status_invalid') }
    expect { move(first, 'recall') }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('kitchen_status_invalid') }
    expect { move(first, 'cook') }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('kitchen_action_invalid') }
    move(first, 'ready')
    move(first, 'serve')
    expect { move(first, 'ready') }.to raise_error(Spree::Pos::Conflict)
  end

  it 'recalls a ready item within 30 minutes only' do
    move(first, 'ready')
    expect(move(first, 'recall')).to have_attributes(status: 'preparing', ready_at: nil)

    move(first, 'ready')
    later = first.ready_at + 31.minutes
    allow(Spree::Pos::Workspace).to receive(:database_now).and_return(later)
    expect { move(first, 'recall') }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('kitchen_recall_expired') }
  end

  it 'bumps every open item of the ticket to ready and announces the ticket' do
    move(first, 'start')
    expect do
      described_class.bump(ticket: ticket, actor: screen)
    end.to have_broadcasted_to(Spree::Pos::Realtime.stream_name(branch)).with(hash_including(event: 'kitchen_ticket.updated', id: ticket.prefixed_id))
    expect(ticket.items.reload.map(&:status)).to eq(%w[ready ready])
    expect(ticket.reload.done?).to be(true)

    expect do
      described_class.bump(ticket: ticket, actor: screen)
    end.not_to have_broadcasted_to(Spree::Pos::Realtime.stream_name(branch))
  end
end
