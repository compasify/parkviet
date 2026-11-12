# frozen_string_literal: true

module Spree
  module Pos
    # Hands one notification to the push relay for one owner device. Retried
    # a few times with growing waits; the last error is kept on the
    # registration and the relay settings for the dashboard. A missing
    # registration or relay, or push turned off since, is a silent no-op.
    class PushDeliveryJob < ApplicationJob
      queue_as :default

      ATTEMPTS = 5
      NETWORK_ERRORS = [Push::RelayClient::Failed, Timeout::Error, SocketError, SystemCallError, IOError,
                        OpenSSL::SSL::SSLError, Net::HTTPBadResponse, Net::ProtocolError].freeze

      retry_on(*NETWORK_ERRORS, attempts: ATTEMPTS, wait: :polynomially_longer) do |job, error|
        job.record_failure(error)
      end

      def perform(registration_id, event, id)
        registration = PushRegistration.enabled.find_by(id: registration_id)
        return if registration.nil?

        setting = PushRelaySetting.for_store(registration.store)
        return if setting.nil?

        begin
          Push::RelayClient.deliver(setting: setting, registration: registration, event: event, id: id)
        rescue *NETWORK_ERRORS => e
          remember_error(registration, setting, e)
          raise
        end
        now = Time.current
        registration.update_columns(last_delivered_at: now, last_error: nil, last_error_at: nil)
        setting.update_columns(last_delivered_at: now, last_error: nil, last_error_at: nil)
      end

      def record_failure(error)
        Rails.logger.warn("[pos] push delivery gave up: #{error.class}")
      end

      private

      # The class and a short message only: never the token, key or body.
      def remember_error(registration, setting, error)
        message = "#{error.class.name.demodulize}: #{error.message}".first(PushRegistration::ERROR_MAX)
        now = Time.current
        registration.update_columns(last_error: message, last_error_at: now)
        setting.update_columns(last_error: message, last_error_at: now)
      end
    end
  end
end
