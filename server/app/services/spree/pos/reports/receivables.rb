# frozen_string_literal: true

module Spree
  module Pos
    module Reports
      # Customer debt of credit sales made at the branch, as of today, from
      # the receivable ledger (debt - credit notes - collections + reversals),
      # never core `amount_due`. Rows carry the customer name only.
      class Receivables < Base
        ENUMS = { 'status' => %w[open overdue settled all] }.freeze
        COLUMNS = %w[order_number placed_at customer debt credit_notes collected balance due_on overdue days_overdue
                     aging currency].freeze

        def self.dated?
          false
        end

        def relation
          table = ReceivableEntry.table_name
          projection.order_rows(status: filters['status'] || 'open').
            reorder(Arel.sql("MAX(#{table}.due_on) ASC, #{table}.order_id ASC"))
        end

        def total_count
          ReceivableEntry.from(relation.reorder(nil), :rows).count
        end

        def rows(records)
          orders = Spree::Order.where(id: records.map(&:order_id)).index_by(&:id)
          accounts = CreditAccount.where(id: records.map(&:credit_account_id)).includes(:customer_profile).index_by(&:id)
          records.map do |row|
            order = orders.fetch(row.order_id)
            account = accounts.fetch(row.credit_account_id)
            collected = BigDecimal(row.collected.to_s) - BigDecimal(row.reversed.to_s)
            { order_number: order.number, placed_at: local(order.completed_at), customer: account.customer_profile&.name,
              debt: money(row.debt), credit_notes: money(row.credit_notes), collected: money(collected),
              balance: money(row.balance), due_on: row.due_on&.iso8601, overdue: projection.overdue?(row),
              days_overdue: projection.days_overdue(row), aging: projection.bucket(row), currency: account.currency }
          end
        end

        def keyset_attribute
          'order_id'
        end

        # The same balance, overdue and aging totals as the projection, summed
        # in one SQL aggregate over the grouped rows instead of loading them.
        def summary
          today = ActiveRecord::Base.connection.quote(projection.today)
          overdue = "rows.balance > 0 AND rows.due_on IS NOT NULL AND rows.due_on < DATE #{today}"
          days = "(CASE WHEN #{overdue} THEN DATE #{today} - rows.due_on ELSE 0 END)"
          buckets = ReceivableProjection::AGING.map do |(name, from, to)|
            bounds = [from && "#{days} >= #{from.to_i}", to && "#{days} <= #{to.to_i}"].compact.join(' AND ')
            "COALESCE(SUM(CASE WHEN #{bounds} THEN rows.balance ELSE 0 END), 0) AS #{name}"
          end
          selects = ['COALESCE(SUM(rows.balance), 0) AS balance',
                     "COALESCE(SUM(CASE WHEN #{overdue} THEN rows.balance ELSE 0 END), 0) AS overdue"] + buckets
          sql = ReceivableEntry.unscoped.from(relation.reorder(nil), :rows).select(Arel.sql(selects.join(', '))).to_sql
          ActiveRecord::Base.connection.select_one(sql).transform_values { |value| money(value) }
        end

        private

        def projection
          @projection ||= begin
            workspaces = Workspace.where(branch_id: branch.id, shift_id: scope.shifts.select(:id))
            workspaces = workspaces.where(register_id: filters.register.id) if filters.register
            workspaces = workspaces.where(shift_id: filters.shift.id) if filters.shift
            workspaces = workspaces.where(shift_id: Shift.where(owner_id: filters.cashier.id).select(:id)) if filters.cashier
            entries = ReceivableEntry.for_store(scope.store).where(branch_id: branch.id, workspace_id: workspaces.select(:id))
            ReceivableProjection.new(entries, today: Time.now.in_time_zone(branch.timezone).to_date)
          end
        end
      end
    end
  end
end
