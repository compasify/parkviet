# frozen_string_literal: true

require_relative '../../../support/pos_timed_helpers'
require_relative '../../../support/pos_race_helpers'

# Two people pressing Start on the same karaoke room at the same moment, on
# real connections: the room's row lock orders them, one clock runs and the
# other is told a clock already runs there. Two stops of one clock bill it once.
RSpec.describe 'POS timed clock race', type: :integration do
  include PosTimedHelpers

  include_context 'with committed POS race rows'

  let(:branch) { timed_branch(store) }
  let(:cashier) { credit_staff(store, branch, PosTimedHelpers::OPERATOR) }
  let(:waiter) { credit_staff(store, branch, PosTimedHelpers::OPERATOR) }
  let(:room) { room!(area!(branch, name: "Tầng #{SecureRandom.hex(2)}"), name: "P#{SecureRandom.hex(2)}", type: 'room') }

  before do
    table_register!(branch, cashier)
    rate_plan!(branch, variant: time_service!(store, branch), type: 'room')
  end

  it 'runs one clock when two people start the same room' do
    outcomes = race(room) do |index|
      start_clock(index.zero? ? waiter : cashier, Spree::Pos::Resource.find(room.id))['timed_session']['id']
    end

    expect(outcomes.map(&:first).sort).to eq(%i[conflict success])
    expect(Spree::Pos::TimedSession.where(resource_id: room.id).count).to eq(1)
    expect(Spree::Pos::Workspace.where(resource_id: room.id).count).to eq(1)
    expect(Spree::Pos::SaleLine.where(kind: 'timed', workspace_id: Spree::Pos::Workspace.where(resource_id: room.id).select(:id)).count).to eq(1)
  end

  it 'bills a clock once when two people stop it' do
    session = session_of(start_clock(cashier, room))

    outcomes = race(session) do |index|
      stop_clock(Spree::Pos::TimedSession.find(session.id), index.zero? ? waiter : cashier)['timed_session']['status']
    end

    expect(outcomes).to eq([[:success, 'stopped'], [:success, 'stopped']])
    expect(Spree::Pos::AuditEntry.where(action: 'timed.stop', subject_id: session.workspace_id).count).to eq(1)
    expect(session.reload.status).to eq('stopped')
  end
end
