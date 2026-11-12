# frozen_string_literal: true

module Spree
  module Pos
    module Reports
      # A meal sponsor's statement for a period: every completed meal order
      # of its people at the branch by business date and employee, with the
      # sponsor's part (its receivable debit on the order, so the statement
      # adds up to the sponsor's ledger) and the part the employee paid.
      # Needs `meal_sponsor_id`. Payroll deductions are read off this file;
      # nothing is sent to a payroll system.
      class MealStatement < Grouped
        COLUMNS = %w[business_date employee_code name group_label order_number total sponsor_amount employee_amount].freeze

        def self.filter_keys
          super + %w[meal_sponsor_id]
        end

        # The sponsor is checked when the report or its export is asked for.
        def initialize(...)
          super
          sponsor
        end

        def summary
          rows = all_rows
          { meals: rows.size, sponsor: sponsor_ref,
            **%i[total sponsor_amount employee_amount].to_h { |key| [key, money(rows.sum { |row| BigDecimal(row[key]) })] } }
        end

        def meta
          super.merge(sponsor: sponsor_ref)
        end

        private

        def sponsor
          @sponsor ||= begin
            id = filters['meal_sponsor_id']
            raise Filters::Invalid, 'Choose a sponsor.' if id.blank?

            MealSponsor.locate(MealSponsor.for_store(scope.store), id) || raise(ActiveRecord::RecordNotFound)
          end
        end

        def sponsor_ref
          { id: sponsor.prefixed_id, name: sponsor.name }
        end

        def build_rows
          debits = sponsor.credit_account_id ? ReceivableEntry.where(credit_account_id: sponsor.credit_account_id,
                                                                     kind: 'debit') : ReceivableEntry.none
          meals = MealSwipe.counting.where(spree_pos_meal_accounts: { meal_sponsor_id: sponsor.id })
          ids = workspaces.where(id: debits.select(:workspace_id)).or(workspaces.where(id: meals.select(:workspace_id))).pluck(:id)
          charged = debits.where(workspace_id: ids).pluck(:workspace_id, :amount).to_h
          eaters = MealSwipe.counting.where(workspace_id: ids).includes(meal_account: :customer_profile).index_by(&:workspace_id)
          Workspace.where(id: ids).includes(:order).order(:business_date, :id).map do |workspace|
            account = eaters[workspace.id]&.meal_account
            total = workspace.order.total
            part = BigDecimal((charged[workspace.id] || 0).to_s)
            { business_date: workspace.business_date.iso8601, employee_code: account&.employee_code,
              name: account&.customer_profile&.name || workspace.pos_customer&.name, group_label: account&.group_label,
              order_number: workspace.order.number, total: money(total), sponsor_amount: money(part),
              employee_amount: money(total - part) }
          end
        end
      end
    end
  end
end
