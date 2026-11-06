# frozen_string_literal: true

module Spree
  module Pos
    module Adjusters
      # Replace only item-level campaign candidates explicitly overridden by a
      # cashier. Core still owns promotion rows, cleanup and order promotions.
      class Promotion < Spree::Adjusters::Promotion
        private

        def line_item_candidates(line_item)
          return super unless order.is_a?(Spree::Order)

          @pos_override_line_ids ||= Spree::Pos::SaleLine.joins(:line_discount_intent)
            .where(order_id: order.id, spree_pos_line_discount_intents: { value_type: %w[item_flat item_percent] }).pluck(:line_item_id)
          @pos_override_line_ids.include?(line_item.id) ? [] : super
        end
      end
    end
  end
end
