# frozen_string_literal: true

module Spree
  module Pos
    module Reports
      # A report whose rows are totals grouped in SQL rather than records:
      # rows are built once per request, paged in memory and exported in the
      # same order. Sales are dated by the workspace's business date, and the
      # reader's scope and the register, shift and cashier filters select
      # the workspaces counted.
      class Grouped < Base
        def self.business_dated?
          true
        end

        def page(page, limit)
          page = [page.to_i, 1].max
          limit = limit.to_i
          limit = 25 if limit <= 0
          limit = PAGE_MAX if limit > PAGE_MAX
          total = all_rows.size
          pages = total.zero? ? 0 : (total.to_f / limit).ceil
          [all_rows.slice((page - 1) * limit, limit) || [], { page: page, limit: limit, count: total, pages: pages }]
        end

        def each_row(&)
          all_rows.each(&)
        end

        def total_count
          all_rows.size
        end

        private

        def all_rows
          @all_rows ||= build_rows
        end

        def workspaces
          relation = Workspace.where(branch_id: branch.id, order_id: Spree::Order.complete.select(:id)).
                     where(shift_id: scope.shifts.select(:id))
          relation = relation.where(register_id: filters.register.id) if filters.register
          relation = relation.where(shift_id: filters.shift.id) if filters.shift
          relation = relation.where(shift_id: Shift.where(owner_id: filters.cashier.id).select(:id)) if filters.cashier
          relation.where(business_date: filters.from..filters.to)
        end

        def consumptions
          RecipeConsumption.where(branch_id: branch.id, workspace_id: workspaces.select(:id))
        end

        def variant_label(variant)
          [variant&.product&.name, variant&.options_text.presence].compact.join(' · ')
        end
      end
    end
  end
end
