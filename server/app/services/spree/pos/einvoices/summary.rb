# frozen_string_literal: true

module Spree
  module Pos
    module Einvoices
      # What the e-invoice screens show above their lists: invoices still
      # waiting (per status), and the store's turnover of the year so far
      # against the 1 billion VND mark, with a warning at 80% and 100%. The
      # turnover is the total of completed POS orders by business date, before
      # returns; it only informs, it never changes selling.
      module Summary
        module_function

        def call(store:, branches:, year: Time.current.in_time_zone('Asia/Ho_Chi_Minh').year)
          invoices = Einvoice.for_store(store).where(branch_id: branches.map(&:id))
          counts = invoices.group(:status).count
          revenue = ytd_revenue(store, year)
          share = (revenue / MANDATORY_REVENUE).round(4)
          {
            einvoice_type: StoreProfile.einvoice_type_for(store),
            outstanding: Einvoice::OUTSTANDING.sum { |status| counts.fetch(status, 0) },
            counts: Einvoice::STATUSES.index_with { |status| counts.fetch(status, 0) },
            oldest_outstanding_at: invoices.outstanding.minimum(:created_at)&.iso8601,
            revenue: { year: year, total: revenue.to_s('F'), threshold: MANDATORY_REVENUE.to_s('F'), share: share.to_s('F'),
                       level: level(share) }
          }
        end

        def ytd_revenue(store, year)
          Spree::Order.joins('INNER JOIN spree_pos_workspaces ON spree_pos_workspaces.order_id = spree_orders.id').
            where(spree_pos_workspaces: { store_id: store.id, operational_status: 'completed',
                                          business_date: Date.new(year, 1, 1)..Date.new(year, 12, 31) }).
            sum('spree_orders.total').to_d
        end

        def level(share)
          return 'reached' if share >= WARNING_SHARES.last
          return 'warning' if share >= WARNING_SHARES.first

          'ok'
        end
      end
    end
  end
end
