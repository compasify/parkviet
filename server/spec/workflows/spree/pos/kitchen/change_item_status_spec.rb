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

  it 'calls a served item back, counts it and names a person in the audit log' do
    cook = credit_staff(store, branch, [Spree::Pos::Capabilities::OPERATE_KITCHEN])
    move(first, 'ready')
    move(first, 'serve')
    described_class.call(item: first, action: 'recall', actor: cook)
    expect(first.reload).to have_attributes(status: 'preparing', ready_at: nil, served_at: nil, recall_count: 1, changed_by: cook)
    expect(first.recalled_at).to be_present
    audit = Spree::Pos::AuditEntry.where(action: 'kitchen.recall').sole
    expect(audit).to have_attributes(actor: cook, subject_id: first.id)
    expect(audit.metadata).to include('recall_count' => 1)

    # A kitchen screen is not a person: the item keeps who moved it instead.
    move(first, 'ready')
    expect(move(first, 'recall')).to have_attributes(recall_count: 2, changed_by: screen)
    expect(Spree::Pos::AuditEntry.where(action: 'kitchen.recall').count).to eq(1)
  end

  it 'refuses to recall a served item more than 30 minutes after it went out' do
    move(first, 'ready')
    move(first, 'serve')
    allow(Spree::Pos::Workspace).to receive(:database_now).and_return(first.served_at + 31.minutes)
    expect { move(first, 'recall') }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('kitchen_recall_expired') }
  end

  it 'keeps how long an item took and whether it passed the red threshold' do
    sent = ticket.sent_at
    allow(Spree::Pos::Workspace).to receive(:database_now).and_return(sent + 5.minutes)
    expect(move(first, 'ready')).to have_attributes(prep_seconds: 300, late: false)

    allow(Spree::Pos::Workspace).to receive(:database_now).and_return(sent + 16.minutes)
    second = ticket.items.second
    expect(move(second, 'ready')).to have_attributes(prep_seconds: 960, late: true)

    move(second, 'recall')
    expect(second.reload).to have_attributes(prep_seconds: nil, late: false)
  end

  it 'bumps one dish on the all-day view oldest first, a whole item at a time' do
    soup = size(item)
    kitchen_station!(branch, name: 'Bếp', default: true)
    add_menu(sale, soup, quantity: 2)
    kitchen_send(sale)
    later = menu_sale(store, branch)
    add_menu(later, soup)
    kitchen_send(later)
    old_item = tickets_of(sale).sole.items.sole
    new_item = tickets_of(later).sole.items.sole
    key = Spree::Pos::Kitchen::Board.all_day_key(new_item)
    expect(Spree::Pos::Kitchen::Board.all_day_key(old_item)).to eq(key)
    stations = Spree::Pos::KitchenStation.where(branch_id: branch.id).to_a

    moved = described_class.bump_all_day(stations: stations, key: key, actor: screen)
    expect(moved.map(&:id)).to eq([old_item.kitchen_ticket_id])
    expect(old_item.reload.status).to eq('ready')
    expect(new_item.reload.status).to eq('new')

    described_class.bump_all_day(stations: stations, key: key, actor: screen)
    expect(new_item.reload.status).to eq('ready')
    expect { described_class.bump_all_day(stations: stations, key: key, actor: screen) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('kitchen_all_day_empty') }
    expect { described_class.bump_all_day(stations: stations, key: key, quantity: 0, actor: screen) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('kitchen_all_day_invalid') }
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
