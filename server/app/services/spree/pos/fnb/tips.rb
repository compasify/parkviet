# frozen_string_literal: true

module Spree
  module Pos
    module Fnb
      # Tips taken with a payment. The tip is part of the receipt but not of
      # the order: it stays unapplied on its ReceivedFunds (a liability to the
      # staff), so the order total, revenue and the VAT invoice never see it.
      # It is paid to the staff through LiabilityPayout.
      module Tips
        MODULE = 'fnb.postpay'
        KINDS = %w[cash bank_manual].freeze

        module_function

        def enabled?(branch)
          ModulePolicy.enabled?(branch, MODULE)
        end

        def record!(workspace, funds, amount)
          ModulePolicy.require!(workspace.branch, MODULE)
          TipRecord.create!(store: workspace.store, branch: workspace.branch, workspace: workspace, received_funds: funds,
                            shift: workspace.shift, amount: amount, currency: funds.currency,
                            business_date: workspace.business_date, status: 'held')
        end

        # Splits `total` among the recipients. `equal` and `by_hours` give the
        # rounding remainder to the first recipients, one unit each; `manual`
        # takes the typed amounts, which must add up to the total.
        def split(total, recipients, mode:, currency:)
          unit = BigDecimal('1') / (10**(::Money::Currency.find(currency.to_s)&.exponent || 2))
          case mode
          when 'equal' then share(total, recipients.map { |row| [row[:staff], BigDecimal('1')] }, unit)
          when 'by_hours'
            weights = recipients.map { |row| [row[:staff], positive!(row[:hours], 'tip_hours_invalid')] }
            share(total, weights, unit)
          when 'manual'
            rows = recipients.map { |row| [row[:staff], positive!(row[:amount], 'tip_amount_invalid')] }
            unless rows.sum { |_, amount| amount } == total && rows.all? { |_, amount| Record.countable_money?(amount, currency) }
              raise Conflict.new('The amounts must add up to the tips.', reason: 'tip_split_mismatch', details: { total: total.to_s('F') })
            end

            rows
          else
            raise Conflict.new('Unknown way to split tips.', reason: 'tip_split_invalid')
          end
        end

        def share(total, weights, unit)
          sum = weights.sum { |_, weight| weight }
          rows = weights.map { |staff, weight| [staff, ((total * weight / sum) / unit).floor * unit] }
          left = total - rows.sum { |_, amount| amount }
          rows.each_with_index do |row, index|
            break unless left.positive? && index < rows.size

            row[1] += unit
            left -= unit
          end
          rows
        end

        def positive!(value, reason)
          number = value.is_a?(Numeric) ? BigDecimal(value.to_s) : Record.money(value.to_s)
          raise Conflict.new('Every share needs a positive number.', reason: reason) unless number&.positive?

          number
        end
      end
    end
  end
end
