# frozen_string_literal: true

require 'timeout'
require_relative '../../../support/pos_race_helpers'

# Two database connections race to open a shift on the same drawer. Rows must be
# committed for the second connection to see them, so this group runs outside the
# transactional fixture and deletes exactly the records it created.
RSpec.describe 'POS open shift race', type: :integration do
  include_context 'with committed POS rows'

  let(:store) { Spree::Store.default }

  before do
    raise 'Committed setup needs the test database' unless Rails.env.test?
    raise 'Expected a persisted default store' unless store.persisted?

    @location = Spree::StockLocation.create!(
      store: store, name: "Race #{SecureRandom.hex(4)}", address1: '1 Race St', city: 'HCM',
      zipcode: '70000', country_code: 'VN', active: true, backorderable_default: false, propagate_all_variants: false
    )
    @branch = Spree::Pos::Branch.create!(
      store: store, stock_location: @location, name: 'Race', code: "race#{SecureRandom.hex(3)}",
      timezone: 'Asia/Ho_Chi_Minh', status: 'active'
    )
    @register = Spree::Pos::Register.create!(store: store, branch: @branch, name: 'Race', code: "rq#{SecureRandom.hex(3)}", status: 'active')
    @staff = 2.times.map do
      Spree.admin_user_class.create!(email: "race-#{SecureRandom.hex(6)}@example.test", password: 'secret123', password_confirmation: 'secret123')
    end
    @staff.each do |member|
      Spree::Pos::StaffMembership.create!(
        store: store, branch: @branch, staff: member,
        capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT], status: 'active'
      )
    end
  end

  def race(&block)
    ready = Queue.new
    outcomes = Queue.new
    threads = []
    blocked = false
    begin
      # Hold the drawer row so both contenders are provably waiting at the same time.
      @register.with_lock do
        threads = 2.times.map do |index|
          Thread.new do
            ActiveRecord::Base.connection_pool.with_connection do |connection|
              ready << connection.select_value('SELECT pg_backend_pid()').to_i
              outcomes << [:success, block.call(index).id]
            rescue Spree::Pos::Conflict
              outcomes << [:conflict, nil]
            rescue StandardError => e
              outcomes << [:error, "#{e.class}: #{e.message}"]
            end
          end
        end
        pids = Timeout.timeout(15) { 2.times.map { ready.pop } }
        raise 'Contenders shared one database connection' unless pids.uniq.length == 2

        Timeout.timeout(15) do
          loop do
            ActiveRecord::Base.connection.execute('SELECT pg_stat_clear_snapshot()')
            waiting = ActiveRecord::Base.connection.select_value(
              "SELECT count(*) FROM pg_stat_activity WHERE pid IN (#{pids.join(',')}) AND cardinality(pg_blocking_pids(pid)) > 0"
            ).to_i
            break if waiting == 2

            sleep 0.05
          end
        end
        blocked = true
      end
    ensure
      threads.each { |thread| thread.join(20) }
    end
    expect(blocked).to be(true)
    expect(threads).to all(satisfy { |thread| !thread.alive? })
    Timeout.timeout(5) { 2.times.map { outcomes.pop } }
  end

  it 'opens exactly one shift when two connections open the same drawer at once' do
    results = race do |index|
      Spree::Pos::Shifts::Open.call(store: store, staff: @staff[index], register: @register, opening_float: "#{index + 1}00")
    end

    expect(results.map(&:first)).to contain_exactly(:success, :conflict)
    shifts = Spree::Pos::Shift.where(register_id: @register.id)
    expect(shifts.count).to eq(1)
    expect(shifts.first.id).to eq(results.assoc(:success)[1])
    expect([BigDecimal('100'), BigDecimal('200')]).to include(shifts.first.opening_float)
    expect(Spree::Pos::AuditEntry.where(subject_type: Spree::Pos::Shift.name, subject_id: shifts.select(:id), action: 'shift.open').count).to eq(1)
  end

  it 'lets the database refuse a second open shift even without the application lock' do
    attributes = lambda do |member|
      {
        store_id: store.id, branch_id: @branch.id, register_id: @register.id, owner_id: member.id,
        opening_float: 0, currency: store.default_currency, status: 'open', opened_at: Time.current
      }
    end
    first_inserted = Queue.new
    release_first = Queue.new
    second_pid = Queue.new
    second_outcome = Queue.new

    first = Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do
        ActiveRecord::Base.transaction do
          Spree::Pos::Shift.new(attributes.call(@staff[0])).save!(validate: false)
          first_inserted << true
          release_first.pop
        end
      end
    end
    Timeout.timeout(15) { first_inserted.pop }

    second = Thread.new do
      ActiveRecord::Base.connection_pool.with_connection do |connection|
        second_pid << connection.select_value('SELECT pg_backend_pid()').to_i
        Spree::Pos::Shift.new(attributes.call(@staff[1])).save!(validate: false)
        second_outcome << :inserted
      rescue ActiveRecord::RecordNotUnique
        second_outcome << :refused
      rescue StandardError => e
        second_outcome << "#{e.class}: #{e.message}"
      end
    end

    begin
      pid = Timeout.timeout(15) { second_pid.pop }
      # The second insert must be waiting on the uncommitted first row, not running after it.
      Timeout.timeout(15) do
        loop do
          ActiveRecord::Base.connection.execute('SELECT pg_stat_clear_snapshot()')
          waiting = ActiveRecord::Base.connection.select_value(
            "SELECT cardinality(pg_blocking_pids(#{pid}))"
          ).to_i
          break if waiting.positive?

          sleep 0.05
        end
      end
    ensure
      release_first << true
      [first, second].each { |thread| thread.join(20) }
    end

    expect(Timeout.timeout(5) { second_outcome.pop }).to eq(:refused)
    expect(Spree::Pos::Shift.where(register_id: @register.id, status: 'open').count).to eq(1)
  end
end
