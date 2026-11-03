# frozen_string_literal: true

module Pos
  # Internal marker, never accepted from cart/order metadata or public API input.
  # The future POS entry point is responsible for authorization and creating it
  # atomically with a staff-originated draft.
  class WalkInOrder < ApplicationRecord
    self.table_name = 'pos_walk_in_orders'

    belongs_to :order, class_name: 'Spree::Order'
  end
end
