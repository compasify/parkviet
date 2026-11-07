# frozen_string_literal: true

require 'timeout'
require_relative '../../../support/pos_credit_helpers'
require_relative '../../../support/pos_race_helpers'

# Credit approvals and debt collections racing over two database connections.
# Rows must be committed for the second connection to see them, so this group
# runs outside the transactional fixture and afterwards deletes exactly the
# rows created during the example.
RSpec.describe 'POS credit races', type: :integration do
  include PosCreditHelpers

  include_context 'with committed POS rows'

  let(:store) { Spree::Store.default }

  def connection
    ActiveRecord::Base.connection
  end

  before do
    raise 'Expected a persisted default store' unless store.persisted?

    @branch = credit_branch(store)
    @manager = credit_staff(store, @branch, PosCreditHelpers::MANAGER)
    @profile = credit_customer(store, @manager)
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

  def priced_sale
    sale = credit_sale(store, @branch, price: 100)
    assign(sale, @profile)
    sale
  end

  it 'never lets two counters approve credit past one customer limit' do
    account = configure_credit(store, @manager, @branch, @profile, limit: 150)
    sales = [priced_sale, priced_sale]

    results = race(account) { |index| approve_credit(sales[index], @manager, 100) }

    expect(results.map(&:first)).to contain_exactly(:success, :conflict)
    expect(results.find { |(kind, _)| kind == :conflict }.last).to include('limit')
    expect(account.reload.exposure.reserved).to eq(BigDecimal('100'))
    expect(Spree::Pos::CreditReservation.where(credit_account: account).count).to eq(1)
  end

  # The counter is not blocked: the second handover records the shortfall for
  # reconciliation and leaves its fulfillment allocated instead of forcing the
  # shelf below zero.
  it 'never lets two forced credit handovers take the last unit off the shelf' do
    configure_credit(store, @manager, @branch, @profile, limit: 1_000)
    first = credit_order(store, @branch, @manager, @profile, price: 100)
    second = credit_order(store, @branch, @manager, @profile, price: 100, product: first.product)
    level = @branch.stock_location.stock_level(first.product.default_variant)
    level.update_columns(count_on_hand: 1)
    sales = [first, second]

    results = race(level) do |index|
      Spree::Pos::Orders::Handover.call(workspace: Spree::Pos::Workspace.find(sales[index].workspace.id),
                                        staff: sales[index].cashier, key: SecureRandom.uuid)
    end

    expect(results.map(&:first)).to eq(%i[success success])
    expect(level.reload.count_on_hand).to eq(0)
    gaps = Spree::Pos::StockDiscrepancy.where(order_id: sales.map { |sale| sale.workspace.order_id })
    expect(gaps.count).to eq(1)
    expect(gaps.first).to have_attributes(needed: 1, on_hand: 0, status: 'open')
    expect(Spree::Fulfillment.where(id: gaps.first.fulfillment_id, status: 'fulfilled')).to be_empty
  end

  it 'settles a revoke racing a credit completion one way or the other, never both' do
    account = configure_credit(store, @manager, @branch, @profile, limit: 1_000)
    sale = priced_sale
    approval = approve_credit(sale, @manager, 100)
    approval_row = Spree::Pos::Approval.find_by_prefix_id!(approval['approval_id'])
    workspace = sale.workspace.reload

    results = race(workspace) do |index|
      if index.zero?
        complete_on_credit(sale, approval['approval_id'])
      else
        Spree::Pos::Approvals::Revoke.call(approval: Spree::Pos::Approval.find(approval_row.id), staff: @manager)
      end
    end

    expect(results.map(&:first)).to contain_exactly(:success, :conflict)
    reservation = Spree::Pos::CreditReservation.find_by!(approval_id: approval_row.id)
    debit = Spree::Pos::ReceivableEntry.find_by(order_id: workspace.order_id, kind: 'debit')
    if reservation.status == 'committed'
      expect(debit.amount).to eq(BigDecimal('100'))
      expect(approval_row.reload.status).to eq('consumed')
    else
      expect(reservation.status).to eq('released')
      expect(debit).to be_nil
      expect(workspace.order.reload).not_to be_placed
    end
    expect(account.reload.exposure.reserved).to eq(0)
  end

  it 'never lets two collections allocate more than the open debt of one order' do
    account = configure_credit(store, @manager, @branch, @profile, limit: 1_000)
    sale = priced_sale
    approval = approve_credit(sale, @manager, 100)
    complete_on_credit(sale, approval['approval_id'])
    order = sale.workspace.reload.order
    collectors = [@manager, credit_staff(store, @branch, PosCreditHelpers::CASHIER)]
    collectors.each { |collector| open_drawer(store, @branch, collector) }

    results = race(account) do |index|
      Spree::Pos::Collections::Receive.call(
        store: store, staff: collectors[index],
        key: SecureRandom.uuid, branch_id: @branch.prefixed_id, credit_account_id: account.prefixed_id,
        kind: 'bank_manual', amount: '100', reference: "FT#{index}", receiving_account: 'VCB-123',
        allocations: [{ 'order_id' => order.prefixed_id, 'amount' => '100' }]
      )
    end

    expect(results.map(&:first)).to contain_exactly(:success, :conflict)
    expect(receivable_balance(order)).to eq(0)
    expect(order.reload.payments.where(status: 'completed').sum(:amount)).to eq(BigDecimal('100'))
    expect(Spree::Pos::Collection.where(credit_account: account).count).to eq(1)
    funds = Spree::Pos::Collection.find_by!(credit_account: account).received_funds
    expect(funds.allocations.sum(:amount)).to be <= funds.received_net
  end
end
