# frozen_string_literal: true

module Spree
  module Pos
    module DeviceApi
      # Device-token channel. No staff JWT. A mode check is explicit per action.
      class BaseController < ActionController::API
        before_action :no_store
        before_action :authenticate_device!

        rescue_from ActiveRecord::RecordNotFound do
          render json: { error: { code: 'record_not_found', message: 'Not found.' } }, status: :not_found
        end

        private

        def no_store
          response.headers['Cache-Control'] = 'no-store'
          response.headers['Referrer-Policy'] = 'no-referrer'
        end

        def authenticate_device!
          device, staff = DeviceAuthenticator.authenticate(request)
          if device.nil?
            render json: { error: { code: 'device_unauthorized', message: 'The device is not connected.' } }, status: :unauthorized
            return
          end

          @device = device
          @staff = staff
        end

        def require_mode!(*modes)
          return if modes.include?(@device.mode)

          render json: { error: { code: 'device_mode_forbidden', message: 'This device mode cannot call that.' } }, status: :forbidden
        end

        def require_staff!
          return if @staff

          render json: { error: { code: 'device_staff_required', message: 'This device needs a staff session.' } }, status: :forbidden
        end
      end
    end
  end
end
