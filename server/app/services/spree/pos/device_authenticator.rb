# frozen_string_literal: true

module Spree
  module Pos
    # Reads `Authorization: Device <token>` and, when present,
    # `X-Pos-Staff-Session`. Shared by the staff API, the device API and,
    # later, the branch realtime channel. A missing or revoked token is nil.
    class DeviceAuthenticator
      SCHEME = 'Device'

      def self.authenticate(request)
        scheme, token = request.authorization.to_s.split(' ', 2)
        return [nil, nil] unless scheme == SCHEME

        device = Device.authenticate(token.to_s.strip)
        return [nil, nil] if device.nil?

        device.touch_seen!
        session_token = request.headers['X-Pos-Staff-Session'].to_s.strip
        session = session_token.present? ? DeviceStaffSession.authenticate(device, session_token) : nil
        [device, session&.staff]
      end

      def self.device_request?(request)
        request.authorization.to_s.split(' ', 2).first == SCHEME
      end

      # Address embedded in a pairing QR. Phase 6 sets POS_PUBLIC_BASE_URL;
      # until then the request's own origin is the address the device can reach.
      def self.public_base_url(request)
        ENV['POS_PUBLIC_BASE_URL'].presence || request.base_url
      end

      def self.qr_payload(url, code)
        { 'v' => 1, 'kind' => 'parkviet.device', 'url' => url, 'code' => code }
      end
    end
  end
end
