# frozen_string_literal: true

module Spree
  module Api
    module V3
      module Admin
        module Pos
          # The waiter's own device, signed in with a PIN: the dishes that
          # became ready at its tables, and the tables it follows. Only a
          # device paired as `waiter`, for a person with `pos.table.serve`
          # at its branch.
          class CurrentDevicesController < BaseController
            scoped_resource :pos_orders
            pos_permissions ready_feed: %w[read_pos_orders write_pos_orders], table_pins: %w[read_pos_orders write_pos_orders],
                            pin: %w[write_pos_orders], unpin: %w[write_pos_orders]

            before_action :require_waiter_device!

            def ready_feed
              render json: { data: Spree::Pos::Kitchen::ReadyFeed.call(device: @pos_device, staff: current_user, area_id: params[:area_id]) }
            end

            def table_pins
              render json: { data: Spree::Pos::Tables::Pin.tables(@pos_device, current_user) }
            end

            def pin = change(true)
            def unpin = change(false)

            private

            def change(pinned)
              key = idempotency_key
              return if key.nil?

              result = Spree::Pos::Tables::Pin.call(device: @pos_device, staff: current_user, key: key,
                                                    resource_id: params[:resource_id], pinned: pinned)
              render json: { data: result }
            end

            def require_waiter_device!
              if @pos_device.nil? || @pos_device.mode != 'waiter'
                render_error(code: Spree::Api::V3::ErrorHandler::ERROR_CODES[:access_denied], message: 'Only a waiter device can call that.',
                             status: :forbidden, details: { reason: 'device_mode_forbidden' })
                return
              end
              return if policy.allows?(@pos_device.branch, Spree::Pos::Capabilities::TABLE_SERVE)

              render_forbidden(Spree::Pos::Capabilities::TABLE_SERVE)
            end
          end
        end
      end
    end
  end
end
