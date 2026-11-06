# frozen_string_literal: true

# Opt-in development probe. Creates one additional synthetic draft and leaves it
# for inspection; never deletes data. Run only with the dedicated POS Review fixture.
require 'json'
require 'securerandom'
require 'timeout'

abort 'Development environment required' unless Rails.env.development?
credentials = JSON.parse(File.read(Rails.root.join('pos-live-review-credentials.json')))
tag = credentials.fetch('tag')
abort 'Unexpected fixture identifier' unless tag.match?(/\A[0-9a-f]{10}\z/)
abort 'Unexpected fixture email' unless credentials.fetch('email') == "pos-review-#{tag}@example.test"
staff = Spree.admin_user_class.find_by!(email: credentials.fetch('email'))
register = Spree::Pos::Register.find_by_prefix_id!(credentials.fetch('register_id'))
abort 'Unexpected fixture register' unless register.name == "POS Review #{tag}" && register.branch.name == "POS Review #{tag}"
store = register.store
Spree::Current.store = store
created = Spree::Pos::Workspaces::Create.call(
  store: store, staff: staff, register_id: register.prefixed_id,
  editor_id: SecureRandom.uuid, key: "race-create-#{SecureRandom.uuid}"
)
workspace = Spree::Pos::Workspace.find_by_prefix_id!(created.fetch('id'))
workspace.update!(lease_expires_at: Spree::Pos::Workspace.database_now - 1.second)

ready = Queue.new
outcomes = Queue.new
threads = []
blocked = false
begin
  workspace.with_lock do
    threads = 2.times.map do
      Thread.new do
        ActiveRecord::Base.connection_pool.with_connection do |connection|
          Spree::Current.store = store
          contender = Spree::Pos::Workspace.find(workspace.id)
          ready << connection.select_value('SELECT pg_backend_pid()').to_i
          begin
            result = Spree::Pos::Workspaces::ClaimLease.call(
              workspace: contender, staff: staff, editor_id: SecureRandom.uuid,
              key: "race-claim-#{SecureRandom.uuid}", takeover: false
            )
            outcomes << [:success, result.fetch('lease_generation')]
          rescue Spree::Pos::Conflict
            outcomes << [:conflict, nil]
          rescue StandardError => e
            outcomes << [:error, "#{e.class}: #{e.message}"]
          ensure
            Spree::Current.reset
          end
        end
      end
    end
    pids = Timeout.timeout(15) { 2.times.map { ready.pop } }
    raise 'Contenders did not use separate database connections' unless pids.uniq.length == 2
    Timeout.timeout(15) do
      loop do
        ActiveRecord::Base.connection.execute('SELECT pg_stat_clear_snapshot()')
        count = ActiveRecord::Base.connection.select_value(
          "SELECT count(*) FROM pg_stat_activity WHERE pid IN (#{pids.join(',')}) AND cardinality(pg_blocking_pids(pid)) > 0"
        ).to_i
        break if count == 2

        sleep 0.05
      end
    end
    blocked = true
  end
ensure
  threads.each { |thread| thread.join(20) }
end
raise 'Lease contenders did not both block on the row' unless blocked
raise 'A contender did not finish' if threads.any?(&:alive?)
results = Timeout.timeout(5) { 2.times.map { outcomes.pop } }
raise "Unexpected outcomes: #{results.inspect}" unless results.map(&:first).sort == %i[conflict success]
raise 'Unexpected generation' unless results.assoc(:success)[1] == 2 && workspace.reload.lease_generation == 2
puts "Two distinct PostgreSQL connections blocked on the same workspace row; one claim succeeded and one conflicted (#{created.fetch('id')})."
