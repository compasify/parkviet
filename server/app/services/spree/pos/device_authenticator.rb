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

      # Address embedded in a pairing QR: the deployment's POS_PUBLIC_BASE_URL
      # (validated at boot by config/initializers/pos_public_url.rb), else the
      # request's own origin, which the manager's browser just reached.
      def self.public_base_url(request)
        Parkviet::PosPublicUrl.base_url || request.base_url
      end

      def self.qr_payload(url, code)
        { 'v' => 1, 'kind' => 'parkviet.device', 'url' => url, 'code' => code }
      end
    end
  end
end
