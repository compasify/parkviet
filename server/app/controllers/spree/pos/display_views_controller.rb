# frozen_string_literal: true

module Spree
  module Pos
    # Public read-only channel of a customer display. Reading and
    # acknowledging accept only a display token in `Authorization: Display
    # <token>` (never a staff JWT, API key or cart token, never a URL
    # parameter). A separate device obtains its token by exchanging a short
    # single-use pairing code; that exchange is the only unauthenticated
    # action and is rate limited per client address. Responses are never
    # cached and send no referrer. Reads and acknowledgements have no rate
    # limit of their own: the token is bound to one open shift and expires.
    class DisplayViewsController < ActionController::API
      SCHEME = 'Display'
      # Pairing attempts per client address. The application cache when it
      # stores anything (Solid Cache in production); a process-local store
      # where it does not (test).
      PAIRING_ATTEMPTS = 10
      PAIRING_WINDOW = 1.minute
      PAIRING_LIMIT_STORE = Rails.cache.is_a?(ActiveSupport::Cache::NullStore) ? ActiveSupport::Cache::MemoryStore.new : Rails.cache

      before_action :no_store
      before_action :authenticate_display!, except: :pair
      rate_limit to: PAIRING_ATTEMPTS, within: PAIRING_WINDOW, only: :pair, store: PAIRING_LIMIT_STORE,
                 with: -> { render json: { error: { code: 'pairing_rate_limited', message: 'Too many attempts.' } }, status: :too_many_requests }

      def show
        render json: { data: DisplayState.call(@display) }
      end

      # The display confirms the generation it rendered, with the lease it
      # received for it. Only a lease of this session, for its current
      # generation and still inside the freshness window is accepted.
      def ack
        generation = Integer(params[:generation].to_s, exception: false)
        leased_generation, issued_at = @display.read_lease(params[:lease_id])
        return reject('lease_invalid', 'The acknowledgement lease is invalid or expired.') if leased_generation.nil?

        DisplaySession.transaction do
          @display.lock!
          if generation != leased_generation || leased_generation != @display.generation
            next reject('generation_stale', 'The acknowledged generation is not current.')
          end

          if @display.acked_generation != leased_generation || @display.acked_at.nil? || issued_at > @display.acked_at
            @display.update_columns(acked_generation: leased_generation, acked_at: issued_at, updated_at: Time.current)
          end
          render json: { data: { generation: @display.generation, acked_at: @display.acked_at.iso8601(3) } }
        end
      end

      # Exchanges a pairing code for this device's display token.
      def pair
        session, token = Displays::Pairing.exchange(params[:code])
        if session.nil?
          return render json: { error: { code: 'pairing_invalid', message: 'The pairing code is invalid or expired.' } },
                        status: :not_found
        end

        render json: { data: { token: token, session_id: session.prefixed_id, token_expires_at: session.token_expires_at.iso8601 } }
      end

      private

      def no_store
        response.headers['Cache-Control'] = 'no-store'
        response.headers['Pragma'] = 'no-cache'
        response.headers['Referrer-Policy'] = 'no-referrer'
        response.headers['X-Content-Type-Options'] = 'nosniff'
      end

      def authenticate_display!
        scheme, token = request.authorization.to_s.split(' ', 2)
        @display = DisplaySession.authenticate(token.to_s.strip) if scheme == SCHEME
        return if @display

        render json: { error: { code: 'display_unauthorized', message: 'The display is not connected.' } }, status: :unauthorized
      end

      def reject(code, message)
        render json: { error: { code: code, message: message } }, status: :conflict
      end
    end
  end
end
