# frozen_string_literal: true

module Spree
  module Pos
    # The public API of a guest's phone at a table (server/openapi/pos-guest.yaml).
    # Only exchanging the table's code for a session is unauthenticated, and
    # it is rate limited per client address. Everything else takes the
    # session token in `Authorization: Guest <token>`: never a staff JWT, an
    # API key or a device token, never a URL parameter. Guests' orders wait
    # for staff (GuestOrders::Submit); no money is taken here. Responses are
    # never cached and send no referrer. Same origin as the guest page, so
    # there is no CORS and no cookie.
    class GuestViewsController < ActionController::API
      SCHEME = 'Guest'
      SESSION_ATTEMPTS = 10
      ORDER_ATTEMPTS = 5
      REQUEST_ATTEMPTS = 10
      WINDOW = 1.minute
      LIMIT_STORE = Rails.cache.is_a?(ActiveSupport::Cache::NullStore) ? ActiveSupport::Cache::MemoryStore.new : Rails.cache
      RATE_LIMITED = -> { render json: { error: { code: 'rate_limited', message: 'Too many attempts. Try again in a minute.' } }, status: :too_many_requests }

      before_action :no_store
      before_action :authenticate_guest!, except: :open_session
      rate_limit to: SESSION_ATTEMPTS, within: WINDOW, only: :open_session, store: LIMIT_STORE, with: RATE_LIMITED
      rate_limit to: ORDER_ATTEMPTS, within: WINDOW, only: :create_order, store: LIMIT_STORE, by: -> { @guest_session.id }, with: RATE_LIMITED
      rate_limit to: REQUEST_ATTEMPTS, within: WINDOW, only: :create_request, store: LIMIT_STORE, by: -> { @guest_session.id },
                 with: RATE_LIMITED

      rescue_from Conflict do |error|
        render json: { error: { code: error.reason || 'conflict', message: error.message, details: guest_details(error) } }, status: :conflict
      end

      # Exchanges the code on the table for a session token.
      def open_session
        opened = GuestSessions::Open.call(table_code: params[:table_code], client_address: request.remote_ip,
                                          user_agent: request.user_agent)
        if opened.nil?
          return render json: { error: { code: 'table_code_invalid', message: 'This QR code does not work. Ask the staff.' } },
                        status: :not_found
        end

        render json: { data: session_body(opened.session).merge(token: opened.token) }, status: :created
      end

      def show_session
        render json: { data: session_body(@guest_session) }
      end

      def menu
        render json: { data: GuestMenu.call(@guest_session.branch) }
      end

      # What is already on the table's order, this phone's orders and its open requests.
      def order
        render json: { data: GuestTable.call(@guest_session) }
      end

      def create_order
        key = request.headers['Idempotency-Key'].to_s
        items = params.to_unsafe_h['items']
        order = GuestOrders::Submit.call(session: @guest_session, key: key, items: items.is_a?(Array) ? items : nil)
        render json: { data: order.to_guest }, status: :created
      end

      def create_request
        guest_request = GuestRequests::Create.call(session: @guest_session, kind: params[:kind])
        render json: { data: guest_request.to_guest }, status: :created
      end

      private

      def session_body(session)
        branch = session.branch
        {
          id: session.prefixed_id, status: session.ordering? ? 'open' : 'table_closed', expires_at: session.expires_at.iso8601,
          table: { name: session.resource.name, kind: session.resource.kind },
          branch: { name: branch.name, store_name: branch.store.name }, currency: branch.store.default_currency,
          approval: branch.qr_order_mode == 'direct_to_kitchen' ? 'direct_to_kitchen' : 'staff_approval',
          timed: session.workspace&.service_mode == 'timed'
        }
      end

      def no_store
        response.headers['Cache-Control'] = 'no-store'
        response.headers['Pragma'] = 'no-cache'
        response.headers['Referrer-Policy'] = 'no-referrer'
        response.headers['X-Content-Type-Options'] = 'nosniff'
      end

      def authenticate_guest!
        scheme, token = request.authorization.to_s.split(' ', 2)
        reason = 'session_invalid'
        @guest_session, reason = GuestSession.authenticate(token.to_s.strip) if scheme == SCHEME
        if @guest_session && !GuestOrders::Guard.enabled?(@guest_session.branch)
          @guest_session = nil
          reason = 'qr_order_unavailable'
        end
        return if @guest_session

        render json: { error: { code: reason, message: 'Scan the QR code on the table again.' } }, status: :unauthorized
      end

      # Only what a guest may read: which item, group or option is meant.
      def guest_details(error)
        details = error.details.is_a?(Hash) ? error.details.stringify_keys : {}
        details.slice('menu_item_id', 'variant_id', 'group_id', 'option_id', 'min_select', 'max_select')
      end
    end
  end
end
