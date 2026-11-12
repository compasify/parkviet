# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../support/pos_timed_helpers'

# Pausing a clock, prepaid packages, free minutes, operating hours and the
# alerts a running clock sends, all on the server's time.
RSpec.describe 'Pauses, packages and free minutes on play time' do
  include PosTimedHelpers
  include ActionCable::TestHelper

  let(:store) { menu_store }
  let(:branch) { timed_branch(store) }
  let(:operator) { credit_staff(store, branch, PosTimedHelpers::OPERATOR) }
  let(:manager) { credit_staff(store, branch, [Spree::Pos::Capabilities::APPROVE]) }
  let(:area) { area!(branch) }
  let(:service) { time_service!(store, branch) }
  let(:room) { room!(area, name: 'P1', type: 'room') }
  let!(:plan) { rate_plan!(branch, variant: service, type: 'room') }

  before { table_register!(branch, operator) }

  after { travel_back }

  def pause(session, staff = operator, key: SecureRandom.uuid)
    Spree::Pos::Timed::Pause.call(session: session.reload, staff: staff, key: key)
  end

  def resume(session, staff = operator, approval_id: nil)
    Spree::Pos::Timed::Resume.call(session: session.reload, staff: staff, key: SecureRandom.uuid, approval_id: approval_id)
  end

  def bands(session)
    session.reload.timed_quote_lines.map { |line| [line.kind, line.minutes, line.amount.to_i] }
  end

  def long_pause_approval(session, requester)
    workspace = session.workspace.reload
    Spree::Pos::Approval.create!(store: store, branch: branch, approver: manager, requester: requester,
                                 subject_type: 'Spree::Pos::Workspace', subject_id: workspace.id,
                                 action: Spree::Pos::Approval::TIMED_LONG_PAUSE_ACTION, revision: workspace.revision.to_s,
                                 expires_at: 10.minutes.from_now, status: 'active')
  end

  def messages
    broadcasts(Spree::Pos::Realtime.stream_name(branch)).map { |raw| JSON.parse(raw) }
  end

  describe 'pausing' do
    it 'bills 19:00 to 21:00 with a pause from 20:00 to 20:15 as 105 minutes' do
      clock_at('2026-11-12 19:00')
      session = session_of(start_clock(operator, room))
      clock_at('2026-11-12 20:00')
      key = SecureRandom.uuid
      first = pause(session, key: key)
      again = pause(session, key: key)
      expect(again).to eq(first)
      expect(session.reload).to have_attributes(status: 'paused', paused_since: local('2026-11-12 20:00'))
      expect(Spree::Pos::AuditEntry.where(action: 'timed.pause').count).to eq(1)
      expect { pause(session) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('timed_session_paused') }

      clock_at('2026-11-12 20:15')
      result = resume(session)
      expect(result.dig('timed_session', 'status')).to eq('running')
      expect(session.reload.timed_segments.map { |segment| [segment.kind, segment.ended_reason] }).
        to eq([%w[play pause], %w[pause resume], ['play', nil]])

      clock_at('2026-11-12 21:00')
      stop_clock(session, operator)
      # 105 minutes in the evening band at 150 000 an hour.
      expect(session.reload).to have_attributes(played_minutes: 105, billed_minutes: 105, amount: 262_500)
      expect(session.timed_segments.last.ended_reason).to eq('stop')
    end

    it 'needs an approval to end a pause longer than the branch allows' do
      clock_at('2026-11-12 19:00')
      session = session_of(start_clock(operator, room))
      clock_at('2026-11-12 20:00')
      pause(session)
      clock_at('2026-11-12 20:20')

      expect { resume(session) }.to raise_error(Spree::Pos::Conflict) { |error|
        expect(error.reason).to eq('approval_required')
        expect(error.details).to include(action: 'timed.long_pause', paused_minutes: 20, max_pause_minutes: 15)
      }
      expect { stop_clock(session, operator) }.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('approval_required') }

      approval = long_pause_approval(session, operator)
      resume(session, approval_id: approval.prefixed_id)
      expect(approval.reload.status).to eq('consumed')
      audit = Spree::Pos::AuditEntry.where(action: 'timed.resume').sole
      expect(audit.metadata).to include('paused_minutes' => 20)

      editor = credit_staff(store, branch, PosTimedHelpers::OPERATOR + [Spree::Pos::Capabilities::TIMED_EDIT])
      clock_at('2026-11-12 20:30')
      pause(session)
      clock_at('2026-11-12 21:00')
      expect(resume(session, editor).dig('timed_session', 'status')).to eq('running')
    end

    it 'tells the branch once when a pause runs too long' do
      clock_at('2026-11-12 19:00')
      session = session_of(start_clock(operator, room))
      clock_at('2026-11-12 20:00')
      pause(session)
      clock_at('2026-11-12 20:16')
      2.times { Spree::Pos::TimedSessions::AlertJob.perform_now }

      alerts = messages.select { |message| message['alert'] }
      expect(alerts.map { |message| message['alert'] }).to eq(['pause_too_long'])
      expect(alerts.first).to include('event' => 'resource.updated', 'id' => room.prefixed_id)
      expect(Spree::Pos::Timed::Guard.long_pause?(session.reload, Time.current)).to be(true)
    end
  end

  describe 'packages' do
    before do
      plan.update!(packages: [{ 'code' => '2h', 'name' => 'Gói 2 giờ', 'minutes' => 120, 'price' => '250000' }])
    end

    it 'bills a 120-minute package played 135 minutes as the package and 15 minutes more' do
      clock_at('2026-11-12 19:00')
      result = start_clock(operator, room, package_code: '2h')
      session = session_of(result)
      expect(session).to have_attributes(prepaid_minutes: 120, package_name: 'Gói 2 giờ', package_price: 250_000,
                                         planned_end_at: local('2026-11-12 21:00'))
      expect(result.dig('timed_session', 'package')).to eq('name' => 'Gói 2 giờ', 'minutes' => 120, 'price' => '250000.0')

      clock_at('2026-11-12 20:50')
      2.times { Spree::Pos::TimedSessions::AlertJob.perform_now }
      expect(messages.filter_map { |message| message['alert'] }).to eq(['ending_soon'])
      expect(session.reload.played_seconds(Time.current)).to eq(110 * 60)

      clock_at('2026-11-12 21:01')
      Spree::Pos::TimedSessions::AlertJob.perform_now
      expect(messages.filter_map { |message| message['alert'] }).to eq(%w[ending_soon ended_package])

      clock_at('2026-11-12 21:15')
      stop_clock(session, operator)
      expect(session.reload).to have_attributes(played_minutes: 135, billed_minutes: 135, amount: 287_500)
      expect(bands(session)).to eq([['package', 120, 250_000], ['rate', 15, 37_500]])
      expect(session.sale_line.reload.line_item.amount).to eq(287_500)
    end

    it 'bills the whole package when the guests leave early and keeps the end after a pause' do
      clock_at('2026-11-12 19:00')
      session = session_of(start_clock(operator, room, package_code: '2h'))
      clock_at('2026-11-12 19:30')
      pause(session)
      clock_at('2026-11-12 19:40')
      resume(session)
      # Ten minutes paused move the package's end ten minutes later.
      expect(session.reload.planned_end_at).to eq(local('2026-11-12 21:10'))

      clock_at('2026-11-12 20:00')
      stop_clock(session, operator)
      expect(session.reload).to have_attributes(played_minutes: 50, billed_minutes: 120, amount: 250_000)
      expect(bands(session)).to eq([['package', 120, 250_000]])
    end

    it 'refuses a package the plan does not sell' do
      clock_at('2026-11-12 19:00')
      expect { start_clock(operator, room, package_code: '3h') }.
        to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('timed_package_unknown') }
    end
  end

  describe 'free minutes' do
    it 'gives 15 free minutes after 120 played as a bonus line at no price' do
      Spree::Pos::TimedPromotion.create!(store: store, branch: branch, name: 'Hát 2 tặng 15', kind: 'bonus_after',
                                         threshold_minutes: 120, bonus_minutes: 15)
      clock_at('2026-11-12 19:00')
      session = session_of(start_clock(operator, room))
      clock_at('2026-11-12 21:15')
      stop_clock(session, operator)

      expect(session.reload).to have_attributes(played_minutes: 135, billed_minutes: 135, amount: 300_000)
      expect(bands(session)).to eq([['rate', 120, 300_000], ['bonus', 15, 0]])
      expect(session.timed_quote_lines.last.timed_promotion.name).to eq('Hát 2 tặng 15')
      # The invoice still states every hour played.
      expect(session.sale_line.reload.line_item).to have_attributes(quantity: 135, amount: 300_000)
    end

    it 'gives nothing before the threshold or outside its windows' do
      Spree::Pos::TimedPromotion.create!(store: store, branch: branch, name: 'Giờ vàng', kind: 'bonus_after', threshold_minutes: 60,
                                         bonus_minutes: 30, active_windows: [{ 'days' => [1, 2, 3, 4, 5], 'from' => '13:00', 'to' => '17:00' }])
      clock_at('2026-11-12 19:00')
      session = session_of(start_clock(operator, room))
      clock_at('2026-11-12 20:30')
      stop_clock(session, operator)

      expect(bands(session).map(&:first)).to eq(['rate'])
    end
  end

  describe 'operating hours' do
    before { branch.update!(operating_windows: [{ 'days' => (0..6).to_a, 'from' => '08:00', 'to' => '24:00' }]) }

    it 'warns, without refusing, when a clock starts at 0:30' do
      clock_at('2026-11-13 00:30')
      expect(Spree::Pos::ResourceState.for(branch)[:outside_operating_hours]).to be(true)
      result = start_clock(operator, room)

      expect(result['warnings']).to eq(['outside_operating_hours'])
      expect(session_of(result)).to be_active
      audit = Spree::Pos::AuditEntry.where(action: 'timed.start').sole
      expect(audit.metadata['warnings']).to eq(['outside_operating_hours'])
    end

    it 'starts quietly inside the hours' do
      clock_at('2026-11-12 10:00')
      expect(Spree::Pos::ResourceState.for(branch)[:outside_operating_hours]).to be(false)
      expect(start_clock(operator, room)['warnings']).to eq([])
    end
  end

  describe Spree::Pos::Timed::SaveSettings do
    let(:owner) { credit_staff(store, branch, [Spree::Pos::Capabilities::RATE_PLAN_MANAGE]) }

    it 'keeps valid windows and the longest pause, and refuses the rest' do
      result = described_class.call(store: store, staff: owner, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                                    operating_windows: [{ 'days' => %w[6 0], 'from' => '18:00', 'to' => '02:00' }], max_pause_minutes: 30)

      expect(result).to include('max_pause_minutes' => 30)
      expect(branch.reload).to have_attributes(max_pause_minutes: 30,
                                               operating_windows: [{ 'days' => [0, 6], 'from' => '18:00', 'to' => '02:00' }])
      # Saturday 01:00 belongs to Friday night, which is closed; Sunday 01:00 to Saturday night.
      expect(Spree::Pos::OperatingHours.check(branch, local('2026-11-14 01:00'))).to eq('outside_operating_hours')
      expect(Spree::Pos::OperatingHours.check(branch, local('2026-11-15 01:00'))).to be_nil

      expect do
        described_class.call(store: store, staff: owner, key: SecureRandom.uuid, branch_id: branch.prefixed_id,
                             operating_windows: [{ 'days' => [7], 'from' => '08:00', 'to' => '22:00' }])
      end.to raise_error(Spree::Pos::Conflict) { |error| expect(error.reason).to eq('operating_windows_invalid') }
      expect do
        described_class.call(store: store, staff: operator, key: SecureRandom.uuid, branch_id: branch.prefixed_id, max_pause_minutes: 20)
      end.to raise_error(CanCan::AccessDenied)
    end
  end
end
