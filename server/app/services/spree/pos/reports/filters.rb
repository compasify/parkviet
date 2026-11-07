# frozen_string_literal: true

module Spree
  module Pos
    module Reports
      # Allowlisted report filters, parsed and scoped on the server. Unknown
      # keys and values are rejected; ids resolve only inside the branch and
      # the reader's scope; dates are days in the branch timezone, at most
      # MAX_DAYS apart, and default to today.
      class Filters
        DIMENSIONS = %w[register_id shift_id cashier_id].freeze
        DATES = %w[from to].freeze
        MAX_DAYS = 366

        # Raised for a filter the report does not accept or cannot parse.
        class Invalid < StandardError; end

        def initialize(scope:, values:, report:)
          @scope = scope
          @report = report
          @values = values.to_h.transform_keys(&:to_s).transform_values { |value| value.to_s.strip }.reject { |_, value| value.empty? }
          unknown = @values.keys - report.filter_keys
          raise Invalid, "Unknown filter: #{unknown.sort.join(', ')}" if unknown.any?

          report::ENUMS.each do |key, allowed|
            raise Invalid, "Invalid #{key}." if @values[key] && !allowed.include?(@values[key])
          end
          parse_dates if report.dated?
          resolve_dimensions
        end

        attr_reader :register, :shift, :cashier, :from, :to

        def [](key)
          @values[key.to_s]
        end

        def range
          return if from.nil?

          zone = ActiveSupport::TimeZone[branch.timezone] || Time.zone
          zone.local(from.year, from.month, from.day)...zone.local(to.year, to.month, to.day).advance(days: 1)
        end

        # Canonical filters, as stored on an export request.
        def to_h
          @values.merge(DATES.zip([from&.iso8601, to&.iso8601]).to_h.compact)
        end

        private

        attr_reader :scope, :report

        def branch
          scope.branch
        end

        def parse_dates
          today = Time.now.in_time_zone(branch.timezone).to_date
          @from = date(@values['from']) || today
          @to = date(@values['to']) || @from
          raise Invalid, 'The end date is before the start date.' if @to < @from
          raise Invalid, "Choose at most #{MAX_DAYS} days." if (@to - @from).to_i >= MAX_DAYS
        end

        def date(value)
          return if value.nil?
          raise Invalid, 'Dates use YYYY-MM-DD.' unless value.match?(/\A\d{4}-\d{2}-\d{2}\z/)

          Date.iso8601(value)
        rescue Date::Error
          raise Invalid, 'Dates use YYYY-MM-DD.'
        end

        def resolve_dimensions
          if @values['register_id']
            @register = Register.locate(Register.for_store(scope.store).where(branch_id: branch.id), @values['register_id'])
            raise ActiveRecord::RecordNotFound if @register.nil?
          end
          if @values['shift_id']
            @shift = Shift.locate(scope.shifts, @values['shift_id'])
            raise ActiveRecord::RecordNotFound if @shift.nil?
          end
          return unless @values['cashier_id']

          @cashier = Spree.admin_user_class.find_by_prefix_id(@values['cashier_id'])
          raise ActiveRecord::RecordNotFound if @cashier.nil?
          raise CanCan::AccessDenied unless scope.full? || @cashier.id == scope.staff.id
        end
      end
    end
  end
end
