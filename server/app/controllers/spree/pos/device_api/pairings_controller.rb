# frozen_string_literal: true

module Spree
  module Pos
    module DeviceApi
      # Exchanges a pairing code. Unauthenticated. Limited per client address.
      class PairingsController < ActionController::API
        PAIRING_ATTEMPTS = 10
        PAIRING_WINDOW = 1.minute
        PAIRING_LIMIT_STORE = Rails.cache.is_a?(ActiveSupport::Cache::NullStore) ? ActiveSupport::Cache::MemoryStore.new : Rails.cache

        rate_limit to: PAIRING_ATTEMPTS, within: PAIRING_WINDOW, only: :create, store: PAIRING_LIMIT_STORE,
                   with: -> { render json: { error: { code: 'pairing_rate_limited', message: 'Too many attempts.' } }, status: :too_many_requests }

        def create
          result = Devices::Pair.call(code: params[:code], platform: params[:platform], name: params[:name], app_version: params[:app_version])
          render json: { data: result }, status: :created
        rescue Conflict
          render json: { error: { code: 'pairing_invalid', message: 'The pairing code is invalid or expired.' } }, status: :not_found
        end
      end
    end
  end
end
