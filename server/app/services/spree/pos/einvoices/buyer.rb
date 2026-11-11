# frozen_string_literal: true

module Spree
  module Pos
    module Einvoices
      # Buyer details an invoice may carry, checked the same way at the
      # counter, on the buyer's own page and by a manager. Empty means a sale
      # to a consumer: the invoice then prints the store's consumer label.
      # A business buyer (with a tax code) needs its registered name and
      # address. A consumer may give a personal ID (12 digits), a phone or a
      # passport with nationality.
      module Buyer
        FIELDS = %w[tax_code name address personal_id phone passport_no nationality email buyer_note].freeze
        LIMITS = { 'tax_code' => 14, 'name' => 400, 'address' => 400, 'personal_id' => 12, 'phone' => 15,
                   'passport_no' => 20, 'nationality' => 60, 'email' => 120, 'buyer_note' => 200 }.freeze
        PERSONAL_ID = /\A\d{12}\z/
        PHONE = /\A\+?\d{9,14}\z/
        EMAIL = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/
        INVALID = 'einvoice_buyer_invalid'

        module_function

        # A clean buyer hash (blank fields dropped), or a Conflict naming the
        # first field that is wrong.
        def normalize!(value)
          raw = value.respond_to?(:to_unsafe_h) ? value.to_unsafe_h : value
          raw = {} if raw.nil?
          raise invalid('buyer') unless raw.is_a?(Hash)

          buyer = FIELDS.each_with_object({}) do |field, result|
            text = raw[field] || raw[field.to_sym]
            next if text.nil?
            raise invalid(field) unless text.is_a?(String) || text.is_a?(Numeric)

            text = text.to_s.strip.gsub(/\s+/, ' ')
            next if text.empty?
            raise invalid(field) if text.length > LIMITS.fetch(field)

            result[field] = text
          end
          check!(buyer)
          buyer
        end

        def check!(buyer)
          buyer['phone'] = buyer['phone'].delete(' .-') if buyer['phone']
          raise invalid('tax_code') if buyer['tax_code'] && !buyer['tax_code'].match?(EinvoiceSetting::TAX_CODE)
          raise invalid('personal_id') if buyer['personal_id'] && !buyer['personal_id'].match?(PERSONAL_ID)
          raise invalid('phone') if buyer['phone'] && !buyer['phone'].match?(PHONE)
          raise invalid('email') if buyer['email'] && !buyer['email'].match?(EMAIL)
          return unless buyer['tax_code']

          raise invalid('name') if buyer['name'].nil?
          raise invalid('address') if buyer['address'].nil?
        end

        def consumer?(buyer)
          buyer['tax_code'].blank? && buyer['name'].blank?
        end

        def invalid(field)
          Conflict.new("The buyer #{field.tr('_', ' ')} is missing or invalid.", reason: INVALID, details: { field: field })
        end
      end
    end
  end
end
