# frozen_string_literal: true

module Spree
  module Pos
    class SaleLine < Record
      self.table_name = 'spree_pos_sale_lines'
      has_prefix_id :possaleline

      belongs_to :workspace, class_name: 'Spree::Pos::Workspace'
      belongs_to :order, class_name: 'Spree::Order'
      belongs_to :line_item, class_name: 'Spree::LineItem'
      belongs_to :variant, class_name: 'Spree::Variant'
      has_one :line_discount_intent, class_name: 'Spree::Pos::LineDiscountIntent', dependent: :destroy

      validates :merge_key, presence: true

      def self.build_merge_key(variant_id:, kind:, unit_price:, sale_unit_code:, lot_code: nil, serial_codes: [], tracked_mode: 'none')
        serials = Array(serial_codes).map(&:to_s).sort
        Digest::SHA256.hexdigest([variant_id, kind, unit_price.to_s, sale_unit_code, lot_code.to_s, serials.join(','), tracked_mode].join('|'))
      end

      def tracked?
        tracked_mode != 'none' || lot_code.present? || Array(serial_codes).any?
      end

      def to_pos(line)
        {
          sale_line_id: prefixed_id, kind: kind, sale_quantity: sale_quantity.to_s('F'),
          base_quantity: base_quantity, sale_unit: sale_unit_code, base_unit: base_unit_code,
          conversion_version: conversion_version, unit_price: unit_price.to_s('F'),
          lot_code: lot_code, expiry_on: expiry_on&.iso8601, serial_codes: Array(serial_codes),
          tracked_mode: tracked_mode,
          line_discount: line_discount_intent && {
            id: line_discount_intent.prefixed_id, value_type: line_discount_intent.value_type,
            value: line_discount_intent.value, reason: line_discount_intent.reason,
            amount: line_discount_intent.allocations.joins(:discount).sum('spree_discounts.amount').to_s('F')
          }
        }
      end
    end
  end
end
