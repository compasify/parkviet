# frozen_string_literal: true

module Spree
  module Pos
    module Einvoices
      # Invoice lines and totals of a completed POS order, from what was
      # posted: core line amounts, discounts and tax lines, the sale lines'
      # units and quantities, and order-level fees (delivery, service
      # charge). Each line carries its own tax rate. Prices are as sold (tax
      # included when the rate is included in the price); the amount before
      # tax is the paid amount less the line's tax. Tips are not order fees,
      # so they never reach the invoice.
      module Builder
        TIMED_UNIT = 'giờ'
        DEFAULT_UNIT = 'cái'
        NAME_LIMIT = 500

        module_function

        def call(workspace)
          order = workspace.order
          sale_lines = SaleLine.where(workspace_id: workspace.id).includes(:line_modifiers).index_by(&:line_item_id)
          units = UnitDefinition.for_store(workspace.store).
                  where(code: sale_lines.values.map(&:sale_unit_code).uniq).pluck(:code, :name).to_h
          lines = order.line_items.includes(:discounts, :tax_lines, variant: [:product, :option_values]).sort_by(&:id).map do |line|
            item_line(line, sale_lines[line.id], units)
          end
          lines.concat(fee_lines(order))
          { lines: lines.each_with_index.map { |line, index| line.merge('position' => index + 1) },
            totals: totals(order, lines), payment_method: payment_method(workspace), currency: order.currency }
        end

        def item_line(line, sale_line, units)
          discount = line.discounts.to_a.sum(&:amount)
          paid = line.amount + discount
          quantity, unit = quantity_and_unit(line, sale_line, units)
          taxed(line.tax_lines.to_a, paid).merge(
            'kind' => 'goods', 'name' => item_name(line, sale_line), 'sku' => line.variant.sku.presence, 'unit' => unit,
            'quantity' => quantity, 'unit_price' => money(sale_line&.unit_price || line.price),
            'discount' => money(-discount)
          )
        end

        # Core's fee kind a service charge is posted as (Spree::Fee::KINDS has
        # no kind of its own for it).
        SERVICE_CHARGE_KIND = 'surcharge'

        # Order-level fees: the delivery fee and the service charge, each
        # with the tax lines core attached to it.
        def fee_lines(order)
          order.fees.where(line_item_id: nil).order(:id).map do |fee|
            taxed(Spree::TaxLine.where(fee_id: fee.id).to_a, fee.amount).merge(
              'kind' => fee.kind.to_s == SERVICE_CHARGE_KIND ? 'service_charge' : 'fee', 'name' => fee.label.presence || 'Phí',
              'sku' => nil, 'unit' => 'lần', 'quantity' => '1', 'unit_price' => money(fee.amount), 'discount' => '0.0'
            )
          end
        end

        def taxed(tax_lines, paid)
          lines = tax_lines.reject { |row| row.try(:credit) }
          tax = lines.sum { |row| BigDecimal(row.amount.to_s) }
          included = lines.none? || lines.all?(&:included)
          before = included ? paid - tax : paid
          { 'tax_rate' => lines.first && rate_text(lines.first.rate), 'tax_amount' => money(tax),
            'amount_before_tax' => money(before), 'amount' => money(before + tax), 'price_includes_tax' => included }
        end

        def quantity_and_unit(line, sale_line, units)
          return [line.quantity.to_s, DEFAULT_UNIT] if sale_line.nil?
          return [sale_line.sale_quantity.round(2).to_s('F'), TIMED_UNIT] if sale_line.kind == 'timed'

          unit = units[sale_line.sale_unit_code] || (sale_line.sale_unit_code == 'item' ? DEFAULT_UNIT : sale_line.sale_unit_code)
          [sale_line.sale_quantity.to_s('F').delete_suffix('.0'), unit]
        end

        # "Trà sữa (Size: L) + Trân châu ×2": the size and the options sold
        # with it, in Vietnamese as the menu names them.
        def item_name(line, sale_line)
          name = line.variant.product.name.to_s
          options = line.variant.options_text.to_s
          name = "#{name} (#{options})" if options.present?
          modifiers = Array(sale_line&.line_modifiers).map { |row| row.quantity > 1 ? "#{row.name} ×#{row.quantity}" : row.name }
          name = "#{name} + #{modifiers.join(', ')}" if modifiers.any?
          name.length > NAME_LIMIT ? "#{name[0, NAME_LIMIT - 1]}…" : name
        end

        def totals(order, lines)
          by_rate = lines.group_by { |line| line['tax_rate'] }.map do |rate, group|
            { 'tax_rate' => rate, 'amount_before_tax' => sum(group, 'amount_before_tax'), 'tax_amount' => sum(group, 'tax_amount') }
          end
          { 'amount_before_tax' => sum(lines, 'amount_before_tax'), 'tax_amount' => sum(lines, 'tax_amount'),
            'discount_total' => sum(lines, 'discount'), 'total' => money(order.total), 'taxes' => by_rate }
        end

        # TM (cash), CK (transfer) or both, as invoices write it.
        def payment_method(workspace)
          kinds = FundsAllocation.where(workspace_id: workspace.id, status: 'active', collection_id: nil).
                  includes(:received_funds).map { |row| row.received_funds.kind }.uniq
          kinds << 'debt' if ReceivableEntry.where(order_id: workspace.order_id, kind: 'debit').exists?
          return nil if kinds.empty?
          return 'TM' if kinds == ['cash']
          return 'CK' if kinds.exclude?('cash')

          'TM/CK'
        end

        # 0.08 -> "8", 0.1 -> "10", 0.055 -> "5.5".
        def rate_text(rate)
          (BigDecimal(rate.to_s) * 100).to_s('F').delete_suffix('.0')
        end

        def sum(rows, key)
          money(rows.sum { |row| BigDecimal(row[key].to_s) })
        end

        def money(value)
          BigDecimal((value || 0).to_s).to_s('F')
        end
      end
    end
  end
end
