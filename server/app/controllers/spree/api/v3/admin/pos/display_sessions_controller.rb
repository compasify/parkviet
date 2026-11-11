# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Cashier side of the customer display: bind or rebind it to the
          # caller's open shift (the only response that carries the display
          # token), read its freshness, pin or clear an order and disconnect
          # it. The display itself reads through the public display route.
          # The bind response carries the token only for a display window
          # this page opens; a separate device pairs with a short code.
          class DisplaySessionsController < BaseController
            scoped_resource :pos_orders
            pos_permissions show: %w[read_pos_orders write_pos_orders], current: %w[read_pos_orders write_pos_orders]

            def create
              return if channel_rejected?

              result = Spree::Pos::Displays::Bind.call(store: current_store, staff: current_user, shift_id: params[:shift_id])
              response.headers['Cache-Control'] = 'no-store'
              render json: { data: result[:session], token: result[:token] }, status: :created
            end

            # The caller's live display of a shift, or null.
            def current
              return if channel_rejected?

              shift = Spree::Pos::Displays::Guard.own_shift!(current_store, current_user, params[:shift_id])
              session = Spree::Pos::DisplaySession.live.find_by(shift_id: shift.id, staff_id: current_user.id)
              render json: { data: session&.to_pos }
            end

            def show
              return if channel_rejected?

              render json: { data: Spree::Pos::Displays::Guard.session!(current_store, current_user, params[:id]).to_pos }
            end

            def pin
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              data = Spree::Pos::Displays::Pin.call(store: current_store, staff: current_user, key: key, session_id: params[:id],
                                                    expected_generation: params[:expected_generation],
                                                    workspace_id: params[:workspace_id], tender_attempt_id: params[:tender_attempt_id])
              render json: { data: data }
            end

            def clear
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              data = Spree::Pos::Displays::Pin.clear(store: current_store, staff: current_user, key: key, session_id: params[:id],
                                                     expected_generation: params[:expected_generation])
              render json: { data: data }
            end

            # One pinned order, or the branch's call numbers.
            def mode
              return if channel_rejected?

              key = idempotency_key
              return if key.nil?

              data = Spree::Pos::Displays::Pin.set_mode(store: current_store, staff: current_user, key: key, session_id: params[:id],
                                                        expected_generation: params[:expected_generation], mode: params[:mode])
              render json: { data: data }
            end

            # A short single-use code to pair a separate device; the display
            # token itself is never shown on the cashier screen.
            def pairing_code
              return if channel_rejected?

              data = Spree::Pos::Displays::Pairing.issue(store: current_store, staff: current_user, session_id: params[:id])
              response.headers['Cache-Control'] = 'no-store'
              render json: { data: data }, status: :created
            end

            def revoke
              return if channel_rejected?

              data = Spree::Pos::Displays::Revoke.call(store: current_store, staff: current_user, session_id: params[:id],
                                                       reason: params[:reason])
              render json: { data: data }
            end
          end
        end
      end
    end
  end
end
