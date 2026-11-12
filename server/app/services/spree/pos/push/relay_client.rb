# frozen_string_literal: true

require 'net/http'

module Spree
  module Pos
    module Push
      # Posts one notification to the store's relay:
      #   { "platform": "fcm", "token": "...", "event": "owner_alert.created", "id": "posowneralert_..." }
      # signed with HMAC-SHA256 of "<timestamp>.<body>" under the relay key,
      # sent as `X-Parkviet-Timestamp` and `X-Parkviet-Signature`. Only the
      # event name and an id leave the server: no money, no names.
      module RelayClient
        TIMEOUT = 5
        # Raised for an answer the relay did not accept; the job retries.
        class Failed < StandardError; end

        # Tests set a callable `(uri, headers, body) -> [status, body]`,
        # so no real relay is ever contacted from a spec.
        mattr_accessor :transport

        module_function

        def deliver(setting:, registration:, event:, id:)
          post!(setting, platform: registration.platform, token: registration.token, event: event, id: id)
        end

        # A signed `relay.check` with no device, from the dashboard. Keeps
        # the outcome on the settings and raises a conflict the dashboard shows.
        def check(setting:, store:)
          post!(setting, event: 'relay.check', id: store.prefixed_id)
          setting.update_columns(last_delivered_at: Time.current, last_error: nil, last_error_at: nil)
        rescue Failed, Timeout::Error, SocketError, SystemCallError, IOError, OpenSSL::SSL::SSLError, Net::ProtocolError => e
          setting.update_columns(last_error: "#{e.class.name.demodulize}: #{e.message}".first(PushRelaySetting::ERROR_MAX),
                                 last_error_at: Time.current)
          raise Conflict.new('The push relay did not answer.', reason: 'push_relay_unreachable')
        end

        def post!(setting, fields)
          body = JSON.generate(fields)
          timestamp = Time.current.to_i.to_s
          headers = {
            'Content-Type' => 'application/json',
            'X-Parkviet-Timestamp' => timestamp,
            'X-Parkviet-Signature' => OpenSSL::HMAC.hexdigest('SHA256', setting.relay_key, "#{timestamp}.#{body}")
          }
          status, = (transport || method(:http)).call(URI.parse(setting.url), headers, body)
          raise Failed, "relay answered #{status}" unless status.to_i.between?(200, 299)

          true
        end

        def http(uri, headers, body)
          response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https',
                                                         open_timeout: TIMEOUT, read_timeout: TIMEOUT, write_timeout: TIMEOUT) do |http|
            request = Net::HTTP::Post.new(uri.request_uri, headers)
            request.body = body
            http.request(request)
          end
          [response.code.to_i, response.body]
        end
      end
    end
  end
end
