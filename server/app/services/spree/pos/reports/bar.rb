# frozen_string_literal: true

module Spree
  module Pos
    module Reports
      # A bar's night by business date, so a tab opened at 23:30 and paid at
      # 01:30 counts once on the day it was opened: completed orders and
      # their revenue (order totals, which never hold tips), how much of it
      # sold at a happy-hour price, the tabs, the tips taken (revenue only
      # when the branch says so), and the bottles: opened and finished for
      # pours, ml poured, and bottles put into keeping. The summary adds the
      # revenue by hour of payment and the kept bottles running out soon.
      class Bar < Grouped
        COLUMNS = %w[business_date orders revenue happy_hour_revenue tabs tips tips_in_revenue bottles_opened bottles_finished
                     ml_poured bottles_kept].freeze
        HAPPY_SQL = 'CASE WHEN spree_pos_sale_lines.price_label IS NOT NULL THEN spree_line_items.price * spree_line_items.quantity + ' \
                    'spree_line_items.adjustment_total ELSE 0 END'
        EXPIRING_DAYS = 7

        def summary
          rows = all_rows
          money_keys = %i[revenue happy_hour_revenue tips]
          totals = money_keys.to_h { |key| [key, money(rows.sum { |row| BigDecimal(row[key]) })] }
          counts = %i[orders tabs bottles_opened bottles_finished ml_poured bottles_kept].to_h { |key| [key, rows.sum { |row| row[key] }] }
          { **counts, **totals, tips_in_revenue: branch.tips_as_revenue, by_hour: by_hour, keeps_expiring: keeps_expiring }
        end

        private

        def build_rows
          orders = workspaces.joins(:order).group(:business_date).
                   pluck(:business_date, Arel.sql('COUNT(*)'), Arel.sql('SUM(spree_orders.total)'),
                         Arel.sql("SUM(CASE WHEN spree_pos_workspaces.service_mode = 'tab' THEN 1 ELSE 0 END)")).
                   to_h { |date, count, total, tabs| [date, [count.to_i, total, tabs.to_i]] }
          happy = SaleLine.where(workspace_id: workspaces.select(:id)).joins(:line_item, :workspace).
                  group('spree_pos_workspaces.business_date').sum(Arel.sql(HAPPY_SQL))
          tips = TipRecord.where(workspace_id: workspaces.select(:id)).group(:business_date).sum(:amount)
          pours = PourEvent.where(branch_id: branch.id, business_date: filters.from..filters.to).group(:business_date).sum(:ml)
          opened = bottles(:opened_at)
          finished = bottles(:finished_at)
          kept = BottleKeep.where(branch_id: branch.id, kept_on: filters.from..filters.to).group(:kept_on).count
          days = (orders.keys + pours.keys + opened.keys + finished.keys + kept.keys).uniq.sort.reverse
          days.map do |day|
            count, total, tabs = orders.fetch(day, [0, 0, 0])
            { business_date: day.iso8601, orders: count, revenue: money(total), happy_hour_revenue: money(happy[day]), tabs: tabs,
              tips: money(tips[day]), tips_in_revenue: branch.tips_as_revenue, bottles_opened: opened.fetch(day, 0),
              bottles_finished: finished.fetch(day, 0), ml_poured: pours.fetch(day, 0).to_i, bottles_kept: kept.fetch(day, 0) }
          end
        end

        # Open bottles counted by the business day of a time column.
        def bottles(column)
          OpenBottle.where(branch_id: branch.id).where.not(column => nil).
            where(column => window).pluck(column).
            map { |at| BusinessDay.for(branch, at) }.select { |day| (filters.from..filters.to).cover?(day) }.tally
        end

        # Wide enough to hold every business day of the range in any zone.
        def window
          (filters.from - 1).beginning_of_day..(filters.to + 2).end_of_day
        end

        def by_hour
          zone = ActiveSupport::TimeZone[branch.timezone] || Time.zone
          workspaces.joins(:order).pluck(Arel.sql('spree_orders.completed_at'), Arel.sql('spree_orders.total')).
            group_by { |at, _| at&.in_time_zone(zone)&.hour }.reject { |hour, _| hour.nil? }.
            sort.map { |hour, rows| { hour: hour, orders: rows.size, revenue: money(rows.sum { |_, total| BigDecimal(total.to_s) }) } }
        end

        def keeps_expiring
          today = BusinessDay.for(branch, Workspace.business_now)
          BottleKeep.where(branch_id: branch.id, status: 'kept', expires_on: today..(today + EXPIRING_DAYS)).count
        end
      end
    end
  end
end
