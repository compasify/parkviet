# frozen_string_literal: true

module Spree
  module Pos
    # Read-only health figures for one branch, computed from the source
    # facts (never from a cached counter): money waiting for an outcome,
    # recovery items needing staff, unexplained cash variances, traced stock
    # out of line with the shelf, and the outbox. The outbox has no branch, so
    # its figures are store-wide and only included for store-level readers
    # (`include_outbox`); lock waits are database-wide. Counts and ages only:
    # no customer, staff, amount detail or query text.
    class OperationalMetrics
      # Same threshold as the recovery sweeps.
      STALE_AFTER = 15.minutes
      # Closing variances older than this are history, not an open item.
      VARIANCE_WINDOW = 30.days

      def initialize(store:, branch:, include_outbox: false, now: Time.current)
        @store = store
        @branch = branch
        @include_outbox = include_outbox
        @now = now
      end

      def call
        {
          branch_id: branch.prefixed_id, generated_at: now.iso8601, stale_after_seconds: STALE_AFTER.to_i,
          variance_window_days: VARIANCE_WINDOW.in_days.to_i,
          tenders: tenders, outbox: @include_outbox ? outbox : nil, attention: attention, variances: variances,
          payouts: payouts, traceability: traceability, lock_waits: lock_waits
        }
      end

      private

      attr_reader :store, :branch, :now

      def scoped(model)
        model.where(store_id: store.id, branch_id: branch.id)
      end

      def tenders
        unresolved = scoped(TenderAttempt).unresolved
        counts = unresolved.group(:status).count
        { prepared: counts.fetch('prepared', 0), unknown: counts.fetch('unknown', 0),
          oldest_unresolved_age_seconds: age(unresolved.minimum(:created_at)) }
      end

      def outbox
        rows = OutboxEntry.for_store(store)
        pending = rows.where(status: 'pending')
        { pending: pending.count, failed: rows.where(status: 'failed').count,
          oldest_pending_age_seconds: age(pending.minimum(:available_at)) }
      end

      # The items the recovery sweeps raise for staff, counted directly.
      def attention
        cutoff = now - STALE_AFTER
        {
          stale_tenders: scoped(TenderAttempt).unresolved.where(created_at: ...cutoff).count,
          completion_pending: completion_pending(cutoff),
          stale_refunds: scoped(RefundRequest).reserving.where(updated_at: ...cutoff).count,
          stale_liability_payouts: scoped(LiabilityPayout).reserving.where(updated_at: ...cutoff).count,
          returns_awaiting_predecessor: scoped(ReturnOperation).where(entitlement_status: 'awaiting_predecessor').count,
          stale_returns: scoped(ReturnOperation).where(status: %w[pending_approval ready]).where(created_at: ...cutoff).count,
          open_stock_discrepancies: scoped(StockDiscrepancy).open_now.count,
          funds_needing_attention: scoped(ReceivedFunds).where(status: 'attention').count
        }
      end

      # Editing drafts whose completed receipts already cover the order.
      def completion_pending(cutoff)
        covered = FundsAllocation.joins(:workspace).
                  where(status: 'active', spree_pos_workspaces: { branch_id: branch.id, operational_status: 'editing' }).
                  where(spree_pos_workspaces: { updated_at: ...cutoff }).group(:workspace_id).sum(:amount)
        return 0 if covered.empty?

        Workspace.where(id: covered.keys).includes(:order).count do |workspace|
          order = workspace.order
          order.total.positive? && covered[workspace.id] >= order.total && !order.placed? && !order.completed?
        end
      end

      def variances
        held = scoped(ReceivedFunds).where(kind: 'cash', custody: 'held').
               where('NOT EXISTS (SELECT 1 FROM spree_pos_cash_reconciliations r WHERE r.received_funds_id = spree_pos_received_funds.id)')
        {
          counts_awaiting_close: scoped(Shift).open_now.where.not(closing_counted: nil).count,
          closures_with_unexplained_variance: unexplained_closures,
          held_cash_unreconciled: held.count,
          cash_requests_pending: scoped(CashMovementRequest).where(status: 'requested').count
        }
      end

      # Closures of the window with a variance nobody accounted for: one that
      # needed an approval and has none, or an overage (cash that came from
      # somewhere) not yet placed by a reconciliation. An approved shortage
      # is explained.
      def unexplained_closures
        rows = scoped(ShiftClosure).where(closed_at: (now - VARIANCE_WINDOW)..).where.not(variance: 0).
               pluck(:id, :variance, :variance_threshold, :approver_id)
        return 0 if rows.empty?

        reconciled = CashReconciliation.where(shift_closure_id: rows.map(&:first)).group(:shift_closure_id).sum(:amount)
        rows.count do |id, variance, threshold, approver_id|
          needed_approval = threshold.nil? || variance.abs > threshold
          (needed_approval && approver_id.nil?) || (variance.positive? && reconciled.fetch(id, 0) < variance)
        end
      end

      def payouts
        {
          refunds: status_counts(scoped(RefundRequest).reserving),
          liability_payouts: status_counts(scoped(LiabilityPayout).reserving)
        }
      end

      def status_counts(scope)
        scope.group(:status).count
      end

      def traceability
        enrollments = scoped(TraceEnrollment)
        { enrolled: enrollments.count, drifted: enrollments.where.not(drift_signature: nil).count,
          last_checked_at: enrollments.maximum(:drift_checked_at)&.iso8601 }
      end

      # Backends of this database waiting on a lock right now. Only counts
      # and an age; no pid, user, application or query text. PostgreSQL
      # hides the wait columns of other roles' sessions unless the database
      # role is a superuser or holds pg_read_all_stats, so without that the
      # figures are reported unavailable rather than as a false zero.
      # PostgreSQL does not expose when a lock wait started: the age given is
      # that of the oldest statement now waiting on a lock (an upper bound).
      def lock_waits
        connection = ApplicationRecord.connection
        visible = connection.select_value(<<~SQL.squish)
          SELECT rolsuper OR pg_has_role(current_user, 'pg_read_all_stats', 'MEMBER') FROM pg_roles WHERE rolname = current_user
        SQL
        return { available: false, waiting: nil, oldest_waiting_statement_seconds: nil } unless visible

        row = connection.select_one(<<~SQL.squish)
          SELECT count(*) AS waiting,
                 COALESCE(EXTRACT(EPOCH FROM max(now() - query_start)), 0) AS oldest
          FROM pg_stat_activity
          WHERE datname = current_database() AND wait_event_type = 'Lock' AND pid <> pg_backend_pid()
        SQL
        { available: true, waiting: row['waiting'].to_i, oldest_waiting_statement_seconds: row['oldest'].to_f.round(1) }
      rescue ActiveRecord::StatementInvalid
        { available: false, waiting: nil, oldest_waiting_statement_seconds: nil }
      end

      def age(time)
        return if time.nil?

        [(now - time).to_i, 0].max
      end
    end
  end
end
