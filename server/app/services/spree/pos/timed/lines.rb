# frozen_string_literal: true

module Spree
  module Pos
    module Timed
      # The timed sale line of a session. It counts minutes (base unit
      # `phut`) at a price per minute and is sold in hours (`gio`), like a
      # measured line counts grams. While the clock runs the line holds one
      # minute at no price, so the order's total never carries a quote; the
      # stop writes the billed minutes and the price that makes them cost
      # exactly the quoted amount.
      module Lines
        KIND = 'timed'
        # A line has at least one minute, whatever was billed.
        PLACEHOLDER_MINUTES = 1
        HOUR_PRECISION = 4

        module_function

        def create!(workspace:, staff:, plan:, device: nil)
          UnitDefinition.ensure_time_units!(workspace.store)
          variant = Workspaces::ManageLineItem.sellable_variant!(branch: workspace.branch, variant: plan.variant)
          line = workspace.order.line_items.build(variant: variant, quantity: PLACEHOLDER_MINUTES, price: 0, currency: workspace.order.currency)
          line.price_source = Spree::LineItem::MANUAL_PRICE_SOURCE
          line.save!
          SaleLine.create!(
            workspace: workspace, order: workspace.order, line_item: line, variant: variant, kind: KIND,
            # A clock never merges into another line.
            merge_key: SaleLine.build_merge_key(variant_id: variant.id, kind: KIND, unit_price: SecureRandom.uuid,
                                                sale_unit_code: UnitDefinition::HOUR_CODE),
            sale_quantity: hours(PLACEHOLDER_MINUTES), base_quantity: PLACEHOLDER_MINUTES,
            sale_unit_code: UnitDefinition::HOUR_CODE, base_unit_code: UnitDefinition::MINUTE_CODE,
            ratio_numerator: 1, ratio_denominator: 1, unit_price: 0, line_price: 0, added_by: staff, added_device: device
          )
        end

        # Writes the billed minutes and amount on the line and sums the order.
        def write!(workspace, sale_line, minutes:, amount:)
          count = [minutes, PLACEHOLDER_MINUTES].max
          per_minute = amount.zero? ? BigDecimal('0') : (amount / count).round(4)
          if Spree::Money::Rounding.to_currency(per_minute * count, workspace.order.currency) != amount
            raise Conflict.new('The play time is too long to bill on one line.', reason: 'timed_amount_unrepresentable')
          end

          sale_line.line_item.update!(quantity: count, price: per_minute)
          sale_line.update!(base_quantity: count, sale_quantity: hours(count), line_price: per_minute,
                            unit_price: minutes.zero? ? BigDecimal('0') : (amount * 60 / minutes).round(4))
          Workspaces::ApplyDiscount.recalculate!(workspace)
        end

        def hours(minutes)
          (BigDecimal(minutes) / 60).round(HOUR_PRECISION)
        end
      end
    end
  end
end
