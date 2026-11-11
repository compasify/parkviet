# frozen_string_literal: true

module Spree
  module Pos
    # The buyer's own page behind the QR on the bill: a small server-rendered
    # form (no app, no script) where they type the details their e-invoice
    # should carry. The signed token in the path is the only credential; it
    # expires (Einvoices::BuyerLink) and the form only takes details while
    # the invoice has not gone to the provider. "Look up" fills the name and
    # address from the tax code through the provider when it offers that.
    # Every action is rate limited per client address. Pages are never
    # cached, send no referrer, and allow no script.
    class EinvoiceBuyerController < ActionController::Base
      ATTEMPTS = 30
      WINDOW = 1.minute
      LIMIT_STORE = Rails.cache.is_a?(ActiveSupport::Cache::NullStore) ? ActiveSupport::Cache::MemoryStore.new : Rails.cache

      layout false
      skip_forgery_protection
      before_action :secure_headers
      before_action :load_invoice
      rate_limit to: ATTEMPTS, within: WINDOW, store: LIMIT_STORE,
                 with: -> { render_page(:limited, status: :too_many_requests) }

      def show
        @buyer = @einvoice.buyer.except('label')
        render_page(page_state)
      end

      def update
        @buyer = submitted_buyer
        return lookup if params[:lookup].present?

        Einvoices::UpdateBuyer.from_buyer!(@einvoice, @buyer)
        @einvoice.reload
        render_page(:saved)
      rescue Conflict => e
        @error = e.reason == Einvoices::Buyer::INVALID ? e.details&.dig(:field) || 'buyer' : nil
        return render_page(page_state(e.reason), status: :conflict) if @error.nil?

        render_page(:form, status: :unprocessable_content)
      end

      private

      def lookup
        setting = EinvoiceSetting.for_branch(@einvoice.branch)
        adapter = setting && Einvoices.provider_for(setting)
        found = adapter&.class&.tax_code_lookup? ? adapter.lookup_tax_code(@buyer['tax_code']) : nil
        if found
          @buyer = @buyer.merge('tax_code' => found.tax_code, 'name' => found.name.presence || @buyer['name'],
                                'address' => found.address.presence || @buyer['address']).compact
        else
          @notice = :lookup_missing
        end
        render_page(:form)
      rescue StandardError => e
        Rails.error.report(e, handled: true, context: { einvoice_id: @einvoice.id })
        @notice = :lookup_missing
        render_page(:form)
      end

      def submitted_buyer
        raw = params[:buyer].respond_to?(:to_unsafe_h) ? params[:buyer].to_unsafe_h : {}
        Einvoices::Buyer::FIELDS.each_with_object({}) do |field, result|
          value = raw[field].to_s.strip
          result[field] = value.first(Einvoices::Buyer::LIMITS.fetch(field)) if value.present?
        end
      end

      def load_invoice
        @einvoice = Einvoices::BuyerLink.find(params[:token].to_s)
        render_page(:expired, status: :not_found) if @einvoice.nil?
      end

      def page_state(reason = nil)
        return :issued if %w[issuing issued replaced].include?(@einvoice.status) || reason == Einvoices::UpdateBuyer::ISSUED
        return :issuing if reason == Einvoices::UpdateBuyer::BUSY
        return :expired unless @einvoice.buyer_link_open?

        :form
      end

      def render_page(state, status: :ok)
        @state = state
        @store_name = @einvoice&.store&.name
        render 'spree/pos/einvoice_buyer/show', status: status
      end

      def secure_headers
        response.headers['Cache-Control'] = 'no-store'
        response.headers['Referrer-Policy'] = 'no-referrer'
        response.headers['X-Content-Type-Options'] = 'nosniff'
        response.headers['X-Frame-Options'] = 'DENY'
        response.headers['Content-Security-Policy'] =
          "default-src 'none'; style-src 'unsafe-inline'; form-action 'self'; frame-ancestors 'none'; base-uri 'none'"
      end
    end
  end
end
