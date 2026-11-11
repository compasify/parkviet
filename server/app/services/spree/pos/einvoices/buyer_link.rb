# frozen_string_literal: true

module Spree
  module Pos
    module Einvoices
      # The link printed as a QR on the bill, where the buyer types their own
      # details. The token is the invoice id signed with the app secret, for
      # this purpose only, and expires with `buyer_token_expires_at`; it is
      # never stored. The link opens only while the invoice can still take
      # buyer details (Einvoice#buyer_link_open?).
      module BuyerLink
        PURPOSE = 'pos_einvoice_buyer'
        PATH = '/pos_einvoice/'

        module_function

        def token(einvoice)
          return nil if einvoice.buyer_token_expires_at.nil?

          einvoice.signed_id(purpose: PURPOSE, expires_at: einvoice.buyer_token_expires_at)
        end

        # nil when this server has no public address to put in it.
        def url(einvoice)
          base = base_url
          value = token(einvoice)
          base && value ? "#{base}#{PATH}#{value}" : nil
        end

        def find(token)
          return nil if token.blank? || token.length > 400

          Einvoice.find_signed(token, purpose: PURPOSE)
        end

        # Where the buyer's phone reaches this server: the deployment's
        # public address (POS_PUBLIC_BASE_URL). A shop server with only a LAN
        # address prints a link that works on the shop's Wi-Fi only.
        def base_url
          Parkviet::PosPublicUrl.base_url
        end

        # Default lifetime: until the end of the business day of the sale.
        def expires_at(branch, setting, at)
          return at + setting.buyer_link_hours.hours if setting&.buyer_link_hours

          Einvoices.business_day_end(branch, at)
        end
      end
    end
  end
end
