# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # Own PIN, or a manager clearing someone else's. The PIN itself is
          # never read back.
          class StaffPinsController < BaseController
            scoped_resource :pos_orders
            pos_permissions update: %w[write_pos_orders write_pos_topology],
                            destroy: %w[write_pos_orders write_pos_topology]

            def update
              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Devices::SetPin.call(
                store: current_store, staff: current_user, key: key,
                membership_id: params[:membership_id], pin: params[:pin]
              )
              render json: { data: result }
            end

            def destroy
              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Devices::ResetPin.call(
                store: current_store, staff: current_user, key: key, membership_id: params[:membership_id]
              )
              render json: { data: result }
            end
          end
        end
      end
    end
  end
end
