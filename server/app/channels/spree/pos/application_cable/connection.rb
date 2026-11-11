# frozen_string_literal: true

module Spree
  module Pos
    module ApplicationCable
      # Three kinds of socket: staff with the Admin API JWT (`?token=`, since a
      # browser cannot set headers on a WebSocket), a paired device, and a
      # paired device with a staff session. Device credentials travel in
      # `Sec-WebSocket-Protocol` or the query. The server only ever selects
      # Action Cable's own protocol, so a token protocol is never echoed.
      #
      # No store is resolved here: the JWT is store-agnostic, a device carries
      # its own store, and a branch names the store it belongs to.
      class Connection < ActionCable::Connection::Base
        DEVICE_PROTOCOL = 'pos-device.'
        STAFF_SESSION_PROTOCOL = 'pos-staff-session.'

        # The only identifier: RemoteConnections#where needs every identifier
        # to address a socket. Staff sockets leave it nil and so have no
        # internal channel, which nothing needs.
        identified_by :device_id

        attr_reader :principal

        delegate :kind, :device, :staff, to: :principal

        def connect
          @principal = device_token ? device_principal : staff_principal
          reject_unauthorized_connection if @principal.nil?

          self.device_id = @principal.device&.prefixed_id
        end

        private

        def device_principal
          found = Device.authenticate(device_token)
          return if found.nil?

          session = staff_session_token && DeviceStaffSession.authenticate(found, staff_session_token, touch: false)
          return if staff_session_token && session.nil?

          found.touch_seen!
          Principal.for_device(found, session)
        end

        def staff_principal
          return if staff_jwt.nil?

          found = StaffTokenReader.staff_for(staff_jwt)
          found && Principal.for_staff(found)
        end

        # Native clients send no Origin and hold a device token no web page
        # can read. A JWT always comes from a browser, so it needs an allowed
        # Origin. This is not the API's CORS check: outside development CORS
        # wants an exact match, while `AllowedOrigin#matches?` ignores the port
        # of a loopback host, and `super` also accepts Action Cable's own
        # configured origins.
        def allow_request_origin?
          origin = env['HTTP_ORIGIN']
          return device_token.present? && staff_jwt.nil? if origin.blank?

          Spree::AllowedOrigin.all.any? { |allowed| allowed.matches?(origin) } || super
        end

        def device_token
          subprotocol(DEVICE_PROTOCOL) || query('device_token')
        end

        def staff_session_token
          subprotocol(STAFF_SESSION_PROTOCOL) || query('staff_session_token')
        end

        def staff_jwt
          query('token')
        end

        def subprotocol(prefix)
          env['HTTP_SEC_WEBSOCKET_PROTOCOL'].to_s.split(/\s*,\s*/).find { |item| item.start_with?(prefix) }&.delete_prefix(prefix).presence
        end

        def query(name)
          value = request.query_parameters[name]
          value if value.is_a?(String) && value.present?
        end
      end
    end
  end
end
