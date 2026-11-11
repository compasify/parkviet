# frozen_string_literal: true

module Spree
  module Pos
    module PrintDocuments
      # Labels and formatting of printed documents. Labels copy the Vietnamese
      # POS locale (config/pos/print_labels.json, checked against it by the
      # client's server contract test); the formats mirror
      # receipt-template/data.ts and money.ts.
      module Text
        LABELS = JSON.parse(Rails.root.join('config/pos/print_labels.json').read).freeze
        ZONE = 'Asia/Ho_Chi_Minh'

        module_function

        def t(key, **values)
          LABELS.fetch(key).gsub(/\{\{(\w+)\}\}/) { values.fetch(Regexp.last_match(1).to_sym).to_s }
        end

        def str(value)
          value.is_a?(String) && value != '' ? value : nil
        end

        def rows(value)
          value.is_a?(Array) ? value.grep(Hash) : []
        end

        def obj(value)
          value.is_a?(Hash) ? value : nil
        end

        # JavaScript's trim, which also removes Unicode spaces.
        def trim(value)
          value.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
        end

        def money(amount, currency = 'VND')
          return '—' unless amount.is_a?(String) && amount.match?(/\A-?\d+(?:\.\d+)?\z/)

          whole, raw = amount.split('.', 2)
          fraction = raw.to_s.sub(/0+\z/, '')
          grouped = whole.gsub(/\B(?=(\d{3})+(?!\d))/, '.')
          "#{grouped}#{fraction.empty? ? '' : ",#{fraction}"} #{currency == 'VND' ? '₫' : currency}"
        end

        # A table cell drops the currency: columns are narrow on a 58mm roll.
        def bare(amount, currency)
          money(amount, currency).sub(/\s(₫|[A-Z]{3})\z/, '')
        end

        def zero?(amount)
          amount.nil? || amount.match?(/\A-?0+(\.0+)?\z/)
        end

        def non_zero?(amount)
          !zero?(amount)
        end

        def document_time(value, zone)
          return '—' if value.blank?

          Time.iso8601(value).in_time_zone(zone).strftime('%d/%m/%Y %H:%M')
        rescue ArgumentError
          value
        end

        def document_date(value)
          match = /\A(\d{4})-(\d{2})-(\d{2})\z/.match(value.to_s)
          match ? "#{match[3]}/#{match[2]}/#{match[1]}" : value.to_s
        end

        def business_date(value)
          match = /\A(\d{4})-(\d{2})-(\d{2})\z/.match(value.to_s)
          match ? "#{match[3]}/#{match[2]}/#{match[1]}" : ''
        end

        def quantity(value)
          return '' if value.nil?

          text = value.to_s
          text.match?(/\A-?\d+(\.\d+)?\z/) ? text.sub(/\.0+\z/, '').sub('.', ',') : text
        end

        def rate(value)
          number = Float(value, exception: false)
          return value unless number&.finite?

          percent = number.abs <= 1 ? number * 100 : number
          rounded = (percent * 100).round / 100.0
          "#{rounded == rounded.to_i ? rounded.to_i : rounded}%"
        end
      end
    end
  end
end
