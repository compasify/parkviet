# frozen_string_literal: true

require 'timeout'

# Committed-row races over two real database connections. Groups that include
# this context run outside the transactional fixture and afterwards delete
# exactly the rows created during the example.
RSpec.shared_context 'with committed POS race rows' do
  self.use_transactional_tests = false

  let(:store) { Spree::Store.default }

  def connection
    ActiveRecord::Base.connection
  end

  def id_tables
    connection.tables.select { |table| connection.columns(table).any? { |column| column.name == 'id' && column.type == :integer } }
  end

  before do
    raise 'Committed setup needs the test database' unless Rails.env.test?
    raise 'Expected a persisted default store' unless store.persisted?

    @high_water = id_tables.to_h do |table|
      [table, connection.select_value("SELECT COALESCE(MAX(id), 0) FROM #{connection.quote_table_name(table)}").to_i]
    end
  end

  after do
    connection.transaction do
      connection.execute('SET LOCAL session_replication_role = replica')
      @high_water&.each do |table, max_id|
        connection.execute("DELETE FROM #{connection.quote_table_name(table)} WHERE id > #{max_id}")
      end
    end
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
