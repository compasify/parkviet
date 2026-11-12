# frozen_string_literal: true

module Spree
  module Pos
    # What the owner app warns about, found by a periodic scan
    # (OwnerAlerts::ScanJob) rather than inside the commands, so no sale
    # waits on it:
    # - `kitchen_late`: an item sent to the kitchen and still not ready
    #   past its station's late threshold;
    # - `shift_variance`: a shift closed with a cash difference;
    # - `void_burst`: VOID_BURST or more sent items taken back in an hour;
    # - `revenue_milestone`: the store's completed POS sales this calendar
    #   year passed 90% or 100% of the 1 billion VND household-business
    #   threshold;
    # - `print_failed`: a print job gave up;
    # - `einvoice_failed`: an e-invoice could not be issued.
    # Each alert is stored once per dedupe key and announced with
    # `owner_alert.created` (realtime, and push when a relay is set).
    module OwnerAlerts
      LOOKBACK = 30.minutes
      VOID_BURST = 5
      REVENUE_THRESHOLD = BigDecimal('1000000000')
      REVENUE_STEPS = [90, 100].freeze
      LIST_LIMIT = 100

      module_function

      # Stores the alert unless its key was raised before. Answers the new
      # alert, or nil.
      def raise!(branch, kind, key, subject_ref: nil, details: {}, at: Time.current)
        rows = OwnerAlert.insert_all(
          [{ store_id: branch.store_id, branch_id: branch.id, kind: kind, dedupe_key: key.to_s.first(120),
             subject_ref: subject_ref, details: details, occurred_at: at, created_at: Time.current, updated_at: Time.current }],
          unique_by: :idx_pos_owner_alerts_dedupe, returning: %w[id]
        )
        return nil if rows.rows.empty?

        alert = OwnerAlert.find(rows.rows.first.first)
        Realtime.publish(branch, 'owner_alert.created', id: alert.prefixed_id)
        Push.notify(branch, 'owner_alert.created', alert)
        alert
      end

      def recent(branch, since: 1.day.ago)
        OwnerAlert.where(branch_id: branch.id, occurred_at: since..).order(occurred_at: :desc, id: :desc).limit(LIST_LIMIT)
      end

      # One branch, now. Each check stands alone: one failing never hides the others.
      def scan!(branch, now: Workspace.database_now)
        %i[kitchen_late shift_variance void_burst print_failed einvoice_failed].each do |check|
          send(check, branch, now)
        rescue StandardError => e
          Rails.error.report(e, handled: true, context: { pos_branch_id: branch.id, pos_owner_alert: check })
        end
      end

      def kitchen_late(branch, now)
        KitchenTicketItem.joins(kitchen_ticket: :kitchen_station).
          where(spree_pos_kitchen_tickets: { branch_id: branch.id, kind: 'fire' }, status: %w[new preparing]).
          where(spree_pos_kitchen_tickets: { sent_at: (now - 1.day)..now }).
          where("spree_pos_kitchen_tickets.sent_at + make_interval(mins => spree_pos_kitchen_stations.late_after_minutes) <= ?", now).
          limit(LIST_LIMIT).pluck('spree_pos_kitchen_ticket_items.id', 'spree_pos_kitchen_tickets.sent_at', 'spree_pos_kitchen_tickets.workspace_id').
          each do |id, sent_at, workspace_id|
            raise!(branch, 'kitchen_late', "kitchen_late:#{id}", subject_ref: Workspace.prefixed_for(workspace_id),
                                                                 details: { minutes: ((now - sent_at) / 60).floor }, at: now)
          end
      end

      def shift_variance(branch, now)
        ShiftClosure.where(branch_id: branch.id, closed_at: (now - LOOKBACK)..now).where.not(variance: 0).find_each do |closure|
          raise!(branch, 'shift_variance', "shift_variance:#{closure.id}", subject_ref: closure.shift.prefixed_id,
                                                                           details: { variance: closure.variance.to_s('F'), currency: closure.currency }, at: closure.closed_at)
        end
      end

      def void_burst(branch, now)
        count = KitchenVoid.joins(:workspace).where(spree_pos_workspaces: { branch_id: branch.id }, created_at: (now - 1.hour)..now).count
        return if count < VOID_BURST

        # One alert per clock hour at most.
        raise!(branch, 'void_burst', "void_burst:#{now.utc.strftime('%Y%m%d%H')}", details: { voids: count }, at: now)
      end

      def print_failed(branch, now)
        PrintJob.where(branch_id: branch.id, status: 'failed', updated_at: (now - LOOKBACK)..now).limit(LIST_LIMIT).each do |job|
          raise!(branch, 'print_failed', "print_failed:#{job.id}", subject_ref: job.prefixed_id, details: { kind: job.kind }, at: job.updated_at)
        end
      end

      def einvoice_failed(branch, now)
        Einvoice.where(branch_id: branch.id, status: 'failed', updated_at: (now - LOOKBACK)..now).limit(LIST_LIMIT).each do |invoice|
          raise!(branch, 'einvoice_failed', "einvoice_failed:#{invoice.id}", subject_ref: invoice.prefixed_id, at: invoice.updated_at)
        end
      end

      # The store's completed POS sales this calendar year, in the store's
      # first branch timezone, against the threshold. Raised on every active
      # branch, since each owner screen shows one branch.
      def revenue_milestone!(store, now: Time.current)
        branches = Branch.for_store(store).where(status: 'active').order(:id).to_a
        return if branches.empty?

        year = now.in_time_zone(branches.first.timezone).year
        workspaces = Workspace.where(branch_id: branches.map(&:id), business_date: Date.new(year, 1, 1)..Date.new(year, 12, 31))
        total = Spree::Order.complete.where(id: workspaces.select(:order_id)).sum(:total)
        step = REVENUE_STEPS.reverse.find { |percent| total >= REVENUE_THRESHOLD * percent / 100 }
        return if step.nil?

        branches.each do |branch|
          raise!(branch, 'revenue_milestone', "revenue_milestone:#{year}:#{step}",
                 details: { percent: step, year: year, total: BigDecimal(total.to_s).to_s('F') }, at: now)
        end
      end
    end
  end
end
