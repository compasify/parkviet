# frozen_string_literal: true

module Spree
  module Pos
    module DeviceApi
      class MeController < BaseController
        def show
          render json: {
            data: {
              device: @device.to_pos,
              branch: { id: @device.branch.prefixed_id, name: @device.branch.name, timezone: @device.branch.timezone },
              register_id: @device.register&.prefixed_id,
              kitchen_station_id: @device.kitchen_station_id,
              staff: staff_payload,
              server_time: Time.current.iso8601
            }
          }
        end

        private

        def staff_payload
          return if @staff.nil?

          { id: @staff.prefixed_id, name: @staff.full_name }
        end
      end
    end
  end
end
