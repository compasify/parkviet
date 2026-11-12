# frozen_string_literal: true

module Spree
  module Pos
    module Reports
      # Shared paging, serialization and timezone helpers. A report defines
      # `relation` (ordered, scoped), `rows(records)`, `summary` and COLUMNS.
      class Base
        ENUMS = {}.freeze
        PAGE_MAX = 100
        BATCH = 500

        def self.dated?
          true
        end

        def self.filter_keys
          (dated? ? Filters::DATES : []) + Filters::DIMENSIONS + self::ENUMS.keys
        end

        def initialize(scope:, filters:)
          @scope = scope
          @filters = filters
        end

        attr_reader :scope, :filters

        def page(page, limit)
          page = [page.to_i, 1].max
          limit = limit.to_i
          limit = 25 if limit <= 0
          limit = PAGE_MAX if limit > PAGE_MAX
          total = total_count
          records = relation.offset((page - 1) * limit).limit(limit).to_a
          pages = total.zero? ? 0 : (total.to_f / limit).ceil
          [rows(records), { page: page, limit: limit, count: total, pages: pages }]
        end

        # Every row, a batch at a time, for exports. Keyset pagination on a
        # unique ascending key (no OFFSET scans), so exports list rows in
        # creation order rather than the screen's newest-first order.
        def each_row(&block)
          last = nil
          loop do
            key = relation.klass.arel_table[keyset_attribute]
            batch = relation.reorder(key.asc).limit(BATCH)
            batch = batch.where(key.gt(last)) unless last.nil?
            records = batch.to_a
            break if records.empty?

            rows(records).each(&block)
            last = records.last.read_attribute(keyset_attribute)
          end
        end

        # Unique column of the relation's table that exports page on.
        def keyset_attribute
          'id'
        end

        def total_count
          relation.except(:order, :select).count
        end

        def columns
          self.class::COLUMNS
        end

        def meta
          { report: self.class.name.demodulize.underscore, branch_id: branch.prefixed_id, timezone: branch.timezone,
            from: filters.from&.iso8601, to: filters.to&.iso8601, scope: scope.full? ? 'branch' : 'own' }
        end

        private

        def branch
          scope.branch
        end

        def local(time)
          time&.in_time_zone(branch.timezone)&.iso8601
        end

        def money(value)
          BigDecimal((value || 0).to_s).to_s('F')
        end

        def within_range(relation, column)
          range = filters.range
          range ? relation.where(column => range) : relation
        end
      end
    end
  end
end
