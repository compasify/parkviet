# frozen_string_literal: true

require 'json'
require 'timeout'

# Rows committed outside the transactional fixture are visible to every process
# that shares the test database, and nothing rolls them back. Every example
# that commits holds one cross-process advisory lock from setup to cleanup, so
# two such examples never overlap and "every id above the marks taken at setup"
# is exactly this example's rows. The marks are also written to disk until the
# cleanup succeeds, so the next example removes what a killed run or a failed
# cleanup left behind.
module PosCommittedRows
  LOCK_KEY = 7_340_045_101 # arbitrary, shared by every committed-row example
  MARKS_PATH = Rails.root.join('tmp/pos_committed_rows_marks.json')
  # Another process's open transaction can hold a lock on a committed row (or
  # deadlock with the cleanup); wait for it and try again rather than leaving
  # the rows behind.
  RETRYABLE = [ActiveRecord::Deadlocked, ActiveRecord::LockWaitTimeout].freeze
  ATTEMPTS = 5

  module_function

  def acquire(connection)
    raise 'Committed setup needs the test database' unless Rails.env.test?

    connection.execute("SELECT pg_advisory_lock(#{LOCK_KEY})")
    purge(connection, JSON.parse(MARKS_PATH.read)) if MARKS_PATH.exist?
    marks = id_tables(connection).to_h do |table|
      [table, connection.select_value("SELECT COALESCE(MAX(id), 0) FROM #{connection.quote_table_name(table)}").to_i]
    end
    MARKS_PATH.write(JSON.generate(marks))
    marks
  end

  def release(connection, marks)
    if marks
      purge(connection, marks)
      MARKS_PATH.delete
    end
  ensure
    connection.execute("SELECT pg_advisory_unlock(#{LOCK_KEY})")
  end

  def id_tables(connection)
    connection.tables.select { |table| connection.columns(table).any? { |column| column.name == 'id' && column.type == :integer } }
  end

  # One transaction, so foreign keys never see half the rows gone; retried
  # whole when another process's lock aborts it.
  def purge(connection, marks)
    attempt = 0
    begin
      attempt += 1
      connection.transaction do
        connection.execute('SET LOCAL session_replication_role = replica')
        connection.execute("SET LOCAL lock_timeout = '10s'")
        marks.each do |table, max_id|
          next unless connection.table_exists?(table)

          connection.execute("DELETE FROM #{connection.quote_table_name(table)} WHERE id > #{Integer(max_id)}")
        end
      end
    rescue *RETRYABLE
      raise if attempt >= ATTEMPTS

      sleep(0.5 * attempt)
      retry
    end
  end
end

# Committed rows for one example, removed afterwards even when the example or
# its setup fails.
RSpec.shared_context 'with committed POS rows' do
  self.use_transactional_tests = false

  before do
    @committed_marks = PosCommittedRows.acquire(ActiveRecord::Base.connection)
  end

  after do
    PosCommittedRows.release(ActiveRecord::Base.connection, @committed_marks)
  end
end

# Committed-row races over two real database connections.
RSpec.shared_context 'with committed POS race rows' do
  include_context 'with committed POS rows'

  let(:store) { Spree::Store.default }

  def connection
    ActiveRecord::Base.connection
  end

  before do
    raise 'Expected a persisted default store' unless store.persisted?
  end

  # Holds `row` locked until both contenders are provably waiting on the
  # database, then releases them and returns each contender's outcome.
  def race(row, &block)
    ready = Queue.new
    outcomes = Queue.new
    threads = []
    blocked = false
    begin
      row.with_lock do
        threads = 2.times.map do |index|
          Thread.new do
            ActiveRecord::Base.connection_pool.with_connection do |thread_connection|
              ready << thread_connection.select_value('SELECT pg_backend_pid()').to_i
              outcomes << [:success, block.call(index)]
            rescue Spree::Pos::Conflict => e
              outcomes << [:conflict, e.message]
            rescue StandardError => e
              outcomes << [:error, "#{e.class}: #{e.message}"]
            end
          end
        end
        pids = Timeout.timeout(15) { 2.times.map { ready.pop } }
        raise 'Contenders shared one database connection' unless pids.uniq.length == 2

        Timeout.timeout(15) do
          loop do
            connection.execute('SELECT pg_stat_clear_snapshot()')
            waiting = connection.select_value(
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
end
