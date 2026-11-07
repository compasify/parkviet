# frozen_string_literal: true

require 'timeout'

# Money commands racing over two database connections. Rows must be committed for
# the second connection to see them, so this group runs outside the transactional
# fixture and afterwards deletes exactly the rows created during the example.
RSpec.describe 'POS settlement races', type: :integration do
  self.use_transactional_tests = false

  let(:store) { Spree::Store.default }
  let(:caps) do
    [Spree::Pos::Capabilities::OPEN_SHIFT, Spree::Pos::Capabilities::PAYMENT, Spree::Pos::Capabilities::RESOLVE,
     Spree::Pos::Capabilities::APPROVE]
  end

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
    @editor_id = SecureRandom.uuid
    @location = Spree::StockLocation.create!(
      store: store, name: "Race #{SecureRandom.hex(4)}", address1: '1 Race St', city: 'HCM',
      zipcode: '70000', country_code: 'VN', active: true, backorderable_default: false, propagate_all_variants: false
    )
    @branch = Spree::Pos::Branch.create!(store: store, stock_location: @location, name: 'Race', code: "race#{SecureRandom.hex(3)}",
                                         timezone: 'Asia/Ho_Chi_Minh', status: 'active')
    @cashier = staff
    @manager = staff
    create(:check_payment_method, store: store, name: "Race transfer #{SecureRandom.hex(3)}", active: true)
    register = Spree::Pos::Register.create!(store: store, branch: @branch, name: 'Race', code: "rq#{SecureRandom.hex(3)}", status: 'active')
    Spree::Pos::Shifts::Open.call(store: store, staff: @cashier, register: register, opening_float: '0')
    created = Spree::Pos::Workspaces::Create.call(store: store, staff: @cashier, register_id: register.prefixed_id,
                                                  key: SecureRandom.uuid, editor_id: @editor_id)
    @workspace = Spree::Pos::Workspace.find_by_prefix_id!(created['id'])
    product = create(:product, store: store, status: 'active', name: "Race item #{SecureRandom.hex(3)}")
    product.default_variant.set_price(@workspace.order.currency, 100)
    Spree::Pos::BranchProduct.create!(branch: @branch, product: product)
    @location.restock(product.default_variant, 5)
    Spree::Pos::Workspaces::ManageLineItem.add(workspace: @workspace, staff: @cashier, revision: 0, key: SecureRandom.uuid,
                                               lease_generation: @workspace.lease_generation, editor_id: @editor_id,
                                               variant_id: product.default_variant.prefixed_id, quantity: 1)
    @workspace.reload
  end

  after do
    connection.transaction do
      connection.execute('SET LOCAL session_replication_role = replica')
      @high_water&.each do |table, max_id|
        connection.execute("DELETE FROM #{connection.quote_table_name(table)} WHERE id > #{max_id}")
      end
    end
  end

  def staff
    role = Spree::Role.create!(name: "race-#{SecureRandom.hex(4)}", resource: store,
                               permissions: %w[write_pos_orders write_pos_workspaces write_pos_shifts])
    user = Spree.admin_user_class.create!(email: "race-#{SecureRandom.hex(6)}@example.test", password: 'secret123',
                                          password_confirmation: 'secret123')
    Spree::RoleUser.create!(role: role, user: user)
    Spree::Pos::StaffMembership.create!(store: store, branch: @branch, staff: user, capabilities: caps, status: 'active')
    user
  end

  def prepare(amount, kind: 'cash')
    method_id = Spree::Pos::PaymentMethodResolver.new(store: store).available.find { |row| row.kind == kind }
    method_id = method_id.prefixed_id || "posmethod-#{kind}"
    Spree::Pos::Tenders::Prepare.call(workspace: @workspace.reload, staff: @cashier, revision: @workspace.revision,
                                      lease_generation: @workspace.lease_generation, editor_id: @editor_id,
                                      key: SecureRandom.uuid, payment_method_id: method_id, amount: amount.to_s)
    Spree::Pos::TenderAttempt.where(workspace: @workspace).order(:id).last
  end

  def unsolicited(amount)
    result = Spree::Pos::RecordUnsolicitedFunds.call(
      store: store, staff: @cashier, key: SecureRandom.uuid, branch_id: @branch.prefixed_id,
      shift_id: @workspace.shift.prefixed_id, kind: 'bank_manual', handed_amount: amount.to_s,
      reference: "FT#{SecureRandom.hex(3)}", receiving_account: 'VCB-123'
    )
    Spree::Pos::ReceivedFunds.find_by_prefix_id!(result['id'])
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

  def confirm_cash(attempt, key)
    Spree::Pos::Tenders::Confirm.call(workspace: Spree::Pos::Workspace.find(@workspace.id), staff: @cashier,
                                      revision: @workspace.revision, lease_generation: @workspace.lease_generation,
                                      editor_id: @editor_id, key: key, attempt_id: attempt.prefixed_id,
                                      evidence_kind: 'cash_count', handed_amount: '100')
  end

  it 'records one receipt when the same confirm arrives twice at once' do
    attempt = prepare(100)
    @workspace.reload
    key = SecureRandom.uuid

    results = race(@workspace) { confirm_cash(attempt, key) }

    expect(results.map(&:first)).to eq(%i[success success])
    expect(results[0][1]).to eq(results[1][1])
    expect(Spree::Pos::ReceivedFunds.where(tender_attempt: attempt).count).to eq(1)
    expect(Spree::Pos::CashMovement.where(shift_id: @workspace.shift_id).sum(:amount)).to eq(BigDecimal('100'))
    expect(@workspace.order.reload.payments.completed.count).to eq(1)
  end

  it 'lets only one of two different confirms of one attempt take the money' do
    attempt = prepare(100)
    @workspace.reload

    results = race(@workspace) { confirm_cash(attempt, SecureRandom.uuid) }

    expect(results.map(&:first)).to contain_exactly(:success, :conflict)
    expect(Spree::Pos::ReceivedFunds.where(tender_attempt: attempt).count).to eq(1)
    expect(@workspace.order.reload.payments.completed.count).to eq(1)
  end

  it 'never returns a confirmed payout to available when a cancel races the confirmation' do
    funds = unsolicited(40)
    payout = Spree::Pos::LiabilityPayouts::Request.call(store: store, staff: @cashier, key: SecureRandom.uuid,
                                                        funds_id: funds.prefixed_id, amount: '40',
                                                        beneficiary_name: 'Khach', reason: 'Thua')

    results = race(funds) do |index|
      if index.zero?
        Spree::Pos::LiabilityPayouts::Confirm.call(store: store, staff: @manager, key: SecureRandom.uuid, payout_id: payout['id'],
                                                   evidence_kind: 'bank_manual', reference: 'FT-OUT')
      else
        Spree::Pos::LiabilityPayouts::Resolve.call(store: store, staff: @manager, key: SecureRandom.uuid, payout_id: payout['id'],
                                                   outcome: 'cancel')
      end
    end

    expect(results.map(&:first)).to contain_exactly(:success, :conflict)
    balance = funds.reload.balance
    expect(balance.allocated + balance.payout_reserved + balance.paid_out + balance.available).to eq(funds.received_net)
    status = Spree::Pos::LiabilityPayout.find_by_prefix_id!(payout['id']).status
    expect(balance.paid_out).to eq(status == 'confirmed' ? BigDecimal('40') : 0)
    expect(balance.available).to eq(status == 'confirmed' ? 0 : BigDecimal('40'))
  end

  it 'spends available funds once when a payout races an allocation' do
    funds = unsolicited(100)

    results = race(funds) do |index|
      if index.zero?
        Spree::Pos::LiabilityPayouts::Request.call(store: store, staff: @manager, key: SecureRandom.uuid, funds_id: funds.prefixed_id,
                                                   amount: '100', beneficiary_name: 'Khach', reason: 'Hoan')
      else
        Spree::Pos::Funds::Allocate.call(workspace: Spree::Pos::Workspace.find(@workspace.id), staff: @cashier,
                                         revision: @workspace.revision, lease_generation: @workspace.lease_generation,
                                         editor_id: @editor_id, key: SecureRandom.uuid, funds_id: funds.prefixed_id, amount: '100')
      end
    end

    expect(results.map(&:first)).to contain_exactly(:success, :conflict)
    balance = funds.reload.balance
    expect(balance.available).to eq(0)
    expect(balance.allocated + balance.payout_reserved).to eq(BigDecimal('100'))
  end
end
