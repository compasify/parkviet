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
      has_many :line_modifiers, -> { order(:id) }, class_name: 'Spree::Pos::LineModifier', dependent: :delete_all,
                                                   inverse_of: :sale_line
      has_many :line_components, -> { order(:id) }, class_name: 'Spree::Pos::LineComponent', dependent: :delete_all,
                                                    inverse_of: :sale_line

      validates :merge_key, presence: true
      validates :note, length: { maximum: 200 }
      validate :kind_is_registered

      def self.build_merge_key(variant_id:, kind:, unit_price:, sale_unit_code:, lot_code: nil, serial_codes: [],
                               tracked_mode: 'none', expiry_on: nil, modifier_signature: nil)
        serials = Array(serial_codes).map(&:to_s).sort
        parts = [variant_id, kind, unit_price.to_s, sale_unit_code, lot_code.to_s, serials.join(','), tracked_mode]
        # Appended only when present so keys of lines without an expiry or
        # an option set stay stable.
        parts << expiry_on.to_s if expiry_on.present?
        parts << "modifiers:#{modifier_signature}" if modifier_signature.present?
        Digest::SHA256.hexdigest(parts.join('|'))
      end

      def merge_key_now
        self.class.build_merge_key(variant_id: variant_id, kind: kind, unit_price: line_price, sale_unit_code: sale_unit_code,
                                   lot_code: lot_code, serial_codes: serial_codes, tracked_mode: tracked_mode,
                                   expiry_on: expiry_on&.iso8601, modifier_signature: modifier_signature)
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
          tracked_mode: tracked_mode, label_barcode: label_barcode, label_format_version: label_format_version,
          line_discount: line_discount_intent && {
            id: line_discount_intent.prefixed_id, value_type: line_discount_intent.value_type,
            value: line_discount_intent.value, reason: line_discount_intent.reason,
            amount: line_discount_intent.allocations.joins(:discount).sum('spree_discounts.amount').to_s('F')
          },
          note: note, modifiers: line_modifiers.map(&:to_pos), components: line_components.map(&:to_pos),
          kitchen_sent_quantity: kitchen_sent_quantity.to_s('F')
        }
      end

      private

      def kind_is_registered
        errors.add(:kind, :inclusion) unless SaleLineKinds.known?(kind)
      end
    end
  end
end
