# frozen_string_literal: true

require 'timeout'

# Two database connections race on one workspace. Rows must be committed for the
# second connection to see them, so this group runs outside the transactional
# fixture and deletes exactly the records it created.
RSpec.describe 'POS workspace races', type: :integration do
  self.use_transactional_tests = false

  let(:store) { Spree::Store.default }

  before do
    raise 'Committed setup needs the test database' unless Rails.env.test?
    raise 'Expected a persisted default store' unless store.persisted?

    @role = Spree::Role.create!(name: "race-#{SecureRandom.hex(4)}", resource: store, permissions: %w[write_pos_orders write_pos_workspaces])
    @staff = Spree.admin_user_class.create!(email: "race-#{SecureRandom.hex(6)}@example.test", password: 'secret123',
                                            password_confirmation: 'secret123')
    @role_user = Spree::RoleUser.create!(role: @role, user: @staff)
    @location = Spree::StockLocation.create!(
      store: store, name: "Race #{SecureRandom.hex(4)}", address1: '1 Race St', city: 'HCM',
      zipcode: '70000', country_code: 'VN', active: true, backorderable_default: false, propagate_all_variants: false
    )
    @branch = Spree::Pos::Branch.create!(
      store: store, stock_location: @location, name: 'Race', code: "race#{SecureRandom.hex(3)}",
      timezone: 'Asia/Ho_Chi_Minh', status: 'active'
    )
    @register = Spree::Pos::Register.create!(store: store, branch: @branch, name: 'Race', code: "rq#{SecureRandom.hex(3)}", status: 'active')
    Spree::Pos::StaffMembership.create!(
      store: store, branch: @branch, staff: @staff,
      capabilities: [Spree::Pos::Capabilities::OPEN_SHIFT], status: 'active'
    )
    @shift = Spree::Pos::Shifts::Open.call(store: store, staff: @staff, register: @register, opening_float: '0')
  end

  after do
    workspaces = Spree::Pos::Workspace.where(branch_id: @branch&.id)
    order_ids = workspaces.pluck(:order_id) + Spree::Order.where(created_by_id: @staff&.id).pluck(:id)
    shifts = Spree::Pos::Shift.where(branch_id: @branch&.id)
    Spree::Pos::CommandReceipt.where(actor_id: @staff&.id).delete_all
    Spree::Pos::AuditEntry.where(actor_id: @staff&.id).delete_all
    workspaces.delete_all
    Pos::WalkInOrder.where(order_id: order_ids).delete_all
    Spree::Order.where(id: order_ids).find_each(&:destroy!)
    shifts.delete_all
    Spree::Pos::StaffMembership.where(branch_id: @branch&.id).delete_all
    Spree::Pos::Register.where(id: @register&.id).delete_all
    Spree::Pos::Branch.where(id: @branch&.id).delete_all
    Spree::StockLocation.where(id: @location&.id).delete_all
    Spree::RoleUser.where(id: @role_user&.id).delete_all
    Spree::Role.where(id: @role&.id).delete_all
    Spree.admin_user_class.where(id: @staff&.id).delete_all
  end

  # Holds `row` locked until both contenders are provably waiting on the database,
  # then releases them and returns each contender's outcome.
  def race(row, &block)
    ready = Queue.new
    outcomes = Queue.new
    threads = []
    blocked = false
    begin
      row.with_lock do
        threads = 2.times.map do |index|
          Thread.new do
            ActiveRecord::Base.connection_pool.with_connection do |connection|
              ready << connection.select_value('SELECT pg_backend_pid()').to_i
              outcomes << [:success, block.call(index)]
            rescue Spree::Pos::Conflict => e
              outcomes << [:conflict, e.reason]
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

  it 'lets exactly one of two editors claim a free lease' do
    created = Spree::Pos::Workspaces::Create.call(
      store: store, staff: @staff, register_id: @register.prefixed_id, key: SecureRandom.uuid, editor_id: SecureRandom.uuid
    )
    workspace = Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
    workspace.update!(lease_expires_at: Spree::Pos::Workspace.database_now - 1.second)
    editors = 2.times.map { SecureRandom.uuid }

    results = race(workspace) do |index|
      Spree::Pos::Workspaces::ClaimLease.call(
        workspace: Spree::Pos::Workspace.find(workspace.id), staff: @staff, key: SecureRandom.uuid, editor_id: editors[index]
      )
    end

    expect(results.map(&:first)).to contain_exactly(:success, :conflict)
    expect(results.assoc(:conflict)[1]).to eq('lease_busy')
    workspace.reload
    expect(workspace.lease_generation).to eq(2)
    expect(editors.count { |editor| workspace.lease_current?(@staff, editor) }).to eq(1)
    expect(results.assoc(:success)[1]['lease_generation']).to eq(2)
    expect(Spree::Pos::AuditEntry.where(subject_type: workspace.class.name, subject_id: workspace.id, action: 'workspace.lease').count).to eq(1)
  end

  it 'creates one draft when the same create command arrives twice at once' do
    key = SecureRandom.uuid
    editor_id = SecureRandom.uuid

    # Inserting a workspace takes a key-share lock on its shift, so holding the
    # shift makes both requests wait inside their transactions before committing.
    results = race(@shift) do
      Spree::Pos::Workspaces::Create.call(
        store: store, staff: Spree.admin_user_class.find(@staff.id), register_id: @register.prefixed_id, key: key, editor_id: editor_id
      )
    end

    expect(results.map(&:first)).to eq(%i[success success])
    expect(results.map { |outcome| outcome[1]['id'] }.uniq.length).to eq(1)
    expect(Spree::Pos::Workspace.where(branch_id: @branch.id).count).to eq(1)
    expect(Spree::Pos::CommandReceipt.where(actor_id: @staff.id, idempotency_key: key).count).to eq(1)
    expect(Pos::WalkInOrder.where(order_id: Spree::Order.where(created_by_id: @staff.id).select(:id)).count).to eq(1)
  end
end
