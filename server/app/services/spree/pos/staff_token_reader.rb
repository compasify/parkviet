# frozen_string_literal: true

module Spree
  module Pos
    # The Admin API's own JWT rules (signature, issuer, `admin_api` audience,
    # expiry, deactivated accounts) for a caller outside a controller action.
    # Inheriting them keeps a WebSocket from ever accepting a token the API
    # would refuse. This class is never routed.
    class StaffTokenReader < Spree::Api::V3::Admin::BaseController
      def self.staff_for(token)
        new.staff_for(token)
      end

      # @return [Object, nil] the staff member, or nil for any unusable token
      def staff_for(token)
        user = find_user_from_payload(decode_jwt(token))
        user if user.is_a?(Spree.admin_user_class)
      rescue JWT::DecodeError, ActiveRecord::RecordNotFound => e
        Rails.logger.debug { "[pos] realtime token refused: #{e.class}" }
        nil
      end
    end
  end
end
