# frozen_string_literal: true

module Spree
  module Pos
    class Record < Spree.base_class
      self.abstract_class = true

      def self.staff_class_name
        Spree.admin_user_class.to_s
      end

      def self.locate(scope, prefixed)
        return if prefixed.blank?

        found = find_by_prefix_id(prefixed.to_s)
        scope.find_by(id: found.id) if found
      end

      def self.money(value)
        return value if value.is_a?(BigDecimal)
        return if value.is_a?(Float)

        string = value.to_s.strip
        return if string.blank? || !string.match?(/\A\d+(\.\d{1,4})?\z/)

        BigDecimal(string)
      end
    end
  end
end
