# frozen_string_literal: true

module Spree
  module Pos
    module Reports
      # Delivery platform orders by business date and platform: how many
      # were completed, their gross, the commission and what the platform
      # pays (net), and the part of it not paid yet. The commission of an
      # unsettled order is the branch rate's estimate; once settled it is
      # the platform's figure, so the two are shown apart.
      class Platforms < Grouped
        COLUMNS = %w[business_date platform orders gross commission net unsettled commission_estimated commission_actual].freeze
        ENUMS = { 'platform' => PlatformSetting::PLATFORMS }.freeze
        SUMS = {
          gross: 'SUM(spree_pos_platform_orders.gross_amount)',
          commission: 'SUM(spree_pos_platform_orders.commission_amount)',
          net: 'SUM(spree_pos_platform_orders.net_amount)',
          unsettled: 'SUM(CASE WHEN spree_pos_platform_orders.settled_at IS NULL THEN spree_pos_platform_orders.net_amount ELSE 0 END)',
          commission_estimated: 'SUM(CASE WHEN spree_pos_platform_orders.settled_at IS NULL ' \
                                'THEN spree_pos_platform_orders.commission_amount ELSE 0 END)',
          commission_actual: 'SUM(CASE WHEN spree_pos_platform_orders.settled_at IS NOT NULL ' \
                             'THEN spree_pos_platform_orders.commission_amount ELSE 0 END)'
        }.freeze

        def summary
          rows = all_rows
          totals = SUMS.keys.to_h { |key| [key, money(rows.sum { |row| BigDecimal(row[key]) })] }
          { orders: rows.sum { |row| row[:orders] }, **totals }
        end

        private

        def build_rows
          relation = PlatformOrder.where(branch_id: branch.id, status: 'completed', workspace_id: workspaces.select(:id)).
                     joins(:workspace)
          relation = relation.where(platform: filters['platform']) if filters['platform']
          grouped = relation.group('spree_pos_workspaces.business_date', 'spree_pos_platform_orders.platform').
                    order('spree_pos_workspaces.business_date DESC', 'spree_pos_platform_orders.platform').
                    pluck(Arel.sql('spree_pos_workspaces.business_date'), Arel.sql('spree_pos_platform_orders.platform'),
                          Arel.sql('COUNT(*)'), *SUMS.values.map { |sql| Arel.sql(sql) })
          grouped.map do |date, platform, count, *sums|
            { business_date: date.iso8601, platform: platform, orders: count.to_i,
              **SUMS.keys.zip(sums.map { |value| money(value) }).to_h }
          end
        end
      end
    end
  end
end
