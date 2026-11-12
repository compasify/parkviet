# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_timed_helpers'

# The clock of a karaoke room or billiard table on the server's time:
# starting opens the room's order and a timed line, stopping bills it,
# moving rooms splits the price, and correcting a stretch's times takes a
# manager's approval and is audited.
RSpec.describe 'Clocks of rooms and billiard tables' do
  include PosTimedHelpers

  let(:store) { menu_store }
  let(:branch) { timed_branch(store) }
  let(:operator) { credit_staff(store, branch, PosTimedHelpers::OPERATOR) }
  let(:area) { area!(branch) }
  let(:service) { time_service!(store, branch) }
  let(:room) { room!(area, name: 'P1', type: 'room') }
  let(:vip) { room!(area, name: 'VIP 1', type: 'vip', x: 4) }
  let(:editor_id) { SecureRandom.uuid }

  before do
    table_register!(branch, operator)
    rate_plan!(branch, variant: service, type: 'room')
    rate_plan!(branch, variant: service, type: 'vip', day: 200_000, evening: 300_000, weekend: 400_000)
  end

  after { travel_back }

  def timed_line(session)
    session.reload.sale_line.reload
  end

  describe Spree::Pos::Timed::Start do
    it 'opens a timed order on the room with a running clock and a line at no price' do
      clock_at('2026-11-12 10:00')
      result = start_clock(operator, room, editor_id: editor_id, planned_end_at: local('2026-11-12 12:00').iso8601)
      session = session_of(result)

      expect(session).to have_attributes(status: 'running', resource_id: room.id, started_at: Time.current, started_by_id: operator.id)
      expect(session.workspace).to have_attributes(service_mode: 'timed', resource_id: room.id)
      expect(session.timed_segments.sole).to have_attributes(kind: 'play', rate_plan_id: Spree::Pos::RatePlan.active_for(room).id)
      line = timed_line(session)
      expect(line).to have_attributes(kind: 'timed', sale_unit_code: 'gio', base_unit_code: 'phut', base_quantity: 1)
      expect(line.line_item.amount).to eq(0)
      expect(result.dig('workspace', 'line_items', 0, 'timed_session', 'status')).to eq('running')
      expect(Spree::Pos::AuditEntry.where(action: 'timed.start', subject_id: session.workspace_id).count).to eq(1)
    end

    it 'joins the room order when guests are already seated' do
      order = open_table(operator, room)
      clock_at(Time.current)
      session = session_of(start_clock(operator, room))

      expect(session.workspace).to eq(order.workspace)
    end

    it 'runs one clock per room and needs a rate plan' do
      clock_at('2026-11-12 10:00')
      start_clock(operator, room)

      expect { start_clock(operator, room) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('timed_session_running') }
      bare = room!(area, name: 'B1', type: 'billiard', kind: 'billiard', x: 8)
      expect { start_clock(operator, bare) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('rate_plan_missing') }
    end

    it 'replays the same key as the same clock' do
      clock_at('2026-11-12 10:00')
      key = SecureRandom.uuid
      first = start_clock(operator, room, key: key, editor_id: editor_id)
      again = start_clock(operator, room, key: key, editor_id: editor_id)

      expect(again['timed_session']['id']).to eq(first['timed_session']['id'])
      expect(Spree::Pos::TimedSession.count).to eq(1)
    end

    it 'needs the play time capability and the module' do
      waiter = credit_staff(store, branch, PosTableHelpers::WAITER)
      clock_at('2026-11-12 10:00')
      expect { start_clock(waiter, room) }.to raise_error(CanCan::AccessDenied)

      set_pos_module(branch, 'timed_billing', false)
      expect { start_clock(operator, room) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('module_disabled') }
    end
  end

  describe Spree::Pos::Timed::Stop do
    it 'bills the minutes played on the server clock as the timed line' do
      clock_at('2026-11-12 17:30')
      session = session_of(start_clock(operator, room))
      clock_at('2026-11-12 18:36')
      result = stop_clock(session, operator)

      session.reload
      # 66 minutes played round up to 75: 30 day minutes, 45 evening minutes.
      expect(session).to have_attributes(status: 'stopped', played_minutes: 66, billed_minutes: 75, amount: 162_500)
      expect(session.timed_quote_lines.map { |row| [row.label, row.minutes, row.amount.to_i] }).to eq([['Ngày', 30, 50_000], ['Tối', 45, 112_500]])
      line = timed_line(session)
      expect(line).to have_attributes(base_quantity: 75, sale_quantity: BigDecimal('1.25'), unit_price: 130_000)
      expect(line.line_item.reload.amount).to eq(162_500)
      expect(session.workspace.order.reload.item_total).to eq(162_500)
      expect(result.dig('timed_session', 'quote', 'final')).to be(true)
    end

    it 'leaves a stopped clock as it is' do
      clock_at('2026-11-12 10:00')
      session = session_of(start_clock(operator, room))
      clock_at('2026-11-12 11:00')
      stop_clock(session, operator)
      clock_at('2026-11-12 12:00')
      stop_clock(session, operator)

      expect(session.reload).to have_attributes(billed_minutes: 60, amount: 100_000)
    end

    it 'keeps payment away until the clock stops' do
      clock_at('2026-11-12 10:00')
      result = start_clock(operator, room, editor_id: editor_id)
      session = session_of(result)
      order = order_of(session, operator, editor_id)

      expect { prepare_cash(order, 10_000) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('timed_session_running') }
      clock_at('2026-11-12 10:30')
      stop_clock(session, operator)
      order = order_of(session, operator, editor_id)
      take_tender(order, 'cash', 50_000)
      Spree::Pos::Workspaces::Complete.call(**editing_args(order))

      expect(session.workspace.reload.operational_status).to eq('completed')
      expect(session.workspace.order.reload.total).to eq(50_000)
    end
  end

  it 'changes the timed line only through its clock' do
    clock_at('2026-11-12 10:00')
    session = session_of(start_clock(operator, room, editor_id: editor_id))
    order = order_of(session, operator, editor_id)
    line = timed_line(session)

    expect { Spree::Pos::Workspaces::ManageLineItem.remove(**editing_args(order), sale_line_id: line.prefixed_id) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('timed_line') }
    expect { Spree::Pos::Workspaces::ManageLineItem.update_quantity(**editing_args(order), sale_line_id: line.prefixed_id, quantity: 5) }.
      to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('timed_line') }
  end

  it 'stops the clock when the order is canceled' do
    clock_at('2026-11-12 10:00')
    session = session_of(start_clock(operator, room, editor_id: editor_id))
    clock_at('2026-11-12 10:20')
    workspace = order_of(session, operator, editor_id).workspace
    Spree::Pos::Workspaces::ChangeStatus.call(workspace: workspace, staff: operator, status: 'canceled', revision: workspace.revision,
                                              lease_generation: workspace.lease_generation, key: SecureRandom.uuid, editor_id: editor_id)

    expect(session.reload).to have_attributes(status: 'stopped', played_minutes: 20)
    expect(Spree::Pos::TimedSession.active.exists?(resource_id: room.id)).to be(false)
  end

  describe Spree::Pos::Timed::MoveResource do
    it 'prices the time before the move at the old room and after at the new one' do
      clock_at('2026-11-12 10:00')
      session = session_of(start_clock(operator, room, editor_id: editor_id))
      clock_at('2026-11-12 10:30')
      described_class.call(session: session.reload, staff: operator, key: SecureRandom.uuid, resource_id: vip.prefixed_id)

      expect(session.reload.resource).to eq(vip)
      expect(session.workspace.reload.resource).to eq(vip)
      expect(session.timed_segments.map { |row| [row.resource_id, row.ended_at.present?] }).to eq([[room.id, true], [vip.id, false]])
      clock_at('2026-11-12 11:00')
      stop_clock(session, operator)

      # 30 minutes at 100 000 an hour, 30 at 200 000.
      expect(session.reload.timed_quote_lines.map { |row| [row.minutes, row.amount.to_i] }).to eq([[30, 50_000], [30, 100_000]])
      expect(session.amount).to eq(150_000)
      expect(Spree::Pos::AuditEntry.where(action: 'timed.move', subject_id: session.workspace_id).count).to eq(1)
    end

    it 'refuses a room with another order or no plan' do
      clock_at('2026-11-12 10:00')
      session = session_of(start_clock(operator, room))
      open_table(operator, vip)

      expect { described_class.call(session: session.reload, staff: operator, key: SecureRandom.uuid, resource_id: vip.prefixed_id) }.
        to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('table_occupied') }
      bare = room!(area, name: 'B1', type: 'billiard', kind: 'billiard', x: 8)
      expect { described_class.call(session: session.reload, staff: operator, key: SecureRandom.uuid, resource_id: bare.prefixed_id) }.
        to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('rate_plan_missing') }
    end

    it 'follows a table move of the order' do
      clock_at('2026-11-12 10:00')
      session = session_of(start_clock(operator, room, editor_id: editor_id))
      clock_at('2026-11-12 10:15')
      order = order_of(session, operator, editor_id)
      Spree::Pos::Tables::Move.call(**editing_args(order), resource_id: vip.prefixed_id)

      expect(session.reload.resource).to eq(vip)
      expect(session.timed_segments.count).to eq(2)
    end
  end

  describe Spree::Pos::Timed::EditSegment do
    let(:manager) { credit_staff(store, branch, [Spree::Pos::Capabilities::APPROVE]) }

    def edit(session, staff, approval_id: nil, **times)
      segment = session.reload.timed_segments.first
      described_class.call(session: session, staff: staff, key: SecureRandom.uuid, segment_id: segment.prefixed_id,
                           reason: 'Bật giờ trễ', approval_id: approval_id, **times.transform_values(&:iso8601))
    end

    def approval_for(session, requester)
      workspace = session.workspace.reload
      Spree::Pos::Approval.create!(store: store, branch: branch, approver: manager, requester: requester,
                                   subject_type: 'Spree::Pos::Workspace', subject_id: workspace.id,
                                   action: Spree::Pos::Approval::TIMED_EDIT_ACTION, revision: workspace.revision.to_s,
                                   expires_at: 10.minutes.from_now, status: 'active')
    end

    it 'needs an approval, refuses future times, and bills a stopped clock again' do
      clock_at('2026-11-12 10:00')
      session = session_of(start_clock(operator, room))
      clock_at('2026-11-12 11:00')
      stop_clock(session, operator)

      expect { edit(session, operator, started_at: local('2026-11-12 09:30')) }.to raise_error(Spree::Pos::Conflict)
      expect { edit(session, operator, ended_at: local('2026-11-12 12:00')) }.
        to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('time_in_future') }

      approval = approval_for(session, operator)
      edit(session, operator, approval_id: approval.prefixed_id, started_at: local('2026-11-12 09:30'))

      expect(session.reload).to have_attributes(billed_minutes: 90, amount: 150_000)
      expect(session.timed_segments.first.edited).to be(true)
      expect(timed_line(session).line_item.reload.amount).to eq(150_000)
      audit = Spree::Pos::AuditEntry.where(action: 'timed.edit_segment', subject_id: session.workspace_id).sole
      expect(audit.metadata).to include('reason' => 'Bật giờ trễ', 'approval_id' => approval.prefixed_id)
      expect(approval.reload.status).to eq('consumed')
    end

    it 'lets a person with the edit capability correct a running clock' do
      editor = credit_staff(store, branch, PosTimedHelpers::OPERATOR + [Spree::Pos::Capabilities::TIMED_EDIT])
      clock_at('2026-11-12 10:00')
      session = session_of(start_clock(operator, room))
      clock_at('2026-11-12 10:30')
      result = edit(session, editor, started_at: local('2026-11-12 10:10'))

      expect(result.dig('timed_session', 'quote', 'played_minutes')).to eq(20)
      expect(session.reload.started_at).to eq(local('2026-11-12 10:10'))
    end
  end
end
